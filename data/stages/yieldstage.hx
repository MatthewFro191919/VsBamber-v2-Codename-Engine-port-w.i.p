var stage:Stage = null;
function create() {
	stage = loadStage('yieldstage');
}
function update(elapsed) {
	stage.update(elapsed);
}
function beatHit(curBeat) {
	stage.onBeat();
}

function creditSetup(songBG, songTitle, creditTexts, creditIcons) {
	for (catIcons in creditIcons) {
		for (icon in catIcons) {
			icon.destroy();
		}
	}
	creditIcons = [];
	PlayState.scripts.setVariable('songIcons', creditIcons);
	songBG.destroy();
	songTitle.destroy();

	for (catText in creditTexts) {
		for (i in 0...catText.length) {
			if (i == 0) {
				catText[i].angle = 0;
				catText[i].scale.x = 1;
				catText[i].updateHitbox();
				catText[i].y = 100 + 100 * creditTexts.indexOf(catText);
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
	for (catText in songTexts) {
		songTweens.push(FlxTween.tween(catText[0], {alpha: 1}, 1, {ease: FlxEase.quartOut}));
	}
	PlayState.scripts.setVariable('creditTweens', songTweens);

	return 4;
}

function creditEnding(songBG, songTitle, songTexts, songIcons, songTweens) {
	for (catText in songTexts) {
		songTweens.push(FlxTween.tween(catText[0], {alpha: 0}, 1, {ease: FlxEase.quartIn, onComplete: function(tween) {
			PlayState.scripts.executeFunc('creditsDestroy');
		}}));
	}
	PlayState.scripts.setVariable('creditTweens', songTweens);
}