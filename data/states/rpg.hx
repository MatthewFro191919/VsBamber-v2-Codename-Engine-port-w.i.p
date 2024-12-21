import flixel.FlxObject;
import flixel.math.FlxRandom;
import flixel.system.FlxSound;
import StoryMenuState;
import Settings;
import StringTools;
import PlayState;
import Highscore;
import Song;
import LoadingState;
import Character;


var player = new FlxSprite(75, 855);
var curDirection = "Left";
var storyModePlay:FlxSprite;
var weekData:Map;
var camFollow:FlxSprite = new FlxSprite();
var collidedWithChar = false;

var characters = [];
function create() {
	add(new FlxSprite(-50, 820).makeGraphic(200, 200, 0xFF6D6D6D));
	add(new FlxSprite(0, 120).makeGraphic(100, 700, 0xFF6D6D6D));
	add(new FlxSprite(-750, 25).makeGraphic(1600, 100, 0xFF6D6D6D));


	FlxG.worldBounds.set(-50000, -50000, 75000, 75000);
	var directions = ["Down", "Up", "Left", "Right", "DownRight", "UpRight", "UpLeft", "DownLeft"];
	player.frames = Paths.getSparrowAtlas("rpg/RPG_Boyfriend");
	player.maxVelocity.set(500, 500);

	for (d in directions) {
		player.animation.addByPrefix("run " + d, "Run_" + d + " instance");
		player.animation.addByPrefix("idle " + d, "Idle_" + d + " instance");
		player.animation.addByPrefix("walk " + d, "Walk_" + d + " instance");
		player.animation.addByPrefix("stand " + d, "Stand_" + d + " instance");
	}
	add(player);
	camFollow.setPosition(player.getMidpoint().x, player.getMidpoint().y);
	add(camFollow);
	camFollow.visible = false;
	FlxG.camera.follow(camFollow);
	loadWeek();
	loadChars();
}


function loadChars() {
	var bamber = new FlxSprite(720, 20);
	bamber.frames = Paths.getSparrowAtlas("PORTRAITS/Bamber_Dialogue");
	bamber.animation.addByPrefix("idle", "BAMBER000", 24, true);
	bamber.animation.play(idle);
	bamber.flipX = true;
	bamber.scale.set(0.27, 0.27);
	bamber.updateHitbox();
	bamber.immovable = true;
	add(bamber);
	characters.push([bamber, "Bamber's Farm"]);
	var davey = new FlxSprite(-720, 20);
	davey.loadGraphic(Paths.image("freeplayportraits/daveyrpg"));
	davey.updateHitbox();
	davey.immovable = true;
	add(davey);
	characters.push([davey, "Davey's Yard"]);
	trace(characters);
}
var playerSpeed = 200;
var controlsList = [
	"left" => [FlxG.keys.anyPressed([39,68]), 2],
	"right" => [FlxG.keys.anyPressed([37,65]), 7],
	"up" => [FlxG.keys.anyPressed([38,87]), 4],
	"down" => [FlxG.keys.anyPressed([40,83]), 1],
	"any" => FlxG.keys.anyPressed([40,68,39,38,65,83,37,87])
];
var curWeekCollided = null;
function update(elapsed) {
	if (FlxG.keys.justPressed.ESCAPE)
		FlxG.switchState(new MainMenuState());
	if (controlsList["any"])
		collidedWithChar = false;

	var playerPos = player.getMidpoint();
	for (i in characters) {
		FlxG.overlap(i[0], player, null, function(v1,v2) {
			trace("sex");
			FlxObject.separate(i[0], v2);
			collidedWithChar = true;
			if (i[0] == v1) curWeekCollided = i[1];
		});
		if (FlxMath.distanceBetween(player, i[0]) < 700)
			playerPos = i[0].getMidpoint();
	}
	if (FlxG.keys.justPressed.ENTER)
		if (curWeekCollided != null) startWeek(curWeekCollided);
	if (playerPos.x == player.getMidpoint().x && playerPos.y == player.getMidpoint().y) {
		playerPos.x += player.velocity.x;
		playerPos.y += player.velocity.y;
	}
	camFollow.acceleration.set(((playerPos.x - camFollow.x) - (camFollow.velocity.x * 0.8)) / 0.1, ((playerPos.y - camFollow.y) - (camFollow.velocity.y * 0.8)) / 0.1); // so much smoothness
	movement(elapsed);
}

