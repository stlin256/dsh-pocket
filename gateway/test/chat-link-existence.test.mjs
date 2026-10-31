import { test } from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import vm from 'node:vm';
import ts from 'typescript';

const services = new URL('../../harmony/entry/src/main/ets/services/', import.meta.url);

function load(name, kits = {}) {
  const source = readFileSync(new URL(name + '.ets', services), 'utf8');
  const output = ts.transpileModule(source, {
    compilerOptions: { target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.CommonJS }
  });
  const module = { exports: {} };
  vm.runInNewContext(output.outputText, {
    module,
    exports: module.exports,
    require: id => {
      if (!(id in kits) && id.startsWith('./') && existsSync(new URL(id.slice(2) + '.ets', services))) {
        return load(id.slice(2), kits);
      }
      if (!(id in kits)) throw Error('Unexpected dependency: ' + id);
      return kits[id];
    }
  });
  return module.exports;
}

test('chat workspace targets require confirmed file or directory existence', () => {
  const { nativeResolvedWorkspaceTarget } = load('NativeWorkspaceTarget');
  assert.deepEqual({ ...nativeResolvedWorkspaceTarget('/workspace/project/README.md', true, false) },
    { kind: 'file', path: '/workspace/project/README.md' });
  assert.deepEqual({ ...nativeResolvedWorkspaceTarget('/workspace/project/docs', false, true) },
    { kind: 'browser', path: '/workspace/project/docs' });
  assert.deepEqual({ ...nativeResolvedWorkspaceTarget('/workspace/project/missing.md', false, false) },
    { kind: '', path: '' });
  assert.deepEqual(
    { ...nativeResolvedWorkspaceTarget('/workspace/project/README.md', false, false, 'docs/README.md') },
    { kind: 'file', path: 'docs/README.md' });
});

test('chat inline links publish a surface only after target confirmation', () => {
  const inline = readFileSync(new URL(
    '../../harmony/entry/src/main/ets/components/NativeInlineText.ets', import.meta.url), 'utf8');
  const openBody = inline.slice(inline.indexOf('private async openFile('),
    inline.indexOf('@Builder', inline.indexOf('private async openFile(')));
  assert.match(openBody, /client\.resolveWorkspaceTarget\(/);
  assert.match(openBody, /if \(!target\.kind \|\| !target\.path\)/);
  assert.match(inline, /request\.previewOnly = kind === 'file'/);
  assert.match(inline, /message: '文件或文件夹不可用'/);
  assert.doesNotMatch(openBody, /this\.openFileView\('file', path, requestId\);/);
  assert.ok(openBody.indexOf('resolveWorkspaceTarget') < openBody.indexOf('openFileView'));

  const browser = readFileSync(new URL(
    '../../harmony/entry/src/main/ets/components/NativeFileBrowser.ets', import.meta.url), 'utf8');
  const pushBody = browser.slice(browser.indexOf('private browserPushChanged()'),
    browser.indexOf('private child(', browser.indexOf('private browserPushChanged()')));
  assert.ok(pushBody.indexOf("this.history.push(this.currentEntry().kind, this.currentEntry().path)")
    < pushBody.indexOf('this.previewPath = next'));

  const client = readFileSync(new URL(
    '../../harmony/entry/src/main/ets/services/NativeHarnessClient.ets', import.meta.url), 'utf8');
  const resolveBody = client.slice(client.indexOf('async resolveWorkspaceTarget('),
    client.indexOf('/**\n   * Resolve a model-emitted basename'));
  assert.match(resolveBody, /this\.statFile\(id, path\)/);
  assert.match(resolveBody, /this\.listFiles\(id, path\)/);
  assert.ok(resolveBody.indexOf('this.statFile(id, path)') <
    resolveBody.indexOf('await fileProbe'));
});
