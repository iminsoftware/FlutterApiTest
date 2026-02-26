/*
 * Copyright 2006-2007 Jeremias Maerki.
 *

 */

package com.imin.zxing.datamatrix.encoder;

interface Encoder {

  int getEncodingMode();

  void encode(EncoderContext context);

}
