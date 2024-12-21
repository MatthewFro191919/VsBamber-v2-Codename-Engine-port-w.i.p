import Settings;
import WaveformSprite;
import lime.media.AudioBuffer;
import lime.utils.Assets;
import flixel.text.FlxTextBorderStyle;
import Character;
import Note;
import flixel.math.FlxPoint;
import ScoreText;
import flixel.util.FlxAxes;
import flixel.ui.FlxBar;
import Main;
import openfl.text.TextFormat;
import flixel.util.FlxSpriteUtil;

var stage:Stage = null;
var fisheye = new CustomShader(Paths.shader('fisheye'));

var instBuffer = AudioBuffer.fromFile(Assets.getPath(Paths.modInst(PlayState_.SONG.song, PlayState_.songMod, PlayState_.storyDiffifculty)));
var waveformI = new WaveformSprite(-1200, 750, instBuffer, 300, 150);

var voiceBuffer = AudioBuffer.fromFile(Assets.getPath(Paths.modVoices(PlayState_.SONG.song, PlayState_.songMod, PlayState_.storyDiffifculty)));
var waveformV = new WaveformSprite(-1200, 1150, voiceBuffer, 300, 75);

engineSettings.scoreTextSize = 25;
engineSettings.animateMsLabel = engineSettings.showPressDelay = engineSettings.showRating = engineSettings.alphabetOutline = engineSettings.showRatingTotal = engineSettings.watermark = engineSettings.smoothHealthbar = false;

var fakeScoreText; //To simulate the changes in score.

var newTimerBar;

var rankingTexts = [
	["You Suck!",0.2],
	["Shit",0.4],
	["Bad",0.5],
	["Bruh",0.6],
	["Meh",0.69],
	["Nice",0.7],
	["Good",0.8],
	["Great",0.9],
	["Sick!",1],
	["Perfect!!",1]
];

