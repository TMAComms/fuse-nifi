#!/bin/sh
set -e 

echo "TMAC Nifi starter " ${NIFI_HOME}

# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.

#sed -i.bak "s/<author type=''>/<author type='Local'>/g" a.xml

mkdir $NIFI_HOME/logs -p 
touch $NIFI_HOME/logs//nifi-app.log
#exec /nifi/bin/nifi.sh run
$NIFI_HOME/bin/nifi-env.sh
tail -F $NIFI_HOME/logs/nifi-app.log & $NIFI_HOME/bin/nifi.sh run
#exec /sbin/setuser memcache /usr/bin/memcached >>/var/log/memcached.log 2>&1








#$NIFI_HOME/bin/nifi-env.sh
#echo "Resetting owner on /opt/nifi"
#mkdir -p /opt/nifi/logs /opt/nifi/run /opt/nifi/state /opt/nifi/work
#sudo chown -R nifi:nifi /opt/nifi
#sudo chmod -R 0777 /opt/nifi
#echo "Resetting owner on /opt/nifi done"
#rpl "BANNERTOREPLACE" "$ASPNETCORE_ENVIRONMENT" $NIFI_HOME/conf/nifi.properties 
#tail -F $NIFI_HOME/logs/nifi-app.log &  $NIFI_HOME/bin/nifi.sh run



