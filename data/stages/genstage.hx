import logging.LogsOverlay;
import flixel.math.FlxRect;

//this is intentionally shitty
engineSettings.showRating = engineSettings.animateMsLabel = engineSettings.showPressDelay = engineSettings.showAverageDelay = engineSettings.classicHealthbar = engineSettings.showAccuracy = engineSettings.showMisses = engineSettings.animateInfoBar = engineSettings.showTimer = engineSettings.watermark = engineSettings.timerSongName = engineSettings.showRatingTotal = true;
engineSettings.minimizedMode = engineSettings.glowCPUStrums = engineSettings.splashesEnabled = engineSettings.autoResyncVocals = engineSettings.customArrowColors_allChars = engineSettings.customScrollSpeed = false;
engineSettings.scoreTextSize = 50;
//make ur mom do the shitty using flxFuckYou

ratings = [
	{
		name: "Good",
		image: "HUD/genstage/keep yourself safe",
		accuracy: 1,
		health: 0.035,
		maxDiff: 30,
		score: 350,
		color: "#00FF00",
		fcRating: "MFC",
		showSplashes: true
	},
	{
		name: "You Should Kill Yourself, Now!",
		image: "HUD/genstage/kill yourself",
		accuracy: -1000,
		health: 0.005,
		maxDiff: 9999999,
		score: 0,
		fcRating: "Piece Of Shit",
		color: "#FF0000"
	},
];

var stage:Stage = null;
var JPG = new CustomShader(Paths.shader('JPG'));
var JPEG = new CustomShader(Paths.shader('jpeg_artifacts'));

var HudJPG = new CustomShader(Paths.shader('JPG'));
var HudJPEG = new CustomShader(Paths.shader('jpeg_artifacts'));

var enemyHealth;
var timeLength;

function create() {
	stage = loadStage('genstage');

	FlxG.camera.addShader(JPEG);
    JPEG.data.quality.value = [0.3];
	JPEG.data.blockSize.value = [8.0];

	FlxG.camera.addShader(JPG);
	JPG.data.pixel_size.value = [4];

	camHUD.addShader(HudJPEG);
    HudJPEG.data.quality.value = [0.3];
	HudJPEG.data.blockSize.value = [4.0];

	camHUD.addShader(HudJPG);
	HudJPG.data.pixel_size.value = [1];

	for (i in [dad, boyfriend]) {
		i.characterScript.setVariable("getColors", function(altAnim) { //very illegal, I'd go to prison for this
			var array = [];
			for (num in 0...5) {
				array.push(FlxColor.fromRGB(FlxG.random.int(0,255), FlxG.random.int(0,255), FlxG.random.int(0,255)).color);
			}
			return array;
		});
	}

	enemyHealth = new FlxSprite().loadGraphic(Paths.image('HUD/genstage/HealthBar'));
	timeLength = new FlxSprite().loadGraphic(Paths.image('HUD/genstage/TimeBar'));
}

function update60() {
	LogsOverlay.trace("Make ur mom do the shitty using FlxFuckYou");
}

var sizeBlock = 8.0;
function miss() {
	sizeBlock += 0.2;
	JPEG.data.blockSize.value = [sizeBlock];
	JPG.data.pixel_size.value = [sizeBlock/2];

	HudJPEG.data.blockSize.value = [sizeBlock/2];
	HudJPG.data.pixel_size.value = [sizeBlock/4];
}

function overrideBars(healthMask, timeMask, colors) {
	healthBarBG.color = 0xFFFF0000;
	healthMask.color = 0xFF00FF00;
}

function createPost() {
	if (!engineSettings.downscroll) {
		scoreTxt.y -= guiSize.y / 10 * 9;
	}

	watermark.text = "verwex if you ever do that again i will kill you -Glitch :33"; // - Glitch.Smh :33
	watermark.y -= 0;

	for (i in cpuStrums) {
		i.scrollSpeed = 8;
	}
	for (i in playerStrums) {
		i.scrollSpeed = 1;
	}
}

function update(elapsed) {
	stage.update(elapsed);
}

function beatHit(curBeat) {
	stage.onBeat();
}

