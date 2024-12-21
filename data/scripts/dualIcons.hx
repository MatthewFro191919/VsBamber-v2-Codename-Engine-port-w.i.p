var songDualIcons = [
    'Coop' => true,
    'Fortnite Duos' => 'bf'
];

function postCreate() {
    if (songDualIcons[PlayState.SONG.song] != null) {
        if (songDualIcons[PlayState.SONG.song] == true || songDualIcons[PlayState.SONG.song] == 'dad') iconP2.changeCharacter(PlayState.SONG.song+'-dad', mod);
        if (songDualIcons[PlayState.SONG.song] == true || songDualIcons[PlayState.SONG.song] == 'bf') iconP1.changeCharacter(PlayState.SONG.song+'-bf', mod);
    }
}