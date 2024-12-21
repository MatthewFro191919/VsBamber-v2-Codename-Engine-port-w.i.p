import Paths;
import Sys;
import sys.net.Host;
import sys.io.Process;
import openfl.utils.Assets;
import Main;
import openfl.text.TextFormat;
import haxe.io.Path;

//Cursors For Each Song
var songArray = [ //sorry guys i fucked up the song order oops...
    ["yield", "cornaholic", "harvest"] => "corn", //farm moment
    ["synthwheel", "yard", "coop", "squeaky clean"] => "acid", //davey's scientific love
    ["bob be like", "ron be like", "fortnite duos", "blusterous day"] => "ping", //because discord ping is funny
    ["judgement farm", "judgement farm 2"] => "knife", //real knife from undertale
    ["multiversus"] => "phone", //bambi's phone
    ["corn n roll"] => "cursor", //recommended character when
    ["astray"] => "mac", //used to have mac-like colors, did not bother changing it but that's the vibe going for it
    ["memeing"] => "3d-green", //3d cursors
    ["generations", "yeld"] => "shit", //funny shit
    ["deathbattle"] => "deathbattle",
    ["screencast"] => "hotline", //nikku hotline 024 *moans*
    ["trade"] => "money", //ya gotta pay for smth, right?
    ["swindled"] => "explode", //his losing icon
    ["call-bamber"] => "call" //call
];
//WHY ARE THE SONGS INCONSISTENT WITH IF ONES WITH MULTIPLE WORDS HAVE HYPHENS (yes "-" are called that) OR SPACES
//will be fixed in the codename port

//Fonts that will be used for specified stages
var customFonts = [
    'bfdifield' => "adelon-serial-bold.ttf"
    'battlegrounds' => "Impact.ttf"
    'judgement_hall' => "Mars_Needs_Cunnilingus.ttf"
    'undertalestage' => "Mars_Needs_Cunnilingus.ttf"
    'hot_farm' => "goodbyeDespair.ttf"
    'paintvoid' => "vcr_osd.ttf"
    'default_stage' => "vcr_osd.ttf"
    'oldfarm' => "vcr_osd.ttf"
    'oldfarm_night' => "vcr_osd.ttf"
];

//songs on which to show the left side disclaimer
doLeftSideDisclaimer = ["call-bamber"].contains(PlayState.SONG.song.toLowerCase());
if (doLeftSideDisclaimer) var leftWarning = new FlxSprite(engineSettings.middleScroll ? 170 : -170, !engineSettings.downscroll ? guiSize.y + 500 : 0).loadGraphic(Paths.image('disclaimers/playing as bamber'+(engineSettings.downscroll ? ' - downscroll' : '')));

function create() {
    for (song in songArray.keys()) {
        if (song.contains(PlayState.SONG.song.toLowerCase())) { //checks which cursor to apply
            FlxG.mouse.load(Assets.getBitmapData(Paths.image('cursors/' + songArray[song]))); //sets cursor image to the song cursor
            break; //break out of the loop
        }
    }

    if (['facsimile', 'yield v1', 'cornaholic v1', 'harvest v1', 'yield seezee remix', 'cornaholic erect remix v1', 'harvest chill remix', 'h2o'].contains(PlayState.SONG.song.toLowerCase())) FlxG.mouse.unload();
    if (['placeholder', 'test footage'].contains(PlayState.SONG.song.toLowerCase())) FlxG.mouse.useSystemCursor = true;
}

function reset() {
    if (doLeftSideDisclaimer) {
        leftWarning.y = (!engineSettings.downscroll ? guiSize.y + 500 : 0) - leftWarning.height;
        leftWarning.alpha = 1;
        leftWarning.angle = 180;
    }
}

function destroy() {
    FlxG.mouse.useSystemCursor = false;
    FlxG.mouse.load(Assets.getBitmapData(Paths.image('cursor'))); //when leaving (or restarting, the func is for that too as much as I don't want it to), bring the cursor back to normal
    Main.fps.defaultTextFormat = new TextFormat(Paths.font('vcr'), 12, Main.fps.color);
}

var isUndertale;

