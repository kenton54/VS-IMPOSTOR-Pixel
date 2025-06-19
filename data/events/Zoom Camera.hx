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
        trace("[Zoom Camera] will zoom camera to value: "+actualZoom);
        if (params.duration == 0)
            camGame.zoom = actualZoom;
        else
            FlxTween.tween(camGame, {zoom: actualZoom}, (Conductor.stepCrochet / 1000) * params.duration, {ease: CoolUtil.flxeaseFromString(params.twnEase, params.twnType)});

        defaultCamZoom = actualZoom;
    }
}