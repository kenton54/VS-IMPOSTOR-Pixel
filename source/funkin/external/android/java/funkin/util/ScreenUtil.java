package funkin.util;

import android.graphics.Rect;
import android.view.DisplayCutout;
import android.view.WindowInsets;

import java.util.List;

import org.haxe.extension.Extension;

public class ScreenUtil
{
  public static Rect[] getCutoutDimentions()
  {
    if (Extension.mainActivity != null)
    {
      WindowInsets insets = Extension.mainActivity.getWindow().getDecorView().getRootWindowInsets();

      if (insets != null)
      {
        DisplayCutout cutout = insets.getDisplayCutout();

        if (cutout != null)
        {
          List<Rect> boundingRects = cutout.getBoundingRects();

          if (boundingRects != null && !boundingRects.isEmpty())
            return boundingRects.toArray(new Rect[0]);
        }
      }
    }

    return new Rect[0];
  }
}
