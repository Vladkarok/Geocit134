FROM tomcat:9

COPY ./citizen.war /usr/local/tomcat/webapps/

EXPOSE 8080
