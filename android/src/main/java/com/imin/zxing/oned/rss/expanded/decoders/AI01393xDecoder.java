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
import com.imin.zxing.NotFoundException;
import com.imin.zxing.common.BitArray;

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */
final class AI01393xDecoder extends AI01decoder {

  private static final int HEADER_SIZE = 5 + 1 + 2;
  private static final int LAST_DIGIT_SIZE = 2;
  private static final int FIRST_THREE_DIGITS_SIZE = 10;

  AI01393xDecoder(BitArray information) {
    super(information);
  }

  @Override
  public String parseInformation() throws NotFoundException, FormatException {
    if (this.getInformation().getSize() < HEADER_SIZE + GTIN_SIZE) {
      throw NotFoundException.getNotFoundInstance();
    }

    StringBuilder buf = new StringBuilder();

    encodeCompressedGtin(buf, HEADER_SIZE);

    int lastAIdigit =
        this.getGeneralDecoder().extractNumericValueFromBitArray(HEADER_SIZE + GTIN_SIZE, LAST_DIGIT_SIZE);

    buf.append("(393");
    buf.append(lastAIdigit);
    buf.append(')');

    int firstThreeDigits = this.getGeneralDecoder().extractNumericValueFromBitArray(
        HEADER_SIZE + GTIN_SIZE + LAST_DIGIT_SIZE, FIRST_THREE_DIGITS_SIZE);
    if (firstThreeDigits / 100 == 0) {
      buf.append('0');
    }
    if (firstThreeDigits / 10 == 0) {
      buf.append('0');
    }
    buf.append(firstThreeDigits);

    DecodedInformation generalInformation = this.getGeneralDecoder().decodeGeneralPurposeField(
        HEADER_SIZE + GTIN_SIZE + LAST_DIGIT_SIZE + FIRST_THREE_DIGITS_SIZE, null);
    buf.append(generalInformation.getNewString());

    return buf.toString();
  }
}
