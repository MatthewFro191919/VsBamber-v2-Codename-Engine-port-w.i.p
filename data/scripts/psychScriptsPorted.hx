import flixel.util.FlxAxes;
import flixel.text.FlxTextBorderStyle;
import flixel.text.FlxTextFormat;

var barSize = 0;
var newCharacter:Character;
var bar1:FlxSprite = new FlxSprite(-600, -560 + (barSize * 10)).makeGraphic(1, 1, 0xFF000000);
var bar2:FlxSprite = new FlxSprite(-600, 720 - (barSize * 10)).makeGraphic(1, 1, 0xFF000000);

bar1.scale.x = bar2.scale.x = 1600 * 2;
bar1.scale.y = bar2.scale.y = 560;
bar1.updateHitbox(); bar2.updateHitbox(); 

var eventText = new FlxText(0, 0, 0, "", 30);
var eventStep = [0, 0];

// glitch for the love of fucking god use if (song.SONG.toLowerCase() == "[SONG FOR CUSTOM BARSIZE]") to change the barsize
var customBarSize:Array<Dynamic> = [
	['Synthwheel', 5],
	['Astray', 36],
	['Facsimile', -36],
	['Placeholder', -36],
	['Deathbattle', 10],
	['Screencast', 7],
	['Harvest', 36],
	['Yield V1', 9],
	['Cornaholic V1', 9],
	['Harvest V1', 9],
	['Yield Seezee Remix', 9],
	['Cornaholic Erect Remix V1', 9],
	['Harvest Chill Remix', 9],
	['call-bamber', 36],
];

function create()	{	for (i in 0...customBarSize.length)
	if (customBarSize[i][0] == PlayState.SONG.song)
		barSize = customBarSize[i][1];
bar1.cameras=[camHUD];bar2.cameras=[camHUD];insert(0,bar1);insert(0,bar2);bar2.y=720-(barSize*10);bar1.y=-560+(barSize*10);}

function postCreate() {
	add(eventText);
}

