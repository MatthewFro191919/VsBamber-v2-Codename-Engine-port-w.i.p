import lime.system.System; import flixel.FlxCamera;
import Sys;
var time:Float = 0;
//hi it's me glitch i wrote SOME of the code with frakits and nearly everythin here is gonna be annotated if you want to steal the code or smth - Glitch.Smh
var freeplaychar:FlxSprite; //those are initial variables and they just make vars work idk -- freeplay portrait variable initialization
var prevchar:String = "";
var textCamera:FlxCamera;
var normalCamera:FlxCamera;

var grain = new CustomShader(Paths.shader('grain'));
var bloom = new CustomShader(Paths.shader('bloom'));
var scanline = new CustomShader(Paths.shader('scanLines'));
var vignette = new CustomShader(Paths.shader('vignette'));
var cooler = new CustomShader(Paths.shader('sketchShader'));

var shaderList = [cooler, bloom, grain, scanline, vignette];

FlxG.scaleMode.isWidescreen = false;
var windowPos = [FlxG.stage.window.x, FlxG.stage.window.y];
//If you want to add a song, put it in freeplaySonglist.json then add its name to an array
var categories =[   "Week Bamber"			=> ["Yield","Cornaholic","Harvest"],
					"Week Davey" 			=> ["Synthwheel","Yard","Coop"],
					"Week Ronnie & Boris" 	=> ["Ron be like","Bob be like","Fortnite Duos"],
					"Joke Songs"			=> ["Judgement Farm","Judgement Farm 2","Generations","Memeing","Yeld"],
					"Bonus Songs"			=> ["Multiversus","Swindled","Trade","Blusterous Day"],
					"Collab Songs"			=> ["Call-Bamber","Deathbattle","H2O"],
					"Crossover Songs"		=> ["Corn N Roll","Screencast"],
					"Legacy/Old Content"	=> ["Yield V1", "Cornaholic V1", "Harvest V1", "Yield Seezee Remix", "Cornaholic Erect Remix V1", "Harvest Chill Remix"], //I fear this might be the BIGGEST category in v3
					"DAVEY'S NIGHTMARE"		=> ["Astray","Facsimile", "Placeholder"],
					"AI Scenario Songs"		=> [] //It's not gonna happen but imagine if it did. It'd be hella funny. There's like, a shit ton of options that could be done, because of Character.AI.
				];
