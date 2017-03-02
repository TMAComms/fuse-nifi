FROM xemuliam/nifi-base:1.1.2
LABEL Name=fuse-nifi Version=1.1.2
MAINTAINER Andrei <andrei@tmacomms.com>
ENV        BANNER_TEXT="" \
           S2S_PORT=""
#COPY       start_nifi.sh /${NIFI_HOME}/


ARG NIFI_HOME
ENV NIFI_HOME=/opt/nifi
RUN mkdir /tmac /tmac/templates /tmac/archive
VOLUME     /tmac/templates /tmac/archive
# update config
ADD conf/nifi.properties /opt/nifi/conf/nifi.properties
ADD conf/nifi.properties /tmac/nifi.base
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
