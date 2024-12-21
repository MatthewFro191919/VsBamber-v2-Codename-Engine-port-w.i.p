function updatePost(elapsed) {
    if (note.shader != null) {
        note.shader.setColors(165, 0, 76);
        note.splashColor = 0xFFA5004C;
        if (PlayState.SONG.song == "Deathbattle")
        {
            note.shader.setColors(0, 164, 255);
            note.splashColor = 0xFF00A4FF;
        }
    }
}

if (!PlayState.chartTestMode) {
    function onPlayerHit(direction:Int) {
        switch(direction) {
            case 0:
                gf.playAnim("singLEFT", true);
            case 1:
                gf.playAnim("singDOWN", true);
            case 2:
                gf.playAnim("singUP", true);
            case 3:
                gf.playAnim("singRIGHT", true);
        }
    }

    function onDadHit(direction:Int) {
        onPlayerHit(direction);
    }

    function onMiss(direction:Int) {
        health -= note.isSustainNote ? 0.03125 : 0.125;
        vocals.volume = 0;

        switch(direction) {
            case 0:
                gf.playAnim("singLEFTmiss", true);
            case 1:
                gf.playAnim("singDOWNmiss", true);
            case 2:
                gf.playAnim("singUPmiss", true);
            case 3:
                gf.playAnim("singRIGHTmiss", true);
        }
        
        PlayState.hits["Misses"]++;
        PlayState.misses++;
        PlayState.numberOfNotes++;
        PlayState.numberOfArrowNotes++;
        PlayState.songScore -= 10;
        PlayState.combo = 0;

        FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
    }
}