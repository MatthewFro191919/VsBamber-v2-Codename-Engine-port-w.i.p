import flixel.util.FlxAxes;
import flixel.ui.FlxBar;
import Main;
import openfl.text.TextFormat;
import Note;
import Settings;
import flixel.text.FlxTextBorderStyle;
import Conductor;
import Reflect;
import flixel.util.FlxGradient;

engineSettings.watermark = true;

var stage:Stage = null;
var shader = new CustomShader(Paths.shader('cheatingshader'));
var timer:Float = 0;
var gradientSprite;

var newTimerBar;

function create() {
	var cheaterBG:FlxSprite = new FlxSprite(-863,-732).loadGraphic(Paths.image('cheater'));
	cheaterBG.scale.set(4.5, 4.5);
	cheaterBG.shader = shader;
	shader.data.uSpeed.value = [2];
	shader.data.uFrequency.value = [5];
	shader.data.uWaveAmplitude.value = [0.1];
	add(cheaterBG);
	stage = loadStage('cheater');

	if (PlayState.scripts.getVariable("enableBlur") == true) PlayState.scripts.getVariable("overrideBlurAmount")[Std.string(cheaterBG.ID)] = 20;
}

function oldNew() {
	for (i in ratings) {
		i.image = 'HUD/Funkin/'+i.name;
	}
}

function onStartCountdown() { //I HAVE TO SPECIFY THIS, or the code will change what shouldn't be.
	Note.noteAppearanceSchemes[4] = [0,1,2,3];
}

function onGenerateStaticArrows() {
	Note.noteAppearanceSchemes[4] = [1,2,3,0];
}

function onDeath() { //This will bring shit back to normal on death
	Note.noteAppearanceSchemes[4] = [0,1,2,3];
} //Destroy doesn't work with it sadly

function onPreEndSong() { //This will bring shit back to normal on death
	Note.noteAppearanceSchemes[4] = [0,1,2,3];
} //Again, destroy doesn't work with this. Trust me, I tried.

