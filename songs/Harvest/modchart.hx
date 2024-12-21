var time:Float = 0;
var allStrums = [];
var allStrumsX = [];
var allStrumsY = 0;
function createPost() {
	for (i in cpuStrums.members) {allStrums.push(i); allStrumsX.push(i.x); allStrumsY = i.y;} 
	for (j in playerStrums.members) {allStrums.push(j); allStrumsX.push(j.x);}
}
function update60(elapsed) {
	time += elapsed;
	var i:Int = 0;
	for (strum in allStrums) {
		strum.y = FlxMath.lerp(strum.y, 
			save.data.vs_bamber_modChart[PlayState.SONG.song.toLowerCase()] ? allStrumsY + (Math.sin((i % 4 + 4) * (time - (20 * i))) / 2) * 50 : allStrumsY,
			0.2);
		strum.x = FlxMath.lerp(strum.x, 
			save.data.vs_bamber_modChart[PlayState.SONG.song.toLowerCase()] ? allStrumsX[i] + Math.cos(((i % 4 + 4) + 2) * (time - (20 * i))) * 10 : allStrumsX[i],
			0.2);
		strum.scale.y = FlxMath.lerp(strum.scale.y, 0.7, 0.2);
		strum.scale.x = FlxMath.lerp(strum.scale.x, 0.7, 0.2);
		i++;
	}
}
var beating:Bool = true;
function beatHit(curBeat) {
	if (save.data.vs_bamber_modChart[PlayState.SONG.song.toLowerCase()]) {
		for (strum in allStrums) {
			if (beating) {
				if (curBeat >= 32) {
					strum.y += 40;
					strum.scale.y = 0.3;
				}
				else
					strum.scale.y = 0.5;
			}
		}
	}
}
function turnOn() {
	beating = !beating;
}
function bigboom() {
	if (save.data.vs_bamber_modChart[PlayState.SONG.song.toLowerCase()]) {
		var i:Int = 0;
		for (strum in allStrums) {
			i++; 
			strum.x += (i % 2 == 0 ? 50 : -50);
			strum.y += (i % 2 == 0 ? 50 : -50);
			strum.scale.x += (i % 2 == 0 ? 0.2 : -0.2);
			strum.scale.y += (i % 2 == 0 ? 0.2 : -0.2);
		}
	}
}
function smallboom() {
	if (save.data.vs_bamber_modChart[PlayState.SONG.song.toLowerCase()]) {
		var i:Int = 0;
		for (strum in allStrums) {
			i++; 
			strum.x += (i % 2 == 0 ? -15 : 15);
			strum.y += (i % 2 == 0 ? -15 : 15);
			strum.scale.x += (i % 2 == 0 ? -0.2 : 0.2);
			strum.scale.y += (i % 2 == 0 ? -0.2 : 0.2);
		}
	}
}
function heychant() {
	if (save.data.vs_bamber_modChart[PlayState.SONG.song.toLowerCase()]) {
		var i:Int = 0;
		for (strum in allStrums) {
			i++; 
			strum.scale.x += 0.2;
			strum.scale.y += 0.2;
		}
	}
}