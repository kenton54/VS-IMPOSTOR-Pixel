function onEvent(sus) {
    if (sus.event.name == "Camera Movement Advanced") {
        var params = {
            target: sus.event.params[0],
            xOffset: sus.event.params[1],
            yOffset: sus.event.params[2],
            duration: sus.event.params[3],
            twnEase: sus.event.params[4],
            twnType: sus.event.params[5]
        }
        var tween = eventsTween.get("cameraMovement");
        if (tween != null) {
            if (tween.onComplete != null) tween.onComplete(tween);
            tween.cancel();
        }

        curCameraTarget = -1;
        var position:CamPosData = getStrumlineCamPos(params.target);

        if (position.amount > 0) {
            var fullXpos:Float = position.pos.x + params.xOffset;
            var fullYpos:Float = position.pos.y + params.yOffset;

            if (params.twnEase == "classic") {
                camFollow.setPosition(fullXpos, fullYpos);

                if (params.duration == 0)
                    camGame.snapToTarget();
            }
            else {
                camFollow.setPosition(fullXpos, fullYpos);
                if (params.duration == 0)
                    camGame.snapToTarget();
                else {
                    var oldFollow:Bool = FlxG.camera.followEnabled;
                    FlxG.camera.followEnabled = false;

                    eventsTween.set("cameraMovement", FlxTween.tween(FlxG.camera.scroll, {x: fullXpos - FlxG.camera.width * 0.5, y: fullYpos - FlxG.camera.height * 0.5}, (Conductor.stepCrochet / 1000) * params.duration, {
                        ease: CoolUtil.flxeaseFromString(params.twnEase, params.twnType),
                        onComplete: _ -> {
                            FlxG.camera.followEnabled = oldFollow;
                        }
                    }));
                }
            }
            var camPoint:FlxPoint = FlxPoint.get(fullXpos, fullYpos);
            scripts.call("onNewCameraMove", [camPoint, strumLines.members[params.target], position.amount]);
        }
    }
    if (sus.event.name == "Camera Movement") {
        curCameraTarget = -1;
        var position:CamPosData = getStrumlineCamPos(sus.event.params[0]);
        camFollow.setPosition(position.pos.x, position.pos.y);
        scripts.call("onNewCameraMove", [position.pos, strumLines.members[sus.event.params[0]], position.amount]);
    }
}