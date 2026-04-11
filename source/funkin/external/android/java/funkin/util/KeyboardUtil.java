package funkin.util;

import org.haxe.extension.Extension;

public class KeyboardUtil
{
  public static boolean isKeyboardConnected()
  {
    if (Extension.mainContext == null) return false;

    return Extension.mainContext.getResources().getConfiguration().keyboard > 1;
  }
}
