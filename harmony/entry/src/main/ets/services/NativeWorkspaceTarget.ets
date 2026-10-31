/** A confirmed chat-link destination. An empty kind means the target is unavailable. */
export class NativeWorkspaceTarget {
  kind: string = '';
  path: string = '';
}

/**
 * Applies confirmed probe results in deterministic precedence order. A bare-name
 * fallback is consulted only after both exact-path probes have failed.
 */
export function nativeResolvedWorkspaceTarget(path: string, hasFile: boolean,
  hasDirectory: boolean, fallbackPath: string = ''): NativeWorkspaceTarget {
  const result = new NativeWorkspaceTarget();
  if (hasFile) {
    result.kind = 'file';
    result.path = path;
  } else if (hasDirectory) {
    result.kind = 'browser';
    result.path = path;
  } else if (fallbackPath) {
    result.kind = 'file';
    result.path = fallbackPath;
  }
  return result;
}
