import funkin.backend.system.Logs;
import HoldCover;
import Xml;

class HoldCoverHandler {
    /**
     * The group of all covers.
     * 
     * Codename doesn't support extending classes to flixel groups, so this is here.
     */
    public var group:FlxTypedGroup<HoldCover>;

    /**
     * Whether this handler is allowed to use or not.
     * 
     * If it isn't, that means it had errors during the creation process.
     */
    public var valid:Bool = true;

    /**
     * The style of the Hold Covers.
     */
    public var style:String;

    public var animationNames:Array<Array<String>> = [];

    private var xml:Xml;

    public function new(style:String, strumline:StrumLine) {
        this.group = new FlxTypedGroup<HoldCover>();

        this.style = style;

        try {
            this.xml = Xml.parse(Assets.getText(Paths.xml("holdCovers/" + style))).firstElement();

            for (strum in strumline.members) {
                var cover:HoldCover = createHoldCover(xml.get("sprite"));
                setupAnimations(xml, cover);
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
    var _antialiasing:Bool = FlxSprite.defaultAntialiasing;

    private function createHoldCover(imagePath:String):HoldCover {
        var cover:HoldCover = new HoldCover();
        cover.active = cover.visible = false;
        cover.loadSprite(Paths.image(imagePath));
        _scale = CoolUtil.getDefault(Std.parseFloat(xml.get("scale")), 1.0);
        _antialiasing = CoolUtil.getDefault(Std.parseFloat(xml.get("antialiasing")), FlxSprite.defaultAntialiasing);
        return cover;
    }

    private function setupAnimations(xml:Xml, cover:HoldCover) {
        for (strum in xml.elementsNamed("strum")) {
            var id:Null<Int> = strum.get("id");
            if (id != null) {
                animationNames[id] = [];
                for (anim in strum.elementsNamed("anim")) {
                    if (!anim.exists("name")) continue;

                    cover.addAnim(anim.get("name"), anim.get("anim"), CoolUtil.getDefault(Std.parseFloat(anim.get("fps")), 24), StringTools.endsWith(anim.get("name"), "loop"), true);
                    cover.animOffsets.set(anim.get("name"), FlxPoint.get(anim.get("x"), anim.get("y")));

                    var fixedName = anim.get("name");
                    fixedName = StringTools.replace(fixedName, "-start", "");
                    fixedName = StringTools.replace(fixedName, "-loop", "");
                    fixedName = StringTools.replace(fixedName, "-end", "");

                    CoolUtil.pushOnce(animationNames[id], fixedName);
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

    public function showHoldCover(strum:Strum, fromPlayer:Bool, length:Float) {
        if (!valid) return;
        var choosenCover:HoldCover = group.members[strum.ID];

        choosenCover.strum = strum;
        choosenCover.strumID = strum.ID;
        choosenCover.endTime = length;
        choosenCover.fromPlayer = fromPlayer;

        choosenCover.scale.x = choosenCover.scale.y = _scale;
        choosenCover.antialiasing = _antialiasing;

        choosenCover.setCoverPosition(strum);
        choosenCover.cameras = strum.lastDrawCameras;
        choosenCover.active = choosenCover.beingHeld = choosenCover.visible = true;

        choosenCover.playStart(getCoverAnim(choosenCover.strumID));

        FlxG.state.add(choosenCover);
    }

    public function destroy() {
        valid = null;
        style = null;
        animationNames = null;
        xml = null;
        coverTimers = null;
        group.destroy();
    }
}