import flixel.text.FlxTextBorderStyle;
import lime.system.System;
import ScoreText;
import Song;
import LoadingState;
import flixel.addons.transition.FlxTransitionableState;
import Settings;

var progressList = ['astray', 'facsimile', 'placeholder', 'test footage'];
var progressindex = progressList.indexOf(PlayState_.SONG.song.toLowerCase());

var fakeScoreText; //To simulate the changes in score.

var comboTxt = new FlxText(0, 0, FlxG.width, combo, 20);

var rippleShader = new CustomShader(Paths.shader('ripple'));

switch (progressindex) {
	case 0:
		ratings = [
			{
				name: "Sick",
				image: "HUD/paintvoid/astray/Sick",
				accuracy: 1,
				health: 0.035,
				maxDiff: 125 * 0.30,
				score: 350,
				color: "#24DEFF",
				fcRating: "MFC",
				showSplashes: true
			},
			{
				name: "Good",
				image: "HUD/paintvoid/astray/Good",
				accuracy: 2 / 3,
				health: 0.025,
				maxDiff: 125 * 0.55,
				score: 200,
				color: "#3FD200",
				fcRating: "GFC"
			},
			{
				name: "Bad",
				image: "HUD/paintvoid/astray/Bad",
				accuracy: 1 / 3,
				health: 0.010,
				maxDiff: 99999,
				score: 50,
				color: "#D70000"
			}
		];
	case 1:
		ratings = [
			{
				name: "Good",
				image: "HUD/paintvoid/facsimile/Good",
				accuracy: 1,
				health: 0.035,
				maxDiff: 125 * 0.55,
				score: 200,
				color: "#FF0000",
				fcRating: "GFC"
			},
			{
				name: "Bad",
				image: "HUD/paintvoid/facsimile/Bad",
				accuracy: 1 / 2,
				health: 0.0175,
				maxDiff: 99999,
				score: 100,
				color: "#00FF00"
			}
		];
	default:
		ratings = [
			{
				name: "Hit",
				image: null,
				accuracy: 1,
				health: 0.035,
				maxDiff: 99999,
				score: 100,
				color: "#FFFFFF"
			}
		];
}

if (progressindex >= 0) {
	engineSettings.animateMsLabel = engineSettings.centerStrums = engineSettings.showAccuracyMode = engineSettings.showAverageDelay = engineSettings.showPressDelay = engineSettings.showRating = engineSettings.animateInfoBar = engineSettings.alphabetOutline = engineSettings.showRatingTotal = false;
	engineSettings.timerSongName = engineSettings.minimizedMode = true;
	engineSettings.scoreJoinString = '   ';
	engineSettings.scoreTextSize = 18;
}
if (progressindex >= 1) {
	engineSettings.watermark = engineSettings.showTimer = engineSettings.resetButton = false;
	engineSettings.classicHealthbar = true;
	engineSettings.accuracyMode = 1;
}
if (progressindex >= 2) {
	engineSettings.middleScroll = engineSettings.showAccuracy = false;
	engineSettings.ghostTapping = true;
	engineSettings.scoreTextSize = 14;
	popupArrows = false;
}

var shader = new CustomShader(Paths.shader('grain'));
var bloom = new CustomShader(Paths.shader('bloom'));
var scanline = new CustomShader(Paths.shader('scanLines'));
var vignette = new CustomShader(Paths.shader('vignette'));
var cooler = new CustomShader(Paths.shader('sketchShader'));

var elapsedShader:Float = 0;
var grainStrength:Float = 16;
var actualGrainStrength:Float = 16;
var chromaticaAbber:Float = 0.001;
var tempBeat:Int = 0;
var oppositeHealth:Float = 1;
var hdr:Float = 1.5;

var stage:Stage = null;
function create() {
	stage = loadStage('paintvoid');
	FlxG.scaleMode.setSize(1280, 960);
	FlxG.scaleMode.isWidescreen = false;

	if (!FlxG.stage.window.maximized && !FlxG.fullscreen)
	{
		FlxG.stage.window.x += (FlxG.stage.window.width - FlxG.stage.window.height/3*4) / 2;
		FlxG.resizeWindow(FlxG.stage.window.height/3*4,FlxG.stage.window.height);
	}
	PlayState.camFollowLerp = 0.01;
	PlayState.health = 1.59;
	if (Settings.engineSettings.stageQuality != "low") {
		PlayState.camHUD.addShader(cooler);
		PlayState.camHUD.addShader(bloom);
		PlayState.camHUD.addShader(shader);
		PlayState.camHUD.addShader(scanline);

		// camGame shader initialization
		FlxG.camera.addShader(cooler);
		FlxG.camera.addShader(bloom);
		FlxG.camera.addShader(vignette);

		// variable initialization
		bloom.data.hDRthingy.value = [1.5];
		shader.data.strength.value = [35];
		vignette.data.size.value = [1.2];
	}
}

