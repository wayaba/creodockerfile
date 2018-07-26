#!/bin/bash


//CLAVEEE INSTALAR ESTE PLUGIN
//Pipeline Utility Steps

properties = null


def loadProperties(String env='tuvieja') {
    node {
        checkout scm
		echo "Archivo leido ${env}.properties"
		def envFile = "${env}.properties"
        //properties = readProperties file: '${env}.properties'
		properties = readProperties file: envFile
        echo "valor url:  ${properties.url}"
		echo "valor puerto: ${properties.puerto}"
    }
}

pipeline {

	agent any

	tools { 
        gradle 'gradle-jenkins' 
    }
	
	parameters {
        string(name: 'mqsihome', defaultValue: '/opt/ibm/ace-11.0.0.0', description: '')
		string(name: 'workspacesdir', defaultValue: '/var/jenkins_home/workspace/creodockerfile', description: '')
		string(name: 'appname', defaultValue: 'ApiMascotas', description: '')
		choice(name: 'environment', choices: "desa\ntest\nprod", description: 'selecciona el ambiente' )
    }

	stages {
	/*
		stage('SonarQube analysis') {
			steps {
				script {
					def scannerHome = tool 'sonnar-jenkins'
					withSonarQubeEnv('sonarqube') {
						sh "${scannerHome}/bin/sonar-scanner \
										-Dsonar.projectKey=esqpipeline \
										-Dsonar.projectname=Esqpipeline \
										-Dsonar.projectVersion=1 \
										-Dsonar.sources=. \
										-Dsonar.language=esql"
					}
				}
			}
		}
		*/
		/*
		stage('Compilacion')
			{
				agent {
					docker { image 'ibmcom/ace:latest' 
							args '-e LICENSE=accept'
					}
				}
				steps{
						echo "EJECUTO ${params.mqsihome}/server/bin/mqsipackagebar -w ${params.workspacesdir} -a ${params.workspacesdir}/abc.bar -k ${params.appname}"
						sh "${params.mqsihome}/server/bin/mqsipackagebar -w ${params.workspacesdir} -a ${params.workspacesdir}/abc.bar -k ${params.appname}"
					}
					
			}
			*/
		stage('Load Env Parameters')
		{
			steps{
				script{
					loadProperties(params.environment)
				}
			}
		}
		stage('Replaces')
			{
				steps{
						//sh "docker build -t sarasa . -ARGS puerto=$properties.puerto url=$"
						//sh "docker build -t sarasa ."
						//sh "cat ${params.workspacesdir}/${params.appname}/connections/odbc.ini"
						
						echo "Realizo replace en odbc.ini"
						
						sh "cat ${params.workspacesdir}/${params.appname}/connections/odbc.ini | \
							sed -e 's,#SQLLOCAL.port#,${properties.'SQLLOCAL.port'},' \
								-e 's,#SQLLOCAL.database#,${properties.'SQLLOCAL.database'},' \
								-e 's,#SQLLOCAL.hostname#,${properties.'SQLLOCAL.hostname'},' \
								-e 's,#SQLLOCAL.installdir#,${params.mqsihome},' \
							> /tmp/odbc.ini"
						
						sh "cp /tmp/odbc.ini ${params.workspacesdir}"
					}
					
			}
		stage('Build Image')
		{
			steps{
				sh "docker build -t sarasa ."
			}
		}
		
		/*
		stage('Deploy')
			{
				agent {
					docker { image 'ibmcom/iib:latest' 
							args '-u 0:0 -e LICENSE=accept -e NODENAME=DesaDocker1 -e SERVERNAME=MiSERVER1'
					}
				}
				steps{
						echo "EJECUTO ${params.mqsihome}/server/bin/mqsideploy -i http://192.168.99.100 -p 4415 -a ${params.barname} -e ungrupo"
						sh "${params.mqsihome}/server/bin/mqsideploy -i 192.168.99.100 -p 4415 -a ${params.barname} -e ungrupo"
					}
					
			}

		stage('Test')
			{
			
				steps{
						echo 'Ejecuto la validacion de SPOCK'
						sh 'gradle clean test'
						
					}
			
				
			}
			
			
		stage('Pruebo parametros de ambiente')
			{
			
				steps {
					script {
						loadProperties(params.environment)
						echo "Later one ${properties.puerto}"
						}
				}
			
				
			}
		*/	
	}
}