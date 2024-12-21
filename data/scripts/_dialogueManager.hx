import ModSupport;

var dialogueJSON = null;
if (Assets.exists(Paths.json(PlayState.SONG.song + '/dialogue'))) dialogueJSON = Paths.parseJson(PlayState.SONG.song + '/dialogue');

var overrideDFN = [
    'Yield Seezee Remix' => 'psych'
];
var dialogueFileName = overrideDFN[PlayState.SONG.song] != null ? overrideDFN[PlayState.SONG.song] : 'default';

if (dialogueJSON != null && (PlayState.isStoryMode || dialogueJSON.forceInFreeplay) && !FlxG.save.data.vs_bamber_hasDiedInThisSong && !PlayState.fromCharter) {
    importScript('global_scripts/dialogueScripts/'+dialogueFileName+'.hx');
}