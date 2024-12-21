
import("Date");

// there's nothing here, its handled via source code
var now = Date.now();
if (now.getMonth() == 3 && now.getDate() == 1 && PlayState.song.keyNumber == 4) {
    trace("April fools!");
    var oldGenerate = generateStaticArrow;
    var oldCreate = create;
    var oldPlayerHit = onPlayerHit;
    var oldDadHit = onDadHit;
    
    function create() {
        if (note.noteData % 4 == 1) {
            var e = Math.floor(note.noteData / 4) * 4;
            note.noteData = e + 2;
            oldCreate();
            note.noteData = e + 1;
        } else if (note.noteData % 4 == 2) {
            var e = Math.floor(note.noteData / 4) * 4;
            note.noteData = e + 1;
            oldCreate();
            note.noteData = e + 2;
        } else {
            oldCreate();
        }
    }
    
    function generateStaticArrow(arrow, i, player) {
        if (i == 1) oldGenerate(arrow, 2, player);
        else if (i == 2) oldGenerate(arrow, 1, player);
        else oldGenerate(arrow, i, player);
    }
    
    function onPlayerHit(data) {
        if (data % 4 == 1) characterAnim(boyfriends[0], 2);
        else if (data % 4 == 2) characterAnim(boyfriends[0], 1);
        else characterAnim(boyfriends[0], data);
    }
    
    function onDadHit(data) {
        if (data % 4 == 1) characterAnim(dads[0], 2);
        else if (data % 4 == 2) characterAnim(dads[0], 1);
        else characterAnim(dads[0], data);
    }
} else {
    function onPlayerHit(data) {
        characterAnim(boyfriends[0], data);
    }
    
    function onDadHit(data) {
        characterAnim(dads[0], data);
    }
}

function characterAnim(character, data) {
    switch(data) {
        case 0:
            character.playAnim("singLEFT", true);
        case 1:
            character.playAnim("singDOWN", true);
        case 2:
            character.playAnim("singUP", true);
        case 3:
            character.playAnim("singRIGHT", true);
    }
}

function onMiss(direction:Int) {
    health -= note.isSustainNote ? 0.03125 : 0.125;
    vocals.volume = 0;
    switch(direction) {
        case 0:
            PlayState.boyfriends[0].playAnim("singLEFTmiss", true);
        case 1:
            PlayState.boyfriends[0].playAnim("singDOWNmiss", true);
        case 2:
            PlayState.boyfriends[0].playAnim("singUPmiss", true);
        case 3:
            PlayState.boyfriends[0].playAnim("singRIGHTmiss", true);
    }

    if (PlayState.gf != null)
        {
            if (PlayState.combo > 5 && PlayState.gf.animOffsets.exists('sad'))
            {
                PlayState.gf.playAnim('sad');
            }
        }
    
    PlayState.hits["Misses"]++;
    PlayState.misses++;
    PlayState.numberOfNotes++;
    PlayState.numberOfArrowNotes++;
    PlayState.songScore -= 10;
    PlayState.combo = 0;
    FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
}
