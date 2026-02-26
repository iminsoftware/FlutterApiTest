/*
 * Copyright 2008 ZXing authors
 *

 */

package com.imin.zxing.oned;

import com.imin.scan.Result;
import com.imin.zxing.BarcodeFormat;
import com.imin.zxing.BinaryBitmap;
import com.imin.zxing.ChecksumException;
import com.imin.zxing.DecodeHintType;
import com.imin.zxing.FormatException;
import com.imin.zxing.NotFoundException;
import com.imin.zxing.common.BitArray;

import java.util.Map;

/**
 * <p>Implements decoding of the UPC-A format.</p>
 *
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */
public final class UPCAReader extends UPCEANReader {

  private final UPCEANReader ean13Reader = new EAN13Reader();

  @Override
  public Result decodeRow(int rowNumber,
                          BitArray row,
                          int[] startGuardRange,
                          Map<DecodeHintType,?> hints)
      throws NotFoundException, FormatException, ChecksumException {
    return maybeReturnResult(ean13Reader.decodeRow(rowNumber, row, startGuardRange, hints));
  }

  @Override
  public Result decodeRow(int rowNumber, BitArray row, Map<DecodeHintType,?> hints)
      throws NotFoundException, FormatException, ChecksumException {
    return maybeReturnResult(ean13Reader.decodeRow(rowNumber, row, hints));
  }

  @Override
  public Result decode(BinaryBitmap image) throws NotFoundException, FormatException {
    return maybeReturnResult(ean13Reader.decode(image));
  }

  @Override
  public Result decode(BinaryBitmap image, Map<DecodeHintType,?> hints)
      throws NotFoundException, FormatException {
    return maybeReturnResult(ean13Reader.decode(image, hints));
  }

  @Override
  BarcodeFormat getBarcodeFormat() {
    return BarcodeFormat.UPC_A;
  }

  @Override
  protected int decodeMiddle(BitArray row, int[] startRange, StringBuilder resultString)
      throws NotFoundException {
    return ean13Reader.decodeMiddle(row, startRange, resultString);
  }

  private static Result maybeReturnResult(Result result) throws FormatException {
    String text = result.getText();
    if (text.charAt(0) == '0') {
      Result upcaResult = new Result(text.substring(1), null, result.getResultPoints(), BarcodeFormat.UPC_A);
      if (result.getResultMetadata() != null) {
        upcaResult.putAllMetadata(result.getResultMetadata());
      }
      return upcaResult;
    } else {
      throw FormatException.getFormatInstance();
    }
  }

}
