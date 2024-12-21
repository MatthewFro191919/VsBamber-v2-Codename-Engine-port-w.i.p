import flixel.util.FlxGradient;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxCameraFollowStyle;
import flixel.FlxObject;
import dev_toolbox.ToolboxHome;
import dev_toolbox.character_editor.CharacterEditor;

var gradientSprite;
var camDest;

var basePos = PlayState.scripts.getVariable("cameraFollow"); //hmmmmmmm, how interesting that this works
var finished = false;

function create() {
    FlxTween.tween(FlxG.camera, {zoom: 0.8}, 3, {ease: FlxEase.quartInOut});

    gradientSprite = FlxGradient.createGradientFlxSprite(FlxG.width * 2, 900, [0x00000000, PlayState.boyfriend.getColors()[0]], 1, 90, true);
    gradientSprite.scrollFactor.set();
	gradientSprite.screenCenter();
    gradientSprite.y += 100;
    insert(members.indexOf(bf), gradientSprite);

    gradientSprite.alpha = 0;
    FlxTween.tween(gradientSprite, {alpha: 1}, 3, {ease: FlxEase.quartInOut});

    camFollow.setPosition(basePos.x, basePos.y);
    camFollow.acceleration.set(basePos.acceleration.x, basePos.acceleration.y);

    camDest = new FlxObject(bf.getMidpoint().x - 100 + bf.camOffset.x, bf.getMidpoint().y - 100 + bf.camOffset.y - 150, 1, 1);
    add(camDest);
}

function update(elapsed) {
    if (controls.BACK) FlxG.save.data.vs_bamber_hasDiedInThisSong = null;

    if (FlxG.keys.justPressed.SEVEN) { //DEBUG SHIT, TO ADJUST CHAR CAM OFFSETS (because that's where the camera will go now)
        var split = GameOverSubstate.char.split(":");
		CharacterEditor.fromFreeplay = true;
		ToolboxHome.selectedMod = split[0];
		FlxG.switchState(new CharacterEditor(split[1]));
    }
}

function updatePost(elapsed) {
    if (bf.animation.curAnim.name == 'firstDeath' && !bf.animation.curAnim.finished) FlxG.camera.follow(camFollow);

    var speedIthink = 0.8;
	var realSpeed = PlayState.camFollowLerp;
    camFollow.acceleration.set(((camDest.x - camFollow.x) - (camFollow.velocity.x * speedIthink)) / realSpeed, ((camDest.y - camFollow.y) - (camFollow.velocity.y * speedIthink)) / realSpeed); // so much smoothness
}