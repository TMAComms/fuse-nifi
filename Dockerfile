#FROM tmacregistry-tmacomms.azurecr.io/tmacomms/fuse-nifi:150base
FROM apache/nifi:1.5.0
LABEL Name=fuse-nifi Version=1.5.0
#FROM openjdk:8-jre
ENV NIFI_HOME=/opt/nifi/nifi-1.5.0
ENV NIFI_BASE=/opt/nifi
USER root
#RUN echo 'Acquire::HTTP::Proxy "http://squid.tmacomms.com:3128";' >> /etc/apt/apt.conf.d/01proxy \
# && echo 'Acquire::HTTPS::Proxy "";' >> /etc/apt/apt.conf.d/01proxy

RUN apt-get update && apt-get upgrade -y
RUN apt-get update && \
    apt-get install -y software-properties-common unzip apt-utils tar zip sudo wget curl && apt-get update 
RUN apt-get install -y git mercurial apt-transport-https ca-certificates git bash ncdu dos2unix nano  



LABEL Name=fuse-nifi Version=1.5.0
#FROM openjdk:8-jre
ENV NIFI_HOME=/opt/nifi/nifi-1.5.0
ENV NIFI_BASE=/opt/nifi
#USER root


#ADD conf/bootstrap.conf $NIFI_HOME/conf/bootstrap.conf
#COPY config/nifi/authorizers.xml $NIFI_HOME/conf/authorizers.xml
#COPY config/nifi/nifi.properties $NIFI_HOME/conf/nifi.base.properties
#COPY config/nifi/nifi.openid.properties $NIFI_HOME/conf/nifi.properties
COPY config/nifi/logback.xml $NIFI_HOME/conf/logback.xml
#COPY config/nifi/bootstrap.conf $NIFI_HOME/conf/bootstrap.conf

# add sample templates
#ADD templates/ $NIFI_HOME/conf/templates/ 
#RUN sudo chown -R nifi:nifi /opt/nifi


# update config
# copy a base versio of config 
# create a copy of the base config
#RUN mkdir -p /config/base/ && cp -R $NIFI_HOME/conf/* /config/base && sudo chown -R nifi:nifi /config && sudo chmod -R 0777 /config



WORKDIR $NIFI_HOME
#ADD config/tmac-nifi.sh bin/tmac-nifi.sh
#RUN sudo chmod 0777 bin/tmac-nifi.sh
#ADD config/ssl/* /ssl/

VOLUME /config

# Web HTTP Port & Remote Site-to-Site Ports
EXPOSE 8080 8181 8443
# Startup NiFi
#ENTRYPOINT ["/opt/nifi/nifi-1.5.0/bin/tmac-nifi.sh"]
#USER nifi

#CMD ""

