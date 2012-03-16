


I'm pleased to announce the first release of the Csgrouper musical program.



*** What is it?

Csgrouper is a (badly written) Perl program that outputs partitions for Csound music system.



*** What's the need?

Many powerful sound shaping and sequencing programs exist nowadays but the western musical language in itself is almost completely worked up. The result is a repetition of well-known musical patterns in popular harmonies and a privilege for pure sound treatment in musical research.

Therefore there is an opportunity to investigate in musical language innovation that Csgrouper wants to grasp.



*** What are the means?

There are two related paths followed by Csgrouper.

Polytonality:
On one hand, Csgrouper allows to produce musical sequences with a different number of intervals (from 2 to 24 against 12 in the traditionnal system). These sequences are generated from permutationnal functions that work on pure frequencies. The user must provides his or her code of compatible Csound instruments that are then integrated into the part managed by Csgrouper (some test instruments are provided in the package for a quick start).  

Polymodality:
On the other hand Csgrouper can reduce the number of intervals in the selected sequence tonality so as to produce a mode. Classic modes are available as well as invented ones.

These basic tools together with a developable set of a dozen of sequence production functions permit the creation a list of sequence definitions, each of them having its proper number of intervals and/or mode and its own instrument, size, tempo, development rules etc... 

In a later stage, sequences defined in this way can be grouped together into sections showing various rythmic and harmonic properties according to choices made by the user like grouping several sequences into a rythmic canon, or an ensemble section that will proceed on selected sub-sequences determined by inter-sequences note relations, or choosing a rythmic model (binary, ternary, mixed) etc..

Finally Csgrouper evaluates the proposed structure and prints its Csound unified score part in case the evaluation succeeds. The resulting sound file can be played directly from the Tk interface or recorded on disk. The Csgrouper and Csound parts and instruments are all saved into a Csgrouper .xml config file.

But this output (hear this 7 voices/18 tones raw example[1]) is not yet music, it's just a Computer Aided Inspiration that can serve to escape a culturally restricting inspiration context, often already entirely explored. The real music comes only as a creative act on Csgrouper output, like sculpture on stone or wood. Personally I treat Csgrouper-Csound output in another software, more convenient, like Blue.



*** What are the flaws?

Many. 

Csgrouper has bugs.

Csgrouper could be improved in many ways. For the time being it's not pure spaghetti code, but you have to appreciate tagliatelle somehow.

Csgrouper is not easy to use. The serial functions (particularly "train" functions) are difficult to understand and require prior analysis through provided subroutines (from the "Series" tab).

Csgrouper Tk GUI is inadequate, and looks outdated. Besides, the program can't be run properly without looking at some additionnal output from the terminal.

Csgrouper is processing slowly: count several dozens od seconds to load a short piece of a few minutes and another similar time to evaluate it before it's finally ready for audio output.



*** What is my proposal?

I offer this piece of code for sharing on github, and I'd like programmers interessed by this project to invest their time in improving it. I'll be happy to create branches as needed on github and see the project become less redundant in some parts, smarter, have a new and better GUI, and finally develop independantly, reach quality standard and help musicians do music.


But for now if Perlmonks can give me a first stage evaluation before I post to the Csound mailing list, I'll be very glad.



emilbarton@ymail.com




Notes:

[1]: This raw Csgrouper part is made on a 18 notes scale which means thirds of tones. The serial material used was chosen for its tonal aspect whicn yields a harmonious feeling in spite of the lack of dominant position in the 18 notes scale. Feel free to sculpt on it!

EOF