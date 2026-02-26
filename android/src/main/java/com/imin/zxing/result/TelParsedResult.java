/*
 * Copyright 2008 ZXing authors
 *

 */

package com.imin.zxing.result;

/**
 * Represents a parsed result that encodes a telephone number.
 *
 * @author Sean Owen
 */
public final class TelParsedResult extends ParsedResult {

  private final String number;
  private final String telURI;
  private final String title;

  public TelParsedResult(String number, String telURI, String title) {
    super(ParsedResultType.TEL);
    this.number = number;
    this.telURI = telURI;
    this.title = title;
  }

  public String getNumber() {
    return number;
  }

  public String getTelURI() {
    return telURI;
  }

  public String getTitle() {
    return title;
  }

  @Override
  public String getDisplayResult() {
    StringBuilder result = new StringBuilder(20);
    maybeAppend(number, result);
    maybeAppend(title, result);
    return result.toString();
  }

}