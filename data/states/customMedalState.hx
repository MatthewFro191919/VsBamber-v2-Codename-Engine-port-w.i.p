import Medals;
import flixel.util.FlxGradient;
// 1 = unlocked, 0 = locked
var medalArray = [
	["Corntastic!", "Beat Week Bamber", 'Bamber', 0x00CC00, "• Play Bamber's week in Story Mode"],
	["Shreddingly Good!", "Beat Week Davey", 'Davey', 0x0066FF, "• Play Davey's week in Story Mode"],
	["Bruh Moment", "Beat Week Boris And Ronnie", 'BorisAndRonnie', 0xFED73E, "• Play Ronnie's & Boris's week in Story Mode"],
	["The Swindler", "Hit EVERY note in Swindled (Located in Bonus Songs)\n(Modchart optional)", 'Swindler', 0x8E0108, "• FC Swindled"],
	["Genocidal Tendencies", "Hit EVERY note in Judgement Farm\n& Judgement Farm 2", 'Judgement', 0x59DEF7, "• FC Judgement Farm\n• FC Judgement Farm 2", "Mars_Needs_Cunnilingus.ttf"],
	["Secret Song 1", "Found Squeaky Clean\n(Now located in Joke Songs)", 'squeaky', 0xFE3455, ""],
	["Am I A Joke To You?", "Found Main Menu secret\n(Head to Freeplay for a surprise...)", 'Joke', 0x0F161F, "", "vcr_osd.ttf"],
	["Secret Song 2", "T E S T F O O T A G E", 'Test', 0x000000, "", "vcr_osd.ttf"],
	["Friendship!", "Beat every Collab Song", 'Collabs', 0x996633, "• Beat Call Bamber\n• Beat Deathbattle\n• Beat H2O"],
	["Nostalgia", "Play a Volume. 1 song", 'Old', 0x16AD01, "• Play any Volume. 1 Song"]
];
var medalState = [];
var medals = [];
var curSelect = 0;
function create() {
	FlxG.stage.window.title = "Vs Bamber And Davey V2 | Medals";
	for(a in 0...medalArray.length){medalState.push(Medals.getState(mod, medalArray[a][0]));}
	trace(medalState);
	for(e in 0...3){
		var curMedal = new FlxSprite();
		curMedal.frames = Paths.getSparrowAtlas('medals');
		for (i in medalArray) {
			curMedal.animation.addByPrefix(i[2], i[2], 24, true);
		}
		medals.push(curMedal);
	}
	for(b in [
		new FlxSprite(0, 0).loadGraphic(Paths.image("menuBGYoshiCrafter")),
		new FlxSprite(0, 0).makeGraphic(FlxG.width, 80, 0x88000000, true),
		gradient = FlxGradient.createGradientFlxSprite(Std.int(FlxG.width), Std.int(FlxG.height), [0x00000000, 0xFFAAAAAA]),
		title = new AlphabetOptimized(FlxG.width / 2, 17.5, "Medals", true, 0.75),
		count = new AlphabetOptimized(FlxG.width - 130, 17.5, curSelect+1 + "/" + medalArray.length, true, 0.75),
		arrowLeft = new FlxSprite(),
		arrowRight = new FlxSprite(),
		name = new FlxText(0, 0).setFormat(Paths.font("vcr.ttf"), 42),
		desc = new FlxText(0, 0).setFormat(Paths.font("vcr.ttf"), 24)])
	{
		b.antialiasing = true;
		add(b);
	}
	arrowRight.angle += 180;
	for(c in medals){
		add(c);
		c.screenCenter();
		c.antialiasing = true;
		c.y -= 100;
	}
	for(h in [arrowLeft, arrowRight]){
		h.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		h.animation.addByPrefix('idle', 'arrow left', 24, false);
		h.animation.addByPrefix('push', 'arrow push left', 24, false);
		h.animation.play('idle');
		h.updateHitbox();
		h.y = medals[0].y + (medals[0].height/2) - (h.height/2);
	}
	arrowLeft.x = medals[0].x - 50;
	arrowRight.x = medals[0].x + medals[0].width;
	desc.fieldWidth = 10000;
	desc.alignment = "center";
	medals[0].x = 25;
	medals[2].x = medals[1].x + medals[1].width + 25;
	medals[1].scale.set(0.75, 0.75);
	for(d in [0, 2]){medals[d].scale.set(0.5, 0.5);}
	title.x -= title.width / 2;
	change(0);
}
function update(){
	if (controls.BACK) FlxG.switchState(new MainMenuState());
	for(b in [arrowLeft, arrowRight]) b.animation.play('idle');
	if (controls.LEFT_P || controls.RIGHT_P) change(controls.LEFT_P ? -1 : 1);
	if (controls.LEFT || controls.RIGHT) (controls.RIGHT ? arrowRight : arrowLeft).animation.play('push');
}
function change(select:Int){
	curSelect = FlxMath.wrap(curSelect + select, 0,	medalArray.length - 1);
	gradient.color = medalArray[curSelect][3];
	count.text = curSelect+1 + "/" + medalArray.length;
	count.x = FlxG.width - 10 - count.width;
	if(medalArray[curSelect-1] == null){prev = 9;} else {prev = curSelect-1;}
	if(medalArray[curSelect+1] == null){next = 0;} else {next = curSelect+1;}

	medals[0].animation.play(medalArray[prev][2]);
	medals[1].animation.play(medalArray[curSelect][2]);
	medals[2].animation.play(medalArray[next][2]);
	
	if(medalState[prev] != 1){medals[0].color = 0x000000;} else {medals[0].color = 0xFFFFFF;}
	if(medalState[curSelect] != 1){medals[1].color = 0x000000; desc.text = "LOCKED" + "\n" + medalArray[curSelect][4];} else {medals[1].color = 0xFFFFFF; desc.text = medalArray[curSelect][1];}
	if(medalState[next] != 1){medals[2].color = 0x000000;} else {medals[2].color = 0xFFFFFF;}
	for(a in [name, desc]){if(medalArray[curSelect][5] != null){a.font = Paths.font(medalArray[curSelect][5]);} else {a.font = Paths.font("vcr.ttf");}}
	name.text = medalArray[curSelect][0];
	name.x = medals[1].getMidpoint().x - (name.width/2);
	name.y = medals[1].y + medals[1].height - 40;
	desc.screenCenter();
	desc.y = name.y + 60;

}