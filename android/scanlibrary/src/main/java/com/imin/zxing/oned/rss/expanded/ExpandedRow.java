/*
 * Copyright (C) 2010 ZXing authors
 *

 */

package com.imin.zxing.oned.rss.expanded;

import java.util.ArrayList;
import java.util.List;

/**
 * One row of an RSS Expanded Stacked symbol, consisting of 1+ expanded pairs.
 */
final class ExpandedRow {

  private final List<ExpandedPair> pairs;
  private final int rowNumber;

  ExpandedRow(List<ExpandedPair> pairs, int rowNumber) {
    this.pairs = new ArrayList<>(pairs);
    this.rowNumber = rowNumber;
  }

  List<ExpandedPair> getPairs() {
    return this.pairs;
  }

  int getRowNumber() {
    return this.rowNumber;
  }

  boolean isEquivalent(List<ExpandedPair> otherPairs) {
    return this.pairs.equals(otherPairs);
  }

  @Override
  public String toString() {
    return "{ " + pairs + " }";
  }

  /**
   * Two rows are equal if they contain the same pairs in the same order.
   */
  @Override
  public boolean equals(Object o) {
    if (!(o instanceof ExpandedRow)) {
      return false;
    }
    ExpandedRow that = (ExpandedRow) o;
    return this.pairs.equals(that.pairs);
  }

  @Override
  public int hashCode() {
    return pairs.hashCode();
  }

}
