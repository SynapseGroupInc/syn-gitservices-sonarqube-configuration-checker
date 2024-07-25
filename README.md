# syn-gitservices-sonarqube-configuration-checker
**Overview**
The SonarQube Configuration Checker is a Jenkins job designed to verify that all specified applications have SonarQube configured. If any application is missing SonarQube configuration, the job will notify the relevant team via a Slack channel and halt the build process.


**Sample configuration in Jenkins job**
sonar.projectKey=mop-ops-dev
sonar.projectName=OPSDEV
sonar.projectVersion=main
sonar.sources=${WORKSPACE}/src, ${WORKSPACE}/grails-app
sonar.exclusions=${WORKSPACE}/src/integrationtest/**/*,
${WORKSPACE}/grails-app/assets/**/*,${WORKSPACE}/grails-app/assets/stylesheets/*.css
sonar.java.binaries=${WORKSPACE}/build
sonar.projectBaseDir=${WORKSPACE}
sonar.lang.patterns.grvy=**/*.groovy
