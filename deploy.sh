#!/bin/bash


# Build the project
cd ~/Projects/TritonLink/tritonlink
mvn clean package

sleep 2

# Copy the war file to the tomcat server
cp target/tritonlink.war ~/Downloads/apache-tomcat-10.1.8/webapps

sleep 1

# Start the tomcat server
$CATALINA_HOME/bin/startup.sh

# sleep 1

# # Open the local server
open http://localhost:8080/tritonlink/