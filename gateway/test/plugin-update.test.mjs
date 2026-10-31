import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import {
  replacePluginVersion,
  validPluginVersion
} from '../../scripts/update-plugin-version.mjs';

const root = new URL('../../', import.meta.url);

test('plugin update rewrites every version form without changing unrelated versions', () => {
  const before = 'plugin-v0.3.6/dsh-harmony-plugin-0.3.6.tgz app-0.4.6';
  assert.equal(replacePluginVersion(before, '0.3.6', '0.3.7'),
    'plugin-v0.3.7/dsh-harmony-plugin-0.3.7.tgz app-0.4.6');
  assert.equal(validPluginVersion('0.3.7'), true);
  assert.equal(validPluginVersion('v0.3.7'), false);
  assert.equal(validPluginVersion('0.03.7'), false);
  assert.equal(validPluginVersion('../0.3.7'), false);
});

test('checked-in App, Store, docs and plugin package versions stay synchronized', () => {
  const pkg = JSON.parse(readFileSync(new URL(
    'plugins/dsh-harmony/package.json', root), 'utf8'));
  const version = pkg.version;
  const files = [
    'README.md',
    'README.en.md',
    'docs/PLUGIN-INSTALL.md',
    'plugins/dsh-harmony/README.md',
    'harmony/entry/src/main/ets/services/BuildInfo.ets',
    'harmony/entry/src/main/ets/services/StoreShowcaseClient.ets'
  ];
  for (const file of files) {
    assert.match(readFileSync(new URL(file, root), 'utf8'), new RegExp(
      version.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')),
    `${file} must reference plugin ${version}`);
  }
});
