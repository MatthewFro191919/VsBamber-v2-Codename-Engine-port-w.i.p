import Song;
import flixel.math.FlxRandom;
import CoolUtil;

var wasItStory = PlayState_.isStoryMode;
var oldSong = [PlayState_.SONG.song, PlayState_.difficulty.charAt(0).toUpperCase() + PlayState_.difficulty.substr(1).toLowerCase()];

if (!PlayState.fromCharter) {
	if (PlayState.SONG.song != 'Squeaky Clean' && new FlxRandom().int(1, 100) == 1 && wasItStory) { //Chance high so that charters can still chart it. Once you guys finish the chart, change the 5 to something high, like 100
		
		CoolUtil.loadSong(mod, 'Squeaky Clean', 'Fortnite'); //this loads parts of the songs instantly
		PlayState_.SONG = Song.loadModFromJson('Squeaky Clean-fortnite', mod, 'Squeaky Clean'); //and this finishes it off
		//one can't work without the other

		//For Coop
		PlayState.scripts.setVariable("gfVersion", 'gf'); //This will set the girlfriend to.... The speaker Girlfriend.
	}
}

var bopper:FlxSprite = new FlxSprite(1703, 268);
var stage:Stage = null;
var bopperThingy:Bool = true;
var bamberSecondary:Character;
var girlfriendSecondary:Character;
var camPosB;
var camPosGF;
var lockedChar:Bool = false;

var sky;
function create() {
	sky = new FlxSprite(-600, -250).loadGraphic(Paths.image("yard/Sky"));
	sky.scrollFactor.set(0, 0);
	sky.scale.set(1.5,1.5);
	add(sky);

	var ballon:FlxSprite = new FlxSprite(-600, -250).loadGraphic(Paths.image("yard/ScrollingBG"));
	ballon.scrollFactor.set(0.2, 0.2);
	add(ballon);

	var hill:FlxSprite = new FlxSprite(-690, -50).loadGraphic(Paths.image("yard/Hills"));
	hill.scrollFactor.set(0.55, 0.55);
	add(hill);

	var leaves:FlxSprite = new FlxSprite(-975, -500).loadGraphic(Paths.image("yard/Spruce"));
	leaves.scrollFactor.set(0.91, 0.91);
	add(leaves);

	var grass:FlxSprite = new FlxSprite(-1048, 255).loadGraphic(Paths.image('yard/' + (PlayState.SONG.song == 'Coop' ? 'Grass_WithBamber' : 'Grass_WithoutBamber')));
	add(grass);

	var foreground:FlxSprite = new FlxSprite(-1280, -630).loadGraphic(Paths.image('yard/Foreground'));
	add(foreground);

	bopper.frames = Paths.getSparrowAtlas("yard/Boppers");
	bopper.animation.addByIndices('danceLeft', 'Boppers', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], '', 24, false);
	bopper.animation.addByIndices('danceRight', 'Boppers', [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27], '', 24, false);
	add(bopper);

	stage = loadStage('yard');
	PlayState.boyfriend.x = 875;
	PlayState.boyfriend.y =  245;
	PlayState.gf.x = 560;
	PlayState.gf.y = -82;
	PlayState.dad.x = -112;
	PlayState.dad.y = -153;
	PlayState.defaultCamZoom = 0.6;

	if (PlayState.SONG.song == 'Coop') {
		PlayState.boyfriend.x += 130;
		PlayState.boyfriend.y += 40;
	}
}

function createInFront() {
	if (PlayState.SONG.song == 'Coop'){
		bamberSecondary = new Character(-120, -18, mod  + ':bamber');
		add(bamberSecondary);
		PlayState.set_dad(bamberSecondary);
		camPosB = bamberSecondary.getCamPos();

		girlfriendSecondary = new Boyfriend(900, -90, mod  + ':gf-playable');
		insert(PlayState.members.indexOf(boyfriend), girlfriendSecondary);
		PlayState.set_boyfriend(girlfriendSecondary);
		camPosGF = girlfriendSecondary.getCamPos();
	}
}

if (PlayState.SONG.song == 'Coop') {
	function update(elapsed) {
		if (lockedChar == 'bamber' && !section.mustHitSection) PlayState.camFollow.setPosition(camPosB.x, camPosB.y); //this goes according to how YCE handles camera movement
		if (lockedChar == 'girlfriend' && section.mustHitSection) PlayState.camFollow.setPosition(camPosGF.x, camPosGF.y);
	}
}

if (PlayState.SONG.song == 'Squeaky Clean' && !PlayState.fromCharter) {
	function createPost() {
		PlayState_.isStoryMode = wasItStory;
	}

	function storyEndSong() {
		PlayState_.difficulty = PlayState_.storyDifficulty = oldSong[1];
	}

	function destroy() {
		if (wasItStory) oldSong[0] = PlayState_.storyPlaylist[0];

		CoolUtil.loadSong(mod, oldSong[0], oldSong[1]);
		PlayState_.SONG = Song.loadModFromJson(oldSong[0] + (oldSong[1] != 'Normal' ? '-'+oldSong[1].toLowerCase() : ''), mod, oldSong[0]);
		PlayState_.isStoryMode = wasItStory;
	}
}

function beatHit(curBeat) {
	if (bopperThingy)
		bopper.animation.play('danceLeft');
	else
		bopper.animation.play('danceRight');
	bopperThingy = -bopperThingy;
}
function lockOnCharacter(char:String) {
	lockedChar = (['bamber', 'girlfriend'].contains(char) ? char : '');
}