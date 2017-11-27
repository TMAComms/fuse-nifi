#FROM tmacregistry-tmacomms.azurecr.io/tmacomms/basejdk8:latest
FROM openjdk:8-jre
LABEL Name=fuse-nifi Version=1.4.0
MAINTAINER Andrei <andrei@tmacomms.com>
ENV        BANNER_TEXT="" \
           S2S_PORT=""
USER root

RUN wget -S -nc -progress=dot -O /usr/local/share/ca-certificates/tmac-devops.crt  https://caddy.tmacomms.com/myca.crt
#RUN mkdir /usr/share/ca-certificates/tmacomms -p && chmod -R 0755 /usr/share/ca-certificates/tmacomms 

ENV http_proxy="http://squid.tmacomms.com:3128"
ENV https_proxy="http://squid.tmacomms.com:3128"
ENV no_proxy="127.0.0.1, localhost, *.tmacomms.com, *.calljourney.com"


RUN apt-get update &&   apt-get install -y apt-transport-https ca-certificates 
RUN update-ca-certificates


RUN apt-get update && apt-get upgrade -y
RUN apt-get update && \
    apt-get install -y software-properties-common unzip tar zip sudo wget curl && apt-get update && \
    apt-get install -y git mercurial apt-transport-https ca-certificates git

# Get CrushFTP 7
RUN mkdir -m 0755 /downloads /nifi/ /tmac/templates /tmac/archive /tmac/flow /etc/service/nifi  /ssl /download/baseconfig/ -p 
RUN ls -l /
WORKDIR /downloads

ARG UID=1000
ARG GID=1000
ARG NIFI_VERSION=1.4.0
ARG MIRROR=https://archive.apache.org/dist

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

USER nifi
ADD artifcats/  /downloads/
RUN ls -l
RUN  tar -xvzf /downloads/nifi-$NIFI_VERSION-bin.tar.gz -C $NIFI_BASE_DIR 


#RUN wget http://apache.mirror.digitalpacific.com.au/$NIFI_TOOLKIT_URL -O /downloads/nifi-toolkit-$NIFI_VERSION-bin.tar.gz 
#RUN   
    #&& rm $NIFI_BASE_DIR/nifi-$NIFI_VERSION-bin.tar.gz \
    #&& chown -R nifi:nifi $NIFI_HOME


#RUN wget http://apache.mirror.digitalpacific.com.au/nifi/1.4.0/nifi-1.4.0-bin.tar.gz && wget http://apache.mirror.digitalpacific.com.au/nifi/1.4.0/nifi-toolkit-1.4.0-bin.tar.gz && tar -xzvf nifi-1.4.0-bin.tar.gz -C /nifi --strip-components=1 && rm -rf /downloads/*

# backup config



#RUN cp  /nifi/conf/* /download/baseconfig/


# add sample templates
ADD templates/ /tmac/templates/ 
WORKDIR  /nifi

# Clean up APT when done.
#RUN sudo apt-get clean && rm -rf /downloads/*
RUN rm -rf /downloads/*




# update config
ADD conf/bootstrap.conf $NIFI_HOME/conf/bootstrap.conf
ADD conf/logback.xml /nifi/conf/logback.xml
ADD conf/ssl/* /ssl/
ADD conf/nifi.properties $NIFI_HOME/conf/nifi.properties
#ADD conf/nifi.properties /tmac/nifi.base

#ADD conf/nifiserver.sh /etc/service/nifi/run
#RUN chmod +x /etc/service/nifi/run
RUN ls -l  $NIFI_HOME
#RUN chmod +x $NIFI_HOME/bin/nifi.sh 

#D:\bb\fuse\fuse-nifi\conf\nifi..properties

# Use baseimage-docker's init system.
#CMD ["/sbin/my_init"]
VOLUME     /tmac/templates /tmac/archive /tmac/flow
WORKDIR $NIFI_HOME
#USER nifi

#/etc/service/nifi

# Web HTTP Port & Remote Site-to-Site Ports
EXPOSE 8080 8181
# Startup NiFi
#ENTRYPOINT ["bin/nifi.sh"]
#CMD ["run"]

# Run Teiid server and bind to all interface
CMD ["/bin/sh", "-c", "$NIFI_HOME/bin/nifi.sh run"]
#ENTRYPOINT ["bin/nifi.sh"]
#CMD ["run"]
#CMD ["bash"]
#ENTRYPOINT ["./bin/nifi.sh run"]
##CMD [" run"]
#entrypoint: "./nifi/bin/nifi.sh run"

# Define default command.
#CMD ["/sbin/my_init", "/bin/bash"]
