function create() {
	character.frames = Paths.getCharacter(character.curCharacter);
	character.loadJSON(true); // Setting to true will override getColors() and dance().
}

/*function onAnim(animName:String) { //Unused function for the "Old Hag" GF skin, to make hair flow smoother. Unused because now hair is animated adequately for all BPMs
	if (animName == 'danceRight') {
		character.playAnim(Conductor.bpm < 140 || character.animation.curAnim.curFrame > 8 ? 'danceRight_140-' : 'danceRight_140+', true);
		return true;
	}
}*/