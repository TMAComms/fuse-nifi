#!/bin/sh

export NIFI_HOME=/opt/nifi 
$NIFI_HOME/bin/nifi-env.sh
echo "Resetting owner on /opt/nifi:
sudo chown -R nifi:nifi /opt/nifi/
echo "Resetting owner on /opt/nifi done"
tail -F $NIFI_HOME/logs/nifi-app.log &  $NIFI_HOME/bin/nifi.sh run

