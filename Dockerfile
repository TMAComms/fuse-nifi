FROM apache/nifi:1.4.0
LABEL Name=fuse-nifi Version=1.4.0
MAINTAINER Andrei <andrei@tmacomms.com>
ENV        BANNER_TEXT="" \
           S2S_PORT=""
#FROM openjdk:8-jre
USER root
RUN echo 'Acquire::HTTP::Proxy "http://squid.tmacomms.com:3128";' >> /etc/apt/apt.conf.d/01proxy \
 && echo 'Acquire::HTTPS::Proxy "";' >> /etc/apt/apt.conf.d/01proxy

RUN apt-get update && apt-get upgrade -y
RUN apt-get update && \
    apt-get install -y software-properties-common unzip apt-utils tar zip sudo wget curl && apt-get update && \
    apt-get install -y git mercurial apt-transport-https ca-certificates git bash 

RUN mkdir /downloads /nifi  /tmac/templates /tmac/archive /tmac/flow -p
WORKDIR /downloads

# remove proxy 
RUN rm /etc/apt/apt.conf.d/01proxy
# Clean up APT when done.
RUN apt-get clean && rm -rf /source/*

# update config

#ADD conf/bootstrap.conf $NIFI_HOME/conf/bootstrap.conf
#ADD conf/logback.xml $NIFI_HOME/conf/logback.xml
# ADD conf/ssl/* /ssl/
# ADD conf/nifi.properties $NIFI_HOME/conf/nifi.properties

# add sample templates
ADD templates/ /tmac/templates/ 
RUN sudo chown -R nifi:nifi /opt/nifi

#ADD conf/nifiserver.sh /etc/service/nifi/run
#RUN chmod +x $NIFI_HOME/bin/tmac-nifi.sh
#RUN ls -l  $NIFI_HOME
#RUN chmod +x $NIFI_HOME/bin/nifi.sh 

#VOLUME /tmac/templates /tmac/archive /tmac/flow
WORKDIR $NIFI_HOME
ADD conf/tmac-nifi.sh bin/tmac-nifi.sh
RUN sudo chmod 0777 bin/tmac-nifi.sh
ADD conf/ssl/* /ssl/

RUN mkdir -p /config-base && cp -R /opt/nifi/nifi-1.4.0/conf/* /config-base/
RUN sudo chown -R nifi:nifi /config-base && sudo chmod -R 0777 /config-base

VOLUME /config-base

# Web HTTP Port & Remote Site-to-Site Ports
EXPOSE 8080 8181
# Startup NiFi
ENTRYPOINT ["bin/nifi.sh"]

CMD ["run"]