function onShowCombo(combo:Int, coolText:FlxText) {
	var tweens:Array<VarTween> = [];

	var rating:FlxSprite = new FlxSprite();
	rating.loadGraphic(lastRating.bitmap);
	rating.screenCenter();
	rating.x = lastCoolText.x - 40;
	rating.y -= 60;
	rating.acceleration.y = 550;
	rating.velocity.y -= FlxG.random.int(140, 175);
	rating.velocity.x -= FlxG.random.int(0, 10);
	rating.antialiasing = lastRating.antialiasing;

	var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('HUD/genstage/combo'));
	comboSpr.screenCenter();
	comboSpr.x = lastCoolText.x;
	comboSpr.acceleration.y = 600;
	comboSpr.velocity.y -= 150;

	comboSpr.velocity.x += FlxG.random.int(1, 10);
	add(rating);
	if (combo >= 10)
	add(comboSpr);

	comboSpr.antialiasing = true;
	rating.scale.x = rating.scale.y = lastRating.scale * 0.7;

	comboSpr.color = boyfriend.getColors()[0];

	var seperatedScore:Array<Int> = [];
	var stringCombo = Std.string(combo);
	for (i in 0...stringCombo.length)
	{
		seperatedScore.push(Std.parseInt(stringCombo.charAt(i)));
	}

	while (seperatedScore.length < 3)
		seperatedScore.insert(0, 0);

	var daLoop:Int = 0;
	var comboColor = boyfriend.getColors()[0];
	for (i in seperatedScore)
	{
		var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('HUD/genstage/' + Std.int(i)));
		numScore.screenCenter();
		numScore.x = lastCoolText.x + (43 * daLoop) - 90;
		numScore.y += 80;

		numScore.antialiasing = true;

		numScore.acceleration.y = FlxG.random.int(200, 300);
		numScore.velocity.y -= FlxG.random.int(140, 160);
		numScore.velocity.x = FlxG.random.float(-5, 5);

		numScore.color = comboColor;

		if (combo >= 10 || combo == 0)
			add(numScore);

		tweens.push(FlxTween.tween(numScore, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				numScore.destroy();
			},
			startDelay: Conductor.crochet * 0.002
		}));

		daLoop++;
	}

	tweens.push(FlxTween.tween(rating, {alpha: 0}, 0.2, {
		startDelay: Conductor.crochet * 0.001
	}));

	tweens.push(FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
		onComplete: function(tween:FlxTween)
		{
			comboSpr.destroy();

			rating.destroy();
		},
		startDelay: Conductor.crochet * 0.001
	}));

	if (engineSettings.maxRatingsAllowed > -1) optimizedTweenSet.push(tweens);

	return false;
}

function creditSetup(songBG, songTitle, creditTexts, creditIcons) {
	for (catIcons in creditIcons) {
		for (icon in catIcons) {
			icon.destroy();
		}
	}
	creditIcons = [];
	PlayState.scripts.setVariable('songIcons', creditIcons);
	songTitle.angle = 0;
	songBG.destroy();

	songTitle.scale.set(0.3, 0.3);
	songTitle.updateHitbox();
	songTitle.x = 80;
	songTitle.y = 20;
	songTitle.alpha = 0;

	for (catText in creditTexts) {
		for (i in 0...catText.length) {
			if (i == 0) {
				catText[i].angle = 0;
				catText[i].scale.x = 1;
				catText[i].updateHitbox();
				catText[i].y = songTitle.y + songTitle.height + 20 + 100 * creditTexts.indexOf(catText);
				catText[i].x = 100;
				catText[0].text += ":";
				catText[0].size = 30;
				catText[0].borderSize = 4;
				catText[0].alpha = 0;
			} else { 
				catText[0].text += " " + catText[i].text + (i < catText.length - 1 ? ',' : '');
			}
		}

		catText = [catText[0]];
	}
	PlayState.scripts.setVariable('songTexts', creditTexts);
}

function creditBehavior(songBG, songTitle, songTexts, songIcons, songTweens) {
	songTweens.push(FlxTween.tween(songTitle, {alpha: 1}, 1, {ease: FlxEase.quartOut}));

	for (catText in songTexts) {
		songTweens.push(FlxTween.tween(catText[0], {alpha: 1}, 1, {ease: FlxEase.quartOut}));
	}
	PlayState.scripts.setVariable('creditTweens', songTweens);

	return 4;
}

function creditEnding(songBG, songTitle, songTexts, songIcons, songTweens) {
	songTweens.push(FlxTween.tween(songTitle, {alpha: 0}, 1, {ease: FlxEase.quartIn}));

	for (catText in songTexts) {
		songTweens.push(FlxTween.tween(catText[0], {alpha: 0}, 1, {ease: FlxEase.quartIn, onComplete: function(tween) {
			PlayState.scripts.executeFunc('creditsDestroy');
		}}));
	}
	PlayState.scripts.setVariable('creditTweens', songTweens);
}
