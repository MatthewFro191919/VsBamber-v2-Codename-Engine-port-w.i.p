import openfl.filters.BlurFilter;
import openfl.geom.Point;

var enableBlur = false;

if (enableBlur) {
    var blurPower = 0.25;

    var stageBlurOffset = [
        ["romania-outskirts", "hot_farm", "farm", "bfdifield"] => 1,
        ["yard"] => 3,
        ["paintvoid", "judgement_hall", "genstage", "callstage", "battlegrounds", "adobevoidstage", "4chan"] => 999 //cuz either there's no background, it's just one huge sprite, or there' something else going on
    ];

    var overrideBlurAmount = [ //default blurring uses scroll factor x; this will be used to change per sprite if it doesn't suit
        "PLACEHOLDER OBJECT ID OR NAME" => null
    ]; //Use IDs if you coded a stage in a script (variables names can't really be accessed); Use names if you used the stage editor instead

    var blurOffset = 0;
    for (stage in stageBlurOffset.keys()) {
        if (stage.contains(PlayState.SONG.stage.toLowerCase())) { //checks which cursor to apply
            blurOffset = stageBlurOffset[stage]; //sets cursor image to the song cursor
            break; //break out of the loop
        }
    }

    function createPost() {
        for (i in PlayState) {
            if (i.pixels != null && PlayState.members.indexOf(i) < PlayState.members.indexOf(gf) - blurOffset) {

                var amount = (overrideBlurAmount[i.ID] != null ? overrideBlurAmount[i.ID]*blurPower : (overrideBlurAmount[i.name] != null ? overrideBlurAmount[i.name]*blurPower : Math.floor(1/(i.scrollFactor.x+0.1)*16*blurPower)));
                i.pixels.applyFilter(i.pixels, i.pixels.rect, new Point(i.pixels.rect.x, i.pixels.rect.y), new BlurFilter(amount, amount, 3));
            }
        }
    }
}