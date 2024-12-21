// Coded peak at on an airplane :fire: - C4rr13
import flixel.util.FlxGradient;
import lime.system.System;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxTextBorderStyle;
import openfl.filters.ShaderFilter;

if(save.data.vs_bamber_freeplaySelect == null){save.data.vs_bamber_freeplaySelect = 0;}

var iconscroller = ['bamber', 'bamber-old', 'bamber-sans', 'bambi', 'bf', 'bomber', 'newboris', 'cheating-bambi', 'cubefreind', 'not-your-char', 'davey', 'elisocray', 'gen-bamber', 'gen-bf', 'gen-screwer', 'gen-joker', 'gf-playable', 'joke_davey_obj', 'manny', 'nikku', 'oldBF', 'newronnie', 'ronnie-and-boris', 'water', 'yr-bamber', 'bamber-trade', 'trade-davey'];
var img = [];
var textGroup = [];

var arrowUp = new FlxSprite();
var arrowDown = new FlxSprite();

var curSelect = 0;
var directionx = FlxG.random.int(-1, 1);
var directiony = FlxG.random.int(-1, 1);

var titleText = new FlxText(FlxG.width/2-10, 20);
var songText = new FlxText(titleText.x);

var yep:FlxSprite;
var nope:FlxSprite;
var maybe:FlxSprite;
var bg1:FlxBackdrop;
var bg2:FlxBackdrop;

var darkenering = new CustomShader(Paths.shader("darkener"));

var data = [ // Image, Title, [Song1, Song2, etc], color, font
	["Bamber", "Week Bamber", ["Yield", "Cornaholic", "Harvest"], 0xB6FF00],
	["Davey", "Week Davey", ["Synthwheel", "Yard", "Coop"], 0x0066FF],
	["Ronnie And Boris", "Week Ronnie & Boris", ["Ron Be Like", "Bob Be Like", "Fortnite Duos"], 0xFED73E],
	["Bonuses", "Bonus Songs", ["Blusterous Day", "Swindled","Trade", "Multiversus"], 0x00FFA6],
	["Jokes", "Joke Songs", ["Generations","Memeing","Judgement Farm","Judgement Farm 2","Yield - OST"], 0x038703],
	["Collabs", "Collab Songs", ["Call (Bamber Mix)","Deathbattle","H2O"], 0xA5CEE3],
	["Crossovers", "Crossover Songs", ["Corn N Roll","Screencast"], 0xFE3455],
	["Legacy", "Legacy/Old Content", ["Yield V1", "Cornaholic V1", "Harvest V1", "Yield Seezee Remix", "Cornaholic Erect Remix V1", "Harvest Chill Remix"], 0x16AD01],
];

function create(){
	if(save.data.vs_bamber_scUnlock == true) data[4][2].push("Squeaky Clean");
	if(save.data.vs_bamber_dmUnlock == true) data.push(["Daveys Nightmare", "DAVEY'S NIGHTMARE", [], 0x000000, "vcr_osd.ttf"]);
	FlxG.scaleMode.isWidescreen = false;

	FlxG.camera.addShader(darkenering);

	add(new FlxSprite(0, 0).loadGraphic(Paths.image('menuBGYoshiCrafter_')));

	add(bg1 = new FlxBackdrop(Paths.getCharacterIcon(iconscroller[FlxG.random.int(0, iconscroller.length-1)]), 0.1, 0.1, true, true));
	bg1.alpha = 0;
	add(bg2 = new FlxBackdrop(Paths.getCharacterIcon(iconscroller[FlxG.random.int(0, iconscroller.length-1)]), 0.1, 0.1, true, true));

	add(gradient = FlxGradient.createGradientFlxSprite(Std.int(FlxG.width), Std.int(FlxG.height), [0x00000000, 0xFFAAAAAA]));

	for(a in data) img.push(new FlxSprite(0, 0).loadGraphic(Paths.image('categoryvinyls/'+a[0])));
	for(a in img) add(a);

	add(titleText);
	add(songText);

	for(b in [arrowUp, arrowDown]){
		b.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		b.animation.addByPrefix('idle', 'arrow left', 24, false);
		b.animation.addByPrefix('push', 'arrow push left', 24, false);
		b.animation.play('idle');
		add(b);
		b.updateHitbox();
	}

	arrowUp.angle += 90;
	arrowDown.angle += 270;
	arrowUp.y += 20;
	arrowDown.y += 610;

	for(c in [yep, nope, maybe, arrowUp, arrowDown, titleText, songText, bg1, bg2]){if (c != null) c.antialiasing = true;}

	changeSelection(save.data.vs_bamber_freeplaySelect);
}
var oldSelect = 0;

