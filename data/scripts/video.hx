import MP4Handler;
var videoSprite:FlxSprite = new FlxSprite();
var video:MP4Handler = new MP4Handler();
function create() {
    var wasWidescreen = PlayState.isWidescreen;
	video.canSkip = false;
	video.canvasWidth = FlxG.width;
	video.canvasHeight = FlxG.height;
	video.playMP4(Assets.getPath(Paths.getPath("songs/" + PlayState.song.song + "/video.mp4")), false, videoSprite);
    PlayState.isWidescreen = false;
    PlayState.camHUD.bgColor = 0xFF000000;
    videoSprite.cameras = [PlayState.camHUD];
    videoSprite.scrollFactor.set();
    PlayState.add(videoSprite);
}
function update(elapsed) {
	video.isPlaying = PlayState.paused;
}