function postCreate() {
    //Window Title bullshit
    if (PlayState.SONG.song == "Astray") FlxG.stage.window.title = "System Username: "+ Sys.environment()["USERNAME"] + " | Computer Name: " + Host.localhost() + " | Have Fun Live Streaming!!! :]";
    else FlxG.stage.window.title = "Vs Bamber And Davey V2 | Currently Playing: " + PlayState.SONG.song;

    setSplashes();

    //Left side disclaimer for some songs
    if (doLeftSideDisclaimer) {
        leftWarning.y -= leftWarning.height;
        leftWarning.cameras = [camHUD];
        leftWarning.scale.set(0.5, 0.5);
        leftWarning.angle = 180;
        add(leftWarning);
    }

    isUndertale = ['bamber-playable-undertale', 'bamber-judgementhall'].contains(boyfriend.curCharacter.split(':')[1]);
}

function setSplashes() {
    if (Assets.exists(Paths.image('splashes/'+boyfriend.curCharacter.split(':')[1]))) {
        splashes.remove(Paths.splashes('splashes', 'shared')); //It's not a necessary step but it's for a good measure

        //This will apply the new splash note, dependent on the current boyfriend.
        splashes.set(Paths.splashes('splashes/'+boyfriend.curCharacter.split(':')[1], mod), [new Splash(Paths.splashes('splashes/'+boyfriend.curCharacter.split(':')[1], mod))]);

        //Sets splashes of needed notes to the new one, so that only the one needed loads, not the default.
        for (i in unspawnNotes) if (i.splash == Paths.splashes('splashes', 'shared')) i.splash = Paths.splashes('splashes/'+boyfriend.curCharacter.split(':')[1], mod);
    }
}

function onGuiPopup() {
    //Disclaimer tween
    if (doLeftSideDisclaimer) FlxTween.tween(leftWarning, {y: engineSettings.downscroll ? 320 : 120, angle: 0}, 1.0, {startDelay: 0.5, ease: FlxEase.backOut, onComplete: function(twn:FlxTween) {
        FlxTween.tween(leftWarning, {alpha: 0}, 1.5, {startDelay: 3.5});
    }});
}

function onPlayerHit(note) {
    if (lastRating.showSplashes && isUndertale) PlayState.splashes[Paths.splashes('splashes/'+boyfriend.curCharacter.split(':')[1], mod)][PlayState.splashes[Paths.splashes('splashes/'+boyfriend.curCharacter.split(':')[1], mod)].length - 1].angle = switch (note.noteData % PlayState.SONG.keyNumber) {
        case 0: 90;
        case 1: 0;
        case 2: 180;
        case 3: -90;
    };
}

function createPost() {
    if (customFonts[PlayState.SONG.stage.toLowerCase()] != null) { //checks if there is a custom font to apply for the stage
        for (i in PlayState) {
            if (i.exists && Std.isOfType(i, FlxText)) { //checks every state object and if they're texts
                i.font = Paths.font(customFonts[PlayState.SONG.stage.toLowerCase()]);
            }
        }
        Main.fps.defaultTextFormat = new TextFormat(Paths.font(customFonts[PlayState.SONG.stage.toLowerCase()]), 12, Main.fps.color);
    }
}

