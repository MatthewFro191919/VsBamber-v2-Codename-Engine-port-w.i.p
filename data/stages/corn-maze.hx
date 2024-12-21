import flixel.text.FlxTextBorderStyle;

var stage:Stage = null;
function create() {
	stage = loadStage('corn-maze');
}
function update(elapsed) {
	stage.update(elapsed);
}
function beatHit(curBeat) {
	stage.onBeat();
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
				catText[i].y = 200 + 35 * creditTexts.indexOf(catText);
				catText[i].x = 1;
				catText[0].text += " by";
				catText[0].size = 30;
				catText[0].borderSize = 2;
				catText[0].alpha = 0;
			} else { 
				catText[0].text += " " + catText[i].text + (i < catText.length - 2 ? '   ,' : i == catText.length - 2 ? '    &' : ( ['Itchgø'].contains(catText[i].text) ? ' ' : '    '));
			}

			if (i == catText.length - 1) {
				var creditHead = new FlxSprite(0, catText[0].y).loadGraphic(Paths.image('HUD/corn-maze/bambiHeading'));
				creditHead.cameras = [camHUD];
				creditHead.scale.x = 1 / creditHead.width * catText[0].width;
				creditHead.scale.y = 0.5;
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