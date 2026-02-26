

package com.imin.zxing.pdf417.detector;

import com.imin.zxing.ResultPoint;
import com.imin.zxing.common.BitMatrix;

import java.util.List;

/**
 * @author Guenther Grau
 */
public final class PDF417DetectorResult {

  private final BitMatrix bits;
  private final List<ResultPoint[]> points;
  private final int rotation;

  public PDF417DetectorResult(BitMatrix bits, List<ResultPoint[]> points, int rotation) {
    this.bits = bits;
    this.points = points;
    this.rotation = rotation;
  }

  public PDF417DetectorResult(BitMatrix bits, List<ResultPoint[]> points) {
    this(bits, points, 0);
  }

  public BitMatrix getBits() {
    return bits;
  }

  public List<ResultPoint[]> getPoints() {
    return points;
  }

  public int getRotation() {
    return rotation;
  }

}
