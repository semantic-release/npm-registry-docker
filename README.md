# semanticrelease/npm-registry-docker

[CouchDB Docker image](https://github.com/apache/couchdb-docker) running [npm-registry-couchapp](https://github.com/npm/npm-registry-couchapp).

[![Travis](https://img.shields.io/travis/com/semantic-release/npm-registry-docker.svg)](https://travis-ci.com/semantic-release/npm-registry-docker)
[![Greenkeeper badge](https://badges.greenkeeper.io/semantic-release/npm-registry-docker.svg)](https://greenkeeper.io/)

This docker image is for test and development purposes only.

## Install

```bash
$ docker pull semanticrelease/npm-registry-docker:latest
```

## Usage

### With default environment variables

```bash
$ docker run -d -p 5984:5984 semanticrelease/npm-registry-docker
```

The npm registry is accessible on `http://localhost:5984/registry/_design/app/_rewrite` and the CouchDB user `admin` with password `admin` is created.

To configure npm to use the registry:
```bash
$ npm config set registry http://localhost:5984/registry/_design/app/_rewrite
```

To create a npm user and configure npm authentication:
```bash
$ curl -H 'Content-Type: application/json' -XPUT -d '{"_id": "org.couchdb.user:npm-user","name": "npm-user","roles": [],"type": "user","password": "npm-password","email":  "npm-user@test.com"}' "http://admin:admin@localhost:5984/_users/org.couchdb.user:npm-user"

$ echo "_auth = $(echo -n npm-user:npm-password | base64)" >> .npmrc
$ echo "email = npm-user@test.com" >> .npmrc
```

### With custom admin user and vhost configuration

```bash
$ docker run -d -p 5984:5984 -e COUCHDB_USER=my-user -e COUCHDB_PASSWORD=my-password -e VHOST=my-registry.com semanticrelease/npm-registry-docker
```

The npm registry is accessible on `http://my-registry:5984` and the CouchDB user `my-user` with password `my-password` is created.

To configure npm to use the registry:
```bash
$ npm config set registry http://my-registry:5984
```

To create a npm user and configure npm authentication:
```bash
$ curl -H 'Content-Type: application/json' -XPUT -d '{"_id": "org.couchdb.user:npm-user","name": "npm-user","roles": [],"type": "user","password": "npm-password","email":  "npm-user@test.com"}' "http://my-user:my-password@localhost:5984/_users/org.couchdb.user:npm-user"

$ echo "_auth = $(echo -n npm-user:npm-password | base64)" >> .npmrc
$ echo "email = npm-user@test.com" >> .npmrc
```