function create() {
	stage = loadStage('hot_farm');
	if (Settings.engineSettings.stageQuality != "medium" || Settings.engineSettings.stageQuality != "low")
		initializeShaders();

	waveformI.scrollFactor.set(0.65, 0.65);
	waveformI.color = 0x55FF0000;
	waveformI.origin.set();
	waveformI.scale.set(2.5, 40);

	waveformV.scrollFactor.set(0.9, 0.9);
	waveformV.color = 0x55FF00FF;
	waveformV.origin.set();
	waveformV.scale.set(2.5, 40);
	
	insert(3, waveformI);
	insert(8, waveformV);

	waveformI.antialiasing = waveformV.antialiasing = false;
	waveformI.angle = waveformV.angle = 270;
	waveformI.alpha = waveformV.alpha = 0.4;
	waveformI.blend = waveformV.blend = 0;

	for (i in PlayState.members) {
		if (i != null && Std.isOfType(i, Character)) {
			i.colorTransform.redMultiplier = 0.65*0.8;
			i.colorTransform.greenMultiplier = 0.4*0.8;
			i.colorTransform.blueMultiplier = 0.8;
			i.colorTransform.blueOffset -= 10;
		}
	}
}
function createPost() {
	PlayState.scripts.executeFunc('setCamType', ['classic']);

	fakeScoreText = new FlxText(healthBar.x + (healthBar.width * 0.28), 0, guiSize.x, "A", 20);
	fakeScoreText.setFormat(Paths.font("vcr_osd.ttf"), Std.int(engineSettings.scoreTextSize), 0xFFFFFFFF, 'center', FlxTextBorderStyle.OUTLINE, 0xFF000000);
	fakeScoreText.borderSize = 1.5;
	fakeScoreText.cameras = [camHUD];
	fakeScoreText.screenCenter();
	fakeScoreText.y = healthBarBG.y + (engineSettings.downscroll ? 60 : 30);
	add(fakeScoreText);
	fakeScoreText.alpha = 0;
	FlxTween.tween(fakeScoreText, {alpha: 1}, 0.75, {ease: FlxEase.quartInOut});
	fakeScoreText.text = 'Score: ' + songScore + (engineSettings.showMisses ? ' | Misses: ' + misses : '') + (engineSettings.showAccuracy ? ' | Rating: ?' : '');

	scoreText.visible = false;

	if (engineSettings.middleScroll) {
		for (i in 0...cpuStrums.length) {
			PlayState.getStrum(i).x = (guiSize.x / 4) - (PlayState.SONG.keyNumber / 2 * Note.swagWidth) + (Note.swagWidth * i);
			PlayState.getStrum(i).visible = true;
			PlayState.getStrum(i).notes_alpha = PlayState.getStrum(i).alpha = 0.5;

			if (i > 1) {
				PlayState.getStrum(i).x += guiSize.x / 2 + 25;
			}
		}
	}

	if (engineSettings.showTimer) {
		timerFinal.visible = false;
		timerBG.visible = false;
		timerBar.visible = false;

		if (engineSettings.timerSongName) timerNow.visible = false;

		(engineSettings.timerSongName ? timerText : timerNow).size = 24;
		(engineSettings.timerSongName ? timerText : timerNow).borderSize = 2;
		(engineSettings.timerSongName ? timerText : timerNow).visible = false;

		newTimerBar = new FlxBar(timerBG.x + 4, timerBG.y + 4, 'LEFT_TO_RIGHT', Std.int(timerBG.width - 8), Std.int(timerBG.height - 8));
		if (!engineSettings.downscroll) newTimerBar.y += timerBG.height - 4;
		newTimerBar.cameras = [camHUD];
		newTimerBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		newTimerBar.alpha = 0;
		newTimerBar.visible = false;
		insert(members.indexOf(timerBG), newTimerBar);
	}

	comboGlow = new FlxSprite().loadGraphic(Paths.image('HUD/hotline/ComboGlow'));
	comboGlow.screenCenter();
	comboGlow.cameras = [camHUD];
	comboGlow.y = engineSettings.middleScroll ? strumLine.y - 400 : strumLine.y; 
	insert(PlayState.members.indexOf(scoreText), comboGlow);

	comboText = new FlxText(0, 0, guiSize.x, "???? x0", 20);
	comboText.setFormat(scoreText.font, 30, 0xFFFFFFFF, 'center', FlxTextBorderStyle.OUTLINE, 0xFF000000);
	comboText.borderSize = 1.5;
	comboText.cameras = [camHUD];
	comboText.screenCenter();
	comboText.y = comboGlow.y + 10;
	insert(PlayState.members.indexOf(comboGlow) + 1, comboText);

	comboModifier = new FlxText(0, 0, guiSize.x, "+0", 20);
	comboModifier.setFormat(scoreText.font, 20, 0xFFFFFFFF, 'center', FlxTextBorderStyle.OUTLINE, 0xFF000000);
	comboModifier.borderSize = 1.5;
	comboModifier.cameras = [camHUD];
	comboModifier.screenCenter();
	comboModifier.y = comboText.y + comboText.height - 20;
	insert(PlayState.members.indexOf(comboGlow) + 1, comboModifier);

	comboScore = new FlxText(0, 0, guiSize.x, "0", 20);
	comboScore.setFormat(scoreText.font, 40, 0xFFFFFFFF, 'center', FlxTextBorderStyle.OUTLINE, 0xFF000000);
	comboScore.borderSize = 1.5;
	comboScore.cameras = [camHUD];
	comboScore.screenCenter();
	comboScore.y = comboModifier.y + comboModifier.height - 10;
	insert(PlayState.members.indexOf(comboGlow) + 1, comboScore);

	comboGlow.y -= 10;

	comboGlow.alpha = comboText.alpha = comboModifier.alpha = comboScore.alpha = 0;
}

function postCreate() {
	Main.fps.defaultTextFormat = new TextFormat(Paths.font('_sans'), 14, Main.fps.color);
}

