import haxe.Json;
import openfl.utils.Assets;
import AlphabetOptimized;
import flixel.addons.text.FlxTypeText;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;

var dialogueJSON = Paths.parseJson(PlayState.SONG.song + '/dialogue');
var curDialogue:Int = 0;

var dialogueBoxes = [
	"left" => null,
	"center" => null,
	"right" => null
];
var dialogueBoxTweens = [];
var dialogueEases = [
	'normal' => 'quart',
	'angry' => 'elastic',
	'thinking' => 'back',
	'weak' => 'sine',
	'whisper' => 'sine'
];
var songColors = [
	['yield', 'cornaholic', 'harvest'] => 0xFF66F951,
	['synthwheel', 'yard', 'coop'] => 0xFF5173F9,
	['ron be like', 'bob be like', 'fortnite duos'] => 0xFFF9EB51,
];
var songDialogueColor;
for (song in songColors.keys()) {
	if (song.contains(PlayState.SONG.song.toLowerCase())) {
		songDialogueColor = songColors[song];
		break;
	}
}

var grayBG = new FlxSprite(-500).makeGraphic(1, 1, 0x6FFFFFFF);
grayBG.scale.set(3000,3000); grayBG.updateHitbox();
var blurFilter:BitmapFilter;

var weekSongNames = [
	"Bamber's Farm" => 'fertilizer',
	"Davey's Yard" => 'sofa',
	"Romania Outskirts" => 'memeshed'
];

var text:AlphabetOptimized = new AlphabetOptimized(175, 500, "", false, 0.53);
var tempText:FlxTypeText = new FlxTypeText(500, 200);
var sounds = [
	new FlxSound().loadEmbedded(Paths.sound('dialogue')),
	new FlxSound().loadEmbedded(Paths.sound('dialogueClose')),
	new FlxSound().loadEmbedded(Paths.sound(weekSongNames[PlayState.actualModWeek.name], true))
];

var preloadPortraits = [];
//Default Portrait Positions
var xPos = [
	"left" => -60,
	"right" => -100
];
var LEFT_CHAR_X:Float = -60;
var RIGHT_CHAR_X:Float = -100;
var DEFAULT_CHAR_Y:Float = 60;

var done = true;
var started = false;
var canSkip = false;
var resetButton = PlayState.engineSettings.resetButton;
var defaultCamZoomer = PlayState.defaultCamZoom;

function oldNew() {
	PlayState.guiElemsPopped = true;
}

