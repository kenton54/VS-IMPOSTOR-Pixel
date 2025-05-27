function onEvent(sus) {
    if (sus.event.name == "Zoom Camera") {
        defaultCamZoom = sus.event.params[0];
    }
}