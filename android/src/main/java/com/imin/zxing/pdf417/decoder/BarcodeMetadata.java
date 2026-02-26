/*
 * Copyright 2013 ZXing authors
 *

 */

package com.imin.zxing.pdf417.decoder;

/**
 * @author Guenther Grau
 */
final class BarcodeMetadata {

  private final int columnCount;
  private final int errorCorrectionLevel;
  private final int rowCountUpperPart;
  private final int rowCountLowerPart;
  private final int rowCount;

  BarcodeMetadata(int columnCount, int rowCountUpperPart, int rowCountLowerPart, int errorCorrectionLevel) {
    this.columnCount = columnCount;
    this.errorCorrectionLevel = errorCorrectionLevel;
    this.rowCountUpperPart = rowCountUpperPart;
    this.rowCountLowerPart = rowCountLowerPart;
    this.rowCount = rowCountUpperPart + rowCountLowerPart;
  }

  int getColumnCount() {
    return columnCount;
  }

  int getErrorCorrectionLevel() {
    return errorCorrectionLevel;
  }

  int getRowCount() {
    return rowCount;
  }

  int getRowCountUpperPart() {
    return rowCountUpperPart;
  }

  int getRowCountLowerPart() {
    return rowCountLowerPart;
  }

}