function movement() {
	controlsList = [
		"left" => FlxG.keys.anyPressed([39,68]),
		"right" => FlxG.keys.anyPressed([37,65]),
		"up" => FlxG.keys.anyPressed([38,87]),
		"down" => FlxG.keys.anyPressed([40,83]),
		"any" => FlxG.keys.anyPressed([40,68,39,38,65,83,37,87]),
		"anyPressed" => [FlxG.keys.anyPressed([40,83]),FlxG.keys.anyPressed([38,87]),FlxG.keys.anyPressed([37,65]),FlxG.keys.anyPressed([39,68]),]
	];
	if (!FlxG.keys.pressed.SHIFT) playerSpeed = FlxMath.lerp(playerSpeed, 200, 0.1); else playerSpeed = FlxMath.lerp(playerSpeed, 500, 0.1);
	player.velocity.set();
	var directionID:Int = 0;
	if (controlsList["any"]) {
		curWeekCollided = null;
		var realSpeed = playerSpeed;
		var amountofKeys = 0;
		for (i in controlsList["anyPressed"])
			if (i == true)
				amountofKeys++;
		if (amountofKeys > 1) realSpeed = playerSpeed / 1.5;
		if (FlxG.keys.pressed.SHIFT && amountofKeys > 2) realSpeed = playerSpeed / 2;
		player.velocity.set((controlsList["left"] ? realSpeed : (controlsList["right"] ? -realSpeed : 0)), (controlsList["down"] ? realSpeed : (controlsList["up"] ? -realSpeed : 0)));
		// sorry for shitty code
		if (controlsList["down"] && controlsList["left"]) curDirection = "DownRight";
		else if (controlsList["down"] && controlsList["right"]) curDirection = "DownLeft";
		else if (controlsList["up"] && controlsList["left"]) curDirection = "UpRight";
		else if (controlsList["up"] && controlsList["right"]) curDirection = "UpLeft";	
		else if (controlsList["left"]) curDirection = "Right";
		else if (controlsList["right"]) curDirection = "Left";
		else if (controlsList["down"]) curDirection = "Down";
		else if (controlsList["up"]) curDirection = "Up";
	}
	if ([0,0].contains(player.velocity.x) && [0,0].contains(player.velocity.y)) {player.animation.play("idle " + curDirection);
	player.animation.curAnim.frameRate = 24;
	player.animation.callback = null;}
	else if (playerSpeed > 445) {player.animation.play("run " + curDirection, false, false, player.animation.curAnim.curFrame);
	player.animation.curAnim.frameRate = (playerSpeed / 10) - 5;
	player.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int) {
		if (frameNumber == 1 || frameNumber == 8) FlxG.sound.play(Paths.sound("minecraft step sounds/stone" + new FlxRandom().int(3, 6)));
	}}
	else {player.animation.play("walk " + curDirection, false, false, player.animation.curAnim.curFrame);
	player.animation.curAnim.frameRate = (playerSpeed / 10) + 15;
	player.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int) {
		if (frameNumber == 15 || frameNumber == 1) FlxG.sound.play(Paths.sound("step"));
	}}
}
function loadWeek() {
	var json = Json.parse(Assets.getText(Paths.getPath('weeks.json', "TEXT", 'mods/' + mod)));
	weekData = [];
	for (w in json.weeks)
	{
		weekData.push(w);
	}
		
}
function startWeek(weekName:String) {
	var week;
	for (i in weekData)
		if (i.name == weekName)
			week = i;
	PlayState.actualModWeek = week;
	PlayState.songMod = mod;
	PlayState.storyPlaylist = week.songs;
	PlayState.isStoryMode = true;
	PlayState.startTime = 0;
	selectedWeek = true;

	PlayState.storyDifficulty = "Normal";

	PlayState._SONG = Song.loadModFromJson(Highscore.formatSong(PlayState.storyPlaylist[0].toLowerCase(), "Normal"), PlayState.songMod, PlayState.storyPlaylist[0].toLowerCase());
	PlayState.jsonSongName = PlayState.storyPlaylist[0].toLowerCase();
	PlayState.storyWeek = 1;
	PlayState.campaignScore = 0;
	PlayState.fromCharter = false;
	LoadingState.loadAndSwitchState(new PlayState(), true);
}