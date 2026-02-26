/*
 * Copyright 2013 ZXing authors
 *

 */

package com.imin.zxing.pdf417.decoder;

/**
 * @author Guenther Grau
 */
final class Codeword {

  private static final int BARCODE_ROW_UNKNOWN = -1;

  private final int startX;
  private final int endX;
  private final int bucket;
  private final int value;
  private int rowNumber = BARCODE_ROW_UNKNOWN;

  Codeword(int startX, int endX, int bucket, int value) {
    this.startX = startX;
    this.endX = endX;
    this.bucket = bucket;
    this.value = value;
  }

  boolean hasValidRowNumber() {
    return isValidRowNumber(rowNumber);
  }

  boolean isValidRowNumber(int rowNumber) {
    return rowNumber != BARCODE_ROW_UNKNOWN && bucket == (rowNumber % 3) * 3;
  }

  void setRowNumberAsRowIndicatorColumn() {
    rowNumber = (value / 30) * 3 + bucket / 3;
  }

  int getWidth() {
    return endX - startX;
  }

  int getStartX() {
    return startX;
  }

  int getEndX() {
    return endX;
  }

  int getBucket() {
    return bucket;
  }

  int getValue() {
    return value;
  }

  int getRowNumber() {
    return rowNumber;
  }

  void setRowNumber(int rowNumber) {
    this.rowNumber = rowNumber;
  }

  @Override
  public String toString() {
    return rowNumber + "|" + value;
  }

}
