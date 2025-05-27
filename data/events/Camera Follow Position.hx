function onEvent(sus) {
    if (sus.event.name == "Camera Follow Position") {
        curCameraTarget = -1;
        camFollow.setPosition(sus.event.params[0], sus.event.params[1]);
    }
}