var stepTime:Float = 0;

function postCreate() {
    // Deactivate some stuff to prevent the engine from fucking things up
    curCameraTarget = -1;
    camZooming = false;

    camGame.fade(FlxColor.BLACK, 0);
    camGame.zoom = 0.4;
    camHUD.alpha = 0;

    camMovementSpeed = 4;
    camFollow.setPosition(0, -1000);

    stepTime = (Conductor.stepCrochet / 1000);
}

function onStartSong() {
    camMovementSpeed = 1;
    camGame.fade(FlxColor.TRANSPARENT, stepTime * 32, true);
}

function moogusIntroTween() {
    FlxTween.tween(camFollow, {y: -150}, stepTime * 32, {ease: FlxEase.quadInOut});
    FlxTween.tween(camGame, {zoom: 0.6}, stepTime * 32, {ease: FlxEase.quadInOut, startDelay: stepTime * 16});
    FlxTween.tween(camHUD, {alpha: 1}, stepTime * 16, {startDelay: stepTime * 56, onStart: _ -> {
        snowParticles.start(false, 0.1);
    }});
}