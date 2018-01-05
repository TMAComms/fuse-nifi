
FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y software-properties-common apt-utils locales tzdata

RUN echo "tzdata tzdata/Areas select Europe" > timezone.txt
RUN echo "tzdata tzdata/Zones/Europe select Rome" >> timezone.txt
RUN debconf-set-selections timezone.txt
RUN rm /etc/timezone
RUN rm /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata



# nat network for docker 

docker network create -d nat --subnet=172.16.238.0/24 --gateway=172.16.238.1 my_network

- https://forums.docker.com/t/how-to-force-docker-for-windows-to-assign-private-and-static-ip-to-the-websites/28111/15
