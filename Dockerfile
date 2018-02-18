#FROM tmacregistry-tmacomms.azurecr.io/tmacomms/fuse-nifi:150base
FROM tmacregistry-tmacomms.azurecr.io/tmacomms/fuse-nifi:1.5.0
LABEL Name=fuse-nifi Version=1.5.0
#FROM openjdk:8-jre
ENV NIFI_HOME=/opt/nifi/nifi-1.5.0 NIFI_BASE=/opt/nifi  NIFI_TOOLKIT=/opt/nifitoolkit  NIFITOOLKIT_FILE=nifi-toolkit-1.5.0-bin.tar.gz

#USER root

# Install kubectl binary via curl
#RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
#  &&  chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

RUN wget --show-progress --progress=bar:force --no-cookies --no-check-certificate -O /downloads/${NIFITOOLKIT_FILE} http://apache.mirror.amaze.com.au/nifi/1.5.0/${NIFITOOLKIT_FILE} 
RUN tar -xzvf /downloads/${NIFITOOLKIT_FILE} -C $NIFI_TOOLKIT --strip-components=1 && rm /downloads/${NIFITOOLKIT_FILE}


# apt-get update && apt-get install -y apt-transport-https && curl -s http://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
#     cat <<EOF >/etc/apt/sources.list.d/kubernetes.list \
#     deb http://apt.kubernetes.io/ kubernetes-xenial main \
#     EOF
#RUN apt-get update -q && apt-get install -y -q kubelet kubectl



#ADD conf/bootstrap.conf $NIFI_HOME/conf/bootstrap.conf
#COPY config/nifi/authorizers.xml $NIFI_HOME/conf/authorizers.xml
COPY config/nifi.properties $NIFI_HOME/conf/nifi.properties
#COPY config/nifi/nifi.openid.properties $NIFI_HOME/conf/nifi.properties
#COPY tlskit/genssl.sh /opt/nifi/genssl.sh
#RUN sudo chmod 0777 /opt/nifi/genssl.sh

ENV TLSPATH=nifi-dev.tmacomms.com
COPY tlskit/ /tlskit/
#COPY comfig/nifiregistry/#nifi-registry.properties $NIFI_HOME/conf/#nifi-registry.properties
COPY tlskit/generated/${TLSPATH}/truststore.jks $NIFI_HOME/conf/truststore.jks
COPY tlskit/generated/${TLSPATH}/keystore.jks $NIFI_HOME/conf/keystore.jks


COPY config/authorizers.xml $NIFI_HOME/conf/authorizers.xml
#  https://community.hortonworks.com/questions/131557/nifi-authorizercreationexception-unable-to-locate.html
RUN rm -f $NIFI_HOME/conf/authorizations.xml $NIFI_HOME/conf/users.xml
COPY config/nifi/logback.xml $NIFI_HOME/conf/logback.xml
#COPY config/nifi/bootstrap.conf $NIFI_HOME/conf/bootstrap.conf

# add sample templates
COPY config/templates/ $NIFI_HOME/conf/templates/ 
RUN sudo chown -R nifi:nifi $NIFI_HOME/conf/ && chmod 0777 /tlskit/genssl.sh


# update config
# copy a base versio of config 
# create a copy of the base config
RUN mkdir -p /config/base/ && cp -R $NIFI_HOME/conf/* /config/base && sudo chown -R nifi:nifi /config && sudo chmod -R 0777 /config

#nifi-registry.properties
#RUN sudo chmod 0777 bin/tmac-nifi.sh
ADD config/ssl/* /ssl/

VOLUME /config

# Web HTTP Port & Remote Site-to-Site Ports
EXPOSE 8080 8181 8443
# Startup NiFi
#ENTRYPOINT ["/opt/nifi/nifi-1.5.0/bin/tmac-nifi.sh"]
#USER nifi

#USER nifi
WORKDIR $NIFI_HOME
ADD config/tmac-nifi.sh ${NIFI_BASE_DIR}/scripts/tmac-nifi.sh
RUN sudo chmod 0777 ${NIFI_BASE_DIR}/scripts/tmac-nifi.sh

# Apply configuration and start NiFi
#ENTRYPOINT  ["${NIFI_BASE_DIR}/scripts/tmac-nifi.sh"]

CMD ${NIFI_BASE_DIR}/scripts/tmac-nifi.sh