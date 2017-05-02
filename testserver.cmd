REM To test, ensure that the image is built in bitbucket
docker login tmacregistry-tmacomms.azurecr.io -u tmacregistry -p mCsU/6AXX+SsTt79hqT=NZW1KDpjWdVk
docker pull tmacregistry-tmacomms.azurecr.io/tmacomms/fuse-nifi:latest
docker run -it --rm -p 2222:2222 tmacregistry-tmacomms.azurecr.io/tmacomms/fuse-nifi:latest
