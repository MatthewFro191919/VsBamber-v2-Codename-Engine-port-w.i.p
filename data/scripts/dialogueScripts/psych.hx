import haxe.Json;
import openfl.utils.Assets;
import AlphabetOptimized;
import flixel.addons.text.FlxTypeText;

var preloadPortraits = [];
var dialogueJSON = Paths.parseJson(PlayState.SONG.song + '/dialogue');
var dialogueBOX = new FlxSprite(70, 370);
var curDialogue:Int = 0;

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

var grayBG = new FlxSprite(-500).makeGraphic(1, 1, 0x9FFFFFFF);
grayBG.scale.set(3000,3000); grayBG.updateHitbox();
var text:AlphabetOptimized = new AlphabetOptimized(175, 475, "", false, 0.7);
var tempText:FlxTypeText = new FlxTypeText(500, 200);
var sounds = [
	new FlxSound().loadEmbedded(Paths.sound('dialogue')),
	new FlxSound().loadEmbedded(Paths.sound('dialogueClose')),
	new FlxSound().loadEmbedded(Paths.sound('breakfast', true))
];

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
	tempText.visible = false;
	tempText.cameras = [PlayState.camHUD];
	tempText.sounds = [sounds[0]];
	text.textColor = 0xFF000000;
	text.cameras = [PlayState.camHUD];
	text.alpha = 0;
	text.maxWidth = 955;
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

	// speech_bubble
	dialogueBOX.frames = Paths.getSparrowAtlas('speechBubbles/psych_bubble');
	dialogueBOX.animation.addByPrefix('normal', 'speech bubble normal', 24);
	dialogueBOX.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
	dialogueBOX.animation.addByPrefix('angry', 'AHH speech bubble', 24);
	dialogueBOX.animation.addByPrefix('angryOpen', 'speech bubble loud open', 24, false);
	dialogueBOX.animation.addByPrefix('center-normal', 'speech bubble middle', 24);
	dialogueBOX.animation.addByPrefix('center-normalOpen', 'Speech Bubble Middle Open', 24, false);
	dialogueBOX.animation.addByPrefix('center-angry', 'AHH Speech Bubble middle', 24);
	dialogueBOX.animation.addByPrefix('center-angryOpen', 'speech bubble Middle loud open', 24, false);
	dialogueBOX.scale.set(0.96, 0.96); //found that this scale feels more accurate to psych than how psych coded its scale to be 0.9x. Ironic.
	dialogueBOX.updateHitbox();

	dialogueBOX.animation.finishCallback = function(name:String) {
		if (!done)
			dialogueBOX.animation.play(dialogueJSON.dialogue[curDialogue].boxState);
		else
			dialogueBOX.visible = false;
	}

	dialogueBOX.cameras = [PlayState.camHUD];
	PlayState.add(dialogueBOX);
	dialogueBOX.visible = false;

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

function updateBoxOffsets(box:FlxSprite, direction:String) { //Had to make it static because of the editors
	box.centerOffsets();
	box.updateHitbox();
	box.flipX = (direction == "left" ? true : false);

	if(dialogueJSON.dialogue[curDialogue].boxState == 'angry') {
		box.offset.set(50, 65);
	} else if(dialogueJSON.dialogue[curDialogue].boxState == 'center-angry') {
		box.offset.set(50, 30);
	} else {
		box.offset.set(10, 0);
	}

	if(!box.flipX) box.offset.y += 10;
}

function update(elapsed) {
	if (FlxG.keys.justPressed.TAB && started && !done) {
		sounds[1].play(true);
		begin();
	}

	if (FlxG.keys.justPressed.ANY && !done && started && canSkip)
	{
		if (tempText.text != dialogueJSON.dialogue[curDialogue].text)
			tempText.skip();
		else
		{
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

			preloadPortraits[i][1].animation.play(dialogueJSON.dialogue[curDialogue].expression + ' loop');

			tempText.completeCallback = function() {
				preloadPortraits[i][1].animation.play(dialogueJSON.dialogue[curDialogue].expression);
				for (j in 0...preloadPortraits[i][2].length) {
					if (preloadPortraits[i][2][j][0] == dialogueJSON.dialogue[curDialogue].expression)
						preloadPortraits[i][1].offset.set(preloadPortraits[i][2][j][1][0], preloadPortraits[i][2][j][1][1]);
				}
			}

			for (j in 0...preloadPortraits[i][2].length) {
				if (preloadPortraits[i][2][j][0] == dialogueJSON.dialogue[curDialogue].expression + ' loop')
					preloadPortraits[i][1].offset.set(preloadPortraits[i][2][j][1][0], preloadPortraits[i][2][j][1][1]);
			}

			if (!dialogueBOX.visible) dialogueBOX.visible = true;
			dialogueBOX.animation.play(dialogueJSON.dialogue[curDialogue].boxState, true);
			updateBoxOffsets(dialogueBOX, preloadPortraits[i][3]);

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
				preloadPortraits[i][1].animation.play(dialogueJSON.dialogue[curDialogue].expression + ' loop');
				for (j in 0...preloadPortraits[i][2].length) {
					if (preloadPortraits[i][2][j][0] == dialogueJSON.dialogue[curDialogue].expression + ' loop')
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
				
				if (!dialogueBOX.visible) dialogueBOX.visible = true;
				dialogueBOX.animation.play((preloadPortraits[i][3] == 'center' ? "center-" : '') + dialogueJSON.dialogue[curDialogue].boxState + "Open", true);
				updateBoxOffsets(dialogueBOX, preloadPortraits[i][3]);
				
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

	dialogueBOX.animation.play(dialogueJSON.dialogue[curDialogue].boxState + "Open", true, true);

	PlayState.engineSettings.resetButton = resetButton;
	PlayState.canPause = true;

	FlxTween.tween(dialogueBOX, {alpha: 0}, 0.1, {onComplete: function(twn:FlxTween) {dialogueBOX.destroy();}});
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

	//BACKUP FOR WHENEVER ANY PSYCH SONG HAS 3RD STRUMS (which none have)
	//if (['coop', 'fortnite duos'].contains(PlayState.SONG.song.toLowerCase()) && started) {
	//	PlayState.scripts.executeFunc("onGenerateStaticArrows");
	//}
}

function onFocus() { sounds[2].resume(); }

function onFocusLost() { sounds[2].pause(); }