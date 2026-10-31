import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import ts from 'typescript';

const services = new URL('../../harmony/entry/src/main/ets/services/', import.meta.url);
const components = new URL('../../harmony/entry/src/main/ets/components/', import.meta.url);

function loadManager(values = {}) {
  const calls = [];
  const workspace = values.workspace || { directory: 200, text: 300, binary: 400 };
  const dependencies = {
    './NativeAttachmentCache': {
      NativeAttachmentCache: {
        async usageScope(_context, scope) {
          calls.push(['usage:attachments', scope]);
          return values.attachments ?? 500;
        },
        async clearScope(_context, scope) {
          calls.push(['clear:attachments', scope]);
          if (values.failAttachments) throw new Error('attachments');
        }
      }
    },
    './NativeMetadataCache': {
      NativeMetadataCache: {
        usage(_context, scope) {
          calls.push(['usage:navigation', scope]);
          return values.navigation ?? 600;
        },
        clear(_context, scope) {
          calls.push(['clear:navigation', scope]);
        }
      }
    },
    './NativeTranscriptCache': {
      NativeTranscriptCache: {
        async usageScope(_context, scope) {
          calls.push(['usage:transcript', scope]);
          return values.conversation ?? 100;
        },
        async clearScope(_context, scope) {
          calls.push(['clear:transcript', scope]);
          if (values.failTranscript) throw new Error('transcript');
        }
      }
    },
    './NativeWorkspaceCache': {
      NativeWorkspaceCacheUsage: class {},
      NativeWorkspaceCache: {
        async usageScope(_context, scope) {
          calls.push(['usage:workspace', scope]);
          return workspace;
        },
        async clearScope(_context, scope) {
          calls.push(['clear:workspace', scope]);
          if (values.failWorkspace) throw new Error('workspace');
        }
      }
    }
  };
  const source = readFileSync(new URL('NativeStorageManager.ets', services), 'utf8');
  const output = ts.transpileModule(source, {
    compilerOptions: { target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.CommonJS }
  });
  const module = { exports: {} };
  vm.runInNewContext(output.outputText, {
    module,
    exports: module.exports,
    require: id => {
      if (id === '@kit.AbilityKit') return {};
      if (id in dependencies) return dependencies[id];
      throw Error('Unexpected dependency: ' + id);
    }
  });
  return { exports: module.exports, calls };
}

test('storage sizes use compact binary units and reject invalid values', () => {
  const { nativeFormatStorageBytes } = loadManager().exports;
  assert.equal(nativeFormatStorageBytes(0), '0 B');
  assert.equal(nativeFormatStorageBytes(-10), '0 B');
  assert.equal(nativeFormatStorageBytes(Number.NaN), '0 B');
  assert.equal(nativeFormatStorageBytes(1023), '1023 B');
  assert.equal(nativeFormatStorageBytes(1024), '1 KiB');
  assert.equal(nativeFormatStorageBytes(1536), '1.5 KiB');
  assert.equal(nativeFormatStorageBytes(10.5 * 1024 * 1024), '10.5 MiB');
  assert.equal(nativeFormatStorageBytes(120.4 * 1024 * 1024), '120 MiB');
});

test('storage usage is a complete current-scope aggregate', async () => {
  const { exports, calls } = loadManager();
  const usage = await exports.NativeStorageManager.usageScope({}, 'scope-current');
  assert.deepEqual({
    conversation: usage.conversation,
    fileBrowser: usage.fileBrowser,
    fileContent: usage.fileContent,
    imageAttachments: usage.imageAttachments,
    navigation: usage.navigation,
    total: usage.total
  }, {
    conversation: 100,
    fileBrowser: 200,
    fileContent: 700,
    imageAttachments: 500,
    navigation: 600,
    total: 2100
  });
  assert.ok(calls.every(call => call[1] === 'scope-current'));
  assert.deepEqual(calls.map(call => call[0]),
    ['usage:transcript', 'usage:workspace', 'usage:attachments', 'usage:navigation']);
});

test('clear continues through every cache owner and reports partial failure', async () => {
  const { exports, calls } = loadManager({ failTranscript: true, failWorkspace: true });
  await assert.rejects(() => exports.NativeStorageManager.clearScope({}, 'scope-current'),
    /Cache clear failed/);
  assert.deepEqual(calls.map(call => call[0]),
    ['clear:navigation', 'clear:transcript', 'clear:workspace', 'clear:attachments']);
  assert.ok(calls.every(call => call[1] === 'scope-current'));
});

test('Settings exposes confirmed red storage clearing without success feedback', () => {
  const settings = readFileSync(new URL('NativeSettings.ets', components), 'utf8');
  assert.match(settings, /navigationRow\('archive-outline', '存储管理', '缓存占用与清理', 'storage'\)/);
  assert.match(settings, /NativeStorageManager\.usageScope\(context, this\.client\.cacheKey\(\)\)/);
  assert.match(settings, /NativeStorageManager\.clearScope\(context, this\.client\.cacheKey\(\)\)/);
  assert.match(settings, /title: '清空缓存'/);
  assert.match(settings, /message: '仅清除当前账户的本机缓存，不会退出登录或删除远端内容。'/);
  assert.match(settings, /fontColor: '#D44A4A'/);
  assert.match(settings, /Text\('清空缓存'\)[\s\S]{0,100}fontColor\(this\.dark \? '#FF9999' : '#B83A3A'\)/);
  assert.match(settings, /this\.settingsPage === 'storage'/);
  assert.doesNotMatch(settings, /Storage[^\n]*success|缓存已清空|showToast\([\s\S]{0,80}清空/);
});

test('cache owners expose non-mutating usage accounting', () => {
  const transcript = readFileSync(new URL('NativeTranscriptCache.ets', services), 'utf8');
  const workspace = readFileSync(new URL('NativeWorkspaceCache.ets', services), 'utf8');
  const attachments = readFileSync(new URL('NativeAttachmentCache.ets', services), 'utf8');
  const metadata = readFileSync(new URL('NativeMetadataCache.ets', services), 'utf8');
  assert.match(transcript, /static async usageScope[\s\S]{0,900}SUM\(bytes\)/);
  assert.match(workspace, /static async usageScope[\s\S]{0,900}directory_cache/);
  assert.match(workspace, /static async usageScope[\s\S]{0,1800}text_cache/);
  assert.match(workspace, /static async usageScope[\s\S]{0,2200}binary_cache/);
  assert.match(attachments, /static async usageScope[\s\S]{0,700}statSync/);
  assert.match(metadata, /static usage[\s\S]{0,600}routeKey\(origin\)/);
  assert.doesNotMatch(transcript.slice(transcript.indexOf('static async usageScope'),
    transcript.indexOf('static async saveRoute')), /UPDATE .*updated_at/);
  assert.doesNotMatch(workspace.slice(workspace.indexOf('static async usageScope'),
    workspace.indexOf('private static async trimMetadata')), /UPDATE .*updated_at/);
});
