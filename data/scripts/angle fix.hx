import flixel.math.FlxRect;
function updatePost() {
    for (i in FlxG.cameras.list) {
        var flxRect = FlxRect.get();
        flxRect.copyFromFlash(i._scrollRect.scrollRect);
        flxRect.getRotatedBounds(i.angle, FlxPoint.get(FlxMath.lerp(flxRect.left, flxRect.right, 0.5), FlxMath.lerp(flxRect.top, flxRect.bottom, 0.5)),
            flxRect);
        i._scrollRect.x += flxRect.x - i._scrollRect.scrollRect.x;
        i._scrollRect.y += flxRect.y - i._scrollRect.scrollRect.y;
        i._scrollRect.scrollRect = flxRect.copyToFlash();
        flxRect.put();
    }
}
