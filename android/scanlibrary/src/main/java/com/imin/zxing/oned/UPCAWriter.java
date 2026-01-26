/*
 * Copyright 2010 ZXing authors
 *

 */

package com.imin.zxing.oned;

import com.imin.zxing.BarcodeFormat;
import com.imin.zxing.EncodeHintType;
import com.imin.zxing.Writer;
import com.imin.zxing.common.BitMatrix;

import java.util.Map;

/**
 * This object renders a UPC-A code as a {@link BitMatrix}.
 *
 * @author qwandor@google.com (Andrew Walbran)
 */
public final class UPCAWriter implements Writer {

  private final EAN13Writer subWriter = new EAN13Writer();

  @Override
  public BitMatrix encode(String contents, BarcodeFormat format, int width, int height) {
    return encode(contents, format, width, height, null);
  }

  @Override
  public BitMatrix encode(String contents,
                          BarcodeFormat format,
                          int width,
                          int height,
                          Map<EncodeHintType,?> hints) {
    if (format != BarcodeFormat.UPC_A) {
      throw new IllegalArgumentException("Can only encode UPC-A, but got " + format);
    }
    // Transform a UPC-A code into the equivalent EAN-13 code and write it that way
    return subWriter.encode('0' + contents, BarcodeFormat.EAN_13, width, height, hints);
  }

}
