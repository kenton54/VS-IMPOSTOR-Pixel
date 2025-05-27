class HoldCover extends FlxSpriteGroup {
    public var glow:FlxSprite;

    public function new(style:String, color:String) {
        super(0, 0);

        setupHoldCover(style, color);
    }

    function setupHoldCover(style:String, color:String) {
        glow = new FlxSprite();
        glow.frames = Paths.getFrames("game/holdCovers/" + style);
        add(glow);

        glow.animation.onFinish.add(onAnimationFinish);
    }
}