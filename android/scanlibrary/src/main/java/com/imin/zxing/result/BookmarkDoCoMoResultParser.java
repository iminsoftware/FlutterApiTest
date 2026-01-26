

package com.imin.zxing.result;

import com.imin.scan.Result;

/**
 * @author Sean Owen
 */
public final class BookmarkDoCoMoResultParser extends AbstractDoCoMoResultParser {

  @Override
  public URIParsedResult parse(Result result) {
    String rawText = result.getText();
    if (!rawText.startsWith("MEBKM:")) {
      return null;
    }
    String title = matchSingleDoCoMoPrefixedField("TITLE:", rawText, true);
    String[] rawUri = matchDoCoMoPrefixedField("URL:", rawText);
    if (rawUri == null) {
      return null;
    }
    String uri = rawUri[0];
    return URIResultParser.isBasicallyValidURI(uri) ? new URIParsedResult(uri, title) : null;
  }

}
