

16 March 2012

I'm pleased to announce the first release of Csgrouper, a musical program that 
stands at the intersection of polytonality, polymodality and serialism.



*** What is it?

Csgrouper is a Perl program that generates Csound scores.



*** Why Csgrouper?

Many powerful sound-shaping and sequencing programs exist nowadays, but notation
of Western musical language has been sadly neglected as far as programming goes.
Thislack of innovation leads to the repetition of well-known musical patterns,
and popular harmonies, and presents an opportunity to develop new kinds of notation,
paired with the ability to synthesize sound directly from such notation.

This opportunity to investigate innovation in notation is the reason for Csgrouper.



*** What does Csgrouper do?

Within a strict serial context, there are two related ways to use Csgrouper.

Alternate tunings:
Csgrouper allows the composer to produce musical sequences using different
divisions of the octave (from 2 up to 24 steps, versus 12 in the traditional
equal-tempered system). These sequences are generated from permutation 
functions that work on pure frequencies. You provide compatible Csound 
instruments that are then integrated into the score managed by Csgrouper. Some 
test instruments are provided in the package to get you started.  

Polymodality:
Csgrouper can also select specific items in a sequence tonality to produce a 
mode. Classic modes are available as well as new ones.

These basic tools together with an extensible set of serial sequence 
production functions (12 in all) allow you to create a list of sequence 
definitions, each of which has its own number of intervals and optional mode, plus
its own instrument, size, tempo, development rules, and so on.

Sequences defined in this way can be grouped together into sections with various 
rythmic and harmonic properties defined byt you, such as grouping several sequences
nto a rythmic canon, or an ensemble section using selected sub-sequences determined by 
inter-sequence note relations, or via a rythmic model (binary, ternary, mixed, ...).

Finally,  Csgrouper evaluates the proposed structure and prints the resulting 
Csound unified score. The resulting sound file can be played realtime from the GUI
or recorded to disk. The Csgrouper score, Csound scores, and instruments are all 
saved into a single Csgrouper .xml config file.

Listen to the 7 voice/18 tone raw example.  Csgrouper output isn't algorithmic
composition per se, but a computer-aided means of generating inspriational material
that can help to escape a culturally-restricted, deeply-explored context.

Real music comes out of creatively filtering Csgrouper output, like sculpture 
of stone or wood. Personally, I reprocess Csgrouper-Csound output in other, more
convienient software, such as Blue.


*** Shortcomings

Csgrouper could be improved in many ways. 

It has bugs. Sometimes crashy ones.

It's not pure spaghetti code, but an appreciation of tagliatelle will help 
you feel a little more comfortable if you look at the source.

It's not easy to use. The serial functions (particularly the "train" 
functions) are difficult to understand and require prior analysis through 
provided subroutines (from the "Series" tab).

The GUI is inadequate, and not very pretty. The program can't be run 
properly without also looking at some output from the terminal.

Csgrouper is slow: expect it to take several dozen seconds to load a short 
piece of a few minutes and as much time again to evaluate it before it's 
ready for audio output.

Csgrouper has no test suite.



*** Goals

I've shared this code via Github, and I'd very much like  programmers 
interested by this project to help me to improve it. I'll be happy 
to see the project fork, become smarter, less redundant, have a new and better 
GUI and increase in quality to help musicians make music.


emilbarton@ymail.com



Notes:

1: Cf. ~/Csgrouper/run/sndout/xpace-flute_raw-csg.csd : This raw Csgrouper score
(and related audio output on the Csgrouper download page) is built on a a scale
of 18 notes to the octave - 1/3 tones. The serial material used was chosen for its 
tonal properties which yield a harmonious aspect in spite of the lack of of a 
dominant in the 18-note scale. Feel free to use it as basis for further work!

2: http://www.emilbarton.net76.net contains an "xpace-flute_raw-csg.mp3" 
and a quickly-sculpted) version of the same project renamed "ballad.mp3"
as well as the corresponding score files. 



EOF
