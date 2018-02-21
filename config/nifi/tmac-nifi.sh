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


echo "TMAC Nifi starter " ${NIFI_HOME}

ls -l /opt/nifi/nifi-1.5.0/conf

# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.

workifile="$NIFI_HOME/conf/nifi.properties"
if [ -f "$workifile" ]
then
	echo "$workifile found."
    echo "workign folder already moved to persistant storage - skipping"
else
	echo "$workifile not found.  Creating copy to persistant storage"
    mkdir -p $NIFI_HOME/conf/
    cp -R /config/base/* $NIFI_HOME/conf/
#    echo "Update ssl config for " ${EVS_SERVICEDNS}
#    cp -f $NIFI_HOME/conf/nifi.properties $NIFI_HOME/conf/nifi.bak
#    cp -f /tlskit/generated/${EVS_SERVICEDNS}/truststore.jks $NIFI_HOME/conf/truststore.jks
#    cp -f /tlskit/generated/${EVS_SERVICEDNS}/keystore.jks $NIFI_HOME/conf/keystore.jks
#    echo "Update ssl config done"
 
fi


TMPHOSTIP=$(ip route get 1 | awk '{print $NF;exit}')
echo "Container IP " ${TMPHOSTIP}
echo "EVS Service DNS " ${EVS_SERVICEDNS}
cp /etc/hosts /etc/hosts.tmacbak
echo "${TMPHOSTIP} ${EVS_SERVICEDNS}" >> /etc/hosts
THISHOST=$(hostname -f)
echo "${TMPHOSTIP} ${THISHOST}" >> /etc/hosts

echo "EVS Service DNS Updateing config to " ${EVS_SERVICEDNS}
sed -i "s~{EVS_SERVICEDNS}~${EVS_SERVICEDNS}~" $NIFI_HOME/conf/nifi.properties


# always grabn latest jks backed into images
echo "Update jks stores for " ${EVS_SERVICEDNS}
#cp -f /tlskit/generated/${EVS_SERVICEDNS}/nifi.properties $NIFI_HOME/conf/nifi.properties
cp -f /config/securitystores/truststore.jks $NIFI_HOME/conf/truststore.jks
cp -f /config/securitystores/keystore.jks $NIFI_HOME/conf/keystore.jks
echo "Update ssl config done"


# update openod settings if needed
#if [ -z "$EVS_AUTHDISCOVERYURL" ]
#then
echo "Update openid settings for " ${EVS_SERVICEDNS} 
sed -i "s~{EVS_AUTHDISCOVERYURL}~${EVS_AUTHDISCOVERYURL}~" $NIFI_HOME/conf/nifi.properties
sed -i "s~{EVS_AUTHCLIENTID}~${EVS_AUTHCLIENTID}~" $NIFI_HOME/conf/nifi.properties
sed -i "s~{EVS_AUTHCLIENTSECRET}~${EVS_AUTHCLIENTSECRET}~" $NIFI_HOME/conf/nifi.properties
sed -i "s~{BANNER_TEXT}~${BANNER_TEXT}~" $NIFI_HOME/conf/nifi.properties
echo "Update openid settings completed " 
#fi



echo "Setting up local ip " ${TMPHOSTIP}
#NIFI_WEB_HTTP_HOST=${TMPHOSTIP}
#export NIFI_WEB_HTTP_HOST=${TMPHOSTIP}

echo "TMAC Nifi running up nifi " 
${NIFI_BASE_DIR}/scripts/start.sh

