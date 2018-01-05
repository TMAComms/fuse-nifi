FROM apache/nifi:1.4.0
LABEL Name=fuse-nifi Version=1.4.0
#FROM openjdk:8-jre
ENV NIFI_HOME=/opt/nifi/nifi-1.4.0
ENV NIFI_BASE=/opt/nifi
USER root
#RUN echo 'Acquire::HTTP::Proxy "http://squid.tmacomms.com:3128";' >> /etc/apt/apt.conf.d/01proxy \
# && echo 'Acquire::HTTPS::Proxy "";' >> /etc/apt/apt.conf.d/01proxy

RUN apt-get update && apt-get upgrade -y
RUN apt-get update && \
    apt-get install -y software-properties-common unzip apt-utils tar zip sudo wget curl && apt-get update 
RUN apt-get install -y git mercurial apt-transport-https ca-certificates git bash ncdu dos2unix nano  

RUN mkdir /downloads /nifi  /tmac/templates /tmac/archive /tmac/flow /baseconfig/original/ /opt/toolkit -p
WORKDIR /downloads


#toolkit
RUN wget --show-progress --progress=bar:force --no-cookies --no-check-certificate -O /downloads/nifi-toolkit-1.4.0-bin.tar.gz http://apache.melbourneitmirror.net/nifi/1.4.0/nifi-toolkit-1.4.0-bin.tar.gz
RUN tar -xzvf /downloads/nifi-toolkit-1.4.0-bin.tar.gz -C /opt/toolkit --strip-components=1 && rm /downloads/nifi-toolkit-1.4.0-bin.tar.gz 


# remove proxy 
#RUN rm /etc/apt/apt.conf.d/01proxy
# Clean up APT when done.
RUN apt-get clean && rm -rf /source/*

# update config
# copy a base versio of config 
# create a copy of the base config
RUN mkdir -p /config-base/original && cp -R $NIFI_HOME/conf/* /config-base/original/
RUN sudo chown -R nifi:nifi /config-base && sudo chmod -R 0777 /config-base

#ADD conf/bootstrap.conf $NIFI_HOME/conf/bootstrap.conf
#ADD conf/logback.xml $NIFI_HOME/conf/logback.xml
# ADD conf/ssl/* /ssl/
COPY config/nifi/authorizers.xml $NIFI_HOME/conf/authorizers.xml
COPY config/nifi/nifi.properties $NIFI_HOME/conf/nifi.base.properties
COPY config/nifi/nifi.openid.properties $NIFI_HOME/conf/nifi.properties
COPY config/nifi/logback.xml $NIFI_HOME/conf/logback.xml
#COPY config/nifi/bootstrap.conf $NIFI_HOME/conf/bootstrap.conf

# add sample templates
ADD templates/ /tmac/templates/ 
#RUN sudo chown -R nifi:nifi /opt/nifi

#ADD conf/nifiserver.sh /etc/service/nifi/run
#RUN chmod +x $NIFI_HOME/bin/tmac-nifi.sh
#RUN ls -l  $NIFI_HOME
#RUN chmod +x $NIFI_HOME/bin/nifi.sh 

#VOLUME /tmac/templates /tmac/archive /tmac/flow
WORKDIR $NIFI_HOME
ADD config/tmac-nifi.sh bin/tmac-nifi.sh
RUN sudo chmod 0777 bin/tmac-nifi.sh
ADD config/ssl/* /ssl/

# create a copy of the base config
RUN mkdir -p /config-base && cp -R /opt/nifi/nifi-1.4.0/conf/* /config-base/
RUN sudo chown -R nifi:nifi /config-base && sudo chmod -R 0777 /config-base

VOLUME /config-base

# Web HTTP Port & Remote Site-to-Site Ports
EXPOSE 8080 8181 8443
RUN echo "starting from ${NIFI_HOME}"  
# Startup NiFi
ENTRYPOINT ["/opt/nifi/nifi-1.4.0/bin/tmac-nifi.sh"]
#USER nifi

CMD ""

