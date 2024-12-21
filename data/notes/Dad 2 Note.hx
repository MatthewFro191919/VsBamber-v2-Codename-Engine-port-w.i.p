var dad2Colors = [
    "Blusterous Day" => 0xFFFFFFFF,
    "Fortnite Duos" => 0xFFFFFFFF,
    "Coop" => 0xFF00AF08,
    "Corn N Roll" => 0xFFFFCC00,
    "Deathbattle" => 0xFFFF6100
];


function updatePost(elapsed) {
    if (note.shader != null) {
        var color = new FlxColor(dad2Colors[PlayState.SONG.song]);
        note.shader.setColors(color.red, color.green, color.blue);
        note.splashColor = dad2Colors[PlayState.SONG.song];
    }

    calculateNote();
}
function onDadHit(noteData) {
    if (!PlayState.chartTestMode) {
        switch(noteData) {
            case 0:
                PlayState.dads[1].playAnim("singLEFT", true);
            case 1:
                PlayState.dads[1].playAnim("singDOWN", true);
            case 2:
                PlayState.dads[1].playAnim("singUP", true);
            case 3:
                PlayState.dads[1].playAnim("singRIGHT", true);
        }
    }
}