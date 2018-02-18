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

# generates ssl related config
/opt/nifitoolkit/bin/tls-toolkit.sh standalone -n localhost,nifilocal,nifi.prod.us.tmacomms.com,nifi.dev.us.tmacomms.com,nifi-dev.tmacomms.com,nifi-prod.tmacomms.com  -o /toolkit/generated -S 77record -K 77record -f $NIFI_HOME/conf/nifi.properties -C "CN=user, OU=NIFI"
