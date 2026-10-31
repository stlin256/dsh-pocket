import { NativeMessage } from './NativeSessionModel';
import { NativeDiffDocument, NativeDiffRow, nativeDiff } from './NativeDiff';

export class NativeTurnFileChange {
  path: string = '';
  added: number = 0;
  removed: number = 0;
}

export class NativeTurnChangeSummary {
  turnKey: string = '';
  files: NativeTurnFileChange[] = [];
  fileCount: number = 0;
  added: number = 0;
  removed: number = 0;
  running: boolean = true;
  outcome: string = '';
}

function mutationTool(tool: NativeMessage): boolean {
  return tool.toolName === 'write' || tool.toolName === 'edit' || tool.toolName === 'apply_patch';
}

function settledSuccess(tool: NativeMessage): boolean {
  if (tool.phase !== 'result' && tool.status !== 'success') return false;
  if (tool.failed || tool.status === 'error' || tool.status === 'interrupted') return false;
  if (tool.outcome === 'failed' || tool.outcome === 'error' ||
      tool.outcome === 'interrupted' || tool.outcome === 'cancelled') return false;
  return !tool.output.includes('AUTO_REVIEW_DENIED');
}

function normalizedPath(path: string): string {
  return path.replace(/\\/g, '/').replace(/\/+/g, '/');
}

function documentFiles(document: NativeDiffDocument): NativeTurnFileChange[] {
  const files: NativeTurnFileChange[] = [];
  const indexes: Map<string, number> = new Map<string, number>();
  let current = document.path || '';
  const addCount = (path: string, added: number, removed: number): void => {
    const display = path.trim();
    const key = normalizedPath(display);
    if (!key) return;
    let index = indexes.get(key);
    if (index === undefined) {
      const file = new NativeTurnFileChange();
      file.path = display;
      file.added = added;
      file.removed = removed;
      indexes.set(key, files.length);
      files.push(file);
      return;
    }
    files[index].added += added;
    files[index].removed += removed;
  };
  document.rows.forEach((row: NativeDiffRow): void => {
    if (row.kind === 'path') {
      current = row.text;
      return;
    }
    if (row.kind === 'add') addCount(current, 1, 0);
    else if (row.kind === 'del') addCount(current, 0, 1);
  });
  return files;
}

function addSummaryFile(summary: NativeTurnChangeSummary, key: string,
  incoming: NativeTurnFileChange): void {
  let index = -1;
  for (let cursor = 0; cursor < summary.files.length; cursor++) {
    if (normalizedPath(summary.files[cursor].path) === key) {
      index = cursor;
      break;
    }
  }
  if (index < 0) {
    const file = new NativeTurnFileChange();
    file.path = incoming.path;
    file.added = incoming.added;
    file.removed = incoming.removed;
    summary.files.push(file);
  } else {
    summary.files[index].added += incoming.added;
    summary.files[index].removed += incoming.removed;
  }
  summary.fileCount = summary.files.length;
  summary.added = summary.files.reduce((total: number, file: NativeTurnFileChange): number =>
    total + file.added, 0);
  summary.removed = summary.files.reduce((total: number, file: NativeTurnFileChange): number =>
    total + file.removed, 0);
}

function visitTool(summaries: Map<string, NativeTurnChangeSummary>,
  calls: Map<string, Set<string>>, tool: NativeMessage): void {
  if (tool.role !== 'tool' || !mutationTool(tool) || !settledSuccess(tool)) return;
  const callKey = tool.callId || tool.id || tool.renderKey;
  if (callKey) {
    let seen = calls.get(tool.turnKey);
    if (!seen) {
      seen = new Set<string>();
      calls.set(tool.turnKey, seen);
    }
    if (seen.has(callKey)) return;
    seen.add(callKey);
  }
  const files = documentFiles(nativeDiff(tool));
  if (!files.length) return;
  let summary = summaries.get(tool.turnKey);
  if (!summary) {
    summary = new NativeTurnChangeSummary();
    summary.turnKey = tool.turnKey;
    summaries.set(tool.turnKey, summary);
  }
  files.forEach((file: NativeTurnFileChange): void => {
    addSummaryFile(summary as NativeTurnChangeSummary, normalizedPath(file.path), file);
  });
}

function visit(rows: NativeMessage[], summaries: Map<string, NativeTurnChangeSummary>,
  calls: Map<string, Set<string>>): void {
  rows.forEach((row: NativeMessage): void => {
    if (row.role === 'process') {
      visit(row.children || [], summaries, calls);
      return;
    }
    if (row.role === 'turn-footer') {
      const summary = summaries.get(row.turnKey);
      if (summary) {
        summary.running = false;
        summary.outcome = row.footerOutcome || row.outcome || '';
      }
      return;
    }
    visitTool(summaries, calls, row);
  });
}

/**
 * Aggregate successful explicit edit/write diffs into stable per-turn file
 * summaries. This is a view projection; it never mutates journal rows.
 */
export function nativeTurnChanges(rows: NativeMessage[]): NativeTurnChangeSummary[] {
  const summaries: Map<string, NativeTurnChangeSummary> =
    new Map<string, NativeTurnChangeSummary>();
  visit(rows || [], summaries, new Map<string, Set<string>>());
  const result: NativeTurnChangeSummary[] = [];
  summaries.forEach((summary: NativeTurnChangeSummary): void => {
    if (summary.files.length) result.push(summary);
  });
  return result;
}

export function nativeLiveTurnChange(rows: NativeMessage[],
  active: boolean): NativeTurnChangeSummary | null {
  if (!active) return null;
  const summaries = nativeTurnChanges(rows);
  for (let index = summaries.length - 1; index >= 0; index--) {
    if (summaries[index].running) return summaries[index];
  }
  return null;
}

export function nativeTurnChangeFor(rows: NativeTurnChangeSummary[],
  turnKey: string): NativeTurnChangeSummary | null {
  const found = rows.find((summary: NativeTurnChangeSummary): boolean =>
    summary.turnKey === turnKey);
  return found || null;
}
