function onEvent(sus) {
    if (sus.event.name == "Set Camera Follow Speed") {
        camMovementSpeed = sus.event.params[0];
    }
}