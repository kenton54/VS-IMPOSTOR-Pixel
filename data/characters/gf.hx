public var speakers:FunkinSprite;

function create() {
    speakers = new FunkinSprite(0, 0, Paths.image("characters/partners/speakers/speakers-normal"));
    speakers.animation.addByPrefix("idle", "bop", 12, false);
    var a = {name: "idle", forced: true};
    speakers.beatAnims.push(a);
    speakers.beatInterval = 1;
    speakers.scale.set(this.scale.x, this.scale.y);
    speakers.updateHitbox();
}

var added:Bool = false;
function update(elapsed:Float) {
    if (!added) {
        added = true;
        speakers.setPosition(this.x - 340, this.y - 4);
        FlxG.state.insert(FlxG.state.members.indexOf(this), speakers);
    }

    //speakers.shader = this.shader;
}