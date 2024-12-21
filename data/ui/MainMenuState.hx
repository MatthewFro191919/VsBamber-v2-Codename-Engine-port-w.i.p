import lime.system.System;
import mod_support_stuff.ModClass;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;
import flixel.system.FlxSound;
import Sys;

FlxG.scaleMode.isWidescreen = false;

if (save.data.vs_bamber_modChart == null) save.data.vs_bamber_modChart = [
	'[SONG TITLE]' => true
];
var modchartSongs = ["harvest","swindled",'memeing']; // List of songs with modcharts (go figure)
for (i in modchartSongs) {
	if (save.data.vs_bamber_modChart[i] == null) save.data.vs_bamber_modChart[i] = true;
}
save.flush();

function create() {
	stage = loadStage('paintvoid');
	
	for (i in state.optionShit.members){
		if (i.name == "freeplay"){
			i.onSelect = function() FlxG.switchState(new ModState("freeplaySelect", mod));
		}
		if (i.name == "medals"){
			i.onSelect = function() FlxG.switchState(new ModState("customMedalState", mod));
		}
	}
}
var dist;
var curSelect = 0;
var cycleAmount = 0;
var gradient;
mouseControls = false;
var oceanic = new FlxSound().loadEmbedded(Paths.sound("oceanic"));
var ambienter = new FlxSound().loadEmbedded(Paths.sound("ambient"));
var theone = new FlxSprite(540, 15600).loadGraphic(Paths.image("freeplayportraits/joke_model_obj"));
theone.scale.set(0.5,0.5);
theone.updateHitbox();
theone.screenCenter();
theone.y += 15600;
var theonetext = new FlxText(0,16200,1280,"press enter.", 20);
theonetext.alignment = "center";
theonetext.visible = false;
var theoneshader = new CustomShader(Paths.shader("grain"));
function createPost() {
	FlxG.camera.addShader(theoneshader);
	oceanic.play();
	oceanic.looped = true;
	ambienter.looped = true;
	FlxG.sound.list.add(oceanic);
	FlxG.sound.list.add(ambienter);
	gradient = FlxGradient.createGradientFlxSprite(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 4), [0xFF000000,0xFF000000, 0x00000000], 4);
	gradient.angle = 180;
	gradient.scrollFactor.set(0,0.18);
	gradient.screenCenter();
	gradient.y += 300;
	insert(members.indexOf(versionShit), gradient);
	dist = menuItems.members[0].getMidpoint().y - menuItems.members[1].getMidpoint().y;
	autoCamPos = false;
	FlxG.stage.window.title = "Vs Bamber And Davey V2 | Main Menu";
	remove(fallBackBG);
	var water1 = new FlxBackdrop(Paths.image("water1"),0,0, true, false);
	var water2 = new FlxBackdrop(Paths.image("water2"),0,0, true, false);
	var water3 = new FlxBackdrop(Paths.image("water3"),0,0, true, false);
	var it = 0;
	for (i in [water1,water2,water3]) {
		i.velocity.x += 10 + (10 * it);
		i.y = 3200;
		i.scrollFactor.set(0.4,0.4);
		FlxTween.tween(i, {y:3250}, 10 / (5-it), {type:4, ease:FlxEase.sineInOut});
		insert(members.indexOf(versionShit), i);
		it++;
	}
	insert(members.indexOf(versionShit), theone);
	insert(members.indexOf(versionShit), theonetext);
}
var intendedVolume = 1;
var time = 0;
function updatePost(elapsed) {
	time += elapsed;
	theoneshader.data.iTime.value = [time];
	oceanic.proximity(0, 7600, camFollow, 1000, false);
	ambienter.proximity(0, 8400, camFollow, 6000, false);
	camFollow.y = menuItems.members[0].getMidpoint().y - dist * curSelect;
	if (curSelect > 7) intendedVolume = FlxMath.lerp(intendedVolume, 1 / (curSelect * 100), 0.006);
	if (curSelect >= 60 && intendedVolume >= 0) intendedVolume -= 0.01;
	FlxG.sound.music.volume = intendedVolume;
	if (controls.UP_P) {curSelect = FlxMath.wrap(curSelect - 1, 0, optionShit.length-1);
		if (cycleAmount != 0) cycleAmount = 0;
	}
	if (controls.DOWN_P) {
		if (curSelect == optionShit.length-1) cycleAmount+=1;
		if (cycleAmount != 3) curSelect = FlxMath.wrap(curSelect + 1, 0, optionShit.length-1);
		else curSelect += 1;
		if (curSelect == Math.floor(16.625 * menuItems.length)) FlxG.camera.bgColor = 0xFF061a2d;
		if (curSelect == Math.floor(15 * menuItems.length)) {
			FlxG.sound.play(Paths.sound("watersplash"));
			oceanic.stop();
			ambienter.play();
			new FlxTimer().start(10, spawnBubbles());
		}
		trace(curSelect);
		if (curSelect > Math.floor(22.5 * menuItems.length)) {
			FlxG.camera.bgColor = FlxColor.fromInt(0xFF061a2d).getDarkened((curSelect - Math.floor(22.5 * menuItems.length)) / 16);
		}
		if (curSelect > Math.floor(26.25 * menuItems.length)) theoneshader.data.strength.value = [(curSelect - Math.floor(26.25 * menuItems.length)) * 5];
		if (curSelect == Math.floor(28.375 * menuItems.length)) theonetext.visible = true; 
		if (curSelect == Math.floor(28.5 * menuItems.length)) theonetext.visible = false;
		trace(camFollow.y);
	}
	gradient.alpha = FlxMath.lerp(gradient.alpha, curSelect / 12, 0.05);
}
function update(elapsed) {
	if(controls.ACCEPT && theonetext.visible == true){
		FlxG.stage.window.alert(".freeplay", "       is waiting for you.");
		Medals.unlock("Am I A Joke To You?");
		save.data.vs_bamber_dmUnlock = true;
		Sys.exit(0);
		controls._accept._checked = false;
	}
}
function spawnBubbles() {
	for (i in 0...50) {
		var bubler = new FlxSprite(FlxG.random.bool()?FlxG.random.float(0, 500):FlxG.random.float(700,1280), 1000 + FlxG.random.float(0,2000)).loadGraphic(Paths.image("lil bubble"));
		bubler.angle = FlxG.random.int(0,360);
		bubler.scrollFactor.set();
		bubler.scale.x = bubler.scale.y = FlxG.random.float(0.1,0.5);
		bubler.velocity.y = -800 / bubler.scale.x;
		FlxTween.tween(bubler, {x:bubler.x + FlxG.random.float(-100,100)}, 0.1, {type:4, ease:FlxEase.sineInOut});
		insert(members.indexOf(versionShit), bubler);
	}
}
