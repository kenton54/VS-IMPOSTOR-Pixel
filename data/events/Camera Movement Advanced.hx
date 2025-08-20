import funkin.backend.scripting.EventManager;
import funkin.backend.scripting.events.CamMoveEvent;

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
            var camPoint:FlxPoint = FlxPoint.get(fullXpos, fullYpos);
            scripts.call("onNewCameraMove", [camPoint, strumLines.members[params.target], position.amount]);
        }
    }
    if (sus.event.name == "Camera Movement") {
        curCameraTarget = -1;
        var position:CamPosData = getStrumlineCamPos(sus.event.params[0]);
        FlxG.camera.followLerp = 0.04;
        camFollow.setPosition(position.pos.x, position.pos.y);
        scripts.call("onNewCameraMove", [position.pos, strumLines.members[params.target], position.amount]);
    }
}