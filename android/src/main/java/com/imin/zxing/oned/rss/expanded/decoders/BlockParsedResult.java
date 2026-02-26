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
final class BlockParsedResult {

  private final DecodedInformation decodedInformation;
  private final boolean finished;

  BlockParsedResult() {
    this(null, false);
  }

  BlockParsedResult(DecodedInformation information, boolean finished) {
    this.finished = finished;
    this.decodedInformation = information;
  }

  DecodedInformation getDecodedInformation() {
    return this.decodedInformation;
  }

  boolean isFinished() {
    return this.finished;
  }
}