function onPsychEvent(event:String, ?value1:String, ?value2:String, ?value3:String, ?value4:String, ?value5:String, ?value6:String, ?value7:String)
{
	if (event == "Change Default Zoom")
	{
		PlayState.defaultCamZoom = value1;
	}
	if (event == "Change Bars Size")
	{
		var val1 = Std.parseFloat(value1);
		var val2 = Std.parseFloat(value2);
		FlxTween.tween(bar1, {y: -560 + (val1 * 10)}, val2, {ease: (value3 == null ? FlxEase.quintOut : CoolUtil.getEase(value3))});
		FlxTween.tween(bar2, {y: 720 + -(val1 * 10)}, val2, {ease: (value3 == null ? FlxEase.quintOut : CoolUtil.getEase(value3))});
	}
	if (event == "Play Animation")
	{
		if (value1 == 'bf')
			PlayState.boyfriend.playAnim(value2);
		if (value1 == 'gf')
			PlayState.gf.playAnim(value2);
		if (value1 == 'dad')
			PlayState.dad.playAnim(value2);
	}
	if (event == "Add Camera Zoom")
	{
		var val1 = Std.parseFloat(value1);
		var val2 = Std.parseFloat(value2);
		PlayState.camZooming = true;
		PlayState.camGame.zoom += val1 * 2;
		PlayState.camHUD.zoom += value2 * 2;
	}
	if (event == 'Change Scroll Speed')
	{
		var val1 = Std.parseFloat(value1);
		var val2 = Std.parseFloat(value2);

		var newValue:Float = PlayState.song.speed * value1;

		if(value2 <= 0)
		{
			SONG.speed = newValue;
		}
		else
		{
			FlxTween.tween(PlayState.song, {speed: newValue}, value2, {ease: FlxEase.linear, onComplete:
				function (twn:FlxTween)
				{
					songSpeedTween = null;
				}
			});
		}
	}
	if (event == 'Change Character')
	{
		switch (value1)
		{
			case 'boyfriend':
				var charX = PlayState.boyfriend.x - boyfriend.charGlobalOffset.x;
				var charY = PlayState.boyfriend.y - boyfriend.charGlobalOffset.y;
				PlayState.remove(PlayState.boyfriend);
				PlayState.boyfriend.destroy();
				PlayState.boyfriends[0] = new Boyfriend(charX, charY, PlayState.songMod + ":" + value2);
				PlayState.add(PlayState.boyfriend);
				PlayState.iconP1.changeCharacter(value2, PlayState.songMod);
			case 'girlfriend':
				var charX = PlayState.gf.x - gf.charGlobalOffset.x;
				var charY = PlayState.gf.y - gf.charGlobalOffset.y;
				PlayState.remove(PlayState.gf);
				PlayState.gf.destroy();
				PlayState.gf = new Boyfriend(charX, charY, PlayState.songMod + ":" + value2);
				PlayState.add(PlayState.gf);
				PlayState.iconP1.changeCharacter(value2, PlayState.songMod);
			case 'dad':
				var charX = PlayState.dad.x - dad.charGlobalOffset.x;
				var charY = PlayState.dad.y - dad.charGlobalOffset.y;
				PlayState.remove(PlayState.dad);
				PlayState.remove(newCharacter);
				newCharacter = new Character(charX, charY, PlayState.songMod + ":" + value2);
				newCharacter.visible = false;
				PlayState.dads[0] = newCharacter;
				PlayState.add(newCharacter);
				PlayState.iconP2.changeCharacter(value2, PlayState.songMod);
				newCharacter.visible = true;
		}
		
	}
	if (event == 'Character Position Dad')
	{
		PlayState.dad.position.set(Std.parseFloat(value1), Std.parseFloat(value2));
	}
	if (event == 'Character AddPos Dad')
	{
		for (i in 0...PlayState.dads.length)
		{
			newCharacter.x += Std.parseFloat(value1);
			newCharacter.y += Std.parseFloat(value2);
		}
	}
	if (event == 'Camera Flash')
	{
		PlayState.camGame.flash(Std.parseInt(value1), Std.parseFloat(value2));
	}
	if (event == "Flash Image") {
		var imgflash = new FlxSprite(0, 0).loadGraphic(Paths.image ("secret stash of secret images!! (super secret)/" + value1));
		FlxTween.tween(imgflash, {alpha: 0}, 1);
		insert(PlayState.members.length+1, imgflash); //insert used so that after the romanian outskirts game over, it always is consistent
		imgflash.scrollFactor(0, 0);
		imgflash.setGraphicSize(FlxG.scaleMode.width, FlxG.scaleMode.height);
		imgflash.cameras = [camHUD];
		imgflash.screenCenter();
  }
	if(event == "Show Custom Text"){
		// Value 1 = Text, Value 2 = X, Value 3 = Y, Value 4 = Font, Value 5 = Size, Value 6 = What step to make it disappear on, Value 7 = How long it takes to disappear in seconds
		eventText.alpha = 1;
		eventText.cameras = [camHUD];
		eventText.text = value1;
		eventText.setFormat(Paths.font(value4), value5, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		eventText.borderSize = value5 / 25;

		if(value2 == "Center"){eventText.screenCenter(FlxAxes.X);} else {eventText.x = value2;}
		if(value3 == "Center"){eventText.screenCenter(FlxAxes.Y);} else if(value3 == "Strums") {eventText.y = playerStrums.members[0].y + (engineSettings.downscroll ? 0 : playerStrums.members[0].height - eventText.height) - ((40 + Std.int(value5)) * (engineSettings.downscroll ? 1 : -1));} else {eventText.y = value3;}
		eventStep = [Std.int(value6), Std.parseFloat(value7)];
	}
	if(event == "Custom Text Formatting"){
		// Value 1 - 7 = Arrays of options (put as many as needed in each array but the formatting is "Starting Index (Which letter to start on), End Index (Which one to end on), Color (0xFFXXXXXX)")
		// Supports bold and italic text but use them before color changes, ok?
		// Clearing the formatting is an option too.
		for (i in [value1, value2, value3, value4, value5, value6, value7]) {
			if (i == null) break;

			if (i == 'clear') {
				eventText.clearFormats();
			} else {
				var formats = Std.string(i).split(',');
				for (f in 0...formats.length) {
					if (f % 3 == 2) {
						var colorFormat = Std.string(formats[f]).split('-');
						var formatColor = Std.parseInt(colorFormat[0]);
						eventText.addFormat(new FlxTextFormat(formatColor, colorFormat.contains('bold'), colorFormat.contains('italic'), (isColorDark(formatColor) ? 0xFFFFFFFF : 0xFF000000)), formats[f - 2], formats[f - 1]);
					}
				}
			}
		}
	}
	if(event == "Note Tomfoolery"){
		// Value 1 = Strum (Player,CPU), Value 2 = what you're doing
		if(value1 == "Player"){
			switch(value2){
				// Value 3 = X/Y, Value 4 = How long the tween takes
				case "MoveY": for(a in playerStrums.members){a.y = value3;}
				case "MoveX": for(a in playerStrums.members){a.x = value3;} // Why would you use this, they'll all overlap
				case "TweenX": for(a in playerStrums.members){FlxTween.tween(a, { x: value3 }, value4);} // See above
				case "TweenY": for(a in playerStrums.members){FlxTween.tween(a, { y: value3 }, value4);} // See above
				// Value 3 = Angle, Ditto as above for Value 4
				case "Angle": for(a in playerStrums.members){a.angle = value3;}
			}
		} else {
			switch(value2){
				// Value 3 = X/Y, Value 4 = How long the tween takes
				case "MoveY": for(a in cpuStrums.members){a.y = value3;}
				case "MoveX": for(a in cpuStrums.members){a.x = value3;} // Why would you use this, they'll all overlap
				case "TweenX": for(a in cpuStrums.members){FlxTween.tween(a, { x: value3 }, value4);} // See above
				case "TweenY": for(a in cpuStrums.members){FlxTween.tween(a, { y: value3 }, value4);} // See above
				// Value 3 = Angle, Ditto as above for Value 4
				case "Angle": for(a in cpuStrums.members){a.angle = value3;}
			}
}
	}
}
function update(elapsed)
{
	bar1.x = -bar1.width / 10;
	bar2.x = -bar1.width / 10;

}
function onPreDeath() {
	PlayState.camGame.setFilters([]);
	PlayState.camHUD.setFilters([]);
}

function stepHit(curStep) {
	if (curStep == eventStep[0]) {FlxTween.tween(eventText, {alpha: 0}, eventStep[1]);}
}

function reset() {
	FlxTween.tween(bar1, {y: -560 + (barSize * 10)}, 0.75, {ease: FlxEase.quintOut});
	FlxTween.tween(bar2, {y: 720 - (barSize * 10)}, 0.75, {ease: FlxEase.quintOut});
}

function isColorDark(color:Int):Bool {
    var r = (color >> 16) & 0xFF;
    var g = (color >> 8) & 0xFF;
    var b = color & 0xFF;

    var max = Math.max(r, Math.max(g, b));
    var min = Math.min(r, Math.min(g, b));

    // Calculate lightness
    var l = (max + min) / 2.0 / 255.0;

    return l < 0.5;
}