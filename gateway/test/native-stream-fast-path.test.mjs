import { test } from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import vm from 'node:vm';
import ts from 'typescript';

const services = new URL('../../harmony/entry/src/main/ets/services/', import.meta.url);

function load(name, kits = {}) {
  const source = readFileSync(new URL(name + '.ets', services), 'utf8');
  const output = ts.transpileModule(source, {
    compilerOptions: {
      target: ts.ScriptTarget.ES2022,
      module: ts.ModuleKind.CommonJS
    }
  });
  const module = { exports: {} };
  vm.runInNewContext(output.outputText, {
    module,
    exports: module.exports,
    require: id => {
      if (!(id in kits) && id.startsWith('./') &&
          existsSync(new URL(id.slice(2) + '.ets', services))) {
        return load(id.slice(2), kits);
      }
      if (!(id in kits)) throw Error('Unexpected dependency: ' + id);
      return kits[id];
    }
  });
  return module.exports;
}

function transcriptModule() {
  const models = load('NativeSessionModel');
  return load('NativeTranscript', {
    './NativeSessionModel': models,
    './NativeHostSettings': {},
    './NativePlan': {
      nativePlanDiff: () => '',
      nativePlanDocument: () => ({ parsed: false, items: [] }),
      nativePlanProgress: () => ''
    }
  });
}

test('tail-only list publication skips render-key reconstruction', () => {
  const { NativeListSource } = load('NativeListSource');
  const source = new NativeListSource();
  const events = [];
  source.registerDataChangeListener({
    onDataChange: index => events.push('change:' + index),
    onDataReloaded: () => events.push('reload'),
    onDataAdded: index => events.push('add:' + index),
    onDataDeleted: index => events.push('delete:' + index),
    onDataMoved: (from, to) => events.push('move:' + from + ':' + to)
  });
  source.set([{ id: 'stable', text: 'old' }, { id: 'live', text: 'a' }],
    row => row.id);
  events.length = 0;
  source.setTail([{ id: 'stable', text: 'old' }, { id: 'live', text: 'ab' }]);
  assert.deepEqual(events, ['change:1']);
  assert.equal(source.getData(1).text, 'ab');

  events.length = 0;
  source.setTail([{ id: 'live', text: 'ab' }]);
  assert.ok(events.includes('reload'));
});

test('live text patching is limited to the final assistant row', () => {
  const models = load('NativeSessionModel');
  const { nativeUpdateLiveAssistant } = transcriptModule();
  const live = Object.assign(new models.NativeMessage(), {
    id: 'live-assistant',
    role: 'assistant',
    text: 'old'
  });
  const patched = nativeUpdateLiveAssistant([
    Object.assign(new models.NativeMessage(), { id: 'message', role: 'user', text: 'prompt' }),
    live
  ], 'new');
  assert.equal(patched.at(-1).text, 'new');
  assert.equal(live.text, 'old');

  const stale = nativeUpdateLiveAssistant([
    live,
    Object.assign(new models.NativeMessage(), { id: 'tool-result', role: 'tool', toolName: 'read' })
  ], 'new');
  assert.equal(stale, null, 'a live row before a newer structural row must not take the tail path');
});

test('native workspace invalidates text-only patching on structural or tool frames', () => {
  const workspace = readFileSync(new URL(
    '../../harmony/entry/src/main/ets/components/NativeWorkspace.ets',
    import.meta.url), 'utf8');
  assert.match(workspace,
    /if \(frame\.type === 'delta'\) \{[\s\S]{0,260}this\.streamTextPatchDirty =/);
  assert.match(workspace,
    /this\.streamTextPatchDirty = frame\.text\.length > 0[\s\S]{0,220}!\(frame\.toolUpdates \|\| \[\]\)\.length/);
  assert.match(workspace,
    /if \(tailOnlyTextUpdate\)[\s\S]{0,180}this\.source\.setTail\(visible, 2\)[\s\S]{0,180}this\.source\.set\(visible/);
});
