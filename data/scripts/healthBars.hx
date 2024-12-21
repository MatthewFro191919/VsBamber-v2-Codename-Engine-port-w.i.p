import flixel.util.FlxAxes;
import flixel.math.FlxRect;

/*Bar Type Initialization; Variables:
- Is a Mask?
- Override Graphic Directory - IF NOT NEEDED, SET IT TO NULL
- Should It Be Upside Down With Downscroll
- Colorization Mode (None/Character/Shader) - LINKED TO "IS A MASK"
- Y Change (Health Y, Time Y)
- Additional Y Change on Downscroll (Health Y, Time Y) - IF NOT NEEDED, SET TO [0,0]
- Strum Push (Y Value for either upscroll or downscroll) - IF NOT NEEDED, SET TO [0,0]
*/

//If Colorization is set to none, don't worry about it. If it's character, it better be white. And if it's shader, better go for red.
var barTypes = [
    //STAGE-BASED
    'default' => [true, 'default', true, 'shader', [0,0], [-10,-10], [20,-20]],
    'bfdifield' => [false, null, false, 'none', [0,0], [-15,-10], [10,-20]],
    'cheater' => [false, null, false, 'none', [0,0], [0,0], [0,0]],
    'genstage' => [true, null, false, 'character', [0,0], [-25,-15], [0,0]],
    'battlegrounds' => [true, null, false, 'shader', [0,0], [0,0], [0,0]],
    'judgement_hall' => [false, 'undertale', false, 'none', [0,0], [0,0], [0,0]],
    'undertalestage' => [false, 'undertale', false, 'none', [0,0], [0,0], [0,0]],
    'paintvoid' => [true, 'paintvoid/astray', true, 'shader', [0,0], [-10,-10], [20,-20]],
    'oldfarm' => [false, 'funkin', true, 'none', [5,-15], [20,15], [0,0]],
    'oldfarm_night' => [false, 'funkin', true, 'none', [5,-15], [20,15], [0,0]],
    'hot_farm' => [false, 'funkin', true, 'none', [5,-15], [20,15], [0,0]],
    'exchangetown' => [false, 'exchangetown', true, 'none', [5,0], [-60,0], [0,0]],
    //SONG SPECIFIC
    'facsimile' => [true, 'paintvoid/facsimile', true, 'shader', [0,0], [-10,-10], [20,-20]],
    'placeholder' => [false, 'paintvoid/placeholder', true, 'none', [0,0], [0,0], [0,0]],
    'test footage' => [false, 'paintvoid/placeholder', true, 'none', [0,0], [0,0], [0,0]],
    'h2o' => [false, 'funkin', true, 'none', [5,-15], [20,15], [0,0]],
    'multiversus' => [true, 'multiversus', true, 'shader', [0,0], [-10,-10], [20,-20]],
];

var curBarType = (barTypes[PlayState.SONG.song.toLowerCase()] != null ? barTypes[PlayState.SONG.song.toLowerCase()] : (barTypes[PlayState.SONG.stage.toLowerCase()] != null ? barTypes[PlayState.SONG.stage.toLowerCase()] : barTypes['default']));

//Variable Initialization because indexing repeatedly can tax. Plus it's more readable that way.
var barType_isMask = curBarType[0];
var barType_directory = curBarType[1] != null ? curBarType[1] : PlayState.SONG.stage.toLowerCase();
var barType_flipY = curBarType[2];
var barType_colorization = curBarType[3];
var barType_Y = curBarType[4];
var barType_YDown = curBarType[5];
var barType_StrumY = curBarType[6];

//Bar Masks
var maskHealthBar = new FlxSprite();
var maskTimeBar = new FlxSprite();

