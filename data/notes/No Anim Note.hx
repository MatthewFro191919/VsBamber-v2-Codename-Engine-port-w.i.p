function onDadHit() {}
function onPlayerHit() {}
function onMiss() {
    health -= note.isSustainNote ? 0.03125 : 0.125;

    PlayState.hits["Misses"]++;
    PlayState.misses++;
    PlayState.numberOfNotes++;
    PlayState.numberOfArrowNotes++;
    PlayState.songScore -= 10;
    PlayState.combo = 0;

    FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
}