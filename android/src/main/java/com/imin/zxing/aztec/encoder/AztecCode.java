/*
 * Copyright 2013 ZXing authors
 *

 */

package com.imin.zxing.aztec.encoder;

import com.imin.zxing.common.BitMatrix;

/**
 * Aztec 2D code representation
 *
 * @author Rustam Abdullaev
 */
public final class AztecCode {

  private boolean compact;
  private int size;
  private int layers;
  private int codeWords;
  private BitMatrix matrix;

  /**
   * @return {@code true} if compact instead of full mode
   */
  public boolean isCompact() {
    return compact;
  }

  public void setCompact(boolean compact) {
    this.compact = compact;
  }

  /**
   * @return size in pixels (width and height)
   */
  public int getSize() {
    return size;
  }

  public void setSize(int size) {
    this.size = size;
  }

  /**
   * @return number of levels
   */
  public int getLayers() {
    return layers;
  }

  public void setLayers(int layers) {
    this.layers = layers;
  }

  /**
   * @return number of data codewords
   */
  public int getCodeWords() {
    return codeWords;
  }

  public void setCodeWords(int codeWords) {
    this.codeWords = codeWords;
  }

  /**
   * @return the symbol image
   */
  public BitMatrix getMatrix() {
    return matrix;
  }

  public void setMatrix(BitMatrix matrix) {
    this.matrix = matrix;
  }

}
