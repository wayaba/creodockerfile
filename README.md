# Integración Continua con Jenkins
[![][ButlerImage]][website]

 - Integración continua manjeada con pipeline de Jenkins.

## Prerrequisitos

* Jenkins debe tener instalado docker.
  - Para el ejemplo se usa la imagen modificada de jenkins oficial: 
    [ppedraza/jenkins](https://hub.docker.com/r/ppedraza/jenkins/)

```
docker pull ppedraza/jenkins
docker run --name jenkins -p 8080:8080 -p 50000:50000 -P ppedraza/jenkins
```

* Servidor de SonarQube instalado con plugin de ESQL (es un jar).
  - El server lo obtengo de una image de docker 
   [sonarqube](https://hub.docker.com/_/sonarqube/)
```
docker pull sonarqube
docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 sonarqube
```

Una vez que sonarqube este running, pegar el jar [(esql-plugin-2.3.3.jar)](https://github.com/EXXETA/sonar-esql-plugin/releases/download/2.3.3/esql-plugin-2.3.3.jar) en la carpeta plugins
```
docker cp "C:\tmp\esql-plugin-2.3.3.jar" sonarqube:/opt/sonarqube/extensions/plugins
```
## Pasos :feet:

## <a name="configsonar"></a>Configuracion de Sonarqube
En SonarQube crear un nuevo proyecto
Administration->Projects->Management->Create Project

Ingresar Datos para la creacion (Ejemplo)
```
 Name : projSonarDoc
 Key  : projSonarDoc
 Visibility: Public
```
Por otro lado dentro de SonarQube crear un nuevo usuario con token
Administration->Security->Users->Create User

Ingresar Datos para la creacion (Ejemplo)
```
 Login: Userjenkins
 Name: Userjenkins
 Pass: Userjenkins
```
Luego de crearlo ir a "Update Tokens" dentro del usuario

En Generate Tokens ingresar la key del proyeto creado anteriormente "projSonarDoc" y generar
```
Token generado: 31ee76df78c1475c4b347aa0db46498a987c28ed
```
## Configuracion Sonarqube en Jenkins

* En Jenkins instalar el plugin "SonarQube Scanner"

Dentro de Manage Jenkins->Global Tool Configuration
En la seccion SonarQube Scanner agregar un SonarQube Scanner presionando el boton de Add
Ingresar (por ejemplo)
```
Name : sonnar-jenkins
- [x] Install automatically
```
y guardar los cambios :heavy_check_mark:

Luego dentro de Manage Jenkins->Configure System agregar el vinculo al servidor de sonarQube previamente instalado.
En la seccion SonarQube servers agregar los datos del servidor (por ejemplo)
- Environment variables
```
- [x]  Enable injection of SonarQube server configuration as build environment variables
```
- SonarQube installations
```
 Name : sonarqube
 Server URL : http://192.168.99.100:9000
 Server authentication token : 31ee76df78c1475c4b347aa0db46498a987c28ed (el token generado anteriormente en el server de sonar)
```
y guardar los cambios :heavy_check_mark:

## Generacion nuevo item en Jenkins

En Jenkins->New Item
Ingresar Nombre del nuevo item y seleccionar el tipo Pipeline

La idea es que el codigo del pipeline este escrito dentro del codigo descargado de git en cada proyecto

Una vez creado el nuevo item, bajar hasta la seccion Pipeline y seleccionar lo siguiente:

```
Definition : Pipeline script from SCM
SCM : Git

Repositories
	Repository URL : https://github.com/repo/proyecto.git
	Credentials : (cargar las credenciales de git cargadas en Jenkins)
Branches to build
	Branch Specifier (blank for 'any') : */master 
Repository browser: (Auto)
Script Path : Jenkinsfile (el nombre del archivo con el pipeline en el root del proyecto)
Lightweight checkout: checked
```
y guardar los cambios :heavy_check_mark:

## Codificacion de Jenkinsfile con pipeline

En el pipeline se definen los stages que indican los pasos a seguir en la integracion. Si falla uno, da FAILURE y no se continua con los siguientes.

### Parametros
Se escribe al comienzo del pipeline y especifica los parametros de entrada para la llamada desde jenkins
Los valores por defecto deberian cambiar con cada proyecto

Ejemplo:
```
parameters {	
	string(name: 'mqsihome', defaultValue: '/opt/ibm/ace-11.0.0.0', description: '')
	string(name: 'workspacesdir', defaultValue: '/var/jenkins_home/workspace/imagenconbar', description: '')
	string(name: 'appname', defaultValue: 'ApiMascotas', description: '')
	string(name: 'version', defaultValue: '9999', description: '1.0')
	choice(name: 'environment', choices: "desa\ntest\nprod", description: 'selecciona el ambiente' )
	}
```

### Stage SonarQube :satellite:
Dentro de este stage se configura la vinculacion del proyecto de sonar con el server configurado en jenkins

De esta forma los valores del ejemplo corresponden a:

 - sonnar-jenkins : Nombre del sonar scanner configurado dentro de Jenkins en Manage Jenkins->Global Tool Configuration
 - sonarqube : Nombre del servidor de Sonar configurado dentro de Jenkins en Manage Jenkins->Configure System
 - Dsonar.projectKey : Key creado dentro del proyecto en el servidor de SonarQube [Link](#configsonar)
 - Dsonar.projectname : Key creado dentro del proyecto en el servidor de SonarQube (Configuracion de Sonarqube)
 - Dsonar.sources : Indica la ruta dentro del proyecto los archivos a escanear
 - Dsonar.language : el lenguaje que se quiere validar. En este caso ESQL (esql-plugin-2.3.3.jar)

Ejemplo:
```
steps {	
	script {
		def scannerHome = tool 'sonnar-jenkins'
		withSonarQubeEnv('sonarqube') {
			sh "${scannerHome}/bin/sonar-scanner \
			-Dsonar.projectKey=projSonarDoc \
			-Dsonar.projectname=ProjSonarDoc \
			-Dsonar.projectVersion=1 \
			-Dsonar.sources=. \
			-Dsonar.language=esql"
		}
	}
}
```

### Stage Compilacion :truck:
En este stage con el codigo bajado de Git, se genera para el BAR a deployar

Se ejecuta la llamada a la imagen de broker oficial v11 (ibmcom/ace:latest) 
Para armar el entorno de ejecucion y poder correr el comando mqsipackagebar 
A este comando se le pasan los siguientes parametros

-w : ruta del workspace de trabajo (parametro desde Jenkins)
-a : nombre del bar (el nombre es lo de menos, lo importante es la ruta donde se va a crear. En este caso en el workspace)
-k : el nombre de la aplicacion a compilar dentro del workspace

Ejemplo
```
stage('Compilacion')
		{
			agent {
				docker { image 'ibmcom/ace:latest' 
						args '-e LICENSE=accept'
				}
			}
			steps{
					sh "${params.mqsihome}/server/bin/mqsipackagebar -w ${params.workspacesdir} -a ${params.workspacesdir}/abc.bar -k ${params.appname}"
				}
					
		}
```
NOTA: Una vez que termina el stage compilacion, el entorno generado con la llamada al docker de ibm, se cierra.

### Stage Build Image :package:

End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc

[ButlerImage]: https://jenkins.io/sites/default/files/jenkins_logo.png
[website]: https://jenkins.io/
