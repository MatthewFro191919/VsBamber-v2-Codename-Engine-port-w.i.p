import Paths;

//Custom Combo graphics
var comboPath = 'HUD/' + (['bfdifield', 'genstage', 'paintvoid', 'exchangetown'].contains(PlayState.SONG.stage.toLowerCase()) ? PlayState.SONG.stage.toLowerCase() : 'default') + '/';

var hasSubfolders = ['paintvoid'];
if (hasSubfolders.contains(PlayState.SONG.stage.toLowerCase())) comboPath = 'HUD/' + PlayState.SONG.stage.toLowerCase() + '/' + PlayState.SONG.song.toLowerCase() + '/';

var countdownOverrideDir = [['judgement_hall', 'undertalestage'] => 'undertale'];

for (song in countdownOverrideDir.keys()) {
	if (song.contains(PlayState.SONG.stage.toLowerCase()) || song.contains(PlayState.SONG.song.toLowerCase())) {
		comboPath = 'HUD/'+countdownOverrideDir[song]+'/';
		break; //break out of the loop
	}
}

var hasPlurality = (Assets.exists(Paths.image(comboPath + 'combo-plural')));

//Ratings for Custom Graphics
ratings = [
    {
        name: "Sick",
        image: comboPath + "Sick",
        accuracy: 1,
        health: 0.035,
        maxDiff: 125 * 0.30,
        score: 350,
        color: "#24DEFF",
        fcRating: "MFC",
        showSplashes: true
    },
    {
        name: "Good",
        image: comboPath + "Good",
        accuracy: 2 / 3,
        health: 0.025,
        maxDiff: 125 * 0.55,
        score: 200,
        color: "#3FD200",
        fcRating: "GFC"
    },
    {
        name: "Bad",
        image: comboPath + "Bad",
        accuracy: 1 / 3,
        health: 0.010,
        maxDiff: 125 * 0.75,
        score: 50,
        color: "#D70000"
    },
    {
        name: "Shit",
        image: comboPath + "Shit",
        accuracy: 1 / 6,
        health: 0.0,
        maxDiff: 99999,
        score: -150,
        color: "#804913"
    }
];

var savedCombo = 0;
var savedMisses = 0;

var enabledMissJudgement = !['genstage', 'cheater', 'paintvoid', 'default_stage', 'battlegrounds', 'oldfarm', 'oldfarm_night', 'hot_farm'].contains(PlayState.SONG.stage.toLowerCase());

var comboScale = [['judgement_hall', 'undertalestage'] => [0.85, 0.85, 0.85], ['exchangetown'] => [1, 1, 1]];
var comboScaleMult = [0.85, 1, 1.5];
for (song in comboScale.keys()) {
	if (song.contains(PlayState.SONG.stage.toLowerCase()) || song.contains(PlayState.SONG.song.toLowerCase())) {
		comboScaleMult = comboScale[song];
		break; //break out of the loop
	}
}

//Miss Judgement + Combo Broken
function updatePost(elapsed) {
    if (savedMisses != misses && health > 0) {
        var missCount = misses - savedMisses;
        savedMisses = misses;

        if (missCount >= 1) {
            for (i in 0...missCount) {
                PlayState.scripts.executeFunc('miss', []);
                if (enabledMissJudgement) onShowCombo((savedCombo > 0 ? -1 : 0), new FlxText());
            }
        }
    }

    if (brokenTween != null) brokenTween.active = !paused;
    for (tweenSet in optimizedTweenSet) { for (i in tweenSet) { i.active = !paused;}}
}

var brokenTween;
var broken:FlxSprite;

var comboOffsets = [
    'bfdifield' => 0,
    'judgement_hall' => -3,
    'undertalestage' => -3
];
var comboXOffset = comboOffsets[PlayState.SONG.stage.toLowerCase()] != null ? comboOffsets[PlayState.SONG.stage.toLowerCase()] : -7;

