import { common } from '@kit.AbilityKit';
import { NativeAttachmentCache } from './NativeAttachmentCache';
import { NativeMetadataCache } from './NativeMetadataCache';
import { NativeTranscriptCache } from './NativeTranscriptCache';
import {
  NativeWorkspaceCache,
  NativeWorkspaceCacheUsage,
  nativeWorkspaceScopeId
} from './NativeWorkspaceCache';
import {
  NATIVE_DEFAULT_CACHE_LIMIT_BYTES,
  NativeStorageCandidate,
  nativeStorageEvictionPlan,
  NativeStorageOwner
} from './NativeStorageBudget';

export class NativeStorageUsage {
  conversation: number = 0;
  fileBrowser: number = 0;
  fileContent: number = 0;
  imageAttachments: number = 0;
  navigation: number = 0;
  total: number = 0;
  poolTotal: number = 0;
  limit: number = NATIVE_DEFAULT_CACHE_LIMIT_BYTES;
}

function normalizedBytes(value: number): number {
  if (!Number.isFinite(value) || value <= 0) return 0;
  return Math.min(Number.MAX_SAFE_INTEGER, Math.floor(value));
}

export function nativeFormatStorageBytes(value: number): string {
  let bytes = normalizedBytes(value);
  if (bytes < 1024) return bytes.toString() + ' B';
  const units: string[] = ['KiB', 'MiB', 'GiB', 'TiB'];
  let unit = -1;
  while (bytes >= 1024 && unit < units.length - 1) {
    bytes = bytes / 1024;
    unit++;
  }
  const digits = bytes >= 100 ? 0 : bytes >= 10 ? 1 : 2;
  const formatted = bytes.toFixed(digits).replace(/\.0+$/, '').replace(/(\.\d*[1-9])0+$/, '$1');
  return formatted + ' ' + units[Math.max(0, unit)];
}

/** Aggregates and clears only app-private cache for one authenticated scope. */
export class NativeStorageManager {
  private static lastGlobalCheckAt: number = 0;
  private static globalCheckIntervalMs: number = 5000;

  static async usageScope(context: common.UIAbilityContext,
    scope: string): Promise<NativeStorageUsage> {
    const conversation = await NativeTranscriptCache.usageScope(context, scope);
    const workspace: NativeWorkspaceCacheUsage = await NativeWorkspaceCache.usageScope(context, scope);
    const attachments = await NativeAttachmentCache.usageScope(context, scope);
    const navigation = NativeMetadataCache.usage(context, scope);
    const usage = new NativeStorageUsage();
    usage.conversation = normalizedBytes(conversation);
    usage.fileBrowser = normalizedBytes(workspace.directory);
    usage.fileContent = normalizedBytes(workspace.text + workspace.binary);
    usage.imageAttachments = normalizedBytes(attachments);
    usage.navigation = normalizedBytes(navigation);
    usage.total = normalizedBytes(usage.conversation + usage.fileBrowser +
      usage.fileContent + usage.imageAttachments + usage.navigation);
    const candidates = await NativeStorageManager.storageCandidates(context);
    usage.poolTotal = NativeStorageManager.candidateBytes(candidates);
    usage.limit = NATIVE_DEFAULT_CACHE_LIMIT_BYTES;
    return usage;
  }

  private static candidateBytes(candidates: NativeStorageCandidate[]): number {
    let total = 0;
    candidates.forEach((candidate: NativeStorageCandidate): void => {
      if (Number.isFinite(candidate.bytes) && candidate.bytes > 0) {
        total = Math.min(Number.MAX_SAFE_INTEGER, total + candidate.bytes);
      }
    });
    return normalizedBytes(total);
  }

  private static async storageCandidates(
    context: common.UIAbilityContext): Promise<NativeStorageCandidate[]> {
    const transcript = await NativeTranscriptCache.storageCandidates(context);
    const workspace = await NativeWorkspaceCache.storageCandidates(context);
    const attachments = await NativeAttachmentCache.storageCandidates(context);
    const navigation = NativeMetadataCache.storageCandidates(context);
    return transcript.concat(workspace).concat(attachments).concat(navigation);
  }

