function create() {
    note.frames = Paths.getSparrowAtlas('customnotes/'+PlayState_.SONG.stage.toLowerCase(), mod);
    note.colored = true;

    note.setGraphicSize(Std.int(note.width * 0.7));
	note.updateHitbox();

    if (!note.isSustainNote) {
        note.animation.addByPrefix('scroll', 'Guitar'+note.get_appearance(), 24, true);
        note.animation.play("scroll");
    } else {
        note.animation.addByPrefix('holdend', 'GuitarEnd', 24, true);
        note.animation.play("holdend");

        if (note.prevNote != null)
            if (note.prevNote.animation.curAnim != null)
                if (note.prevNote.animation.curAnim.name == "holdend") {
                    note.prevNote.animation.addByPrefix('holdpiece', 'GuitarHold', 24, true);
                    note.prevNote.animation.play("holdpiece");
                }
    }
}

function onDadHit(direction) {
    switch(direction) {
        case 0:
            dad.playAnim("singLEFT", true);
        case 1:
            dad.playAnim("singDOWN", true);
        case 2:
            dad.playAnim("singUP", true);
        case 3:
            dad.playAnim("singRIGHT", true);
    }
}

function onPlayerHit(direction) {
    switch(direction) {
        case 0:
            boyfriend.playAnim("singLEFT", true);
        case 1:
            boyfriend.playAnim("singDOWN", true);
        case 2:
            boyfriend.playAnim("singUP", true);
        case 3:
            boyfriend.playAnim("singRIGHT", true);
    }
}