function changeSelection(changeNum:Int){
	oldSelect = curSelect;
	curSelect = FlxMath.wrap(curSelect + changeNum, 0, data.length - 1);

	if (oldSelect != curSelect) FlxG.sound.play(Paths.sound("scrollMenu"));

	var isInNightmareWeek = (data[curSelect][1] == "DAVEY'S NIGHTMARE");

	bg1.velocity.set(130, 130);
	bg2.velocity.set(-130, -130);

	titleText.text = data[curSelect][1]+":";

	fontString = (data[curSelect][4] == null) ? "vcr.ttf" : data[curSelect][4];

	titleText.setFormat(Paths.font(fontString), 60, data[curSelect][3], 'LEFT', FlxTextBorderStyle.OUTLINE, 0xFF000000);
	songText.text = "";
	songText.setFormat(Paths.font(fontString), 40, data[curSelect][3], 'LEFT', FlxTextBorderStyle.OUTLINE, 0xFF000000);
	songText.y =  titleText.y + titleText.height;
	titleText.borderSize = songText.borderSize = (isInNightmareWeek ? 0 : 4);

	gradient.color = data[curSelect][3];

	for(b in data[curSelect][2]){
		songText.text = songText.text + "• "+ b + "\n";
	}

	gradient.visible = songText.visible = titleText.visible = !isInNightmareWeek;

		

	for(c in img){
		c.visible = false;
	}

	yep = img[curSelect]; 
	yep.screenCenter(); 
	yep.x -= 350;
	yep.scale.set(0.5, 0.5);
	yep.angularVelocity = 100 / (isInNightmareWeek ? 5 : 1);

	nope = img[FlxMath.wrap(curSelect-1, 0, img.length-1)];
	maybe = img[FlxMath.wrap(curSelect+1, 0, img.length-1)];

	for(d in [yep, nope, maybe]){d.visible = true; d.antialiasing = true; d.color = 0xFFFFFF;}
	for(e in [nope, maybe]){e.x = yep.x; e.scale.set(0.25/2, 0.25/2); e.color = 0x000000;}
	for(h in [arrowUp, arrowDown]){h.x = yep.getMidpoint().x - h.width/2; h.animation.play('idle');}

	nope.y = yep.y-300;
	maybe.y = yep.y+300;

	FlxG.stage.window.title = "Vs Bamber And Davey V2 | Freeplay Categories | Selecting: \"" + titleText.text.split(":")[0] + "\"";
}

var time:Float = 0;
var canMove = true;

function update(elapsed){
	time += elapsed;
	bg1.alpha = 0.5 + Math.sin(time/3)*0.50001;
	bg2.alpha = 1-bg1.alpha;

	if(bg1.alpha == 0) bg1.loadGraphic(Paths.getCharacterIcon(iconscroller[FlxG.random.int(0, iconscroller.length-1)])); 
	if(bg2.alpha == 0) bg2.loadGraphic(Paths.getCharacterIcon(iconscroller[FlxG.random.int(0, iconscroller.length-1)])); 

	for(b in [arrowUp, arrowDown]) b.animation.play('idle');

	if (canMove) {
		if(controls.ACCEPT){
			save.data.freeplayCat = titleText.text.split(":")[0];
			save.data.vs_bamber_freeplaySelect = curSelect;
			save.flush();
			if ((data[curSelect][1] == "DAVEY'S NIGHTMARE")) {
				FlxG.sound.music.fadeOut(4);
				FlxTween.num(0.0, 1.2, 0.4, {startDelay: 4, onComplete: function() {
					new FlxTimer().start(2, function() FlxG.switchState(new FreeplayState()));
				}}, function(a) {darkenering.data.valuable.value = [a];});
			}
			else {
				FlxTween.num(FlxG.camera.zoom, 3, 0.5, {ease: FlxEase.quartInOut}, function(v) {FlxG.camera.zoom = v;});
			
				if(Assets.exists(Paths.sound("accept/ACCEPT_" + curSelect)))
					FlxG.sound.play(Paths.sound("accept/ACCEPT_" + curSelect));
				else
					FlxG.sound.play(Paths.sound('accept/ACCEPT_Default'));

				canMove = false;
				FlxG.switchState(new FreeplayState());
			}

		}
		if (controls.BACK){save.data.vs_bamber_freeplaySelect = curSelect; save.flush(); FlxG.switchState(new MainMenuState());}
		if (controls.UP_P || controls.DOWN_P) changeSelection(controls.UP_P ? -1 : 1);
		if (controls.UP || controls.DOWN) (controls.DOWN ? arrowDown : arrowUp).animation.play('push');
	}
}
