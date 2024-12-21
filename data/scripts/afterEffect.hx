var songDisable = ['generations', 'astray', 'facsimile', 'placeholder', 'test footage', 'yield v1', 'cornaholic v1', 'harvest v1', 'yield seezee remix', 'cornaholic erect remix v1', 'harvest chill remix'];

var ghosts = [];
var ghostTweens = [];

var notesForStrum= [
    "Coop" => [1,2,4],
    "Deathbattle" => [2],
    "Corn N Roll" => [2],
    "Fortnite Duos" => [1],
    "Blusterous Day" => [1]
];
var girlfriendStrums= [
	"Deathbattle" => [3],
	"Fortnite Duos" => [3]
];

if (!songDisable.contains(PlayState.SONG.song.toLowerCase())) {
	function onPlayerHit(note) {
		createGhost(note,((girlfriendStrums[PlayState.SONG.song] != null && girlfriendStrums[PlayState.SONG.song].contains(note.noteType)) ? gf : boyfriends[(notesForStrum[PlayState.SONG.song] != null && notesForStrum[PlayState.SONG.song].contains(note.noteType)) ? 1 : 0]));
	}
	function onDadHit(note) {
		createGhost(note,((girlfriendStrums[PlayState.SONG.song] != null && girlfriendStrums[PlayState.SONG.song].contains(note.noteType)) ? gf : dads[(notesForStrum[PlayState.SONG.song] != null && notesForStrum[PlayState.SONG.song].contains(note.noteType)) ? 1 : 0]));
	}
	function createGhost(note, char) {
		for (i in notes) if (i.mustPress == note.mustPress && note.strumTime == i.strumTime && note.noteData != i.noteData) {
			var ghost = new Character(0,0, char.curCharacter, char.isPlayer);
			ghost.scrollFactor.set(char.scrollFactor.x, char.scrollFactor.y);
			ghost.updateHitbox();
			ghost.setPosition(char.x, char.y);
			ghost.alpha = 0.8;
			ghost.color = char.color;
			ghost.angle = char.angle;
			ghost.visible = char.visible;
			ghost.colorTransform = char.colorTransform.__clone();
			insert(members.indexOf(char), ghost);
			ghosts.push(ghost);
			//add(ghost);
			ghost.playAnim(char.animation.curAnim.name);
			ghostTweens.push(FlxTween.tween(ghost, {alpha:0}, Conductor.stepCrochet/1000 * 8, {ease:FlxEase.quartOut,onComplete:function() {
				remove(ghost);
				ghost.destroy();
			}}));
		}
	}
	
	function update(elapsed) {
		for (i in ghostTweens) i.active = !paused;
	}

	function onDeath() {
		for (i in ghosts) { if (i != null) {
			remove(i);
			i.destroy();
		}}
	
		ghosts = [];
		ghostTweens = [];
	}
}