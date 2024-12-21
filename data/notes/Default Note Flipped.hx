if (!PlayState.chartTestMode) {
    function onPlayerHit(noteData) {
        switch(noteData) {
            case 0:
                playBFsAnim("singRIGHT", true);
            case 1:
                playBFsAnim("singDOWN", true);
            case 2:
                playBFsAnim("singUP", true);
            case 3:
                playBFsAnim("singLEFT", true);
        }

    }
    function onDadHit(noteData) {
        switch(noteData) {
            case 0:
                playDadsAnim("singRIGHT", true);
            case 1:
                playDadsAnim("singDOWN", true);
            case 2:
                playDadsAnim("singUP", true);
            case 3:
                playDadsAnim("singLEFT", true);
        }
    }
}
