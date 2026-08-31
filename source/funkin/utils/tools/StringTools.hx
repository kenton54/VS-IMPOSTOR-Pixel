package funkin.utils.tools;

class StringTools
{
  public inline static function remove(s:String, value:String):String
  {
    return s.contains(value) ? s.substring(0, s.indexOf(value)) + s.substring(s.indexOf(value) + value.length - 1) : s;
  }
}
