import funkin.backend.scripting.events.NoteHitEvent;

var noteScale:Float = 5.55;

var noteArray:Array<String> = ["left", "down", "up", "right", "center"];

function onNoteCreation(event) {
	event.cancel();

	var pixelNote = event.note;

	if (pixelNote.isSustainNote) {
		pixelNote.frames = Paths.getFrames("game/defaultNotes/sustains");
		pixelNote.animation.addByPrefix("hold", "hold " + noteArray[event.strumID]);
		pixelNote.animation.addByPrefix("holdend", "end " + noteArray[event.strumID]);
	}
	else {
		pixelNote.frames = Paths.getFrames("game/defaultNotes/notes");
		pixelNote.animation.addByPrefix("scroll", "note " + noteArray[event.strumID]);
	}
	pixelNote.scale.set(noteScale, noteScale);
}

function onPostNoteCreation(event) {
	event.note.splash = "impostorPixel-default";
}

function onStrumCreation(event) {
	event.cancel();
	event.__doAnimation = false;

	var daStrum = event.strum;

	daStrum.frames = Paths.getFrames("game/defaultNotes/strums");
	daStrum.animation.addByPrefix("static", "strum idle " + noteArray[event.strumID], 24, false);
	daStrum.animation.addByPrefix("pressed", "strum press " + noteArray[event.strumID], 12, false);
	daStrum.animation.addByPrefix("confirm", "strum hit " + noteArray[event.strumID], 24, false);

	daStrum.scale.set(noteScale, noteScale);
	daStrum.updateHitbox();

	daStrum.x -= 32;
}