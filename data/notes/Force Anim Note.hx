function onNoteCreation(event) {
    if (event.note.noteType == "Force Anim Note")
        event.note.extra.set("forceAnim", true);
}