import Note;
import Conductor;
import flixel.FlxCamera;

var modchartSong = save.data.vs_bamber_modChart[PlayState.SONG.song.toLowerCase()]; //reference variable because it's easier to read that way
var isCountingDown = false;
var countTimer;
var diffColors = ["normal" => 0xfcfc04, "easy" => 0x04fc04, "hard" => 0xfc0404, "absolutely fucking fucked" => 0xfc0404];
var useAtlasInstead = ['battlegrounds', 'judgement_hall', 'undertalestage', 'bfdifield'].contains(PlayState_.SONG.stage.toLowerCase());

var graphicOverrideDir = 	[['astray'] => 'paintvoid/astray', ['facsimile'] => 'paintvoid/facsimile', ['yieldstage'] => 'genstage',
							['cheater', 'oldfarm', 'oldfarm_night', 'default_stage', 'corn-maze', 'hot_farm'] => 'funkin', ['farm', 'yard'] => 'default',
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

var scalingArray = [
	'hot_farm' => 0.6,
];
var coutndownScale = scalingArray[PlayState.SONG.stage.toLowerCase()] != null ? scalingArray[PlayState.SONG.stage.toLowerCase()] : 1;

var countdownSprite = new FlxSprite();

var newCam = new FlxCamera(0, 0, PlayState.guiSize.x, PlayState.guiSize.y, 1);

function create() {
    if(modchartSong != null) {menuItems.insert(2, (modchartSong ? 'Disable' : 'Enable') + ' Modchart');}
    newCam.bgColor = 0;
    FlxG.cameras.add(newCam);
    newCam._filters = PlayState.camHUD._filters;
    if(diffColors[levelDifficulty.text.toLowerCase()] != null){levelDifficulty.color = diffColors[levelDifficulty.text.toLowerCase()];} else {levelDifficulty.color = 0xFFFFFF;}
}

function createPost() {
    cameras = [newCam];

    for (i in [levelInfo, levelDifficulty, blueballAmount]) i.font = PlayState.scoreTxt.font;

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
    
    countdownSprite.scale.set(coutndownScale, coutndownScale);
	countdownSprite.updateHitbox();
	countdownSprite.screenCenter();
	insert(1, countdownSprite);
	countdownSprite.alpha = 0.0001;
}

var backupMenuItems = menuItems;

function update(elapsed) {
    if (controls.BACK) {
        if (isCountingDown) {
            grpMenuShit.clear();
            menuItems = backupMenuItems;

            for (i in 0...menuItems.length)
            {
                var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
                songText.isMenuItem = true;
                songText.targetY = i;
                grpMenuShit.add(songText);
            }

            isCountingDown = false;

            CoolUtil.playMenuSFX(2);
            changeSelection(0);

            countdownSprite.alpha = 0.0001;
            countTimer.cancel();
        } else {
            if (script.executeFunc("onSelect", ['Resume']) != false) {}
        }
    }
}

function onChangeSelected(curSelected) {
    if (isCountingDown) return false;
}

var countdownTempo = 1 / Math.pow(2, Math.floor(Math.log(Conductor.bpm/120) / Math.log(2)));

function onSelect(daSelected) {
    if(daSelected.split(" ")[1] == 'Modchart') {
        save.data.vs_bamber_modChart[PlayState.SONG.song.toLowerCase()] = modchartSong = !modchartSong; //had to do it like that because making a variable IS NOT REFERENCING, it's copy and paste.

        grpMenuShit.clear();
        menuItems[2] = (modchartSong ? 'Disable' : 'Enable') + ' Modchart';

        for (i in 0...menuItems.length)
        {
            var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
            songText.isMenuItem = true;
            songText.targetY = i;
            grpMenuShit.add(songText);
        }

        save.flush();

        CoolUtil.playMenuSFX(1);
        changeSelection(0);

        PlayState.scripts.executeFunc("switchModchart", [modchartSong]); //in case extra stuff are needed lol
    }

    if (daSelected == 'Resume') {
        var swagCounter = 2;
        isCountingDown = true;

        grpMenuShit.clear();
        menuItems = ['Cancel'];

        for (i in 0...menuItems.length)
        {
            var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
            songText.isMenuItem = true;
            songText.targetY = i;
            grpMenuShit.add(songText);
        }

        CoolUtil.playMenuSFX(1);
        changeSelection(0);

        PlayState.scripts.executeFuncMultiple("onCountdown", [3, countdownSprite], [true, null]);
        countTimer = new FlxTimer().start(Conductor.crochet / 1000 / countdownTempo, function(tmr:FlxTimer) {
            if (swagCounter > -1) { 
                PlayState.scripts.executeFuncMultiple("onCountdown", [swagCounter, countdownSprite], [true, null]);
            }
            else {
                FlxG.cameras.remove(newCam);
                close();
            }

            swagCounter--;
        }, 4);
        return false;
    }

    if (daSelected == 'Cancel') {
        grpMenuShit.clear();
        menuItems = backupMenuItems;

        for (i in 0...menuItems.length)
        {
            var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
            songText.isMenuItem = true;
            songText.targetY = i;
            grpMenuShit.add(songText);
        }

        isCountingDown = false;

        CoolUtil.playMenuSFX(2);
        changeSelection(0);

        countdownSprite.alpha = 0.0001;
        countTimer.cancel();

        return true;
    }

    if (daSelected == 'Restart Song') {
        FlxG.save.data.vs_bamber_hasDiedInThisSong = true;
        return true;
    }

    if (daSelected == "Exit to menu"){
        if (PlayState.fromCharter) {
            var m = new MenuMessage("Are you sure you want to exit back to the main menu? Any unsaved progress will be lost.", [
                {
                    label: "No",
                    callback: function() {}
                },
                {
                    label: "Yes",
                    callback: function() {
                        FlxG.save.data.vs_bamber_hasDiedInThisSong = null;
                        FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
                        Note.noteAppearanceSchemes[4] = [0,1,2,3];
                        FlxG.sound.playMusic(save.data.freeplayCat == "DAVEY'S NIGHTMARE" && !PlayState.isStoryMode ? Paths.sound("ambient") : Paths.music("freakyMenu"));
                        PlayState.set_song(null);
                    }
                }
            ]);
            m.cameras = cameras;
            openSubState(m);
        } else {
            FlxG.save.data.vs_bamber_hasDiedInThisSong = null;
            FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
            FlxG.sound.playMusic(save.data.freeplayCat == "DAVEY'S NIGHTMARE" && !PlayState.isStoryMode ? Paths.sound("ambient") : Paths.music("freakyMenu"));
            PlayState.set_song(null);
            Note.noteAppearanceSchemes[4] = [0,1,2,3];
        }
        return false;
    }
}
