import flixel.sound.FlxSound;
import funkin.backend.utils.AudioAnalyzer;
import StringTools;

public var abot:FlxSpriteGroup;
var vizGroup:FlxSpriteGroup;
var analyzer:AudioAnalyzer;
var analyzerLevelsCache:Array<Float>;
var analyzerTimeCache:Float;

var volumes:Array<Float> = [];

public var snd:Null<FlxSound> = null;

static final BAR_COUNT:Int = 7;

var knifeThreshold:Float = 25 / 100 * 2; // at 25% health

/**
 * The default state
 * its just her boping her head to the beat, nothing special.
 * special animations like combo milestones or combo drops may play in this state.
 */
final STATE_DEFAULT:Int = 0;

/**
 * Oh! the player is at low health
 * dont play the raise knife animation until he appropiate animation has finished playing
 */
final STATE_PRE_RAISE_KNIFE:Int = 1;

/**
 * the raise knife animation begun playing
 */
final STATE_RAISE_KNIFE:Int = 2;

/**
 * the knife is ready
 *
 * during this state, the animation will stay at the first frame and play the rest of the animation randomly
 * makes the blink look less periodic
 */
final STATE_READY_KNIFE:Int = 3;

/**
 * the player is no longer at low health so the knife gets put away
 * after this state, it will go back to the default state
 */
final STATE_LOWER_KNIFE:Int = 4;

var neneCurrentState:Int = STATE_DEFAULT;

final MIN_BLINK_DELAY:Int = 3;
final MAX_BLINK_DELAY:Int = 7;
var blinkCountdown:Int = MIN_BLINK_DELAY;

function create() {
    abot = new FlxSpriteGroup();

    var abotMain:FunkinSprite = new FunkinSprite(0, 0, Paths.image("characters/partners/speakers/abot/abot"));
    abotMain.animation.addByPrefix("idle", "abot bop", 24, false);
    //abotMain.animation.addByPrefix("flash", "flash", 24, false);
    abotMain.animation.play("idle");
    abotMain.beatAnims.push({name: "idle", forced: true});
    abotMain.beatInterval = 1;
    abotMain.scale.set(10, 10);
    abotMain.updateHitbox();

    var abotBG:FlxSprite = new FlxSprite(abotMain.x + 240, abotMain.y + 60).loadGraphic(Paths.image("characters/partners/speakers/abot/bg"));
    abotBG.scale.set(10, 10);
    abotBG.updateHitbox();

    var abotHead:FunkinSprite = new FunkinSprite(abotMain.x, abotMain.y, Paths.image("characters/partners/speakers/abot/abotHead"));
    abotHead.animation.addByPrefix("idle left", "abot head left idle", 24, false);
    abotHead.animation.addByPrefix("trans left", "abot head left trans", 24, false);
    abotHead.animation.addByPrefix("idle right", "abot head right idle", 24, false);
    abotHead.animation.addByPrefix("trans right", "abot head right trans", 24, false);
    abotHead.animation.play("idle right");
    abotHead.scale.set(10, 10);
    abotHead.updateHitbox();

    abot.add(abotHead);
    abot.add(abotBG);

    vizGroup = new FlxSpriteGroup(abotBG.x + 147, abotBG.y + 102);
    abot.add(vizGroup);

    for (index in 1...BAR_COUNT + 1) {
        var viz:FunkinSprite = new FunkinSprite();
        viz.frames = Paths.getFrames("characters/partners/speakers/abot/abotViz");
        viz.antialiasing = false;
        viz.scale.set(abotMain.scale.x, abotMain.scale.y);
        vizGroup.add(viz);

        var visStr = 'abot viz ';
        viz.animation.addByPrefix('VIZ', visStr + Std.string(index), 0);
        viz.animation.play('VIZ', false, false, 0);

        //viz.visible = false;
    }

    abot.add(abotMain);

    this.animation.finishCallback = function(name:String) {
        transitionState();
    };
}

function onStartSong() {
    analyzer = new AudioAnalyzer(FlxG.sound.music, 256);
}

var added:Bool = false;
function update(elapsed:Float) {
    if (!added) {
        added = true;
        abot.setPosition(this.x - 420, this.y + 66);
        abot.forEach(function(spr) {
            if (spr is FlxSpriteGroup) {
                spr.forEach(function(viz) {
                    viz.camera = this.camera;
                });
            }
            else
                spr.camera = this.camera;
        });
        FlxG.state.insert(FlxG.state.members.indexOf(this), abot);
    }

    abot.forEach(function(botPart) {
        if (this.alpha != botPart.alpha) botPart.alpha = this.alpha;
        if (this.visible != botPart.visible) botPart.visible = this.visible;
    });

    transitionState();

    updateFFT();
}

