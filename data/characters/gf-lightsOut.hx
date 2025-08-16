public var speakers:FunkinSprite;

function create() {
    speakers = new FunkinSprite(0, 0, Paths.image("characters/partners/speakers/speakers-lightsOut"));
    speakers.animation.addByPrefix("idle", "bop", 24, false);
    speakers.animation.play("idle");
    speakers.beatAnims.push({name: "idle", forced: true});
    speakers.beatInterval = 1;
    speakers.scale.set(this.scale.x, this.scale.y);
    speakers.updateHitbox();
}

var added:Bool = false;
function update(elapsed:Float) {
    if (!added) {
        added = true;
        speakers.setPosition(this.x - 340, this.y + 66);
        speakers.camera = this.camera;
        FlxG.state.insert(FlxG.state.members.indexOf(this), speakers);
    }

    if (this.alpha != speakers.alpha) speakers.alpha = this.alpha;
    if (this.visible != speakers.visible) speakers.visible = this.visible;
}