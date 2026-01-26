/*
 * Copyright 2008 ZXing authors
 *

 */

package com.imin.zxing;

import com.imin.zxing.common.BitMatrix;

import java.util.Map;

/**
 * The base class for all objects which encode/generate a barcode image.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 */
public interface Writer {

  /**
   * Encode a barcode using the default settings.
   *
   * @param contents The contents to encode in the barcode
   * @param format The barcode format to generate
   * @param width The preferred width in pixels
   * @param height The preferred height in pixels
   * @return {@link BitMatrix} representing encoded barcode image
   * @throws WriterException if contents cannot be encoded legally in a format
   */
  BitMatrix encode(String contents, BarcodeFormat format, int width, int height)
      throws WriterException;

  /**
   * @param contents The contents to encode in the barcode
   * @param format The barcode format to generate
   * @param width The preferred width in pixels
   * @param height The preferred height in pixels
   * @param hints Additional parameters to supply to the encoder
   * @return {@link BitMatrix} representing encoded barcode image
   * @throws WriterException if contents cannot be encoded legally in a format
   */
  BitMatrix encode(String contents,
                   BarcodeFormat format,
                   int width,
                   int height,
                   Map<EncodeHintType, ?> hints)
      throws WriterException;

}
