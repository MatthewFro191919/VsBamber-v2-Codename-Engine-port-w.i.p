import flixel.addons.util.FlxSimplex;

var stage:Stage = null;
//var colorizer = new CustomShader(Paths.shader('colorizer'));

engineSettings.antialiasing = engineSettings.timerSongName = false;

function create() {
	stage = loadStage('exchangetown');

	ogBFY = boyfriend.y;
}

var deathTimer;
var ogBFY;

function update(elapsed) {
	stage.update(elapsed);

	if (justDIED) {
		Conductor.songPosition = -5000;
		Conductor.songPositionOld = -5000;

		var camPos = boyfriend.getCamPos();

		FlxG.camera.angle = 20 * 0.5 * FlxSimplex.simplex(deathTimer.elapsedTime/90 * 25.5, deathTimer.elapsedTime/90 * 25.5);
		camPos.x += 100 * FlxSimplex.simplex(deathTimer.elapsedTime/190 * 100, deathTimer.elapsedTime/190 * 100);
		camPos.y += 100 * FlxSimplex.simplex(deathTimer.elapsedTime/220 * 100, deathTimer.elapsedTime/220 * 100);

		camFollow.setPosition(camPos.x, camPos.y);
		
		if (concluded && controls.ACCEPT) {
			concluded = false;

			FlxG.sound.playMusic(Paths.sound(GameOverSubstate.retrySFX, 'mods/'+mod));
			camHUD.fade(0xFF000000, 2, false, function() {
				justDIED = false;
				deathTimer = null;

				defaultCamZoom -= 0.3;
				FlxG.camera.zoom -= 0.3;

				var camPos = dad.getCamPos();
				camFollow.setPosition(camPos.x, camPos.y);

				FlxG.camera.angle = 0;

				remove(bar);
				remove(vignette);
				FlxG.camera.removeShader(matrixShader);

				unspawnNotes = [];

				hits['Sick'] = hits['Good'] =  hits['Bad'] = hits['Shit'] = combo = misses = songScore = accuracy = numberOfNotes = numberOfArrowNotes = delayTotal = 0;

				pressedArray = [];

				for (i in PlayState.members) {
					if (i != null && i.exists && i.camera == FlxG.camera && i.colorTransform != null) {
						i.colorTransform.redMultiplier = 1;
						i.colorTransform.greenMultiplier = 1;
						i.colorTransform.blueMultiplier = 1;
						i.colorTransform.redOffset = 0;
						i.colorTransform.greenOffset = 0;
						i.colorTransform.blueOffset = 0;
					}
				}

				boyfriend.y = ogBFY;

				for (i in [boyfriend, dad]) { //Makes all characters go into idle. Makes the winner screens look consistent.
					i.lastNoteHitTime = -100000;
					i.dance(true);
				}

				camHUD.fade(0xFF000000, 1, true, function() {
					PlayState.scripts.executeFunc('setCamType', ['default']);

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
	
					health = 4;
	
					remove(strumLineNotes);
					insert(PlayState.members.indexOf(iconGroup), strumLineNotes);
					remove(notes);
					insert(PlayState.members.indexOf(strumLineNotes)+1, notes);
	
					if (engineSettings.watermark) {
						FlxTween.cancelTweensOf(watermark);
					}
	
					for (elem in [
						iconP1, iconP2, scoreText, healthBarBG, timerBG, hitCounter, timerNow, timerFinal, timerText, timerBar, healthBar, watermark
					])
					{
						if (elem != null)
						{
							elem.alpha = 0;
							FlxTween.tween(elem, {alpha: 1}, 0.75, {ease: FlxEase.quartOut});
						}
					}
					FlxTween.tween(healthBar, {alpha: 1}, 0.75, {ease: FlxEase.quartOut});
				});
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

		deathTimer = new FlxTimer().start(1000000);

		PlayState.scripts.executeFunc('reset', []);

		boyfriend.animation.play('firstDeath');

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
				i.alpha = 0;
			}
		}
		iconP1.alpha = iconP2.alpha = 0;

		for (i in strumLineNotes.members) {
			FlxTween.tween(i, {alpha: 0}, 0.0001, {ease: FlxEase.quartInOut, onComplete: function(tween) {
				i.destroy();
				playerStrums.clear();
				cpuStrums.clear();
			}});
		}

		PlayState.scripts.executeFunc('setCamType', ['snap']);

		var camPos = boyfriend.getCamPos();
		camFollow.setPosition(camPos.x, camPos.y);

		FlxG.camera.zoom += 0.4;
		defaultCamZoom += 0.3;

		FlxG.sound.play(Paths.sound('death/trade-wasted', 'mods/'+mod));

		for (i in PlayState.members) {
			if (i != null && i.exists && i.camera == FlxG.camera && i.colorTransform != null) {
				i.colorTransform.blueMultiplier = 0.9;
				i.colorTransform.redOffset = 80;
				i.colorTransform.greenOffset = 80;
				i.colorTransform.blueOffset = -100;

				FlxTween.tween(i.colorTransform, {blueMultiplier: 1, redOffset: -50, greenOffset: -50, blueOffset: -50}, 2.76, {onComplete: function(tween) {
					i.colorTransform.redMultiplier = 2;
					i.colorTransform.greenMultiplier = 2;
					i.colorTransform.blueMultiplier = 2;
					i.colorTransform.redOffset = 0;
					i.colorTransform.greenOffset = 0;
					i.colorTransform.blueOffset = 0;
					FlxTween.tween(i.colorTransform, {redMultiplier: 0.7, greenMultiplier: 0.7, blueMultiplier: 0.7,}, 2);
				}});
			}
		}

		new FlxTimer().start(2.76, function(timer) {
			FlxG.camera.zoom += 0.6;

			var t = 1/3;

			FlxG.camera.addShader(matrixShader);
			matrixShader.data.uOffsets.value = [0,0,0,0];
			matrixShader.data.uMultipliers.value = [t, t, t, 0, t, t, t, 0, t, t, t, 0, 0, 0, 0, 1];

			bar.cameras = vignette.cameras = [camHUD];
			bar.screenCenter();
			vignette.screenCenter();

			vignette.scale.set(0.8, 0.8);
			FlxTween.tween(vignette.scale, {x: 0.9, y: 0.9}, 2, {ease: FlxEase.quartOut});
			add(bar); add(vignette);
		});

		new FlxTimer().start(7, function(timer) {
			concluded = true;

			FlxG.sound.playMusic(Paths.music(GameOverSubstate.gameOverMusic));

			FlxG.sound.music.volume = 1;
			FlxG.sound.music.onComplete = null;
		});

		return false;
	}
}

var matrixShader = new CustomShader(Paths.shader('colorMatrix'));

var bar = new FlxSprite().loadGraphic(Paths.image('HUD/exchangetown/wastedBar'));
var vignette = new FlxSprite().loadGraphic(Paths.image('HUD/exchangetown/pixelVignette'));

function beatHit(curBeat) {
	stage.onBeat();
	
	if (PlayState.SONG.song == 'Trade')
	{
		if (curBeat == 76)
		{
			FlxTween.tween(dad, {angle: 90, y: dad.y + 40, x: dad.x + 40}, 1, {ease: FlxEase.circOut});
			FlxTween.color(dad, 1, 0xFF000000, 0x71C41900, {
				onComplete: function(twn:FlxTween) {
					dad.alpha = 0;
				}
			});
		}
		if (curBeat >= 76)
			dad.animation.play('dead', true);
	}
}
function helicopter() {
	FlxTween.tween(boyfriend, {y: -50000}, 5, {ease: FlxEase.circIn});
}
function postCreate() {
	if (engineSettings.showTimer) {
		timerBG.y = healthBarBG.y + 7 * (engineSettings.downscroll ? 1 : -1);
		timerBar.y = 1000000;

		timerBG.flipY = false;
		timerBG.x += 230;
		timerBar.x += 230;

		timerNow.x = timerBG.x + 30;
	}

	healthBar.y += 12 * (engineSettings.downscroll ? 1 : -1);
	scoreText.y += 30 * (engineSettings.downscroll ? 1 : -1);

	if (!engineSettings.downscroll) scoreText.y -= -2 + scoreText.height;

	healthBarBG.x -= 150;
	healthBar.x -= 145;
	scoreWarning.x -= 150;
	scoreText.x -= 150;

	remove(notes); insert(PlayState.members.indexOf(iconGroup), notes);

	for (i in PlayState.members) if (i != null && i.exists && i.antialiasing != null) i.antialiasing = false;

	maxHealth = 8.2;
	health = maxHealth/2;
}

var lastHealth = 4;

function miss() {
	health -= (lastHealth - health) * 3;
	lastHealth = health;
}

function onPlayerHit(note) {
	lastHealth = health;
}

function onTimerUpdate(elapsed) {
	timerNow.x = timerBG.x + timerBG.width + 10;
	timerText.x = timerNow.x + timerNow.width;
	timerFinal.x = timerText.x + timerText.width;
}