function createPost() {
	if (progressindex >= 1) {
		if (progressindex < 3) {
			if (!engineSettings.botplay) {
				fakeScoreText = new FlxText(healthBar.x + (healthBar.width * 0.28), 0, healthBar.width * (1 - 0.28), "A", 20);
				fakeScoreText.setFormat(Paths.font("vcr_osd.ttf"), Std.int(engineSettings.scoreTextSize), 0xFFFFFFFF, 'right', (progressindex < 2 ? FlxTextBorderStyle.OUTLINE : FlxTextBorderStyle.NONE), 0xFF000000);
				fakeScoreText.antialiasing = false;
				fakeScoreText.scale.x = 1;
				fakeScoreText.scale.y = 1;
				fakeScoreText.cameras = [camHUD];
				fakeScoreText.screenCenter();
				fakeScoreText.y = healthBarBG.y + 30;
				add(fakeScoreText);
				fakeScoreText.alpha = 0;
				FlxTween.tween(fakeScoreText, {alpha: 1}, 0.75, {ease: FlxEase.quartInOut});
				fakeScoreText.text = 'Score: ' + songScore + (progressindex < 2 ? '   Misses: ' + misses + '   ' + ScoreText.generateAccuracy(PlayState) : '');
			}
		} else {
			for (i in PlayState.members) if (i.name != null) i.destroy();
			healthBarBG.y = healthBar.y = -1000000;

			comboTxt.setFormat(Paths.font("vcr_osd.ttf"), 64, 0xFFFFFFFF, 'center', FlxTextBorderStyle.NONE, 0xFF000000);
			comboTxt.cameras = [camHUD];
			comboTxt.screenCenter();
			comboTxt.x += 200;
			add(comboTxt);

			boyfriend.visible = false;
		}

		if (progressindex >= 2) {
			for (i in unspawnNotes) {
				if (i.isSustainNote) i.alpha = 1;
			}
		}

		scoreText.visible = false;
	}
}

function destroy() {
	FlxG.scaleMode.setSize(1280, 720);

	if (!FlxG.stage.window.maximized && !FlxG.fullscreen) {
		FlxG.stage.window.x -= (FlxG.stage.window.height/9*16 - FlxG.stage.window.width) / 2;
		FlxG.resizeWindow(FlxG.stage.window.height/9*16,FlxG.stage.window.height);
	}
}

function update(elapsed:Float) {
	camGame.angle = 0;
	stage.update(elapsed);
	var camPos = PlayState.dad.getCamPos();
	PlayState.camFollow.setPosition(camPos.x, camPos.y);

	while (unspawnNotes[0] != null)
	{
		if (!(unspawnNotes[0].strumTime - Conductor.songPosition < 2000))
			break;
		notes.add(unspawnNotes.shift());
	}

	if (progressindex == 3) {
		health = 1.59;
		misses = numberOfNotes = numberOfArrowNotes = delayTotal = songScore = 0;

		scoreWarning.y = -1000000;
	}

	oppositeHealth = (2.2 - PlayState.health);

	// chromatic abberation
	chromaticaAbber = FlxMath.lerp(chromaticaAbber, 0.1, 0.02);
	bloom.data.chromatic.value = [chromaticaAbber];
	if (PlayState.curBeat != tempBeat)
		{
			chromaticaAbber = 1;
			tempBeat = PlayState.curBeat;
		}
	hdr = 1.5 - (PlayState.misses / 20);
	bloom.data.hDRthingy.value = [hdr];
	if (hdr <= 0)
		PlayState.doGameOver();
	//grain
	elapsedShader += Std.parseFloat(elapsed);
	shader.data.iTime.value = [elapsedShader];
	grainStrength = oppositeHealth * 47;
	actualGrainStrength = FlxMath.lerp(actualGrainStrength, grainStrength, 0.01);
	shader.data.strength.value = [actualGrainStrength];

	//scanline
	scanline.data.opacity.value = [oppositeHealth/6];
}

function onPostDeath() {
	CoolUtil.loadSong(mod, 'Test Footage', ''); //this loads parts of the songs instantly
	PlayState_.SONG = Song.loadModFromJson('Test Footage-', mod, 'Test Footage');
	FlxG.sound.music.stop();

	FlxTransitionableState.skipNextTransIn = true;
	FlxTransitionableState.skipNextTransOut = true;

	LoadingState.loadAndSwitchState(new PlayState());
}

