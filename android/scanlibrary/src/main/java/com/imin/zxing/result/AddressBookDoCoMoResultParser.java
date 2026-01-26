

package com.imin.zxing.result;

import com.imin.scan.Result;

/**
 * Implements the "MECARD" address book entry format.
 *
 * Supported keys: N, SOUND, TEL, EMAIL, NOTE, ADR, BDAY, URL, plus ORG
 * Unsupported keys: TEL-AV, NICKNAME
 *
 * Except for TEL, multiple values for keys are also not supported;
 * the first one found takes precedence.
 *
 * Our understanding of the MECARD format is based on this document:
 *
 * http://www.mobicode.org.tw/files/OMIA%20Mobile%20Bar%20Code%20Standard%20v3.2.1.doc
 *
 * @author Sean Owen
 */
public final class AddressBookDoCoMoResultParser extends AbstractDoCoMoResultParser {

  @Override
  public AddressBookParsedResult parse(Result result) {
    String rawText = getMassagedText(result);
    if (!rawText.startsWith("MECARD:")) {
      return null;
    }
    String[] rawName = matchDoCoMoPrefixedField("N:", rawText);
    if (rawName == null) {
      return null;
    }
    String name = parseName(rawName[0]);
    String pronunciation = matchSingleDoCoMoPrefixedField("SOUND:", rawText, true);
    String[] phoneNumbers = matchDoCoMoPrefixedField("TEL:", rawText);
    String[] emails = matchDoCoMoPrefixedField("EMAIL:", rawText);
    String note = matchSingleDoCoMoPrefixedField("NOTE:", rawText, false);
    String[] addresses = matchDoCoMoPrefixedField("ADR:", rawText);
    String birthday = matchSingleDoCoMoPrefixedField("BDAY:", rawText, true);
    if (!isStringOfDigits(birthday, 8)) {
      // No reason to throw out the whole card because the birthday is formatted wrong.
      birthday = null;
    }
    String[] urls = matchDoCoMoPrefixedField("URL:", rawText);

    // Although ORG may not be strictly legal in MECARD, it does exist in VCARD and we might as well
    // honor it when found in the wild.
    String org = matchSingleDoCoMoPrefixedField("ORG:", rawText, true);

    return new AddressBookParsedResult(maybeWrap(name),
                                       null,
                                       pronunciation,
                                       phoneNumbers,
                                       null,
                                       emails,
                                       null,
                                       null,
                                       note,
                                       addresses,
                                       null,
                                       org,
                                       birthday,
                                       null,
                                       urls,
                                       null);
  }

  private static String parseName(String name) {
    int comma = name.indexOf(',');
    if (comma >= 0) {
      // Format may be last,first; switch it around
      return name.substring(comma + 1) + ' ' + name.substring(0, comma);
    }
    return name;
  }

}
