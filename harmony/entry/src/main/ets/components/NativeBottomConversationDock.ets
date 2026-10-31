import { NativeExperience } from '../services/NativeExperience';

/**
 * Shared bottom conversation chrome. The backdrop spans the horizontal bleed,
 * while the builder contents keep the caller's content inset.
 */
@Component
export struct NativeBottomConversationDock {
  @BuilderParam content: () => void;
  @StorageLink('nativeDark') private dark: boolean = false;
  @StorageLink('nativeExperienceRevision') private experienceRevision: number = 0;
  @StorageLink('nativeSafeBottom') private safeBottom: number = 0;
  @Prop horizontalBleed: number = 0;
  @Prop contentInset: number = 12;
  @State private measuredHeight: number = 0;
  onHeight: (height: number) => void = (_height: number): void => {};

  private surface(): ResourceColor {
    if (this.dark) return NativeExperience.materialsEnabled() ? '#E61A1B1D' : '#151517';
    return NativeExperience.materialsEnabled() ? '#F2FFFFFF' : '#FFFFFF';
  }

  build() {
    Column() {
      this.content()
    }.width('100%').margin({ left: -this.horizontalBleed, right: -this.horizontalBleed })
      .padding({ left: this.horizontalBleed + this.contentInset, right: this.horizontalBleed + this.contentInset,
        top: 8, bottom: Math.ceil(this.safeBottom * 1.2) + 8 })
      .backgroundColor(this.surface())
      .backgroundBlurStyle(NativeExperience.materialsEnabled() ? BlurStyle.Thin : BlurStyle.NONE)
      .onAreaChange((_old: Area, area: Area): void => {
        const height = Number(area.height);
        if (height <= 0 || height === this.measuredHeight) return;
        this.measuredHeight = height;
        this.onHeight(height);
      })
  }
}
