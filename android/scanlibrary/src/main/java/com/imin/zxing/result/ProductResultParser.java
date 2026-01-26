

package com.imin.zxing.result;

import com.imin.scan.Result;
import com.imin.zxing.BarcodeFormat;
import com.imin.zxing.oned.UPCEReader;

/**
 * Parses strings of digits that represent a UPC code.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */
public final class ProductResultParser extends ResultParser {

  // Treat all UPC and EAN variants as UPCs, in the sense that they are all product barcodes.
  @Override
  public ProductParsedResult parse(Result result) {
    BarcodeFormat format = result.getBarcodeFormat();
    if (!(format == BarcodeFormat.UPC_A || format == BarcodeFormat.UPC_E ||
          format == BarcodeFormat.EAN_8 || format == BarcodeFormat.EAN_13)) {
      return null;
    }
    String rawText = getMassagedText(result);
    if (!isStringOfDigits(rawText, rawText.length())) {
      return null;
    }
    // Not actually checking the checksum again here    

    String normalizedProductID;
    // Expand UPC-E for purposes of searching
    if (format == BarcodeFormat.UPC_E && rawText.length() == 8) {
      normalizedProductID = UPCEReader.convertUPCEtoUPCA(rawText);
    } else {
      normalizedProductID = rawText;
    }

    return new ProductParsedResult(rawText, normalizedProductID);
  }

}