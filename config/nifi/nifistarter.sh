#!/bin/sh

# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.
#exec /nifi/bin/nifi.sh run

export NIFI_HOME=/opt/nifi 
$NIFI_HOME/bin/nifi-env.sh
tail -F $NIFI_HOME/logs/nifi-app.log &  $NIFI_HOME/bin/nifi.sh run

