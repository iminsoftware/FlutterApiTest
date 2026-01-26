/*
 * Copyright 2009 ZXing authors
 *

 */

package com.imin.zxing.oned.rss;

import com.imin.zxing.ResultPoint;

/**
 * Encapsulates an RSS barcode finder pattern, including its start/end position and row.
 */
public final class FinderPattern {

  private final int value;
  private final int[] startEnd;
  private final ResultPoint[] resultPoints;

  public FinderPattern(int value, int[] startEnd, int start, int end, int rowNumber) {
    this.value = value;
    this.startEnd = startEnd;
    this.resultPoints = new ResultPoint[] {
        new ResultPoint(start, rowNumber),
        new ResultPoint(end, rowNumber),
    };
  }

  public int getValue() {
    return value;
  }

  public int[] getStartEnd() {
    return startEnd;
  }

  public ResultPoint[] getResultPoints() {
    return resultPoints;
  }

  @Override
  public boolean equals(Object o) {
    if (!(o instanceof FinderPattern)) {
      return false;
    }
    FinderPattern that = (FinderPattern) o;
    return value == that.value;
  }

  @Override
  public int hashCode() {
    return value;
  }

}
