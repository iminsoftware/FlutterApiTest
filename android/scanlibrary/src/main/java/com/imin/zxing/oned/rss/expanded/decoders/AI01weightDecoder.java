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

import com.imin.zxing.common.BitArray;

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */
abstract class AI01weightDecoder extends AI01decoder {

  AI01weightDecoder(BitArray information) {
    super(information);
  }

  final void encodeCompressedWeight(StringBuilder buf, int currentPos, int weightSize) {
    int originalWeightNumeric = this.getGeneralDecoder().extractNumericValueFromBitArray(currentPos, weightSize);
    addWeightCode(buf, originalWeightNumeric);

    int weightNumeric = checkWeight(originalWeightNumeric);

    int currentDivisor = 100000;
    for (int i = 0; i < 5; ++i) {
      if (weightNumeric / currentDivisor == 0) {
        buf.append('0');
      }
      currentDivisor /= 10;
    }
    buf.append(weightNumeric);
  }

  protected abstract void addWeightCode(StringBuilder buf, int weight);

  protected abstract int checkWeight(int weight);

}
