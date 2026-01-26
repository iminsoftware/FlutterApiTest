/*
 * Copyright 2009 ZXing authors
 *

 */

package com.imin.zxing.oned.rss;

/**
 * Encapsulates a since character value in an RSS barcode, including its checksum information.
 */
public class DataCharacter {

  private final int value;
  private final int checksumPortion;

  public DataCharacter(int value, int checksumPortion) {
    this.value = value;
    this.checksumPortion = checksumPortion;
  }

  public final int getValue() {
    return value;
  }

  public final int getChecksumPortion() {
    return checksumPortion;
  }

  @Override
  public final String toString() {
    return value + "(" + checksumPortion + ')';
  }

  @Override
  public final boolean equals(Object o) {
    if (!(o instanceof DataCharacter)) {
      return false;
    }
    DataCharacter that = (DataCharacter) o;
    return value == that.value && checksumPortion == that.checksumPortion;
  }

  @Override
  public final int hashCode() {
    return value ^ checksumPortion;
  }

}