function changeNoteskin(atlas, side) {
    for (i in [unspawnNotes, notes.members]) {
        for (a in i) {
            if ((side == 'player' && a.mustPress) || (side == 'opponent' && !a.mustPress) || side == 'both') {
                var curAnim = a.animation.curAnim.name;
                a.frames = atlas;
        
                a.animation.addByPrefix('green', 'arrowUP');
                a.animation.addByPrefix('blue', 'arrowDOWN');
                a.animation.addByPrefix('purple', 'arrowLEFT0');
                a.animation.addByPrefix('red', 'arrowRIGHT0');
        
                switch (a.appearance) {
                    case 0:
                        a.animation.addByPrefix('scroll', "purple0");
                        a.animation.addByPrefix('holdend', "pruple end hold");
                        a.animation.addByPrefix('holdpiece', "purple hold piece");
                    case 1:
                        a.animation.addByPrefix('scroll', "blue0");
                        a.animation.addByPrefix('holdend', "blue hold end");
                        a.animation.addByPrefix('holdpiece', "blue hold piece");
                    case 2:
                        a.animation.addByPrefix('scroll', "green0");
                        a.animation.addByPrefix('holdend', "green hold end");
                        a.animation.addByPrefix('holdpiece', "green hold piece");
                    case 3:
                        a.animation.addByPrefix('scroll', "red0");
                        a.animation.addByPrefix('holdend', "red hold end");
                        a.animation.addByPrefix('holdpiece', "red hold piece");
                }
                a.centerOffsets();
                if (a.isSustainNote) a.noteOffset.x += a.width/4;
        
                a.animation.play(curAnim);
                if (a.isSustainNote) {
                    a.noteOffset.x = a.width / 2;
                    a.updateHitbox();
                    a.noteOffset.y = -Note.swagWidth / 2;

                    if (a.prevNote != null) {
                        if (a.prevNote.isSustainNote)
                        {
                            a.prevNote.updateHitbox();
            
                            if (engineSettings.downscroll) {
                                a.prevNote.offset.y = a.prevNote.height / 2;
                            }
                        }
                    }
                    a.offset.y += a.height / 4 * (engineSettings.downscroll ? 1 : -1);
                }
            }
            
        }
    }
    for (a in (side == 'both' ? strumLineNotes : (side == 'player' ? playerStrums : cpuStrums)).members) {
        var curAnim = a.animation.curAnim.name;
        
        a.frames = atlas;
    
        a.animation.addByPrefix('green', 'arrowUP');
        a.animation.addByPrefix('blue', 'arrowDOWN');
        a.animation.addByPrefix('purple', 'arrowLEFT0');
        a.animation.addByPrefix('red', 'arrowRIGHT0');
    
        var appearance = Note.noteAppearanceSchemes[PlayState.SONG.keyNumber];
        switch (appearance[strumLineNotes.members.indexOf(a) % PlayState.SONG.keyNumber])
        {
            case 0:
                a.animation.addByPrefix('static', 'arrowLEFT0');
                a.animation.addByPrefix('pressed', 'left press', 24, false);
                a.animation.addByPrefix('confirm', 'left confirm', 24, false);
            case 1:
                a.animation.addByPrefix('static', 'arrowDOWN');
                a.animation.addByPrefix('pressed', 'down press', 24, false);
                a.animation.addByPrefix('confirm', 'down confirm', 24, false);
            case 2:
                a.animation.addByPrefix('static', 'arrowUP');
                a.animation.addByPrefix('pressed', 'up press', 24, false);
                a.animation.addByPrefix('confirm', 'up confirm', 24, false);
            case 3:
                a.animation.addByPrefix('static', 'arrowRIGHT0');
                a.animation.addByPrefix('pressed', 'right press', 24, false);
                a.animation.addByPrefix('confirm', 'right confirm', 24, false);
        }
    
        a.centerOffsets();
        a.centerOrigin();
        a.animation.play(curAnim);
    
        a.x -= a.width / 7;
        a.y -= a.height / 7;
    }
}

function changeScrollSpeed(addOrMultiply, change, side, steps, inputEase) {
    var exampleStrum = (side == 'player' ? playerStrums : strumLineNotes).members[0];
    if (exampleStrum.scrollSpeed == null) exampleStrum.scrollSpeed = exampleStrum.getScrollSpeed();

    //Special cases
    switch (change) {
        case 'Scroll Speed': change = (engineSettings.customScrollSpeed ? engineSettings.scrollSpeed : PlayState.SONG.speed);
        case 'Song Speed': change = PlayState.SONG.speed;
    }

    var resultNeeded = Math.max(1, Math.min(Math.abs(addOrMultiply == 'set' ? change : (addOrMultiply == 'add' ? exampleStrum.getScrollSpeed() + change : exampleStrum.getScrollSpeed() * change)), 8));

    for (i in (side == 'both' ? strumLineNotes : (side == 'player' ? playerStrums : cpuStrums)).members) {
        if (i.scrollSpeed == null) i.scrollSpeed = i.getScrollSpeed(); //Why is it initialized as a null type?
        FlxTween.tween(i, {scrollSpeed: resultNeeded}, Conductor.stepCrochet / 250 * steps, {ease: CoolUtil.getEase(inputEase)});
    }
}