// vhs.frag -- vhs/glitch shader
	var vhs = new CustomShader(Paths.shader('vhs'));
	function create() {
		// use PlayState.camHUD.addShader(vhs); to add it on the HUD
		FlxG.camera.addShader(vhs);

		// these have to be here in order to work (the values can be adjusted)
		vhs.data.range.value = [0.05];
		vhs.data.noiseQuality.value = [250.0];
		vhs.data.noiseIntensity.value = [0.0088];
		vhs.data.offsetIntensity.value = [0.02];
		vhs.data.colorOffsetIntensity.value = [1.3];	
	}

	// this code is optional if you want the dynamic effect
	var time:Float = 0;
	function update(elapsed) {
		time += elapsed;
		vhs.data.iTime.value = [time];
	}
/*_______________________________________________________________________*/

//grain.frag
	var grain = new CustomShader(Paths.shader('grain'));
	function create() {
		// use PlayState.camHUD.addShader(grain); to add it on the HUD
		FlxG.camera.addShader(grain);

		// this has to be here in order to work (the value can be adjusted)
		grain.data.strength.value = [35];
	}

	// this code is optional if you want the dynamic effect
	var time:Float = 0;
	function update(elapsed) {
		time += elapsed;
		grain.data.iTime.value = [time];
	}
/*_______________________________________________________________________*/

//cheatingshader.frag -- shader that gives a trippy effect
	var trippy = new CustomShader(Paths.shader('cheatingshader'));
	function create() {
		// you can use FlxG.camera.addShader(trippy);, but it won't work properly
		// you need to make the sprite in the stage.hx in order to use it
		[var].shader = trippy;
	}

	// this code is optional if you want the dynamic effect
	var time:Float = 0;
	function update(elapsed) {
		time += elapsed;
		trippy.data.iTime.value = [time];
	}
/*_______________________________________________________________________*/

//vignette.frag
	var vignette = new CustomShader(Paths.shader('vignette'));
	function create() {
		FlxG.camera.addShader(vignette);

		// this has to be here in order to work (the values can be adjusted)
		vignette.data.size.value = [1.5];
	}
/*_______________________________________________________________________*/

//oldActualBloom.frag -- shader with some cinematic effects (isn't actually old lol)
	var bloom = new CustomShader(Paths.shader('oldActualBloom'));
	function create() {
		FlxG.camera.addShader(bloom);

		//theres no values to adjust for now
	}
/*_______________________________________________________________________*/

//actualBloom.frag -- oldActualBloom but with less features
	var bloom = new CustomShader(Paths.shader('actualBloom'));
	function create() {
		FlxG.camera.addShader(bloom);

		//theres no values to adjust for now
	}
/*_______________________________________________________________________*/

//bloom.frag -- simple chromatic abberation (theres no bloom)
	var chromaticAbber = new CustomShader(Paths.shader('bloom'));
	function create() {
		// use PlayState.camHUD.addShader(chromaticAbber); to add it on the HUD
		FlxG.camera.addShader(chromaticAbber);

		// these have to be here in order to work (the values can be adjusted)
		chromaticAbber.data.hDRthingy.value = [2]; //aka brightness (the lower the darker)
		chromaticAbber.data.chromatic.value = [0.5];
	}
/*_______________________________________________________________________*/

//bloom2.frag -- chromatic abberation sequel (theres still no bloom)
	var chromaticAbber = new CustomShader(Paths.shader('bloom2'));
	function create() {
		// use PlayState.camHUD.addShader(chromaticAbber); to add it on the HUD
		FlxG.camera.addShader(chromaticAbber);

		//theres no values to adjust for now
	}
/*_______________________________________________________________________*/

//scanLines.frag
	var scanLines = new CustomShader(Paths.shader('scanLines'));
	function create() {
		// use PlayState.camHUD.addShader(scanLines); to add it on the HUD
		FlxG.camera.addShader(scanLines);

		// this has to be here in order to work (the value can be adjusted)
		scanLines.data.opacity.value = [0.3];
	}
/*_______________________________________________________________________*/

//cameraFlip.frag -- flips camera in X axis
	var cameraFlip = new CustomShader(Paths.shader('cameraFlip'));
	function create() {
		// use PlayState.camHUD.addShader(cameraFlip); to add it on the HUD
		FlxG.camera.addShader(cameraFlip);
	}
/*_______________________________________________________________________*/

//mirrored.frag -- flares from actualBloom.frag (doesn't mirror anything)
	var flare = new CustomShader(Paths.shader('mirrored'));
	function create() {
		// use PlayState.camHUD.addShader(flare); to add it on the HUD
		FlxG.camera.addShader(flare);

		// these have to be here in order to work (the values can be adjusted)
		weirdstuff.data.threshold.value = [0.8];
		weirdstuff.data.intensity.value = [200];
		weirdstuff.data.stretch.value = [0.07];
		weirdstuff.data.brightness.value = [0.05];
	}
/*_______________________________________________________________________*/

//outliner.frag -- shader that gives edges a white outline
	var outliner = new CustomShader(Paths.shader('outliner'));
	function create() {
		// use PlayState.camHUD.addShader(outliner); to add it on the HUD
		FlxG.camera.addShader(outliner);

		// this has to be here in order to work (the value can be adjusted)
		outliner.data.edgeIntense.value = [1];
	}
/*_______________________________________________________________________*/