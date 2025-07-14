import funkin.backend.utils.DiscordUtil;
import hxdiscord_rpc.Types;
import ImpostorFlags;

function new() {}

function onDiscordPresenceUpdate(event) {
	var presence = event.presence;
}

function onMenuLoaded(name:String) {
    DiscordUtil.changePresenceSince("Navigating Menus", name);
}

function onPlayStateUpdate() {
	DiscordUtil.changeSongPresence(
		PlayState.instance.detailsText,
		!ImpostorFlags.playingVersus ? "Playing Solo: " + PlayState.SONG.meta.displayName + " [" + PlayState.difficulty + "]" : "Competing against a Friend: " + PlayState.SONG.meta.displayName,
		PlayState.instance.inst
	);
}

function onGameOver() {
	DiscordUtil.changePresence('Game Over', PlayState.SONG.meta.displayName + " [" + PlayState.difficulty + "]");
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

function destroy() {
	if (DiscordUtil.ready) {
		DiscordUtil.user.handle = null;
		DiscordUtil.user.userId = null;
		DiscordUtil.user.username = null;
		DiscordUtil.user.discriminator = null;
		DiscordUtil.user.avatar = null;
		DiscordUtil.user.globalName = null;
		DiscordUtil.user.bot = null;
		DiscordUtil.user.flags = null;
		DiscordUtil.user.premiumType = null;
	}
}