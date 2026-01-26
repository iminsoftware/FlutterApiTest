/*
 * Copyright 2010 ZXing authors
 *

 */

package com.imin.zxing.result;

/**
 * Represents the type of data encoded by a barcode -- from plain text, to a
 * URI, to an e-mail address, etc.
 *
 * @author Sean Owen
 */
public enum ParsedResultType {

  ADDRESSBOOK,
  EMAIL_ADDRESS,
  PRODUCT,
  URI,
  TEXT,
  GEO,
  TEL,
  SMS,
  CALENDAR,
  WIFI,
  ISBN,
  VIN,

}
