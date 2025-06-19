function onEvent(sus) {
    if (sus.event.name == "Camera Movement Advanced") {
        curCameraTarget = -1;
        var params = {
            target: sus.event.params[0],
            xOffset: sus.event.params[1],
            yOffset: sus.event.params[2],
            duration: sus.event.params[3],
            twnEase: sus.event.params[4],
            twnType: sus.event.params[5]
        }
        FlxTween.cancelTweensOf(camFollow, ["x", "y"]);
        var position:CamPosData = getStrumlineCamPos(params.target);
        if (position.amount > 0) {
            var fullXpos:Float = position.pos.x + params.xOffset;
            var fullYpos:Float = position.pos.y + params.yOffset;
            if (params.twnEase == "classic") {
                FlxG.camera.followLerp = 0.04;
                camFollow.setPosition(fullXpos, fullYpos);
                if (params.duration == 0) camGame.snapToTarget();
            }
            else {
                FlxG.camera.followLerp = 1;
                if (params.duration == 0) {
                    camFollow.setPosition(fullXpos, fullYpos);
                    camGame.snapToTarget();
                }
                else {
                    FlxTween.tween(camFollow, {x: fullXpos, y: fullYpos}, (Conductor.stepCrochet / 1000) * params.duration, {ease: CoolUtil.flxeaseFromString(params.twnEase, params.twnType)});
                }
            }
        }
    }
}