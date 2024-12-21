import flixel.math.FlxRandom;
import flixel.math.FlxVelocity;
import flixel.addons.util.FlxSimplex;
import StringTools;
var angle:Float;
var cameraFollow:FlxSprite = new FlxSprite();
var driftAmount = 30;
var time:Float = 0;

var speedIthink = 0.05;

var camType = 'default';

function createPost() {
	add(cameraFollow);
	cameraFollow.visible = false;
	cameraFollow.setPosition(camFollow.x, camFollow.y);
	FlxG.camera.follow(cameraFollow);
}

var trauma = 0;
var speed = 0.0;
var xoffset = 0.0;
var yoffset = 0.0;
var angleoffset = 0.0;
function shake(traumatizer = 0.3, ?speedizer) {
	trauma = traumatizer;
	speed = speedizer;
	xoffset = FlxG.random.float(-100, 100);
	yoffset = FlxG.random.float(-100, 100);
	angleoffset = FlxG.random.float(-100, 100);
}

var allBlock = ['Astray', 'Facsimile', 'Placeholder', 'Test Footage', 'Yeld'];
var angleBlock = ['Yield V1', 'Cornaholic V1', 'Harvest V1', 'Yield Seezee Remix', 'Cornaholic Erect Remix V1', 'Harvest Chill Remix', 'Generations', 'Memeing'];

if (allBlock.contains(PlayState.SONG.song)) driftAmount = 0;

var shakeFormula = 0;
var lastElapsedTime = 0;
var rotateTarget = 0;
function updatePost60(elapsed) {
	time += elapsed;
	lastElapsedTime += elapsed;
	camHUD.followLerp = FlxG.camera.followLerp * 2;

	var animName = "";

	if (PlayState_.SONG.song == 'Ron Be Like' && curBeat >= 72 && curBeat <= 111) { //Ohio Camera
		camHUD.scroll.set(FlxMath.lerp(camHUD.scroll.x, cameraFollow.velocity.x / 5, 0.1), FlxMath.lerp(camHUD.scroll.y, cameraFollow.velocity.y / 5, 0.1));
	}

	if (!allBlock.contains(PlayState.SONG.song)) {
		if (PlayState.section != null)
		{
			if (gf.animation.curAnim != null && !['danceLeft', 'danceRight', 'idle'].contains(gf.animation.curAnim.name)) {
				animName = gf.animation.curAnim.name;
			}
			if (section.mustHitSection) {
				for (b in PlayState.boyfriends) {
					if (b.animation.curAnim != null && !['danceLeft', 'danceRight', 'idle'].contains(b.animation.curAnim.name) && !StringTools.contains(b.animation.curAnim.name, "miss")) {
						animName = b.animation.curAnim.name;
					}
				} 
			} else {
				for (d in PlayState.dads) {
					if (d.animation.curAnim != null && !['danceLeft', 'danceRight', 'idle'].contains(d.animation.curAnim.name)) {
						animName = d.animation.curAnim.name;
					}
				}
			}
		}


	
		if (['singLEFT', 'singLEFT-end'].contains(animName)) {
			PlayState.camFollow.x -= driftAmount;
			rotateTarget = -1;
		}
    	if (['singRIGHT', 'singRIGHT-end'].contains(animName)) {
			PlayState.camFollow.x += driftAmount;
			rotateTarget = 1;
		}
	    if (['singUP', 'singUP-end'].contains(animName)) {
			PlayState.camFollow.y -= driftAmount;
			rotateTarget = 0;
		}
			
	    if (['singDOWN', 'singDOWN-end'].contains(animName)) {
			PlayState.camFollow.y += driftAmount;
			rotateTarget = 0;
		}

		if (animName == "") rotateTarget = 0;

		if (rotateTarget != 0 && angleBlock.contains(PlayState.SONG.song)) rotateTarget = 0;
		FlxG.camera.angle = FlxMath.lerp(FlxG.camera.angle, rotateTarget, 0.04);
	}

	//credit to wizard.hx lol
	trauma = FlxMath.bound(trauma - 0.02, 0, 1);
	FlxG.camera.angle += 5 * (trauma * trauma) * FlxSimplex.simplex(trauma * 25.5, trauma * 25.5 + angleoffset);
	FlxG.camera.scroll.x += 50 * (trauma * trauma) * FlxSimplex.simplex(trauma * 100 + xoffset, 10);
	FlxG.camera.scroll.y += 50 * (trauma * trauma) * FlxSimplex.simplex(10, trauma * 100 + yoffset);

	//Smooth camera experiment
	//cameraFollow.velocity.set(camFollow.x - cameraFollow.x, camFollow.y - cameraFollow.y); // old and not very smooth
	var realSpeed = camFollowLerp / 20;
	if (camType == 'classic' || camType == 'snap') cameraFollow.setPosition(camFollow.x, camFollow.y);
	else cameraFollow.acceleration.set(((camFollow.x - cameraFollow.x) - (cameraFollow.velocity.x * speedIthink)) / realSpeed, ((camFollow.y - cameraFollow.y) - (cameraFollow.velocity.y * speedIthink)) / realSpeed); // so much smoothness

	for (i in zoomTweens) i.active = !paused;
}
function setDriftAmount(value:Float) {driftAmount = value;}

function setCamType(type:String) {
	camType = type;

	if (['snap', 'classic'].contains(type)) cameraFollow.acceleration.set(0,0);

	if (type != 'snap') camFollowLerp = 0.04;
	else camFollowLerp = 5;
}

var zoomTweens = [];

function tweenZoom(amount:Float, beats:Float, ease:String, ?affectHUD = 'true', ?doChangeDefaultZoom = 'false') {
	zoomTweens.push(FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + Std.parseFloat(amount)}, Conductor.stepCrochet / 250 * beats, {ease: CoolUtil.getEase(ease)}));
	if (doChangeDefaultZoom == 'true') zoomTweens.push(FlxTween.tween(PlayState, {defaultCamZoom: PlayState.defaultCamZoom + Std.parseFloat(amount)}, Conductor.stepCrochet / 250 * beats, {ease: CoolUtil.getEase(ease)}));
	if (affectHUD == 'true') zoomTweens.push(FlxTween.tween(camHUD, {zoom: camHUD.zoom + amount/3}, Conductor.stepCrochet / 250 * beats, {ease: CoolUtil.getEase(ease)}));
}

function reset() {
	FlxG.camera.follow(cameraFollow);
	zoomTweens = [];
}