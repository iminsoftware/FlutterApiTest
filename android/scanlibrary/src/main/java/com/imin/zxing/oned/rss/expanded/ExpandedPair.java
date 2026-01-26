/*
 * Copyright (C) 2010 ZXing authors
 *

 */

/*
 * These authors would like to acknowledge the Spanish Ministry of Industry,
 * Tourism and Trade, for the support in the project TSI020301-2008-2
 * "PIRAmIDE: Personalizable Interactions with Resources on AmI-enabled
 * Mobile Dynamic Environments", led by Treelogic
 * ( http://www.treelogic.com/ ):
 *
 *   http://www.piramidepse.com/
 */

package com.imin.zxing.oned.rss.expanded;

import com.imin.zxing.oned.rss.DataCharacter;
import com.imin.zxing.oned.rss.FinderPattern;

import java.util.Objects;

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */
final class ExpandedPair {

  private final DataCharacter leftChar;
  private final DataCharacter rightChar;
  private final FinderPattern finderPattern;

  ExpandedPair(DataCharacter leftChar,
               DataCharacter rightChar,
               FinderPattern finderPattern) {
    this.leftChar = leftChar;
    this.rightChar = rightChar;
    this.finderPattern = finderPattern;
  }

  DataCharacter getLeftChar() {
    return this.leftChar;
  }

  DataCharacter getRightChar() {
    return this.rightChar;
  }

  FinderPattern getFinderPattern() {
    return this.finderPattern;
  }

  boolean mustBeLast() {
    return this.rightChar == null;
  }

  @Override
  public String toString() {
    return
        "[ " + leftChar + " , " + rightChar + " : " +
        (finderPattern == null ? "null" : finderPattern.getValue()) + " ]";
  }

  @Override
  public boolean equals(Object o) {
    if (!(o instanceof ExpandedPair)) {
      return false;
    }
    ExpandedPair that = (ExpandedPair) o;
    return Objects.equals(leftChar, that.leftChar) &&
        Objects.equals(rightChar, that.rightChar) &&
        Objects.equals(finderPattern, that.finderPattern);
  }

  @Override
  public int hashCode() {
    return Objects.hashCode(leftChar) ^ Objects.hashCode(rightChar) ^ Objects.hashCode(finderPattern);
  }

}