function createPost() {
    healthBarBG.loadGraphic(Paths.image('HUD/'+barType_directory+'/HealthBar'));
	timerBG.loadGraphic(Paths.image('HUD/'+barType_directory+'/TimeBar'));

    healthBarBG.screenCenter(FlxAxes.X);
    timerBG.screenCenter(FlxAxes.X);

    if (barType_flipY) healthBarBG.flipY = timerBG.flipY = engineSettings.downscroll;

    if (barType_isMask)  { 
        healthBar.visible = timerBar.visible = false;

        maskHealthBar.loadGraphic(Paths.image('HUD/'+barType_directory+'/HealthBar'));
	    maskTimeBar.loadGraphic(Paths.image('HUD/'+barType_directory+'/TimeBar'));

        maskHealthBar.flipY = maskTimeBar.flipY = healthBarBG.flipY;
        maskHealthBar.cameras = maskTimeBar.cameras = [camHUD];

        maskHealthBar.setPosition(healthBarBG.x, healthBarBG.y);
        maskTimeBar.setPosition(timerBG.x, timerBG.y);

        timerBG.color = 0xFF000000;

        var barColors = engineSettings.classicHealthbar ? [0xFFFF0000, 0xFF00FF00] : [dad.getColors()[0], boyfriend.getColors()[0]];
        //iiiiit's important. Sadly.
        if (barType_colorization == 'shader') barColors = engineSettings.classicHealthbar ? [FlxColor.fromString('0xFFFF0000'), FlxColor.fromString('0xFF00FF00')] : [FlxColor.fromInt(dad.getColors()[0]), FlxColor.fromInt(boyfriend.getColors()[0])];

        switch (barType_colorization) {
            case 'none':
            case 'character':
                maskTimeBar.color = maskHealthBar.color = barColors[0];
                healthBarBG.color = barColors[1];
            case 'shader':
                maskTimeBar.shader = maskHealthBar.shader = new ColoredNoteShader(barColors[0].red, barColors[0].green, barColors[0].blue, false);
                healthBarBG.shader = new ColoredNoteShader(barColors[1].red, barColors[1].green, barColors[1].blue, false);
        }

        insert(members.indexOf(iconGroup),maskHealthBar);
        insert(members.indexOf(timerBG)+1,maskTimeBar);
    } else {

    }

    PlayState.scripts.executeFunc('overrideBars', [maskHealthBar, maskTimeBar, curBarType]);

    maskHealthBar.y = healthBarBG.y += barType_Y[0] * (engineSettings.downscroll ? 1 : -1) + (engineSettings.downscroll ? barType_YDown[0] : 0);
    scoreText.y += barType_Y[0] * (engineSettings.downscroll ? 1 : -1) + (engineSettings.downscroll ? barType_YDown[0] : 0);
    maskTimeBar.y = timerBG.y += barType_Y[1] * (engineSettings.downscroll ? 1 : -1) + (engineSettings.downscroll ? barType_YDown[1] : 0);

    healthBar.y = healthBarBG.y + healthBarBG.height/2 - healthBar.height/2;
    timerBar.y = timerBG.y + timerBG.height/2 - timerBar.height/2;

    maskTimeBar.alpha = maskHealthBar.alpha = 0;

    if (!engineSettings.showTimer && timerText != null) {
        timerText.destroy();
        timerText = null;
        timerNow.destroy();
        timerFinal.destroy();
        maskTimeBar.destroy();
    }

    scoreWarning.y = Math.max(Math.min(healthBarBG.y - scoreWarning.height, guiSize.y - 5 - scoreWarning.height), 5);
}

function onStartCountdown() {
    if (engineSettings.showTimer) strumLine.y += !engineSettings.downscroll ? barType_StrumY[0] : barType_StrumY[1];
}

function reset() {
    if (engineSettings.showTimer) strumLine.y = (engineSettings.downscroll ? guiSize.y - 150 : 50);
}

function onGuiPopup() {
	maskHealthBar.alpha = 0;
	FlxTween.tween(maskHealthBar, {alpha: 1}, 0.75, {ease: FlxEase.quartInOut});

    if (engineSettings.showTimer) {
        maskTimeBar.alpha = 0;
        FlxTween.tween(maskTimeBar, {alpha: 1}, 0.75, {ease: FlxEase.quartInOut});
    }

    if (barType_isMask)  {
        timerBar.visible = healthBar.visible = false;
    }
}

if (barType_isMask) {
    function updatePost() {
        if (engineSettings.showTimer) {
            maskTimeBar.clipRect = new FlxRect(0, 0, maskTimeBar.frameWidth / (PlayState.songLength != null ? PlayState.songLength : 1) * Conductor.songPosition, maskTimeBar.frameHeight);
            timerBG.clipRect = new FlxRect(timerBG.frameWidth / (PlayState.songLength != null ? PlayState.songLength : 1) * Conductor.songPosition, 0, maskTimeBar.frameWidth, maskTimeBar.frameHeight);
        }
    }

    function onHealthUpdate(elapsed) {
        maskHealthBar.clipRect = new FlxRect(0, 0, (maskHealthBar.frameWidth - (maskHealthBar.frameWidth / 2 * health)), maskHealthBar.frameHeight);
        healthBarBG.clipRect = new FlxRect(healthBarBG.frameWidth - (healthBarBG.frameWidth / 2 * health), 0, healthBarBG.frameWidth - (healthBarBG.frameWidth - (healthBarBG.frameWidth / 2 * health)), healthBarBG.frameHeight);

        return true;
    }
}