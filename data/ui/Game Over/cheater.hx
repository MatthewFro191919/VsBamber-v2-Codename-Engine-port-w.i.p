import dev_toolbox.ToolboxHome;
import dev_toolbox.character_editor.CharacterEditor;
import flixel.util.FlxGradient;

var expungo = new FlxSprite();
var gradientSprite;

var gameover = new FlxSprite();
var retry = new FlxSprite();

var goTWEENS = [];

function create() {
    FlxG.camera.zoom = 0.8;
    camFollow.setPosition(bf.getMidpoint().x - 100 + bf.camOffset.x, bf.getMidpoint().y - 100 + bf.camOffset.y);
    FlxG.camera.follow(camFollow);
    bf.antialiasing = false;

    expungo.frames = Paths.getSparrowAtlas('deathShit/cheater/expunged');
    expungo.animation.addByPrefix('idle', 'Expunged', 8, true);
    expungo.animation.play('idle');
    expungo.scrollFactor.set();
    expungo.screenCenter();
    expungo.x += 120;
    expungo.y += 1500;
    expungo.antialiasing = false;
    insert(0, expungo);

    expungo.alpha = 0;
    goTWEENS.push(FlxTween.tween(expungo, {alpha:1, y: expungo.y - 1500, x: expungo.x - 80}, 2, {ease: FlxEase.quartInOut, startDelay: 2}));

    expungo.scale.x = expungo.scale.y = 45;
    goTWEENS.push(FlxTween.tween(expungo.scale, {x:1.2, y: 1.2}, 2, {ease: FlxEase.quartInOut, startDelay: 2}));

    gradientSprite = FlxGradient.createGradientFlxSprite(FlxG.width * 5, 900, [0x00000000, 0x00000000, 0xFF008C00, 0x00000000], 1, 90, true);
    gradientSprite.scrollFactor.set();
	gradientSprite.screenCenter();
    gradientSprite.y += 100;
    insert(0, gradientSprite);

    gradientSprite.alpha = 0;
    goTWEENS.push(FlxTween.tween(gradientSprite, {alpha: 1}, 3, {ease: FlxEase.quartInOut, startDelay: 2}));

    gameover.frames = Paths.getSparrowAtlas('deathShit/cheater/gameover');
    gameover.animation.addByPrefix('trans', 'GameOver_Transition', 24, false);
    gameover.animation.addByPrefix('loop', 'GameOver_Loop', 24, false);
    gameover.animation.addByPrefix('end', 'GameOver_End', 24, false);
    gameover.scrollFactor.set();
    gameover.screenCenter();
    gameover.antialiasing = false;
    gameover.visible = false;
    gameover.y = PlayState.guiSize.y - 300;
    add(gameover);

    retry.frames = Paths.getSparrowAtlas('deathShit/cheater/retry');
    retry.animation.addByPrefix('trans', 'Retry_Transition', 24, false);
    retry.animation.addByPrefix('loop', 'Retry_Loop', 24, false);
    retry.animation.addByPrefix('end', 'Retry_End', 24, false);
    retry.scrollFactor.set();
    retry.screenCenter();
    retry.antialiasing = false;
    retry.visible = false;
    retry.y -= 470;
    add(retry);
}

function beatHit(beat) {
    if (beat % 2 == 0 && !isEnding && gameover.animation.curAnim.name == 'loop') { gameover.animation.play('loop', true); retry.animation.play('loop', true);}
}

function update(elapsed) {
    if (controls.BACK) FlxG.save.data.vs_bamber_hasDiedInThisSong = null;

    if (FlxG.keys.justPressed.SEVEN) { //DEBUG SHIT, TO ADJUST CHAR CAM OFFSETS (because that's where the camera will go now)
        var split = GameOverSubstate.char.split(":");
		CharacterEditor.fromFreeplay = true;
		ToolboxHome.selectedMod = split[0];
		FlxG.switchState(new CharacterEditor(split[1]));
    }

    if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished && !isEnding) { gameover.animation.play('loop', true); retry.animation.play('loop', true);}
}

function updatePost(elapsed) {
    if (bf.animation.curAnim.name == 'firstDeath' && !bf.animation.curAnim.finished) {
        if (!bf.animation.curAnim.finished) FlxG.camera.follow(camFollow);

        if (bf.animation.curAnim.curFrame == 54 && !isEnding) { gameover.visible = true; retry.visible = true; gameover.animation.play('trans', true); retry.animation.play('trans', true); }
    }
}

function onEnd() {
    if (!isEnding) {
        for (i in goTWEENS) i.cancel();
        goTWEENS.push(FlxTween.tween(expungo, {alpha:0}, 3, {ease: FlxEase.quartIn}));
        goTWEENS.push(FlxTween.tween(expungo.scale, {x:0.5, y: 0.5}, 3, {ease: FlxEase.quartIn}));
        goTWEENS.push(FlxTween.tween(gradientSprite, {alpha: 0}, 3, {ease: FlxEase.quartIn}));

        gameover.animation.play('end', true);
        retry.animation.play('end', true);
    }
}

function end() {
    new FlxTimer().start(1.5, function(tmr:FlxTimer)
        {
            FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
            {
                start();
            });
        });
}