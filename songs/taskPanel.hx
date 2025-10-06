import TaskPanel;

/**
 * The task panel handler holds information about who made the current-playing-song possible to exist.
 * 
 * These are the specific values it gets from the song's metadata file to show information:
 * ```json
 * {
 *     "displayName": "your readable song name",
 *     "customValues": {
 *         "artists": [
 *             {
 *                 "artist": "the artist name",
 *                 "job": "whatever they did for the song"
 *             }
 *         ]
 *     }
 * }
 * ```
 * In PlayState, the interactable tab is hardcored to spell "SONG", so you can't really modify it to say whatever you'd like.
 */
public var taskPanel:TaskPanel;

function postUIOverhaul() {
    if (!isPlayingVersus) {
        taskPanel = new TaskPanel(FlxG.height * 0.25, true, PlayState.SONG.meta.displayName, "Song", songExtraMetadata.artists);
        taskPanel.group.camera = camExtra;
        add(taskPanel.group);
    }
}

var panelTimer:FlxTimer = new FlxTimer();
function onStartSong() {
    if (taskPanel != null) {
        taskPanel.tweenIn();
        panelTimer.start((Conductor.stepCrochet / 1000) * 16 * 4, _ -> {
            taskPanel.tweenOut();
            panelTimer.destroy();
        });
    }
}

function postUpdate(elapsed:Float) {
    if (taskPanel != null && touchOverlapsComplex(taskPanel.interactiveBox.members[0], taskPanel.interactiveBox.members[0].camera)) {
        if (touchJustReleased()) {
            taskPanel.tweenVisibility();

            if (panelTimer != null && panelTimer.active) {
                panelTimer.cancel();
                panelTimer.destroy();
            }
        }
    }
}