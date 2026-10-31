import { common } from '@kit.AbilityKit';
import { NativeAttachmentCache } from './NativeAttachmentCache';
import { NativeMetadataCache } from './NativeMetadataCache';
import { NativeTranscriptCache } from './NativeTranscriptCache';
import { NativeWorkspaceCache, NativeWorkspaceCacheUsage } from './NativeWorkspaceCache';

export class NativeStorageUsage {
  conversation: number = 0;
  fileBrowser: number = 0;
  fileContent: number = 0;
  imageAttachments: number = 0;
  navigation: number = 0;
  total: number = 0;
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
    return usage;
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
