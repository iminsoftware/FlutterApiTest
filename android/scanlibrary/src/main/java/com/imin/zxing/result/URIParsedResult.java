

package com.imin.zxing.result;

/**
 * A simple result type encapsulating a URI that has no further interpretation.
 *
 * @author Sean Owen
 */
public final class URIParsedResult extends ParsedResult {

  private final String uri;
  private final String title;

  public URIParsedResult(String uri, String title) {
    super(ParsedResultType.URI);
    this.uri = massageURI(uri);
    this.title = title;
  }

  public String getURI() {
    return uri;
  }

  public String getTitle() {
    return title;
  }

  /**
   * @return true if the URI contains suspicious patterns that may suggest it intends to
   *  mislead the user about its true nature
   * @deprecated see {@link URIResultParser#isPossiblyMaliciousURI(String)}
   */
  @Deprecated
  public boolean isPossiblyMaliciousURI() {
    return URIResultParser.isPossiblyMaliciousURI(uri);
  }

  @Override
  public String getDisplayResult() {
    StringBuilder result = new StringBuilder(30);
    maybeAppend(title, result);
    maybeAppend(uri, result);
    return result.toString();
  }

  /**
   * Transforms a string that represents a URI into something more proper, by adding or canonicalizing
   * the protocol.
   */
  private static String massageURI(String uri) {
    uri = uri.trim();
    int protocolEnd = uri.indexOf(':');
    if (protocolEnd < 0 || isColonFollowedByPortNumber(uri, protocolEnd)) {
      // No protocol, or found a colon, but it looks like it is after the host, so the protocol is still missing,
      // so assume http
      uri = "http://" + uri;
    }
    return uri;
  }

  private static boolean isColonFollowedByPortNumber(String uri, int protocolEnd) {
    int start = protocolEnd + 1;
    int nextSlash = uri.indexOf('/', start);
    if (nextSlash < 0) {
      nextSlash = uri.length();
    }
    return ResultParser.isSubstringOfDigits(uri, start, nextSlash - start);
  }


}
