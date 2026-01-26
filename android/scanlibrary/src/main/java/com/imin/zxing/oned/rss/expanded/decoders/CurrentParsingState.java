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
 */
final class CurrentParsingState {

  private int position;
  private State encoding;

  private enum State {
    NUMERIC,
    ALPHA,
    ISO_IEC_646
  }

  CurrentParsingState() {
    this.position = 0;
    this.encoding = State.NUMERIC;
  }

  int getPosition() {
    return position;
  }

  void setPosition(int position) {
    this.position = position;
  }

  void incrementPosition(int delta) {
    position += delta;
  }

  boolean isAlpha() {
    return this.encoding == State.ALPHA;
  }

  boolean isNumeric() {
    return this.encoding == State.NUMERIC;
  }

  boolean isIsoIec646() {
    return this.encoding == State.ISO_IEC_646;
  }

  void setNumeric() {
    this.encoding = State.NUMERIC;
  }

  void setAlpha() {
    this.encoding = State.ALPHA;
  }

  void setIsoIec646() {
    this.encoding = State.ISO_IEC_646;
  }
}
