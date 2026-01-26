/*
 * Copyright 2010 ZXing authors
 *

 */

package com.imin.zxing.aztec;

import com.imin.zxing.ResultPoint;
import com.imin.zxing.common.BitMatrix;
import com.imin.zxing.common.DetectorResult;

/**
 * <p>Extends {@link DetectorResult} with more information specific to the Aztec format,
 * like the number of layers and whether it's compact.</p>
 *
 * @author Sean Owen
 */
public final class AztecDetectorResult extends DetectorResult {

  private final boolean compact;
  private final int nbDatablocks;
  private final int nbLayers;

  public AztecDetectorResult(BitMatrix bits,
                             ResultPoint[] points,
                             boolean compact,
                             int nbDatablocks,
                             int nbLayers) {
    super(bits, points);
    this.compact = compact;
    this.nbDatablocks = nbDatablocks;
    this.nbLayers = nbLayers;
  }

  public int getNbLayers() {
    return nbLayers;
  }

  public int getNbDatablocks() {
    return nbDatablocks;
  }

  public boolean isCompact() {
    return compact;
  }

}
