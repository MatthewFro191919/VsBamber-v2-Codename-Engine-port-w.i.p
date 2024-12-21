import flixel.util.FlxAxes;

function create() {
    note.frames = Paths.getSparrowAtlas('customnotes/'+PlayState_.SONG.stage.toLowerCase(), mod);
    note.colored = true;

    note.setGraphicSize(Std.int(note.width * 0.7));
	note.updateHitbox();

    note.animation.addByPrefix('scroll', 'Beatbox'+note.get_appearance(), 24, true);
    note.animation.play("scroll");
}

if (!PlayState.chartTestMode) {
	function onPlayerHit(noteData) {
        switch(noteData) {
            case 0:
                playBFsAnim("beatboxLEFT", true);
            case 1:
                playBFsAnim("beatboxDOWN", true);
            case 2:
                playBFsAnim("beatboxUP", true);
            case 3:
                playBFsAnim("beatboxRIGHT", true);
        }

    }
    function onDadHit(noteData) {
        switch(noteData) {
            case 0:
                playDadsAnim("beatboxLEFT", true);
            case 1:
                playDadsAnim("beatboxDOWN", true);
            case 2:
                playDadsAnim("beatboxUP", true);
            case 3:
                playDadsAnim("beatboxRIGHT", true);
        }
    }
}