var fontSongs = ["Corn N Roll" => "adelon-serial-bold.ttf", "Deathbattle" => "Impact.ttf", "Judgement Farm" => "Mars_Needs_Cunnilingus.ttf", "Judgement Farm 2" => "Mars_Needs_Cunnilingus.ttf", "Screencast" => "goodbyeDespair.ttf", "Astray" => "vcr_osd.ttf", "Facsimile" => "vcr_osd.ttf", "Placeholder" => "vcr_osd.ttf", "Test Footage" => "vcr_osd.ttf"];
var diffColors = ["normal" => 0xfcfc04, "easy" => 0x04fc04, "hard" => 0xfc0404, "absolutely fucking fucked" => 0xfc0404];
function create() {
	if(save.data.vs_bamber_scUnlock == true) categories["Joke Songs"].push("Squeaky Clean");
	if(save.data.vs_bamber_tfUnlock == true) categories["DAVEY'S NIGHTMARE"].push("Test Footage");
	normalCamera = new FlxCamera();
	FlxG.cameras.reset(normalCamera);
	textCamera = new FlxCamera();
	FlxG.cameras.add(textCamera, false);
	textCamera.bgColor = 0;
	textCamera.zoom = .7;
	textCamera.scroll.x += 300;
	normalCamera.zoom = 1;
	var songers = CoolUtil.filterNulls(songs);
	var curCat = categories[save.data.freeplayCat];
	for (i in 0...curCat.length) {
		curCat[i] = curCat[i].toLowerCase();
	}
	for (i in songers) {
		if (!curCat.contains(i.songName.toLowerCase())){
			state.songs.remove(i);
		}
	}
	menuTexts = [scoreText, diffText, moreInfoText, accuracyText, missesText];
	for(a in [scoreText, moreInfoText]){a.y -= 10;}

	FlxG.stage.window.onMove.add(function() { //so that the nightmare shaking will happen where the window is instead of dead center
		windowPos = [FlxG.stage.window.x, FlxG.stage.window.y];
	});
}
function createPost(){
	if(save.data.freeplayCat == "DAVEY'S NIGHTMARE") FlxG.sound.music.pause();
	//everything here is just setting the portraits up to work when you enter freeplay -- freeplay portrait init
	freeplaychar = new FlxSprite(700, -50); //sets the position prior to the movement tween that sets it in the correct place, basically simulating sort of a fade-in from the right of the screen
											//actually does nothing lmfao
	insert(3, freeplaychar);
	freeplaychar.antialiasing = true; //makes the sprite able to be visible
	//freeplaychar.alpha = 0; //this makes the sprite initially invisible so the fade-in effect works nicer -- also does nothing since its overwritten when changing song select
	//useless
	FlxTween.tween(freeplaychar, {alpha: 0.5}, 1, {ease: FlxEase.quintOut}); //fades the sprite in as it appears
	FlxTween.tween(freeplaychar, {x: 500}, 1, {ease: FlxEase.elasticOut}); //moves the sprite to the final position
	//none of them do anything important if you change song selection
	for (a in grpSongs.members)
		a.cameras = [textCamera];
	for (e in iconArray)
		e.cameras = [textCamera];
	if(save.data.freeplayCat == "DAVEY'S NIGHTMARE") {
		for(a in shaderList) {normalCamera.addShader(a); textCamera.addShader(a);}
		textCamera.zoom = 1.5;
		textCamera.scroll.x -= 500;
		scoreText.setPosition(200, 100);
		scoreText.scale.set(2,2);
		scoreText.updateHitbox();
		scoreText.height = 600;
		for (i in [diffText, moreInfoText, bg]) remove(i);
		FlxG.sound.music.pause();
		bloom.data.hDRthingy.value = [1.5];
		grain.data.strength.value = [1.25];
		vignette.data.size.value = [0.02];
		scanline.data.opacity.value = [0.08];
	}
}
var escCounter = 0;
function update(elapsed){
	if(controls.BACK) {
		if (save.data.freeplayCat == "DAVEY'S NIGHTMARE") {
			var message = ["no.", "no.", "no.", "you cannot go right now.", "you cant go right now.", "stop.", "you cannot leave right now.", "no."
			, "you cannot leave right now", "stop.", "i said STOP!", "no.", "stop.", "YOU ARE NOT LEAVING RIGHT NOW", "STOP.", "NO.", "STOP.", "RIGHT.", "NOW."];
			if (escCounter == message.length) {
				Sys.exit(0);
			}
			else {
				FlxG.stage.window.alert(message[escCounter], message[escCounter++]);
			}
		}
		else {
			FlxG.switchState(new ModState("freeplaySelect", mod)); 
			FlxG.stage.window.onMove.removeAll();
		}
		controls._back._checked = false;
	}
	if(controls.CONFIRM) {FlxG.stage.window.onMove.removeAll();}
	if(diffColors[_songs[curSelected].difficulties[curDifficulty].toLowerCase()] != null){diffText.color = diffColors[_songs[curSelected].difficulties[curDifficulty].toLowerCase()];} else {diffText.color = 0xFFFFFF;}
}
function updatePost(elapsed){
	time += elapsed;
	if (diffText.text == "ABSOLUTELY FUCKING FUCKED") //frakits wrote this but it basically makes the difficulty text on "Swindled" shake
 	{
		freeplaychar.setPosition(FlxMath.lerp(freeplaychar.x, 500, 0.5), FlxMath.lerp(freeplaychar.y, -50, 0.5));
		diffText.x = FlxMath.lerp(diffText.x, scoreText.x, 1);
		diffText.y = FlxMath.lerp(diffText.y, scoreText.y + 36, 1);
		var sine = Math.sin(95 * time) * 2;
		var shake = FlxG.random.float(0, 70) * 0.1;
		diffText.x += ((shake * sine / FlxG.camera.zoom)) * (elapsed * 85);
		freeplaychar.x += ((shake * sine / FlxG.camera.zoom-0.6)) * (elapsed * 85);
		var sineY = Math.sin(125 * time) * 2;
		var shakeY = FlxG.random.float(0, 60) * 0.1;
		diffText.y += ((shakeY * sineY / FlxG.camera.zoom)) * (elapsed * 85);
		diffText.angle = FlxG.random.float(-3, 3);
		freeplaychar.y += ((shakeY * sineY / FlxG.camera.zoom-0.6)) * (elapsed * 78);
	}
	else {
		diffText.angle = 0;
		diffText.x = FlxMath.lerp(diffText.x, scoreText.x, 1);
		diffText.y = FlxMath.lerp(diffText.y, scoreText.y + (scoreText.height * scoreText.scale.y), 1);
	}
	for (song in grpSongs.members) {
		if (song.text.toLowerCase() == "swindled") //same as the difficulty text, but this makes the song text and icon shake instead
		{
			song.angle = FlxG.random.float(-13, 13);
			var sine = Math.sin(95 * time) * 2;
			var shake = FlxG.random.float(0, 45) * 0.1;
			song.x += ((shake * sine / FlxG.camera.zoom)) * (elapsed * 85);
			var sineY = Math.sin(125 * time) * 2;
			var shakeY = FlxG.random.float(0, 60) * 0.1;
			song.y += ((shakeY * sineY / FlxG.camera.zoom)) * (elapsed * 85);
		}
	}
	if (advancedBG.visible)
		freeplaychar.alpha = FlxMath.lerp(freeplaychar.alpha, 0.2, 0.1);
	else 
		freeplaychar.alpha = FlxMath.lerp(freeplaychar.alpha, 1, 0.1);
	FlxG.stage.window.title = "Vs Bamber And Davey V2 | Freeplay Menu | Currently Selecting: " + grpSongs.members[curSelected].text + " | Difficulty: " + diffText.text; //makes the title show what song and difficulty you're currently selecting. It's comepletely useless but it was fun to code
	//very useful if you DONT play in fullscreen
	var character = iconArray[curSelected].curCharacter.split(":")[1]; //reads which character the icon of the song belongs to
	if (prevchar != character) { //does the fade-in effect for each character change, not just entering the freeplay menu itself -- checking if previous character is not the same as the current character
		FlxTween.globalManager.cancelTweensOf(freeplaychar); //resets tweens if they weren't done before changing the characters
		freeplaychar.setPosition(700, -50); //sets initial position for the tween to work
		freeplaychar.loadGraphic(Paths.image ("freeplayportraits/" + character)); //automatically picks the portrait image depending on who the icon belongs to -- loads current character's portrait
		freeplaychar.setGraphicSize(800, 800); //sets the final size of the portraits. The images themselves are 1000x1000 but that's only to not break the offset of the image -- offsets are still broken
		//FlxTween.tween(freeplaychar, {alpha: 1}, 1, {ease: FlxEase.quintOut});
		FlxTween.tween(freeplaychar, {x: 500}, 1, {ease: FlxEase.elasticOut});
		freeplaychar.antialiasing = true;
		//tweens the portraits positions and opacity
		prevchar = character; //makes the fade-in effect for each character change work -- changes previous character to the current character for check
	}
}

function onChangeSelection(){if(fontSongs[_songs[curSelected].songName] != null){for(b in menuTexts){b.font = Paths.font(fontSongs[_songs[curSelected].songName]);}} else {for(b in menuTexts){b.font = "vcr.ttf";}}}
