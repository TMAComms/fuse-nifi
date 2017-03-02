#!/bin/bash
tmacBaseImage="tmacomms/fuse-nifi:latest"
tmacRegistryPath="registry.tmacomms.com"
tmacAzureRegistryPath="tmacregistry-tmacomms.azurecr.io"
tmacFullPath=$tmacAzureRegistryPath/$tmacBaseImage

echo "Setting up base image $tmacFullPath"

# from https://github.com/andrey-pohilko/registry-cli
##registry.py -l tmacregistry:mCsU/6AXX+SsTt79hqT=NZW1KDpjWdVk  -r https://tmacregistry-tmacomms.azurecr.io:443

echo "Building image $tmacBaseImage"
docker build -t $tmacBaseImage .

docker tag $tmacBaseImage $tmacAzureRegistryPath/$tmacBaseImage

echo "Pushing image to " $tmacFullPath
docker login tmacregistry-tmacomms.azurecr.io -u tmacregistry -p mCsU/6AXX+SsTt79hqT=NZW1KDpjWdVk
docker push $tmacFullPath