function musicstart() {
	if (timerText != null) {
		newTimerBar.setParent(Conductor, "songPosition");
		newTimerBar.setRange(0, Math.max(inst.length, 1000));

		newTimerBar.visible = true;
		FlxTween.tween(newTimerBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		(engineSettings.timerSongName ? timerText : timerNow).alpha = 0;
		(engineSettings.timerSongName ? timerText : timerNow).visible = true;
		FlxTween.tween((engineSettings.timerSongName ? timerText : timerNow), {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		timerBG.alpha = 0;
		timerBG.visible = true;
		FlxTween.tween(timerBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
	}
}

function initializeShaders()
{
	FlxG.camera.addShader(fisheye);
	fisheye.data.MAX_POWER.value = [.15];
}
var fisheyePower:Float = 0.15;

function update60(elapsed) {
	stage.update(elapsed);
	fisheyePower = FlxMath.lerp(fisheyePower, 0.15, 0.07);
	fisheye.data.MAX_POWER.value = [fisheyePower];

	waveformI.generateFlixel(Conductor.songPosition, Conductor.songPosition + 200);
	waveformV.generateFlixel(Conductor.songPosition - 200, Conductor.songPosition);

	if (vocals != null) waveformV.scale.y = 40 * vocals.volume;
}

function updatePost(elapsed) {
	scoreWarning.y = strumLine.y + strumLineNotes.members[0].height/2 - scoreWarning.height/2;

	if (engineSettings.showTimer && !engineSettings.timerSongName) { 
		timerText.alpha = 0;
		timerNow.screenCenter(FlxAxes.X);
	}

	for (i in generalComboTweens) i.active = !paused;
    if (comboTimer != null) comboTimer.active = !paused;
}

var accuracyText = '?';
function miss() {
	if (!engineSettings.botplay) calculateRating();
	PlayState.songScore = holdScore;
	fakeScoreText.text = 'Score: ' + songScore + (engineSettings.showMisses ? ' | Misses: ' + misses : '') + (engineSettings.showAccuracy ? ' | Rating: ' + accuracyText : '');
}

var scoreTxtTween;
function onPlayerHit(note) {
	if (!engineSettings.botplay) { 
		calculateRating();
		if(engineSettings.animateInfoBar) {
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			fakeScoreText.scale.x = 1.075;
			fakeScoreText.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(fakeScoreText.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
	}
	fakeScoreText.text = 'Score: ' + songScore + (engineSettings.showMisses ? ' | Misses: ' + misses : '') + (engineSettings.showAccuracy ? ' | Rating: ' + accuracyText : '');
}

function calculateRating() {
	var ratingName = '';

	if (PlayState.get_accuracy_() >= 1) ratingName = rankingTexts[rankingTexts.length - 1][0];
	else {
		for (i in 0...rankingTexts.length)
		{
			if(PlayState.get_accuracy_() < rankingTexts[i][1])
			{
				ratingName = rankingTexts[i][0];
				break;
			}
		}
	}

	var advancedRating = "";
    if (numberOfArrowNotes > 0) {
        if (misses == 0) {
            var t = "FC";
            for (r in ratings) {
                if (hits[r.name] > 0 && r.fcRating != null) {
                    t = r.fcRating;
                    }
                }
            advancedRating = t;
        }
    	else if (misses < 10) advancedRating = "SDCB"
		else if (numberOfArrowNotes > 0) advancedRating = "Clear";
    }


	accuracyText = ratingName + ' (' + (Math.floor(PlayState.get_accuracy_() * 10000) / 100) + '%) - ' + advancedRating;
}

function beatHit(curBeat) {
	stage.onBeat();
}

var creditHeaders = [];

function creditSetup(songBG, songTitle, creditTexts, creditIcons) {
	songBG.destroy();
	songTitle.destroy();
	
	for (i in creditIcons) {
		for (icon in i) {
			icon.destroy();
		}
	}
	PlayState.scripts.setVariable('songIcons', []);

	creditTexts[0][0].angle = creditTexts[0][1].angle = 0;

	for (catText in creditTexts) {
		if (creditTexts.indexOf(catText) != 0) creditTexts[0][0].text += creditTexts[creditTexts.indexOf(catText)][0].text;

		for (i in 0...catText.length) {
			if (i == 0) {
				creditTexts[0][0].text += " by";
			} else {
				creditTexts[0][0].text += " " + catText[i].text + (i < catText.length - 2 ? ',' : i == catText.length - 2 ? ' &' : ' ');
			}
		}
		creditTexts[0][0].text += "\n";
	}
	creditTexts[0][1].text = creditTexts[0][0].text;
	creditTexts[0][1].scale.x = 1;
	creditTexts[0][1].updateHitbox();

	creditTexts[0][0].text = 'SCREENCAST';
	creditTexts[0][0].size = 40;
	creditTexts[0][1].size = 20;
	creditTexts[0][0].font = Paths.font('Coco-Sharp-Heavy-Italic-trial');

	creditTexts[0][0].y = 190;
	creditTexts[0][1].y = creditTexts[0][0].y + creditTexts[0][0].height + 15;

	creditTexts[0][0].x = creditTexts[0][1].x = 20;

	creditTexts = [creditTexts[0]];

	for (i in 0...creditTexts[0].length) {
		var creditHead = new FlxSprite(0, creditTexts[0][i].y - 10).makeGraphic(creditTexts[0][i].width + 80,creditTexts[0][i].height + 15,0x88000000);
		creditHead.cameras = [camHUD];
		insert(PlayState.members.indexOf(creditTexts[0][i]), creditHead);

		creditHead.x -= creditHead.width;
		creditTexts[0][i].x -= creditHead.width;

		creditHeaders.push(creditHead);
	}

	creditTexts[0][1].y += 15;

	PlayState.scripts.setVariable('songTexts', creditTexts);
}

function creditBehavior(songBG, songTitle, songTexts, songIcons, songTweens) {
	for (i in 0...songTexts[0].length) {
		songTweens.push(FlxTween.tween(creditHeaders[i], {x: 0}, 1, {ease: FlxEase.quartOut}));
		songTweens.push(FlxTween.tween(songTexts[0][i], {x: songTexts[0][i].x + creditHeaders[i].width}, 1, {ease: FlxEase.quartOut}));
	}
	PlayState.scripts.setVariable('creditTweens', songTweens);
	return 4;
}

function creditEnding(songBG, songTitle, songTexts, songIcons, songTweens) {
	for (i in 0...songTexts[0].length) {
		songTweens.push(FlxTween.tween(creditHeaders[i], {x: creditHeaders[i].x - creditHeaders[i].width}, 1, {ease: FlxEase.quartIn}));
		songTweens.push(FlxTween.tween(songTexts[0][i], {x: songTexts[0][i].x - creditHeaders[i].width}, 1, {ease: FlxEase.quartIn, onComplete: function(tween) {
			PlayState.scripts.executeFunc('creditsDestroy');
			creditHeaders[i].destroy();
		}}));
	}
	PlayState.scripts.setVariable('creditTweens', songTweens);
}

var comboTimer;
var generalComboTweens = [];

var comboText;
var comboModifier;
var comboScore;
var comboGlow;

var tempCombo:Int = 0;
var tempScore:Int = 0;

var comboTextTweens = [];
var comboRatings = [];

var holdScore = 0;

function onShowCombo(combo:Int, coolText:FlxText) {
	PlayState.songScore = holdScore;

	if (comboTimer != null) comboTimer.cancel();
	for (i in generalComboTweens) { if (i != null) i.cancel(); }

	if (combo >= 1) tempCombo++;
	if (combo != tempCombo) combo = tempCombo;

	comboText.alpha = comboModifier.alpha = comboScore.alpha = 1;
	comboGlow.alpha = 0.3;

	comboText.text = lastRating.name + ' x' + tempCombo;
	comboModifier.text = (lastRating.score > 0 ? '+' : '') + lastRating.score;

	tempScore += lastRating.score;
	comboScore.text = tempScore;

	for (i in comboTextTweens) { if (i != null) i.cancel(); }
	for (i in [comboText, comboModifier, comboScore]) {
		i.scale.x = 1.075;
		i.scale.y = 1.075;
		comboTextTweens.push(FlxTween.tween(i.scale, {x: 1, y: 1}, 0.2));
	}

	comboRatings.push(lastRating.name);

	comboTimer = new FlxTimer().start(2, function(timer:FlxTimer) {
		comboModifier.alpha = 0;

		comboText.text = (comboRatings.contains('Shit') ? 'Whoops...' : (comboRatings.contains('Bad') ? 'Nice!' : (comboRatings.contains('Good') ? 'Great!' : 'Perfect!')));
		comboRatings = [];

		FlxSpriteUtil.flicker(comboText);
		tempCombo = 0;

		generalComboTweens.push(FlxTween.num(tempScore, 0, 0.5, {}, function(num:Int) {
			num = Math.round(num);

			PlayState.songScore += tempScore - num;
			tempScore = num;
			comboScore.text = tempScore;
			holdScore = PlayState.songScore;

			fakeScoreText.text = 'Score: ' + songScore + (engineSettings.showMisses ? ' | Misses: ' + misses : '') + (engineSettings.showAccuracy ? ' | Rating: ' + accuracyText : '');

			generalComboTweens.push(FlxTween.tween(comboText, {alpha: 0}, 1));
			generalComboTweens.push(FlxTween.tween(comboScore, {alpha: 0}, 1));
			generalComboTweens.push(FlxTween.tween(comboGlow, {alpha: 0}, 1));
		}));
	});

	return false;
}