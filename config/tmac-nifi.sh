#!/bin/sh
set -e 

echo "TMAC Nifi starter " ${NIFI_HOME}

function set_nifi_properties()  {
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    for property in $(env | grep -i NIFI_ | grep -v HOME); do 
        key=$(echo $property | cut -f1 -d= | sed -e 's/_/./g' | tr A-Z a-z)
        value=$(eval echo $property | cut -f2 -d=)
        sed -e "s~$key=.*~$key=$value~" -i $NIFI_HOME/conf/nifi.properties
    done
    IFS=$SAVEIFS
}

function set_java() {
   JAVA_MS=${JAVA_MS:=1024}
   JAVA_MX=${JAVA_MX:=1024}
   sed -e "s/Xms.*/Xms${JAVA_MS}m/" -e "s/Xmx.*/Xmx${JAVA_MX}m/" -i $NIFI_HOME/conf/bootstrap.conf
}

function set_hdfs() {
 if [ ${HDFS_SERVICE_NAME} ]; then
  mkdir -p $NIFI_HOME/hdfs
  API_PORT=$(dig _${HDFS_SERVICE_NAME}._tcp.marathon.mesos SRV +short | cut -d " " -f 3)
  wget -O $NIFI_HOME/hdfs/core-site.xml "${HDFS_SERVICE_NAME}.marathon.mesos:${API_PORT}/v1/endpoints/core-site.xml"
  wget -O $NIFI_HOME/hdfs/hdfs-site.xml "${HDFS_SERVICE_NAME}.marathon.mesos:${API_PORT}/v1/endpoints/hdfs-site.xml"
 fi
}

function set_cluster() {
 if [ ${NIFI_CLUSTER_IS_NODE} ]; then
   PORT0=${PORT0:=10001}
   PORT1=${PORT1:=10002}
   PORT2=${PORT2:=10003}
   sed -e "s/nifi.cluster.node.address=.*/nifi.cluster.node.address=${HOST}/" \
       -e "s/nifi.web.http.host=.*/nifi.web.http.host=${HOST}/" \
       -e "s/nifi.remote.input.host=.*/nifi.remote.input.host=${HOST}/" \
       -e "s/nifi.cluster.node.address=.*/nifi.cluster.node.address=${HOST}/" \
       -e "s/nifi.web.http.port=.*/nifi.web.http.port=${PORT0}/" \
       -e "s/nifi.remote.input.socket.port=.*/nifi.remote.input.socket.port=${PORT1}/" \
       -e "s/nifi.cluster.node.protocol.port=.*/nifi.cluster.node.protocol.port=${PORT2}/" \
   -i $NIFI_HOME/conf/nifi.properties
 fi
}



set_nifi_properties
set_java
set_hdfs
set_cluster

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



