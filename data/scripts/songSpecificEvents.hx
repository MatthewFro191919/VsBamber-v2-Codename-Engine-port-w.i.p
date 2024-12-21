import openfl.utils.Assets;
import SongMetadata;
import Settings;

function songEvents() {
    var songDifficulties = Json.parse(Assets.getText(Paths.json('freeplaySonglist', 'mods/'+Settings.engineSettings.data.selectedMod)));

    for (song in songDifficulties.songs) {
        if (song.displayName == PlayState.SONG.song) {
            songDifficulties = song.difficulties;
            break;
        }
    }

    if (songDifficulties.length > 1 && songDifficulties.contains('Normal') && PlayState.get_difficulty() != 'Normal') {
        var normalEvents = Json.parse(Assets.getText(Paths.json(PlayState.SONG.song+'/'+PlayState.SONG.song, 'mods/'+Settings.engineSettings.data.selectedMod))).song.events;
        
        if (PlayState._SONG.events.length > 0) {
            normalEvents = normalEvents.filter(function(element1) { //the only problem is that it's o(n*m), but it happens once at least so idc
                for (element2 in PlayState._SONG.events) {
                    if (Std.parseFloat(element1.time) == Std.parseFloat(element2.time)) {
                        return false;
                    }
                }
                return true;
            });
        }
        
        for (i in normalEvents) {
            if (i.time < PlayState.startTime && PlayState.startTime > 0) continue;
            events.push({name: i.name, time: i.time, parameters: i.parameters});
        }
    }
}

function oldNew() {
    songEvents();
}