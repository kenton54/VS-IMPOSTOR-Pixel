var transOut:Bool = false;

function create(event) {
    event.cancel();

    transOut = event.transOut;

    var transDur:Float = FlxG.save.data.impPixelFastMenus ? 0.125 : 0.25;
    transitionCamera.fade(FlxColor.BLACK, transDur, !transOut);
    new FlxTimer().start(transDur, _ -> {
        finish();
    });
}

function onPostFinish() {
    if (!transOut) setTransition("");
}