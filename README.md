# README #

### What is this repository for? ###

* Fuse build of nifi docker container
* Version 1.1.2

## How do I get set up? ###

### Locally 
** Git clone this repo
** docker-compose up

### Via Rancher
* git clone this repo
** run ./build.sh which will push this to the registry
** Use the rancher catalog TMAC - apache-nifi catalog item

## Data 

This image has a lot of data points, refer to your compose file for details
        - /logs/nifi:/opt/nifi/logs:rw

### used for artifacts storage (shared)
        - /config/nifi/shared/datafiles/:/opt/datafiles/
        - /config/nifi/shared/scriptfiles/:/opt/scriptfiles/
        - /config/nifi/shared/certfiles/:/opt/certfiles/
### automatic snapshots of flows 
        - /config/nifi/archives/:/tmac/archives/:rw
        - /config/nifi/templates/:/tmac/templates/:rw
### current flow on ui
        - /config/nifi/flow/:/tmac/flow/:rw


### Used during runtime (not stored in shared config)  - No longer in use
- /config/nifi/repos/flowfile_repository/:/opt/nifi/flowfile_repository/
- /config/nifi/repos/database_repository/:/opt/nifi/database_repository/
- /config/nifi/repos/provenance_repository/:/opt/nifi/provenance_repository/
- /config/nifi/repos/content_repository/:/opt/nifi/content_repository/
