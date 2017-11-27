
#!/bin/sh
# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.
#exec /nifi/bin/nifi.sh run
#exec tail -F /nifi/logs/nifi-app.log & /nifi/bin/nifi.sh run
#exec /sbin/setuser memcache /usr/bin/memcached >>/var/log/memcached.log 2>&1

exec "$REGISTRY_HOME/bin/registry-server-start.sh $REGISTRY_HOME/conf/registry.yaml"

