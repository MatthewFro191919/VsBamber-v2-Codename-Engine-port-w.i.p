import flixel.addons.ui.FlxUIDropDownMenu;
import sys.FileSystem;
import flixel.addons.ui.FlxUIDropDownHeader;
var dropDown;
function create() {
	dropDown = new FlxUIDropDownMenu(200, 0, FlxUIDropDownMenu.makeStrIdLabelArray(FileSystem.readDirectory(Paths.modsPath + "/" + mod + "/songs")), null,
	new FlxUIDropDownHeader(245));
	add(dropDown);
}
function update() {
	if (FlxG.keys.pressed.SPACE) dropDown.setPosition(FlxG.mouse.screenX, FlxG.mouse.screenY);
	//for (i in dropDown.list) {
	//	i.scale.y = 0.1;
	//	i.getLabel().size = 7;
	//}
	dropDown.height = 0.6;
}