function createPost() {
	Main.fps.defaultTextFormat = new TextFormat(Paths.font('vcr'), 15, Main.fps.color);

	var noteColors = [new FlxColor(boyfriend.getColors()[2]),
	new FlxColor(boyfriend.getColors()[3]), 
	new FlxColor(boyfriend.getColors()[4]), 
	new FlxColor(boyfriend.getColors()[1])];

	for (i in unspawnNotes) {
		i.script.setVariable('id3D', function(note) {
			return note.mustPress && (note.strumTime / 50) % 20 > 10;
		});
		i.flipY = (Math.round(Math.random()) == 0);
		i.flipX = (Math.round(Math.random()) == 1);

		if (i.mustPress) i.shader.setColors(noteColors[i.noteData].red,noteColors[i.noteData].green,noteColors[i.noteData].blue);

		if (i.mustPress && i.mustPress && i.script.executeFunc('id3D', [i]) == true) {
			i.frames = Paths.getSparrowAtlas('characters/cheating-bambi/NOTE_assets', 'mods/'+mod, false);

			i.splash = Paths.splashes('splashes/funkin', mod);

			i.shader.data.enabled.value = [false];

			i.antialiasing = false;

			i.splashColor = boyfriend.getColors()[(i.noteData+1) % 4 + 1];

			switch (i.appearance)
			{
				case 0:
					i.animation.addByPrefix('scroll', "purple0");
					i.animation.addByPrefix('holdend', "pruple end hold");
					i.animation.addByPrefix('holdpiece', "purple hold piece");
				case 1:
					i.animation.addByPrefix('scroll', "blue0");
					i.animation.addByPrefix('holdend', "blue hold end");
					i.animation.addByPrefix('holdpiece', "blue hold piece");
				case 2:
					i.animation.addByPrefix('scroll', "green0");
					i.animation.addByPrefix('holdend', "green hold end");
					i.animation.addByPrefix('holdpiece', "green hold piece");
				case 3:
					i.animation.addByPrefix('scroll', "red0");
					i.animation.addByPrefix('holdend', "red hold end");
					i.animation.addByPrefix('holdpiece', "red hold piece");
				case 4:
					i.animation.addByPrefix('scroll', "doubleleft0");
					if (i.animation.getByName("scroll") == null) {
						i.animation.addByPrefix('scroll', "purple0");
					}
					i.animation.addByPrefix('holdend', "pruple end hold");
					i.animation.addByPrefix('holdpiece', "purple hold piece");
				case 5:
					i.animation.addByPrefix('scroll', "doubleright0");
					if (i.animation.getByName("scroll") == null) {
						i.animation.addByPrefix('scroll', "red0");
					}
					i.animation.addByPrefix('holdend', "red hold end");
					i.animation.addByPrefix('holdpiece', "red hold piece");
				case 6:
					i.animation.addByPrefix('scroll', "square0");
					if (i.animation.getByName("scroll") == null) {
						i.animation.addByPrefix('scroll', "green0");
					}
					i.animation.addByPrefix('holdend', "green hold end");
					i.animation.addByPrefix('holdpiece', "green hold piece");
				case 7:
					i.animation.addByPrefix('scroll', "plus0");
					if (i.animation.getByName("scroll") == null) {
						i.animation.addByPrefix('scroll', "green0");
					}
					i.animation.addByPrefix('scroll', "green0");
					i.animation.addByPrefix('holdend', "green hold end");
					i.animation.addByPrefix('holdpiece', "green hold piece");
			}

			if (i.isSustainNote) {
				if (i.prevNote != null)
					if (i.prevNote.animation.curAnim != null)
						if (i.prevNote.animation.curAnim.name == "holdend")
							i.prevNote.animation.play("holdpiece");
				i.animation.play("holdend");
			} else {
				i.animation.play("scroll");
			}
		}
	}

	watermark.setFormat(Paths.font("vcr"), Std.int(16), 0xFFFFFFFF, 'LEFT', FlxTextBorderStyle.OUTLINE, 0xFF000000);
	watermark.text = 'Memeing\nNotes are scrambled! FUCK YOU!';
	watermark.y = healthBarBG.y + 30;

	newTimerBar = new FlxBar(healthBarBG.x + 4, timerBar.y + 2, 'LEFT_TO_RIGHT', Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
	newTimerBar.cameras = [camHUD];
	newTimerBar.createFilledBar(0xFF888888, 0xFF00FF00);
	newTimerBar.alpha = 0;
	if (engineSettings.showTimer) insert(members.indexOf(timerBG), newTimerBar);
	FlxTween.tween(newTimerBar, {alpha: 1}, 0.75, {ease: FlxEase.quartInOut});
	timerBar.y = 50000000;

	for (i in [timerText, timerNow, timerFinal]) {
		i.size = 32;
	}

	for (i in PlayState) {
		if (i.exists && Std.isOfType(i, FlxText)) { //checks every state object and if they're texts
			i.borderSize = 2;
		}
	}

	gradientSprite = FlxGradient.createGradientFlxSprite(guiSize.x * 5, guiSize.y, [0x00000000, 0x4481FF69], 1, 90, true);
    gradientSprite.cameras = [camHUD];
	gradientSprite.screenCenter();
    insert(members.indexOf(healthBarBG), gradientSprite);

	PlayState.scripts.executeFunc('setCamType', ['classic']);
}

function destroy() {
	Main.fps.defaultTextFormat = new TextFormat(Paths.font('vcr'), 12, Main.fps.color);
}

function musicstart() {
	if (timerBar != null) {
		newTimerBar.setParent(Conductor, "songPosition");
		newTimerBar.setRange(0, Math.max(inst.length, 1000));
	}
}

function update(elapsed) {
	timer += elapsed;
	shader.data.uTime.value = [timer];
	stage.update(elapsed);
}

function beatHit(curBeat) {
	stage.onBeat();
}

var comboPath = 'HUD/funkin/';
var graphicsToUpdate = [];

function onPlayerHit(note) {
	comboPath = note.script.executeFunc('id3D', [note]) == true ? 'HUD/funkin/3D/' : 'HUD/funkin/';

	for (graphic in graphicsToUpdate) {
		graphic[0].loadGraphic(Paths.image(comboPath+graphic[1]));
	}
}

function onShowCombo(combo:Int, coolText:FlxText) {
	var tweens:Array<VarTween> = [];

	coolText.set(2400,gf.y + 200);

	var rating:FlxSprite = new FlxSprite();
	rating.loadGraphic(Paths.image(comboPath+lastRating.name));
	rating.screenCenter();
	rating.x = coolText.x - 40;
	rating.y = coolText.y - 60;
	rating.acceleration.y = 550;
	rating.velocity.y -= FlxG.random.int(140, 175);
	rating.velocity.x -= FlxG.random.int(0, 10);
	rating.antialiasing = lastRating.antialiasing;
	rating.setGraphicSize(Std.int(rating.width * 0.7));

	var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(comboPath+'combo'));
	comboSpr.screenCenter();
	comboSpr.x = coolText.x;
	comboSpr.y = coolText.y;
	comboSpr.acceleration.y = 600;
	comboSpr.velocity.y -= 150;
	comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));

	comboSpr.updateHitbox();
	rating.updateHitbox();

	comboSpr.velocity.x += FlxG.random.int(1, 10);
	add(rating);
	if (combo >= 10)
	add(comboSpr);

	graphicsToUpdate = [[rating, lastRating.name], [comboSpr, 'combo']];

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
		var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(comboPath + Std.int(i)));
		numScore.screenCenter();
		numScore.x = coolText.x + (43 * daLoop) - 90;
		numScore.y = coolText.y + 80;

		numScore.acceleration.y = FlxG.random.int(200, 300);
		numScore.velocity.y -= FlxG.random.int(140, 160);
		numScore.velocity.x = FlxG.random.float(-5, 5);

		numScore.setGraphicSize(Std.int(numScore.width * 0.5));
		numScore.updateHitbox();

		if (combo >= 10 || combo == 0)
			add(numScore);

		tweens.push(FlxTween.tween(numScore, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				numScore.destroy();
			},
			startDelay: Conductor.crochet * 0.002
		}));

		graphicsToUpdate.push([numScore, Std.int(i)]);

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
	songBG.destroy();
	songTitle.destroy();

	for (catText in creditTexts) {
		for (i in 0...catText.length) {
			if (i == 0) {
				catText[i].angle = 0;
				catText[i].scale.x = 1;
				catText[i].updateHitbox();
				catText[i].y = 200 + 50 * creditTexts.indexOf(catText);
				catText[i].x = 1;
				catText[0].text += " by";
				catText[0].size = 30;
				catText[0].borderSize = 2;
				catText[0].alpha = 0;
			} else { 
				catText[0].text += " " + catText[i].text + (i < catText.length - 2 ? '   ,' : i == catText.length - 2 ? '    &' : ( ['Itchgø'].contains(catText[i].text) ? ' ' : '    '));
			}

			if (i == catText.length - 1) {
				var creditHead = new FlxSprite(0, catText[0].y);
				creditHead.frames = Paths.getSparrowAtlas('HUD/cheater/cheatingHeading');
				creditHead.animation.addByPrefix('cheating', 'Cheating', 24, true, [false, false]);
				creditHead.animation.play('cheating');
				creditHead.cameras = [camHUD];
				creditHead.scale.x = 1 / creditHead.width * catText[0].width;
				creditHead.updateHitbox();
				creditHead.alpha = 0;
				insert(PlayState.members.indexOf(songBG), creditHead);
				creditHeaders.push(creditHead);

				var parts = catText[0].text.split("   ");
				var xPos = 0;

				creditHead.x -= creditHead.width;
				catText[0].x -= creditHead.width;

				for (catIcon in creditIcons[creditTexts.indexOf(catText)]) {
					catIcon.setGraphicSize(30); catIcon.updateHitbox();
					catIcon.y = catText[0].y + 10;
					catIcon.angle = 0;
					catIcon.alpha = 0;

					var partText = new FlxText(0, 0, 0, parts[creditIcons[creditTexts.indexOf(catText)].indexOf(catIcon)]);
					partText.setFormat(scoreTxt.font, 30, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
            		partText.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 2, 1);

					xPos += partText.width + 10 + (creditIcons[creditTexts.indexOf(catText)].indexOf(catIcon) > 0 ? 22 : 0);
					catIcon.x = xPos;

					catIcon.x -= creditHead.width;
				}
			}
		}

		catText = [catText[0]];
	}

	PlayState.scripts.setVariable('songTexts', creditTexts);
}