function postCreate() {
	PlayState.strumLineNotes.set_maxSize(PlayState.SONG.keyNumber * 2);
	PlayState.playerStrums.set_maxSize(PlayState.SONG.keyNumber);
	PlayState.cpuStrums.set_maxSize(PlayState.SONG.keyNumber);

	PlayState.scripts.executeFunc('dialogueStart');
	done = false;

	grayBG.alpha = 0;
	grayBG.cameras = [PlayState.camHUD];
	PlayState.add(grayBG);

	blurFilter = new BlurFilter(0.001, 0.001, 3);
	if (FlxG.camera._filters == null) FlxG.camera._filters = [];
	FlxG.camera._filters.push(blurFilter);
	FlxTween.tween(blurFilter, {blurX: 8, blurY: 8}, 2, {ease: FlxEase.quartOut});

	tempText.visible = false;
	tempText.cameras = [PlayState.camHUD];
	tempText.sounds = [sounds[0]];
	text.textColor = 0xFF000000;
	text.cameras = [PlayState.camHUD];
	text.alpha = 0;
	text.maxWidth = 670;
	text.cutPoint = -2;
	sounds[2].persist = false;
	FlxG.sound.list.add(sounds[2]);

	//preventing the bitch from starting
	PlayState.canPause = false;
	PlayState.engineSettings.resetButton = false;

	//getting portraits info
	var tempThingy = [];
	for (i in 0...dialogueJSON.dialogue.length)
	{
		if (!tempThingy.contains(dialogueJSON.dialogue[i].portrait))
		{
			preloadPortraits.push([dialogueJSON.dialogue[i].portrait]);
			tempThingy.push(dialogueJSON.dialogue[i].portrait);
		}
	}

	//portraits preload
	for (i in 0...preloadPortraits.length)
	{
		var portraitJson = Json.parse(Assets.getText(Paths.getPath('images/PORTRAITS/' + preloadPortraits[i][0] + '.json')));
		
		var portrait = new FlxSprite(0, 60);
		portrait.frames = Paths.getSparrowAtlas('PORTRAITS/' + portraitJson.image);
		portrait.setGraphicSize(Std.int(portrait.width * 0.7 * portraitJson.scale));
		
		var offsets = [];
		portrait.antialiasing = true;
		portrait.cameras = [PlayState.camHUD];
		portrait.x = (portraitJson.dialogue_pos == "right" ? FlxG.width - portrait.width + xPos[portraitJson.dialogue_pos] : xPos[portraitJson.dialogue_pos]);
		if (portraitJson.dialogue_pos == "center") 	portrait.x = FlxG.width / 2 - portrait.width / 2;
		portrait.x += portraitJson.position[0];
		portrait.y += portraitJson.position[1];
		
		for (j in 0...portraitJson.animations.length)
		{
			portrait.animation.addByPrefix(portraitJson.animations[j].anim, portraitJson.animations[j].idle_name, 24);
			offsets.push([portraitJson.animations[j].anim, portraitJson.animations[j].idle_offsets]);
			portrait.animation.addByPrefix(portraitJson.animations[j].anim + " loop", portraitJson.animations[j].loop_name, 24);
			offsets.push([portraitJson.animations[j].anim + " loop", portraitJson.animations[j].loop_offsets]);
		}
		
		preloadPortraits[i].push(portrait);
		preloadPortraits[i].push(offsets);
		preloadPortraits[i].push(portraitJson.dialogue_pos);
		preloadPortraits[i].push(portraitJson.position);
		
		PlayState.add(preloadPortraits[i][1]);
		preloadPortraits[i][1].visible = false;
	}

	// speech_bubbles
	for (i in 0...3) {
		var dialogueBOX = new FlxSprite(0, 400);
		dialogueBOX.frames = Paths.getSparrowAtlas('speechBubbles/bamber_bubble');
		dialogueBOX.animation.addByPrefix('normal', 'Normal_Loop', 24, true);
		dialogueBOX.animation.addByPrefix('angry', 'Anger_Loop', 24, true);
		dialogueBOX.animation.addByPrefix('thinking', 'Think_Loop', 24, true);
		dialogueBOX.animation.addByPrefix('weak', 'Weak_Loop', 24, true);
		dialogueBOX.animation.addByPrefix('whispering', 'Whisper_Loop', 24, true);
		dialogueBOX.animation.play('normal');

		dialogueBOX.x = 20 + (FlxG.width - dialogueBOX.width - 40) / 2 * i;
		if (i == 0) dialogueBOX.flipX = true;

		dialogueBOX.scale.x = 0;
		dialogueBOX.scale.y = 0;

		dialogueBOX.cameras = [PlayState.camHUD];
		PlayState.add(dialogueBOX);

		var superCoolColor = new FlxColor(songDialogueColor);
		dialogueBOX.shader = new ColoredNoteShader(superCoolColor.red, superCoolColor.green, superCoolColor.blue);

		dialogueBoxes[i == 0 ? 'left' : (i == 1 ? 'center' : 'right')] = dialogueBOX;
	}

	//starting dialogue
	PlayState.add(text);
	PlayState.add(tempText);
	if (PlayState.startTimer != null) PlayState.startTimer.cancel();
	if (!PlayState.inCutscene) startDialog();

	defaultCamZoomer = PlayState.defaultCamZoom;
	PlayState.defaultCamZoom += 0.3;

	for (babyArrow in PlayState.strumLineNotes.members) babyArrow.visible = false;
}
function startDialog() {
	PlayState.startCountdown();
	PlayState.startTimer.cancel();

	FlxTween.tween(grayBG, {alpha: 1}, 0.5, {startDelay: 0.5, onComplete: function (twn:FlxTween) {
		nextDialog(0);
		FlxTween.tween(text, {alpha: 1}, 0.1);
		started = true;
	}, onStart: function (twn:FlxTween) {
		sounds[2].play();
		sounds[2].fadeIn(0.5);
		sounds[2].looped = true;
	}});
}

function update(elapsed) {
	if (FlxG.keys.justPressed.TAB && started && !done) {
		dialogueBoxTweens = [];
		sounds[1].play(true);
		begin();
	}

	if (FlxG.keys.justPressed.ANY && !done && started && canSkip)
	{
		if (tempText.text != dialogueJSON.dialogue[curDialogue].text)
			tempText.skip();
		else
		{
			dialogueBoxTweens = [];
			nextDialog(1);
			sounds[1].play(true);
		}
	}

	if (!done)Conductor.songPosition = -2000;

	text.text = tempText.text;
}

