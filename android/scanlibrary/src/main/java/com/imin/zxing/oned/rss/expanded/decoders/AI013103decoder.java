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
final class AI013103decoder extends AI013x0xDecoder {

  AI013103decoder(BitArray information) {
    super(information);
  }

  @Override
  protected void addWeightCode(StringBuilder buf, int weight) {
    buf.append("(3103)");
  }

  @Override
  protected int checkWeight(int weight) {
    return weight;
  }
}
