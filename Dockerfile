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
RUN mkdir -m 0755 /downloads/baseconfig /nifi/ /tmac/templates /tmac/archive /tmac/flow /etc/service/nifi  /ssl /download/baseconfig/ -p 

WORKDIR /downloads

ARG UID=1000
ARG GID=1000
ARG NIFI_VERSION=1.4.0
ARG MIRROR=http://archive.apache.org/dist

ENV NIFI_BASE_DIR=/opt/nifi 
ENV NIFI_HOME=$NIFI_BASE_DIR/nifi-$NIFI_VERSION \
    NIFI_BINARY_URL=/nifi/$NIFI_VERSION/nifi-$NIFI_VERSION-bin.tar.gz \
    NIFI_TOOLKIT_URL=/nifi/$NIFI_VERSION/nifi-toolkit-$NIFI_VERSION-bin.tar.gz

# Setup NiFi user
RUN groupadd -g $GID nifi || groupmod -n nifi `getent group $GID | cut -d: -f1` \
    && useradd --shell /bin/bash -u $UID -g $GID -m nifi \
    && mkdir -p $NIFI_HOME/conf/templates \
    && chown -R nifi:nifi $NIFI_BASE_DIR \
    && chown -R nifi:nifi /downloads \
    && chown -R nifi:nifi /ssl \
    && chown -R nifi:nifi /tmac \
    && chown -R nifi:nifi /nifi 

#USER nifi

# Download, validate, and expand Apache NiFi binary.
#RUN curl -fSL $MIRROR/$NIFI_BINARY_URL -o $NIFI_BASE_DIR/nifi-$NIFI_VERSION-bin.tar.gz \
#    && echo "$(curl https://archive.apache.org/dist/$NIFI_BINARY_URL.sha256) *$NIFI_BASE_DIR/nifi-$NIFI_VERSION-bin.tar.gz" | sha256sum -c - \
#    && 
RUN wget -N --show-progress --progress=bar:force --no-cookies --no-check-certificate -O /downloads/nifi-1.4.0-bin.tar.gz http://apache.melbourneitmirror.net/nifi/1.4.0/nifi-1.4.0-bin.tar.gz
RUN wget -N --show-progress --progress=bar:force --no-cookies --no-check-certificate -O /downloads/nifi-toolkit-1.4.0-bin.tar.gz http://apache.melbourneitmirror.net/nifi/1.4.0/nifi-toolkit-1.4.0-bin.tar.gz
#USER nifi
ADD artifacts/  /downloads/
RUN ls -l
RUN tar -xvzf /downloads/nifi-$NIFI_VERSION-bin.tar.gz -C $NIFI_BASE_DIR 
# backup base conifg
RUN sudo cp -r $NIFI_HOME/conf/* /download/baseconfig


#USER root
# add sample templates
ADD templates/ /tmac/templates/ 
WORKDIR  /nifi

# Clean up APT when done.
#RUN sudo apt-get clean && rm -rf /downloads/*
RUN rm -rf /downloads/nifi*

# update config
ADD config/nifi/bootstrap.conf $NIFI_HOME/conf/bootstrap.conf
ADD config/nifi/logback.xml /nifi/conf/logback.xml
ADD config/ssl/* /ssl/
ADD config/nifi/nifi.properties $NIFI_HOME/conf/nifi.properties
#ADD conf/nifi.properties /tmac/nifi.base


RUN ls -l  $NIFI_HOME
RUN chmod +x $NIFI_HOME/bin/nifi.sh 

VOLUME /tmac/templates /tmac/archive /tmac/flow
WORKDIR $NIFI_HOME
#USER nifi


# Web HTTP Port & Remote Site-to-Site Ports
EXPOSE 8080 8181
# Startup NiFi

# Run NIFI Server
CMD ["/bin/sh", "-c", "$NIFI_HOME/bin/nifi.sh run"]