  private static protectCandidates(candidates: NativeStorageCandidate[], scope: string,
    activeSessionId: string, protectedSessionIds: string[]): void {
    const protectedSessions: Set<string> = new Set<string>(protectedSessionIds);
    if (activeSessionId) protectedSessions.add(activeSessionId);
    const transcriptScope = NativeTranscriptCache.scopeId(scope);
    const workspaceScope = nativeWorkspaceScopeId(scope);
    const attachmentScope = NativeAttachmentCache.scopeId(scope);
    const navigationScope = NativeMetadataCache.scopeId(scope);
    candidates.forEach((candidate: NativeStorageCandidate): void => {
      if (candidate.owner === NativeStorageOwner.transcript) {
        candidate.protectedEntry = candidate.scopeId === transcriptScope &&
          protectedSessions.has(candidate.sessionId);
      } else if (candidate.owner === NativeStorageOwner.workspaceDirectory ||
        candidate.owner === NativeStorageOwner.workspaceText ||
        candidate.owner === NativeStorageOwner.workspaceBinary) {
        candidate.protectedEntry = candidate.scopeId === workspaceScope &&
          protectedSessions.has(candidate.sessionId);
      } else if (candidate.owner === NativeStorageOwner.attachment) {
        candidate.protectedEntry = candidate.scopeId === attachmentScope;
      } else if (candidate.owner === NativeStorageOwner.navigation) {
        candidate.protectedEntry = candidate.scopeId === navigationScope;
      }
    });
  }

  private static async evict(context: common.UIAbilityContext,
    candidate: NativeStorageCandidate): Promise<void> {
    if (candidate.owner === NativeStorageOwner.transcript) {
      await NativeTranscriptCache.evictStorageCandidate(context, candidate);
    } else if (candidate.owner === NativeStorageOwner.workspaceDirectory ||
      candidate.owner === NativeStorageOwner.workspaceText ||
      candidate.owner === NativeStorageOwner.workspaceBinary) {
      await NativeWorkspaceCache.evictStorageCandidate(context, candidate);
    } else if (candidate.owner === NativeStorageOwner.attachment) {
      await NativeAttachmentCache.evictStorageCandidate(context, candidate);
    } else if (candidate.owner === NativeStorageOwner.navigation) {
      NativeMetadataCache.evictStorageCandidate(context, candidate);
    }
  }

  /**
   * Enforces the shared app-private cache limit. Checks are throttled because
   * streaming transcript snapshots may request enforcement several times a
   * second; storage management can force a check after explicit user actions.
   */
  static async enforceDefaultLimit(context: common.UIAbilityContext, scope: string,
    activeSessionId: string = '', protectedSessionIds: string[] = [],
    force: boolean = false): Promise<number> {
    const now = Date.now();
    if (!force && now - NativeStorageManager.lastGlobalCheckAt <
      NativeStorageManager.globalCheckIntervalMs) return -1;
    NativeStorageManager.lastGlobalCheckAt = now;
    const candidates = await NativeStorageManager.storageCandidates(context);
    const before = NativeStorageManager.candidateBytes(candidates);
    if (before <= NATIVE_DEFAULT_CACHE_LIMIT_BYTES) return before;
    NativeStorageManager.protectCandidates(candidates, scope, activeSessionId, protectedSessionIds);
    const plan = nativeStorageEvictionPlan(candidates, NATIVE_DEFAULT_CACHE_LIMIT_BYTES);
    let after = before;
    for (const candidate of plan) {
      try {
        await NativeStorageManager.evict(context, candidate);
        after -= candidate.bytes;
      } catch (_) {}
    }
    return normalizedBytes(Math.max(0, after));
  }

  static async clearScope(context: common.UIAbilityContext, scope: string): Promise<void> {
    let failed = false;
    NativeMetadataCache.clear(context, scope);
    try {
      await NativeTranscriptCache.clearScope(context, scope);
    } catch (_) {
      failed = true;
    }
    try {
      await NativeWorkspaceCache.clearScope(context, scope);
    } catch (_) {
      failed = true;
    }
    try {
      await NativeAttachmentCache.clearScope(context, scope);
    } catch (_) {
      failed = true;
    }
    if (failed) throw new Error('Cache clear failed');
  }
}
