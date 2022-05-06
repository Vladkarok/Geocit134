FROM tomcat:9

COPY ./citizen.war /usr/local/tomcat/webapps/

ENV DATABASE_URL=db \
     DB_USERNAME=username \
     DB_PASSWORD=password \
     DB_NAME=somename \
     EMAIL_LOGIN=examplecom \
     EMAIL_PASSWORD=emailpassword \
     FRONTEND_URL=someurl

EXPOSE 8080