function nextDialog(e:Int) {
	curDialogue += e;
	
	if (curDialogue == dialogueJSON.dialogue.length)
	{
		curDialogue--;
		begin();
		return false;
	}

	for (i in 0...preloadPortraits.length)
	{
		if (dialogueJSON.dialogue[curDialogue].portrait == preloadPortraits[i][0])
		{
			//Forcefully resetting positions because at times characters don't spawn properly. Strangely fixed that issue so im not complaining
			preloadPortraits[i][1].x = (preloadPortraits[i][3] == "right" ? FlxG.width - preloadPortraits[i][1].width + xPos[preloadPortraits[i][3]] : xPos[preloadPortraits[i][3]]);
			if (preloadPortraits[i][3] == "center") preloadPortraits[i][1].x = FlxG.width / 2 - preloadPortraits[i][1].width / 2;
			preloadPortraits[i][1].x += preloadPortraits[i][4][0];
			preloadPortraits[i][1].y = 60 + preloadPortraits[i][4][1];

			preloadPortraits[i][1].animation.play(dialogueJSON.dialogue[curDialogue].expression + (dialogueJSON.dialogue[curDialogue].boxState != 'thinking' ? ' loop' : ''));
			for (j in 0...preloadPortraits[i][2].length) {
				if (preloadPortraits[i][2][j][0] == dialogueJSON.dialogue[curDialogue].expression + (dialogueJSON.dialogue[curDialogue].boxState != 'thinking' ? ' loop' : ''))
					preloadPortraits[i][1].offset.set(preloadPortraits[i][2][j][1][0], preloadPortraits[i][2][j][1][1]);
			}

			tempText.completeCallback = function() {
				preloadPortraits[i][1].animation.play(dialogueJSON.dialogue[curDialogue].expression);
				for (j in 0...preloadPortraits[i][2].length) {
					if (preloadPortraits[i][2][j][0] == dialogueJSON.dialogue[curDialogue].expression)
						preloadPortraits[i][1].offset.set(preloadPortraits[i][2][j][1][0], preloadPortraits[i][2][j][1][1]);
				}
			}

			if (dialogueBoxes[preloadPortraits[i][3]].animation.curAnim != null && dialogueBoxes[preloadPortraits[i][3]].animation.curAnim.name != dialogueJSON.dialogue[curDialogue].boxState && dialogueJSON.dialogue[curDialogue - 1] != null) {
				dialogueBoxes[preloadPortraits[i][3]].scale.x = 0;
				dialogueBoxTweens.push(FlxTween.tween(dialogueBoxes[preloadPortraits[i][3]].scale, {x: 1}, 0.1, {ease: CoolUtil.getEase(dialogueEases[dialogueBoxes[preloadPortraits[i][3]].animation.curAnim.name]+'Out')}));
			}
			dialogueBoxes[preloadPortraits[i][3]].animation.play(dialogueJSON.dialogue[curDialogue].boxState, true);

			tempText.completeCallback = function() {
			preloadPortraits[i][1].animation.play(dialogueJSON.dialogue[curDialogue].expression);
				for (j in 0...preloadPortraits[i][2].length) {
					if (preloadPortraits[i][2][j][0] == dialogueJSON.dialogue[curDialogue].expression)
						preloadPortraits[i][1].offset.set(preloadPortraits[i][2][j][1][0], preloadPortraits[i][2][j][1][1]);
				}
			}
		}

		if (dialogueJSON.dialogue[curDialogue - 1] == null || dialogueJSON.dialogue[curDialogue].portrait != dialogueJSON.dialogue[curDialogue - 1].portrait)
		{
			if (dialogueJSON.dialogue[curDialogue].portrait == preloadPortraits[i][0])
			{
				preloadPortraits[i][1].visible = true;
				preloadPortraits[i][1].animation.play(dialogueJSON.dialogue[curDialogue].expression + (dialogueJSON.dialogue[curDialogue].boxState != 'thinking' ? ' loop' : ''));
				for (j in 0...preloadPortraits[i][2].length) {
					if (preloadPortraits[i][2][j][0] == dialogueJSON.dialogue[curDialogue].expression + (dialogueJSON.dialogue[curDialogue].boxState != 'thinking' ? ' loop' : ''))
						preloadPortraits[i][1].offset.set(preloadPortraits[i][2][j][1][0], preloadPortraits[i][2][j][1][1]);
				}
				
				if (preloadPortraits[i][3] != "center")
				{
					preloadPortraits[i][1].x += (preloadPortraits[i][3] == "left" ? -350 : 350);
					FlxTween.tween(preloadPortraits[i][1], {x: preloadPortraits[i][1].x - (preloadPortraits[i][3] == "left" ? -350 : 350)}, 0.1, {onStart: function(twn:FlxTween) {canSkip = false;}, onComplete: function(twn:FlxTween) {canSkip = true;}, startDelay: 0.01});
				}
				else
				{
					preloadPortraits[i][1].y += 100;
					FlxTween.tween(preloadPortraits[i][1], {y: preloadPortraits[i][1].y - 100}, 0.1, {onStart: function(twn:FlxTween) {canSkip = false;}, onComplete: function(twn:FlxTween) {canSkip = true;}, startDelay: 0.01});
				}

				text.x = dialogueBoxes[preloadPortraits[i][3]].x + 130;
				
				dialogueBoxes[preloadPortraits[i][3]].animation.play(dialogueJSON.dialogue[curDialogue].boxState, true);
				for (d in dialogueBoxes) {
					if (dialogueBoxes[preloadPortraits[i][3]] == d && d.scale.x == 1) d.scale.x = d.scale.y = 0;
					dialogueBoxTweens.push(FlxTween.tween(d.scale, {y: (dialogueBoxes[preloadPortraits[i][3]] == d ? 1 : 0)}, 0.15, {ease: CoolUtil.getEase(dialogueEases[d.animation.curAnim.name]+(dialogueBoxes[preloadPortraits[i][3]] == d ? 'Out' : 'In'))}));
					dialogueBoxTweens.push(FlxTween.tween(d.scale, {x: (dialogueBoxes[preloadPortraits[i][3]] == d ? 1 : 0)}, 0.25, {ease: CoolUtil.getEase(dialogueEases[d.animation.curAnim.name]+(dialogueBoxes[preloadPortraits[i][3]] == d ? 'Out' : 'In'))}));
				}
				
				tempText.completeCallback = function() {
					preloadPortraits[i][1].animation.play(dialogueJSON.dialogue[curDialogue].expression);
					for (j in 0...preloadPortraits[i][2].length) {
						if (preloadPortraits[i][2][j][0] == dialogueJSON.dialogue[curDialogue].expression)
							preloadPortraits[i][1].offset.set(preloadPortraits[i][2][j][1][0], preloadPortraits[i][2][j][1][1]);
					}
				}
			}

			if (dialogueJSON.dialogue[curDialogue - 1] != null && dialogueJSON.dialogue[curDialogue - 1].portrait == preloadPortraits[i][0])
			{
				preloadPortraits[i][1].visible = false;
			}
		}
	}

	tempText.resetText(dialogueJSON.dialogue[curDialogue].text);
	tempText.start(dialogueJSON.dialogue[curDialogue].speed);
}

