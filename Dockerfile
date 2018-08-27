#FROM tmacregistry-tmacomms.azurecr.io/tmacomms/fuse-nifi:150base
FROM apache/nifi:1.7.1
LABEL Name=fuse-nifi Version=1.7.1
USER root

RUN apt-get update && apt-get upgrade -y && \
 apt-get install -y software-properties-common unzip apt-utils tar zip sudo wget curl git apt-transport-https ca-certificates git bash ncdu dos2unix nano  \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && mkdir /opt/nifitoolkit /downloads


#FROM openjdk:8-jre
ENV NIFI_HOME=/opt/nifi/nifi-1.7.1 NIFI_BASE=/opt/nifi  NIFI_TOOLKIT=/opt/nifitoolkit  NIFITOOLKIT_FILE=nifi-toolkit-1.7.1-bin.tar.gz TZ=Australia/Melbourne 
#RUN ln -snf /usr/share/zoneinfo/$TZ && echo $TZ > /etc/timezone

RUN wget --show-progress --progress=bar:force --no-cookies --no-check-certificate -O /downloads/${NIFITOOLKIT_FILE} http://mirror.intergrid.com.au/apache/nifi/1.7.1/nifi-toolkit-1.7.1-bin.tar.gz 
RUN tar -xzvf /downloads/${NIFITOOLKIT_FILE} -C $NIFI_TOOLKIT --strip-components=1 && rm /downloads/${NIFITOOLKIT_FILE}



#ADD conf/bootstrap.conf $NIFI_HOME/conf/bootstrap.conf
COPY config/nifi/authorizers.xml $NIFI_HOME/conf/authorizers.xml

#COPY config/nifi/nifi.openid.properties $NIFI_HOME/conf/nifi.properties
COPY tlskit/genssl.sh /opt/nifi/genssl.sh
RUN sudo chmod 0777 /opt/nifi/genssl.sh

#ENV TLSPATH=nifi-dev.tmacomms.com
COPY tlskit/ /tlskit/
ADD config/securitystores/* /config/securitystores/

# reset base users 
#RUN rm -f $NIFI_HOME/conf/authorizations.xml $NIFI_HOME/conf/users.xml

#COPY config/securitystores/truststore.jks $NIFI_HOME/conf/truststore.jks
#COPY config/securitystores/keystore.jks $NIFI_HOME/conf/keystore.jks
#COPY config/nifi/nifi.properties $NIFI_HOME/conf/nifi.properties
#COPY config/nifi/authorizers.xml $NIFI_HOME/conf/authorizers.xml
#COPY config/nifi/logback.xml $NIFI_HOME/conf/logback.xml

# add sample templates
COPY config/templates/ $NIFI_HOME/conf/templates/ 
RUN chown -R nifi:nifi $NIFI_HOME/conf/ 
    # && chmod 0777 /tlskit/genssl.sh


# update config
# copy a base versio of config 
# create a copy of the base config
RUN mkdir -p /config/base/ && cp -R $NIFI_HOME/conf/* /config/base && sudo chown -R nifi:nifi /config && sudo chmod -R 0777 /config

#nifi-registry.properties
#RUN sudo chmod 0777 bin/tmac-nifi.sh


VOLUME /config

# Web HTTP Port & Remote Site-to-Site Ports
EXPOSE 8080 8181 8443 9090
# Startup NiFi
#ENTRYPOINT ["/opt/nifi/nifi-1.7.0/bin/tmac-nifi.sh"]
#USER nifi

#USER nifi
WORKDIR $NIFI_HOME
COPY config/nifi/tmac-nifi.sh ${NIFI_BASE}/scripts/tmac-nifi.sh
COPY config/nifi/start.sh ${NIFI_BASE}/scripts/start.sh
RUN chmod 0777 ${NIFI_BASE}/scripts/*.sh

#ENV NIFI_WEB_HTTPS_PORT=''
#ENTRYPOINT ["../scripts/start.sh"]
ENTRYPOINT ["/opt/nifi/scripts/tmac-nifi.sh"]

#CMD ${NIFI_BASE}/scripts/tmac-nifi.sh
