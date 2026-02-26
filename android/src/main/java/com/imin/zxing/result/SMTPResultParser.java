/*
 * Copyright 2010 ZXing authors
 *

 */

package com.imin.zxing.result;

import com.imin.scan.Result;

/**
 * <p>Parses an "smtp:" URI result, whose format is not standardized but appears to be like:
 * {@code smtp[:subject[:body]]}.</p>
 *
 * @author Sean Owen
 */
public final class SMTPResultParser extends ResultParser {

  @Override
  public EmailAddressParsedResult parse(Result result) {
    String rawText = getMassagedText(result);
    if (!(rawText.startsWith("smtp:") || rawText.startsWith("SMTP:"))) {
      return null;
    }
    String emailAddress = rawText.substring(5);
    String subject = null;
    String body = null;
    int colon = emailAddress.indexOf(':');
    if (colon >= 0) {
      subject = emailAddress.substring(colon + 1);
      emailAddress = emailAddress.substring(0, colon);
      colon = subject.indexOf(':');
      if (colon >= 0) {
        body = subject.substring(colon + 1);
        subject = subject.substring(0, colon);
      }
    }
    return new EmailAddressParsedResult(new String[] {emailAddress},
                                        null,
                                        null,
                                        subject,
                                        body);
  }
}
