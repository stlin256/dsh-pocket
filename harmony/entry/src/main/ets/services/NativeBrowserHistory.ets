export class NativeBrowserHistoryEntry {
  kind: string = 'directory';
  path: string = '';

  constructor(kind: string = 'directory', path: string = '') {
    this.kind = kind;
    this.path = path;
  }
}

/** Compact browser navigation state. Payloads and listings stay in bounded caches. */
export class NativeBrowserHistory {
  private entries: NativeBrowserHistoryEntry[] = [];

  push(kind: string, path: string): void {
    if (kind !== 'directory' && kind !== 'file') return;
    const previous = this.peek();
    if (previous && previous.kind === kind && previous.path === path) return;
    this.entries.push(new NativeBrowserHistoryEntry(kind, path));
  }

  pop(): NativeBrowserHistoryEntry | null {
    return this.entries.pop() || null;
  }

  peek(): NativeBrowserHistoryEntry | null {
    return this.entries.length ? this.entries[this.entries.length - 1] : null;
  }

  size(): number {
    return this.entries.length;
  }

  clear(): void {
    this.entries = [];
  }
}
