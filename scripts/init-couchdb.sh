#!/bin/bash
#
# Initialize CouchDB, create databases and install npm-registry-couchapp.

dir=$(dirname "${BASH_SOURCE[0]}")
if [[ ! -d $dir ]]; then dir=$PWD; fi
#shellcheck source=scripts/functions.sh
. "${dir#/}/functions.sh"
#shellcheck source=scripts/constants.sh
. "${dir#/}/constants.sh"

###############################################################################
# Constants.
###############################################################################

# Databases to create
DATABASES=(_users _global_changes _metadata _replicator registry)

###############################################################################
# Wait until CouchDB is started.
#
# Arguments:
#   couchdb_url: The URL of the CouchDB instance.
###############################################################################
function wait_until_ready() {
  local couchdb_url=$1
  echo "Wait until $couchdb_url is started ..."
  while true; do
    http_code=$(curl -sL -w "%{http_code}\\n"  --connect-timeout 1 -o /dev/null -XGET "${couchdb_url}")
    if [ 200 -eq "${http_code}" ]; then
      echo "CouchDB service on ${couchdb_url} is started"
      break
    else
      sleep 1
      echo "Wait until ${couchdb_url} is started ..."
    fi
  done
}

###############################################################################
# Create a new database.
#
# Arguments:
#   couchdb_url: The URL of the CouchDB instance.
#   database_name: The name of the database to create.
# Returns:
#   0 if the database is created successfully, 1 otherwise.
###############################################################################
function create_database() {
  local couchdb_url=$1 database_name=$2
  http_code=$(curl -sL -w "%{http_code}\\n" --connect-timeout 30 -XPUT "${couchdb_url}/${database_name}"  -o /dev/null)
  if [[ ( 200 -eq "${http_code}" ) || ( 201 -eq "${http_code}" ) ]]; then
    echo "Database ${database_name} created successfully on CouchDB."
    return 0
  else
    echo "Create database ${database_name} failed with HTTP code: ${http_code}"
    return 1
  fi
}

###############################################################################
# Create all the databases defined in $DATABASES.
#
# Arguments:
#   couchdb_url: The URL of the CouchDB instance.
###############################################################################
function create_databases() {
  local couchdb_url=$1
  strong_echo "Creating databases"
  for database in "${DATABASES[@]}"
  do
    create_database "${couchdb_url}" "${database}"
  done
}

###############################################################################
# Set the CouchDB data directory in the local.ini config file.
###############################################################################
function set_config_data_dir() {
  sed -i "s/<%COUCHDB_DATA_DIR%>/$(sed 's/[&/\]/\\&/g' <<<"${COUCHDB_DATA_DIR}")/g" "${COUCHDB_CONFIG_DIR}/local.ini"
}

###############################################################################
# Set the registry URL in ~/.npmrc.
#
# Arguments:
#   couchdb_url: The URL of the CouchDB instance.
###############################################################################
function set_npm_config() {
  local couchdb_url=$1
  strong_echo "Set registry URL in ~/.npmrc"
  echo "_npm-registry-couchapp:couch=${couchdb_url}/registry" >> ~/.npmrc
}

###############################################################################
# Install npm-registry-couchapp.
###############################################################################
function install_registry_app() {
  if cd $COUCHAPP; then
    strong_echo "Run npm-registry-couchapp start script"
    DEPLOY_VERSION=testing npm start
    sleep 2

    strong_echo "Run npm-registry-couchapp load script"
    npm run load
    sleep 2

    strong_echo "Run npm-registry-couchapp copy script"
    NO_PROMPT=true npm run copy
    sleep 15
  else
    error_exit "The npm-registry-couchapp package is not installed";
  fi
}

###############################################################################
# Remove the admin credentials created during the build stage.
###############################################################################
function reset_admin() {
  rm $DOCKER_INI
}

###############################################################################
# Globals variables.
###############################################################################
export COUCHDB_USER="admin"
export COUCHDB_PASSWORD="admin"
export NODENAME="localhost"

###############################################################################
# Main script section.
###############################################################################

couchdb_url="http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@${NODENAME}:5984"

# Create CouchDB data directory
create_data_dir

# Set CouchDB data in local.ini config
set_config_data_dir

# Start CouchDB
start_couchdb
wait_until_ready $couchdb_url

set -e

# Create Databases
create_databases $couchdb_url

# Setup npm registry config
set_npm_config $couchdb_url

# Install npm registry app
install_registry_app

# Remove admin:admin authentication used for building the databases
reset_admin
