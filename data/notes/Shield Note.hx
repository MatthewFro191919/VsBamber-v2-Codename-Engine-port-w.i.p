import flixel.math.FlxRandom;

var playerTeam;

function create() {
    note.frames = Paths.getSparrowAtlas('customnotes/'+PlayState_.SONG.stage.toLowerCase(), mod);
    note.colored = true;

    note.maxEarlyDiff = 90;

    note.setGraphicSize(Std.int(note.width * 0.7));
	note.updateHitbox();

    note.animation.addByPrefix('scroll', 'shield', 24, true);
    note.animation.play("scroll");

    playerTeam = boyfriends.copy();
    playerTeam.push(gf);

    note.enableRating = false;
    note.hitOnBotplay = true;

    noteTweens = [
    'NOTE_TIME' => 'TWEEN'
    ];
}

var dadTweens = [];
var dadPosX = [];

var noteTweens = [
    'NOTE_TIME' => 'TWEEN'
];

function update(elapsed) {
    super.update(elapsed);

    if (Conductor.songPosition - 60 >= note.strumTime) {
        //PlayState.scripts.executeFunc('punch', [playerTeam, dads, true, true]);

        noteMiss(note);
        PlayState.health -= 0.5;
        
        note.kill();
		notes.remove(note, true);
		note.destroy();

        PlayState.scripts.executeFunc('shake', [2]);
    }
}

function updatePost(elapsed) {
    if (noteTweens[note.strumTime] == null && ((engineSettings.downscroll && note.y >= -50) || (!engineSettings.downscroll && note.y <= guiSize.y + 50))) noteTweens[note.strumTime] = FlxTween.tween(note.noteOffset, {x:0}, 0.2 / (PlayState.current.engineSettings.customScrollSpeed ? PlayState.current.engineSettings.scrollSpeed : PlayState.SONG.speed), {ease: FlxEase.expoOut});
    if ((engineSettings.downscroll && note.y < -50) || (!engineSettings.downscroll && note.y > guiSize.y + 50)) note.noteOffset.x = cpuStrums.members[note.noteData % PlayState.SONG.keyNumber].x - playerStrums.members[note.noteData % PlayState.SONG.keyNumber].x;
}

function onPlayerHit(direction:Int) {
    if (!PlayState.chartTestMode) {
        FlxG.sound.play(Paths.sound('battlefx/dodge'), 1);

        if (dadTweens.length == 0) for (i in 0...playerTeam.length) { dadTweens[i] = null; dadPosX[i] = playerTeam[i].x;}

        var chosenDad = FlxG.random.int(0, playerTeam.length-1);

        if (dadTweens[chosenDad] != null && dadTweens[chosenDad].active) dadTweens[chosenDad].cancel();
        playerTeam[chosenDad].x = dadPosX[chosenDad];
        playerTeam[chosenDad].x += 200;
        dadTweens[chosenDad] = FlxTween.tween(playerTeam[chosenDad], {x: dadPosX[chosenDad]}, 0.5, {ease: FlxEase.backIn});
    }
}