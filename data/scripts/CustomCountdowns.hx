var countdownSprite;

var useAtlasInstead = ['battlegrounds', 'judgement_hall', 'undertalestage', 'bfdifield'].contains(PlayState_.SONG.stage.toLowerCase());
var dontFadeIntro = ['battlegrounds', 'callstage', 'judgement_hall', 'undertalestage', 'bfdifield'].contains(PlayState_.SONG.stage.toLowerCase());

var graphicOverrideDir = 	[['farm', 'yard', 'multiversus'] => 'default', ['astray'] => 'paintvoid/astray', ['facsimile'] => 'paintvoid/facsimile', ['yieldstage'] => 'genstage',
							['cheater', 'oldfarm', 'oldfarm_night', 'default_stage', 'corn-maze', 'hot_farm'] => 'funkin',
							['judgement_hall', 'undertalestage'] => 'undertale'];
var graphicDir = 'HUD/'+PlayState.SONG.stage.toLowerCase();

for (song in graphicOverrideDir.keys()) {
	if (song.contains(PlayState.SONG.stage.toLowerCase())) {
		graphicDir = 'HUD/'+graphicOverrideDir[song];
		break; //break out of the loop
	}
}
for (song in graphicOverrideDir.keys()) {
	if (song.contains(PlayState.SONG.song.toLowerCase())) {
		graphicDir = 'HUD/'+graphicOverrideDir[song];
		break; //break out of the loop
	}
}

var soundOverrideDir = [['cheating-bambi', 'bambi', 'bamber-trade'] => 'bamber', ['bamber-old', 'oldNightBamber', 'water'] => 'funkin', ['bamber-sans', 'bamber-sans-undertale'] => 'undertale', ['ronnie', 'boris', 'ronnie-and-boris', 'gen-bamber', 'bomber', 'newronnie', 'newboris'] => 'amongus',
						['nikku', 'hotline-bamber'] => 'hotline', ['bfdi-bamber'] => 'four'];
var soundDir;

var scalingArray = [
	'hot_farm' => 0.6,
];
var coutndownScale = scalingArray[PlayState.SONG.stage.toLowerCase()] != null ? scalingArray[PlayState.SONG.stage.toLowerCase()] : 1;

function postCreate() {
	soundDir = 'countdown/'+dad.curCharacter.split(':')[1];
	for (song in soundOverrideDir.keys()) {
		if (song.contains(dad.curCharacter.split(':')[1])) {
			soundDir = 'countdown/'+soundOverrideDir[song];
			break; //break out of the loop
		}
	}

	countdownSprite = new FlxSprite();

	if (useAtlasInstead) {
		countdownSprite.frames = Paths.getSparrowAtlas(graphicDir+"/countdown", mod);
		countdownSprite.animation.addByPrefix("3", "Three", 24, false);
		countdownSprite.animation.addByPrefix("2", "Two", 24, false);
		countdownSprite.animation.addByPrefix("1", "One", 24, false);
		countdownSprite.animation.addByPrefix("0", "Go", 24, false);
		countdownSprite.animation.play("3");
	} else {
		countdownSprite.loadGraphic(Paths.image(graphicDir+'/Get'));
	}

	countdownSprite.cameras = [camHUD];
	countdownSprite.scale.set(coutndownScale, coutndownScale);
	countdownSprite.updateHitbox();
	countdownSprite.screenCenter();
	PlayState.insert(PlayState.members.indexOf(strumLineNotes), countdownSprite);
	countdownSprite.alpha = 0.0001;
}

var countdownTempo;

function onGuiPopup() {
	countdownTempo = 1 / Math.pow(2, Math.floor(Math.log(Conductor.bpm/120) / Math.log(2)));
	Conductor.songPosition = PlayState.startTime - (Conductor.crochet / countdownTempo * 5);
	PlayState.startTimer.time = Conductor.crochet / 1000 / countdownTempo;
}

function onCountdown(count, ?overrideSprite) {
	var spriteCount = overrideSprite != null ? overrideSprite : countdownSprite;

	var customCountdownPath = Paths.sound(soundDir + '/intro'+count);
	if (Assets.exists(customCountdownPath)){
		FlxG.sound.play(customCountdownPath, 0.6);
	} else {
		FlxG.sound.play(Paths.sound('intro'+count), 0.6);
	}
	
	spriteCount.alpha = 1;

	if (useAtlasInstead) {
		spriteCount.animation.play(Std.string(count), true);
	} else {
		spriteCount.loadGraphic(Paths.image(graphicDir+'/'+['Go', 'Set', 'Ready', 'Get'][count]));
		spriteCount.updateHitbox();
	}

	spriteCount.screenCenter();
	FlxTween.cancelTweensOf(spriteCount);
	PlayState.scripts.executeFunc('countdownBehavior', [count, spriteCount]);

	if (dontFadeIntro) {
		if (useAtlasInstead) {
			spriteCount.animation.finishCallback = function(name){
				FlxTween.tween(spriteCount, {alpha: 0}, 1, {ease: FlxEase.quartIn});
			};
		} else {
			FlxTween.tween(spriteCount, {alpha: 0}, 1, {ease: FlxEase.quartIn});
		}
	} else {
		FlxTween.tween(spriteCount, {alpha: 0}, Conductor.crochet / 1050 / countdownTempo, {
			ease: FlxEase.cubeInOut});
	}

	if (!paused) PlayState.scripts.executeFunc('beatHit', [-1 - count]);

	return false;
}

function reset() {
	countdownSprite.alpha = 0;
	if (PlayState.startTimer != null) PlayState.startTimer.cancel();
}
