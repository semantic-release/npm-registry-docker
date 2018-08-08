# Build stage
FROM apache/couchdb:2.1 as builder

MAINTAINER Pierre Vanduynslager pierre.denis.vanduynslager@gmail.com

WORKDIR /build

# Install dependencies
COPY scripts/utils.sh .
COPY scripts/install-deps.sh .
RUN ./install-deps.sh

# Install npm-registry-couchapp
COPY package.json .
RUN npm install --production

# Copy base config
COPY config/local.ini /opt/couchdb/etc/

# Start CouchDB, create databases and install npm-registry-couchapp
COPY scripts/constants.sh scripts/functions.sh scripts/init-couchdb.sh ./
RUN ./init-couchdb.sh

# Image stage
FROM apache/couchdb:2.1

# Retrieve data and config
COPY --from=builder /usr/local/var/lib/couchdb /usr/local/var/lib/couchdb
COPY --from=builder /opt/couchdb/etc/ /opt/couchdb/etc/

# Start CouchDB with data and config from build stage
COPY scripts/constants.sh scripts/utils.sh scripts/functions.sh /
COPY scripts/start-couchdb.sh /
ENTRYPOINT ["/start-couchdb.sh"]
