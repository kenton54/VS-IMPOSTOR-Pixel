import StringTools;

public var speakers:FunkinSprite;

var comboAnimsList:Array<Int> = [];
var dropAnimsList:Array<Int> = [];

function create() {
    speakers = new FunkinSprite(0, 0, Paths.image("characters/partners/speakers/speakers"));
    speakers.animation.addByPrefix("idle", "bop", 24, false);
    speakers.animation.addByPrefix("flash", "flash", 24, false);
    speakers.animation.play("idle");
    speakers.beatAnims.push({name: "idle", forced: true});
    speakers.beatInterval = 1;
    speakers.scale.set(this.scale.x, this.scale.y);
    speakers.updateHitbox();

    comboAnimsList = getCountAnims("combo");
    dropAnimsList = getCountAnims("drop");
}

function getCountAnims(prefix:String):Array<Int> {
    var result:Array<Int> = [];
    var anims:Array<String> = this.animation.getNameList();
    for (anim in anims) {
        if (StringTools.startsWith(anim, prefix)) {
            var comboNum:Int = Std.parseInt(anim.substring(prefix.length));
            if (comboNum != null) {
                result.push(comboNum);
            }
        }
    }
    result.sort((a, b) -> a - b);
    return result;
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

function onPlayAnim(event) {
    if (event.animName == "shock") {
        speakers.playAnim("flash", true);
        speakers.animation.finishCallback = _ -> {
            speakers.playAnim("idle", true);
            speakers.animation.finishCallback = null;
        };
    }
}

function playComboAnim(count:Int) {
    var animName:String = "combo" + count;
    if (this.animation.exists(animName)) {
        this.playAnim(animName, true);
    }
}

function playComboDropAnim(count:Int) {
    var animName:Null<String> = null;
    for (cnt in dropAnimsList) {
        if (cnt >= count) {
            animName = "drop" + count;
        }
    }
    if (animName != null) {
        this.playAnim(animName, true);
    }
}