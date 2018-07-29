#!/bin/bash
#
# Global constants.

# shellcheck disable=SC2034

###############################################################################
# apache/couchdb base image constants.
###############################################################################

# CouchDB binary defined in apache/couchdb base image
COUCHDB_BIN="/opt/couchdb/bin/couchdb"
# apache/couchdb base image entrypoint script
BASE_ENTRYPOINT="/docker-entrypoint.sh"
# docker.ini file path defined in apache/couchdb base image
DOCKER_INI="/opt/couchdb/etc/local.d/docker.ini"

###############################################################################
# npm-registry-couchapp npm package constants.
###############################################################################

# Install directory of the npm-registry-couchapp npm package
COUCHAPP="node_modules/npm-registry-couchapp"

###############################################################################
# Dockerfile .
###############################################################################

# CouchDB data directory; Must match the directory in which the Dockerfile copies the data files
COUCHDB_DATA_DIR="/usr/local/var/lib/couchdb"
# CouchDB config directory; Must match the directory in which the Dockerfile copies the config file
COUCHDB_CONFIG_DIR="/opt/couchdb/etc/"
