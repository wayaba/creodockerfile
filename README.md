# Integración Continua con Jenkins
[![][ButlerImage]][website]

 - Integración continua manjeada con pipeline de Jenkins.

### Prerrequisitos

* Jenkins debe tener instalado docker.
  - Para el ejemplo se usa la imagen modificada de jenkins oficial: 
    [ppedraza/jenkins](https://hub.docker.com/r/ppedraza/jenkins/)

```
docker pull ppedraza/jenkins
```

* Servidor de SonarQube instalado con plugin de ESQL (es un jar).
  - El server lo obtengo de una image de docker 
   [sonarqube](https://hub.docker.com/_/sonarqube/)
```
docker pull sonarqube
docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 sonarqube
```

Una vez que sonarqube este running, pegar el jar (esql-plugin-2.3.3.jar) en la carpeta plugins
```
docker cp "C:\tmp\esql-plugin-2.3.3.jar" sonarqube:/opt/sonarqube/extensions/plugins
```
### Pasos

A step by step series of examples that tell you how to get a development env running

Say what the s

```
Give the example
```

And repeat

```
until finished
```

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
