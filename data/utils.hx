public static var isMobile:Bool = FlxG.onMobile;
public static var fakeMobile:Bool = false;

public function resizeGame(width:Int, height:Int) {
    FlxG.initialWidth = width;
    FlxG.initialHeight = height;
    FlxG.width = width;
    FlxG.height = height;
}

public function resizeWindow(width:Int, height:Int) {
    window.resize(width, height);
}

function update(elapsed:Float) {
    if (FlxG.onMobile == true) {
        isMobile = FlxG.onMobile;
    }

    if (isMobile && !FlxG.onMobile)
        fakeMobile = true;
    else
        fakeMobile = false;
}