var boyfriend2Colors = [
    "Coop" => 0xFFA5004C,
];

function update(elapsed) {
    if (note.shader != null) {
        var color = new FlxColor(boyfriend2Colors[PlayState.SONG.song]);
        note.shader.setColors(color.red, color.green, color.blue);
        note.splashColor = boyfriend2Colors[PlayState.SONG.song];
    }
    
    calculateNote();
}

onDadHit = function onPlayerHit(noteData) {
    if (!PlayState.chartTestMode) {
        switch(noteData) {
            case 0:
                PlayState.boyfriends[1].playAnim("singLEFT", true);
            case 1:
                PlayState.boyfriends[1].playAnim("singDOWN", true);
            case 2:
                PlayState.boyfriends[1].playAnim("singUP", true);
            case 3:
                PlayState.boyfriends[1].playAnim("singRIGHT", true);
        }
    }
}

function onMiss(direction:Int) {
    health -= note.isSustainNote ? 0.03125 : 0.125;
    vocals.volume = 0;

    switch(direction) {
        case 0:
            PlayState.boyfriends[1].playAnim("singLEFTmiss", true);
        case 1:
            PlayState.boyfriends[1].playAnim("singDOWNmiss", true);
        case 2:
            PlayState.boyfriends[1].playAnim("singUPmiss", true);
        case 3:
            PlayState.boyfriends[1].playAnim("singRIGHTmiss", true);
    }
    
    PlayState.hits["Misses"]++;
    PlayState.misses++;
    PlayState.numberOfNotes++;
    PlayState.numberOfArrowNotes++;
    PlayState.songScore -= 10;
    PlayState.combo = 0;

    if (PlayState.gf != null)
        {
            if (PlayState.combo > 5 && PlayState.gf.animOffsets.exists('sad'))
            {
                PlayState.gf.playAnim('sad');
            }
        }

    FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
}