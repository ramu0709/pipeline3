node {
    def mavenHome = tool name: "Maven 3.9.9"

    buildName "pipe - #${BUILD_NUMBER}"
    echo "✅ Job: ${env.JOB_NAME}, Node: ${env.NODE_NAME}"

    properties([
        buildDiscarder(logRotator(numToKeepStr: '2')),
        pipelineTriggers([githubPush()])
    ])

    stage('✅ Checkout Code') {
        git branch: 'main',
            credentialsId: '9c54f3a6-d28e-4f8f-97a3-c8e939dcc8ff',
            url: 'https://github.com/ramu0709/pipeline3.git'
    }

    def branchName = env.BRANCH_NAME ?: sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
    echo "✅ Git Branch: ${branchName}"

    stage('✅ Build') {
        sh "${mavenHome}/bin/mvn clean package" // no mvn deploy
    }

    stage('✅ SonarQube') {
        withSonarQubeEnv('SonarQube') {
            // Make sure you have created the 'sonarqube-token' credentials in Jenkins as a secret text
            withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                sh """
                    ${mavenHome}/bin/mvn sonar:sonar -Dsonar.login=${SONAR_TOKEN}
                """
            }
        }
    }

    stage('✅ Code Coverage - JaCoCo') {
        jacoco buildOverBuild: true,
            changeBuildStatus: true,
            minimumBranchCoverage: '80',
            minimumClassCoverage: '80',
            minimumMethodCoverage: '80',
            minimumLineCoverage: '80',
            minimumInstructionCoverage: '80',
            minimumComplexityCoverage: '80'
    }

    stage('✅ Upload to Nexus') {
        def repository = (branchName == "main" || branchName == "master") ? "sample-release" : "sample-snapshot"
        def version = (branchName == "main" || branchName == "master") ? "0.0.1" : "0.0.1-SNAPSHOT"

        nexusArtifactUploader artifacts: [[
            artifactId: 'maven-web-application',
            classifier: '',
            file: 'target/maven-web-application.war',
            type: 'war'
        ]],
        credentialsId: 'nexus-credentials',
        groupId: 'Batman',
        version: version,
        repository: repository,
        nexusUrl: 'http://172.21.40.70:8081',
        nexusVersion: 'nexus3',
        protocol: 'http'
    }

    stage('✅ Deploy to Tomcat') {
        sh 'sudo cp target/maven-web-application.war /opt/tomcat/webapps/'
    }
}
