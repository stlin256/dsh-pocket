import { NativeExperience } from '../services/NativeExperience';
import { NativeMotion } from '../services/NativeMotion';

/**
 * Shared bottom conversation layout. Extra dock content enables a conditionally
 * masked blur; the composer keeps its own local surface.
 */
@Component
export struct NativeBottomConversationDock {
  @BuilderParam content: () => void;
  @StorageLink('nativeSafeBottom') private safeBottom: number = 0;
  @Prop horizontalBleed: number = 0;
  @Prop contentInset: number = 12;
  @Prop elevated: boolean = false;
  @State private measuredHeight: number = 0;
  onHeight: (height: number) => void = (_height: number): void => {};

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.elevated && NativeExperience.materialsEnabled()) {
        Column()
          // A percentage-sized child makes this unconstrained Stack expand to
          // the remaining page height. Follow the natural content measurement
          // so the composer keeps ownership of its intrinsic bottom height.
          .width('100%').height(this.measuredHeight)
          .backgroundBlurStyle(BlurStyle.Thin)
          .linearGradientBlur(18, {
            fractionStops: [[0, 0], [0.28, 0.12], [1, 1]],
            direction: GradientDirection.Bottom
          })
          .opacity(0.82)
          .transition(NativeMotion.rowTransition())
          .animation(NativeMotion.disclosureParam())
      }
      Column() {
        this.content()
      }.width('100%').margin({ left: -this.horizontalBleed, right: -this.horizontalBleed })
        .padding({ left: this.horizontalBleed + this.contentInset, right: this.horizontalBleed + this.contentInset,
          top: 8, bottom: Math.ceil(this.safeBottom * 1.2) + 8 })
    }.width('100%').onAreaChange((_old: Area, area: Area): void => {
      const height = Number(area.height);
      if (height <= 0 || height === this.measuredHeight) return;
      this.measuredHeight = height;
      this.onHeight(height);
    })
  }
}
