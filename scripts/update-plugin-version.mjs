import { readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { spawnSync } from 'node:child_process';

const root = resolve(import.meta.dirname, '..');
const packagePath = resolve(root, 'plugins/dsh-harmony/package.json');

export function validPluginVersion(value) {
  return typeof value === 'string' &&
    /^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-[0-9A-Za-z.-]+)?$/.test(value);
}

export function replacePluginVersion(content, previous, next) {
  if (!validPluginVersion(previous) || !validPluginVersion(next)) {
    throw Error('Invalid plugin version');
  }
  return content.split(previous).join(next);
}

const references = [
  'README.md',
  'README.en.md',
  'docs/PLUGIN-INSTALL.md',
  'plugins/dsh-harmony/README.md',
  'harmony/entry/src/main/ets/services/BuildInfo.ets',
  'harmony/entry/src/main/ets/services/StoreShowcaseClient.ets'
];

async function update(version, packageAfter) {
  if (!validPluginVersion(version)) {
    throw Error('Usage: node scripts/update-plugin-version.mjs <major.minor.patch> [--no-package]');
  }
  const manifest = JSON.parse(await readFile(packagePath, 'utf8'));
  const previous = manifest.version;
  if (!validPluginVersion(previous)) throw Error('Current plugin version is invalid');
  if (previous === version) throw Error('Requested plugin version is already current');
  manifest.version = version;
  const edits = [];
  for (const relative of references) {
    const filename = resolve(root, relative);
    const before = await readFile(filename, 'utf8');
    const after = replacePluginVersion(before, previous, version);
    if (after !== before) edits.push({ filename, after });
  }
  await writeFile(packagePath, JSON.stringify(manifest, null, 2) + '\n');
  for (const edit of edits) await writeFile(edit.filename, edit.after);
  console.log(`Updated plugin ${previous} -> ${version} across ${edits.length + 1} files`);
  if (!packageAfter) {
    console.log('Packaging skipped; run node scripts/package-plugin.mjs before distribution');
    return;
  }
  const packaged = spawnSync(process.execPath,
    [resolve(root, 'scripts/package-plugin.mjs')], { cwd: root, stdio: 'inherit' });
  if (packaged.status !== 0) process.exit(packaged.status || 1);
}

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  await update(process.argv[2] || '', !process.argv.includes('--no-package'));
}
