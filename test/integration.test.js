const path = require('path');
const test = require('ava');
const {writeJson, appendFile} = require('fs-extra');
const execa = require('execa');
const got = require('got');
const tempy = require('tempy');
const npmRegistry = require('./helpers/run-docker-image');

/* eslint camelcase: ["error", {properties: "never"}] */

const COUCHDB_USER = 'admin';
const COUCHDB_PASSWORD = 'password';
const NPM_USERNAME = 'integration';
const NPM_PASSWORD = 'suchsecure';
const NPM_EMAIL = 'integration@test.com';

const env = {
  ...process.env,
  npm_config_registry: npmRegistry.url,
};

test.before(async () => {
  await npmRegistry.start({COUCHDB_USER, COUCHDB_PASSWORD});
});

test.after.always(async () => {
  await npmRegistry.stop();
});

test('Create npm user and publish a package', async t => {
  const name = 'test-package';
  let version = '1.0.0';
  const cwd = tempy.directory();

  t.log('Create npm user');
  await got(`${npmRegistry.baseUrl}/_users/org.couchdb.user:${NPM_USERNAME}`, {
    username: COUCHDB_USER,
    password: COUCHDB_PASSWORD,
    method: 'PUT',
    json: {
      _id: `org.couchdb.user:${NPM_USERNAME}`,
      name: NPM_USERNAME,
      roles: [],
      type: 'user',
      password: NPM_PASSWORD,
      email: NPM_EMAIL,
    },
  });

  t.log('Verify user');
  await appendFile(
    path.resolve(cwd, '.npmrc'),
    `_auth = ${Buffer.from(`${NPM_USERNAME}:${NPM_PASSWORD}`, 'utf8').toString('base64')}
email = ${NPM_EMAIL}
registry = ${npmRegistry.url}
`
  );
  t.is((await execa('npm', ['whoami'], {cwd, env})).stdout, NPM_USERNAME);

  t.log('Publish package');
  await writeJson(path.resolve(cwd, 'package.json'), {name, version});
  let {exitCode} = await execa('npm', ['publish'], {cwd, env});
  t.is(exitCode, 0);
  t.is((await execa('npm', ['view', name, 'version'], {cwd, env})).stdout, version);

  t.log('Publish on @next');
  version = '1.1.0';
  await execa('npm', ['version', version], {cwd, env});
  ({exitCode} = await execa('npm', ['publish', '--tag', 'next'], {cwd, env}));
  t.is(exitCode, 0);
  t.is((await execa('npm', ['view', name, 'dist-tags.next'], {cwd, env})).stdout, version);

  t.log('Add to @latest');
  ({exitCode} = await execa('npm', ['dist-tag', 'add', `${name}@${version}`, 'latest'], {cwd, env}));
  t.is(exitCode, 0);
  t.is((await execa('npm', ['view', name, 'dist-tags.latest'], {cwd, env})).stdout, version);
});
