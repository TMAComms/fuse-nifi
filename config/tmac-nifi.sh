#!/bin/sh
set -e 

echo "TMAC Nifi starter for home dir  " ${NIFI_HOME}
echo "TMAC Nifi starter for base dir  " ${NIFI_BASE_DIR}

echo "Vars: CONF_INTERVAL = " ${CONF_INTERVAL}
echo "Vars: EVSENVIRONMENT = " ${EVSENVIRONMENT}
echo "Vars: NIFI_WEB_HTTP_PORT = " ${NIFI_WEB_HTTP_PORT}
echo "Vars: NIFI_WEB_HTTP_HOST = " ${NIFI_WEB_HTTP_HOST}
echo "Vars: NIFI_WEB_HTTPS_PORT = " ${NIFI_WEB_HTTPS_PORT}
echo "Vars: NIFI_WEB_HTTPS_HOST = " ${NIFI_WEB_HTTPS_HOST}
echo "Vars: NIFI_REMOTE_INPUT_HOST = " ${NIFI_REMOTE_INPUT_HOST}
echo "Vars: EVS_SERVICEDNS = " ${EVS_SERVICEDNS}

echo "Vars: EVS_AUTHDISCOVERYURL = " ${EVS_AUTHDISCOVERYURL}
echo "Vars: EVS_AUTHCLIENTID = " ${EVS_AUTHCLIENTID}
echo "Vars: EVS_AUTHCLIENTSECRET = " ${EVS_AUTHCLIENTSECRET}



TMPHOSTIP=$(ip route get 1 | awk '{print $NF;exit}')
echo "Container IP " ${TMPHOSTIP}
echo "EVS Service DNS " ${EVS_SERVICEDNS}
cp /etc/hosts /etc/hosts.tmacbak
echo "${TMPHOSTIP} ${EVS_SERVICEDNS}" >> /etc/hosts


echo "Update ssl config for " ${EVS_SERVICEDNS}
cp -f /tlskit/generated/${EVS_SERVICEDNS}/nifi.properties $NIFI_HOME/conf/nifi.properties
cp -f /tlskit/generated/${EVS_SERVICEDNS}/truststore.jks $NIFI_HOME/conf/truststore.jks
cp -f /tlskit/generated/${EVS_SERVICEDNS}/keystore.jks $NIFI_HOME/conf/keystore.jks
echo "Update ssl config done"


echo "Update openid settings for " ${EVS_SERVICEDNS} 

sed -i "s~{EVS_AUTHDISCOVERYURL}~${EVS_AUTHDISCOVERYURL}~" $NIFI_HOME/conf/nifi.properties
sed -i "s~{EVS_AUTHCLIENTID}~{${EVS_AUTHCLIENTID}~" $NIFI_HOME/conf/nifi.properties
sed -i "s~{EVS_AUTHCLIENTSECRET}~${EVS_AUTHCLIENTSECRET}~" $NIFI_HOME/conf/nifi.properties
echo "Update openid settings completed " 

echo "Setting up local ip " ${TMPHOSTIP}
#NIFI_WEB_HTTP_HOST=${TMPHOSTIP}
#export NIFI_WEB_HTTP_HOST=${TMPHOSTIP}

echo "TMAC Nifi running up nifi " 
${NIFI_BASE_DIR}/scripts/start.sh

