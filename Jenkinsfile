
def projectVarsEDI = loadProjectVariablesEDI()
def projectVarsWWW = loadProjectVariablesWWW()

pipeline {
  agent any
  parameters {
    choice(name: 'ENVIRONMENT', choices:  listEnvironments(projectVarsWWW), description: 'The target environment')
    booleanParam(name: 'DEPLOY_EDI', defaultValue: false, description: 'Deploy SCHEMA to EDI  ')
    booleanParam(name: 'DEPLOY_WWW', defaultValue: false, description: 'Deploy SCHEMA to WWW')
  }
  stages {
    stage('Clean Target') {
      steps {
        sh """
        rm -rdf target
        mkdir target
        """
      }
    }
    stage('Build'){
    steps{
        sh """
        mkdir target/schema
        mkdir target/schemaModules
        cp schema target/schema -rf
        cp xmetal/. target/schema/schema -rf
        cp schemaModules target/schemaModules -rf
        cp appspec.yml target/appspec.yml                 
        """
      }
    }

    stage('Upload'){
      parallel {
        stage('Upload to EDI'){
          steps {
            uploadToBucket(projectVarsEDI,params.ENVIRONMENT,"SCHEMA")
          }
        }
        stage('Upload to WWW'){
          steps {
            uploadToBucket(projectVarsWWW,params.ENVIRONMENT,"SCHEMA")
          }
        }
      }
    }

    stage('Deploy'){
      parallel {
        stage('Deploy to EDI'){
          when{
            expression { params.DEPLOY_EDI == true }
          }
          steps {
            initiateDeployment(projectVarsEDI,params.ENVIRONMENT,"SCHEMA")
          }
        }
        stage('Deploy to WWW'){
          when{
            expression { params.DEPLOY_WWW == true }
          }
          steps {
            initiateDeployment(projectVarsWWW,params.ENVIRONMENT,"SCHEMA")
          }
        }
      }
    }

  }
  post{
    success {
      notify(projectVarsEDI,"success")
      notify(projectVarsWWW,"success")
    }
    failure {
      notify(projectVarsEDI,"failure")
      notify(projectVarsWWW,"failure")
    }
  }
}

def runAnt(antCall){
  withAnt(installation: "LegislationAnt"){
    sh "ant ${antCall}"
  }
}

//Functions

def loadProjectVariablesWWW(){
  node {
    def projectName = "tna.legislation.website"
    def variables = readJSON file: "/jenkins/projects/${projectName}.json"
    return variables
  }
}

def loadProjectVariablesEDI(){
  node {
    def projectName = "tna.legislation.editorial"
    def variables = readJSON file: "/jenkins/projects/${projectName}.json"
    return variables
  }
}


def listEnvironments(json){
  def environments = []
  Iterator it = json.keys();
  while (it.hasNext()) {
    String key = (String) it.next()
    if (key != "environments") {
      environments << key
    }
  }
  return environments
}

def deploymentFile(){
  return "${BRANCH_NAME}/${BUILD_NUMBER}.zip"
}

def uploadToBucket(project,environment,group){
  echo "Upload Artefact to S3"
  def env = project[environment]
  withAWS(roleAccount:env["accountId"], role: "Jenkins-${env["region"]}") {
    sh """aws deploy push --application-name ${env["application"]} \
          --s3-location s3://${env["bucket"]}.${env["region"]}.mgmt/deploy/${env["application"]}/${group}/${deploymentFile()} \
          --source target --region ${env["region"]}"""
  }
}

def initiateDeployment(project,environment,group){
  def env = project[environment]
  withAWS(roleAccount:env["accountId"], role: "Jenkins-${env["region"]}") {
    createDeployment( s3Bucket: "${env["bucket"]}.${env["region"]}.mgmt",
                      s3Key:"deploy/${env["application"]}/${group}/${deploymentFile()}",
                      s3BundleType:"zip",
                      applicationName: "${env["application"]}",
                      deploymentGroupName: "${env["application"]}-${group}",
                      fileExistsBehavior: "OVERWRITE",
                      waitForCompletion: true,
                      description: "Branch: ${BRANCH_NAME}, Build Number: ${BUILD_NUMBER}"
                    )
  }
}

def notify(project,status){
  echo "${status}"
}

