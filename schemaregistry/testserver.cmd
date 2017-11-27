REM To test, ensure that the image is built in bitbucket
docker login tmacregistry-tmacomms.azurecr.io -u tmacregistry -p mCsU/6AXX+SsTt79hqT=NZW1KDpjWdVk
REM # docker pull tmacregistry-tmacomms.azurecr.io/tmacomms/fuse-schemaregistry:latest
docker run -it --rm -p 9090:9090 tmacregistry-tmacomms.azurecr.io/tmacomms/fuse-schemaregistry:latest
