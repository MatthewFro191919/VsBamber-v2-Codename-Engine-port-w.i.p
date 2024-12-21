import dev_toolbox.ToolboxHome;
import dev_toolbox.character_editor.CharacterEditor;

function create() {
    FlxG.camera.zoom = 0.8;

    bf.visible = false;

    matzu = new FlxSprite();
    matzu.frames = Paths.getSparrowAtlas('deathShit/hotline/MATZURETRY');
    matzu.animation.addByPrefix('deathLoop', 'dead loop', 24, true);
    matzu.animation.addByPrefix('deathConfirm', 'dead confirm', 24, false);
    matzu.animation.play('deathLoop');
    matzu.scrollFactor.set();
    matzu.screenCenter();
    matzu.alpha = 0.001;
    add(matzu);
}

function preUpdate(elapsed) {
    if (controls.BACK) FlxG.save.data.vs_bamber_hasDiedInThisSong = null;

    if (FlxG.keys.justPressed.SEVEN) { //DEBUG SHIT, TO ADJUST CHAR CAM OFFSETS (because that's where the camera will go now)
        var split = GameOverSubstate.char.split(":");
		CharacterEditor.fromFreeplay = true;
		ToolboxHome.selectedMod = split[0];
		FlxG.switchState(new CharacterEditor(split[1]));
    }

    if (controls.ACCEPT && !isEnding) {
        matzu.alpha = 1;
        FlxTween.globalManager.completeTweensOf(matzu);
        matzu.animation.play('deathConfirm');
    }
}

var matzu;

function updatePost(elapsed) {
    if (bf.animation.curAnim.name == 'deathLoop' && matzu.alpha == 0.001) {
        FlxTween.tween(matzu, {alpha: 1}, 1);
    }
}

function beatHit(curBeat) {
    if (!isEnding) matzu.animation.play('deathLoop');
}