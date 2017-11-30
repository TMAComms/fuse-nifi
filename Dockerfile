#FROM tmacregistry-tmacomms.azurecr.io/tmacomms/basejdk8:latest
FROM openjdk:8-jre 
LABEL Name=fuse-nifi Version=1.4.0
ENV        BANNER_TEXT="" \
           S2S_PORT=""

RUN apt-get update &&   apt-get install -y apt-transport-https ca-certificates wget nano acl unzip 
RUN wget -S -nc -progress=dot -O /usr/local/share/ca-certificates/tmac-devops.crt  https://caddy.tmacomms.com/myca.crt

## removed as runnign in azure agent
#ENV http_proxy="http://squid.tmacomms.com:3128"
#ENV https_proxy="http://squid.tmacomms.com:3128"
#ENV no_proxy="127.0.0.1, localhost, *.tmacomms.com, *.calljourney.com"
ENV http_proxy=""
ENV https_proxy=""
RUN update-ca-certificates
ARG ASPNETCORE_ENVIRONMENT=development
ARG UID=1000
ARG GID=1000
ARG NIFI_VERSION=1.4.0
ARG MIRROR=http://archive.apache.org/dist
ARG NIFI_HOME=/opt/nifi
ENV NIFI_HOME=/opt/nifi 
RUN apt-get update && \
    apt-get install -qq -y software-properties-common unzip tar zip sudo wget curl \
                      mercurial apt-transport-https ca-certificates git nano sudo rpl
RUN echo "nifi ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

# Set the timezone.
RUN echo "Australia/Melbourne" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
## based on install guide 
COPY config/baseos/limits.conf /etc/security/limits.conf
COPY config/baseos/sysctl.conf /etc/sysctl.conf

# Setup NiFi user
RUN groupadd -g $GID nifi || groupmod -n nifi `getent group $GID | cut -d: -f1` \
    && useradd --shell /bin/bash -u $UID -g $GID -m nifi \
    && mkdir -p $NIFI_HOME/conf/templates $NIFI_HOME/provenance_repository $NIFI_HOME/flowfile_repository  /opt/toolkit $NIFI_HOME/database_repository  $NIFI_HOME/content_repository /downloads/baseconfig /tmac/templates /tmac/flow/archive /tmac/working /ssl \
    && chown -R nifi:nifi $NIFI_HOME \
    && chown -R nifi:nifi /downloads \
    && chown -R nifi:nifi /ssl \
    && chown -R nifi:nifi /tmac 
    

# Download, validate, and expand Apache NiFi binary.
RUN wget -N --show-progress --progress=bar:force --no-cookies --no-check-certificate -O /downloads/nifi-1.4.0-bin.tar.gz http://apache.melbourneitmirror.net/nifi/1.4.0/nifi-1.4.0-bin.tar.gz \
       && tar -xzvf /downloads/nifi-1.4.0-bin.tar.gz -C $NIFI_HOME --strip-components=1 && rm /downloads/nifi-1.4.0-bin.tar.gz

#toolkit
RUN wget --show-progress --progress=bar:force --no-cookies --no-check-certificate -O /downloads/nifi-toolkit-1.4.0-bin.tar.gz http://apache.melbourneitmirror.net/nifi/1.4.0/nifi-toolkit-1.4.0-bin.tar.gz \
        && tar -xzvf /downloads/nifi-toolkit-1.4.0-bin.tar.gz -C /opt/toolkit --strip-components=1 && rm /downloads/nifi-toolkit-1.4.0-bin.tar.gz 


# backup base conifg
RUN cp -r $NIFI_HOME/conf/* /downloads/baseconfig

# update config
ADD templates/* $NIFI_HOME/conf/templates/
ADD config/nifi/logback.xml $NIFI_HOME/conf/logback.xml
ADD config/ssl/* /ssl/
ADD config/nifi/nifi.properties $NIFI_HOME/conf/nifi.properties
ADD config/nifi/nifistarter.sh $NIFI_HOME/bin/nifistarter.sh

RUN chmod +x $NIFI_HOME/bin/nifistarter.sh && chown -R nifi:nifi $NIFI_HOME && chown -R nifi:nifi /ssl  && \
     rpl "BANNERTOREPLACE" $ASPNETCORE_ENVIRONMENT $NIFI_HOME/conf/nifi.properties 

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

WORKDIR $NIFI_HOME
# Clean up APT when done.
USER nifi

VOLUME ["$NIFI_HOME/conf"]
VOLUME ["/tmac/flow"]
VOLUME ["$NIFI_HOME/database_repository"]
VOLUME ["$NIFI_HOME/content_repository"]
VOLUME ["$NIFI_HOME/provenance_repository"]
VOLUME ["$NIFI_HOME/flowfile_repository"]


# Web HTTP Port & Remote Site-to-Site Ports
EXPOSE 8080 8181 8733 9090 8081


# Run NIFI Server
CMD ["/bin/sh", "-c", "/opt/nifi/bin/nifistarter.sh"]



