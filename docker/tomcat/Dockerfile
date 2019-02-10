FROM tomcat:latest

ADD dist/ /root/dist/

RUN mv /root/dist/context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml && \
    mv /root/dist/tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml
