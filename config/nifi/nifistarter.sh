#!/bin/sh

export NIFI_HOME=/opt/nifi 
$NIFI_HOME/bin/nifi-env.sh
#echo "Resetting owner on /opt/nifi"
#sudo chown -R nifi:nifi /opt/nifi
#sudo chmod -R 0777 /opt/nifi
#echo "Resetting owner on /opt/nifi done"
rpl "BANNERTOREPLACE" "$ASPNETCORE_ENVIRONMENT" $NIFI_HOME/conf/nifi.properties 
tail -F $NIFI_HOME/logs/nifi-app.log &  $NIFI_HOME/bin/nifi.sh run



