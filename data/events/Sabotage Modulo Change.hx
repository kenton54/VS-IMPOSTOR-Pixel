var interval:Int = 0;
var onStep:Bool = false;
var shouldPlaySound:Bool = false;

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
    if (event.event.name == "Sabotage Modulo Change") {
        var params = {
            modulo: event.event.params[0],
            step: event.event.params[1],
            doSound: event.event.params[2]
        };

        interval = params.modulo;
        onStep = params.step;
        shouldPlaySound = params.doSound;
    }
}

function beatHit(curBeat:Int) {
    if (curBeat % interval == 0 && !onStep) {
        sabotageFlash.visible = !sabotageFlash.visible;
        if (sabotageFlash.visible)
            if (shouldPlaySound) playSound("sabotage", 0.7);
    }
}

function stepHit(curStep:Int) {
    if (curStep % interval == 0 && onStep) {
        sabotageFlash.visible = !sabotageFlash.visible;
        if (sabotageFlash.visible)
            if (shouldPlaySound) playSound("sabotage", 0.7);
    }
}