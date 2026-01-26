/*
 * Copyright 2008 ZXing authors
 *

 */

package com.imin.zxing.result;

/**
 * Represents a parsed result that encodes a product ISBN number.
 *
 * @author jbreiden@google.com (Jeff Breidenbach)
 */
public final class ISBNParsedResult extends ParsedResult {

  private final String isbn;

  ISBNParsedResult(String isbn) {
    super(ParsedResultType.ISBN);
    this.isbn = isbn;
  }

  public String getISBN() {
    return isbn;
  }

  @Override
  public String getDisplayResult() {
    return isbn;
  }

}
