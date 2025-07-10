var stepTime:Float = 0;

function create() {
    if (curStage == "Polus Lab (Outside)")
        songUsesLightsSabotage = true;
}

function postCreate() {
    camZooming = false;

    //camGame.fade(FlxColor.BLACK, 0);
    camGame.zoom = 0.4;
    camHUD.alpha = 0;

    camFollow.setPosition(130, -1800);
    camGame.snapToTarget();

    stepTime = (Conductor.stepCrochet / 1000);
}

function onStartSong() {
    camGame.fade(FlxColor.TRANSPARENT, 1, true);
}

function moogusIntroTween() {
    if (curStage == "Polus Lab (Outside)")
        snowParticles.start(false, 0.1);
    FlxTween.tween(camHUD, {alpha: 1}, stepTime * 16);
}

function killCrewmateBesideBF() {
    if (curStage == "Polus Lab (Outside)") {
        dad.playAnim("shoot-front", true);
        boyfriend.playAnim("shock-front", true);
        polus1Flash();
    }
}

function killCrewmatePassingBy() {
    if (curStage == "Polus Lab (Outside)") {
        dad.playAnim("shoot-camera", true);
        boyfriend.playAnim("shock-camera", true);
        polus1Flash();
    }
}

function lightsOut() {
    if (curStage == "Polus Lab (Outside)")
        polus1SabotageLights();
}

function lightsBack() {
    if (curStage == "Polus Lab (Outside)")
        polus1FixLights();
}