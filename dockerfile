#reate Custom Docker Image
# Pull tomcat latest image from dockerhub
FROM tomcat:latest
 
# Maintainer
MAINTAINER "vijay"
 
# copy war file on to container
COPY ./springboot.war /usr/local/tomcat/webapps

