package funkin.util;

import java.util.Locale;

public class LocaleUtil
{
  public static String getUserLanguage()
  {
    Locale curLocale = Locale.getDefault();
    return curLocale.getLanguage();
  }
}
