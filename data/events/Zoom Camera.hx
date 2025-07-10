var stageDefCamZoom:Float = 0;

function create() {
    stageDefCamZoom = defaultCamZoom;
}

function onEvent(event) {
    if (event.event.name == "Zoom Camera") {
        var params = {
            zoomVal: event.event.params[0],
            duration: event.event.params[1],
            twnEase: event.event.params[2],
            twnType: event.event.params[3],
        }
        FlxTween.cancelTweensOf(camGame, ["zoom"]);

        var actualZoom:Float = stageDefCamZoom + (params.zoomVal - 1.0);
        var easing:FlxEase = CoolUtil.flxeaseFromString(params.twnEase, params.twnType);
        var duration:Float = (Conductor.stepCrochet / 1000) * params.duration;
        trace("[Zoom Camera] zoom: "+Std.string(actualZoom)+", easing: "+Std.string(easing)+", duration: "+Std.string(duration)+" seconds ("+params.duration+" steps)");

        if (duration == 0)
            camGame.zoom = actualZoom;
        else
            FlxTween.tween(camGame, {zoom: actualZoom}, duration, {ease: CoolUtil.flxeaseFromString(params.twnEase, params.twnType)});

        defaultCamZoom = actualZoom;
    }
}