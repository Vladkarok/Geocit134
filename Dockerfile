FROM tomcat:9

COPY ./citizen.war /usr/local/tomcat/webapps/

ENV DATABASE_URL \
     DB_USERNAME \
     DB_PASSWORD \
     DB_NAME \
     EMAIL_LOGIN \
     EMAIL_PASSWORD \
     FRONTEND_URL

EXPOSE 8080
