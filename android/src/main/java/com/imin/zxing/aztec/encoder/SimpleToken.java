/*
 * Copyright 2013 ZXing authors
 *

 */

package com.imin.zxing.aztec.encoder;

import com.imin.zxing.common.BitArray;

final class SimpleToken extends Token {

  // For normal words, indicates value and bitCount
  private final short value;
  private final short bitCount;

  SimpleToken(Token previous, int value, int bitCount) {
    super(previous);
    this.value = (short) value;
    this.bitCount = (short) bitCount;
  }

  @Override
  void appendTo(BitArray bitArray, byte[] text) {
    bitArray.appendBits(value, bitCount);
  }

  @Override
  public String toString() {
    int value = this.value & ((1 << bitCount) - 1);
    value |= 1 << bitCount;
    return '<' + Integer.toBinaryString(value | (1 << bitCount)).substring(1) + '>';
  }

}
