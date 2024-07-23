#!/bin/bash
#****************************************************************
#Name:		    	check_sonarqube.ksh
#Written by:		Mithun Gowda R
#Date:		    	July 23, 2024
#Description:		The SonarQube Configuration Checker is a Jenkins job designed to verify that all specified applications have SonarQube configured. If any application is missing SonarQube configuration, the job will notify the relevant team via a Slack channel and halt the build process.
#Modifications:
#  Date			   Name		        Description
#---------- 	  ------------	    -------------------------
#************************************************************************
#Read the applications from the properties file
applications_file="/home/jenkins/.jenkins/jobs/SonarQube Configuration Checker/applications.properties"
if [ -f "$applications_file" ]; then
    applications_string=$(grep 'applications=' "$applications_file" | cut -d'=' -f2)
    IFS=',' read -r -a applications <<< "$applications_string"
else
    echo "Applications properties file not found!"
    exit 1
fi

#applications=("*_EAR_*" "*_WAR_*")

# fetch all jobs in Jenkins
jenkins_jobs_dir="/home/jenkins/.jenkins/jobs"
all_jobs=($(ls "$jenkins_jobs_dir"))

sonarqube_missing_apps=()

#check if an element is in an array
contains_element () {
  local element
  for element in "${@:2}"; do [[ "$element" == "$1" ]] && return 0; done
  return 1
}

# match patterns with exact keyword
matches_pattern() {
    local job="$1"
    local pattern="$2"
    if [[ "$pattern" == *'*'* ]]; then
        if [[ "$job" =~ ${pattern//\*/[^/]*} ]]; then
            return 0
        fi
    fi
    return 1
}

# Check each application's configuration
for app in "${applications[@]}"
do
    if [[ "$app" == *'*'* ]]; then
        # wildcard pattern checks
        for job in "${all_jobs[@]}"; do
            if matches_pattern "$job" "$app"; then
                if ! grep -q 'SonarQube' "$jenkins_jobs_dir/$job/config.xml"; then
                    echo "SonarQube is not configured for $job"
                    sonarqube_missing_apps+=("$job")
                fi
            fi
        done
    else
        # Handle specific application name
        if contains_element "$app" "${all_jobs[@]}"; then
            if ! grep -q 'SonarQube' "$jenkins_jobs_dir/$app/config.xml"; then
                echo "SonarQube is not configured for $app"
                sonarqube_missing_apps+=("$app")
            fi
        else
            echo "Job $app does not exist in Jenkins"
        fi
    fi
done

# Write missing applications to a properties file
> sonarqube_missing_apps.properties
for app in "${sonarqube_missing_apps[@]}"
do
    echo "$app" >> sonarqube_missing_apps.properties
done

# Check the results and exit with appropriate status
if [ ${#sonarqube_missing_apps[@]} -eq 0 ]; then
    echo "All applications have SonarQube configured."
else
    echo "SonarQube is missing in the following applications: ${sonarqube_missing_apps[*]}"
    exit 1  # Exit with non-zero status to mark the build as failure
fi

