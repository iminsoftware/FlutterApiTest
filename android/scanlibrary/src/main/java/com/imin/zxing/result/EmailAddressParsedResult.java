

package com.imin.zxing.result;

/**
 * Represents a parsed result that encodes an email message including recipients, subject
 * and body text.
 *
 * @author Sean Owen
 */
public final class EmailAddressParsedResult extends ParsedResult {

  private final String[] tos;
  private final String[] ccs;
  private final String[] bccs;
  private final String subject;
  private final String body;

  EmailAddressParsedResult(String to) {
    this(new String[] {to}, null, null, null, null);
  }

  EmailAddressParsedResult(String[] tos,
                           String[] ccs,
                           String[] bccs,
                           String subject,
                           String body) {
    super(ParsedResultType.EMAIL_ADDRESS);
    this.tos = tos;
    this.ccs = ccs;
    this.bccs = bccs;
    this.subject = subject;
    this.body = body;
  }

  /**
   * @return first elements of {@link #getTos()} or {@code null} if none
   * @deprecated use {@link #getTos()}
   */
  @Deprecated
  public String getEmailAddress() {
    return tos == null || tos.length == 0 ? null : tos[0];
  }

  public String[] getTos() {
    return tos;
  }

  public String[] getCCs() {
    return ccs;
  }

  public String[] getBCCs() {
    return bccs;
  }

  public String getSubject() {
    return subject;
  }

  public String getBody() {
    return body;
  }

  /**
   * @return "mailto:"
   * @deprecated without replacement
   */
  @Deprecated
  public String getMailtoURI() {
    return "mailto:";
  }

  @Override
  public String getDisplayResult() {
    StringBuilder result = new StringBuilder(30);
    maybeAppend(tos, result);
    maybeAppend(ccs, result);
    maybeAppend(bccs, result);
    maybeAppend(subject, result);
    maybeAppend(body, result);
    return result.toString();
  }

}