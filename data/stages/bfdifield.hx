import Paths;
import flixel.util.FlxAxes;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxTextBorderStyle;
import flixel.math.FlxMath;

ratings = [
	{
		name: "Nice",
		image: "HUD/bfdifield/Nice",
		accuracy: 1,
		health: 0.035,
		maxDiff: 125 * 0.25,
		score: 350,
		color: "#FFD11A",
		fcRating: "MFC",
		showSplashes: true
	},
	{
		name: "Good",
		image: "HUD/bfdifield/Good",
		accuracy: 3 / 4,
		health: 0.025,
		maxDiff: 125 * 0.4,
		score: 200,
		color: "#1DC0DE",
		fcRating: "GFC"
	},
	{
		name: "Ok",
		image: "HUD/bfdifield/Ok",
		accuracy: 1 / 2,
		health: 0.010,
		maxDiff: 125 * 0.65,
		score: 100,
		color: "#0EC200"
	},
	{
		name: "Bad",
		image: "HUD/bfdifield/Bad",
		accuracy: 1 / 3,
		health: 0.005,
		maxDiff: 125 * 0.8,
		score: 50,
		color: "#880E77"
	},
	{
		name: "Sad",
		image: "HUD/bfdifield/Sad",
		accuracy: 1 / 6,
		health: 0.0,
		maxDiff: 125,
		score: -150,
		color: "#565A6B"
	}
];

var stage:Stage = null;
var otherHitCounter:FlxText = new FlxText(-20, 400, PlayState.guiSize.x, "Misses : 0", 16);

var stage_BlackHole = new FlxSprite(135, -450).loadGraphic(Paths.image('bfdifield/cast_BlackHole'));
var stage_Chatters = new FlxSprite(1175, 5);
var stage_Pillow = new FlxSprite(970, 80).loadGraphic(Paths.image('bfdifield/cast_Pillow'));
var stage_Cloudy = new FlxSprite(-132, -148);
var stage_Marker = new FlxSprite(300, -74);
var stage_Rhythming = new FlxSprite(-273, 31);
var stage_Relaxing = new FlxSprite(426, -62);
var stage_Pie = new FlxSprite(-1055, 160);
var stage_TVGang = new FlxSprite(-827, 56);
var stage_Gelatin = new FlxSprite(802, 288);

var four = new FlxSprite(580, -800);

var gameOverSprite = new FlxSprite().loadGraphic(Paths.image('HUD/bfdifield/Game Over'));

