var transOut:Bool = false;

function create(event) {
    event.cancel();

    transOut = event.transOut;

    transitionCamera.fade(FlxColor.BLACK, 2, event.transOut ? false : true);
    new FlxTimer().start(2, _ -> {
        finish();
    });
}

function onPostFinish() {
    if (!transOut) setTransition("");
}