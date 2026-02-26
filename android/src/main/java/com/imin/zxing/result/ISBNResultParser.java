/*
 * Copyright 2008 ZXing authors
 *

 */

package com.imin.zxing.result;

import com.imin.scan.Result;
import com.imin.zxing.BarcodeFormat;

/**
 * Parses strings of digits that represent a ISBN.
 * 
 * @author jbreiden@google.com (Jeff Breidenbach)
 */
public final class ISBNResultParser extends ResultParser {

  /**
   * See <a href="http://www.bisg.org/isbn-13/for.dummies.html">ISBN-13 For Dummies</a>
   */
  @Override
  public ISBNParsedResult parse(Result result) {
    BarcodeFormat format = result.getBarcodeFormat();
    if (format != BarcodeFormat.EAN_13) {
      return null;
    }
    String rawText = getMassagedText(result);
    int length = rawText.length();
    if (length != 13) {
      return null;
    }
    if (!rawText.startsWith("978") && !rawText.startsWith("979")) {
      return null;
    }
   
    return new ISBNParsedResult(rawText);
  }

}
