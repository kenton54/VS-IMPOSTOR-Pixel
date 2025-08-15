import StringTools;
import flixel.animation.FlxAnimation;

class VSliceCharacter extends Character {
    /**
     * This character plays a given animation when hitting these specific combo numbers.
     */
    public var comboNoteCounts(default, null):Array<Int> = [];

    /**
     * This character plays a given animation when dropping combos larger than these numbers.
     */
    public var dropNoteCounts(default, null):Array<Int> = [];

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

    private function playComboAnim(comboCount:Int) {
        var animName:String = "combo" + Std.string(comboCount);
        if (hasAnimation(animName)) {
            this.playAnim(animName, true);
        }
    }

    private function playDropAnim(comboCount:Int) {
        var animName:Null<String> = null;

        // Chooses the combo drop animation to play.
        // If they're several animations, the highest one will be played.
        for (dropCount in dropNoteCounts) {
            if (comboCount >= dropCount) {
                animName = "drop" + Std.string(dropCount);
            }
        }
        if (animName != null) {
            this.playAnim(animName, true);
        }
    }
}