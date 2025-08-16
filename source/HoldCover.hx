class HoldCover extends FunkinSprite {
    public var strum:Null<Strum> = null;

    public var strumID:Null<Int> = null;

    public function new() {
        super(0, 0);
    }

    public function setCoverPosition(strum:Strum):Void {
        var xPos:Float = 0.0;
        var yPos:Float = 0.0;

        if (strum != null) {
            xPos = strum.x + (strum.width / 2) - (this.width / 2);
            yPos = strum.y + (strum.height / 2) - (this.height / 2);
        }

        this.setPosition(xPos, yPos);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (StringTools.endsWith(getAnimName(), "-start") && isAnimFinished()) {
            playLoop();
        }
        if (StringTools.endsWith(getAnimName(), "-end") && isAnimFinished()) {
            killCover();
        }

        this.setCoverPosition(strum);
    }

    var curAnim:String = "";

    public function playStart(anim:String) {
        curAnim = anim;

        if (this.hasAnim(anim + "-start"))
            this.playAnim(anim + "-start");
        else
            playLoop();
    }

    public function playLoop() {
        if (!this.hasAnim(curAnim + "-loop"))
            throw "Loop animation for this cover doesn't exist, it's required!";
        else
            this.playAnim(curAnim + "-loop");
    }

    public function playEnd() {
        if (this.hasAnim(curAnim + "-end"))
            this.playAnim(curAnim + "-end");
        else
            killCover();
    }

    public function killCover() {
        FlxG.state.remove(this);
        this.strum = null;
        this.strumID = null;
        this.active = this.visible = false;
    }
}