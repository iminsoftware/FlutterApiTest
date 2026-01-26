/*
 * Copyright 2010 ZXing authors
 *

 */

package com.imin.zxing.aztec;

import com.imin.scan.Result;
import com.imin.zxing.BarcodeFormat;
import com.imin.zxing.BinaryBitmap;
import com.imin.zxing.DecodeHintType;
import com.imin.zxing.FormatException;
import com.imin.zxing.NotFoundException;
import com.imin.zxing.Reader;
import com.imin.zxing.ResultMetadataType;
import com.imin.zxing.ResultPoint;
import com.imin.zxing.ResultPointCallback;
import com.imin.zxing.aztec.decoder.Decoder;
import com.imin.zxing.aztec.detector.Detector;
import com.imin.zxing.common.DecoderResult;

import java.util.List;
import java.util.Map;

/**
 * This implementation can detect and decode Aztec codes in an image.
 *
 * @author David Olivier
 */
public final class AztecReader implements Reader {

  /**
   * Locates and decodes a Data Matrix code in an image.
   *
   * @return a String representing the content encoded by the Data Matrix code
   * @throws NotFoundException if a Data Matrix code cannot be found
   * @throws FormatException if a Data Matrix code cannot be decoded
   */
  @Override
  public Result decode(BinaryBitmap image) throws NotFoundException, FormatException {
    return decode(image, null);
  }

  @Override
  public Result decode(BinaryBitmap image, Map<DecodeHintType,?> hints)
      throws NotFoundException, FormatException {

    NotFoundException notFoundException = null;
    FormatException formatException = null;
    Detector detector = new Detector(image.getBlackMatrix());
    ResultPoint[] points = null;
    DecoderResult decoderResult = null;
    try {
      AztecDetectorResult detectorResult = detector.detect(false);
      points = detectorResult.getPoints();
      decoderResult = new Decoder().decode(detectorResult);
    } catch (NotFoundException e) {
      notFoundException = e;
    } catch (FormatException e) {
      formatException = e;
    }
    if (decoderResult == null) {
      try {
        AztecDetectorResult detectorResult = detector.detect(true);
        points = detectorResult.getPoints();
        decoderResult = new Decoder().decode(detectorResult);
      } catch (NotFoundException | FormatException e) {
        if (notFoundException != null) {
          throw notFoundException;
        }
        if (formatException != null) {
          throw formatException;
        }
        throw e;
      }
    }

    if (hints != null) {
      ResultPointCallback rpcb = (ResultPointCallback) hints.get(DecodeHintType.NEED_RESULT_POINT_CALLBACK);
      if (rpcb != null) {
        for (ResultPoint point : points) {
          rpcb.foundPossibleResultPoint(point);
        }
      }
    }

    Result result = new Result(decoderResult.getText(),
                               decoderResult.getRawBytes(),
                               decoderResult.getNumBits(),
                               points,
                               BarcodeFormat.AZTEC,
                               System.currentTimeMillis());

    List<byte[]> byteSegments = decoderResult.getByteSegments();
    if (byteSegments != null) {
      result.putMetadata(ResultMetadataType.BYTE_SEGMENTS, byteSegments);
    }
    String ecLevel = decoderResult.getECLevel();
    if (ecLevel != null) {
      result.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, ecLevel);
    }
    result.putMetadata(ResultMetadataType.SYMBOLOGY_IDENTIFIER, "]z" + decoderResult.getSymbologyModifier());

    return result;
  }

  @Override
  public void reset() {
    // do nothing
  }

}
