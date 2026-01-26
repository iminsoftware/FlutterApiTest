/*
 * Copyright 2009 ZXing authors
 *

 */

package com.imin.zxing.multi;

import com.imin.scan.Result;
import com.imin.zxing.BinaryBitmap;
import com.imin.zxing.DecodeHintType;
import com.imin.zxing.NotFoundException;
import com.imin.zxing.Reader;

import java.util.Map;

/**
 * Implementation of this interface attempt to read several barcodes from one image.
 *
 * @see Reader
 * @author Sean Owen
 */
public interface MultipleBarcodeReader {

  Result[] decodeMultiple(BinaryBitmap image) throws NotFoundException;

  Result[] decodeMultiple(BinaryBitmap image,
                          Map<DecodeHintType, ?> hints) throws NotFoundException;

}
