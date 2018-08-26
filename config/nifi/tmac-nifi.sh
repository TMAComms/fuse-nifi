#!/bin/sh
set -e 


scripts_dir='/opt/nifi/scripts'

[ -f "${scripts_dir}/common.sh" ] && . "${scripts_dir}/common.sh"


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

#ls -l ${NIFI_HOME}/conf

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


#TMPHOSTIP=$(ip route get 1 | awk '{print $NF;exit}')
#echo "Container IP " ${TMPHOSTIP}
#echo "EVS Service DNS " ${EVS_SERVICEDNS}
#cp /etc/hosts /etc/hosts.tmacbak
#echo "${TMPHOSTIP} ${EVS_SERVICEDNS}" >> /etc/hosts
#THISHOST=$(hostname -f)
#echo "${TMPHOSTIP} ${THISHOST}" >> /etc/hosts

#echo "EVS Service DNS Updateing config to " ${EVS_SERVICEDNS}
#sed -i "s~{EVS_SERVICEDNS}~${EVS_SERVICEDNS}~" $NIFI_HOME/conf/nifi.properties


# always grabn latest jks backed into images
echo "Update jks stores for " ${EVS_SERVICEDNS}
#cp -f /tlskit/generated/${EVS_SERVICEDNS}/nifi.properties $NIFI_HOME/conf/nifi.properties
cp -f /config/securitystores/truststore.jks $NIFI_HOME/conf/truststore.jks
cp -f /config/securitystores/keystore.jks $NIFI_HOME/conf/keystore.jks
echo "Update ssl config done"


# update openod settings if needed
#if [ -z "$EVS_AUTHDISCOVERYURL" ]
#then


# Establish baseline properties

# Disable HTTP and enable HTTPS
prop_replace 'nifi.web.http.port'   ''
prop_replace 'nifi.web.http.host'   ''
prop_replace 'nifi.web.https.port'  "${NIFI_WEB_HTTPS_PORT:-8443}"
prop_replace 'nifi.web.https.host'  "${NIFI_WEB_HTTPS_HOST:-$HOSTNAME}"
prop_replace 'nifi.remote.input.secure' 'true'
prop_replace 'nifi.remote.input.http.enabled' 'false'

# Check if the user has specified a nifi.web.proxy.host setting and handle appropriately
if [ -z "${NIFI_WEB_PROXY_HOST}" ]; then
    echo 'NIFI_WEB_PROXY_HOST was not set but NiFi is configured to run in a secure mode.  The NiFi UI may be inaccessible if using port mapping.'
else
    prop_replace 'nifi.web.proxy.host' "${NIFI_WEB_PROXY_HOST}"
fi

echo "Update openid settings for " ${EVS_SERVICEDNS} 
prop_replace 'nifi.security.user.oidc.discovery.url'    "${EVS_AUTHDISCOVERYURL:-none}"
prop_replace 'nifi.security.user.oidc.client.id'    "${EVS_AUTHCLIENTID:-none}"
prop_replace 'nifi.security.user.oidc.client.secret'    "${EVS_AUTHCLIENTSECRET:-none}"
prop_replace 'nifi.security.user.oidc.preferred.jwsalgorithm'    "${EVS_AUTHJWSTYPE:-RS256}"
echo "Update openid settings completed " 

prop_replace 'nifi.security.keystore'           "${KEYSTORE_PATH}"
prop_replace 'nifi.security.keystoreType'       "${KEYSTORE_TYPE:-JKS}"
prop_replace 'nifi.security.keystorePasswd'     "${KEYSTORE_PASSWORD}"
prop_replace 'nifi.security.truststore'         "${TRUSTSTORE_PATH}"
prop_replace 'nifi.security.truststoreType'     "${TRUSTSTORE_TYPE:-JKS}"
prop_replace 'nifi.security.truststorePasswd'   "${TRUSTSTORE_PASSWORD}"

echo "Setting up local ip " ${TMPHOSTIP}
#NIFI_WEB_HTTP_HOST=${TMPHOSTIP}
#export NIFI_WEB_HTTP_HOST=${TMPHOSTIP}

echo "TMAC Nifi running up nifi " 


# Continuously provide logs so that 'docker logs' can    produce them
tail -F "${NIFI_HOME}/logs/nifi-app.log" &
"${NIFI_HOME}/bin/nifi.sh" run &
nifi_pid="$!"

trap "echo Received trapped signal, beginning shutdown...;" KILL TERM HUP INT EXIT;

echo NiFi running with PID ${nifi_pid}.
wait ${nifi_pid}

#${NIFI_BASE_DIR}/scripts/start.sh

