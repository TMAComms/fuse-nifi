FROM tmacomms/basejdk8
LABEL Name=fuse-nifi Version=1.1.2
MAINTAINER Andrei <andrei@tmacomms.com>
ENV        BANNER_TEXT="" \
           S2S_PORT=""
#COPY       start_nifi.sh /${NIFI_HOME}/
#FROM xemuliam/nifi-base:1.1.2

# CrushFTP requires root
#  tmacregistry-tmacomms.azurecr.io/tmacomms/basejdk8

USER root
RUN apt-get update && apt-get upgrade -y


# Get CrushFTP 7
RUN mkdir /downloads
WORKDIR /downloads

RUN wget http://apache.mirror.amaze.com.au/nifi/1.1.2/nifi-1.1.2-bin.tar.gz
RUN wget http://apache.mirror.amaze.com.au/nifi/1.1.2/nifi-toolkit-1.1.2-bin.tar.gz
RUN tar -xzvf nifi-1.1.2-bin.tar.gz -C /nifi --strip-components=1

ARG NIFI_HOME
ENV NIFI_HOME=/opt/nifi
RUN mkdir /tmac /tmac/templates /tmac/archive
VOLUME     /tmac/templates /tmac/archive
# update config
ADD conf/nifi.properties /opt/nifi/conf/nifi.properties
ADD conf/nifi.properties /tmac/nifi.base
ADD templates/ /tmac/templates/
WORKDIR    ${NIFI_HOME}
#RUN        chmod +x ./start_nifi.sh
EXPOSE 8080
#CMD        ./start_nifi.sh

# For more control, you can copy and build manually
# FROM golang:latest 
# LABEL Name=fuse-nifi Version=0.0.1 
# RUN mkdir /app 
# ADD . /app/ 
# WORKDIR /app 
# RUN go build -o main .
# EXPOSE 8080 
# CMD ["/app/main"]
