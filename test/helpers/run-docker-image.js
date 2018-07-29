import Docker from 'dockerode';
import got from 'got';
import delay from 'delay';
import pRetry from 'p-retry';

const IMAGE = 'semanticrelease/npm-registry-docker';
const SERVER_PORT = 15986;
const COUCHDB_PORT = 5984;
const SERVER_HOST = 'localhost';

const docker = new Docker();
let container;

async function start({COUCHDB_USER, COUCHDB_PASSWORD}) {
  container = await docker.createContainer({
    Tty: true,
    Image: IMAGE,
    PortBindings: {[`${COUCHDB_PORT}/tcp`]: [{HostPort: `${SERVER_PORT}`}]},
    Env: [`COUCHDB_USER=${COUCHDB_USER}`, `COUCHDB_PASSWORD=${COUCHDB_PASSWORD}`],
  });

  await container.start();
  await delay(4000);

  try {
    // Wait for the registry to be ready
    await pRetry(() => got(`http://${SERVER_HOST}:${SERVER_PORT}/registry/_design/app`, {cache: false}), {
      retries: 7,
      minTimeout: 1000,
      factor: 2,
    });
  } catch (err) {
    throw new Error(`Couldn't start npm-registry-docker after 2 min`);
  }
}

const baseUrl = `http://${SERVER_HOST}:${SERVER_PORT}`;
const url = `${baseUrl}/registry/_design/app/_rewrite/`;

async function stop() {
  await container.stop();
  await container.remove();
}

export default {start, stop, url, baseUrl};
