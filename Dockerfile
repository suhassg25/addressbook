FROM tomcat:9

# Remove default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your WAR
COPY target/addressbook.war /usr/local/tomcat/webapps/ROOT.war
