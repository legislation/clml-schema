def projectVars = loadProjectVariables()
pipeline {
  agent any
  parameters {
    choice(name: 'ENVIRONMENT', choices:  listEnvironments(projectVars), description: 'The target environment')
    booleanParam(name: 'DEPLOY_SCHEMA', defaultValue: false, description: 'Deploy SCHEMA code to server')
  }
  stages{
    stage('Clean Target') {
      steps {
        sh """
			rm -rdf target
			mkdir target
		"""
      }
    }
   stage('Build and Upload SCHEMA'){
	  steps{
        sh """
        mkdir target/schema
		mkdir target/schemaModules
        cp schema target/schema -rf
		cp schemaModules target/schemaModules -rf
		cp appspec.yml target/appspec.yml                 
		"""
		uploadToBucket(projectVars,params.ENVIRONMENT,"SCHEMA")
	  }
	}

    stage('Deploy SCHEMA'){
	  when{
		expression { params.DEPLOY_SCHEMA == true }
	  }
	  steps {
		initiateDeployment(projectVars,params.ENVIRONMENT,"SCHEMA")
	  }
	}
  }
  post{
    success {
      notify(projectVars,"success")
    }
    failure {
      notify(projectVars,"failure")
    }
  }
}

def runAnt(antCall){
  withAnt(installation: "LegislationAnt"){
    sh "ant ${antCall}"
  }
}

//Functions

def loadProjectVariables(){
  node {
    projectName = "tna.legislation.website"
    variables = readJSON file: "/jenkins/projects/${projectName}.json"
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
  env = project[environment]
  withAWS(roleAccount:env["accountId"], role: "Jenkins-${env["region"]}") {
    sh """aws deploy push --application-name ${env["application"]} \
          --s3-location s3://${env["bucket"]}.${env["region"]}.mgmt/deploy/${env["application"]}/${group}/${deploymentFile()} \
          --source target --region ${env["region"]}"""
  }
}

def initiateDeployment(project,environment,group){
  env = project[environment]
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

