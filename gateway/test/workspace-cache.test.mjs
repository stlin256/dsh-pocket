import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import vm from 'node:vm';
import ts from 'typescript';

const services = new URL('../../harmony/entry/src/main/ets/services/', import.meta.url);

class NativeDirectoryEntry {
  name = '';
  type = 'other';
  size = -1;
}

class NativeDirectoryListing {
  path = '';
  entries = [];
  truncated = false;
}

class NativeFilePage {
  absolutePath = '';
  version = '';
  text = '';
  lines = 0;
  offset = 1;
  eof = false;
}

function loadWorkspaceCache() {
  const source = readFileSync(new URL('NativeWorkspaceCache.ets', services), 'utf8');
  const output = ts.transpileModule(source, {
    compilerOptions: { target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.CommonJS }
  });
  const module = { exports: {} };
  vm.runInNewContext(output.outputText, {
    module,
    exports: module.exports,
    require: id => {
      if (id === './NativeHarnessClient') {
        return { NativeDirectoryEntry, NativeDirectoryListing, NativeFilePage };
      }
      if (id === '@kit.AbilityKit') return {};
      if (id === '@kit.CoreFileKit') return { fileIo: {} };
      if (id === '@kit.ArkData') return { relationalStore: {} };
      if (id === '@kit.ArkTS') return { util: {} };
      throw Error('Unexpected dependency: ' + id);
    }
  });
  return module.exports;
}

function entry(name, type, size = -1) {
  return Object.assign(new NativeDirectoryEntry(), { name, type, size });
}

test('directory cache fingerprints are canonical and detect metadata changes', () => {
  const { nativeDirectoryFingerprint } = loadWorkspaceCache();
  const files = [entry('b.ts', 'file', 20), entry('src', 'directory')];
  const reordered = [entry('src', 'directory'), entry('b.ts', 'file', 20)];
  assert.equal(nativeDirectoryFingerprint(files, false),
    nativeDirectoryFingerprint(reordered, false),
    'server response order alone must not invalidate a cache');
  assert.notEqual(nativeDirectoryFingerprint(files, false),
    nativeDirectoryFingerprint([entry('b.ts', 'file', 21), entry('src', 'directory')], false));
  assert.notEqual(nativeDirectoryFingerprint(files, false),
    nativeDirectoryFingerprint(files, true));
  assert.notEqual(nativeDirectoryFingerprint(files, false),
    nativeDirectoryFingerprint([entry('b.ts', 'directory'), entry('src', 'directory')], false));
});

test('directory and text cache payloads reject corrupt metadata', () => {
  const {
    NativeWorkspaceCachedDirectory,
    NativeWorkspaceCachedText,
    nativeDirectoryFingerprint,
    nativeValidWorkspaceDirectoryCache,
    nativeValidWorkspaceTextCache,
    nativeWorkspaceTextChecksum
  } = loadWorkspaceCache();
  const directory = new NativeWorkspaceCachedDirectory();
  const listing = new NativeDirectoryListing();
  listing.path = 'src';
  listing.entries = [entry('main.ts', 'file', 12)];
  directory.listing = listing;
  directory.savedAt = Date.now();
  directory.fingerprint = nativeDirectoryFingerprint(listing.entries, false);
  assert.equal(nativeValidWorkspaceDirectoryCache(directory), true);
  listing.entries[0].size = 13;
  assert.equal(nativeValidWorkspaceDirectoryCache(directory), false);

  const text = new NativeWorkspaceCachedText();
  text.savedAt = Date.now();
  text.page = Object.assign(new NativeFilePage(), {
    absolutePath: '/workspace/README.md',
    version: 'v1',
    text: '# cached',
    lines: 1,
    offset: 1,
    eof: true
  });
  text.checksum = nativeWorkspaceTextChecksum(text.page);
  assert.equal(nativeValidWorkspaceTextCache(text), true);
  text.page.text = '# changed';
  assert.equal(nativeValidWorkspaceTextCache(text), false);
});

test('workspace cache keys are one-way and account scoped', () => {
  const { nativeWorkspaceScopeId } = loadWorkspaceCache();
  const first = nativeWorkspaceScopeId('https://one.example/#account-a');
  const second = nativeWorkspaceScopeId('https://one.example/#account-b');
  assert.match(first, /^[0-9a-f]+:[0-9a-f]+:[0-9a-f]+$/);
  assert.notEqual(first, second);
  assert.equal(first, nativeWorkspaceScopeId('https://one.example/#account-a'));
  assert.equal(first.includes('one.example'), false);
});

test('workspace surfaces paint validated cache before remote revalidation', () => {
  const browser = readFileSync(new URL(
    '../../harmony/entry/src/main/ets/components/NativeFileBrowser.ets', import.meta.url), 'utf8');
  const loadBody = browser.slice(browser.indexOf('private async load('),
    browser.indexOf('private parent()'));
  assert.ok(loadBody.indexOf('NativeWorkspaceCache.loadDirectory') <
    loadBody.indexOf('this.client.listFiles'));
  assert.match(loadBody, /cached\.fingerprint !== fingerprint/);
  assert.match(loadBody, /NativeWorkspaceCache\.saveDirectory/);
  assert.match(loadBody, /generation !== this\.requestGeneration/);

  const preview = readFileSync(new URL(
    '../../harmony/entry/src/main/ets/components/NativeFilePreview.ets', import.meta.url), 'utf8');
  const previewLoad = preview.slice(preview.indexOf('private async load('),
    preview.indexOf('private async loadMetadata('));
  assert.ok(previewLoad.indexOf('this.loadCachedImage') < previewLoad.indexOf('this.loadImageWithRetry'));
  assert.match(previewLoad, /stat\.version === this\.version/);
  assert.match(previewLoad, /stat\.version === cachedText\.page\.version/);
  assert.ok(previewLoad.indexOf('NativeWorkspaceCache.loadText') <
    previewLoad.indexOf('this.loadText(true'));

  const cache = readFileSync(new URL('NativeWorkspaceCache.ets', services), 'utf8');
  assert.match(cache, /encrypt: true/);
  assert.match(cache, /fileIo\.renameSync\(temporary, absolute\)/);
  assert.match(cache, /byteHash\(valueBytes\) !== checksum/);
  const index = readFileSync(new URL(
    '../../harmony/entry/src/main/ets/pages/Index.ets', import.meta.url), 'utf8');
  assert.match(index, /NativeWorkspaceCache\.clearScope/);
});
