var stepTime:Float = 0;

function postCreate() {
    // Deactivate some stuff to prevent the engine from fucking things up
    curCameraTarget = -1;
    camZooming = false;

    //camGame.fade(FlxColor.BLACK, 0);
    camGame.zoom = 0.4;
    camHUD.alpha = 0;

    camFollow.setPosition(120, -1000);
    camGame.snapToTarget();

    stepTime = (Conductor.stepCrochet / 1000);
}

function onStartSong() {
    camMovementSpeed = 1;
    camGame.fade(FlxColor.TRANSPARENT, stepTime * 32, true);
}

function moogusIntroTween() {
    snowParticles.start(false, 0.1);
    FlxTween.tween(camHUD, {alpha: 1}, stepTime * 16);
}