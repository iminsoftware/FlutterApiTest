/*
 * Copyright 2009 ZXing authors
 *

 */

package com.imin.zxing.multi.qrcode.detector;

import com.imin.zxing.DecodeHintType;
import com.imin.zxing.NotFoundException;
import com.imin.zxing.ReaderException;
import com.imin.zxing.ResultPointCallback;
import com.imin.zxing.common.BitMatrix;
import com.imin.zxing.common.DetectorResult;
import com.imin.zxing.qrcode.detector.Detector;
import com.imin.zxing.qrcode.detector.FinderPatternInfo;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * <p>Encapsulates logic that can detect one or more QR Codes in an image, even if the QR Code
 * is rotated or skewed, or partially obscured.</p>
 *
 * @author Sean Owen
 * @author Hannes Erven
 */
public final class MultiDetector extends Detector {

  private static final DetectorResult[] EMPTY_DETECTOR_RESULTS = new DetectorResult[0];

  public MultiDetector(BitMatrix image) {
    super(image);
  }

  public DetectorResult[] detectMulti(Map<DecodeHintType,?> hints) throws NotFoundException {
    BitMatrix image = getImage();
    ResultPointCallback resultPointCallback =
        hints == null ? null : (ResultPointCallback) hints.get(DecodeHintType.NEED_RESULT_POINT_CALLBACK);
    MultiFinderPatternFinder finder = new MultiFinderPatternFinder(image, resultPointCallback);
    FinderPatternInfo[] infos = finder.findMulti(hints);

    if (infos.length == 0) {
      throw NotFoundException.getNotFoundInstance();
    }

    List<DetectorResult> result = new ArrayList<>();
    for (FinderPatternInfo info : infos) {
      try {
        result.add(processFinderPatternInfo(info));
      } catch (ReaderException e) {
        // ignore
      }
    }
    if (result.isEmpty()) {
      return EMPTY_DETECTOR_RESULTS;
    } else {
      return result.toArray(EMPTY_DETECTOR_RESULTS);
    }
  }

}
