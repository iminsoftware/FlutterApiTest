/*
 * Copyright 2009 ZXing authors
 *

 */

package com.imin.zxing.multi;

import com.imin.scan.Result;
import com.imin.zxing.BinaryBitmap;
import com.imin.zxing.ChecksumException;
import com.imin.zxing.DecodeHintType;
import com.imin.zxing.FormatException;
import com.imin.zxing.NotFoundException;
import com.imin.zxing.Reader;
import com.imin.zxing.ResultPoint;

import java.util.Map;

/**
 * This class attempts to decode a barcode from an image, not by scanning the whole image,
 * but by scanning subsets of the image. This is important when there may be multiple barcodes in
 * an image, and detecting a barcode may find parts of multiple barcode and fail to decode
 * (e.g. QR Codes). Instead this scans the four quadrants of the image -- and also the center
 * 'quadrant' to cover the case where a barcode is found in the center.
 *
 * @see GenericMultipleBarcodeReader
 */
public final class ByQuadrantReader implements Reader {

  private final Reader delegate;

  public ByQuadrantReader(Reader delegate) {
    this.delegate = delegate;
  }

  @Override
  public Result decode(BinaryBitmap image)
      throws NotFoundException, ChecksumException, FormatException {
    return decode(image, null);
  }

  @Override
  public Result decode(BinaryBitmap image, Map<DecodeHintType,?> hints)
      throws NotFoundException, ChecksumException, FormatException {

    int width = image.getWidth();
    int height = image.getHeight();
    int halfWidth = width / 2;
    int halfHeight = height / 2;

    try {
      // No need to call makeAbsolute as results will be relative to original top left here
      return delegate.decode(image.crop(0, 0, halfWidth, halfHeight), hints);
    } catch (NotFoundException re) {
      // continue
    }

    try {
      Result result = delegate.decode(image.crop(halfWidth, 0, halfWidth, halfHeight), hints);
      makeAbsolute(result.getResultPoints(), halfWidth, 0);
      return result;
    } catch (NotFoundException re) {
      // continue
    }

    try {
      Result result = delegate.decode(image.crop(0, halfHeight, halfWidth, halfHeight), hints);
      makeAbsolute(result.getResultPoints(), 0, halfHeight);
      return result;
    } catch (NotFoundException re) {
      // continue
    }

    try {
      Result result = delegate.decode(image.crop(halfWidth, halfHeight, halfWidth, halfHeight), hints);
      makeAbsolute(result.getResultPoints(), halfWidth, halfHeight);
      return result;
    } catch (NotFoundException re) {
      // continue
    }

    int quarterWidth = halfWidth / 2;
    int quarterHeight = halfHeight / 2;
    BinaryBitmap center = image.crop(quarterWidth, quarterHeight, halfWidth, halfHeight);
    Result result = delegate.decode(center, hints);
    makeAbsolute(result.getResultPoints(), quarterWidth, quarterHeight);
    return result;
  }

  @Override
  public void reset() {
    delegate.reset();
  }

  private static void makeAbsolute(ResultPoint[] points, int leftOffset, int topOffset) {
    if (points != null) {
      for (int i = 0; i < points.length; i++) {
        ResultPoint relative = points[i];
        if (relative != null) {
          points[i] = new ResultPoint(relative.getX() + leftOffset, relative.getY() + topOffset);
        }    
      }
    }
  }

}