function onOpenSubstate(substate) {
	if (health <= 0) {
		health = 0.01;

		for (i in FlxG.sound.list.members) {
			i.stop();
		}
		vocals.volume = 1;

		FlxTween.globalManager._tweens = [];

		notes.clear();
		for (e in events) events.remove(e);

		return false;
	}
}

if (progressindex < 3 && progressindex > 0 && !engineSettings.botplay) {
	function miss() {
		fakeScoreText.text = 'Score: ' + songScore + (progressindex < 2 ? '   Misses: ' + misses + '   ' + ScoreText.generateAccuracy(PlayState) : '');
	}

	function onPlayerHit(note) {
		fakeScoreText.text = 'Score: ' + songScore + (progressindex < 2 ? '   Misses: ' + misses + '   ' + ScoreText.generateAccuracy(PlayState) : '');
	}
}

function onGuiPopup() {
	if (engineSettings.showTimer) {
		timerBar.visible = false;

		//new final timer, cuz why would you bother updating every fucking time when you can create a new object
		//it may be easier to update, but this will be lagless
		var newTimerFinal = new FlxText(timerFinal.x, timerNow.y, 0, "????");
		newTimerFinal.setFormat(Paths.font("vcr.ttf"), 24, 0xFFFFFFFF, 'center', FlxTextBorderStyle.OUTLINE, 0xFF000000);
		newTimerFinal.cameras = [camHUD];
		newTimerFinal.antialiasing = true;
		newTimerFinal.alpha = 0;
		add(newTimerFinal);
		FlxTween.tween(newTimerFinal, {alpha: 1}, 0.75, {ease: FlxEase.quartInOut});

		timerFinal.destroy();
	}

	if (progressindex == 2) {
		iconP1.visible = iconP2.visible = false;
		PlayState.scripts.executeFunc('changeNoteskin', [Paths.getSparrowAtlas('characters/'+dad.curCharacter.split(':')[1]+'/NOTE_assets', mod, false), 'player']);
	}
}

function beatHit(curBeat) {
	stage.onBeat();
}

if (progressindex == 1) {
	function onShowCombo(combo:Int, coolText:FlxText) {
		var strumsX:Float = 0;
		var strumsY:Float = 0;
		var strumScale:Float = 0;
		var strumCount = 0;
	
		for (e in playerStrums.members)
		{
			if (e != null)
			{
				strumsX += e.x + (e.width / 2);
				strumsY += e.y + (e.height / 2);
				strumScale += e.notesScale/7*4;
				strumCount++;
			}
		}
		strumsX /= strumCount;
		strumsY /= strumCount;
		strumScale /= strumCount;
	
		coolText.x = Math.max(Math.min(strumsX, guiSize.x - 80), 20);
		coolText.y = Math.max(Math.min(strumsY - guiSize.y/2*(engineSettings.downscroll ? 1 : -1), guiSize.y - 80), 20);
	
		if (combo > 0) {
			var rating:FlxSprite = new FlxSprite().loadGraphic(lastRating.bitmap);
			rating.centerOrigin();
			rating.scale.x = rating.scale.y = lastRating.scale * strumScale;
			rating.updateHitbox();
			
			rating.x = coolText.x - rating.width/2;
			rating.y = coolText.y - rating.height/2;
			rating.cameras = [camHUD];
			rating.antialiasing = lastRating.antialiasing;
			PlayState.add(rating);

			new FlxTimer().start(0.4, function(tmr:FlxTimer) {
				rating.destroy();
			});
	
			var seperatedScore:Array<Int> = [];
			var stringCombo = Std.string(combo);
	
			for(i in 0...stringCombo.length) {
				seperatedScore.push(Std.parseInt(stringCombo.charAt(i)));
			}
	
			while(seperatedScore.length < combo.length) seperatedScore.insert(0, 0);
	
			var scoreWidth;
			var scoreHeight;
			var numScorePos = [];
	
			var comboSpr = new FlxSprite().loadGraphic(Paths.image('HUD/paintvoid/facsimile/combo'));
			comboSpr.centerOrigin();
			comboSpr.scale.set(strumScale, strumScale);
			comboSpr.antialiasing = engineSettings.antialiasing;
			comboSpr.updateHitbox();
			
			for (i in 0...seperatedScore.length + 1)
			{
				if (i < seperatedScore.length) {
					var numScore = new FlxSprite().loadGraphic(Paths.image('HUD/paintvoid/facsimile/' + seperatedScore[i]));
					numScore.centerOrigin();
					numScore.scale.set(strumScale*0.85, strumScale*0.85);
					numScore.antialiasing = engineSettings.antialiasing;
					numScore.updateHitbox();
					scoreWidth = numScore.width;
					scoreHeight = numScore.height;
	
					numScore.x = coolText.x - numScore.width/2 + (numScore.width * i + 3) - ((numScore.width + 3) * (seperatedScore.length - 1) + comboSpr.width + 3)/2 - 7;
					numScore.y = coolText.y + rating.height/2 + 5;
					numScorePos = [numScore.x, numScore.y];
	
					numScore.cameras = [camHUD];
	
					PlayState.add(numScore);

					new FlxTimer().start(0.4, function(tmr:FlxTimer) {
						numScore.destroy();
					});
				} else {
					comboSpr.x = numScorePos[0] + (scoreWidth + 3);
					comboSpr.y = numScorePos[1] + scoreHeight - comboSpr.height;
					comboSpr.cameras = [camHUD];
					PlayState.add(comboSpr);
	
					new FlxTimer().start(0.4, function(tmr:FlxTimer) {
						comboSpr.destroy();
					});
				}
			}
		}

		return false;
	}
} 