function updateFFT() {
	if (analyzer != null && FlxG.sound.music.playing) {
		var time = FlxG.sound.music.time;
		if (analyzerTimeCache != time)
			analyzerLevelsCache = analyzer.getLevels(analyzerTimeCache = time, FlxG.sound.music.calcTransformVolume(), vizGroup.group.members.length, analyzerLevelsCache, CoolUtil.getFPSRatio(0.4), -65, -10, 500, 20000);
	}
	else {
		if (analyzerLevelsCache == null) analyzerLevelsCache = [];
		analyzerLevelsCache.resize(vizGroup.group.members.length);
	}

	for (i in 0...analyzerLevelsCache.length) {
		var animFrame:Int = CoolUtil.bound(Math.round(analyzerLevelsCache[i] * 6), 0, 6);
		if (vizGroup.group.members[i].visible = animFrame > 0) {
			vizGroup.group.members[i].animation.curAnim.curFrame = 5 - (animFrame - 1);
		}
	}
}

function onDance(event) {
    event.cancel();
}

function beatHit(curBeat:Int) {
    if (danceOnBeat && (curBeat + beatOffset) % beatInterval == 0 && !__lockAnimThisFrame)
		attemptDance();
}

function attemptDance() {
    switch(lastAnimContext) {
        case "SING" | "MISS":
            if (lastHit + (Conductor.stepCrochet * holdTime) < Conductor.songPosition)
                ddance();
        case "DANCE":
            ddance();
        case "LOCK":
            if (getAnimName() == null)
                ddance();
        default:
            if (getAnimName() == null || isAnimFinished())
                ddance();
    }
}

var ddanced:Bool = false;
function ddance() {
    if (neneCurrentState != STATE_DEFAULT) {
        switch(neneCurrentState) {
            case STATE_PRE_RAISE_KNIFE:
                this.playAnim("danceLeft");
                ddanced = false;
            case STATE_READY_KNIFE:
                if (blinkCountdown == 0) {
                    this.playAnim("knife idle");
                    blinkCountdown = FlxG.random.int(MIN_BLINK_DELAY, MAX_BLINK_DELAY);
                }
                else
                    blinkCountdown--;
            default:
        }
    }
    else
        playAnim(((ddanced = !ddanced) ? 'danceLeft' : 'danceRight') + idleSuffix, true, "DANCE");
}

function onPlayAnim(event) {
    if (event.animName == "shock") {
        abot.members[0].playAnim("flash", true);
        abot.members[0].animation.finishCallback = _ -> {
            abot.members[0].playAnim("idle", true);
            abot.members[0].animation.finishCallback = null;
        };
    }
}

function transitionState() {
    switch(neneCurrentState) {
        case STATE_DEFAULT:
            if (PlayState.instance != null && PlayState.instance.health <= knifeThreshold)
                neneCurrentState = STATE_PRE_RAISE_KNIFE;
            else
                neneCurrentState = STATE_DEFAULT;
        case STATE_PRE_RAISE_KNIFE:
            if (PlayState.instance != null && PlayState.instance.health > knifeThreshold)
                neneCurrentState = STATE_DEFAULT;
            else if (isAnimFinished()) {
                this.playAnim("knife raise");
                neneCurrentState = STATE_RAISE_KNIFE;
            }
        case STATE_RAISE_KNIFE:
            if (isAnimFinished())
                neneCurrentState = STATE_READY_KNIFE;
        case STATE_READY_KNIFE:
            if (PlayState.instance != null && PlayState.instance.health > knifeThreshold) {
                neneCurrentState = STATE_LOWER_KNIFE;
                this.playAnim("knife lower");
            }
        case STATE_LOWER_KNIFE:
            if (isAnimFinished())
                neneCurrentState = STATE_DEFAULT;
        default:
            neneCurrentState = STATE_DEFAULT;
    }
}

function cameraPositionChange(position:FlxPoint) {
    trace(position);
    if (position.x > abot.members[2].x)
        changeABotLook(true);
    else if (position.x < abot.members[2].x)
        changeABotLook(false);
}

function changeABotLook(right:Bool) {
    var side:String = right ? "right" : "left";
    trace("abot is looking " + side, abot.members[0].animation.getNameList());
    abot.members[0].playAnim("trans " + side);
    abot.members[0].animation.finishCallback = _ -> {
        abot.members[0].playAnim("idle " + side);
        abot.members[0].animation.finishCallback = null;
    };
}