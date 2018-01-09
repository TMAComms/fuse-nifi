#!/bin/sh
set -e 

echo "TMAC Nifi starter " ${NIFI_HOME}

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
fi

#sed -i.bak "s/<author type=''>/<author type='Local'>/g" a.xml

mkdir $NIFI_HOME/logs -p 
touch $NIFI_HOME/logs/nifi-app.log
#exec /nifi/bin/nifi.sh run
$NIFI_HOME/bin/nifi-env.sh
#tail -F $NIFI_HOME/logs/nifi-app.log & $NIFI_HOME/bin/nifi.sh run
#exec /sbin/setuser memcache /usr/bin/memcached >>/var/log/memcached.log 2>&1
$NIFI_HOME/bin/nifi.sh start; tail -f $NIFI_HOME/logs/nifi-app.log





