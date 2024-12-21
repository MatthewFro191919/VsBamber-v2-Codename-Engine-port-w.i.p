function beatHit(beat) {
    if (beat == 415) {
        PlayState.scripts.executeFunc('changeScrollSpeed', ['multiply', 0.8, 'both', 2, 'quartInOut']);
    }

    if (beat == 443) {
        PlayState.scripts.executeFunc('changeScrollSpeed', ['multiply', 0.75, 'both', 2, 'quartInOut']);
    }
}