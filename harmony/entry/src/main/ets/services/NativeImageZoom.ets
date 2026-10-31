export class NativeImageZoomTarget {
  zoom: number = 1;
  offsetX: number = 0;
  offsetY: number = 0;
}

/** Pure math shared by full-screen image surfaces. Coordinates use viewport vp. */
export class NativeImageZoom {
  static readonly DEFAULT_SCALE: number = 1;
  static readonly DOUBLE_TAP_SCALE: number = 2.5;

  static collapsed(): NativeImageZoomTarget {
    return new NativeImageZoomTarget();
  }

  static doubleTap(currentZoom: number, tapX: number, tapY: number,
    viewportWidth: number, viewportHeight: number,
    sourceWidth: number, sourceHeight: number,
    currentOffsetX: number = 0, currentOffsetY: number = 0): NativeImageZoomTarget {
    if (currentZoom > NativeImageZoom.DEFAULT_SCALE + 0.001) {
      return NativeImageZoom.collapsed();
    }
    const target = new NativeImageZoomTarget();
    target.zoom = NativeImageZoom.DOUBLE_TAP_SCALE;
    const width = Math.max(1, viewportWidth);
    const height = Math.max(1, viewportHeight);
    const sourceW = Math.max(1, sourceWidth);
    const sourceH = Math.max(1, sourceHeight);
    const fit = Math.min(width / sourceW, height / sourceH);
    const ratio = target.zoom / Math.max(0.001, currentZoom);
    const focusX = tapX - width / 2;
    const focusY = tapY - height / 2;
    target.offsetX = focusX - (focusX - currentOffsetX) * ratio;
    target.offsetY = focusY - (focusY - currentOffsetY) * ratio;
    const limitX = Math.max(0, (sourceW * fit * target.zoom - width) / 2);
    const limitY = Math.max(0, (sourceH * fit * target.zoom - height) / 2);
    target.offsetX = Math.max(-limitX, Math.min(limitX, target.offsetX));
    target.offsetY = Math.max(-limitY, Math.min(limitY, target.offsetY));
    return target;
  }
}
