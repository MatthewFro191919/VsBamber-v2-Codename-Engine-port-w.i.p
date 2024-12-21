/*import flixel.FlxCamera;

var noteCams = [];
var camAmount = 5;

if (camAmount > 1) {
    function createPost() {
        var noteCam:FlxCamera = new FlxCamera(camHUD.x, camHUD.y, camHUD.width, camHUD.height);
        noteCam.bgColor = camHUD.bgColor;
        FlxG.cameras.remove(camHUD, false);
        FlxG.cameras.add(noteCam);
        noteCams.push(noteCam);

        var objectsToMove = [notes, strumLineNotes, playerStrums, cpuStrums];

        for (i in objectsToMove) {
            i.cameras = [noteCam];
        }

        for (i in 0...camAmount-1) {
            var clonedCamera:FlxCamera = new FlxCamera(camHUD.x, camHUD.y, camHUD.width, camHUD.height);
            clonedCamera.bgColor = camHUD.bgColor;
            FlxG.cameras.add(clonedCamera);
        
            clonedCamera.angle = 360 / (camAmount) * (i+1);

            noteCams.push(clonedCamera);
            
            for (i in objectsToMove) {
                i.cameras.push(clonedCamera);
            }
        }

        FlxG.cameras.add(camHUD);
    }

    function update60() {
        for (i in noteCams) i.angle += 1;
    }
}*/