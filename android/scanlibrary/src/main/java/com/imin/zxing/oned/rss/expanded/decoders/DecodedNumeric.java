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

package com.imin.zxing.oned.rss.expanded.decoders;

import com.imin.zxing.FormatException;

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
final class DecodedNumeric extends DecodedObject {

  private final int firstDigit;
  private final int secondDigit;

  static final int FNC1 = 10;

  DecodedNumeric(int newPosition, int firstDigit, int secondDigit) throws FormatException {
    super(newPosition);

    if (firstDigit < 0 || firstDigit > 10 || secondDigit < 0 || secondDigit > 10) {
      throw FormatException.getFormatInstance();
    }

    this.firstDigit  = firstDigit;
    this.secondDigit = secondDigit;
  }

  int getFirstDigit() {
    return this.firstDigit;
  }

  int getSecondDigit() {
    return this.secondDigit;
  }

  int getValue() {
    return this.firstDigit * 10 + this.secondDigit;
  }

  boolean isFirstDigitFNC1() {
    return this.firstDigit == FNC1;
  }

  boolean isSecondDigitFNC1() {
    return this.secondDigit == FNC1;
  }

}
