FROM tomcat:9

COPY ./citizen.war /usr/local/tomcat/webapps/

# ENV GEO_DATABASE_URL \
#      GEO_DATABASE_USERNAME \
#      GEO_DATABASE_PASSWORD \
#      GEO_DATABASE_NAME \
#      GEO_EMAIL_LOGIN \
#      GEO_EMAIL_PASSWORD \
#      GEO_FRONTEND_URL

EXPOSE 8080
