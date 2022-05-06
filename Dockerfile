FROM tomcat:9

COPY ./citizen.war /usr/local/tomcat/webapps/

ENV DATABASE_URL=db \
     DB_USERNAME=username \
     DB_PASSWORD=password \
     DB_NAME=some_name \
     EMAIL_LOGIN=example@com \
     EMAIL_PASSWORD=emailpassword \
     FRONTEND_URL=some.url \
 
EXPOSE 8080
