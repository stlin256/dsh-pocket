import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { webview } from '@kit.ArkWeb';
import { NativeFileTransfer } from '../services/NativeFileTransfer';
import { NativeHarnessClient } from '../services/NativeHarnessClient';
import { NativeFileViewRequest } from '../services/NativeSessionModel';
import {
  NativeHtmlAssetReference,
  nativeHtmlInline,
  nativeHtmlMimeType,
  nativeHtmlReferences,
  nativeHtmlInlineCss
} from '../services/NativeHtmlDocument';
import { NativeMotion } from '../services/NativeMotion';

const htmlAssetLimit: number = 32 * 1024 * 1024;
const htmlAssetCountLimit: number = 32;
const htmlTextAssetLimit: number = 8 * 1024 * 1024;

@Component
export struct NativeHtmlPreview {
  client: NativeHarnessClient = new NativeHarnessClient('');
  sessionId: string = '';
  @Prop @Watch('sourceChanged') source: string = '';
  @Prop path: string = '';
  @StorageLink('nativeDark') private dark: boolean = false;
  @State private prepared: string = '';
  @State private loading: boolean = true;
  @State private error: string = '';
  private controller: webview.WebviewController = new webview.WebviewController();
  private mounted: boolean = false;
  private controllerReady: boolean = false;
  private loadRevision: number = 0;
  private loadedRevision: number = -1;

  aboutToAppear(): void {
    this.mounted = true;
    this.prepare();
  }
  aboutToDisappear(): void {
    this.mounted = false;
    this.loadRevision++;
  }
  private sourceChanged(): void {
    if (this.mounted) this.prepare();
  }
  private base64(bytes: Uint8Array): string {
    return new util.Base64Helper().encodeToStringSync(bytes);
  }
  private text(bytes: Uint8Array): string {
    return util.TextDecoder.create('utf-8').decodeToString(bytes);
  }
  private dataUrl(path: string, bytes: Uint8Array): string {
    return 'data:' + nativeHtmlMimeType(path) + ';base64,' + this.base64(bytes);
  }
  private async prepare(): Promise<void> {
    const revision = ++this.loadRevision;
    this.loading = true;
    this.error = '';
    this.prepared = '';
    const assets: Map<string, string> = new Map<string, string>();
    const css: Map<string, string> = new Map<string, string>();
    const queue: NativeHtmlAssetReference[] = nativeHtmlReferences(this.source, this.path);
    const visited: Set<string> = new Set<string>();
    let count: number = 0;
    let bytes: number = 0;
    try {
      while (queue.length && count < htmlAssetCountLimit && bytes < htmlAssetLimit) {
        const item = queue.shift() as NativeHtmlAssetReference;
        const key = item.kind + '\n' + item.path;
        if (!item.path || visited.has(key)) continue;
        visited.add(key);
        count++;
        try {
          const limit = Math.max(1, Math.min(item.kind === 'binary' ? htmlTextAssetLimit : htmlTextAssetLimit,
            htmlAssetLimit - bytes));
          const content = await NativeFileTransfer.readComplete(
            this.client, this.sessionId, item.path, limit);
          if (!this.mounted || revision !== this.loadRevision) return;
          bytes += content.bytes.byteLength;
          if (item.kind === 'style' || item.kind === 'binary' &&
            nativeHtmlMimeType(item.path) === 'text/css') {
            const value = this.text(content.bytes);
            css.set(item.path, value);
            queue.push(...nativeHtmlReferences('<style>' + value + '</style>', item.path));
          } else if (item.kind === 'script') {
            assets.set(item.path, this.dataUrl(item.path, content.bytes));
          } else {
            assets.set(item.path, this.dataUrl(item.path, content.bytes));
          }
        } catch (_) {
          assets.set(item.path, '');
        }
      }
      css.forEach((value: string, path: string): void => {
        assets.set(path, nativeHtmlInlineCss(value, path, assets));
      });
      const html = nativeHtmlInline(this.source, this.path, assets);
      if (!this.mounted || revision !== this.loadRevision) return;
      this.prepared = html;
      this.loading = false;
      this.loadPrepared();
    } catch (_) {
      if (this.mounted && revision === this.loadRevision) {
        this.error = '无法预览此网页';
        this.loading = false;
      }
    }
  }
  private loadPrepared(): void {
    if (!this.controllerReady || !this.prepared || this.loadedRevision === this.loadRevision) return;
    try {
      this.controller.loadData(this.prepared, 'text/html', 'UTF-8', 'dshharmony://workspace/');
      this.loadedRevision = this.loadRevision;
    } catch (_) {
      if (this.mounted) this.error = '无法预览此网页';
    }
  }
  private async openLocal(path: string): Promise<void> {
    try {
      const target = await this.client.resolveWorkspaceTarget(this.sessionId, path);
      if (target.kind !== 'file' && target.kind !== 'directory') {
        if (this.mounted) this.getUIContext().getPromptAction().showToast({
          message: '文件或文件夹不可用', duration: 1500
        });
        return;
      }
      const request = new NativeFileViewRequest();
      request.kind = target.kind === 'directory' ? 'browser' : 'file';
      request.sessionId = this.sessionId;
      request.path = target.path;
      request.requestId = util.generateRandomUUID();
      AppStorage.setOrCreate<string>('nativeFileViewPayload', JSON.stringify(request));
      AppStorage.setOrCreate<number>('nativeFileViewRevision',
        (AppStorage.get<number>('nativeFileViewRevision') || 0) + 1);
    } catch (_) {
      if (this.mounted) this.getUIContext().getPromptAction().showToast({
        message: '文件或文件夹不可用', duration: 1500
      });
    }
  }
  private openExternal(url: string): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    context.startAbility({ action: 'ohos.want.action.viewData', uri: url }).catch((): void => {});
  }
  private intercept(url: string): boolean {
    if (url === 'about:blank' || url === 'dshharmony://workspace/') return false;
    if (url.startsWith('dshharmony://file?path=')) {
      const encoded = url.slice('dshharmony://file?path='.length);
      try { this.openLocal(decodeURIComponent(encoded)); } catch (_) {}
      return true;
    }
    if (/^https?:\/\//i.test(url)) {
      this.openExternal(url);
      return true;
    }
    return true;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Web({ src: 'about:blank', controller: this.controller })
        .width('100%').height('100%')
        .javaScriptAccess(true).fileAccess(false).domStorageAccess(false)
        .darkMode(WebDarkMode.Auto).forceDarkAccess(false)
        .backgroundColor(this.dark ? '#151517' : '#FFFFFF')
        .onControllerAttached((): void => {
          this.controllerReady = true;
          this.loadPrepared();
        })
        .onLoadIntercept((event): boolean => this.intercept(event.data.getRequestUrl()))
      if (this.loading) {
        Column({ space: 8 }) {
          LoadingProgress().width(24).height(24).color(this.dark ? '#8AB4FF' : '#3964FE')
          Text('正在读取…').fontSize(12).fontColor(this.dark ? '#93969B' : '#8A8D91')
        }.padding(14).borderRadius(14).backgroundColor(this.dark ? '#E6242527' : '#EEFFFFFF')
          .transition(NativeMotion.rowTransition())
      } else if (this.error) {
        Text(this.error).fontSize(13).fontColor(this.dark ? '#FFB1B1' : '#B3261E')
          .padding(14).borderRadius(14).backgroundColor(this.dark ? '#242527' : '#FFFFFF')
      }
    }.width('100%').height('100%')
  }
}
