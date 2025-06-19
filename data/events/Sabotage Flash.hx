var sabotageFlash:FlxSprite;

function create() {
    sabotageFlash = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
    sabotageFlash.blend = 0;
    sabotageFlash.alpha = 0.4;
    sabotageFlash.visible = false;
    sabotageFlash.camera = camHUD;
    insert(0, sabotageFlash);
}

function onEvent(event) {
    if (event.event.name == "Sabotage Flash") {
        var params = {
            length: event.event.params[0],
            doSound: event.event.params[1]
        };

        sabotageFlash.visible = true;

        if (params.doSound)
            FlxG.sound.play(Paths.sound("sabotage"), 0.7);

        var dur:Float = (Conductor.stepCrochet / 1000) * params.length;
        new FlxTimer().start(dur, _ -> {sabotageFlash.visible = false;});
    }
}