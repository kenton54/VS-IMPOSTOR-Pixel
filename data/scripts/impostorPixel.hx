import funkin.backend.scripting.events.NoteHitEvent;
import funkin.game.Note;
import funkin.game.StrumLine;

var noteScale:Float = 5.55;

var noteArray:Array<String> = ["left", "down", "up", "right", "center"];
var noteColor:Array<String> = ["purple", "blue", "green", "red", "white"];

var theThing:String = "impostorPixel-default";

function onNoteCreation(event) {
	event.cancel();

	var pixelNote = event.note;

	if (pixelNote.isSustainNote) {
		pixelNote.frames = Paths.getFrames("game/notes/" + theThing + "/sustains");
		pixelNote.animation.addByPrefix("hold", "sustain hold " + noteColor[event.strumID]);
		pixelNote.animation.addByPrefix("holdend", "sustain end " + noteColor[event.strumID]);
	}
	else {
		pixelNote.frames = Paths.getFrames("game/notes/" + theThing + "/notes");
		pixelNote.animation.addByPrefix("scroll", "note " + noteArray[event.strumID]);
	}
	pixelNote.scale.set(noteScale, noteScale);
	pixelNote.updateHitbox();
}

function onPostNoteCreation(event) {
	event.note.splash = theThing;
}

function onStrumCreation(event) {
	event.cancel();

	var daStrum = event.strum;

	daStrum.frames = Paths.getFrames("game/notes/" + theThing + "/strums");
	daStrum.animation.addByPrefix("static", "strum idle " + noteArray[event.strumID], 24, false);
	daStrum.animation.addByPrefix("pressed", "strum press " + noteArray[event.strumID], 12, false);
	daStrum.animation.addByPrefix("confirm", "strum hit " + noteArray[event.strumID], 24, false);

	daStrum.scale.set(noteScale, noteScale);
	daStrum.updateHitbox();

	daStrum.x -= 32;
}

// hold note covers
var coverData:Array<Dynamic> = [];
var coverGroup:FlxSpriteGroup;
public var holdCoverSkin:String = "game/covers/impostorPixel-default";
public var holdCoverColor:Array<String> = ["purple", "blue", "green", "red"];

function postPostCreate() {
	createHoldCovers();
}

function createHoldCovers() {
    coverGroup = new FlxSpriteGroup();
    coverGroup.camera = camHUD;
    add(coverGroup);

    var i:Int = 0;
    for (strumline in strumLines.members) {
        if (i > 3) i = 0;

        // dont create hold covers if the strumline doesnt have any notes
        if (strumline.notes.length < 1) break;

        for (strum in strumline.members) {
            var cover:FunkinSprite = new FunkinSprite();
            cover.frames = Paths.getFrames(holdCoverSkin);
            cover.animation.addByPrefix("hold", "cover hold " + holdCoverColor[i], 24, true);
            cover.animation.addByPrefix("end", "cover splash " + holdCoverColor[i], 24, false);
            cover.animation.play("hold");
            cover.antialiasing = false;
            cover.scale.set(noteScale, noteScale);
            cover.updateHitbox();
            cover.offset.set(-53.5, -50);
            cover.visible = false;

            cover.setPosition(strum.x + 4, strum.y - 3.55);

            coverGroup.add(cover);
            coverData.push({cover: cover});

            i++;
        }
    }
}

function onNoteHit(event) {
    coverBehaviour(event.note, event.player);
}

function onPlayerMiss(event) {
    if (!event.ghostMiss) {
        if (event.note.isSustainNote) {
            var id = event.note.noteData;
            var cover = coverData[id].cover;
            coverTimers[id].cancel();
            coverKill(cover);
        }
    }
}

var coverTimers:Array<FlxTimer> = [];
function coverBehaviour(note:Note, isPlayer:Bool) {
	var id:Int = note.noteData;

	var strumline:StrumLine = note.strumLine;
	var strum:Strum = strumline.members[id];

    if (isPlayer) id += strumLines.members[1].members.length;

    if (coverData[id] == null && coverData[id].cover == null) return;
    var cover:FunkinSprite = coverData[id].cover;

    if (note.isSustainNote) {
        cover.revive();
        cover.visible = true;
        cover.animation.play("hold");

		cover.setPosition(strum.x + 4, strum.y - 3.55);

        var delay:Float = 0.2;
        if (coverTimers[id] == null) coverTimers[id] = new FlxTimer();
        coverTimers[id].cancel();
        coverTimers[id].start(delay, _ -> {
            if (isPlayer) {
                cover.animation.play("end", true);
                cover.animation.finishCallback = _ -> {coverKill(cover);};
            }
            else
                coverKill(cover);
        });
    }
}

function coverKill(cover:FunkinSprite) {
    cover.visible = false;
    cover.kill();
}