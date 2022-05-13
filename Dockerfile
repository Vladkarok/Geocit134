FROM bitnami/tomcat:9.0

COPY ./citizen.war /opt/bitnami/tomcat/webapps

EXPOSE 8080
