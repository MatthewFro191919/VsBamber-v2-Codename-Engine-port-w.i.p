function onDadHit(noteData) {
    if (!PlayState.chartTestMode) {
        switch(noteData) {
            case 0:
                PlayState.dads[0].playAnim("singLEFT", true);
            case 1:
                PlayState.dads[0].playAnim("singDOWN", true);
            case 2:
                PlayState.dads[0].playAnim("singUP", true);
            case 3:
                PlayState.dads[0].playAnim("singRIGHT", true);
        }
    }
}