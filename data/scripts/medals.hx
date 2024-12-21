import discord_rpc.DiscordRpc;
for (a in [
	save.data.vs_bamber_jf1Save,
	save.data.vs_bamber_jf2Save,
	save.data.vs_bamber_callbamberSave,
	save.data.vs_bamber_deathbattle,
	save.data.vs_bamber_h2o,
	save.data.vs_bamber_yieldv1,
	save.data.vs_bamber_cornaholicv1,
	save.data.vs_bamber_harvestv1,
	save.data.vs_bamber_yieldseezee,
	save.data.vs_bamber_cornaholicerectold,
	save.data.vs_bamber_harvestchill
]) {if (a == null) {a = false;}}
var rpcAnim = [
	// Song name w/ animated icon => [character name in rpc dev thing, number of frames]
	"Harvest" => ["bamber", 1],
	"Coop" => ["davey", 1],
	"Swindled" => ["bamber-bout-2-howl-da-nword", 6],
	"Astray" => ["joke_model_obj", FlxG.random.int(1, 5)],
	"Facsimile" => ["joke_model_obj", FlxG.random.int(1, 5)]
];
function createPost() {
	rpcSong = PlayState.SONG.song;
	if (rpcAnim[PlayState.SONG.song] != null) {updateType = "rpcAnim";} else {updateType = "rpc";}
	trace(PlayState.SONG.player2);
	switch (PlayState.SONG.song) {
		case "Squeaky Clean":
			Medals.unlock("Secret Song 1");
			save.data.vs_bamber_scUnlock = true;
		case "Test Footage":
			Medals.unlock("Secret Song 2");
			save.data.vs_bamber_tfUnlock = true;
	}
}
function update() {
	rpcUpdate(updateType);
}
function onPreEndSong() {
	if (PlayState.isStoryMode) {
		switch (PlayState.SONG.song) {
			case "Harvest": Medals.unlock("Corntastic!");
			case "Coop": Medals.unlock("Shreddingly Good!");
			case "Fortnite Duos": Medals.unlock("Bruh Moment");
		}
	}
	if(misses == 0 && validScore == true){ // FC'd songs
		switch(PlayState.SONG.song){
			case "Swindled": Medals.unlock("The Swindler");
			case "Judgement Farm": save.data.vs_bamber_jf1Save = true;
			case "Judgement Farm 2": save.data.vs_bamber_jf2Save = true;
		}
	}
	switch(PlayState.SONG.song){
		case "call-bamber": save.data.vs_bamber_callbamberSave = true;
		case "Deathbattle": save.data.vs_bamber_deathbattle = true;
		case "H20": save.data.vs_bamber_h2o = true;
		case "Yield V1": save.data.vs_bamber_yieldv1 = true;
		case "Cornaholic V1": save.data.vs_bamber_cornaholicv1 = true;
		case "Harvest V1": save.data.vs_bamber_harvestv1 = true;
		case "Yield Seezee Remix": save.data.vs_bamber_yieldseezee = true;
		case "Cornaholic Erect Remix V1": save.data.vs_bamber_cornaholicerectold = true;
		case "Harvest Chill Remix": save.data.vs_bamber_harvestchill = true;
	}
	if (save.data.vs_bamber_jf1Save == true && save.data.vs_bamber_jf2Save == true) Medals.unlock("Genocidal Tendencies");
	if (save.data.vs_bamber_callbamberSave == true && save.data.vs_bamber_deathbattle == true && save.data.vs_bamber_h2o == true) Medals.unlock("Friendship!");
	if (save.data.vs_bamber_yieldv1 == true
        && save.data.vs_bamber_cornaholicv1 == true
	&& save.data.vs_bamber_harvestv1 == true
	&& save.data.vs_bamber_yieldseezee == true
	&& save.data.vs_bamber_cornaholicerectold == true
	&& save.data.vs_bamber_harvestchill == true){
	Medals.unlock("Nostalgia");}
}

function rpcUpdate(type:String) {
	if (validScore == true) {
		if (!['astray', 'facsimile', 'placeholder', 'test footage'].contains(PlayState.SONG.song.toLowerCase())) {
			rpcDetails = "Playing " + rpcSong;
			rpcState = "Misses: " + misses + " | " + songScore + "pts";
		} else {
			rpcDetails = "███████ " + rpcSong;
			rpcState = "██████: " + misses + " | " + songScore + "███";
		}
	} else {
		rpcDetails = "Spectating " + rpcSong;
		rpcState = "";
	}
	if (type == "rpc") {
		DiscordRpc.presence({
			details: rpcDetails,
			state: rpcState,
			largeImageKey: PlayState.SONG.player2.split(":")[1].toLowerCase(),
			largeImageText: ""
		});
	} else {
		DiscordRpc.presence({
			details: rpcDetails,
			state: rpcState,
			largeImageKey: rpcAnim[PlayState.SONG.song][0] + "-" + rpcAnim[PlayState.SONG.song][1],
			largeImageText: ""
		});
	}
}
