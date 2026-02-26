

package com.imin.zxing.result;

import com.imin.scan.Result;

import java.util.regex.Pattern;

/**
 * Implements the "MATMSG" email message entry format.
 *
 * Supported keys: TO, SUB, BODY
 *
 * @author Sean Owen
 */
public final class EmailDoCoMoResultParser extends AbstractDoCoMoResultParser {

  private static final Pattern ATEXT_ALPHANUMERIC = Pattern.compile("[a-zA-Z0-9@.!#$%&'*+\\-/=?^_`{|}~]+");

  @Override
  public EmailAddressParsedResult parse(Result result) {
    String rawText = getMassagedText(result);
    if (!rawText.startsWith("MATMSG:")) {
      return null;
    }
    String[] tos = matchDoCoMoPrefixedField("TO:", rawText);
    if (tos == null) {
      return null;
    }
    for (String to : tos) {
      if (!isBasicallyValidEmailAddress(to)) {
        return null;
      }
    }
    String subject = matchSingleDoCoMoPrefixedField("SUB:", rawText, false);
    String body = matchSingleDoCoMoPrefixedField("BODY:", rawText, false);
    return new EmailAddressParsedResult(tos, null, null, subject, body);
  }

  /**
   * This implements only the most basic checking for an email address's validity -- that it contains
   * an '@' and contains no characters disallowed by RFC 2822. This is an overly lenient definition of
   * validity. We want to generally be lenient here since this class is only intended to encapsulate what's
   * in a barcode, not "judge" it.
   */
  static boolean isBasicallyValidEmailAddress(String email) {
    return email != null && ATEXT_ALPHANUMERIC.matcher(email).matches() && email.indexOf('@') >= 0;
  }

}
