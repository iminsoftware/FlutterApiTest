

package com.imin.zxing.result;

import com.imin.scan.Result;

/**
 * <p>Abstract class representing the result of decoding a barcode, as more than
 * a String -- as some type of structured data. This might be a subclass which represents
 * a URL, or an e-mail address. {@link ResultParser#parseResult(Result)} will turn a raw
 * decoded string into the most appropriate type of structured representation.</p>
 *
 * <p>Thanks to Jeff Griffin for proposing rewrite of these classes that relies less
 * on exception-based mechanisms during parsing.</p>
 *
 * @author Sean Owen
 */
public abstract class ParsedResult {

  private final ParsedResultType type;

  protected ParsedResult(ParsedResultType type) {
    this.type = type;
  }

  public final ParsedResultType getType() {
    return type;
  }

  public abstract String getDisplayResult();

  @Override
  public final String toString() {
    return getDisplayResult();
  }

  public static void maybeAppend(String value, StringBuilder result) {
    if (value != null && !value.isEmpty()) {
      // Don't add a newline before the first value
      if (result.length() > 0) {
        result.append('\n');
      }
      result.append(value);
    }
  }

  public static void maybeAppend(String[] values, StringBuilder result) {
    if (values != null) {
      for (String value : values) {
        maybeAppend(value, result);
      }
    }
  }

}
