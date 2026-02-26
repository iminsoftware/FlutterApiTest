/*
 * Copyright 2011 ZXing authors
 *

 */

package com.imin.zxing.pdf417.encoder;

/**
 * Holds all of the information for a barcode in a format where it can be easily accessible
 *
 * @author Jacob Haynes
 */
public final class BarcodeMatrix {

  private final BarcodeRow[] matrix;
  private int currentRow;
  private final int height;
  private final int width;

  /**
   * @param height the height of the matrix (Rows)
   * @param width  the width of the matrix (Cols)
   */
  BarcodeMatrix(int height, int width) {
    matrix = new BarcodeRow[height];
    //Initializes the array to the correct width
    for (int i = 0, matrixLength = matrix.length; i < matrixLength; i++) {
      matrix[i] = new BarcodeRow((width + 4) * 17 + 1);
    }
    this.width = width * 17;
    this.height = height;
    this.currentRow = -1;
  }

  void set(int x, int y, byte value) {
    matrix[y].set(x, value);
  }

  void startRow() {
    ++currentRow;
  }

  BarcodeRow getCurrentRow() {
    return matrix[currentRow];
  }

  public byte[][] getMatrix() {
    return getScaledMatrix(1, 1);
  }

  public byte[][] getScaledMatrix(int xScale, int yScale) {
    byte[][] matrixOut = new byte[height * yScale][width * xScale];
    int yMax = height * yScale;
    for (int i = 0; i < yMax; i++) {
      matrixOut[yMax - i - 1] = matrix[i / yScale].getScaledRow(xScale);
    }
    return matrixOut;
  }
}
