FROM container-registry.oracle.com/middleware/weblogic:12.2.1.3-dev

ADD dist/ /root/dist/

USER root

RUN mkdir -p /u01/oracle/properties && \
    mv /root/dist/domain.properties /u01/oracle/properties/domain.properties
