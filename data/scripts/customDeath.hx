import openfl.utils.Assets;

var goBMPs = [
    'cheater' => 105,
    'funkin' => 100,
    'ut' => 594,
    'hotline' => 0
];

var gOMs = [
    ['cheater'] => 'cheater',
    ['oldfarm', 'oldfarm_night', 'default_stage', 'genstage', 'yieldstage'] => 'funkin',
    ['judgement_hall', 'undertalestage'] => 'ut',
    ['hot_farm'] => 'hotline'
];

var overrideScripts = [
    ['cheater'] => 'cheater',
    ['oldfarm', 'oldfarm_night', 'default_stage'] => 'funky',
    ['genstage', 'yieldstage'] => 'genstage',
    ['judgement_hall', 'undertalestage'] => 'judgemental-failure',
    ['hot_farm'] => 'hotline'
];

function onDeath() { 
    FlxG.save.data.vs_bamber_hasDiedInThisSong = true;
    
    GameOverSubstate.scriptName = 'vs-bamber:ui/Game Over/global';

    //Default Sounds
    GameOverSubstate.gameOverMusic = 'death/default';
    GameOverSubstate.gameOverMusicBPM = 130;
    GameOverSubstate.retrySFX = 'death/ends/default-end';

    for (song in overrideScripts.keys()) {
        if (song.contains(PlayState.SONG.stage.toLowerCase()) || song.contains(PlayState.SONG.song.toLowerCase())) {
            GameOverSubstate.scriptName = 'vs-bamber:ui/Game Over/'+overrideScripts[song];
            if (overrideScripts[song] == null) GameOverSubstate.scriptName = null;
            break; //break out of the loop
        }
    }

    if (Paths.characterExists(boyfriend.curCharacter.split(':')[1] + '-dead', mod)) {
        GameOverSubstate.char = boyfriend.curCharacter + '-dead';
        GameOverSubstate.firstDeathSFX = 'death/' + GameOverSubstate.char.split(":")[1];
    }

    if (Paths.characterExists(boyfriend.curCharacter.split(':')[1] + '-dead-' + PlayState.SONG.stage.toLowerCase(), mod)) {
        GameOverSubstate.char = boyfriend.curCharacter + '-dead-' + PlayState.SONG.stage.toLowerCase();
        GameOverSubstate.firstDeathSFX = 'death/' + GameOverSubstate.char.split(":")[1];
    }

    for (song in gOMs.keys()) {
        if (song.contains(PlayState.SONG.stage.toLowerCase()) || song.contains(PlayState.SONG.song.toLowerCase())) {
            GameOverSubstate.gameOverMusic = 'death/'+gOMs[song];
            GameOverSubstate.gameOverMusicBPM = goBMPs[gOMs[song]];
            GameOverSubstate.retrySFX = 'death/ends/'+gOMs[song]+'-end';
            break; //break out of the loop
        }
    }

    FlxTimer.globalManager._timers = [];
}

function onPreEndSong() { FlxG.save.data.vs_bamber_hasDiedInThisSong = null; }