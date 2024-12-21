function onCountdown(countdown:Int) {
    if (gf != null && gf.animation.exists('countdown'+countdown)) gf.playAnim('countdown'+countdown);
}

function onSongStart() {
    if (gf != null && gf.animation.curAnim.name == 'countdown0') gf.dance(true);
}