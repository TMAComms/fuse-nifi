docker run -it -d -p 443:443 -p 8000:8000 -p 80:80 tmacregistry-tmacomms.azurecr.io/tmacomms/evs-router:latest
NIFI_WEB_HTTP_HOST

docker run -it --rm -v e:\tmac:/tmac -p 8080:8080 -e NIFI_WEB_HTTP_HOST=tmac-devops1681939944003.australiaeast.cloudapp.azure.com  fusenifi
docker run -it --rm -v E:\bb\fuse\fuse-nifi\tlskit:/toolkit -v e:\nifi\work:/opt/nifi/nifi-1.5.0/work -p 8080:8080 -e NIFI_WEB_HTTP_PORT=8080 -e NIFI_WEB_HTTP_HOST=cloudfunk fusenifi

/opt/nifitoolkit/bin/tls-toolkit.sh standalone -n localhost,azurenifi,nifi,nifi.prod.us.tmacomms.com,nifi.dev.us.tmacomms.com,nifi-dev.tmacomms.com,nifi-prod.tmacomms.com  -o /toolkit/generated -S Smile4ow -K Smile4ow -f /toolkit/nifibase.properties -C "CN=user, OU=NIFI"