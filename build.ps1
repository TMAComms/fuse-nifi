$ErrorActionPreference = "Stop"

$tmacBaseImage = "tmacomms/fuse-nifi:latest"
$tmacRegistryPath = "registry.tmacomms.com"
$tmacAzureRegistryPath = "tmacregistry-tmacomms.azurecr.io"
$tmacFullPath = "$tmacAzureRegistryPath/$tmacBaseImage"

echo "Setting up base image $tmacFullPath"
docker login tmacregistry-tmacomms.azurecr.io -u tmacregistry -p mCsU/6AXX+SsTt79hqT=NZW1KDpjWdVk 

echo "Building image $tmacBaseImage"
#docker build --force-rm --file Dockerfile-gateway.build --squash -t $tmacBaseImage .

#docker build --file Dockerfile-jobserver.build --squash -t  tmacomms/evs-jobserver:latest .
docker build --file Dockerfile --squash -t $tmacBaseImage .

echo "docker run -it --name nifi --rm -v ${pwd}/working:/working -p 9090:9090 $tmacBaseImage"

1