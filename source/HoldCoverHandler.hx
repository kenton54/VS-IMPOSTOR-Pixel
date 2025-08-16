import funkin.backend.system.Logs;
import HoldCover;

class HoldCoverHandler {
    /**
     * The group of all covers.
     * Codename doesn't support extending classes to flixel groups, so this is here.
     */
    public var group:FlxTypedGroup<HoldCover>;

    public var valid:Bool = true;

    public var style:String;

    public var animationNames:Array<Array<String>> = [];

    private var json:Dynamic;

    public function new(style:String, strumline:StrumLine) {
        this.group = new FlxTypedGroup<HoldCover>();

        this.style = style;

        try {
            this.json = Json.parse(Assets.getText(Paths.json("holdCovers/" + style)));

            for (strum in strumline.members) {
                var cover:HoldCover = createHoldCover(json.sprite);
                setupAnimations(json, cover);
                cover.strum = strum;
                cover.strumID = strum.ID;
                group.add(cover);
            }
        }
        catch(e:Dynamic) {
            Logs.error('Error loading hold covers for style "' + style + '": ' + e);
            valid = false;
        }
    }

    var _scale:Float = 1.0;
    var _alpha:Float = 1.0;
    var _antialiasing:Bool = FlxSprite.defaultAntialiasing;

    private function createHoldCover(imagePath:String):HoldCover {
        var cover:HoldCover = new HoldCover();
        cover.active = cover.visible = false;
        cover.loadSprite(Paths.image(imagePath));
        _scale = CoolUtil.getDefault(Std.parseFloat(json.scale), 1.0);
        _alpha = CoolUtil.getDefault(Std.parseFloat(json.alpha), 1.0);
        _antialiasing = CoolUtil.getDefault(Std.parseFloat(json.antialiasing), FlxSprite.defaultAntialiasing);
        return cover;
    }

    private function setupAnimations(json:Dynamic, cover:HoldCover) {
        for (strum in json.strums) {
            var id:Null<Int> = strum.id;
            if (id != null) {
                animationNames[id] = [];
                for (anim in strum.animations) {
                    if (!Reflect.hasField(anim, "name")) continue;

                    cover.addAnim(anim.name, anim.anim, CoolUtil.getDefault(Std.parseFloat(anim.fps), 24), StringTools.endsWith(anim.name, "loop"), true);
                    cover.animOffsets.set(anim.name, FlxPoint.get(anim.x, anim.y));

                    var fixedName = anim.name;
                    fixedName = StringTools.replace(fixedName, "-start", "");
                    fixedName = StringTools.replace(fixedName, "-loop", "");
                    fixedName = StringTools.replace(fixedName, "-end", "");

                    var alreadyExists:Bool = false;
                    for (animName in animationNames[id])
                        if (animName == fixedName) alreadyExists = true;

                    if (!alreadyExists)
                        animationNames[id].push(fixedName);
                }
            }
        }
    }

    public function getCoverAnim(id:Int):String {
		if (animationNames.length < 1) return null;
		id %= animationNames.length;
		var animNames = animationNames[id];
		if (animNames == null || animNames.length <= 0) return null;
		return animNames[FlxG.random.int(0, animNames.length - 1)];
	}

    public function showHoldCover(strum:Strum) {
        if (!valid) return;
        var choosenCover:HoldCover = group.members[strum.ID];

        choosenCover.strum = strum;
        choosenCover.strumID = strum.ID;

        choosenCover.scale.x = choosenCover.scale.y = _scale;
        choosenCover.alpha = _alpha;
        choosenCover.antialiasing = _antialiasing;

        choosenCover.setCoverPosition(strum);
        choosenCover.cameras = strum.lastDrawCameras;
        choosenCover.active = choosenCover.visible = true;

        choosenCover.playStart(getCoverAnim(choosenCover.strumID));

        FlxG.state.add(choosenCover);

        delay = (Conductor.stepCrochet / 1000) * 1.4;
        startCoverTimer(choosenCover, strum.strumLine.cpu == false);
    }

    public function checkNote(note:Note, isPlayer:Bool) {
        if (!valid) return;

        for (i => cover in group.members) {
            if (cover.visible && cover.active) {
                if (note.isSustainNote) {
                    startCoverTimer(cover, isPlayer);
                }
            }
        }
    }

    var coverTimers:Array<FlxTimer> = [];
    var delay:Float = 0;
    private function startCoverTimer(cover:HoldCover, isPlayer:Bool) {
        var id:Int = cover.strumID;

        if (coverTimers[id] == null) coverTimers[id] = new FlxTimer();
        coverTimers[id].cancel();
        coverTimers[id].start(delay, _ -> {
            if (isPlayer)
                cover.playEnd();
            else
                cover.killCover();
        });
    }

    public function killCover(note:Note) {
        if (!valid) return;

        for (i => cover in group.members) {
            var id:Int = cover.strumID;

            if (id != note.noteData) continue;

            if (cover.visible && cover.active) {
                if (coverTimers[id] == null) coverTimers[id].cancel();
                cover.killCover();
            }
        }
    }

    public function destroy() {
        valid = null;
        style = null;
        animationNames = null;
        json = null;
        for (timer in coverTimers) timer.destroy();
        coverTimers = null;
        group.destroy();
    }
}