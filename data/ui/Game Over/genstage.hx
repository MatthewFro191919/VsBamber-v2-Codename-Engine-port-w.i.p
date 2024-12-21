import dev_toolbox.ToolboxHome;
import dev_toolbox.character_editor.CharacterEditor;

function create() {
    FlxG.camera.zoom = 0.8;
    camFollow.setPosition(bf.getMidpoint().x - 100 + bf.camOffset.x, bf.getMidpoint().y - 100 + bf.camOffset.y);
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
}