function onShowCombo(combo:Int, coolText:FlxText) {
	var tweens:Array<VarTween> = [];

    var strumsX:Float = 0;
    var strumsY:Float = 0;
    var strumScale:Float = 0;
    var strumCount = 0;

    for (e in playerStrums.members)
    {
        if (e != null)
        {
            strumsX += e.x + (e.width / 2);
            strumsY += e.y + (e.height / 2);
            strumScale += e.notesScale/7*4;
            strumCount++;
        }
    }
    strumsX /= strumCount;
    strumsY /= strumCount;
    strumScale /= strumCount;

    coolText.x = Math.max(Math.min(strumsX, guiSize.x - 80), 20);
    coolText.y = Math.max(Math.min(strumsY - guiSize.y/2*(engineSettings.downscroll ? 1 : -1), guiSize.y - 80), 20);

    if (combo > 0) {
        savedCombo++;
        if (brokenTween != null) { 
            brokenTween.cancel();
            broken.destroy();
        }

        var rating:FlxSprite = new FlxSprite().loadGraphic(lastRating.bitmap);
        rating.centerOrigin();
        rating.scale.x = rating.scale.y = lastRating.scale * strumScale;
        rating.updateHitbox();
        
        rating.x = coolText.x - rating.width/2;
        rating.y = coolText.y - rating.height/2;
        rating.cameras = [camHUD];
        rating.antialiasing = lastRating.antialiasing;
        PlayState.add(rating);

        rating.alpha = 0;
        rating.y -= 20;
        tweens.push(FlxTween.tween(rating, {y: rating.y + 30, alpha: 1}, 0.15, {
            onComplete: function(tween:FlxTween)
            {
                tweens.push(FlxTween.tween(rating, {alpha: 0}, 0.2, {
                    onComplete: function(tween:FlxTween)
                    {
                        rating.destroy();
                    },
                    startDelay: 0.5
                }));
            },
            ease: FlxEase.quartOut
        }));

        var seperatedScore:Array<Int> = [];
        var stringCombo = Std.string(combo);

        for(i in 0...stringCombo.length) {
            seperatedScore.push(Std.parseInt(stringCombo.charAt(i)));
        }

        while(seperatedScore.length < combo.length) seperatedScore.insert(0, 0);

        var scoreWidth;
        var scoreHeight;
        var numScorePos = [];

        var comboSpr = new FlxSprite().loadGraphic(Paths.image(comboPath + ((hasPlurality && combo > 1) ? 'combo-plural' : 'combo')));
        comboSpr.centerOrigin();
        comboSpr.scale.set(strumScale * comboScaleMult[1], strumScale * comboScaleMult[1]);
        comboSpr.antialiasing = engineSettings.antialiasing;
        comboSpr.updateHitbox();
        
        for (i in 0...seperatedScore.length + 1)
        {
            if (i < seperatedScore.length) {
                var numScore = new FlxSprite().loadGraphic(Paths.image(comboPath + seperatedScore[i]));
                numScore.centerOrigin();
                numScore.scale.set(strumScale * comboScaleMult[0], strumScale * comboScaleMult[0]);
                numScore.antialiasing = engineSettings.antialiasing;
                numScore.updateHitbox();
                scoreWidth = numScore.width;
                scoreHeight = numScore.height;

                numScore.x = coolText.x - numScore.width/2 + (numScore.width * i + 3) - ((numScore.width + 3) * (seperatedScore.length - 1) + comboSpr.width + 3)/2 + comboXOffset;
                numScore.y = coolText.y + rating.height/2 + 5;
                numScorePos = [numScore.x, numScore.y];

                numScore.cameras = [camHUD];

                PlayState.add(numScore);

                numScore.alpha = 0;
                numScore.y += 20;
                tweens.push(FlxTween.tween(numScore, {y: numScore.y - 15, alpha: 1}, 0.15, {
                    onComplete: function(tween:FlxTween)
                    {
                        tweens.push(FlxTween.tween(numScore, {alpha: 0}, 0.2, {
                            onComplete: function(tween:FlxTween)
                            {
                                numScore.destroy();
                            },
                            startDelay: 0.5
                        }));
                    },
                    ease: FlxEase.quartOut
                }));
            } else {
                comboSpr.x = numScorePos[0] + (scoreWidth + 3);
                comboSpr.y = numScorePos[1] + scoreHeight - comboSpr.height;
                comboSpr.cameras = [camHUD];
                PlayState.add(comboSpr);

                comboSpr.alpha = 0;
                comboSpr.y += 20;
                tweens.push(FlxTween.tween(comboSpr, {y: comboSpr.y - 15, alpha: 1}, 0.15, {
                    onComplete: function(tween:FlxTween)
                    {
                        tweens.push(FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
                            onComplete: function(tween:FlxTween)
                            {
                                comboSpr.destroy();
                            },
                            startDelay: 0.5
                        }));
                    },
                    ease: FlxEase.quartOut
                }));
            }
        }
    } else {
        savedCombo = 0;

        var miss:FlxSprite = new FlxSprite().loadGraphic(Paths.image(comboPath + 'miss'));
        miss.centerOrigin();
        miss.scale.x = miss.scale.y = strumScale;
        miss.updateHitbox();
        
        miss.x = coolText.x - miss.width/2;
        miss.y = coolText.y - miss.height/2;
        miss.cameras = [camHUD];
        miss.antialiasing = engineSettings.antialiasing;
        PlayState.add(miss);
        
        miss.alpha = 0;
        miss.y -= 20;
        tweens.push(FlxTween.tween(miss, {y: miss.y + 30, alpha: 1}, 0.15, {
            onComplete: function(tween:FlxTween)
            {
                tweens.push(FlxTween.tween(miss, {alpha: 0}, 0.2, {
                    onComplete: function(tween:FlxTween)
                    {
                        miss.destroy();
                    },
                    startDelay: 0.5
                }));
            },
            ease: FlxEase.quartOut
        }));

        if (combo == -1) {
            broken = new FlxSprite().loadGraphic(Paths.image(comboPath + 'broken'));
            broken.scale.set(comboScaleMult[2] * strumScale, comboScaleMult[2] * strumScale);
            broken.updateHitbox();

            broken.x = coolText.x - broken.width/2;
            broken.y = coolText.y + miss.height/2 + 5;

            broken.antialiasing = engineSettings.antialiasing;
            broken.cameras = [camHUD];
            PlayState.add(broken);

            broken.alpha = 0;
            broken.y += 20;
            brokenTween = FlxTween.tween(broken, {y: broken.y - 15, alpha: 1}, 0.15, {
                onComplete: function(tween:FlxTween)
                {
                    FlxTween.tween(broken, {alpha: 0}, 0.2, {
                        onComplete: function(tween:FlxTween)
                        {
                            broken.destroy();
                        },
                        startDelay: 0.5
                    });
                },
                ease: FlxEase.quartOut
            });
        }
    }

	if (engineSettings.maxRatingsAllowed > -1) optimizedTweenSet.push(tweens);

    return false;
}