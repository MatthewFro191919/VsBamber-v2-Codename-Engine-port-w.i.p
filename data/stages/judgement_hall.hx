import flixel.ui.FlxBar;
import flixel.math.FlxRect;

var stage:Stage = null;
var strumPos = [];
function create()
	stage = loadStage('judgement_hall');
function beatHit(curBeat)
	stage.onBeat();
var hptexter;
var hepertexter;

engineSettings.timerSongName = false;

ratings = [
    {
        name: "Perfect",
        image: "HUD/undertale/perfect",
        accuracy: 1,
        health: 0.035,
        maxDiff: 30,
        score: 350,
        color: "#2877FF",
        fcRating: "PFC",
        showSplashes: true
    },
    {
        name: "Great",
        image: "HUD/undertale/great",
        accuracy: 2 / 3,
        health: 0.025,
        maxDiff: 70,
        score: 200,
        color: "#51C3E2",
        fcRating: "GFC"
    },
    {
        name: "Nice",
        image: "HUD/undertale/nice",
        accuracy: 1 / 3,
        health: 0.010,
        maxDiff: 120,
        score: 50,
        color: "#F6FF56"
    },
    {
        name: "Meh",
        image: "HUD/undertale/meh",
        accuracy: 1 / 6,
        health: 0.0,
        maxDiff: 99999,
        score: -150,
        color: "#FF4040"
    }
];

function createPost() {
	GameOverSubstate.firstDeathSFX = "death/starts/ut-death";
	iconP1.visible = iconP2.visible = false;
	healthBarBG.visible = false;
	remove(healthBar);
	healthBar = new FlxBar(0, 640, null, 92 * 2, 35, healthBar.parent, healthBar.parentVariable,0,2);
	healthBar.screenCenter(FlxAxes.X);
	healthBar.createFilledBar(0xFFFF0000, 0xFFfffd03);
	add(healthBar);
	var thing = new FlxSprite(-2000, engineSettings.downscroll ? -10 : 600).makeGraphic(1, 1, 0xFF000000);
    thing.scale.set(5000,130); thing.updateHitbox();
	insert(0, thing);
	var nametexter = new FlxText(healthBar.x - 350, healthBarBG.y - 16, 0, "BAMBER", 30);
	add(nametexter);
	var leveltexter = new FlxText(healthBar.x - 200, healthBarBG.y - 16, 0, "LV 19", 30);
	add(leveltexter);
	hptexter = new FlxText(healthBar.x - 40, healthBarBG.y - 12, 0, "HP", 15);
	hepertexter = new FlxText(healthBar.x + (healthBar.width + 20), healthBarBG.y - 16, 0, "FHOSIOJFHSDJ", 30);
	add(hepertexter);
	thing.cameras = healthBar.cameras = nametexter.cameras = leveltexter.cameras = hptexter.cameras = hepertexter.cameras = [camHUD];
}

function postCreate() {
	hptexter.font = Paths.font("8bit_wonder.ttf");
	add(hptexter);

	if (engineSettings.showTimer) {
		timerBar.visible = timerBG.visible = false;
		timerText.size = 30;

		timerBG.y = hptexter.y + 3;
		timerBG.x += 100;

		for (i in [timerText, timerNow, timerFinal]) {
			i.size = 30;
			i.antialiasing = false;
		}

		scoreText.antialiasing = false;
	}
}

function onTimerUpdate(elapsed) {
	timerNow.x = timerBG.x + timerBG.width + 5;
	timerText.x = timerNow.x + timerNow.width + 5;
	timerFinal.x = timerText.x + timerText.width + 5;
}

function update(elapsed) {
	hepertexter.text = Math.min(Math.floor(health * 46), 92)  + " / 92";
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

	songTitle.scale.set(1, 1); //Clipping rectangles are finicky when scale is modified so I gotta revert them to normal size for them to work seamlessly.
	songTitle.updateHitbox();
	songTitle.screenCenter();
    songTitle.y -= 50;

    remove(songTitle); insert(PlayState.members.indexOf(strumLineNotes), songTitle);

    songTitle.antialiasing = songBG.antialiasing = false;

	for (catText in creditTexts) {
		for (i in catText) {
            i.size = (catText.indexOf(i) == 0 ? 40 : 20);
            i.y = 380 + ((i.height + 10) * catText.indexOf(i));
            i.angle = 0;
            i.x = 400 - (25 * (creditTexts.length/4)) + ((guiSize.x - 700) / creditTexts.length * creditTexts.indexOf(catText));

            if (catText.indexOf(i) == 0) i.x += (creditTexts[1][0].width - i.width) / 3;
            if (catText.indexOf(i) > 0) i.y = catText[0].y + catText[0].height - 5 + (i.height - 2) * (catText.indexOf(i) - 1);
			
            remove(i); insert(PlayState.members.indexOf(strumLineNotes), i);

            i.antialiasing = false;
		}
	}

    songBG.alpha = 1;
    songBG.screenCenter();
    remove(songBG); insert(PlayState.members.indexOf(strumLineNotes), songBG);

    songBG.x = guiSize.x + 1000;
    
    adjustCreditClippingRects(songBG, songTitle, creditTexts);
}

function adjustCreditClippingRects(masker, songTitle, creditTexts) {
    songTitle.clipRect = new FlxRect((masker.x + masker.width/2 - songTitle.x), 0, songTitle.frameWidth + (masker.x + masker.width/2 - songTitle.x) * -1, songTitle.frameHeight);
    for (catText in creditTexts) {
		for (i in catText) {
            i.clipRect = new FlxRect((masker.x + masker.width/2 - i.x), 0, i.frameWidth + (masker.x + masker.width/2 - i.x) * -1, i.frameHeight);
		}
	}
}

function creditBehavior(songBG, songTitle, songTexts, songIcons, songTweens) {
	songTweens.push(FlxTween.tween(songBG, {x: 200}, 1, {ease: FlxEase.quartOut, onUpdate: function(twn:FlxTween) {
        adjustCreditClippingRects(PlayState.scripts.getVariable('songBG'), PlayState.scripts.getVariable('songTitle'), PlayState.scripts.getVariable('songTexts'));
    }}));
    PlayState.scripts.setVariable('creditTweens', songTweens);

	return 4;
}

function creditEnding(songBG, songTitle, songTexts, songIcons, songTweens) {
	songTweens.push(FlxTween.tween(songBG, {x: guiSize.x + 1000}, 1, {ease: FlxEase.quartIn, onUpdate: function(twn:FlxTween) {
        adjustCreditClippingRects(PlayState.scripts.getVariable('songBG'), PlayState.scripts.getVariable('songTitle'), PlayState.scripts.getVariable('songTexts'));
    }, onComplete: function(tween) {
        PlayState.scripts.executeFunc('creditsDestroy');
    }}));
    PlayState.scripts.setVariable('creditTweens', songTweens);
}