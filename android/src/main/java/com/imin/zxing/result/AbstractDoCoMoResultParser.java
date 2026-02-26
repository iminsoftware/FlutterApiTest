

package com.imin.zxing.result;

/**
 * <p>See
 * <a href="http://www.nttdocomo.co.jp/english/service/imode/make/content/barcode/about/s2.html">
 * DoCoMo's documentation</a> about the result types represented by subclasses of this class.</p>
 *
 * <p>Thanks to Jeff Griffin for proposing rewrite of these classes that relies less
 * on exception-based mechanisms during parsing.</p>
 *
 * @author Sean Owen
 */
abstract class AbstractDoCoMoResultParser extends ResultParser {

  static String[] matchDoCoMoPrefixedField(String prefix, String rawText) {
    return matchPrefixedField(prefix, rawText, ';', true);
  }

  static String matchSingleDoCoMoPrefixedField(String prefix, String rawText, boolean trim) {
    return matchSinglePrefixedField(prefix, rawText, ';', trim);
  }

}