function begin()
{
	PlayState.strumLine.y = (PlayState.engineSettings.downscroll ? PlayState.guiSize.y - 150 : 50);

	tempText.resetText('');

	sounds[2].fadeOut(1,0,function(twn:FlxTween) {
		sounds[2].destroy();
	});

	PlayState.engineSettings.resetButton = resetButton;
	PlayState.canPause = true;

	for (d in dialogueBoxes) {
		dialogueBoxTweens.push(FlxTween.tween(d.scale, {y: 0}, 0.15, {ease: CoolUtil.getEase(dialogueEases[d.animation.curAnim.name]+'In'), onComplete: function(twn:FlxTween) {d.destroy();}}));
		dialogueBoxTweens.push(FlxTween.tween(d.scale, {x: 0}, 0.25, {ease: CoolUtil.getEase(dialogueEases[d.animation.curAnim.name]+'In'), onComplete: function(twn:FlxTween) {d.destroy();}}));
	}
	
	FlxTween.tween(blurFilter, {blurX: 0, blurY: 0}, 2, {ease: FlxEase.quartOut, onComplete: function (twn:FlxTween) {
		FlxG.camera._filters.remove(blurFilter);
	}});
	FlxTween.tween(text, {alpha: 0}, 0.1);
	FlxTween.tween(grayBG, {alpha: 0}, 0.3, {startDelay: 0.2, onComplete: function (twn:FlxTween) {
		PlayState.health += 0.000001;
		PlayState.startCountdown();
	}});
	FlxTween.tween(PlayState, {defaultCamZoom: defaultCamZoomer}, 1, {ease: FlxEase.backInOut, onStart: function(twn:FlxTween) {
	}});

	for (portrait in preloadPortraits) PlayState.remove(portrait[1]);

	done = true;

	PlayState.guiElemsPopped = false;
	PlayState.popUpGUIelements();
	PlayState.scripts.executeFunc('dialogueEnd');

	for (babyArrow in PlayState.strumLineNotes.members) {
		babyArrow.__animationEnabled = true;
		babyArrow.__animationY -= 10;
		babyArrow.__animationAlpha = 0;
		babyArrow.visible = true;
		FlxTween.tween(babyArrow, {__animationY: 0, __animationAlpha: 1}, 1,
		{ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * (PlayState.strumLineNotes.members.indexOf(babyArrow)%PlayState.song.keyNumber) / (0.1 * PlayState.song.keyNumber) * 0.4)});
	}
}

function musicStart() {
	PlayState.strumLineNotes.set_maxSize(0);
	PlayState.playerStrums.set_maxSize(0);
	PlayState.cpuStrums.set_maxSize(0);

	if (['coop', 'fortnite duos'].contains(PlayState.SONG.song.toLowerCase()) && started && !FlxG.save.data.vs_bamber_hasDiedInThisSong) {
		PlayState.scripts.executeFunc("onGenerateStaticArrows");
	}
}

function onFocus() { sounds[2].resume(); }

function onFocusLost() { sounds[2].pause(); }