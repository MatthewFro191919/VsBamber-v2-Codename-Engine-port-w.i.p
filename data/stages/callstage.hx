import flixel.math.FlxRect;
import flixel.system.FlxSound;

var stage:Stage = null;
var strumPos = [];

var callstage; var bamberstage; var barrier; //Stage Assets from the Stage Editor

function create() {
	stage = loadStage('callstage');

	callstage = stage.getSprite('callstage'); //Who knew getting assets from the stage editor is so simple
	bamberstage = stage.getSprite('bamberstage');
	barrier = stage.getSprite('barrier');
}

function overrideBars(healthMask, timeMask, colors) {
	healthBarBG.flipX = healthMask.flipX = true;
}

var gameOverSprite = new FlxSprite().loadGraphic(Paths.image('HUD/callstage/disconnect'));

function createPost() {
	repositionNotes();
	PlayState.iconP2.changeCharacter(PlayState.boyfriend.curCharacter, mod);
	PlayState.iconP1.changeCharacter(PlayState.dad.curCharacter, mod);

	gameOverSprite.cameras = [camHUD];
	gameOverSprite.centerOrigin();
	gameOverSprite.screenCenter();
	insert(10000, gameOverSprite);

	gameOverSprite.angle = -720;
	gameOverSprite.scale.set(4,4);

	defaultPos = [boyfriend.x, dad.x];
}

function repositionNotes() {
	strumPos = [];

	for (i in 0...PlayState.playerStrums.length)
		strumPos.push(PlayState.playerStrums.members[i].x);
	for (i in 0...PlayState.playerStrums.length)
		strumPos.push(PlayState.cpuStrums.members[i].x);

	if (!engineSettings.middleScroll) {
		for (i in 0...PlayState.playerStrums.length)
		{
			PlayState.playerStrums.members[i].x = strumPos[i + 4];
			PlayState.cpuStrums.members[i].x = strumPos[i];
		}
	}
}

var defaultPos = [];

