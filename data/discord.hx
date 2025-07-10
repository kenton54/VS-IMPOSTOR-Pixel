import funkin.backend.utils.DiscordUtil;
import ImpostorFlags;

function onGameOver() {
	DiscordUtil.changePresence('Game Over', PlayState.SONG.meta.displayName + " [" + PlayState.difficulty + "]");
}

function onDiscordPresenceUpdate(e) {
	var data = e.presence;

	/*
	if (data.button1Label == null)
		//data.button1Label = "";
	if (data.button1Url == null)
		//data.button1Url = "";
	*/
}

function onPlayStateUpdate() {
	DiscordUtil.changeSongPresence(
		PlayState.instance.detailsText,
		!ImpostorFlags.playingVersus ? "Playing Solo: " + PlayState.SONG.meta.displayName + " [" + PlayState.difficulty + "]" : "Competing against a Friend: " + PlayState.SONG.meta.displayName,
		PlayState.instance.inst
	);
}

function onMenuLoaded(name:String) {
    DiscordUtil.changePresenceSince("Navigating Menus", name);
}

function onEditorTreeLoaded(name:String) {
	switch(name) {
		case "Character Editor":
			DiscordUtil.changePresenceSince("Choosing a Character", null);
		case "Chart Editor":
			DiscordUtil.changePresenceSince("Choosing a Chart", null);
		case "Stage Editor":
			DiscordUtil.changePresenceSince("Choosing a Stage", null);
	}
}

function onEditorLoaded(name:String, editingThing:String) {
	switch(name) {
		case "Character Editor":
			DiscordUtil.changePresenceSince("Editing a Character", editingThing);
		case "Chart Editor":
			DiscordUtil.changePresenceSince("Editing a Chart", editingThing);
		case "Stage Editor":
			DiscordUtil.changePresenceSince("Editing a Stage", editingThing);
	}
}