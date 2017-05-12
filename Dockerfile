FROM tmacregistry-tmacomms.azurecr.io/tmacomms/basejdk8:latest
LABEL Name=fuse-nifi Version=1.2.0
MAINTAINER Andrei <andrei@tmacomms.com>
ENV        BANNER_TEXT="" \
           S2S_PORT=""
#COPY       start_nifi.sh /${NIFI_HOME}/
#FROM xemuliam/nifi-base:1.2.0

# CrushFTP requires root
#  tmacregistry-tmacomms.azurecr.io/tmacomms/basejdk8

USER root
RUN apt-get update && apt-get upgrade -y


# Get CrushFTP 7
RUN mkdir /downloads /nifi
WORKDIR /downloads

RUN wget http://apache.mirror.digitalpacific.com.au/nifi/1.2.0/nifi-1.2.0-bin.tar.gz && wget http://apache.mirror.digitalpacific.com.au/nifi/1.2.0/nifi-toolkit-1.2.0-bin.tar.gz && tar -xzvf nifi-1.2.0-bin.tar.gz -C /nifi --strip-components=1 && rm -rf /downloads/*


ARG NIFI_HOME
ENV NIFI_HOME=/nifi
RUN mkdir /tmac /tmac/templates /tmac/archive /tmac/flow
VOLUME     /tmac/templates /tmac/archive /tmac/flow

#backup config
RUN mv /nifi/conf/nifi.properties /nifi/conf/nifi.origprops
RUN mv /nifi/conf/bootstrap.conf /nifi/conf/bootstrap.origconf
RUN mv /nifi/conf/logback.xml /nifi/conf/logback.origxml



# add sample templates
ADD templates/ /tmac/templates/ 
WORKDIR  /nifi

# Clean up APT when done.
RUN apt-get clean && rm -rf /downloads/*

RUN mkdir /etc/service/nifi
RUN mkdir /ssl
ADD conf/nifiserver.sh /etc/service/nifi/run
RUN  chmod +x /etc/service/nifi/run

RUN  chmod +x /nifi/bin/nifi.sh 
EXPOSE 8080 8443

# update config
ADD conf/bootstrap.conf /nifi/conf/bootstrap.conf
ADD conf/logback.xml /nifi/conf/logback.xml
ADD conf/ssl/* /ssl/
ADD conf/nifi.properties /nifi/conf/nifi.properties
#ADD conf/nifi.properties /tmac/nifi.base

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Run Teiid server and bind to all interface
#CMD ["/bin/sh", "-c", "/nifi/bin/nifi.sh run"]


#ENTRYPOINT ["/nifi/bin/nifi.sh run"]
##CMD [" run"]
#entrypoint: "./nifi/bin/nifi.sh run"


