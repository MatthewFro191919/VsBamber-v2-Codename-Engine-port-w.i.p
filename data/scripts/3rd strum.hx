import StringTools;
var wasMiddleScroll = EngineSettings.middleScroll;
EngineSettings.middleScroll = false;
var gaveBirth:Bool = false;
var strums = [];
var notesForStrum = [
    "Coop" => [1,2], //noteType numbers for the 3rd strum
    "Deathbattle" => [2],
    "Corn N Roll" => [2],
    "Fortnite Duos" => [1],
    "Blusterous Day" => [1]
];
function onGenerateStaticArrows() {
    strums = [];
    PlayState.generateStaticArrows();
    for(i in 0...PlayState_.SONG.keyNumber) {
        var strum = PlayState.cpuStrums.members[i + PlayState_.SONG.keyNumber];
        if (strum != null) {
            strum.visible = false;
            strums.push(strum);
        }
    }
}
function updatePost(elapsed:Float) {
    EngineSettings.glowCPUStrums = true;
    PlayState.notes.forEach(function(n) {
        for (i in 0...notesForStrum[PlayState.SONG.song].length)
            if (n.noteType == notesForStrum[PlayState.SONG.song][i]) {
                // gf note
                var strum = PlayState.cpuStrums.members[n.noteData % PlayState_.SONG.keyNumber];
                var nStrum = strums[n.noteData % PlayState_.SONG.keyNumber];
                if (n.isSustainNote)
                    n.x = nStrum.x + (n.width);
                else
                    n.x = nStrum.x;
                n.y = n.y - strum.y + nStrum.y;
            }
    });
}
function onDadHit(note:Note) {
    if (gaveBirth)
    {
        for (i in 0...notesForStrum[PlayState.SONG.song].length) {
            if (note.noteType == notesForStrum[PlayState.SONG.song][i])
            {
                EngineSettings.glowCPUStrums = false;
                note.destroy();
                var nStrum = strums[note.noteData % PlayState_.SONG.keyNumber];
                if (note.splashColor != false)
                {
                    var color = new FlxColor(note.splashColor);
                    nStrum.shader = new ColoredNoteShader(color.red, color.green, color.blue, false);
                }
                nStrum.cpuRemainingGlowTime = note.stepLength * 1.5 / 1000;
                nStrum.animation.play("confirm", true);
                nStrum.centerOffsets();
                nStrum.centerOrigin();
                nStrum.toggleColor(nStrum.colored);
            }

        }
    }
}
function giveBirthToThe3rd() {
    gaveBirth = true;
	for(e in PlayState.playerStrums.members) {
        FlxTween.tween(e, {x: (wasMiddleScroll ? ((FlxG.width / 2) + ((playerStrums.members.indexOf(e) - 2) * (Note.swagWidth * 0.87))) : (FlxG.width - ((FlxG.width - e.x - 65) * 0.87))), notesScale: e.notesScale * 0.9}, 0.5, {ease: FlxEase.backOut});
    }
    for(e in PlayState.cpuStrums.members) {
		if (e.visible)
			FlxTween.tween(e, {x: (e.x * 0.87) - 65, notesScale: e.notesScale * 0.9}, 0.5, {ease: FlxEase.backOut});
    }
	for (i in 0...strums.length){
		strums[i].visible = true;
		FlxTween.tween(strums[i], {x: (!wasMiddleScroll ? ((FlxG.width / 2) + ((i - 2) * (Note.swagWidth * 0.87))) : (FlxG.width - ((FlxG.width - playerStrums.members[i].x - 65) * 0.87))), notesScale: strums[i].notesScale * 0.9}, 1.0, {ease: FlxEase.elasticOut});
	}
}

function reset() {
    gaveBirth = false;
    new FlxTimer().start(0.75, function() {
        for (i in strums) {
            remove(i);
        }
    });

    strums = [];
}