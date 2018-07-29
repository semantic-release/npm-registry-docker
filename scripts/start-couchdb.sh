#!/bin/bash
#
# Start CouchDB.

dir=$(dirname "${BASH_SOURCE[0]}")
if [[ ! -d $dir ]]; then dir=$PWD; fi
#shellcheck source=scripts/functions.sh
. "${dir#/}/functions.sh"
#shellcheck source=scripts/constants.sh
. "${dir#/}/constants.sh"

###############################################################################
# Log the begining of a step.
#
# Globals:
#   VHOST: virtual host to set.
###############################################################################
function add_vhost() {
  if [ -n "${VHOST:-}" ]; then
    sed -i "/\\[vhosts\\]/a $(sed 's/[&/\]/\\&/g' <<<"${VHOST}:5984 = /registry/_design/app/_rewrite")" "${COUCHDB_CONFIG_DIR}/local.ini"
  fi
}

###############################################################################
# Globals variables.
###############################################################################
export COUCHDB_USER="${COUCHDB_USER:-admin}"
export COUCHDB_PASSWORD="${COUCHDB_PASSWORD:-admin}"
export NODENAME="${NODENAME:-localhost}"
export VHOST="${VHOST:-}"

###############################################################################
# Main script section.
###############################################################################

set -e

# Create CouchDB data directory
create_data_dir

# Create a vhost if one is set in VHOST environment variable
add_vhost

# Start CouchDB
start_couchdb

wait
