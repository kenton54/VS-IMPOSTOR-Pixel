public var speakers:FunkinSprite;

function postCreate() {
    speakers = new FunkinSprite(0, 0, Paths.image("characters/partners/speakers/speakers-lightsOut"));
    speakers.animation.addByPrefix("idle", "bop", 24, false);
    speakers.animation.play("idle");
    speakers.beatAnims.push({name: "idle", forced: true});
    speakers.beatInterval = 1;
    speakers.scale.set(scale.x, scale.y);
    speakers.updateHitbox();
}

var added:Bool = false;
function update(elapsed:Float) {
    if (!added) {
        added = true;
        speakers.setPosition(x - 340, y + 66);
        speakers.camera = camera;
        FlxG.state.insert(FlxG.state.members.indexOf(this), speakers);
    }

    if (alpha != speakers.alpha) speakers.alpha = alpha;
    if (visible != speakers.visible) speakers.visible = visible;
}