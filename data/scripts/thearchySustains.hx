import Note;
import Conductor;

var enabled = false;
var spacing = 5;
var vocalTimes = [];
var curVocal = [];

if (enabled && !PlayState.fromCharter) {
    function createPost() {
        for (i in 0...PlayState.unspawnNotes.length) {
            var curNote = unspawnNotes[i];

            //Mic'd Up's Jacktastic generation
            /*if (!curNote.isSustainNote) {
                for (num in 0...100) {
                    unspawnNotes.push(new Note(curNote.strumTime, curNote.noteData, null, false, curNote.mustPress, curNote.altAnim));
                    unspawnNotes[unspawnNotes.length - 1].strumTime += 2 * (num + 1);
                }
            }*/

            //Spamtrack generation
            if (!curNote.isSustainNote && curNote.sustainLength > 0) {
                var startTime = curNote.strumTime;
                var endTime = startTime + curNote.sustainLength;
                vocalTimes.push([startTime, endTime, curNote.mustPress]);

                var time = (endTime - startTime - 1) / (spacing * (curNote.mustPress ? 10 : 1));

                curNote.sustainLength = startTime;

                for (i in 0...time) {
                    unspawnNotes.push(new Note(curNote.strumTime, curNote.noteData, null, false, curNote.mustPress, curNote.altAnim));
                    unspawnNotes[unspawnNotes.length - 1].strumTime += (spacing * (curNote.mustPress ? 10 : 1)) * (i + 1);
                    unspawnNotes[unspawnNotes.length - 1].sustainLength = curNote.sustainLength;
                }
            }
        }
        curVocal = vocalTimes.shift();

        unspawnNotes.sort(sortByShit);
        unspawnNotes.filter(x -> !x.isSustainNote);
    }
    
    function update(elapsed) {
        if (curVocal != null && !paused) {
            if (Conductor.songPosition > curVocal[1]) {
                curVocal = vocalTimes.shift();
                PlayState.resyncVocals();
            } else if (Conductor.songPosition >= curVocal[0] && Conductor.songPosition <= curVocal[1]) {
                vocals.time = 100 + curVocal[0];
            }
        }
    }

    function onDadHit(note) {
        updateThearchyVocal(note, false);
    }

    function onPlayerHit(note) {
        updateThearchyVocal(note, true);
    }

    function updateThearchyVocal(note, mustBePressed) {
        if (curVocal != null && curVocal[2] != mustBePressed && Conductor.songPosition >= curVocal[0]) {
            curVocal[0] = (note.sustainLength > 0 ? note.sustainLength : note.strumTime) - 75;
        }
    }
}