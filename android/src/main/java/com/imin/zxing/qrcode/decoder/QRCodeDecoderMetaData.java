/*
 * Copyright 2013 ZXing authors
 *

 */

package com.imin.zxing.qrcode.decoder;

import com.imin.zxing.ResultPoint;

/**
 * Meta-data container for QR Code decoding. Instances of this class may be used to convey information back to the
 * decoding caller. Callers are expected to process this.
 *
 * @see com.imin.zxing.common.DecoderResult#getOther()
 */
public final class QRCodeDecoderMetaData {

  private final boolean mirrored;

  QRCodeDecoderMetaData(boolean mirrored) {
    this.mirrored = mirrored;
  }

  /**
   * @return true if the QR Code was mirrored.
   */
  public boolean isMirrored() {
    return mirrored;
  }

  /**
   * Apply the result points' order correction due to mirroring.
   *
   * @param points Array of points to apply mirror correction to.
   */
  public void applyMirroredCorrection(ResultPoint[] points) {
    if (!mirrored || points == null || points.length < 3) {
      return;
    }
    ResultPoint bottomLeft = points[0];
    points[0] = points[2];
    points[2] = bottomLeft;
    // No need to 'fix' top-left and alignment pattern.
  }

}
