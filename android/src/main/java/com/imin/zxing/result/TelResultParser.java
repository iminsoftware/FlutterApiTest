/*
 * Copyright 2008 ZXing authors
 *

 */

package com.imin.zxing.result;

import com.imin.scan.Result;

/**
 * Parses a "tel:" URI result, which specifies a phone number.
 *
 * @author Sean Owen
 */
public final class TelResultParser extends ResultParser {

  @Override
  public TelParsedResult parse(Result result) {
    String rawText = getMassagedText(result);
    if (!rawText.startsWith("tel:") && !rawText.startsWith("TEL:")) {
      return null;
    }
    // Normalize "TEL:" to "tel:"
    String telURI = rawText.startsWith("TEL:") ? "tel:" + rawText.substring(4) : rawText;
    // Drop tel, query portion
    int queryStart = rawText.indexOf('?', 4);
    String number = queryStart < 0 ? rawText.substring(4) : rawText.substring(4, queryStart);
    return new TelParsedResult(number, telURI, null);
  }

}