var creditHeaders = [];

function creditBehavior(songBG, songTitle, songTexts, songIcons, songTweens) {
	for (i in 0...creditHeaders.length) {
		creditHeaders[i].alpha = 1;
		songTexts[i][0].alpha = 1;

		songTweens.push(FlxTween.tween(creditHeaders[i], {x: 0}, 0.5, {ease: FlxEase.backOut}));

		songTweens.push(FlxTween.tween(songTexts[i][0], {x: 1}, 0.5, {ease: FlxEase.backOut}));

		for (a in songIcons[i]) {
			a.alpha = 1;
			songTweens.push(FlxTween.tween(a, {x: a.x + creditHeaders[i].width}, 0.5, {ease: FlxEase.backOut}));
		}
	}
	PlayState.scripts.setVariable('creditTweens', songTweens);
	return 3.5;
}

function creditEnding(songBG, songTitle, songTexts, songIcons, songTweens) {
	for (i in 0...creditHeaders.length) {
		songTweens.push(FlxTween.tween(creditHeaders[i], {x: 0 - creditHeaders[i].width}, 1, {ease: FlxEase.backIn}));

		songTweens.push(FlxTween.tween(songTexts[i][0], {x: 0 - creditHeaders[i].width}, 1, {ease: FlxEase.backIn, onComplete: function(tween) {
			PlayState.scripts.executeFunc('creditsDestroy');
			creditHeaders[i].destroy();
		}}));

		for (a in songIcons[i]) {
			songTweens.push(FlxTween.tween(a, {x: a.x - creditHeaders[i].width}, 1, {ease: FlxEase.backIn}));
		}
	}
	PlayState.scripts.setVariable('creditTweens', songTweens);
}