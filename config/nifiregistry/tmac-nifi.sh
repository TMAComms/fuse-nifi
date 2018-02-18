#!/bin/sh
set -e 
NIFI_REGISTRYBASE=/opt/nifiregistry
echo "TMAC Nifi Registry starter for home dir  " ${NIFI_REGISTRYBASE}

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


echo "TMAC Nifi starter " ${NIFI_REGISTRYBASE}

# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.

workifile="$NIFI_REGISTRYBASE/conf/nifi.properties"
if [ -f "$workifile" ]
then
	echo "$workifile found."
    echo "workign folder already moved to persistant storage - skipping"
else
	echo "$workifile not found.  Creating copy to persistant storage"
    mkdir -p $NIFI_REGISTRYBASE/conf/
    cp -R /config/base/* $NIFI_REGISTRYBASE/conf/
fi


TMPHOSTIP=$(ip route get 1 | awk '{print $NF;exit}')
echo "Container IP " ${TMPHOSTIP}
echo "EVS Service DNS " ${EVS_SERVICEDNS}
cp /etc/hosts /etc/hosts.tmacbak
echo "${TMPHOSTIP} ${EVS_SERVICEDNS}" >> /etc/hosts




echo "Setting up local ip " ${TMPHOSTIP}
#NIFI_WEB_HTTP_HOST=${TMPHOSTIP}
#export NIFI_WEB_HTTP_HOST=${TMPHOSTIP}

echo "TMAC Nifi running up nifi " 
#${NIFI_REGISTRYBASE}/scripts/start.sh

/opt/nifiregistry/bin/nifi-registry.sh run 

