function onEvent(event) {
    if (event.event.name == "Zoom Camera") {
        var params = {
            zoomVal: event.event.params[0],
            duration: event.event.params[1],
            twnEase: event.event.params[2],
            twnType: event.event.params[3],
        }

        FlxTween.cancelTweensOf(camGame, ["zoom"]);
        if (params.duration == 0)
            camGame.zoom = params.zoomVal;
        else
            FlxTween.tween(camGame, {zoom: params.zoomVal}, (Conductor.stepCrochet / 1000) * params.duration, {ease: CoolUtil.flxeaseFromString(params.twnEase, params.twnType)});

        defaultCamZoom = params.zoomVal;
    }
}