function create() {
	stage = loadStage('bfdifield');
	if (PlayState.SONG.song == 'Corn N Roll'){
		bfdiSecondary = new Character(-400, 30, mod  + ':bfdi-davey');
		add(bfdiSecondary);
		dads.push(bfdiSecondary);
	}

	//recreating the hit counter cuz it's UNOPTMIZED AS SHIT
	//PLUS MAP ORDERING IS NOT POSSIBLE WITH THE JUDGEMENTS I SUPPLIED -Verwex
	if (engineSettings.showRatingTotal) {
		otherHitCounter.setFormat(Paths.font("adelon-serial-bold.ttf"), 16, 0xFFFFFFFF, "right", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		otherHitCounter.antialiasing = true;
		otherHitCounter.cameras = [camHUD];
		otherHitCounter.alpha = 0;
		PlayState.add(otherHitCounter);

		otherHitCounter.text = 'Nice: '+hits['Nice']+'\r\nGood: '+hits['Good']+'\r\nOk: '+hits['Ok']+'\r\nBad: '+hits['Bad']+'\r\nSad: '+hits['Sad'];
		otherHitCounter.y = (guiSize.y / 2) - (otherHitCounter.height / 2);
	}
}

function createPost() {
	insert(PlayState.members.indexOf(gf), stage_BlackHole);
	insert(PlayState.members.indexOf(gf), stage_Pillow);

	stage_Chatters.frames = Paths.getSparrowAtlas("bfdifield/cast_Chatters", mod);
	stage_Chatters.animation.addByPrefix("idle", "Chatters_Idle", 24, true);
	stage_Chatters.animation.addByPrefix("gasp", "Chatters_Gasp", 24, false);
	stage_Chatters.animation.play("idle");
	insert(PlayState.members.indexOf(gf), stage_Chatters);

	stage_Marker.frames = Paths.getSparrowAtlas("bfdifield/cast_Marker", mod);
	stage_Marker.animation.addByPrefix("idle", "Marker_Idle", 24, false);
	stage_Marker.animation.addByPrefix("gasp", "Marker_Gasp", 24, false);
	stage_Marker.animation.play("idle");
	insert(PlayState.members.indexOf(gf), stage_Marker);

	stage_Cloudy.frames = Paths.getSparrowAtlas("bfdifield/cast_Cloudy", mod);
	stage_Cloudy.animation.addByPrefix("idle", "Cloudy_Idle", 24, false);
	stage_Cloudy.animation.addByPrefix("gasp", "Cloudy_Gasp", 24, false);
	stage_Cloudy.animation.play("idle");
	insert(PlayState.members.indexOf(gf), stage_Cloudy);

	stage_Relaxing.frames = Paths.getSparrowAtlas("bfdifield/cast_Relaxing", mod);
	stage_Relaxing.animation.addByPrefix("idle", "Relaxing_Idle", 24, true);
	stage_Relaxing.animation.addByPrefix("gasp", "Relaxing_Gasp", 24, false);
	stage_Relaxing.animation.play("idle");
	insert(PlayState.members.indexOf(gf), stage_Relaxing);

	stage_Gelatin.frames = Paths.getSparrowAtlas("bfdifield/cast_Gelatin", mod);
	stage_Gelatin.animation.addByPrefix("idle", "Gelatin_Idle", 24, true);
	stage_Gelatin.animation.addByPrefix("gasp", "Gelatin_Gasp", 24, false);
	stage_Gelatin.animation.play("idle");
	insert(PlayState.members.indexOf(gf), stage_Gelatin);

	stage_Rhythming.frames = Paths.getSparrowAtlas("bfdifield/cast_Rhythmic", mod);
	stage_Rhythming.animation.addByPrefix("idle", "Rhythmic_Gang_Idle", Conductor.crochet / 24 * 2, false);
	stage_Rhythming.animation.addByIndices("idleReversed", "Rhythmic_Gang_Idle", [15,14,13,12,11,10,9,8,7,6,5,4,3,2,1], '', Conductor.crochet / 24 * 2, false);
	stage_Rhythming.animation.addByPrefix("gasp", "Rhythmic_Gang_Gasp", 24, false);
	stage_Rhythming.animation.play("idle");
	insert(PlayState.members.indexOf(gf), stage_Rhythming);

	stage_TVGang.frames = Paths.getSparrowAtlas("bfdifield/cast_TVGang", mod);
	stage_TVGang.animation.addByPrefix("idle", "TV_Gang_Idle", 24, false); //It doesn't trigger the finish Callback if it's looped so I have to make one of my own to manage a special easter egg
	stage_TVGang.animation.addByPrefix("decipher", "TV_Gang_Decipher", 24, false);
	stage_TVGang.animation.addByPrefix("gasp", "TV_Gang_Gasp", 24, false);
	stage_TVGang.animation.play("idle");
	stage_TVGang.animation.finishCallback = function(name){
		loopCount++;
		stage_TVGang.animation.play("idle", true);

		if (loopCount > 51) {
			stage_TVGang.animation.play("decipher", true);
			stage_TVGang.animation.finishCallback = function(name) {
				stage_TVGang.animation.play("idle", true);
				stage_TVGang.animation.finishCallback = function(name){
					stage_TVGang.animation.play("idle", true);
				};
			}
		}
	}
	insert(PlayState.members.indexOf(gf), stage_TVGang);

	stage_Pie.frames = Paths.getSparrowAtlas("bfdifield/cast_Pie", mod);
	stage_Pie.animation.addByPrefix("idle", "Pie_Idle", 24, false);
	stage_Pie.animation.addByIndices("idleReversed", "Pie_Idle", [15,14,13,12,11,10,9,8,7,6,5,4,3,2,1], '', 24, false);
	stage_Pie.animation.addByPrefix("gasp", "Pie_Gasp", 24, false);
	stage_Pie.animation.play("idle");
	insert(PlayState.members.indexOf(gf), stage_Pie);

	four.frames = Paths.getSparrowAtlas("bfdifield/four", mod);
	four.animation.addByPrefix("appearance", "Four_Appearance", 24, false);
	four.animation.addByPrefix("action", "Four_Action", 24, false);
	four.animation.addByPrefix("confirm", "Four_Confirm", 24, false);
	four.animation.addByPrefix("punish", "Four_Punish", 24, false);
	four.animation.addByPrefix("lesson", "Four_Lesson", 24, false);
	four.animation.play("appearance");
	insert(2, four);

	gameOverSprite.screenCenter();
	gameOverSprite.y = 0 - gameOverSprite.height;
	gameOverSprite.cameras = [camHUD];
	add(gameOverSprite);
}

var loopCount = 0;

function beatHit(curBeat) {
	if (curBeat % 2) {
		stage_Marker.animation.play("idle", true);
		stage_Cloudy.animation.play("idle", true);
	}
		
	stage_Pie.animation.play("idle" + (curBeat % 2 ? 'Reversed' : ''), true);
	stage_Rhythming.animation.play("idle" + (curBeat % 2 ? 'Reversed' : ''), true);
}

function onGuiPopup() {
	if (engineSettings.showRatingTotal) {
		hitCounter.destroy();
	}
	
	if (otherHitCounter != null) {
		FlxTween.tween(otherHitCounter, {alpha: 1}, 0.75, {ease: FlxEase.quartInOut});
	}
}

function onShowCombo(combo:Int, coolText:FlxText) {
	otherHitCounter.text = 'Nice: '+hits['Nice']+'\r\nGood: '+hits['Good']+'\r\nOk: '+hits['Ok']+'\r\nBad: '+hits['Bad']+'\r\nSad: '+hits['Sad'];
	otherHitCounter.y = (guiSize.y / 2) - (otherHitCounter.height / 2);

	return true;
}

function update(elapsed) {
	if (justDIED) {
		Conductor.songPosition = -5000;
		Conductor.songPositionOld = -5000;

		var camPos = boyfriend.getCamPos();
		camFollow.setPosition(camPos.x + 550, camPos.y + 50);
		
		if (concluded && controls.ACCEPT) {
			concluded = false;
			unspawnNotes = [];

			hits['Sick'] = hits['Good'] =  hits['Bad'] = hits['Shit'] = combo = misses = songScore = accuracy = numberOfNotes = numberOfArrowNotes = delayTotal = 0;

			pressedArray = [];

			FlxTween.tween(gameOverSprite, {y: gameOverSprite.y - gameOverSprite.height}, 1, {ease: FlxEase.quartInOut});

			FlxG.sound.playMusic(Paths.sound(GameOverSubstate.retrySFX, 'mods/'+mod), 0.1);
			FlxG.sound.play(Paths.sound('bfdi/four_confirm', 'mods/'+mod));

			four.animation.play('confirm');
			FlxSpriteUtil.flicker(boyfriend, 0.5, 0.01, false);

			four.animation.finishCallback = function(name) {
				four.animation.play('action');
				boyfriend.animation.play('deathConfirm');
				boyfriend.visible = true;

				four.animation.finishCallback = null;

				FlxG.sound.play(Paths.sound('bfdi/recover', 'mods/'+mod));

				boyfriend.scale.set(0,0);
				boyfriend.angle = -360 * 3;

				FlxTween.tween(boyfriend.scale, {y: 1, x: 1}, 2);
				FlxTween.tween(boyfriend, {angle: 0}, 2);
			};

			new FlxTimer().start(3.5, function(timer) {
				four.animation.play('lesson');
				FlxG.sound.play(Paths.sound('bfdi/four_lesson', 'mods/'+mod));

				FlxTween.tween(four, {y: four.y - 940}, 2, {onComplete: function (tween) {
					four.animation.play('appearance');
					remove(four);
					insert(2, four);

					justDIED = false;
					paused = false;
					blockPlayerInput = false;
					engineSettings.resetButton = wasResetButton;
					boyfriend.stunned = false;

					strumLineNotes.clear();
					playerStrums.clear();
					cpuStrums.clear();

					FlxG.sound.music.stop();
					inst = null;
					generateSong(PlayState.SONG.song);
					startCountdown();

					PlayState.scripts.executeFunc('setSplashes', []);

					health = 1;

					remove(strumLineNotes);
					insert(PlayState.members.indexOf(PlayState.scripts.getVariable('bar2'))+1, strumLineNotes);
					remove(notes);
					insert(PlayState.members.indexOf(strumLineNotes)+1, notes);

					if (engineSettings.watermark) {
						FlxTween.cancelTweensOf(watermark);
					}

					otherHitCounter.text = 'Nice: '+hits['Nice']+'\r\nGood: '+hits['Good']+'\r\nOk: '+hits['Ok']+'\r\nBad: '+hits['Bad']+'\r\nSad: '+hits['Sad'];
					otherHitCounter.y = (guiSize.y / 2) - (otherHitCounter.height / 2);

					for (elem in [
						iconP1, iconP2, scoreText, healthBarBG, timerBG, otherHitCounter, timerNow, timerFinal, timerText, timerBar, healthBar, watermark
					])
					{
						if (elem != null)
						{
							elem.alpha = 0;
							FlxTween.tween(elem, {alpha: 1}, 0.75, {ease: FlxEase.quartOut});
						}
					}
					FlxTween.tween(healthBar, {alpha: 1}, 0.75, {ease: FlxEase.quartOut});

					for (i in [boyfriend, dad, bfdiSecondary]) { //Makes all characters go into idle. Makes the winner screens look consistent.
						i.lastNoteHitTime = -100000;
						i.dance(true);
					}

					for (i in [stage_Chatters, stage_Gelatin, stage_Relaxing, stage_TVGang, stage_Cloudy, stage_Marker]) {
						i.animation.play('idle');
					}

					loopCount = 0;
					stage_TVGang.animation.finishCallback = function(name){
						loopCount++;
						stage_TVGang.animation.play("idle", true);
				
						if (loopCount > 51) {
							stage_TVGang.animation.play("decipher", true);
							stage_TVGang.animation.finishCallback = function(name) {
								stage_TVGang.animation.play("idle", true);
								stage_TVGang.animation.finishCallback = function(name){
									stage_TVGang.animation.play("idle", true);
								};
							}
						}
					}

					gf.animation.curAnim.looped = true;
					gf.animation.curAnim.curFrame = 0;
				}});
			});
		}

		if (concluded && controls.BACK) {
			FlxG.save.data.vs_bamber_hasDiedInThisSong = null;
			FlxG.switchState(new FreeplayState());
		}
	}
}

var justDIED = false;
var concluded = false;
var wasResetButton = engineSettings.resetButton;

function onOpenSubstate(substate) {
	if (health <= 0) {
		health = 0.001;

		for (i in FlxG.sound.list.members) {
			i.stop();
		}
		vocals.volume = 1;

		FlxTween.globalManager._tweens = [];
		FlxTimer.globalManager._timers = [];

		PlayState.scripts.executeFunc('onPsychEvent', ['Change Default Zoom', 0.75]);
		PlayState.scripts.executeFunc('reset', []);

		notes.clear();
		for (e in events) events.remove(e);

		justDIED = true;
		blockPlayerInput = true;
		currentSustains = [];
		generatedMusic = false;
		persistentUpdate = true;
		persistentDraw = true;
		engineSettings.resetButton = false;
		startingSong = true;
		startedCountdown = false;
		guiElemsPopped = false;
		startTimer = null;

		for (i in PlayState.members) {
			if (i != null && i.exists && i.camera == camHUD && i.alpha != null && ![PlayState.scripts.getVariable('bar1'), PlayState.scripts.getVariable('bar2')].contains(i)) {
				FlxTween.tween(i, {alpha: 0}, 0.75, {ease: FlxEase.quartIn});
			}
		}

		FlxTween.tween(iconP1, {alpha: 0}, 0.75, {ease: FlxEase.quartIn});
		FlxTween.tween(iconP2, {alpha: 0}, 0.75, {ease: FlxEase.quartIn});

		for (i in strumLineNotes.members) {
			FlxTween.tween(i, {alpha: 0}, 1, {ease: FlxEase.quartInOut, onComplete: function(tween) {
				i.destroy();
				playerStrums.clear();
				cpuStrums.clear();
			}});
		}

		FlxG.sound.play(Paths.sound('bfdi/gasp', 'mods/'+mod));
		for (i in [stage_BlackHole, stage_Chatters, stage_Cloudy, stage_Gelatin, stage_Marker, stage_Pie, stage_Relaxing, stage_Rhythming, stage_TVGang, dad, bfdiSecondary]) {
			if (i != stage_BlackHole) i.animation.play('gasp', true);
			if (i == stage_TVGang) i.animation.finishCallback = null;

			i.y -= 20;
			i.scale.set(0.8, 1.2);
			FlxTween.tween(i, {y: i.y+20}, 0.5, {ease: FlxEase.quartOut});
			FlxTween.tween(i.scale, {x: 1, y: 1}, 0.5, {ease: FlxEase.quartOut});
		}

		gf.animation.curAnim.looped = false;
		gf.animation.curAnim.curFrame = gf.animation.curAnim.frames.length - 1;

		boyfriend.playAnim('firstDeath', true);

		new FlxTimer().start(1, function(timer) {
			FlxTween.tween(four, {y: four.y + 940}, 2, {onComplete: function (tween) {
				four.animation.play('punish');
				FlxG.sound.play(Paths.sound('bfdi/four_punish', 'mods/'+mod));
				four.animation.finishCallback = function(name) {
					gameOverSprite.alpha = 1;
					FlxTween.tween(gameOverSprite, {y: gameOverSprite.y + gameOverSprite.height}, 1, {ease: FlxEase.quartInOut});

					four.animation.play('action');
					FlxG.sound.play(Paths.sound('bfdi/mutilation', 'mods/'+mod));
					four.animation.finishCallback = null;

					boyfriend.playAnim('deathLoop', true);
					boyfriend.animation.finishCallback = function(name) {
						four.animation.play('appearance');
						boyfriend.animation.finishCallback = null;
						concluded = true;

						FlxG.sound.playMusic(Paths.music(GameOverSubstate.gameOverMusic));

						FlxG.sound.music.volume = 1;
						FlxG.sound.music.onComplete = null;
					}
				}
			}});
		});

		new FlxTimer().start(2, function(timer) {
			remove(four); insert(3, four);
			new FlxTimer().start(0.2, function(timer) {
				remove(four); insert(PlayState.members.indexOf(stage_Chatters), four);
				new FlxTimer().start(0.2, function(timer) {
					remove(four); insert(PlayState.members.indexOf(stage_Relaxing), four);
					new FlxTimer().start(0.2, function(timer) {
						remove(four); insert(PlayState.members.indexOf(stage_Gelatin), four);
						new FlxTimer().start(0.2, function(timer) {
							remove(four); insert(PlayState.members.indexOf(boyfriend), four);
						});
					});
				});
			});
		});

		return false;
	}
}

function countdownBehavior(count, overrideSprite) {
	if (count == 3) {
		overrideSprite.scale.set(0.4, 1.5);
		overrideSprite.y += guiSize.y;

		FlxTween.tween(overrideSprite, {y: overrideSprite.y - guiSize.y}, PlayState.startTimer.time * 0.5, {ease: FlxEase.backOut});
		FlxTween.tween(overrideSprite.scale, {y: 1, x: 1}, PlayState.startTimer.time * 0.3, {ease: FlxEase.backOut});
	} else if (count == 0) {
		FlxTween.tween(overrideSprite, {y: overrideSprite.y + guiSize.y}, PlayState.startTimer.time * 0.5, {ease: FlxEase.quartIn, startDelay: PlayState.startTimer.time * 0.5});
		FlxTween.tween(overrideSprite.scale, {y: 1.3, x: 0.6}, PlayState.startTimer.time * 0.3, {ease: FlxEase.quartIn, startDelay: PlayState.startTimer.time * 0.5});
	}
}

function creditSetup(songBG, songTitle, creditTexts, creditIcons) {
	songBG.alpha = 1;
	songBG.screenCenter();
	songBG.scale.set(1,0);
	remove(songBG); insert(PlayState.members.indexOf(strumLineNotes), songBG);

	songTitle.destroy();

	for (catText in creditTexts) {
		for (i in catText) {
			i.destroy();
		}
	}

	for (catIcons in creditIcons) {
		for (i in catIcons) {
			i.destroy();
		}
	}

	PlayState.scripts.setVariable('songIcons', []);
	PlayState.scripts.setVariable('songTexts', []);
}

function creditBehavior(songBG, songTitle, songTexts, songIcons, songTweens) {
	songTweens.push(FlxTween.tween(songBG.scale, {y: 1}, 0.5, {ease: FlxEase.backOut}));

    PlayState.scripts.setVariable('creditTweens', songTweens);

	return 4;
}


function creditEnding(songBG, songTitle, songTexts, songIcons, songTweens) {
	songTweens.push(FlxTween.tween(songBG.scale, {y: 0}, 0.5, {ease: FlxEase.backIn}));

    PlayState.scripts.setVariable('creditTweens', songTweens);
}