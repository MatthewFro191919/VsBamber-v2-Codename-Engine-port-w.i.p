//today im gonna try to fix the flawed boyfriend offsets cuz why not

function updatePost(elapsed) {
	if (boyfriend.animation.curAnim != null) boyfriend.offset.set(boyfriend.animOffsets[boyfriend.animation.curAnim.name][0], boyfriend.animOffsets[boyfriend.animation.curAnim.name][1]);
}