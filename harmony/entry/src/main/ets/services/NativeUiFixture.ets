export class NativeUiFixture {
  static readonly screens: string[] = ['conversation', 'process', 'sidebar', 'browser', 'settings'];
  static readonly states: string[] = [
    'completed', 'live-change', 'attachments', 'streaming', 'empty', 'long-history'
  ];
  static readonly themes: string[] = ['light', 'dark', 'system'];

  static screen(value: Object | undefined): string {
    return typeof value === 'string' && NativeUiFixture.screens.includes(value) ? value : 'conversation';
  }

  static state(value: Object | undefined): string {
    return typeof value === 'string' && NativeUiFixture.states.includes(value) ? value : 'completed';
  }

  static theme(value: Object | undefined): string {
    return typeof value === 'string' && NativeUiFixture.themes.includes(value) ? value : 'system';
  }
}