if (progressindex == 2) {
	function onShowCombo(combo:Int, coolText:FlxText) {
		var comboTxt2 = new FlxText(0, 0, FlxG.width, combo, 20);

		comboTxt2.setFormat(Paths.font("vcr_osd.ttf"), 64, 0xFFFFFFFF, 'center', FlxTextBorderStyle.NONE, 0xFF000000);
		comboTxt2.cameras = [camHUD];
		comboTxt2.screenCenter();
		comboTxt2.x += 200;
		add(comboTxt2);
		comboTxt2.text = combo + ' COMBO';
		new FlxTimer().start(0.4, function(tmr:FlxTimer) {
			comboTxt2.destroy();
		});

		return false;
	}
}

if (progressindex == 3) {
	canPause = autoCamZooming = false;
	FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;

	function onShowCombo(combo:Int, coolText:FlxText) {
		comboTxt.text = Std.string(combo);

		return false;
	}
}

function creditSetup(songBG, songTitle, creditTexts, creditIcons) {
	if (progressindex >= 1) {
		for (catIcons in creditIcons) {
			for (icon in catIcons) {
				icon.destroy();
			}
		}
		creditIcons = [];
		PlayState.scripts.setVariable('songIcons', creditIcons);
		songTitle.angle = 0;
		songBG.alpha = 1;
	}

	if (progressindex == 1) {
		for (catText in creditTexts) {
			for (i in 0...catText.length) {
				if (i == 0) {
					catText[i].angle = 0;
					catText[i].y = creditTexts[0][0].y;
					catText[i].x -= 25;
					catText[0].text += "\n";
					catText[0].size -= 10;
				} else { 
					catText[0].text += catText[i].text + "\n";
				}
			}

			catText = [catText[0]];
		}
		PlayState.scripts.setVariable('songTexts', creditTexts);
	} else if (progressindex == 2) {
		for (catText in creditTexts) {
			for (field in catText) {
				field.destroy();
			}
		}
		creditTexts = [];
		PlayState.scripts.setVariable('songTexts', creditTexts);
	}
}

function creditBehavior(songBG, songTitle, songTexts, songIcons, songTweens) {
	if (progressindex == 1) {
		songTweens.push(FlxTween.tween(songBG, {y: songBG.y - guiSize.y}, 1));

		songTweens.push(FlxTween.tween(songTitle, {y: songTitle.y - guiSize.y}, 1));

		for (catText in songTexts) {
			songTweens.push(FlxTween.tween(catText[0], {y: catText[0].y - guiSize.y}, 1));
		}
		PlayState.scripts.setVariable('creditTweens', songTweens);
	} else if (progressindex == 2) {
		songTitle.y -= guiSize.y;
	}

	return (progressindex == 0 ? true : 4);
}

function creditEnding(songBG, songTitle, songTexts, songIcons, songTweens) {
	if (progressindex == 1) {
		songTweens.push(FlxTween.tween(songBG, {y: songBG.y - guiSize.y}, 1));

		songTweens.push(FlxTween.tween(songTitle, {y: songTitle.y - guiSize.y}, 1, {onComplete: function(tween) {
			PlayState.scripts.executeFunc('creditsDestroy');
		}}));

		for (catText in songTexts) {
			songTweens.push(FlxTween.tween(catText[0], {y: catText[0].y - guiSize.y}, 1));
		}
		PlayState.scripts.setVariable('creditTweens', songTweens);
	} else if (progressindex == 2) {
		songTitle.y -= guiSize.y;
	}
}