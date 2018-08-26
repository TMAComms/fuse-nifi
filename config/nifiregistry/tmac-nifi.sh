#!/bin/sh
set -e 
NIFI_REGISTRYBASE=/opt/nifi-registry/nifi-registry-0.2.0
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

workifile="${NIFI_REGISTRYBASE}/conf/nifi-registry.properties"
if [ -f "$workifile" ]
then
	echo "$workifile found."
    echo "Working folder already moved to persistant storage - skipping"
else
	echo "$workifile not found.  Creating copy to persistant storage"
    mkdir -p $NIFI_REGISTRYBASE/conf/
    cp -R /config/base/* $NIFI_REGISTRYBASE/conf/
fi


# always update ip and hosts 
TMPHOSTIP=$(ip route get 1 | awk '{print $NF;exit}')
echo "Container IP " ${TMPHOSTIP}
echo "EVS Service DNS " ${EVS_SERVICEDNS}
cp /etc/hosts /etc/hosts.tmacbak
echo "${TMPHOSTIP} ${EVS_SERVICEDNS}" >> /etc/hosts
THISHOST=$(hostname -f)
echo "${TMPHOSTIP} ${THISHOST}" >> /etc/hosts

# always grabn latest jks backed into images
echo "Update jks stores for " ${EVS_SERVICEDNS}
#cp -f /tlskit/generated/${EVS_SERVICEDNS}/nifi.properties $NIFI_HOME/conf/nifi.properties
cp -f /config/securitystores/truststore.jks $NIFI_REGISTRYBASE/conf/truststore.jks
cp -f /config/securitystores/keystore.jks $NIFI_REGISTRYBASE/conf/keystore.jks
echo "Update ssl config done"


#sed -i "s~{EVS_SERVICEDNS}~${EVS_SERVICEDNS}~" $NIFI_REGISTRYBASE/conf/nifi-registry.properties


echo "Setting up local ip " ${TMPHOSTIP}

echo "TMAC Nifi registry - running up nifi " 
#${NIFI_REGISTRYBASE}/scripts/start.sh


# Continuously provide logs so that 'docker logs' can    produce them
tail -F "${NIFI_REGISTRYBASE}/logs/nifi-registry-app.log" & ${NIFI_REGISTRYBASE}/bin/nifi-registry.sh run

#"${NIFI_REGISTRYBASE}/bin/nifi-registry.sh " run & nifi_pid="$!"

#/opt/nifi-registry/bin/nifi-registry.sh