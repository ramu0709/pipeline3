FROM tomcat:9.0-jdk17
COPY target/maven-web-application.war /usr/local/tomcat/webapps/maven-web-application.war
