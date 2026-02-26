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
final class DecodedChar extends DecodedObject {

  private final char value;

  static final char FNC1 = '$'; // It's not in Alphanumeric neither in ISO/IEC 646 charset

  DecodedChar(int newPosition, char value) {
    super(newPosition);
    this.value = value;
  }

  char getValue() {
    return this.value;
  }

  boolean isFNC1() {
    return this.value == FNC1;
  }

}
