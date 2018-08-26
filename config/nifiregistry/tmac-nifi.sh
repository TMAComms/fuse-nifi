#!/bin/sh
set -e 
NIFI_REGISTRYBASE=/opt/nifi-registry/nifi-registry-0.2.0
echo "TMAC Nifi Registry starter for home dir " ${NIFI_REGISTRYBASE}

scripts_dir="${NIFI_REGISTRYBASE}/scripts" # '/opt/nifi/scripts'

[ -f "${scripts_dir}/common.sh" ] && . "${scripts_dir}/common.sh"


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



# always grabn latest jks backed into images
echo "Update jks stores for " ${EVS_SERVICEDNS}
#cp -f /tlskit/generated/${EVS_SERVICEDNS}/nifi.properties $NIFI_HOME/conf/nifi.properties
cp -f /config/securitystores/truststore.jks $NIFI_REGISTRYBASE/conf/truststore.jks
cp -f /config/securitystores/keystore.jks $NIFI_REGISTRYBASE/conf/keystore.jks
echo "Update ssl config done"


#sed -i "s~{EVS_SERVICEDNS}~${EVS_SERVICEDNS}~" $NIFI_REGISTRYBASE/conf/nifi-registry.properties


# Disable HTTP and enable HTTPS
prop_replace 'nifi.registry.web.http.port'   ''
prop_replace 'nifi.registry.web.http.host'   ''
prop_replace 'nifi.registry.web.https.port'  "${NIFI_WEB_HTTPS_PORT:-8443}"
prop_replace 'nifi.registry.web.https.host'  "${NIFI_WEB_HTTPS_HOST:-$HOSTNAME}"
prop_replace 'nifi.registry.remote.input.secure' 'true'
prop_replace 'nifi.registry.remote.input.http.enabled' 'false'

# Check if the user has specified a nifi.web.proxy.host setting and handle appropriately
if [ -z "${NIFI_WEB_PROXY_HOST}" ]; then
    echo 'NIFI_WEB_PROXY_HOST was not set but NiFi is configured to run in a secure mode.  The NiFi UI may be inaccessible if using port mapping.'
else
    prop_replace 'nifi.registry.web.proxy.host' "${NIFI_WEB_PROXY_HOST}"
fi

echo "Update openid settings for" ${EVS_SERVICEDNS} 
echo "Update openid settings for discovery url " ${EVS_AUTHDISCOVERYURL} 
prop_replace 'nifi.registry.security.user.oidc.discovery.url'    "${EVS_AUTHDISCOVERYURL}"
echo "Update openid settings for client id " ${EVS_AUTHCLIENTID} 
prop_replace 'nifi.registry.security.user.oidc.client.id'    "${EVS_AUTHCLIENTID}"
echo "Update openid settings for client sec " ${EVS_AUTHCLIENTSECRET} 
prop_replace 'nifi.registry.security.user.oidc.client.secret'    "${EVS_AUTHCLIENTSECRET}"
echo "Update openid settings for jwsa" ${EVS_AUTHJWSTYPE} 
prop_replace 'nifi.registry.security.user.oidc.preferred.jwsalgorithm'    "${EVS_AUTHJWSTYPE:-RS256}"
echo "Update openid settings completed" 

echo "Update KEYSTORE_PATH settings for " ${KEYSTORE_PATH} 
prop_replace 'nifi.registry.security.keystore'           "${KEYSTORE_PATH}"
echo "Update KEYSTORE_TYPE settings for " ${KEYSTORE_TYPE} 
prop_replace 'nifi.registry.security.keystoreType'       "${KEYSTORE_TYPE:-JKS}"
echo "Update KEYSTORE_PASSWORD settings for " ${KEYSTORE_PASSWORD} 
prop_replace 'nifi.registry.security.keystorePasswd'     "${KEYSTORE_PASSWORD}"
echo "Update keystore settings completed" 
prop_replace 'nifi.registry.security.truststore'         "${TRUSTSTORE_PATH}"
prop_replace 'nifi.registry.security.truststoreType'     "${TRUSTSTORE_TYPE:-JKS}"
prop_replace 'nifi.registry.security.truststorePasswd'   "${TRUSTSTORE_PASSWORD}"
echo "Update truststore settings completed" 



echo "TMAC Nifi registry - running up nifi " 
#${NIFI_REGISTRYBASE}/scripts/start.sh


# Continuously provide logs so that 'docker logs' can    produce them
tail -F "${NIFI_REGISTRYBASE}/logs/nifi-registry-app.log" & ${NIFI_REGISTRYBASE}/bin/nifi-registry.sh run

#"${NIFI_REGISTRYBASE}/bin/nifi-registry.sh " run & nifi_pid="$!"

#/opt/nifi-registry/bin/nifi-registry.sh