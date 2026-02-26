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

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
final class DecodedInformation extends DecodedObject {

  private final String newString;
  private final int remainingValue;
  private final boolean remaining;

  DecodedInformation(int newPosition, String newString) {
    super(newPosition);
    this.newString = newString;
    this.remaining = false;
    this.remainingValue = 0;
  }

  DecodedInformation(int newPosition, String newString, int remainingValue) {
    super(newPosition);
    this.remaining = true;
    this.remainingValue = remainingValue;
    this.newString = newString;
  }

  String getNewString() {
    return this.newString;
  }

  boolean isRemaining() {
    return this.remaining;
  }

  int getRemainingValue() {
    return this.remainingValue;
  }
}
