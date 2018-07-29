#!/bin/bash
#
# Commons functions.

dir=$(dirname "${BASH_SOURCE[0]}")
if [[ ! -d $dir ]]; then dir=$PWD; fi
#shellcheck source=scripts/utils.sh
. "${dir#/}/utils.sh"
#shellcheck source=scripts/constants.sh
. "${dir#/}/constants.sh"

###############################################################################
# Create and set permission to the CouchDB data directory.
###############################################################################
function create_data_dir() {
  mkdir -p $COUCHDB_DATA_DIR
  chown -fR couchdb:couchdb $COUCHDB_DATA_DIR || true
  chmod -fR 0770 $COUCHDB_DATA_DIR || true
}

###############################################################################
# Start the CouchDB server.
###############################################################################
function start_couchdb() {
  strong_echo "Start CouchDB"
  exec tini -s -- $BASE_ENTRYPOINT $COUCHDB_BIN &
}
