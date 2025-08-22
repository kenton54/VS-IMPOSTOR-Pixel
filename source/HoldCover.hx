class HoldCover extends FunkinSprite {
    /**
     * The Strum this Hold Cover is attached to.
     * 
     * This means that it'll follow the Strum to wherever it moves to.
     */
    public var strum:Null<Strum> = null;

    /**
     * The ID of the Strum.
     */
    public var strumID:Null<Int> = null;

    /**
     * When the Hold Cover plays the ending animation in the current playing song's position.
     */
    public var endTime:Null<Float> = null;

    /**
     * Whether the Hold Cover is from a player Strum or not.
     * 
     * If it is, it will play the ending animation, otherwise it will hide immediatly.
     */
    public var fromPlayer:Null<Bool> = null;

    /**
     * Whether the Hold Cover is being held.
     * 
     * If it is, it will follow the Strum.
     */
    public var beingHeld:Bool = false;

    public function new() {
        super(0, 0);
        endTime = 0;
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

        if (StringTools.endsWith(getAnimName(), "-start") && isAnimFinished())
            playLoop();

        if (StringTools.endsWith(getAnimName(), "-end") && isAnimFinished())
            killCover();

        if (beingHeld)
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
        beingHeld = false;

        if (this.hasAnim(curAnim + "-end") && fromPlayer)
            this.playAnim(curAnim + "-end");
        else
            killCover();
    }

    public function killCover() {
        FlxG.state.remove(this);
        strum = null;
        strumID = null;
        fromPlayer = null;
        beingHeld = false;
        active = visible = false;
    }

    override public function destroy() {
        super.destroy();
        strum = null;
        strumID = null;
        endTime = null;
    }
}