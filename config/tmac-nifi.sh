#!/bin/sh

echo "TMAC Nifi starter " ${NIFI_HOME}
# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.

#sed -i.bak "s/<author type=''>/<author type='Local'>/g" a.xml


#exec /nifi/bin/nifi.sh run
/opt/nifi/nifi-1.4.0/bin/nifi-env.sh
tail -F /opt/nifi/nifi-1.4.0/logs/nifi-app.log & /opt/nifi/nifi-1.4.0/bin/nifi.sh run
#exec /sbin/setuser memcache /usr/bin/memcached >>/var/log/memcached.log 2>&1