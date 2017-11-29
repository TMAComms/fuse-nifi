#FROM tmacregistry-tmacomms.azurecr.io/tmacomms/basejdk8:latest
FROM openjdk:8-jre 
LABEL Name=fuse-nifi Version=1.4.0
MAINTAINER Andrei <andrei@tmacomms.com>
ENV        BANNER_TEXT="" \
           S2S_PORT=""
USER root
RUN apt-get update &&   apt-get install -y apt-transport-https ca-certificates wget nano
RUN wget -S -nc -progress=dot -O /usr/local/share/ca-certificates/tmac-devops.crt  https://caddy.tmacomms.com/myca.crt

ENV http_proxy="http://squid.tmacomms.com:3128"
ENV https_proxy="http://squid.tmacomms.com:3128"
ENV no_proxy="127.0.0.1, localhost, *.tmacomms.com, *.calljourney.com"
RUN update-ca-certificates

RUN apt-get update && \
    apt-get install -y software-properties-common unzip tar zip sudo wget curl \
                      mercurial apt-transport-https ca-certificates git nano sudo

# Get CrushFTP 7
RUN mkdir -m 0755 /downloads/baseconfig /tmac/templates  /ssl  -p 


ARG UID=1000
ARG GID=1000
ARG NIFI_VERSION=1.4.0
ARG MIRROR=http://archive.apache.org/dist
ARG NIFI_HOME=/opt/nifi 
ENV NIFI_HOME=/opt/nifi 


# Setup NiFi user
RUN groupadd -g $GID nifi || groupmod -n nifi `getent group $GID | cut -d: -f1` \
    && useradd --shell /bin/bash -u $UID -g $GID -m nifi \
    && mkdir -p $NIFI_HOME/conf/templates \
    && chown -R nifi:nifi $NIFI_HOME \
    && chown -R nifi:nifi /downloads \
    && chown -R nifi:nifi /ssl \
    && chown -R nifi:nifi /tmac 


#USER nifi

# Download, validate, and expand Apache NiFi binary.
RUN wget -N --show-progress --progress=bar:force --no-cookies --no-check-certificate -O /downloads/nifi-1.4.0-bin.tar.gz http://apache.melbourneitmirror.net/nifi/1.4.0/nifi-1.4.0-bin.tar.gz 
RUN tar -xzvf /downloads/nifi-1.4.0-bin.tar.gz -C $NIFI_HOME --strip-components=1 && rm /downloads/nifi-1.4.0-bin.tar.gz

#toolkit
RUN wget --show-progress --progress=bar:force --no-cookies --no-check-certificate -O /downloads/nifi-toolkit-1.4.0-bin.tar.gz http://apache.melbourneitmirror.net/nifi/1.4.0/nifi-toolkit-1.4.0-bin.tar.gz
RUN tar -xzvf /downloads/nifi-toolkit-1.4.0-bin.tar.gz -C $NIFI_HOME --strip-components=1 && rm /downloads/nifi-toolkit-1.4.0-bin.tar.gz
# && rm -rf /downloads/*

#USER nifi
RUN ls -l
RUN ls -l $NIFI_HOME


# backup base conifg
RUN sudo cp -r $NIFI_HOME/conf/* /downloads/baseconfig


#USER root
# add sample templates
ADD templates/ /tmac/templates/ 
WORKDIR $NIFI_HOME

# Clean up APT when done.
#RUN sudo apt-get clean && rm -rf /downloads/nifi*
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# update config
ADD config/nifi/bootstrap.conf $NIFI_HOME/conf/bootstrap.conf
ONBUILD ADD config/nifi/logback.xml $NIFI_HOME/conf/logback.xml
ADD config/ssl/* /ssl/
ONBUILD ADD config/nifi/nifi.properties $NIFI_HOME/conf/nifi.properties
ONBUILD ADD config/nifi/nifi.properties $NIFI_HOME/conf/nifi.base
ONBUILD ADD config/nifi/nifistarter.sh $NIFI_HOME/bin/nifistarter.sh

#RUN ls -l  $NIFI_HOME
ONBUILD RUN chmod +x $NIFI_HOME/bin/nifistarter.sh

WORKDIR $NIFI_HOME

VOLUME ["$NIFI_HOME/conf"]
VOLUME ["$NIFI_HOME/flowfile_repository"]
VOLUME ["$NIFI_HOME/database_repository"]
VOLUME ["$NIFI_HOME/content_repository"]
VOLUME ["$NIFI_HOME/provenance_repository"]

# Web HTTP Port & Remote Site-to-Site Ports
EXPOSE 8080 8181 8733 9090 8081
# Startup NiFi

#ONBUILD ADD config /tmacbaseconfig

USER root
# Run NIFI Server
CMD ["/bin/sh", "-c", "$NIFI_HOME/bin/nifi.sh run"]

