#FROM tmacregistry-tmacomms.azurecr.io/tmacomms/fuse-nifi:150base
FROM tmacregistry-tmacomms.azurecr.io/tmacomms/fuse-nifi:1.5.0
LABEL Name=fuse-nifi Version=1.5.0
#FROM openjdk:8-jre
ENV NIFI_HOME=/opt/nifi/nifi-1.5.0
ENV NIFI_BASE=/opt/nifi
#USER root

# Install kubectl binary via curl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
  &&  chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

RUN /bin/hostname -i



# apt-get update && apt-get install -y apt-transport-https && curl -s http://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
#     cat <<EOF >/etc/apt/sources.list.d/kubernetes.list \
#     deb http://apt.kubernetes.io/ kubernetes-xenial main \
#     EOF
#RUN apt-get update -q && apt-get install -y -q kubelet kubectl



#ADD conf/bootstrap.conf $NIFI_HOME/conf/bootstrap.conf
#COPY config/nifi/authorizers.xml $NIFI_HOME/conf/authorizers.xml
COPY config/nifi.properties $NIFI_HOME/conf/nifi.properties
#COPY config/nifi/nifi.openid.properties $NIFI_HOME/conf/nifi.properties
COPY config/nifi/logback.xml $NIFI_HOME/conf/logback.xml
#COPY config/nifi/bootstrap.conf $NIFI_HOME/conf/bootstrap.conf

# add sample templates
#ADD templates/ $NIFI_HOME/conf/templates/ 
#RUN sudo chown -R nifi:nifi /opt/nifi


# update config
# copy a base versio of config 
# create a copy of the base config
#RUN mkdir -p /config/base/ && cp -R $NIFI_HOME/conf/* /config/base && sudo chown -R nifi:nifi /config && sudo chmod -R 0777 /config


#RUN sudo chmod 0777 bin/tmac-nifi.sh
ADD config/ssl/* /ssl/

VOLUME /config

# Web HTTP Port & Remote Site-to-Site Ports
EXPOSE 8080 8181 8443
# Startup NiFi
#ENTRYPOINT ["/opt/nifi/nifi-1.5.0/bin/tmac-nifi.sh"]
#USER nifi

USER nifi
WORKDIR $NIFI_HOME
ADD config/tmac-nifi.sh ${NIFI_BASE_DIR}/scripts/tmac-nifi.sh
RUN chmod 0777 ${NIFI_BASE_DIR}/scripts/tmac-nifi.sh

# Apply configuration and start NiFi
CMD ${NIFI_BASE_DIR}/scripts/tmac-nifi.sh