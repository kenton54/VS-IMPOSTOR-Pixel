import flixel.util.FlxStringUtil;
import funkin.backend.utils.DiscordUtil;
import hxdiscord_rpc.Types as DiscordTypes;

function new() {}

function onDiscordPresenceUpdate(event) {
	var presence = event.presence;

	presence.partyId = 1392684759658008758;
	presence.partySize = (PlayState.instance != null && isPlayingVersus) ? 2 : 1;
	presence.partyMax = 2;
	presence.partyPrivacy = 1;

	presence.button1Label = "Play the Mod";
	presence.button1Url = "https://gamebanana.com/mods/506768";

	presence.activityType = ActivityType.Playing;
}

function onMenuLoaded(name:String) {
    DiscordUtil.changePresenceSince("Navigating Menus", name);
}

function onPlayStateUpdate() {
	DiscordUtil.changeSongPresence(
		PlayState.instance.detailsText,
		(isPlayingVersus ? "1v1 Versus: " : "Playing: ") + PlayState.SONG.meta.displayName + " [" + FlxStringUtil.toTitleCase(PlayState.difficulty) + "]",
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
		case "Week Selector":
			DiscordUtil.changePresenceSince("Choosing a Week", null);
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