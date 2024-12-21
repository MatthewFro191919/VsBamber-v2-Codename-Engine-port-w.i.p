import flixel.math.FlxRandom;

function create() {
    note.frames = Paths.getSparrowAtlas('customnotes/'+PlayState_.SONG.stage.toLowerCase(), mod);
    note.colored = true;

    note.setGraphicSize(Std.int(note.width * 0.7));
	note.updateHitbox();

    note.animation.addByPrefix('scroll', 'strike', 24, true);
    note.animation.play("scroll");
}

var dadTweens = [];
var dadPosX = [];

var camera_follow = PlayState.scripts.getVariable('cameraFollow');

function onDadHit(direction:Int) {
    if (!PlayState.chartTestMode) {
        if (dadTweens.length == 0) for (i in 0...dads.length) { dadTweens[i] = null; dadPosX[i] = dads[i].x;}
        FlxTween.tween(camera_follow, {x: boyfriend.x + boyfriend.width/2}, 0.1, {ease: FlxEase.quartOut});

        var chosenDad = Math.min(FlxG.random.int(0, dads.length+3), dads.length-1);

        if (dadTweens[chosenDad] != null && dadTweens[chosenDad].active) dadTweens[chosenDad].cancel();
        dads[chosenDad].x = dadPosX[chosenDad];
        dads[chosenDad].x += 750;
        dadTweens[chosenDad] = FlxTween.tween(dads[chosenDad], {x: dadPosX[chosenDad]}, 0.5, {ease: FlxEase.backIn});
    }
}