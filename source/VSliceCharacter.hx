import StringTools;
import flixel.animation.FlxAnimation;

class VSliceCharacter extends Character {
    public var comboNoteCounts:Array<Int> = [];

    public var dropNoteCounts:Array<Int> = [];

    public function new(x:Float, y:Float, ?character:String, isPlayer:Bool = false, switchAnims:Bool = true) {
        super(x, y, character, isPlayer, switchAnims, false);

        this.comboNoteCounts = getCountAnims("combo");
        this.dropNoteCounts = getCountAnims("drop");
    }

    public function getCurrentAnimation():FlxAnimation
        return this.animation?.curAnim ?? null;

    public function hasAnimation(id:String):Bool {
        if (this.animation == null) return false;

        return this.animation.getByName(id) != null;
    }

    public function isAnimationFinished():Bool
        return this.animation?.finished ?? false;

    private function getCountAnims(prefix:String):Array<Int> {
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

        // sort numerically
        result.sort((a, b) -> a - b);
        return result;
    }

    private function playComboAnim(count:Int) {
        var animName:String = "combo" + Std.string(count);
        if (hasAnimation(animName)) {
            this.playAnim(animName, true);
        }
    }

    private function playDropAnim(count:Int) {
        var animName:Null<String> = null;
        for (cnt in dropAnimsList) {
            if (cnt >= count) {
                animName = "drop" + Std.string(count);
            }
        }
        if (animName != null) {
            this.playAnim(animName, true);
        }
    }
}