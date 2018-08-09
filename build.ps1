$ErrorActionPreference = "Stop"

$tmacBaseImage = "tmacomms/fuse-nifi:latest"
$tmacRegistryBaseImage = "tmacomms/fuse-nifiregistry:latest"
$tmacSchemaRegistryBaseImage = "tmacomms/fuse-schemaregistry:latest"
$tmacRegistryPath = "registry.tmacomms.com"
$tmacAzureRegistryPath = "tmacregistry-tmacomms.azurecr.io"
$tmacFullPath = "$tmacAzureRegistryPath/$tmacBaseImage"

echo "Setting up base image $tmacFullPath"
docker login tmacregistry-tmacomms.azurecr.io -u tmacregistry -p mCsU/6AXX+SsTt79hqT=NZW1KDpjWdVk 

echo "Building image $tmacBaseImage"
#docker build --force-rm --file Dockerfile-gateway.build --squash -t $tmacBaseImage .

#docker build --file Dockerfile-jobserver.build --squash -t  tmacomms/evs-jobserver:latest .
docker build --file Dockerfile --squash -t $tmacBaseImage .
echo "Building image $tmacRegistryBaseImage"
docker build --file Dockerfile.registry --squash -t $tmacRegistryBaseImage .

echo "Building image $tmacSchemaRegistryBaseImage"
docker build --file Dockerfile.schemaregistry --squash -t $tmacSchemaRegistryBaseImage .
echo "docker run -it --name schemareg --rm  -p 9040:9090 $tmacSchemaRegistryBaseImage"

echo "docker run -it --name nifi --rm -v ${pwd}/working:/working -p 9090:9090 $tmacBaseImage"

1