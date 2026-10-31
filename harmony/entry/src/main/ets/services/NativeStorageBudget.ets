export const NATIVE_DEFAULT_CACHE_LIMIT_BYTES: number = 5 * 1024 * 1024 * 1024;

export enum NativeStorageOwner {
  transcript = 'transcript',
  workspaceDirectory = 'workspace-directory',
  workspaceText = 'workspace-text',
  workspaceBinary = 'workspace-binary',
  attachment = 'attachment',
  navigation = 'navigation'
}

/** Compact cache metadata; it never contains transcript text or file bytes. */
export class NativeStorageCandidate {
  owner: string = '';
  scopeId: string = '';
  sessionId: string = '';
  key: string = '';
  bytes: number = 0;
  updatedAt: number = 0;
  protectedEntry: boolean = false;

  constructor(owner: string = '', scopeId: string = '', sessionId: string = '',
    key: string = '', bytes: number = 0, updatedAt: number = 0) {
    this.owner = owner;
    this.scopeId = scopeId;
    this.sessionId = sessionId;
    this.key = key;
    this.bytes = bytes;
    this.updatedAt = updatedAt;
  }
}

function validCandidate(value: NativeStorageCandidate): boolean {
  return !!value && !!value.owner && !!value.scopeId && !!value.key &&
    Number.isFinite(value.bytes) && value.bytes > 0 &&
    Number.isFinite(value.updatedAt);
}

function candidateKey(value: NativeStorageCandidate): string {
  return value.owner + '\n' + value.scopeId + '\n' + value.sessionId + '\n' + value.key;
}

function candidateOrder(left: NativeStorageCandidate, right: NativeStorageCandidate): number {
  if (left.updatedAt !== right.updatedAt) return left.updatedAt - right.updatedAt;
  const leftKey = candidateKey(left);
  const rightKey = candidateKey(right);
  return leftKey < rightKey ? -1 : leftKey > rightKey ? 1 : 0;
}

/**
 * Returns the minimum LRU eviction list needed to reach the hard cache limit.
 * Unprotected entries are preferred. Protected entries are admitted only when
 * removing every unprotected candidate still leaves the pool over budget.
 */
export function nativeStorageEvictionPlan(candidates: NativeStorageCandidate[],
  limit: number = NATIVE_DEFAULT_CACHE_LIMIT_BYTES): NativeStorageCandidate[] {
  const safeLimit = Number.isFinite(limit) && limit >= 0 ?
    Math.floor(limit) : NATIVE_DEFAULT_CACHE_LIMIT_BYTES;
  const valid = candidates.filter((value: NativeStorageCandidate): boolean =>
    validCandidate(value));
  let total = 0;
  valid.forEach((value: NativeStorageCandidate): void => {
    total = Math.min(Number.MAX_SAFE_INTEGER, total + Math.min(Number.MAX_SAFE_INTEGER, value.bytes));
  });
  if (total <= safeLimit) return [];
  const ordered = valid.slice().sort(candidateOrder);
  const plan: NativeStorageCandidate[] = [];
  for (const value of ordered) {
    if (total <= safeLimit) break;
    if (value.protectedEntry) continue;
    plan.push(value);
    total -= value.bytes;
  }
  if (total <= safeLimit) return plan;
  for (const value of ordered) {
    if (total <= safeLimit) break;
    if (!value.protectedEntry || plan.includes(value)) continue;
    plan.push(value);
    total -= value.bytes;
  }
  return plan;
}
