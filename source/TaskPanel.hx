class TaskPanel {
    public var group:FlxSpriteGroup;

    public var interactiveBox:FlxSpriteGroup;

    public var label:String;

    public var purpose:String;

    public var tasks:Array<Dynamic> = [];

    public var visible:Bool;

    public function new(y:Float, startOffscreen:Bool, label:String, purpose:String, ?tasks:Array<Dynamic/*Artist*/>) {
        group = new FlxSpriteGroup(0, y);

        if (tasks == null) tasks = [];

        this.label = label;
        this.purpose = purpose;
        this.tasks = tasks;

        var boxLength:Float = 0;
        var box:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
        box.alpha = 0.5;
        group.add(box);

        var boxPos:Float = 8;
        var boxLabelTxt:FunkinText = new FunkinText(boxPos, boxPos, 0, this.label, 36);
        boxLabelTxt.font = Paths.font("pixeloidsans.ttf");
        boxLabelTxt.borderSize = 3;
        group.add(boxLabelTxt);

        boxLength = boxPos * 2 + boxLabelTxt.width;

        var finalLength:Float = boxPos + boxLabelTxt.height;
        if (this.tasks.length > 0) {
            for (artist in this.tasks) {
                var artistAndJob:String = artist.job + ": " + artist.artist;
                var artistTxt:FunkinText = new FunkinText(boxPos, finalLength, 0, artistAndJob, 24);
                artistTxt.font = Paths.font("pixeloidsans.ttf");
                artistTxt.borderSize = 2.2;
                group.add(artistTxt);

                if ((artistTxt.width + boxPos * 2) > boxLength)
                    boxLength = boxPos * 2 + artistTxt.width;

                finalLength += artistTxt.height;
            }
        }

        box.setGraphicSize(boxLength, finalLength + boxPos);
        box.updateHitbox();

        group.x = startOffscreen ? -box.width : 0;

        interactiveBox = new FlxSpriteGroup(box.width);
        group.add(interactiveBox);

        var purposeBox:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
        purposeBox.alpha = box.alpha;
        interactiveBox.add(purposeBox);

        var purposeTxt:FunkinText = new FunkinText(boxPos, boxPos, 24, this.purpose.toUpperCase(), 24);
        purposeTxt.font = Paths.font("pixeloidsans.ttf");
        purposeTxt.borderSize = 2;
        purposeTxt.textField.__textFormat.leading = -6;
        interactiveBox.add(purposeTxt);

        purposeBox.setGraphicSize(purposeTxt.width + boxPos * 2, purposeTxt.height + boxPos * 2);
        purposeBox.updateHitbox();

        visible = !startOffscreen;
    }

    var _tweeningIn:Bool = false;
    public function tweenIn() {
        if (_tweeningIn || visible) return;

        _tweeningIn = true;
        _tweeningOut = false;
        visible = true;

        FlxTween.cancelTweensOf(group);
        FlxTween.tween(group, {x: 0}, 1, {ease: FlxEase.cubeInOut, onComplete: _ -> {
            _tweeningIn = false;
        }});
    }

    var _tweeningOut:Bool = false;
    public function tweenOut() {
        if (_tweeningOut || !visible) return;

        _tweeningIn = false;
        _tweeningOut = true;
        visible = false;

        FlxTween.cancelTweensOf(group);
        FlxTween.tween(group, {x: -group.members[0].width}, 1, {ease: FlxEase.cubeInOut, onComplete: _ -> {
            _tweeningOut = false;
        }});
    }

    public function tweenVisibility()
        visible ? tweenOut() : tweenIn();
}

/*
typedef Artist = {
    var artist:String;
    var job:String;
}
*/