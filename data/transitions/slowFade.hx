function create(event) {
    transitionCamera.fade(FlxColor.BLACK, 2, event.transOut ? false : true);
    new FlxTimer().start(2, _ -> {
        finish();
    });
}