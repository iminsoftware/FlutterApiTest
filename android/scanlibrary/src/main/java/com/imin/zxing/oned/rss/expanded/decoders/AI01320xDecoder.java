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
final class AI01320xDecoder extends AI013x0xDecoder {

  AI01320xDecoder(BitArray information) {
    super(information);
  }

  @Override
  protected void addWeightCode(StringBuilder buf, int weight) {
    if (weight < 10000) {
      buf.append("(3202)");
    } else {
      buf.append("(3203)");
    }
  }

  @Override
  protected int checkWeight(int weight) {
    if (weight < 10000) {
      return weight;
    }
    return weight - 10000;
  }

}