function update(elapsed) {
	stage.update(elapsed);
	for (icon in PlayState.iconGroup)
	{
		var playerOffset:Int = 0;
		var opponentOffset:Int = 0;
		var iconOffset:Int = 26;
		if (icon.isPlayer)
		{
			icon.x = healthBar.x
				+ (healthBar.width * (FlxMath.remapToRange(100 - healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset)
				+ icon.offset.x
				+ (icon.width * (icon.scale.x - 1) / 4)
				+ (playerOffset * 85 * icon.scale.x);
		}
		else
		{
			icon.x = healthBar.x
				+ (healthBar.width * (FlxMath.remapToRange(100 - healthBar.percent, 0, 100, 100, 0) * 0.01))
				- (icon.width - iconOffset)
				+ icon.offset.x
				- (icon.width * (icon.scale.x - 1) / 2)
				- (opponentOffset * 85 * icon.scale.x);
		}
		if (!icon.isPlayer)
			{
				icon.health = (healthBar.percent / 100);
				playerOffset++;
			}
			else
			{
				icon.health = 1 - (healthBar.percent / 100);
				opponentOffset++;
			}
			
	}

	PlayState.camFollow.x = 770;
	PlayState.camFollow.y = 490;

	for (i in callTweens) {
		if (i != null) i.active = !paused;
	}

	if (justDIED) {
		Conductor.songPosition = -5000;
		Conductor.songPositionOld = -5000;
		
		if (justDIED) {
			if (concluded && controls.ACCEPT) {
				concluded = false;
				unspawnNotes = [];

				hits['Sick'] = hits['Good'] =  hits['Bad'] = hits['Shit'] = combo = misses = songScore = accuracy = numberOfNotes = numberOfArrowNotes = delayTotal = 0;

				pressedArray = [];

				boyfriend.animation.play('deathConfirm');
				FlxG.sound.playMusic(Paths.sound(GameOverSubstate.retrySFX, 'mods/'+mod));
				FlxG.sound.play(Paths.sound('call', 'mods/'+mod));

				FlxTween.tween(gameOverSprite, {angle: -720}, 1, {ease: FlxEase.quartIn});
				FlxTween.tween(gameOverSprite.scale, {x: 4, y: 4}, 1, {ease: FlxEase.quartIn, onComplete: function(tween:FlxTween) {
					PlayState.scripts.executeFunc('reset', []);

					new FlxTimer().start(1.5, function(timer:FlxTimer) {
						boyfriend.x = defaultPos[0];
						callstage.x = -49;
						dad.x = defaultPos[1];
						bamberstage.x = -1195;
						barrier.x = -295;

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

						stageMask(barrier.x + 50 - callstage.x);

						health = 1;

						remove(strumLineNotes);
						insert(PlayState.members.indexOf(PlayState.scripts.getVariable('bar2'))+1, strumLineNotes);
						remove(notes);
						insert(PlayState.members.indexOf(strumLineNotes)+1, notes);

						if (engineSettings.watermark) {
							FlxTween.cancelTweensOf(watermark);
						}

						for (elem in [
							iconP1, iconP2, scoreText, healthBarBG, timerBG, hitCounter, timerNow, timerFinal, timerText, watermark
						])
						{
							if (elem != null)
							{
								FlxTween.tween(elem, {alpha: 1}, 0.75, {ease: FlxEase.quartOut});
							}
						}

						for (i in [boyfriend, dad]) { //Makes all characters go into idle. Makes the winner screens look consistent.
							i.lastNoteHitTime = -100000;
							i.playAnim("idle");
							i.dance(true);
						}

						repositionNotes();
						callstage.color = dad.color = 0xFFFFFFFF;
						callstage.colorTransform.redOffset = callstage.colorTransform.greenOffset = callstage.colorTransform.blueOffset = dad.colorTransform.redOffset = dad.colorTransform.greenOffset = dad.colorTransform.blueOffset = 0;
					});
				}});
			}
	
			if (concluded && controls.BACK) {
				FlxG.save.data.vs_bamber_hasDiedInThisSong = null;
				FlxG.switchState(new FreeplayState());
			}
		}
	}
}

function beatHit(curBeat) {
	stage.onBeat();
}

var callTweens = [];

function dualCall() {
	PlayState.scripts.executeFunc('onPsychEvent', ['Change Bars Size', 9, 1]);
	PlayState.scripts.executeFunc('onPsychEvent', ['Change Default Zoom', 0.75]);

	for (i in [dad, callstage]) callTweens.push(FlxTween.tween(i, {x: i.x + 350}, 1.5, {ease: FlxEase.quartOut, onComplete: function(tween){tween = null; callTweens = callTweens.filter(x -> x != null);}}));
	for (i in [boyfriend, bamberstage]) callTweens.push(FlxTween.tween(i, {x: i.x + 700}, 1.5, {ease: FlxEase.quartOut, onComplete: function(tween){tween = null; callTweens = callTweens.filter(x -> x != null);}}));
	callTweens.push(FlxTween.tween(barrier, {x: barrier.x + 800}, 2, {ease: FlxEase.quartOut, onComplete: function(tween){tween = null; callTweens = callTweens.filter(x -> x != null);}, onUpdate: function() {
		stageMask(barrier.x + 50 - callstage.x);
	}}));
}

var wasResetButton = engineSettings.resetButton;
var justDIED = false;
var concluded = false;

function onOpenSubstate(substate) {
	if (health <= 0) {
		health = 0.001;

		for (i in FlxG.sound.list.members) {
			i.stop();
		}
		vocals.volume = 1;

		PlayState.scripts.executeFunc('reset', []);

		FlxTween.globalManager._tweens = [];
		FlxTimer.globalManager._timers = [];

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

		PlayState.scripts.executeFunc('onPsychEvent', ['Change Bars Size', 0, 0.5]);
		PlayState.scripts.executeFunc('onPsychEvent', ['Change Default Zoom', 0.85]);

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

		FlxTween.tween(bamberstage, {x: -1195 + 1180}, 1.5, {ease: FlxEase.quartInOut});
		FlxTween.tween(boyfriend, {x: -693 + 1180}, 1.5, {ease: FlxEase.quartInOut});

		FlxTween.tween(callstage, {x: -49 + 1180}, 1.5, {ease: FlxEase.quartInOut});
		FlxTween.tween(dad, {x: 613 + 1180}, 1.5, {ease: FlxEase.quartInOut});

		FlxTween.tween(barrier, {x: 1800}, 1.5, {ease: FlxEase.quartInOut, onUpdate: function() {
			stageMask(barrier.x + 50 - callstage.x);
		}});

		dad.playAnim("idle");
		FlxG.sound.play(Paths.sound('tv off', 'mods/'+mod));
		FlxG.sound.play(Paths.sound('death/call interrupted', 'mods/'+mod));
		new FlxTimer().start(0.13, function(timer:FlxTimer) {
			boyfriend.playAnim("firstDeath");
			boyfriend.animation.finishCallback = function(name){
				concluded = true;
				boyfriend.playAnim("deathLoop");
				boyfriend.animation.finishCallback = null;
				FlxG.sound.playMusic(Paths.music(GameOverSubstate.gameOverMusic));

				FlxG.sound.music.volume = 1;
				FlxG.sound.music.onComplete = null;
			};
		});

		FlxTween.cancelTweensOf(gameOverSprite);
		FlxTween.tween(gameOverSprite, {angle: 0}, 1.5, {ease: FlxEase.quartOut, startDelay: 3});
		FlxTween.tween(gameOverSprite.scale, {x: 1, y: 1}, 1.5, {ease: FlxEase.quartOut, startDelay: 3});

		for (i in [dad, callstage]) {
			i.color = 0xFF000000;
			i.colorTransform.redOffset = i.colorTransform.greenOffset = i.colorTransform.blueOffset = 255;

			FlxTween.tween(i.colorTransform, {redOffset: 0, greenOffset: 0, blueOffset: 0}, 0.5, {ease: FlxEase.quartIn});
		}

		return false;
	}
}

function stageMask(difference) {
	callstage.clipRect = new FlxRect(difference, 0, callstage.frameWidth + difference * -1, callstage.frameHeight);
}