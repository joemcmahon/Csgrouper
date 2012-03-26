#!/usr/bin/perl -s 

###############################################################################
## ### FILE INFO: csgrouper.pl.
###############################################################################
## 110606.
## Encoding of this document: iso 8859-1
## Main Tk interface for Csgrouper on Linux.
## Run: $INSTALLDIR/Csgrouper/run/csgrouper .

# Copyright (C) 2012  "Emil Barton" (emilbarton@ymail.com).
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
## Format & comments:
## Notes,warnings, ideas, etc.: XXX NOTE, XXX WARNING, XXX IDEA, etc.
## Explanations and informations: ##..
## Section Start: 								## ###..
## Section End: 									## END..
## Commented out line: 						#..
 
## General task list:
## TODO: use the ternary conditional operator: my $truthiness = $value ? 'true' : 'false';
## END FILE INFO.

=head1 Manual for csgrouper.pl 

=head2 Todo/Questions

 - From now on (120317) and for a while, most changes will concern the Manual 
 pages that need to be completed and they will be mentionned on Github by a
 "Minor comment fix." to distinguish them from possible minor code fixes. 

 - Problem with the instruments fields: 
 in spite of correct bindings sometimes unsupported utf8 are recorded.
 If a .csg recorded part refuses to load it's that some unwanted multibyte char 
 has been inserted at some stage by some keypress (e.g. from Emacs-like reflexes). 
 In this case XML:Simple aborts. The solution is to find and destroy the bad char 
 (showing some special prefixe like ^) with an editor as nano or vi.

		   
=head2 General Introduction and quick start

The aim of this program is to offer at the same time a way to produce musical sequences with interesting mathematical properties and to experiment various tonal, modal and serial settings. Thus everything depends primarily on the serial notation: if you want to work on dodecaphonic series you will be using the dodecaphonic row whose natural expression (the chromatic scale) is "0123456789AB". And every input you will enter will have to contain signs taken within this set. For instance you could choose to ask Csgrouper to produce the sequence corresponding to the gradual suite of one series, say "769801AB3254" (which is the row used by Webern in his Quartet  op. 28) so you would have to create a new row, enter this series into the main field which is named "A", choose "Gradual suite" from the row menu, most of all set the "mode" field to the chromatic scale in base 12, i.e. "0123456789AB", and choose "exp" in order to see the expanded content, otherwise only the final state of the suite would be printed and it would equal its origin in this particular case (this is a bug because the final state of a gradual suite is not its origin but the chromatic scale, being understood that the gradual suite reproduces the same permutation on its output until it reaches the first row on which the permutation was applied that is always the chromatic scale - but we don't care since nobody wants to output the chromatic scale using the non-expanded mode of a Gradual suite). 

As things can reveal difficult to control while working on the "Sequences" tab, there is an analytic tab called "Series" that shows clearly the result of intended actions on serial content. So before creating a sequence it's always a good idea to check there (with help of the menu and button "Apply") that the transformation you are asking makes sense, and some most of the time do not. This is the case with static and dynamic "train" function for which you need to input a key and a list of signs as well as a serial content. For them you will have the opportunity  to introduce the two series that you want to interleaf into fields "A" and "B" of the "Series" tab and ask for "Dynana" (dynamic analysis) or "Inana" (static analysis) and these routines will output the choices of keys and signs you should input in the appropriate fields in order to obtain correct sequential "trains". Just putting any random content won't do and Csgrouper will fail, generally with some more or less instructive complaint.

The various transformation routines proposed refer to dodecaphonic content but applied to various non dodecaphonic bases. The default part for example works in base 18. These routines which will be explained soon, do things like taking the schoenbergian opposite of a row (always relatively to the chosen base) and redo the same on the output till some cycle is attained (because permutations are cyclic) : this is Gradual(Opposite). There are several other variants of such routines, and ways to transpose and mix rows together. If you want to simply introduce your own melody, use Suite(): its content will be respected but some additionnal (neutral) filling might be added at the end, so as to respect the serial structure.  

Once several sequences are created, you might want to either put some of them together, or to concatenate them. This last job is done by the "Pre" field, that allows to choose a "previous" sequence for the one that is treated. The "Set" field permits the grouping of various sequences inside a ... set. This set can then be included into one or the other Xfun fields, and the concerned sequence will receive a postreatment (on duration, amplitude, attack etc.). Sets can also be placed into Yfun fields (Rythmic-canon and Ensemble) and that will produce a structural relation between sequences. Sets can also be grouped into sections.

One thing that is impossible with Csgrouper, is to write a simple tune the way you hear it, because the duration of notes is always computed according to serial properties (or even randomness when it's chosen so). That's why I advise to use this software as a pre-composition tool, in order to hear how it would sound like to use this or that serial, tonal and modal content. Personally I use Csgrouper in order to produce some raw material that I can sculpt afterwards according to my taste.

Last but not least one shouldn't underestimate the importance of the mode field: if not appropriately filled with the whole set of authorized notes (basically the chromatic scale of your base) and the right number of them (12 if you are in base 12) Csgrouper won't output what you are waiting for. When wanting to work in a particular mode, you can replace the notes you don't want to hear by some of the other notes producing various versions of the same mode, as long as you keep the right number of notes. For instance, the Dorian mode can be achieved by setting the "mode" field to "00224557799B" but also "022445797BB9" that will output a different dorian flavour. The secret is simple, at output time notes of the indice are replaced by their content: so in the first dorian flavour C# (1) will be replaced by C (0) but in the second it will be replaced by D (2).

There are still many things to clarify but I think it will be OK for a start with Csgrouper.

Have fun!

=head2 Structure of this program

csgrouper.pl is an interface to the Csgrouper classes.
This program depends also on the package csg_Sets which contain analysis tools that are not needed by the Csgrouper main class package.

Some functions used by classes are meant to be defined at interface level, for them we use a call back method based on an interface package accessible from Csgrouper classes (see Compstr0 et al.). 

=head2 Objects

	$CsgObj->sequences->{Seq_n}. 

The %{$CsgObj->sequences} hash is structured in a peculiar way:

on one side we store Csgrouper::Sequence object references there, as $CsgObj->sequences->{id} keys, on the other side we store Tk rows properties as $CsgObj->sequences->{Tkrow_n_***} where n is a Tk row number (subject to change as sequences are added or deleted) and *** a property. 
  
The sequence id for a specific row n is stored into $CsgObj->sequences->{Tkrow_n_id}.
  
It'd be easier to reference our object as $CsgObj->sequences->{n} but XML.pm doesn't accept numeric keys like <1>...</1> so we reference them as $CsgObj->sequences->{"Seq_$n"}
  
=head2 Final structure

Before writing the Csound file, some important parameters, like note duration, have to be set up as well as the whole list of other possible instrument parameters. This is the job for Xfun() and other subroutines dedicated to the relations between objects. These functions are called by a required "Eval" step which evaluates consistency of the desired layout. In case this layout is not appropriate, the part will bot be writable unless corrections are made at set and section levels (second frame in the Sequences tab).

This control process takes the following path:

	Eval button -> struct_out()-> struct_ctl() 
	
		-> Xfun() -> inseth() -> basedef() -> inote() 
		                                 	-> overfun() 
		                                 	-> overdef()
		-> Yfun()	-> xryc() 
		          	-> yens()

=head2 Xfun()


Among possible parameters, some are so common that they have received a name in csgrouper.pl in order to be able to interact at computation time without having to keep them at special p-values in the instrument text. If the instrument table does not contain the official csgrouper names for these common parameters (like amp for the amplitude, dur for duration and so on), then the computation will only provide the default value for the parameter and this will have consequences on the quality of the resulting csound score file. 

=head2 Parameter overwriting

There is a hierarchy of ways to overwrite a note parameter: 

First, the default value set in the instrument is applied.

This value is a factor in the following cases:

- duration : then $CSG{part_durmin_le} and $CSG{part_durmax_le} will limit variation.

In all other cases default values are directly expressed in the concerned unit (seconds in most of them).

Next, the X-functions set boxes can contain factors or limits for each set of Sequences, that will overwrite the parameter at note computation time. Note that even when no special param would be put into the Xfun box, the simple mention of a set is important in order to override defaults. The content of x-boxes with their optional parameter values have to be written according to the following syntax cases:

	3,2,1 This is the simplest syntax: some sets (there can be only one) separated by the SETSEP separator.
	
In this case the function overfun() launched by inote(), will simply do the special computing originally attributed and overwrite the previous default value. Note that the order of sets is important here because a note can be member of various of them, if the computed note is member of sets 3 and 1 for instance, the last value attributed will be the one in the last set mentionned (here 1). In our example there is no special value attributed to set 1 but it could have been the case with the xfun string "1#0.4,2,3" for example the value first attributed to our note for set 1 would have been overwritten by the default xfun value. This is an inner xfun overwriting process.  

From now on for the sake of simplicity, we'll consider that each xfun box contains only one set mention.

	3#0.3 A set id followed by the param separator and a simple factor value (if there were two sets mentionned we could have a string like "1#B,3#0.3" for instance). 
	
This simple case can be made more complex if one wants to have this factor value as the result of an evaluation. In this case one could well have something like:

	3#$myglobal*$parlist->{dur} where the simple fact that this can be evaluated will provide evaluation. 

Many hacks are possible at this level that one shouldn't play toomuch with...

	3#-0.3 This time the simple value being negative, it implies a special treatment for the factor (usually randomization).

From here the different behaviours of our overfun() routine depends on the presence of a third parameter. 
	
	3#10#90 The set id is followed by the param separator and then a low limit followed by high limit (after separation). This is a valid syntax for xamp for instance but not for xpan nor xgli.

See below under the Data Section to get the precise list of recognized values for other x-functions.	

It should be noted however that X-functions can only overwrite their proper name parameter while the "ipars" Sequence attribute we are going to explore now overwrites any param. 

The Sequence "ipars" attribute can overwrite any of these previous successive attributions in one of two ways: either by passing a p-value string to evaluate like p4='$myglobal*10' or by passing the same string with a named param like amp=10 (see the list of named params below). The latter is more powerful since named params are used preferably at note-computation. Any param meant to be evaluated should be quoted (and not contain single quotes inside) as in:

	i3,dur=0.5,p5=f10,amp='$parlist->{amp}*1.5'

An useful ipars tool consists in setting sta to a certain starting point for the sequence:

	i3,sta=16.5

	
The special hash %parlist is the hash containing previously evaluated params for the note being processed. Thus in the example above, $parlist->{amp} contains a value that may be the default value for the instrument or the overwriting value for this set of sequences, in case the Xamp box contained an overwriting string like:
	
	3:60 	

At last it should be noted that any modification in the Sequence fields require a re-recording of the Sequence (deselect and reselect it) and struct_ctl() to bew run again before the changes can show in the score file. But modification in the Instrument table only require an ins_update() to be done (the "Update" button in the Orchestra tab).	
	
=head3 Duration

The duration of a note can be set deterministically by csgrouper.pl according to cpmstr note parameters, or randomly. There are two ways to set note duration randomly:

=head4 a) the general random duration checkbox

In this case every note in the piece will be set to random duration that can later be reduced to certain limits or scaled according to the appropriate Xdur set params.

=head4 b) the Xdur random duration param

As any set parameter, the Xdur random param has to be inserted into the corresponding box. The syntax for param sequence runs as follows:

	- if param 3 exists:

durations will be set to limits given in param 2 and 3 for the set mentionned in param 1, e.g. 5:3:9 : notes in set 5 will not last less than 3 seconds and longer than 9;

	- if param 3 does not exist and param 2 is positive:

durations as set according to cmpstr note params (see Note class), will be scaled by the factor in param 1, e.g. 5:3:9,4:0.5 : notes in set 4 will last only half their original durations;

	- if param 3 does not exist and param 2 is negative:

durations in this set will be recreated randomly to not exceed duration of the absolute value of the same parameter, e.g. 3:-7,5:3:9,4:0.5 : notes in set 3 will be set randomly but will last less than 7 seconds.


=head2 Frequency

=head2 Csound score writing

Any csd file will contain at the end a copy of the csgrouper part that produced it.



=head1 TK Section

=cut

###############################################################################
## ### USE:
###############################################################################

=head2 Initialization
=cut

use Modern::Perl;
no warnings; ## Uncomment this in case of problem only (stdout pollution).

use Cwd;
use lib ( "$ENV{HOME}/Csgrouper/lib");
# use Data::Dumper; # E.g.:  &Csgrouper::says($subname, Dumper($Part));
# use Data::Dumper::Simple; # Cf. Tk Design Section only.

##use Pod::Simple;
use Scalar::Util qw(blessed);
use Tk;
require Tk::CmdLine;
require Tk::Dialog;
require Tk::DialogBox;
require Tk::FileSelect;
require Tk::NoteBook;
require Tk::Pane;
require Tk::PathEntry;
require Tk::Pod::Text;
require Tk::Table;
require Tk::TextUndo;
use XML::Simple; ## E.g.:  my $part = XMLin('csgdef.xml'); &Csgrouper::says($subname, $part->{logdir}); etc.

use Csgrouper; ## Our Moose class tree.
use Csgrouper::Sequence; 
use Csgrouper::Series; 
use Csgrouper::Types; 
use csg_Sets; ## A temporary outsider.


## END USE.

###############################################################################
## ### GENERAL VARIABLES:
###############################################################################

=head3 The saving process: 

Tk objects variables are first saved by &refer() to the $Part global hash, but with a special naming that impedes these values to be saved later into the xml part file. Actually, any hash name in $Part, that beggins with a hyphen will be skipped in the saving process. 

Each other hash key-value pair (whose name does not beggining with a hyphen sign) is saved into the xml part file. 

Default values for many of the $Part object keys do exist in another global hash: the %CSG object, defined in Csgrouper.pm.

=cut
## ### Constants: a new C style way: 
sub MAXOBJ { $Csgrouper::Types::MAXOBJ }  ## We dont deal with more than 576 Sequences, instruments, data arrays and flags.

## ### Generic Params:
## There is a recognition key for part files 'csg_key' and it is not included  
## here so as not to be saved by default.

## ### Csgrouper.pm globals:
## Csgrouper CSG values can be overriden here:

$Csgrouper::ERROR 	= ""; ## Should always be empty.
$Csgrouper::DEBFLAG	=	0; 	# Variable to test for bugs.
$Csgrouper::DEBSUBS	=	'';	# Variable to test for bugs by subnames.

=head3 Warning on csg containers: 

%CSG is the main fixed container co-related to the XML $Part object (hash keys here == xml keys there), and sometimes correlated to non Tk csg globals.

Hash keys with a hyphen in front will impede XML::Simple from storing them directly and help save their new values acquired through UI. This process require that CSG variables hash keys, $Part object keys, and Tk widgets have the same names spellings. So no matter which is the depth of the widgets in terms of parent-child inheritance, since the widget variable name has to be unique anyway. Thus XML process remains truly simple with only a few levels of intrication. See record(), refer(), reload().

The corresponding $Part XML object contains values displayed by the widgets as modified (or not) during the running process. The values are stored under hash keys displaying the same name as ther corresponding widget. This way we can take advantage of a Dumper function to extract the name of a $variable without knowing it. The names given to the widgets must be as explicit as possible and we choose to include a mention of the widget type in order to be able to reset the widget content just by knowing its variable name (since different widgets do not share the same functions for getting and setting their contents). So a text widget name will end with "_tw" for instance; the widget will also often indicate the tab it is located in, as in 'part_title_le'.

Widgets with purely graphic goal will not have their widget type at the end but more internally, as in 'part_lw_title' where '_lw' stands for 'label widget'; this helps fixing attention on the right objects.
=cut

# $Csgrouper::CSG{'cline'} = '$CsgObj->struct_ctl()';  ## Command Menu

my $subname = "csgrouper";

## Internals Tab:
$Csgrouper::CSG{'csg_file'} = $0;  
$Csgrouper::CSG{'interface'} = "Csgrouperinter";
&Csgrouper::Describe($subname,"Csg interface: ".$Csgrouper::CSG{'interface'});

## ### Our Globals can be set to other values temporarily and reset by &Resetall().
## Here is the place to override default values given by Csgrouper.pm with our new
## defaults. Resetall() vars are aliased with more simpler names. These redundant 
## aliases can help in defining command lines for example:

## Resetall() variables:
our	$Author				=	$Csgrouper::CSG{'part_author_le'} = "E.B."; ## Part Tab
our $BasePath			= $Csgrouper::CSG{'csg_path_pe'};  ## Path Tab # Not user-configurable.
our	$Comptype			=	$Csgrouper::CSG{'part_comptype_mw'}; 				# Comparison function suffixe.
our	$Durtype			=	$Csgrouper::CSG{'part_durtype_mw'}; 				# Duration type 0=serial (normal).
our	$Durmin				=	$Csgrouper::CSG{'part_durmin_le'}; 				   	## The minimal duration that will be multiplied by 1, 2 or 3 (depending on the binary, ternary or mixed rythm setup).
our	$Durmax				=	$Csgrouper::CSG{'part_durmax_le'}; 				  	## A factor of dur_norm.
our	$Intersil			=	$Csgrouper::CSG{'part_intersil_le'};				# Silence between sections.
our	$Rythmtype		=	$Csgrouper::CSG{'part_rythmtype_mw'};				 # Rythm type 0=mixed (normal).
our	$SEPA					=	$Csgrouper::CSG{'separator'}; 							# 
our	$Sf2Path			=	$Csgrouper::CSG{'csound_sf2path_pe'}; 
our	$Steps				=	$Csgrouper::CSG{'part_steps_le'}; 					# Number of steps for trains.
our	$Tempo				=	$Csgrouper::CSG{'part_tempo_le'}; 					# Base number of "seconds" per minute (Scorp).
our	$Title				=	$Csgrouper::CSG{'part_title_le'}; 					# Part Tab
## END Resetall() variables.

## Notes Tab:
$Csgrouper::CSG{'Notes_tw'} 					= 'Some notes.'; ## Notes Tab

## END %CSG Main Fixed container.

## ### Global Display Vars:
my $Date = &Csgrouper::Datem();
my $CsgObj = Csgrouper->new(); ## A required empty Part object.
my $STARTEXEC = 1; ## A simple test for launch time..

## Test:
$CsgObj->testh->{key2} = 'val2';
&Csgrouper::Describe($subname,"CsgObj: testh: key1 = ".$CsgObj->testh->{key1});
&Csgrouper::Describe($subname,"CsgObj: testh: key2 = ".$CsgObj->testh->{key2});
$CsgObj->testh({}); ## Delete the hash..
&Csgrouper::Describe($subname,"CsgObj: testh: key1 = ".$CsgObj->testh->{key1});
&Csgrouper::Describe($subname,"CsgObj: testh: key2 = ".$CsgObj->testh->{key2});
$CsgObj->testh->{key1} = 'val11';
$CsgObj->testh->{key2} = 'val22';
while (my ($key,$val) = each %{$CsgObj->testh}) {
	&Csgrouper::Describe($subname,"CsgObj: testh: $key = $val");
}

=head3 Warning on output and option params: 

Subroutines are divided into 3 main categories: 
	1. Subs that do not return notes or only return individual notes (e.g. Dode).
	2. Subs that return notes and/or mathematical transformations (e.g. Gradual).
	3. Subs that return only sequences of notes (e.g. Intrain).
	4. Subs that return bigger arrangements of notes (e.g. Xens).

Among these categories only the second and third ones have to conform with strict output standards.

For this purpose we choose to use a string options variable that deals with where, wether or not to record the sequence. This param can receive the following values:

	p (=print), 
	c (=continue), 
	r (=record),
	a (=array), 
	s (=scalar) 
	
and is associated with a sequence ($seq) param.

In certain cases the output of a category-2 subroutine can be expanded or not, therefore the option values can also cover these cases by choosing the uppercase version for result expansion.

Category 2 will return numerical values in priority with opts=a. Ready to print output depands on opts=p.

=cut

my %View;
$View{'db_struct_flag'} = 0;

my @ColorSet = (											
	'PaleGoldenRod',		# 0 ## REDS:
	'PeachPuff',				# 1
	'Tan', 							# 2
	'#B03060',					# 3 sort of Crimson (cf checkbox default)	
	'#00FFFF',					## GREENS:
	'MediumAquaMarine',	# 5 Aqua 
	'LightSeaGreen',	  # 6
	'Teal',			   		  # 7
	'Cyan',							## BLUES
	'LightSteelBlue',	  # 9
	'CornflowerBlue', 	# 10	
	'Navy',							# 11	
	'MintCream',				## B&W	
	'Linen',						# 13
	'#C0C0C0',					# 14
	'Black' ,						# 15
	'LightPink'					# 16
);

our %COLOR;

$COLOR{'button_bgcolor'}		= $ColorSet[10];
$COLOR{'button_fgcolor'}		= $ColorSet[11]; 

$COLOR{'cbox_bgcolor'}			= $ColorSet[9]; 
$COLOR{'cbox_fgcolor'}			= $ColorSet[3];
$COLOR{'cbox_disfgcolor'}		= $ColorSet[3];

$COLOR{'input_bgcolor'}			= $ColorSet[12];
$COLOR{'compat_bgcolor'}		= $ColorSet[5];
$COLOR{'input_bgdisabled'}	= $ColorSet[14];
$COLOR{'input_fgcolor'}			= $ColorSet[15];

$COLOR{'label_bgcolor'}			= $ColorSet[0];
$COLOR{'label_fgcolor'}			= $ColorSet[3];

$COLOR{'notebook_bgcolor'}	= $ColorSet[8];
$COLOR{'notebook_fgcolor'}	= $ColorSet[15];

$COLOR{'output_bgcolor'}		= $ColorSet[9]; 
$COLOR{'output_fgcolor'}		= $ColorSet[11];

$COLOR{'table_bgcolor'}			= $ColorSet[13];
$COLOR{'table_fgcolor'}			= $ColorSet[11];

$COLOR{'window_bgcolor'}		= $ColorSet[13];
$COLOR{'window_fgcolor'}		= $ColorSet[15];

$COLOR{'set_bgcolor'}	= $ColorSet[5];
$COLOR{'set_fgcolor'}	= $ColorSet[15];

# A way to override Tk Podtext bug:
Tk::CmdLine::SetResources("*mantab*background: $COLOR{input_bgcolor}"); 


## END Global Display Vars.

## ### Global Non Tk Vars: ************************************************
our 	@GENA					; 	# Serset() et al. general purpose;
our 	%GENH					; 	# Serset() et al. general purpose;
our 	$GENS					; 	# Serset() et al. general purpose;
our 	$PREV					; 	# Serset() et al. previous value;
our 	$CONST				; 	# A constant;

	## Arrays: 
our ($TMP); 
our @XYfun = qw/xamp xatk xdur xgli xhus xpan xrep yens yryc/;

## END Global Non Tk Vars.
## END GENERAL VARIABLES.

###############################################################################
## ### PARSE AND CONFIG:
###############################################################################
## The -s option passed to perl allows variables to be set. 
## Use ./csgrouper mypart.xml to load mypart.
## File Check 1:
my $Csgdef = $Csgrouper::CSG{'run_path_pe'}.'default.xml';
my $Partfile;
$ARGV[0] = "default.xml" if (!(defined ($ARGV[0])));
$ARGV[0] .= ".xml" if ($ARGV[0] !~ /^(.+\.xml)$/);
if (!(-d $Csgrouper::CSG{'ins_path_pe'}) || !(&check_wdir($Csgrouper::CSG{'ins_path_pe'})==0)) { die("No writable ins path ($Csgrouper::CSG{'ins_path_pe'}): Aborting.") }
if (!(-d $Csgrouper::CSG{'part_path_pe'}) || !(&check_wdir($Csgrouper::CSG{'part_path_pe'})==0)) { die("No writable part path ($Csgrouper::CSG{'part_path_pe'}): Aborting.") }
if (!(-d $Csgrouper::CSG{'run_path_pe'}) || !(&check_wdir($Csgrouper::CSG{'run_path_pe'})==0)) { die("No writable run path ($Csgrouper::CSG{'run_path_pe'}): Aborting.") }
if (!(&check_wfile($Csgdef)==0)) { die("No writable run path ($Csgrouper::CSG{'run_path_pe'}): Aborting.") }
## Now the file must exist somewhere..
if (!(-f $Csgrouper::CSG{'run_path_pe'}.$ARGV[0]) && !(-f $Csgrouper::CSG{'part_path_pe'}.$ARGV[0]) && !(-f $ARGV[0])) { # File doesn't seem to exist...
  &Csgrouper::Debug($subname, "Not in working directories : $ARGV[0]..", 1);
  &Csgrouper::Debug($subname, "Trying with $Csgdef..", 1);
  $Partfile = $Csgdef;
  if (check_csgfile($Csgdef)==0) {
		$Csgdef = $Csgrouper::CSG{'run_path_pe'}.'default.xml';
		&part_default;
  }
}
else { ## This will impede user to modify manually certain path variables in partfiles:
	my $com = "";
	if (-f $ARGV[0]) { if (&check_wfile($ARGV[0]) == 0) { $Partfile = $ARGV[0]; $com = "(valid ".$ARGV[0]." in working directory  [precedence 1])" } } ## Wdir has precedence over part path for the same file (a way to allow overcoming precedence2).
  elsif (-f $Csgrouper::CSG{'part_path_pe'}.$ARGV[0] ) { if (&check_wfile($Csgrouper::CSG{'part_path_pe'}.$ARGV[0])==0) { $Partfile = $Csgrouper::CSG{'part_path_pe'}.$ARGV[0] ; $com = "(valid ".$ARGV[0]." in part_path [precedence 2])" } } ## Part path has precedence over run path for the same file.
  elsif (-f $Csgrouper::CSG{'run_path_pe'}.$ARGV[0]) { if (&check_wfile($Csgrouper::CSG{'run_path_pe'}.$ARGV[0])==0) { $Partfile = $Csgrouper::CSG{'run_path_pe'}.$ARGV[0]; $com = "(valid ".$ARGV[0]." in run_path)"  } }
  else { $Partfile = $Csgdef && &Csgrouper::Debug($subname, "Not a valid file ($ARGV[0]), falling back to default.",1) }
  my $wdir = cwd(); my $wtyp = "called from anywhere";
	$wtyp = "called from part_path" if ($Csgrouper::CSG{'part_path_pe'} =~ /^($wdir\/?)$/);
	$wtyp = "called from run_path" if ($Csgrouper::CSG{'run_path_pe'} =~ /^($wdir\/?)$/);
	&Csgrouper::Describe($subname, "partfile: $Partfile $com");
	&Csgrouper::Describe($subname, "$wtyp");
	&Csgrouper::Describe($subname, "working directory: $wdir");
  if (check_csgfile($Partfile)==0) {
		$Csgdef = $Csgrouper::CSG{'run_path_pe'}.'default.xml';
		&part_default;
  }
}
## END PARSE AND CONFIG.

###############################################################################
## ### LOAD AND CONNECT:
###############################################################################
## $Part: Main csg runtime XML object (correlated to %CSG).

NEWSTART:

my $Part = ();
## This is the first of two starter calls to reload(),
## here param 'init' impedes still inexistent Tk objects to be scoped:
&reload('init');
&Csgrouper::Describe($subname,"pid=$$");
## Instructions continue at: "### MAIN LOOP".
## END LOAD AND CONNECT

###############################################################################
## ### TK DESIGN:
###############################################################################

=head2 Tk design
=cut

## ### Tk Variables:
use Data::Dumper::Simple;
my %Tabs;
## END Tk Variables.

## my $mw = tkinit; # or 
my $mw = MainWindow->new; # $mw is the only global to remain lc for compat with code samples.
$mw->minsize(qw(1000 800)); #$mw->maxsize(qw(800 600));
$mw->geometry('1000x900'); # Let the pane define the size.
$mw->bisque;
$Csgrouper::CSG{'csg_status'} = "Started at ".localtime;
$mw->configure(
    -menu => my $menubar = $mw->Menu(-menuitems => &menu_bar)
); 

my $Statusbar = $mw->Label(
	 -textvariable=>\$Csgrouper::CSG{'csg_status'}
)->pack(
	 -side=>'bottom'
	,-anchor =>'nw'
);

## ### NOTEBOOK WIDGET:
my $Book = $mw->NoteBook(
  -backpagecolor => $ColorSet[2]
  ,-focuscolor => $ColorSet[10]
  ,-inactivebackground => $COLOR{'cbox_bgcolor'}
)->pack(
	-fill=>'both'
	,-side=>'top'  
	,-expand=>1 
);

## ### Part Tab:
$Tabs{'part'} = $Book->add("Part", -label=>"Sequences", -raisecmd=>\&book_open);
my $Part_frame = $Tabs{'part'}->Frame(-borderwidth=>4, -relief=>'groove');
$Part_frame->form(-top=>['%1',4], -left=>['%1',0], -right=>['%99',0]);

## $Part_frame:

## Line 1:

my $part_title_le = $Part_frame->LabEntry(
   -label => 'Part title: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  #,-labelFont => '9x15bold'
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_title_le'}
  ,-width => 128
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }
  # ,-invalidcommand => sub { }
);
$part_title_le->form(   
  -left=>['%1',0]
  ,-right=>['%36',4]
  ,-top=>['%1',4]
);

## XXX WARNING: A special way of getting the spelling of '$var' : 
## ($var_spelling) = split /=/, Dumper($var);  ## Enable file saving:
&refer((split /=/, Dumper($part_title_le))[0],'LabEntry',\$part_title_le); ## Refer: 1.

## Part author:
my $part_author_le = $Part_frame->LabEntry(
   -label => 'Author: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_author_le'}
  ,-width => 128
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }
);
$part_author_le->form(   
  -left=>[$part_title_le,0]
  ,-right=>['%72',4]
  ,-top=>['%1',4]
);

&refer((split /=/, Dumper($part_author_le))[0],'LabEntry',\$part_author_le);  ## Refer: 2.

## Rythm-Type:
my $part_rythmtype_mw = $Part_frame->Menubutton(
	 -borderwidth=>1 
	,-background => $COLOR{cbox_bgcolor}
	,-foreground => $COLOR{cbox_fgcolor}
	,-relief=>'groove' 
	,-text=>'Rythm Type'
);
$part_rythmtype_mw->radiobutton(
	-label => 'mixed-'
	,-variable => \$Part->{'part_rythmtype_mw'}
  ,-value => '1'
  ,-underline => 0
  ,-command=> sub { &set_ready(0) }
);
$part_rythmtype_mw->radiobutton(
	-label => 'mixed+'
	,-variable => \$Part->{'part_rythmtype_mw'}
  ,-value => '6'
  ,-underline => 0
  ,-command=> sub { &set_ready(0) }
);
$part_rythmtype_mw->radiobutton(
	-label => 'binary-'
	,-variable => \$Part->{'part_rythmtype_mw'}
  ,-value => '2'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_rythmtype_mw->radiobutton(
	-label => 'binary+'
	,-variable => \$Part->{'part_rythmtype_mw'}
  ,-value => '4'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_rythmtype_mw->radiobutton(
	-label => "ternary-"
	,-variable => \$Part->{'part_rythmtype_mw'}
  ,-value => '3'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_rythmtype_mw->radiobutton(
	-label => "ternary+"
	,-variable => \$Part->{'part_rythmtype_mw'}
  ,-value => '5'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_rythmtype_mw->form(
   -top=>['%1',4]
  ,-left=>[$part_author_le,4]
);
&refer((split /=/, Dumper($part_rythmtype_mw))[0],'Menubutton',\$part_rythmtype_mw);  ## Refer: 6.

## Struct ctl button:
my $part_structctl_bw = $Part_frame->Button(
	 -background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Struct'
	,-text=>' Eval '
  ,-command=> sub { &struct_out() }
)->form(
   -top=>['%1',0]
  ,-right=>['%99',0]
);

## This variable will enable csd writing. 
## Set after Csgrouper->struct_ctl()
my $ready_txt = "CSD: not ready";
my $ready_cbw =  $Part_frame->Label(
	-textvariable=>\$ready_txt
	,-state=>'disabled'
)->form(
  -top=>['%1',4]
  ,-right=>[$part_structctl_bw,2]
);

## Line 2:

## Tempo:
my $part_tempo_le = $Part_frame->LabEntry(
   -label => '  Tempo: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_tempo_le'}
  ,-width => 24
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }
);
$part_tempo_le->form(   
   -top=>[$part_title_le,4]
  ,-left=>['%1',4]
  ,-right=>['%36',4]
);

&refer((split /=/, Dumper($part_tempo_le))[0],'LabEntry',\$part_tempo_le);  ## Refer: 3.

## Inter_sil:
my $part_intersil_le = $Part_frame->LabEntry(
   -label => 'Intersil: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_intersil_le'}
  ,-width => 4
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'float') }
);
$part_intersil_le->form(   
   -top=>[$part_title_le,4]
  ,-left=>[$part_tempo_le,4]
);

&refer((split /=/, Dumper($part_intersil_le))[0],'LabEntry',\$part_intersil_le);  ## Refer: 4.

## Steps:
my $part_steps_le = $Part_frame->LabEntry(
   -label => 'Steps: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_steps_le'}
  ,-width => 4
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'digit') }
);
$part_steps_le->form(   
   -top=>[$part_title_le,4]
  ,-left=>[$part_intersil_le,4]
);

&refer((split /=/, Dumper($part_steps_le))[0],'LabEntry',\$part_steps_le);  ## Refer: 5.

## Durmin:
my $part_durmin_le = $Part_frame->LabEntry(
   -label => 'Dur. min: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_durmin_le'}
  ,-width => 6
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'float') }
);
$part_durmin_le->form(   
   -top=>[$part_title_le,4]
  ,-left=>[$part_steps_le,4]
);

&refer((split /=/, Dumper($part_durmin_le))[0],'LabEntry',\$part_durmin_le);  ## Refer: 5.

## Durmax:
my $part_durmax_le = $Part_frame->LabEntry(
   -label => 'fac. max: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_durmax_le'}
  ,-width => 4
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'float') }
);
$part_durmax_le->form(   
   -top=>[$part_title_le,4]
  ,-left=>[$part_durmin_le,4]
);

&refer((split /=/, Dumper($part_durmax_le))[0],'LabEntry',\$part_durmax_le);  ## Refer: 5.

## Reset button:
my $part_reset_bw = $Part_frame->Button(
	 -background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Reset'
	,-command=>\&part_reset
)->form(
   -top=>[$part_title_le,0]
  ,-right=>['%99',0]
);

## Debug button:
my $part_debug_bw = $Part_frame->Button(
	 -background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Debug'
	,-command=> sub { $Csgrouper::DEBFLAG = eval($Csgrouper::DEBFLAG == 0); say "deb=".$Csgrouper::DEBFLAG }
)->form(
   -top=>[$part_title_le,0]
  ,-right=>[$part_reset_bw,0]
);


## ### Frame 2 (write):
my $Part_frame2 = $Tabs{'part'}->Frame(-borderwidth=>4, -relief=>'groove');
$Part_frame2->form(-top=>[$Part_frame,4], -left=>['%1',0], -right=>['%99',0]);

## Line 1:

## Xdur:
my $part_xdur_le = $Part_frame2->LabEntry(
   -label => 'Xdur: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_xdur_le'}
  ,-width => 9
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'text') }
);
$part_xdur_le->form(   
   -top=>['%1',0]
#  ,-right=>['%12',4]
  ,-left=>['%0',4]
);

&refer((split /=/, Dumper($part_xdur_le))[0],'LabEntry',\$part_xdur_le);  ## Refer: 7.

## Xamp:
my $part_xamp_le = $Part_frame2->LabEntry(
   -label => 'Xamp: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_xamp_le'}
  ,-width => 9
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'text') }
);

$part_xamp_le->form(   
   -top=>['%1',0]
#  ,-right=>['%24',4]
  ,-left=>['%13',4]
);

&refer((split /=/, Dumper($part_xamp_le))[0],'LabEntry',\$part_xamp_le); ## Refer: 8.

## Xhus:
my $part_xhus_le = $Part_frame2->LabEntry(
   -label => 'Xhus: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_xhus_le'}
  ,-width => 9
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'text') }
);
$part_xhus_le->form(   
   -top=>['%1',0]
#  ,-right=>['%36',4]
  ,-left=>['%26',4]
);

&refer((split /=/, Dumper($part_xhus_le))[0],'LabEntry',\$part_xhus_le);  ## Refer: 9.

## Xatk:
my $part_xatk_le = $Part_frame2->LabEntry(
   -label => 'Xatk: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_xatk_le'}
  ,-width => 9
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'text') }
);
$part_xatk_le->form(   
   -top=>['%1',0]
#  ,-right=>['%48',4]
  ,-left=>['%39',4]
);

&refer((split /=/, Dumper($part_xatk_le))[0],'LabEntry',\$part_xatk_le);   ## Refer: 10.

## Xpan:
my $part_xpan_le = $Part_frame2->LabEntry(
   -label => 'Xpan: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_xpan_le'}
  ,-width => 9
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'text') }
);
$part_xpan_le->form(   
   -top=>['%1',0]
#  ,-right=>['%60',4]
  ,-left=>['%52',4]
);

&refer((split /=/, Dumper($part_xpan_le))[0],'LabEntry',\$part_xpan_le);  ## Refer: 11.

## Xgli:
my $part_xgli_le = $Part_frame2->LabEntry(
   -label => 'Xgli: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_xgli_le'}
  ,-width => 9
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'text') }
);

$part_xgli_le->form(   
   -top=>['%1',0]
#  ,-right=>['%72',4]
  ,-left=>['%65',4]
);

&refer((split /=/, Dumper($part_xgli_le))[0],'LabEntry',\$part_xgli_le);  ## Refer: 12.

## Sequences buttons:
my $del_seq_bw = $Part_frame2->Button(
	 -background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Delete'
	,-command=>\&seq_del
)->form(
   -top=>['%1',0]
  ,-right=>['%99',0]
);

my $add_seq_bw = $Part_frame2->Button(	
	-background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Add'
	,-command=>\&seq_add
)->form(
   -top=>['%1',0]
  ,-right=>[$del_seq_bw,0]
);

my $seq_label_text = "Sequences: ";
my $seq_label = $Part_frame2->Label( -textvariable=>\$seq_label_text )->form(
   -top=>['%1',4]
  ,-right=>[$add_seq_bw,0]
);

## Line 2:
## Xsec:

## Xryc:
my $part_yryc_le = $Part_frame2->LabEntry(
   -label => 'R-Canon: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_yryc_le'}
  ,-width => 16
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'text') }
);
$part_yryc_le->form(   
   -top=>[$part_xamp_le,6]
  ,-left=>['%1',4]
);

&refer((split /=/, Dumper($part_yryc_le))[0],'LabEntry',\$part_yryc_le);  ## Refer: 13.

## Xens:
my $part_yens_le = $Part_frame2->LabEntry(
   -label => 'Ensemble: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_yens_le'}
  ,-width => 16
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'text') }
);
$part_yens_le->form(   
   -top=>[$part_xamp_le,6]
  ,-left=>['%24',4]
);

&refer((split /=/, Dumper($part_yens_le))[0],'LabEntry',\$part_yens_le); ## Refer: 14.

## Groupings:
my $part_sections_le = $Part_frame2->LabEntry(
   -label => 'Sections: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{set_bgcolor}
  ,-foreground => $COLOR{set_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_sections_le'}
  ,-width => 16
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'subsets') }
);
$part_sections_le->form(   
   -top=>[$part_xamp_le,6]
  ,-left=>['%48',4]
);

&refer((split /=/, Dumper($part_sections_le))[0],'LabEntry',\$part_sections_le); ## Refer: 15.

## Comp-Type:
my $part_comptype_mw = $Part_frame2->Menubutton(
	 -borderwidth=>1 
	,-background => $COLOR{cbox_bgcolor}
	,-foreground => $COLOR{cbox_fgcolor}
	,-relief=>'groove' 
	,-text=>'Comp. Type'
);
$part_comptype_mw->radiobutton(
	-label => 'self (Compstr0)'
	,-variable => \$Part->{'part_comptype_mw'}
  ,-value => '0'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_comptype_mw->radiobutton(
	-label => 'random (Compstr4)'
	,-variable => \$Part->{'part_comptype_mw'}
  ,-value => '4'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_comptype_mw->form(
   -top=>[$part_xamp_le,6]
  ,-left=>[$part_sections_le,4]
);
&refer((split /=/, Dumper($part_comptype_mw))[0],'Menubutton',\$part_comptype_mw);  ## Refer: 6.

## Dur-Type:
my $part_durtype_mw = $Part_frame2->Menubutton(
	 -borderwidth=>1 
	,-background => $COLOR{cbox_bgcolor}
	,-foreground => $COLOR{cbox_fgcolor}
	,-relief=>'groove' 
	,-text=>'Dur. Type'
);
$part_durtype_mw->radiobutton(
	-label => 'serial'
	,-variable => \$Part->{'part_durtype_mw'}
  ,-value => '0'
  ,-underline => 0
  ,-command=> sub { &set_ready(0) }
);
$part_durtype_mw->radiobutton(
	-label => 'random'
	,-variable => \$Part->{'part_durtype_mw'}
  ,-value => '1'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_durtype_mw->radiobutton(
	-label => "fixed (".$Csgrouper::CSG{'part_durmin_le'}." sec.)"
	,-variable => \$Part->{'part_durtype_mw'}
  ,-value => '2'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_durtype_mw->form(
   -top=>[$part_xamp_le,6]
  ,-left=>[$part_comptype_mw,4]
);
&refer((split /=/, Dumper($part_durtype_mw))[0],'Menubutton',\$part_durtype_mw);  ## Refer: 6.

## ### Seq Table:
my $Seq_tblw = $Tabs{'part'}->Table(
   -rows => 18
  ,-columns => 30
  ,-relief=>'raised'
  ,-scrollbars => 'se' 
  ,-fixedrows => 1
  ,-fixedcolumns => 0
  ,-takefocus => 'on'
);

&seq_header(); ## Create the header row.
$Seq_tblw->form(-top=>[$Part_frame2,4], -left=>['%2',4], -right=>['%98',4]);

## Let's store a reference to it in order to refresh the file contents:
&refer((split /=/, Dumper($Seq_tblw))[0],'SeqTable',\$Seq_tblw);  ## Refer: 18.

## Let's load rows (or define a new one).
## XXX WARNING: seq_load() must occur after refer() at init time:
## this will be done in reload().

## END Part Tab

## ### The Orchestra sub-notebook:
$Tabs{'orchestra'} = $Book->add("Orchestra", -label=>"Orchestra", -state=>'normal', -raisecmd=>\&book_open);
my $Orcbook = $Tabs{'orchestra'}->NoteBook(
   -backpagecolor => $ColorSet[2]
  ,-focuscolor => $ColorSet[10]
  ,-inactivebackground => $COLOR{'button_bgcolor'}
)->pack(
	-fill=>'both'
	,-side => 'left'  
	,-expand=>1 
);
## F-Table widget:
$Tabs{'ftb'} = $Orcbook->add("F-tables", -label=>"F-tables", -raisecmd=>\&book_open);

## ### Special real scrolled syntax..
my $Ftb_top_tw = $Tabs{'ftb'}->Scrolled (
  'TextUndo'
  , -background=>$COLOR{input_bgcolor}
  , -foreground =>$COLOR{input_fgcolor}
  , -scrollbars => 'se' 
  , -wrap => 'word' 
)->form(-top=>['%1',8], -left=>['%1',0], -right=>['%99',0], -bottom=>['%98',0]);
my $Ftb_tw = $Ftb_top_tw->Subwidget("scrolled"); # get real widget

## ### .. instead of the buggy: 
## my $Ftb_tw = $Tabs{'ftb'}->Scrolled(
##   'TextUndo'
##   , -background=>$COLOR{input_bgcolor}
##   , -foreground =>$COLOR{input_fgcolor}
##   , -scrollbars => 'se' 
##   , -wrap => 'word' 
## );
## $Ftb_tw->form(-top=>['%1',8], -left=>['%1',0], -right=>['%99',0], -bottom=>['%98',0]);
## .. which inserts unwanted unicode at control keys press.
## ###

&refer((split /=/, Dumper($Ftb_tw))[0],'TextUndo',\$Ftb_tw); ## Refer: 19.
$Ftb_tw->Contents($Part->{'Ftb_tw'}); ## Don't forget to load the content before starting.

## Global init:
$Tabs{'init'} = $Orcbook->add("Init", -label=>"Init", -raisecmd=>\&book_open);
## ### Special real scrolled syntax..
my $Orcini_top_tw = $Tabs{'init'}->Scrolled (
  'TextUndo'
  , -background=>$COLOR{input_bgcolor}
  , -foreground =>$COLOR{input_fgcolor}
  , -scrollbars => 'se' 
  , -wrap => 'word' 
)->form(-top=>['%1',8], -left=>['%1',0], -right=>['%99',0], -bottom=>['%98',0]);
my $Orcini_tw = $Orcini_top_tw->Subwidget("scrolled"); ## Get the real widget.
&refer((split /=/, Dumper($Orcini_tw))[0],'TextUndo',\$Orcini_tw); ## Refer: 20.
$Orcini_tw->Contents($Part->{Orcini_tw}); ## Don't forget to load the content before starting.

## Tab for default inst:
&ins_load();
my $test = 0;
for (my $n = 1; $n <= MAXOBJ; $n++) { $test = 1 if (exists $CsgObj->instruments->{"I$n"}) }
&Csgrouper::Describe($subname,"ins_def() test == $test");
&ins_def() if ($test == 0); ## We need a first instrument tab.
## Let's store a reference without having a widget though.
&refer('InsTab','InsTab',\%{$CsgObj->instruments});  ## Refer: 21.

## END Orchestra sub-notebook

## ### Score Tab:
$Tabs{'score'} = $Book->add("Score", -label=>"CSD", -state=>'normal', -raisecmd=>\&book_open); # disabled
## Score selection Frame:
my $Score_select_frame = $Tabs{'score'}->Frame(-borderwidth=>4, -relief=>'groove');
$Score_select_frame->form(-top=>['%1',4], -left=>['%1',0], -right=>['%99',0]);
my $score_empty_bw = $Score_select_frame->Button(
	-background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Delete'
	,-command=>\sub { &csd_empty }
)->form(
   -top=>['%1',4]
  ,-right=>['%99',4]
);
my $score_save_bw = $Score_select_frame->Button(
	-background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Save As'
	,-command=>\sub { &csd_sas }
)->form(
   -top=>['%1',4]
  ,-right=>[$score_empty_bw,4]
);
my $score_render_bw = $Score_select_frame->Button(
	-background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Render'
	,-command=>\sub { &csd_render }
)->form(
   -top=>['%1',4]
  ,-right=>[$score_save_bw,4]
);
my $score_play_bw = $Score_select_frame->Button(
	-background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Play'
	,-command=>\sub { &csd_play }
)->form(
   -top=>['%1',4]
  ,-right=>[$score_render_bw,4]
);
my $score_write_bw = $Score_select_frame->Button(
	-background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Rewrite'
	,-command=>\&csd_write
)->form(
   -top=>['%1',4]
  ,-right=>[$score_play_bw,4]
);

my $score_structctl_bw = $Score_select_frame->Button(
	 -background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Struct'
	,-text=>' Eval '
  ,-command=> sub { &struct_out() }
)->form(
   -top=>['%1',4]
  ,-right=>[$score_write_bw,4]
);

## Cf. above Part_frame for variables:
my $ready_cbw2 =  $Score_select_frame->Label(
	-textvariable=>\$ready_txt
	,-state=>'disabled'
)->form(
  -top=>['%1',6]
  ,-right=>[$score_structctl_bw,-4]
);

## This cb and the associated field will decide wether to print  
## only some Sequences in the final csd part (because a Sequence 
## can be needed for computation but not wanted in the final score).
my $sel_prnt_cbw =  $Score_select_frame->Checkbutton(
	-text=>"Comment out ids:"
	,-variable=>\$Part->{'part_selprnt_le'}
	,-onvalue=>1
	,-offvalue=>0
)->form(
  -top=>['%1',4]
  ,-left=>['%1',4]
);

## Select sequences:

my $part_select_le = $Score_select_frame->LabEntry(
   -label => ''
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'part_select_le'}
  ,-width => 6
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'digicominst',"",1) }
);
$part_select_le->form(   
   -top=>['%1',4]
  ,-left=>[$sel_prnt_cbw,4]
);

&refer((split /=/, Dumper($part_select_le))[0],'LabEntry',\$part_select_le); ## Refer: 16.

## Comp-Type2:
my $part_comptype2_mw = $Score_select_frame->Menubutton(
	 -borderwidth=>1 
	,-background => $COLOR{cbox_bgcolor}
	,-foreground => $COLOR{cbox_fgcolor}
	,-relief=>'groove' 
	,-text=>'Comp. Type'
);
$part_comptype2_mw->radiobutton(
	-label => 'self (Compstr0)'
	,-variable => \$Part->{'part_comptype_mw'}
  ,-value => '0'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_comptype2_mw->radiobutton(
	-label => 'random (Compstr4)'
	,-variable => \$Part->{'part_comptype_mw'}
  ,-value => '4'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_comptype2_mw->form(
   -top=>['%1',4]
  ,-left=>[$part_select_le,14]
);
&refer((split /=/, Dumper($part_comptype2_mw))[0],'Menubutton',\$part_comptype2_mw);  ## Refer: 16b.

## Dur-Type2:
my $part_durtype2_mw = $Score_select_frame->Menubutton(
	 -borderwidth=>1 
	,-background => $COLOR{cbox_bgcolor}
	,-foreground => $COLOR{cbox_fgcolor}
	,-relief=>'groove' 
	,-text=>'Dur. Type'
);
$part_durtype2_mw->radiobutton(
	-label => 'serial'
	,-variable => \$Part->{'part_durtype_mw'}
  ,-value => '0'
  ,-underline => 0
  ,-command=> sub { &set_ready(0) }
);
$part_durtype2_mw->radiobutton(
	-label => 'random'
	,-variable => \$Part->{'part_durtype_mw'}
  ,-value => '1'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_durtype2_mw->radiobutton(
	-label => "fixed (".$Csgrouper::CSG{'part_durmin_le'}." sec.)"
	,-variable => \$Part->{'part_durtype_mw'}
  ,-value => '2'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_durtype2_mw->form(
   -top=>['%1',4]
  ,-left=>[$part_comptype2_mw,4]
);
&refer((split /=/, Dumper($part_durtype2_mw))[0],'Menubutton',\$part_durtype2_mw);  ## Refer: 16c.

## Rythm-Type2:
my $part_rythmtype2_mw = $Score_select_frame->Menubutton(
	 -borderwidth=>1 
	,-background => $COLOR{cbox_bgcolor}
	,-foreground => $COLOR{cbox_fgcolor}
	,-relief=>'groove' 
	,-text=>'Rythm Type'
);
$part_rythmtype2_mw->radiobutton(
	-label => 'mixed-'
	,-variable => \$Part->{'part_rythmtype_mw'}
  ,-value => '1'
  ,-underline => 0
  ,-command=> sub { &set_ready(0) }
);
$part_rythmtype2_mw->radiobutton(
	-label => 'mixed+'
	,-variable => \$Part->{'part_rythmtype_mw'}
  ,-value => '6'
  ,-underline => 0
  ,-command=> sub { &set_ready(0) }
);
$part_rythmtype2_mw->radiobutton(
	-label => 'binary-'
	,-variable => \$Part->{'part_rythmtype_mw'}
  ,-value => '2'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_rythmtype2_mw->radiobutton(
	-label => 'binary+'
	,-variable => \$Part->{'part_rythmtype_mw'}
  ,-value => '4'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_rythmtype2_mw->radiobutton(
	-label => "ternary-"
	,-variable => \$Part->{'part_rythmtype_mw'}
  ,-value => '3'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_rythmtype2_mw->radiobutton(
	-label => "ternary+"
	,-variable => \$Part->{'part_rythmtype_mw'}
  ,-value => '5'
  ,-underline => 0
  ,-command=> sub {  &set_ready(0) }
);
$part_rythmtype2_mw->form(
   -top=>['%1',4]
  ,-left=>[$part_durtype2_mw,4]
);
&refer((split /=/, Dumper($part_rythmtype2_mw))[0],'Menubutton',\$part_rythmtype2_mw);  ## Refer: 16d.

my $Score_top_tw = $Tabs{'score'}->Scrolled (
  'TextUndo'
  , -background =>$COLOR{input_bgcolor}
  , -foreground =>$COLOR{input_fgcolor}
  , -scrollbars => 'se' 
  , -wrap => 'word' 
)->form(-top=>[$Score_select_frame,8], -left=>['%1',0], -right=>['%99',0], -bottom=>['%98',0]);
my $Score_tw = $Score_top_tw->Subwidget("scrolled"); ## Get the real widget.
## I don't know yet wether to store Score_tw in part file... 110611.
## Let's store a reference to it in order to refresh the file contents:
&refer((split /=/, Dumper($Score_tw))[0],'TextUndo',\$Score_tw); ## Refer: 22.

## END Score Tab.

## ### Series Tab:
$Tabs{'series'} = $Book->add("Series", -label=>"Series", -raisecmd=>\&book_open);

## Serial Analyse Frame:
my $Series_ana_frame = $Tabs{'series'}->Frame(-borderwidth=>4, -relief=>'groove');
$Series_ana_frame->form(-top=>['%1',4], -left=>['%1',0], -right=>['%99',0], -bottom=>['%98',0]);
my ($anavar,$tanavar);
my $A_series_le = $Series_ana_frame->LabEntry(
   -label => 'A: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{compat_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'A_series_le'}
  ,-width => 24
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'xphonic',"",1) }
);

$A_series_le->form(   
   -top=>['%1',4]
  ,-left=>['%1',4]
);

&refer((split /=/, Dumper($A_series_le))[0],'LabEntry',\$A_series_le); ## Refer: 23.

my $A_octs_le = $Series_ana_frame->LabEntry(
   -label => 'Aoct: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'A_octs_le'}
  ,-width => 24
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'xphonic',"",1) }
);
$A_octs_le->form(   
   -top=>['%1',4]
  ,-left=>[$A_series_le,4]
);

&refer((split /=/, Dumper($A_octs_le))[0],'LabEntry',\$A_octs_le); ## Refer: 24.

$Part->{'ana_Aroc_cb'} = 0;
my $ana_Aroc_cb = $Series_ana_frame->Checkbutton(
	-text=>'ran: '
	,-variable=>\$Part->{'ana_Aroc_cb'}
	,-onvalue=>1
	,-offvalue=>0
)->form(
   -top=>['%1',4]
  ,-left=>[$A_octs_le,0]
);

&refer((split /=/, Dumper($ana_Aroc_cb))[0],'Checkbutton',\$ana_Aroc_cb); ## Refer: 25.

my $ord_series_le = $Series_ana_frame->LabEntry(
   -label => 'ord: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{compat_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'ord_series_le'}
  ,-width => 24
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'param',"",1) }
);
$ord_series_le->form(   
   -top=>['%1',4]
  ,-left=>[$ana_Aroc_cb,4]
);

&refer((split /=/, Dumper($ord_series_le))[0],'LabEntry',\$ord_series_le); ## Refer: 26.

my $series_ana_mw = $Series_ana_frame->Optionmenu(
		 -options => &fun_menu('ana')
		,-background =>$COLOR{'input_bgcolor'} 
		,-foreground =>$COLOR{'input_fgcolor'}
		,-variable =>\$anavar,
		,-textvariable =>\$tanavar
		,-command => ''
  );

$series_ana_mw->form(-right=>['%99',0],-top=>['%1',2]);

## Second line

my $B_series_le = $Series_ana_frame->LabEntry(
   -label => 'B: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{compat_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'B_series_le'}
  ,-width => 24
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'xphonic',"",1) }
);
$B_series_le->form(   
   -top=>[$A_series_le,4]
  ,-left=>['%1',4]
);

&refer((split /=/, Dumper($B_series_le))[0],'LabEntry',\$B_series_le); ## Refer: 27.

my $B_octs_le = $Series_ana_frame->LabEntry(
   -label => 'Boct: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'B_octs_le'}
  ,-width => 24
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'xphonic',"",1) }
);
$B_octs_le->form(   
   -top=>[$A_series_le,4]
  ,-left=>[$B_series_le,4]
);

&refer((split /=/, Dumper($B_octs_le))[0],'LabEntry',\$B_octs_le); ## Refer: 28.

$Part->{'ana_Broc_cb'} = 0;
my $ana_Broc_cb = $Series_ana_frame->Checkbutton(
	-text=>'ran: '
	,-variable=>\$Part->{'ana_Broc_cb'}
	,-onvalue=>1
	,-offvalue=>0
)->form(
   -top=>[$A_series_le,4]
  ,-left=>[$B_octs_le,0]
);

&refer((split /=/, Dumper($ana_Broc_cb))[0],'Checkbutton',\$ana_Broc_cb); ## Refer: 29.

my $signs_series_le = $Series_ana_frame->LabEntry(
   -label => 'sig: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'signs_series_le'}
  ,-width => 24
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'plusminus',"",1) }
);
$signs_series_le->form(   
   -top=>[$A_series_le,4]
  ,-left=>[$ana_Broc_cb,4]
);

&refer((split /=/, Dumper($signs_series_le))[0],'LabEntry',\$signs_series_le); ## Refer: 30.

my $mod_series_le = $Series_ana_frame->LabEntry(
   -label => 'mod: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{'compat_bgcolor'}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'mod_series_le'}
  ,-width => 24
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'xphonic',"",1) }
);

$mod_series_le->form(   
   -top=>[$A_series_le,4]
  ,-left=>[$signs_series_le,4]
);

&refer((split /=/, Dumper($mod_series_le))[0],'LabEntry',\$mod_series_le); ## Refer: 31.

## Third line

my $base_param_le = $Series_ana_frame->LabEntry(
   -label => 'base: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'base_param_le'}
  ,-width => 4
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'digit',"",1) }
);
$base_param_le->form(   
   -top=>[$B_series_le,4]
  ,-left=>[ '%1',4]
);

&refer((split /=/, Dumper($base_param_le))[0],'LabEntry',\$base_param_le); ## Refer: 32.

my $range_param_le = $Series_ana_frame->LabEntry(
   -label => 'range: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'range_param_le'}
  ,-width => 4
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'digit',"",1) }
);
$range_param_le->form(   
   -top=>[$B_series_le,4]
  ,-left=>[$base_param_le,4]
);

&refer((split /=/, Dumper($range_param_le))[0],'LabEntry',\$range_param_le); ## Refer: 33.

$Part->{'ana_sense_cb'} = 1;
my $ana_sense_cb = $Series_ana_frame->Checkbutton(
	-text=>'sens '
	,-variable=>\$Part->{'ana_sense_cb'}
	,-onvalue=>1
	,-offvalue=>0
)->form(
   -top=>[$B_series_le,4]
  ,-left=>[$range_param_le,0]
);

&refer((split /=/, Dumper($ana_sense_cb))[0],'Checkbutton',\$ana_sense_cb); ## Refer: 34.

$Part->{'ana_exp_cb'} = 0;
my $ana_exp_cb = $Series_ana_frame->Checkbutton(
	-text=>'exp '
	,-variable=>\$Part->{'ana_exp_cb'}
	,-onvalue=>1
	,-offvalue=>0
)->form(
   -top=>[$B_series_le,4]
  ,-left=>[$ana_sense_cb,0]
);

&refer((split /=/, Dumper($ana_exp_cb))[0],'Checkbutton',\$ana_exp_cb); ## Refer: 35.

$Part->{'ana_line_cb'} = 0; ## Use this to decide wether erasing previous output.
my $ana_line_cb = $Series_ana_frame->Checkbutton(
	 -text=>'line '
	,-variable=>\$Part->{'ana_line_cb'}
	,-onvalue=>1
	,-offvalue=>0
)->form(
   -top=>[$B_series_le,4]
  ,-left=>[$ana_exp_cb,0]
);

&refer((split /=/, Dumper($ana_line_cb))[0],'Checkbutton',\$ana_line_cb); ## Refer: 36.

my $N_param_le = $Series_ana_frame->LabEntry(
   -label => 'n: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'N_param_le'}
  ,-width => 4
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'float',"",1) }
);
$N_param_le->form(   
   -top=>[$B_series_le,4]
  ,-left=>[$ana_line_cb,4]
);

&refer((split /=/, Dumper($N_param_le))[0],'LabEntry',\$N_param_le); ## Refer: 37.

my $X_param_le = $Series_ana_frame->LabEntry(
   -label => 'x: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'X_param_le'}
  ,-width => 4
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'float',"",1) }
);
$X_param_le->form(   
   -top=>[$B_series_le,4]
  ,-left=>[$N_param_le,4]
);

&refer((split /=/, Dumper($X_param_le))[0],'LabEntry',\$X_param_le); ## Refer: 38.

my $Y_param_le = $Series_ana_frame->LabEntry(
   -label => 'y: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'Y_param_le'}
  ,-width => 4
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'float',"",1) }
);
$Y_param_le->form(   
   -top=>[$B_series_le,4]
  ,-left=>[$X_param_le,4]
);

&refer((split /=/, Dumper($Y_param_le))[0],'LabEntry',\$Y_param_le); ## Refer: 39.

my $Z_param_le = $Series_ana_frame->LabEntry(
   -label => 'z: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'Z_param_le'}
  ,-width => 4
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'float',"",1) }
);
$Z_param_le->form(   
   -top=>[$B_series_le,4]
  ,-left=>[$Y_param_le,4]
);

&refer((split /=/, Dumper($Z_param_le))[0],'LabEntry',\$Z_param_le); ## Refer: 40.

$Part->{'tone_param_le'} //= 0;

my $tone_param_le = $Series_ana_frame->LabEntry(
   -label => 'tone: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'tone_param_le'}
  ,-width => 4
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'inst',"",1) }
);
$tone_param_le->form(   
   -top=>[$B_series_le,4]
  ,-left=>[$Z_param_le,4]
);

&refer((split /=/, Dumper($tone_param_le))[0],'LabEntry',\$tone_param_le); ## Refer: 41.

my $ins_param_le = $Series_ana_frame->LabEntry(
   -label => 'ins: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'ins_param_le'}
  ,-width => 4
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'inst',"",1) }
);
$ins_param_le->form(   
   -top=>[$B_series_le,4]
  ,-left=>[$tone_param_le,4]
);

&refer((split /=/, Dumper($ins_param_le))[0],'LabEntry',\$ins_param_le); ## Refer: 42.

my $anaplay_bw = $Series_ana_frame->Button(
	-background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Play '
	,-state=>'disabled'
	,-command=>sub{ }
)->form(
   -top=>[$B_series_le,0]
  ,-right=>['%99',0]
);


my $ana_bw = $Series_ana_frame->Button(
	-background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Apply '
	,-command=>\&anado
)->form(
   -top=>[$B_series_le,0]
  ,-right=>[$anaplay_bw,-4]
);

## Fourth line
my $cmd_line_bw = $Series_ana_frame->Button(
	-background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Send '
	,-command=>\&anacom
)->form(
   -top=>[$ana_bw,4]
  ,-right=>['%99',0]
);

my $cmd_line = '&recurse("0123","rec1",0,1)';
my $ana_cmd_le = $Series_ana_frame->LabEntry(
   -label => 'cmd line: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$cmd_line
);

$ana_cmd_le->form(   
   -top=>[$ana_bw,6]
  ,-right=>[$cmd_line_bw,-4]
  ,-left=>['%1',4]
);

## No need to store.
	
## END Series Tab.

## ### Notes Tab:
$Tabs{'Notes'} = $Book->add("Notes", -label=>"Notes", -raisecmd=>\&book_open);

## Notes Frame:
my $Notes_frame = $Tabs{'Notes'}->Frame(-borderwidth=>4, -relief=>'groove');
$Notes_frame->form(-top=>['%1',4], -left=>['%1',0], -right=>['%99',0]);
my $notes_lw_text = "Notes: ";
my $notes_lw = $Notes_frame->Label( -textvariable=>\$notes_lw_text )->form(-top=>['%1',8], -left=>['%1',0]);
my $notes_state ="disabled";
my $notes_save_bw = $Notes_frame->Button(
	-background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Save As'
	,-state=>$notes_state
	,-command=>\sub { &notes_sas }
)->form(
   -top=>['%1',4]
  ,-right=>['%99',0]
);

## ### special real scrolled syntax:
my $Notes_top_tw = $Tabs{'Notes'}->Scrolled (
  'TextUndo'
  , -background=>$COLOR{input_bgcolor}
  , -foreground =>$COLOR{input_fgcolor}
  , -scrollbars => 'se' 
  , -wrap => 'word' 
)->form(-top=>[$Notes_frame,8], -left=>['%1',0], -right=>['%99',0], -bottom=>['%98',0]);
my $Notes_tw = $Notes_top_tw->Subwidget("scrolled"); # get real widget
&refer((split /=/, Dumper($Notes_tw))[0],'TextUndo',\$Notes_tw); ## Refer: 45.
$Notes_tw->Contents($Part->{'Notes_tw'}); ## Don't forget to load the content before starting.

## END Notes Tab.

## ### SETUP sub-notebook:
$Tabs{'setup'} = $Book->add("Setup", -label=>"Setup", -state=>'normal', -raisecmd=>\&book_open);
my $Prefbook = $Tabs{'setup'}->NoteBook(
   -backpagecolor => $ColorSet[2]
  ,-focuscolor => $ColorSet[10]
  ,-inactivebackground => $COLOR{'button_bgcolor'}
)->pack(
	-fill=>'both'
	, -side => 'left'  
	, -expand=>1 
);
$Tabs{'paths'} = $Prefbook->add("Paths", -label=>"Paths", -raisecmd=>\&book_open);
my $Paths_frame = $Tabs{'paths'}->Frame(-borderwidth=>4, -relief=>'groove');
$Paths_frame->form(-left=>['%1',0], -right=>['%99',0], -top=>['%1',4]);
my $csg_lw_path_text = "Application: ";
my $csg_lw_path = $Paths_frame->Label( 
	-textvariable=>\$csg_lw_path_text 
)->form(-left=>['%0',0], -top=>['%1',4]);
my $csg_path_pe = $Paths_frame->PathEntry( 
	-textvariable=>\$Part->{'csg_path_pe'}
	,-disabledforeground =>$COLOR{'input_fgcolor'}
	,-state=>'disabled'
)->form(
  -left=>[$csg_lw_path,0]
  ,-right=>['%49',0]
  ,-top=>['%1',4]
);
&refer((split /=/, Dumper($csg_path_pe))[0],'PathEntry',\$csg_path_pe); ## Refer: 46.
my $run_lw_path_text = "Runtime: ";
my $run_lw_path = $Paths_frame->Label( -textvariable=>\$run_lw_path_text )->form(-top=>[$csg_lw_path,0]); 
my $run_path_pe = $Paths_frame->PathEntry( 
	 -textvariable=>\$Part->{'run_path_pe'}
	,-disabledforeground =>$COLOR{'input_fgcolor'}
	,-state=>'disabled'
)->form(
   -left=>[$run_lw_path,0]
  ,-top=>[$csg_lw_path,0]
  ,-right=>['%49',0]
);
&refer((split /=/, Dumper($run_path_pe))[0],'PathEntry',\$run_path_pe); ## Refer: 47.
my $part_lw_path_text = "Parts: ";
my $part_lw_path = $Paths_frame->Label( -textvariable=>\$part_lw_path_text )->form( -left=>['%50',0], -top=>['%1',4]);
my $part_path_pe = $Paths_frame->PathEntry( 
	 -textvariable=>\$Part->{'part_path_pe'}
	,-disabledforeground =>$COLOR{'input_fgcolor'}
	,-state=>'disabled'
)->form(
   -left=>[$part_lw_path,0]
  ,-right=>['%99',0]
  ,-top=>['%1',4]
);
&refer((split /=/, Dumper($part_path_pe))[0],'PathEntry',\$part_path_pe); ## Refer: 48.
my $ins_lw_path_text = "Instruments: ";
my $ins_lw_path = $Paths_frame->Label( -textvariable=>\$ins_lw_path_text )->form(
   -top=>[$part_lw_path,0]
  ,-left=>['%50',0]
);
my $ins_path_pe = $Paths_frame->PathEntry( -textvariable=>\$Part->{'ins_path_pe'}, -background=>$COLOR{input_bgcolor}, -state=>'normal',  )->form(
   -left=>[$ins_lw_path,0]
  ,-top=>[$part_lw_path,0]
  ,-right=>['%99',0]
);
&refer((split /=/, Dumper($ins_path_pe))[0],'PathEntry',\$ins_path_pe); ## Refer: 49.

my $setup_paths_bw = $Paths_frame->Button(
  	-background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Reload'
	,-command=>\sub { &pref_load }
)->form(
  -top=>[$ins_path_pe,4]
  ,-right=>['%99',0]
);

## Setup Csound Frame:
$Tabs{'csound'} = $Prefbook->add("Csound", -label=>"Csound", -raisecmd=>\&book_open);
my $Csound_setup_frame = $Tabs{'csound'}->Frame(-borderwidth=>4, -relief=>'groove');
$Csound_setup_frame->form(-left=>['%1',0], -right=>['%99',0], -top=>['%1',4]);
my $csound_lw_path_text = "Csound path: ";
my $csound_lw_path = $Csound_setup_frame->Label( -textvariable=>\$csound_lw_path_text )->form(-top=>['%1',4],-left=>['%1',0]);
my $csound_path_pe = $Csound_setup_frame->PathEntry( -textvariable=>\$Part->{'csound_path_pe'}, -background=>$COLOR{input_bgcolor}, -state=>'normal',  )->form(
   -left=>[$csound_lw_path,0]
  ,-top=>['%1',4]
  ,-right=>['%75',0]
);
&refer((split /=/, Dumper($csound_path_pe))[0],'PathEntry',\$csound_path_pe); ## Refer: 53. 
my $audio_driver_mbw = $Csound_setup_frame->Menubutton(
	-borderwidth=>1
	,-background => $COLOR{cbox_bgcolor}
	,-foreground => $COLOR{cbox_fgcolor}
	,-relief=>'groove' 
	, -text=>'Audio driver'
);
$audio_driver_mbw->radiobutton(-label => 'ALSA',
  -variable => \$Part->{'audio_driver_mbw'}
  , -label => 'ALSA'
  , -value => 'alsa'
  , -underline => 0
  ,	-command=>\&menu_set_audio
);
$audio_driver_mbw->radiobutton(-label => 'JACK',
  -variable => \$Part->{'audio_driver_mbw'}
  , -label => 'JACK'
  , -value => 'jack'
  , -underline => 0
  ,	-command=>\&menu_set_audio
);
$audio_driver_mbw->radiobutton(-label => 'PortAudio',
  -variable => \$Part->{'audio_driver_mbw'}
  , -label => 'PortAudio'
  , -value => 'portaudio'
  , -underline => 0
  ,	-command=>\&menu_set_audio
);

my $midi_driver_mbw = $Csound_setup_frame->Menubutton(
		-borderwidth=>1
	,-background => $COLOR{cbox_bgcolor}
	,-foreground => $COLOR{cbox_fgcolor}
	,-relief=>'groove' 
	, -text=>'Midi driver'
);
$midi_driver_mbw->radiobutton(-label => 'ALSA',
  -variable => \$Part->{'midi_driver_mbw'}
  , -label => 'ALSA'
  , -value => 'alsa'
  , -underline => 0
  ,	-command=>\&menu_set_midi
);
$midi_driver_mbw->radiobutton(-label => 'PortMidi',
  -variable => \$Part->{'midi_driver_mbw'}
  , -label => 'PortMidi'
  , -value => 'portmidi'
  , -underline => 0
  ,	-command=>\&menu_set_midi
);
$midi_driver_mbw->form(-right=>['%99',0],-top=>['%1',4]);
$audio_driver_mbw->form(-right=>[$midi_driver_mbw,-8],-top=>['%1',4]);

my $csound_sr_le = $Csound_setup_frame->LabEntry(
   -label => 'sr: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'csound_sr_le'}
  ,-width => 6
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'digit') }
);
$csound_sr_le->form(   
   -top=>[$csound_path_pe,4]
  ,-left=>['%1',4]
);

&refer((split /=/, Dumper($csound_sr_le))[0],'LabEntry',\$csound_sr_le);  ## Refer: 54. 

my $csound_ksmps_le = $Csound_setup_frame->LabEntry(
   -label => 'ksm: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'csound_ksmps_le'}
  ,-width => 6
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'digit') }
);
$csound_ksmps_le->form(   
   -top=>[$csound_path_pe,4]
  ,-left=>[$csound_sr_le,4]
);

&refer((split /=/, Dumper($csound_ksmps_le))[0],'LabEntry',\$csound_ksmps_le); ## Refer: 55. 

my $csound_nchnls_le = $Csound_setup_frame->LabEntry(
   -label => 'nch: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'csound_nchnls_le'}
  ,-width => 6
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'digit') }
);
$csound_nchnls_le->form(   
   -top=>[$csound_path_pe,4]
  ,-left=>[$csound_ksmps_le,4]
);

&refer((split /=/, Dumper($csound_nchnls_le))[0],'LabEntry',\$csound_nchnls_le); ## Refer: 56. 

my $csound_sbuffer_le = $Csound_setup_frame->LabEntry(
   -label => 'sbw: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'csound_sbuffer_le'}
  ,-width => 6
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'digit') }
);
$csound_sbuffer_le->form(   
   -top=>[$csound_path_pe,4]
  ,-left=>[$csound_nchnls_le,4]
);

&refer((split /=/, Dumper($csound_sbuffer_le))[0],'LabEntry',\$csound_sbuffer_le); ## Refer: 57. 

my $csound_hbuffer_le = $Csound_setup_frame->LabEntry(
   -label => 'hbw: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'csound_hbuffer_le'}
  ,-width => 6
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'digit') }
);
$csound_hbuffer_le->form(   
   -top=>[$csound_path_pe,4]
  ,-left=>[$csound_sbuffer_le,4]
);

&refer((split /=/, Dumper($csound_hbuffer_le))[0],'LabEntry',\$csound_hbuffer_le); ## Refer: 58. 

my $csound_sample_mbw = $Csound_setup_frame->Menubutton(
	-borderwidth=>1
	,-background => $COLOR{cbox_bgcolor}
	,-foreground => $COLOR{cbox_fgcolor}
	,-relief=>'groove' 
	,-text=>'Smp format'
);
$csound_sample_mbw->radiobutton(-label => 'FLOAT',
  -variable => \$Part->{'csound_sample_mbw'}
  , -label => 'Float'
  , -value => '-f'
  , -underline => 0
  ,	-command=>\sub { &pref_load }
);
$csound_sample_mbw->radiobutton(-label => 'LONG',
  -variable => \$Part->{'csound_sample_mbw'}
  , -label => 'Long'
  , -value => '-l'
  , -underline => 0
  ,	-command=>\sub { &pref_load }
);
$csound_sample_mbw->radiobutton(-label => 'SHORT',
  -variable => \$Part->{'csound_sample_mbw'}
  , -label => 'Short'
  , -value => '-s'
  , -underline => 0
  ,	-command=>\sub { &pref_load }
);
$csound_sample_mbw->form(-left=>[$csound_hbuffer_le,8],-top=>[$csound_path_pe,4]);

my $csound_params_le = $Csound_setup_frame->LabEntry(
   -label => 'outfile params: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'csound_params_le'}
  ,-width => 64
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'text') }
);
$csound_params_le->form(   
   -top=>[$csound_sr_le,4]
  ,-right=>['%75',0]
);

&refer((split /=/, Dumper($csound_params_le))[0],'LabEntry',\$csound_params_le); ## Refer: 59. 

my $realtime_params_le = $Csound_setup_frame->LabEntry(
   -label => 'realtime params: '
  ,-labelPack => ['-side', 'left', '-anchor', 'w' ]
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'normal'
  ,-textvariable =>\$Part->{'realtime_params_le'}
  ,-width => 64
  ,-validate => 'key'
  ,-validatecommand => sub { &valid_entry($_[1],'text') }
);
$realtime_params_le->form(   
   -top=>[$csound_params_le,4]
  ,-right=>['%75',0]
);

&refer((split /=/, Dumper($realtime_params_le))[0],'LabEntry',\$realtime_params_le); ## Refer: 60. 
my $csound_lw_sf2path_text = "Sf2 path: ";
my $csound_lw_sf2path = $Csound_setup_frame->Label( -textvariable=>\$csound_lw_sf2path_text )->form(-top=>[$realtime_params_le,4],-left=>['%1',0]);
my $csound_sf2path_pe = $Csound_setup_frame->PathEntry( -textvariable=>\$Part->{'csound_sf2path_pe'}, -background=>$COLOR{input_bgcolor}, -state=>'normal',  )->form(
   -left=>[$csound_lw_sf2path,0]
  ,-top=>[$realtime_params_le,4]
  ,-right=>['%75',0]
);
&refer((split /=/, Dumper($csound_sf2path_pe))[0],'PathEntry',\$csound_sf2path_pe); ## Refer: 61. 

my $csound_setup_bw = $Csound_setup_frame->Button(
  	-background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Reload'
	,-command=>\sub { &pref_load }
)->form(
   -top=>[$csound_hbuffer_le,4]
  ,-right=>['%99',0]
);


## Setup Internals Tab:
$Tabs{'internals'} = $Prefbook->add("Internals", -label=>"Internals", -raisecmd=>\&book_open);

## Setup Internals Frame:
my $Internals_frame = $Tabs{'internals'}->Frame(-borderwidth=>4, -relief=>'groove');
$Internals_frame->form(-top=>['%1',4], -bottom=>['%98',4], -left=>['%1',0], -right=>['%49',0]);

my $internals_le = $Internals_frame->Label(
   -text => 'Internal settings: '
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-disabledforeground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'disabled'
);
$internals_le->form(   
   -top=>['%1',4]
  ,-left=>['%1',4]
);

my $Instparams_frame = $Tabs{'internals'}->Frame(-borderwidth=>4, -relief=>'groove');
$Instparams_frame->form(-top=>['%1',4], -bottom=>['%98',4], -left=>['%51',0], -right=>['%98',0]);

my $inst_params_le = $Instparams_frame->Label(
   -text => 'Available Instruments Params: '
  ,-background => $COLOR{input_bgcolor}
  ,-foreground => $COLOR{input_fgcolor}
  ,-disabledforeground => $COLOR{input_fgcolor}
  ,-relief => 'ridge'
  ,-state => 'disabled'
);
$inst_params_le->form(   
   -top=>['%1',4]
  ,-left=>['%1',4]
);



## Other Setup Tab:
$Tabs{'other'} = $Prefbook->add("Other", -label=>"Other", -raisecmd=>\&book_open);

## Other Setup Frame:
my $Other_setup_frame = $Tabs{'other'}->Frame(-borderwidth=>4, -relief=>'groove');
$Other_setup_frame->form(-top=>['%1',4], -left=>['%1',0], -right=>['%25',0]);
my $setup_lw_text = "Other preferences: "; 
my $setup_lw = $Other_setup_frame->Label( -textvariable=>\$setup_lw_text )->form(-top=>['%1',8], -left=>['%1',0]);
my $setup_save_bw = $Other_setup_frame->Button(
	-background =>$COLOR{'button_bgcolor'}
	,-foreground =>$COLOR{'button_fgcolor'}
	,-text=>'Save '
	,-command=>\sub { &setup_save }
)->form(
   -top=>['%1',4]
  ,-right=>['%99',0]
);

my $Other_setup_frame2 = $Tabs{'other'}->Frame(-borderwidth=>4, -relief=>'groove');
$Other_setup_frame2->form(-top=>[$Other_setup_frame,4], -left=>['%1',0], -right=>['%99',0]);
my $auto_cb_bkp_var = 0;
my $auto_cb_bkp = $Other_setup_frame2->Checkbutton(
   -text=>'Automated backup '
  ,-variable=>\$auto_cb_bkp_var
  ,-onvalue=>1
  ,-offvalue=>0
)->form(
   -left=>['%1',0]
  ,-top=>['%1',4]
);

my $savenotes_enabled_cb = $Other_setup_frame2->Checkbutton(
  -text=>'Enable Save Notes As.. ' 
  ,-variable=>\$notes_state
  ,-onvalue=>'normal'
  ,-offvalue=>'disabled'
  ,-command=>\sub { $notes_save_bw->configure(-state=>$notes_state) }
)->form(
  -left=>['%1',0]
  ,-top=>[$auto_cb_bkp,4]
);
&refer((split /=/, Dumper($savenotes_enabled_cb))[0],'Cbox',\$savenotes_enabled_cb); ## Refer: 62. 

## END SETUP sub-notebook.

## ### MAN Tab:
$Tabs{'man'} = $Book->add("Man", -label=>"Manual", -raisecmd=>\&book_open);

## Man Frame:
my $Man_frame = $Tabs{'man'}->Frame(
	-borderwidth=>4
	,-relief=>'groove'
);
$Man_frame->form(-top=>['%1',4], -left=>['%1',0], -right=>['%99',0]);

my $Int_man = $Csgrouper::CSG{'csg_path_pe'}."lib/csgrouper.pl";
my $Ins_man = $Csgrouper::CSG{'csg_path_pe'}."lib/Csgrouper/Instrument.pm";
my $Csg_man = $Csgrouper::CSG{'csg_path_pe'}."lib/Csgrouper.pm";
my $Not_man = $Csgrouper::CSG{'csg_path_pe'}."lib/Csgrouper/Note.pm";
my $Seq_man = $Csgrouper::CSG{'csg_path_pe'}."lib/Csgrouper/Sequence.pm";
my $Ser_man = $Csgrouper::CSG{'csg_path_pe'}."lib/Csgrouper/Series.pm";
my $Typ_man = $Csgrouper::CSG{'csg_path_pe'}."lib/Csgrouper/Types.pm";
my $Int_nam = "csgrouper.pl";
my $Ins_nam = "Instrument.pm";
my $Csg_nam = "Csgrouper.pm";
my $Not_nam = "Note.pm";
my $Seq_nam = "Sequence.pm";
my $Ser_nam = "Series.pm";
my $Typ_nam = "Types.pm";

## ### Special real scrolled syntax..
my $Man_top_tw = $Tabs{'man'}->Scrolled (
  'PodText'
  ,-background=>$COLOR{input_bgcolor} # TK bug? Can't get these colors to be displayed..
  ,-foreground =>$COLOR{input_fgcolor}
	,'Name' => 'mantab' ## This name will be used to override the previous bug.
  ,-file=> $Int_man
  ,-scrollbars => "se",
  ,-wrap => 'word' 
)->form(-top=>[$Man_frame,8], -left=>['%1',0], -right=>['%99',0], -bottom=>['%98',0]);
# my $Man_tw = $Man_top_tw->Subwidget("scrolled"); # get real widget # unuseful here.


my ($manvar,$tmanvar);
my $man_select_omw = $Man_frame->Optionmenu(
	-borderwidth=>1
	,-background => $COLOR{cbox_bgcolor}
	,-foreground => $COLOR{cbox_fgcolor}
	,-relief=>'groove' 
  , -options => [
  	 [ $Int_nam => $Int_man ]
  	,[ $Csg_nam => $Csg_man ]
  	,[ $Ins_nam => $Ins_man ]
  	,[ $Not_nam => $Not_man ]
  	,[ $Seq_nam => $Seq_man ]
  	,[ $Ser_nam => $Ser_man ]
  	,[ $Typ_nam => $Typ_man ]
   ]
  ,-variable     => \$manvar
  ,-textvariable => \$tmanvar
  ,-command      => sub { $Man_top_tw->configure(-file=>$manvar);  } 
)->form(-left=>['%1',0],-top=>['%1',2]);

## END MAN Tab.

## ### LOG Tab:
$Tabs{'log'} = $Book->add("Log", -label=>"Log", -raisecmd=>\&book_open);

## ManLogFrame:
my $Log_frame = $Tabs{'log'}->Frame(
	-borderwidth=>4
	,-relief=>'groove'
);
$Log_frame->form(-top=>['%1',4], -left=>['%1',0], -right=>['%99',0]);

## ### Special real scrolled syntax..
my $Output_top_tw = $Tabs{'log'}->Scrolled (
  'TextUndo'
  , -background=>$COLOR{input_bgcolor}
  , -foreground =>$COLOR{input_fgcolor}
  , -scrollbars => 'se' 
  , -wrap => 'word' 
)->form(-top=>[$Log_frame,8], -left=>['%1',0], -right=>['%99',0], -bottom=>['%98',0]);
my $Output_tw = $Output_top_tw->Subwidget("scrolled"); # get real widget
## Don't enable log saving.
## END LOG Tab.
## END NOTEBOOK WIDGET.

## XXX WARNING: Some necessary bindings to impede insertion of unwanted hex char:
## for ctl-3,4,5,6,7,g,l,m,r,s,u.

$Ftb_tw->bind('<Control-3>', sub { $_[0]->break }); ## This one doesn't work: insertion remains.
$Ftb_tw->bind('<Control-4>', sub { $_[0]->break }); ## Neither..
$Ftb_tw->bind('<Control-5>', sub { $_[0]->break }); ## Neither: another bug?.
$Ftb_tw->bind('<Control-6>', sub { $_[0]->break });
$Ftb_tw->bind('<Control-7>', sub { $_[0]->break });
$Ftb_tw->bind('<Control-g>', sub { $_[0]->break });
$Ftb_tw->bind('<Control-l>', sub { $_[0]->break });
$Ftb_tw->bind('<Control-m>', sub { $_[0]->break });
$Ftb_tw->bind('<Control-r>', sub { $_[0]->break });
$Ftb_tw->bind('<Control-s>', sub { &menu_save; $_[0]->break });
$Ftb_tw->bind('<Control-u>', sub { $_[0]->break });

$Notes_tw->bind('<Control-3>', sub { $_[0]->break });
$Notes_tw->bind('<Control-4>', sub { $_[0]->break });
$Notes_tw->bind('<Control-5>', sub { $_[0]->break }); 
$Notes_tw->bind('<Control-6>', sub { $_[0]->break });
$Notes_tw->bind('<Control-7>', sub { $_[0]->break });
$Notes_tw->bind('<Control-g>', sub { $_[0]->break });
$Notes_tw->bind('<Control-l>', sub { $_[0]->break });
$Notes_tw->bind('<Control-m>', sub { $_[0]->break });
$Notes_tw->bind('<Control-r>', sub { $_[0]->break });
$Notes_tw->bind('<Control-s>', sub { &menu_save; $_[0]->break });
$Notes_tw->bind('<Control-u>', sub { $_[0]->break });

$Orcini_tw->bind('<Control-3>', sub { $_[0]->break }); 
$Orcini_tw->bind('<Control-4>', sub { $_[0]->break }); 
$Orcini_tw->bind('<Control-5>', sub { $_[0]->break }); 
$Orcini_tw->bind('<Control-6>', sub { $_[0]->break });
$Orcini_tw->bind('<Control-7>', sub { $_[0]->break });
$Orcini_tw->bind('<Control-g>', sub { $_[0]->break });
$Orcini_tw->bind('<Control-l>', sub { $_[0]->break });
$Orcini_tw->bind('<Control-m>', sub { $_[0]->break });
$Orcini_tw->bind('<Control-r>', sub { $_[0]->break });
$Orcini_tw->bind('<Control-s>', sub { &menu_save; $_[0]->break });
$Orcini_tw->bind('<Control-u>', sub { $_[0]->break });

$Output_tw->bind('<Control-3>', sub { $_[0]->break }); 
$Output_tw->bind('<Control-4>', sub { $_[0]->break });
$Output_tw->bind('<Control-5>', sub { $_[0]->break }); 
$Output_tw->bind('<Control-6>', sub { $_[0]->break });
$Output_tw->bind('<Control-7>', sub { $_[0]->break });
$Output_tw->bind('<Control-g>', sub { $_[0]->break });
$Output_tw->bind('<Control-l>', sub { $_[0]->break });
$Output_tw->bind('<Control-m>', sub { $_[0]->break });
$Output_tw->bind('<Control-r>', sub { $_[0]->break });
$Output_tw->bind('<Control-s>', sub { &menu_save; $_[0]->break });
$Output_tw->bind('<Control-u>', sub { $_[0]->break });

$Score_tw->bind('<Control-3>', sub { $_[0]->break });
$Score_tw->bind('<Control-4>', sub { $_[0]->break });
$Score_tw->bind('<Control-5>', sub { $_[0]->break }); 
$Score_tw->bind('<Control-6>', sub { $_[0]->break });
$Score_tw->bind('<Control-7>', sub { $_[0]->break });
$Score_tw->bind('<Control-g>', sub { $_[0]->break });
$Score_tw->bind('<Control-l>', sub { $_[0]->break });
$Score_tw->bind('<Control-m>', sub { $_[0]->break });
$Score_tw->bind('<Control-r>', sub { $_[0]->break });
$Score_tw->bind('<Control-s>', sub { &menu_save; $_[0]->break });
$Score_tw->bind('<Control-u>', sub { $_[0]->break });

## Original bindings for this field were: 
## $Notes_tw->bind('<Control-3>', sub { $_[0]->break }); 
## Tk::TextUndo .notebook.notes.frame1.textundo . all
## New order gives (0 and 1 permuted):
## .notebook.notes.frame1.textundo Tk::TextUndo . all
$Ftb_tw->bindtags([($Ftb_tw->bindtags)[1,0,2,3]]);
# $Man_tw->bindtags([($Man_tw->bindtags)[1,0,2,3]]);
$Notes_tw->bindtags([($Notes_tw->bindtags)[1,0,2,3]]);
$Orcini_tw->bindtags([($Orcini_tw->bindtags)[1,0,2,3]]);
$Output_tw->bindtags([($Output_tw->bindtags)[1,0,2,3]]);
$Score_tw->bindtags([($Score_tw->bindtags)[1,0,2,3]]);

## Main window bindings:
$mw->bind($mw, "<Control-a>" => \&menu_sall);
$mw->bind($mw, "<Control-k>" => \&cline);
$mw->bind($mw, "<Control-n>" => \&menu_new);
$mw->bind($mw, "<Control-s>" => \&menu_save);
$mw->bind($mw, "<Control-q>" => \&menu_quit);
$mw->bind($mw, "<Control-v>" => \&menu_paste);
$mw->bind($mw, "<Control-x>" => \&menu_cut);
$mw->bind($mw, "<Control-z>" => \&menu_clear);


## XXX WARNING: Don't forget to unload Data::Dumper::Simple:

no Data::Dumper::Simple; 

## Otherwise every other variable shall be treated by 
## the module (and it would take lots of time and memory...).

## ### Packing: NEVER DO:
## $Tabs{'sometab'}->pack(-expand=>1); ## Packing tabs is messing the pack computation!

## END TK DESIGN.

###############################################################################
## ### MAIN LOOP:
###############################################################################

=head2 Main loop
=cut

&Resetall('init'); ## In order to load default values, now that $Part exists.
&reload(); ## In order to load remaining prefs, now that widgets exist.
&aoa_out(\@Csgrouper::Internals, \$Internals_frame, \$internals_le, 2, "Internal Params:");
&aoa_out(\@Csgrouper::Paramar, \$Instparams_frame, \$inst_params_le, 2, "Available Instruments Params:");
&Csgrouper::says($subname, "loaded part '".$Part->{'csg_part'}."'",1);
&Csgrouper::says($subname, "started");
$STARTEXEC = 0; ## Launch time finished.
# $DEBSUB = $subname;
# &Csgrouper::Debug($subname,Dumper($Part)); 
$mw->title('Csgrouper: '.$Part->{'part_title_le'});
MainLoop; 
### END MAIN LOOP.

###############################################################################
## ### TK AND SYSTEM SUBS:
###############################################################################

=head2 Tk and system subroutines

=over

=item * anacom() : calls an evaluation of the global Tk variable '$cmd_line'.
=cut

sub anacom {
  my $subname = "anacom";
  { no warnings; &Csgrouper::says($subname, $cmd_line, 1); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my @rslt; 
  if ($cmd_line =~ /^(\~.+)/){
  	my $content = $cmd_line; $content =~ s/^\~//;
		@rslt = eval($content);
		my $exit_value = $? >> 8;
		my $signal_num = $? & 127;
		my $dumped_core = $? & 128;
		print "\ncsg-cline\> ouput: \n @rslt" if (scalar (@rslt) > 0);
		print "\ncsg-cline\> \$\!: $!" if ($! =~ /.+/);
		print "\ncsg-cline\> \$\@: $@"  if ($@ =~ /.+/);
		print "\ncsg-cline\> \$signal_num: $signal_num" if ($signal_num != 0);
		print "\ncsg-cline\> \$exit_value: $exit_value"  if ($exit_value != 0);
		print "\ncsg-cline\> \$dumped_core: $dumped_core"  if ($dumped_core != 0);
		print "\ncsg-cline\> done.";
	}
	else {
		@rslt = &csg_Sets::Cmd_line($cmd_line);
  }
  &aoa_out(\@rslt, \$Series_ana_frame, \$ana_cmd_le, '0', $cmd_line);
  $Csgrouper::DEBFLAG =  $oldebflag;
  return 1;
}

=item * anado() : calls computing of Sequence 0.
=cut

sub anado { 
  my $subname = "anado";
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  &Csgrouper::says($subname, $tanavar, 1);
  my $arref ;
  ## Create the object here anyway...
  &seq_test();
  ## The tree should be built:
  if ($CsgObj->sequences->{'Seq_0'}->ready == 1){
  	## Anasend will select and return the appropriate values in Sequence object.
  	$arref = $CsgObj->sequences->{'Seq_0'}->aoa;
  }
  else {
  	&Csgrouper::Error($subname,"Object not ready!",0);
  	&Csgrouper::says($subname,"Object not ready!");
  	return 0;
  }
  &aoa_out($arref, \$Series_ana_frame, \$ana_cmd_le, '0');
  $Csgrouper::DEBFLAG =  $oldebflag;
  return 1;
} ## END anado().

=item * aoa_out($rslt_ref, $frame_ref, $upobj_ref, $mode, $title) : formats data in $rslt_ref for table printout.
=cut

sub aoa_out {
  my ($rslt_ref, $frame_ref, $upobj_ref, $mode, $title) = @_;
  my $subname = 'aoa_out';
  # { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  $mode = 0 if ($mode !~ /.+/);
  my $tf = 'on';
  my $state = 'normal';
  my $bg = $COLOR{table_bgcolor};
  my $fg = $COLOR{table_fgcolor};
  my $bg2 = $COLOR{table_bgcolor};
  my $fg2 = $COLOR{table_fgcolor};
  if ($mode == 2) {
		$tf = 'off'; $state = 'disabled';
		$bg = $COLOR{'label_bgcolor'};	
		$bg2 = $COLOR{'output_bgcolor'};	
  }
  my $out_table = $$frame_ref->Table(
	   -fixedrows => 1
	  ,-scrollbars => 'se'
	  ,-relief => 'raised'
	  ,-takefocus =>\$tf
  );
  $out_table->form(-top=>[$$upobj_ref,4], -left=>['%1',0], -right=>['%99',0], -bottom=>['%99',0]);
  my $row = 1; 
  my $in; 
  if (defined $title) { $in = "\n$title" }
  foreach (@{$rslt_ref}) {
		my $item = $_;
		if ($item =~ /ARRAY\(/){ ## $item is an arref...
			my @cols = @$item;
			my $col = 0;
			my $tmp_label = $out_table->Label(-text => '', -relief =>'groove', -justify => 'left');
			$out_table->put($row, 0, $tmp_label);
			$in .= "\n";
			foreach (@cols) {
				my $column = $_; $col++;
				$tmp_label = $out_table->Label(-text =>$row, -relief =>'groove', -justify => 'left');
				$out_table->put($row, 0, $tmp_label);
				$tmp_label = $out_table->Label(-text => "C $col", -relief =>'groove', -justify => 'left');
				$out_table->put(0, $col, $tmp_label);
				$in .= "$column\t";
				my $bgd = $bg2; $bgd = $bg if ($row == 1);
				my $fgd = $fg2; $fgd = $fg if ($row == 1);
				$tmp_label = $out_table->Text(-background => $bgd, -foreground => $fgd, -height=>1, -width => length($column));
				$out_table->put($row, $col, $tmp_label);
				$out_table->get($row, $col)->Contents($column); 
				$out_table->get($row, $col)->configure(-state=>$state); 
			} ## END foreach cols;
			$row++;
		} 
		else { ## $item is an arval...
			my $tmp_label = $out_table->Text(-background => $bg, -foreground => $fg, -height =>1, -width => length($item));
			$out_table->put($row, 0, $row);
			$out_table->put($row, 1, $tmp_label);
			$out_table->get($row, 1)->Contents($item); 
			$out_table->get($row, 0)->configure(-state=>$state); 
			$out_table->get($row, 1)->configure(-state=>$state); 
			$in .= "\n$item";
			$row++;
		}
  } ## END foreach rslt;
  &Log($in);
  $Csgrouper::DEBFLAG =  $oldebflag;
  return 1;
} ## END aoa_out().
  
=item * book_open() : raises a Notebook page.
=cut

sub book_open {
  my $subname = 'book_open';
  ## { no warnings; &Csgrouper::says($subname, "@_"); } ## Uncomment to debug.
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $page = $Book->raised() // "";
  if ($page !~/^(Setup)$/) {
  	$Book->pageconfigure("Setup", -state=> 'normal'); # will be 'disabled' by default..
  }
  $Csgrouper::DEBFLAG =  $oldebflag;
  return 1;
} ## END book_open().

=item * check_wdir() : checks existence of a directory.
=cut

sub check_wdir {
  my ($dir) = @_;
  my $subname = 'check_wdir';
  ## { no warnings; &Csgrouper::says($subname, "@_"); } ## Uncomment to debug.
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $test = system("touch","$dir/csg.touch");
  system("rm","$dir/csg.touch");
  $Csgrouper::DEBFLAG =  $oldebflag;
  return $test; ## Here true and false are sort of inversed since the system "achieved" value is 0 (false for Perl).
} ## END check_wdir().

=item * check_wfile() : checks existence of a file.
=cut

sub check_wfile {
  my ($file) = @_;
  my $subname = 'check_wfile';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $test = system("echo '' >> $file");
  return $test; ## Here true and false are sort of inversed since the system "achieved" value is 0 (false for Perl).
} ## END check_wfile().

=item * check_csgfile() : checks existence and content of a file.
=cut

sub check_csgfile {
  my ($file) = @_;
  my $subname = 'check_csgfile';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $res = 0; ## In Perl 0 and empty strings are FALSE, everything else is TRUE.
  open (FH, "< $file") or  die "Can't r-open $file: $!";
	while (<FH>) { if ($_ =~ /\<csg_key\>/) { $res = 1; last } }
  close FH;
  $Csgrouper::DEBFLAG =  $oldebflag;
  return $res;
} ## END check_csgfile().

=item * cline() : evaluates a Tk widget command line for STDOUT.
=cut

sub cline { 
  my $subname = 'cline';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $d = $mw->DialogBox(-title => "csg c-line", -buttons => ["OK", "Cancel"]);
  my $w = $d->add('TextUndo', -state=>'normal', -background=>$COLOR{input_bgcolor}, -height=>'1')->pack;
  $w->Contents($Csgrouper::CSG{cline});
  my $button = $d->Show;
  my $content = $w->Contents(); chomp($content); chomp($content); ## In case we typed return for ok..
  if ($button =~ /OK/) { 
	&Csgrouper::says($subname, "\ncsg-cline\> $content :");
	$Csgrouper::CSG{cline} = $content;
	my @rslt = eval($content);
	my $exit_value = $? >> 8;
	my $signal_num = $? & 127;
	my $dumped_core = $? & 128;
	print "\ncsg-cline\> ouput: \n @rslt" if (scalar (@rslt) > 0);
	print "\ncsg-cline\> \$\!: $!" if ($! =~ /.+/);
	print "\ncsg-cline\> \$\@: $@"  if ($@ =~ /.+/);
	print "\ncsg-cline\> \$signal_num: $signal_num" if ($signal_num != 0);
	print "\ncsg-cline\> \$exit_value: $exit_value"  if ($exit_value != 0);
	print "\ncsg-cline\> \$dumped_core: $dumped_core"  if ($dumped_core != 0);
	print "\ncsg-cline\> done.";
	#$mw->messageBox(-message => "output: @rslt");
  }
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END cline().

=item * csd_empty() : deletes the score content.
=cut

sub csd_empty {
  my $subname = "csd_empty";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 0;
  $Score_tw->Contents("");  
  return 1;
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END csd_empty().


=item * csd_play() : plays csound file.
=cut

sub csd_play {
  my $subname = "csd_play";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 0;
  my $txt = $Score_tw->Contents();
	die "No valid csd file to play: $!" if ($txt !~ /\<CsoundSynthesizer\>/);
  my $file = &Csgrouper::Datem('n'); $file = "csg.$file.csd";
  my $newfile = $Part->{'bkp_path_pe'}."/".$file;
  &Csgrouper::says($subname, $newfile);
	open (FH, "> $newfile") or  die "Can't w-open $newfile: $!";
	  print FH $txt;
	close FH;
	&Csgrouper::says($subname,"Csd file saved as $newfile.");
	my $pid=fork();
	die "Cannot fork: $!" if (! defined $pid);
	if (! $pid) {
		my $opts = $Part->{'realtime_params_le'};
		exec("/usr/bin/xterm", "-e", $Part->{'csound_path_pe'}." $opts $newfile");
		&Csgrouper::Describe($subname,"still a little problem here.. $!"); 
		return 1;
	}
	&Csgrouper::says($subname,"done");
  return 0;
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END csd_play().


=item * csd_render() : record csound file and score.
=cut

sub csd_render {
  my $subname = "csd_render";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 0;
  my $txt = $Score_tw->Contents();
	die "No valid csd file to play: $!" if ($txt !~ /\<CsoundSynthesizer\>/);
  my $file = &Csgrouper::Datem('n'); $file = "csg.$file";
  my $newfile = $Part->{'render_path_pe'}.'/'.$file.".csd";
  my $outfile = $Part->{'render_path_pe'}.'/'.$file.".wav";
  &Csgrouper::says($subname, $newfile);
	open (FH, "> $newfile") or  die "Can't w-open $newfile: $!";
	  print FH $txt;
	close FH;
	&Csgrouper::says($subname,"Csd file saved as $newfile.");
	my $pid=fork();
	die "Cannot fork: $!" if (! defined $pid);
	if (! $pid) {
		my $opts = $Part->{'outfile_params_le'}." -o $outfile"; ## -o = outfile path
		exec("/usr/bin/xterm", "-e", $Part->{'csound_path_pe'}." $opts $newfile");
		&Csgrouper::Describe($subname,"still a little problem here.. $!"); 
		return 1;
	}
	&Csgrouper::says($subname,"done");
  return 0;
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END csd_render().


=item * csd_sas() : saves a csd output as external file.
=cut

sub csd_sas {
  my $subname = "csd_sas";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 0;
  my $txt = $Score_tw->Contents();
  my $file = &Csgrouper::Datem('n'); $file = "csg.$file.csd";
  my $newfile = $mw->getSaveFile(-title => "Save csd file as:", -initialdir => $Part->{'run_path_pe'}."/bkp", -initialfile => $file);
  &Csgrouper::says($subname, $newfile);
  if ($newfile =~ /.+/) {
	open (FH, "> $newfile") or  die "Can't w-open $newfile: $!";
	  print FH $txt;
	close FH;
	&Csgrouper::says($subname,"Csd file saved as $newfile.");
  }
  else { &Csgrouper::says($subname,"Saving aborted.") }
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END csd_sas().

=item * csd_write($self) : write main csd file.
=cut

sub csd_write {
  my $subname = "csd_write";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  if ($CsgObj->ready != 1){
    &Csgrouper::Describe($subname, "CSD not ready : could not write CSD part");
    return;
  }
  ## Which sequences to print:
  my @comseqs = split /$Csgrouper::SETSEP/,$Part->{'part_select_le'};
  if ($Part->{'part_selprnt_le'} == 1) {
  	&Csgrouper::Describe($subname,"Commented out sequences ids: @comseqs");
  }
	## Information gathered by struct_ctl (see below).
  my $csd = "; ".$Part->{'part_title_le'}."; ".$Part->{'part_author_le'}.", ";
  $csd .= &Csgrouper::Datem().".\n\n";
  $csd .= "\n; Csgrouper params:\n\n";
  $csd .= "; intersil:\t".$Part->{'part_intersil_le'}."\n";
  $csd .= "; steps:\t".$Part->{'part_steps_le'}."\n";
  $csd .= "; cmp. type:\t".$Part->{'part_comptype_mw'}."\n";
  $csd .= "; dur. type:\t".$Part->{'part_durtype_mw'}." (0 = scmp1, 1=rand)\n";
  $csd .= "\n<CsoundSynthesizer>\n";
  $csd .= "\n<CsInstruments>\n";
  $csd .= "\n; Csound params:\n\n";
  $csd .= "sr=".$Part->{'csound_sr_le'}."\n";
  $csd .= "ksmps=".$Part->{'csound_ksmps_le'}."\n";
  $csd .= "nchnls=".$Part->{'csound_nchnls_le'}."\n";
  $csd .= "\n; Global init:\n\n";
  $csd .= $Orcini_tw->Contents()."\n";
  $csd .= "\n; Instruments:\n\n";
  my (@len, $n);
  for ($n = 1; $n <= MAXOBJ; $n++){ push @len, $n if (exists $CsgObj->instruments->{"I".$n}) } 
  foreach (@len){
		$n = $_;
		my $pref = "i$n"; 
		$csd .= "; $pref (path: ".$CsgObj->instruments->{$pref.'_path'}.")\n";
		my $comment = $CsgObj->instruments->{$pref.'_comment'}; $comment =~ s/\n//g;
		$csd .= "; note: $comment\n\n";
		$csd .= $CsgObj->instruments->{$pref.'_content'}."\n";
 		$csd .= "\n";
  }
  $csd .= "\n</CsInstruments>\n";
  $csd .= "\n<CsScore>\n";
  $csd .= "\n; F-tables:\n\n";
  $csd .= $Ftb_tw->Contents()."\n";
  $csd .= "\n; Score:\n\n";
  ## Now treat each section as an independant part:
  # for (my $g = 0; $g < $SectionsH{'size'}; $g++) {
  for (my $g = 0; $g < $CsgObj->sections->{size}; $g++) {
		## A. Clear Csdata and sequences.
		## B. Track and Sequence Info.
		my %sequence; # Where we store information about sequence state.
		## next if (not defined @{$TracksH{$g}});
		next if (not defined @{$CsgObj->tracks->{$g}});
		## my $len = scalar(@{$TracksH{$g}});
		my $len = scalar(@{$CsgObj->tracks->{$g}});
		my $maxdur = 0; 
		$csd .= "s ; Section $g.\n";
		$csd .= "\n; Tempo:\n\n";
		$csd .= $Part->{'part_tempo_le'}."\n";
		for (my $n = 0; $n < $len; $n++) {
			## my $str =  ${$TracksH{$g}}[$n]; 
			my $str =  ${$CsgObj->tracks->{$g}}[$n]; 
			$str =~ s/__/_/gi; $str =~ s/^(_)(.+)(_)$/$2/;
			my @seqs = split /_/,$str;
			## ${$TracksH{$g}}[$n] = $str.'_'; ## For a later compatibility.
			${$CsgObj->tracks->{$g}}[$n] = $str.'_'; ## For a later compatibility.
			&Csgrouper::Debug($subname,"Section=$g track=$n/$len seqs=@seqs");
			## Now record these tracks without any concern for time precedence:
			## The container sequences will be set to the track ids in order to 
			## be able to recover intelligence of what had been done when later reading a 
			## previous csd part whose sequence order could have been modified in the meantime.
			foreach (@seqs) {
				my $tid = $_; my $seqdur = 0;
				my $sid = $CsgObj->sequences->{"Tkrow_$tid\_id"};
				## Replace this by the object equivalent:
				my $spref = "Seq_".$CsgObj->sequences->{"Tkrow_$tid\_id"};
				my $opt = "r"; ## Record.
				$sequence{$spref} //= "";
				next if ($sequence{$spref} =~ /seen/); ## A seq can't be recorded twice in the same section.
				&Csgrouper::Debug($subname,"spref=$spref opt=$opt tid=$tid");
				$csd .= "\n; $spref comments: ".$CsgObj->sequences->{$spref}->com."\n";
				my $instr = $CsgObj->sequences->{$spref}->instr; ## Instr. id.
				my $parnum = $CsgObj->instruments->{$instr.'_parnum'}; ## Number of p-values.
				my $header = ";ins\tsta\tdur\t";
				for (my $p = 4; $p <= $parnum+2; $p++){
					$header .= $CsgObj->instruments->{"$instr\_p$p\_fun"}."\t";
				}
				my $first = 1; my $last = $CsgObj->sequences->{$spref}->tree->size - 1;
				for (my $i = 0; $i <= $last; $i++){
					my $ref = $CsgObj->sequences->{$spref}->tree->notes->{$i};
					my $line; $line = "$header\n" if ($first == 1);
					for (my $p = 1; $p <= $parnum+2; $p++){
						my $val = $ref->csph->{$p};
						if ($first == 1) { $val =~ s/^(.+)([.]{1})$/$1/ } 
						else { $val =~ s/^(.*)(\.{1})$/$2/ }
						$line .= $val."\t";
					}
					if ($Part->{'part_selprnt_le'} == 1) {
						if ($sid ~~ @comseqs){ ## Not selected for printing. 
							$line = ";$line" ;
							$line =~ s/\n/\n;/g if ($first == 1);
						}
					}	
					$first = 0;
					$csd .= $line.";Sec:$g:$spref:$i\t:".$ref->indi.":".$ref->val.":".$ref->voc."\try:".$ref->ryc.":en:".$ref->ens."\n";
					&Csgrouper::Debug($subname,"line $i = $line");
				}
				$seqdur = $CsgObj->sequences->{$spref}->tree->notes->{$last}->csph->{2} + $CsgObj->sequences->{$spref}->tree->notes->{$last}->csph->{3};
				$maxdur = $seqdur if ($seqdur > $maxdur);
				$sequence{$spref} = 'seen'; # 
			} ## end foreach @seqs
		} ## end for Tracks
		## C. Effects for this section:
		$csd .= "\n; FX for Section $g.\n\n";
		for (my $i = $Csgrouper::Types::MAXOBJ; $i > 1; $i--) {
			next unless defined $CsgObj->instruments->{"I$i"};
			my $ins = "i$i"; 
			next unless $CsgObj->instruments->{"$ins\_type"} =~ /fx/i;
			my $line = "$ins\t0\t$maxdur\t";
			my $parnum = $CsgObj->instruments->{$ins.'_parnum'}; 
			&Csgrouper::Describe($subname,"writing score for instrument $ins parnum=$parnum");
			## Get contents:
			## I don't know why totalcolumns returns real number of cols + 1...
			## cell 1 = p3 = dur...
			for (my $p = 2; $p < $CsgObj->instruments->{'-'.$ins.'_table'}->totalColumns; $p++){ 
				&Csgrouper::Debug($subname, "i=$ins col=$p");
				my $fun = $CsgObj->instruments->{'-'.$ins.'_table'}->get(1, $p)->Contents(); 
				my $def = $CsgObj->instruments->{'-'.$ins.'_table'}->get(2, $p)->Contents(); 
				$def =~ s/\n*//g; $fun =~ s/\n*//g; ## A Tk bug.
				$line .= "$def\t";
			} 
			if ($Part->{'part_selprnt_le'} == 1) {
					$line = ";$line" if ($ins ~~ @comseqs); ## Not selected for printing. 
			}
			$csd .= $line.";\n";
		}
		## D. Write Section END.
		$csd .= "\n; End of Section $g.\n\n";
  } ## end for Sections
  $csd .= "e; END\n";
  $csd .= "\n</CsScore>\n";
  $csd .= "\n</CsoundSynthesizer>\n";
  $csd .= "\n; Notes:\n\n";
  $csd .= $Notes_tw->Contents()."\n";
  $csd .= "\nEOF";
  $Csgrouper::DEBFLAG =  $oldebflag;
  $Score_tw->Contents($csd);
  return 1;
} ## END csd_write().

=item * fun_menu() : creates the main functions menu.
=cut

sub fun_menu {
	my ($mode) = @_; ## 'cascade', $_->[0]
	my @menu;
	if ($mode eq 'ana'){
		@menu =   
		  ([ $Csgrouper::Types::Funx{'Dynana'}{'menutext'} => 'Dynana' ]
		 ,[ $Csgrouper::Types::Funx{'Inana'}{'menutext'} => 'Inana' ]
		 ,[ $Csgrouper::Types::Funx{'Randcond'}{'menutext'} => 'Randcond' ] 
		 ,[ $Csgrouper::Types::Funx{'Smetana'}{'menutext'} => 'Smetana' ] 
		 ,[''],)
	}  
	push @menu,
		([ $Csgrouper::Types::Funx{'Suite'}{'menutext'} => 'Suite' ]
		,[ $Csgrouper::Types::Funx{'Revert'}{'menutext'} => 'Revert' ]
		,[ $Csgrouper::Types::Funx{'Invert'}{'menutext'} => 'Invert' ]
		,[ $Csgrouper::Types::Funx{'Oppose'}{'menutext'} => 'Oppose' ]
		,['']
		,[ $Csgrouper::Types::Funx{'random'}{'menutext'} => 'random' ]
		,[ $Csgrouper::Types::Funx{'Transpose'}{'menutext'} => 'Transpose' ]
		,[ $Csgrouper::Types::Funx{'Powerp'}{'menutext'} => 'Powerp' ]
		,[ $Csgrouper::Types::Funx{'Map'}{'menutext'} =>'Map' ]
		,[ $Csgrouper::Types::Funx{'Unmap'}{'menutext'} => 'Unmap' ]
		,[ $Csgrouper::Types::Funx{'Omap'}{'menutext'} => 'Omap' ]
		,['']
		,[ $Csgrouper::Types::Funx{'Gradual'}{'menutext'} => 'Gradual' ]
		,[ $Csgrouper::Types::Funx{'Oppgrad'}{'menutext'} => 'Oppgrad' ]
		,[ $Csgrouper::Types::Funx{'Gradomap'}{'menutext'} => 'Gradomap' ]
		,[ $Csgrouper::Types::Funx{'Supergrad'}{'menutext'} => 'Supergrad' ]
		,['']
		,[ $Csgrouper::Types::Funx{'Train'}{'menutext'} => 'Train' ]
		,[ $Csgrouper::Types::Funx{'Trainspose'}{'menutext'} => 'Trainspose' ]
		,[ $Csgrouper::Types::Funx{'Intrain'}{'menutext'} => 'Intrain' ]
		,[ $Csgrouper::Types::Funx{'Dynatrain'}{'menutext'} => 'Dynatrain' ]
		,[ '' ]
		,[$Csgrouper::Types::Funx{'arg_types'}{'menucom1'} => 'menucom1' ] 
		,[$Csgrouper::Types::Funx{'arg_types'}{'menucom2'} => 'menucom2' ]
	);
	return([@menu]);	
}	 ## END fun_menu().

=item * ins_def() : gets standard ins 1 and MAXOBJ as well as ftb 1 and global garvbsig into Orchestra tabs.
=cut

sub ins_def { 
  my $subname = 'ins_def';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $pref = "i1";
  $CsgObj->instruments->{$pref.'_author'} = "csound";
  $CsgObj->instruments->{$pref.'_name'} = "Simple Sine";
  $CsgObj->instruments->{$pref.'_comment'} = "A basic instrument.";
  $CsgObj->instruments->{$pref.'_id'} = 1;
  $CsgObj->instruments->{$pref.'_type'} = "sine";
  $CsgObj->instruments->{$pref.'_path'} = "internal";
  $CsgObj->instruments->{$pref.'_content'} = 
  "\n idur = p3;\n".
  "iamp = p4;\n".
  "ifq1 = p5;\n".
  "ift1 = p6;\n".
  "irvn = p7;\n".
  "irvs = p8;\n".
  "a1  oscil ampdb(iamp), ifq1, ift1 ;\n".
  "garvbsig = garvbsig+(a1*irvs);\n".
  "outs a1,a1 ;\n".
	"endin ;\n";
  $CsgObj->instruments->{$pref.'_p3_fun'} = "dur";
  $CsgObj->instruments->{$pref.'_p3_def'} = "1";
  $CsgObj->instruments->{$pref.'_p4_fun'} = "amp";
  $CsgObj->instruments->{$pref.'_p4_def'} = "60";
  $CsgObj->instruments->{$pref.'_p5_fun'} = "fq1";
  $CsgObj->instruments->{$pref.'_p5_def'} = "440";
  $CsgObj->instruments->{$pref.'_p6_fun'} = "ft1";
  $CsgObj->instruments->{$pref.'_p6_def'} = "10";
  $CsgObj->instruments->{$pref.'_p7_fun'} = "rvn";
  $CsgObj->instruments->{$pref.'_p7_def'} = "1";
  $CsgObj->instruments->{$pref.'_p8_fun'} = "rvs";
  $CsgObj->instruments->{$pref.'_p8_def'} = "0.2";

  ## Now create or refresh the corresponding tab (-$pref = not XML storable).
  if (exists $CsgObj->instruments->{"I1"}) { $Orcbook->delete($pref) }
  $CsgObj->instruments->{'-'.$pref.'_tab'} = $Orcbook->add($pref, -label=>$pref, -raisecmd=>\&book_open);

  $CsgObj->instruments->{"I1"} = &Csgrouper::Datem();

  ## File name, Title, Desc, Comments text flds
  $CsgObj->instruments->{'-'.$pref.'_frame'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Frame(-borderwidth=>4, -relief=>'groove');
  $CsgObj->instruments->{'-'.$pref.'_frame'}->form(-left=>['%1',0], -right=>['%99',0], -top=>['%1',4]);
  $CsgObj->instruments->{'-'.$pref.'_path_label'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Label( -textvariable=>\'File path: ' )->form(-top=>['%1',4],-left=>['%1',0]);
  $CsgObj->instruments->{'-'.$pref.'_path_entry'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->PathEntry( 
  	-textvariable=>\$CsgObj->instruments->{$pref.'_path'}
  	,-background=>$COLOR{input_bgcolor}
  	,-state=>'normal',  
  )->form(
		-left=>[$CsgObj->instruments->{'-'.$pref.'_path_label'},0]
		,-top=>['%1',4]
		,-right=>['%40',0]
	);

  $CsgObj->instruments->{'-'.$pref.'_author_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->LabEntry(
		-label => 'Author: '
		,-labelPack => ['-side', 'left', '-anchor', 'w' ]
		#,-labelFont => '9x15bold'
		,-background => $COLOR{input_bgcolor}
		,-foreground => $COLOR{input_fgcolor}
		,-relief => 'ridge'
		,-state => 'normal'
		,-textvariable =>\$CsgObj->instruments->{$pref.'_author'}
		,-width => 12
		,-validate => 'key'
		,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }
		,-invalidcommand => sub { }
  );
  $CsgObj->instruments->{'-'.$pref.'_author_text'}->form(   
	-top=>['%1',4]
	,-left=>[$CsgObj->instruments->{'-'.$pref.'_path_entry'},0]
  );

  $CsgObj->instruments->{'-'.$pref.'_name_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->LabEntry(
		-label => 'Ins. name: '
		,-labelPack => ['-side', 'left', '-anchor', 'w' ]
		#,-labelFont => '9x15bold'
		,-background => $COLOR{input_bgcolor}
		,-foreground => $COLOR{input_fgcolor}
		,-relief => 'ridge'
		,-state => 'normal'
		,-textvariable =>\$CsgObj->instruments->{$pref.'_name'}
		,-width => 12
		,-validate => 'key'
		,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }
		,-invalidcommand => sub { }
  );
  $CsgObj->instruments->{'-'.$pref.'_name_text'}->form(   
		-top=>['%1',4]
		,-left=>[$CsgObj->instruments->{'-'.$pref.'_author_text'},0]
  );

  ## ### Multi choice: $COLOR{'button_bgcolor'}
	$CsgObj->instruments->{'-'.$pref.'_type_text'} =
	$CsgObj->instruments->{'-'.$pref.'_frame'}->Menubutton(
		 -borderwidth=>1
		,-background => $COLOR{cbox_bgcolor}
		,-foreground => $COLOR{cbox_fgcolor}
		,-relief=>'groove'
		,-text=>'Ins. type'
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'Inst',
		-variable => \$CsgObj->instruments->{$pref.'_type'}
		,-value => 'ins'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'Fx',
		-variable => \$CsgObj->instruments->{$pref.'_type'}
		,-value => 'fx'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->separator();
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'amp',
		-variable => \$CsgObj->instruments->{$pref.'_amp_type'}
		,-value => 'amp'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'ampdb',
		-variable => \$CsgObj->instruments->{$pref.'_amp_type'}
		,-value => 'ampdb'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->separator();
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'cps',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'cps'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'cpspch',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'cpspch'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'midi',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'midi'
		,-underline => 0
	);
	
  $CsgObj->instruments->{'-'.$pref.'_type_text'}->form(   
	-top=>['%1',4]
	,-left=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]
  );

  $CsgObj->instruments->{'-'.$pref.'_com_label'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Label( -textvariable=>\'Comments: ' )->form(-left=>['%1',0],-top=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]);
  $CsgObj->instruments->{'-'.$pref.'_com_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Text(-state=>'normal', -background=>$COLOR{input_bgcolor}, -height=>'2')->form(
		-left=>[$CsgObj->instruments->{'-'.$pref.'_com_label'},0]
		,-top=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]
		,-right=>['%99',0]
		## XXX WARNING wrap option produces an error when not in scrolled text.
  );
  $CsgObj->instruments->{'-'.$pref.'_com_text'}->Contents($CsgObj->instruments->{$pref.'_comment'});
  
  ## Default params table  with zeroes if no previous data in i576_p4 e.g.
  my $parnum = 2;
  $CsgObj->instruments->{'-'.$pref.'_table'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Table(
		-rows => 3
		,-columns => ($parnum+1)
		,-relief=>'groove'
		,-scrollbars => 'se' 
		,-fixedrows => 1
		,-fixedcolumns => 1
		,-takefocus => 'on'
  );
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(0, 0, 'ind:');
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(1, 0, 'fun:');
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(2, 0, 'def:');
  for (my $n = 1; $n <= $parnum; $n++) {
		my $tmp_label = $CsgObj->instruments->{'-'.$pref.'_table'}->Label(-text =>"p".($n+2), -anchor => 'w', -relief =>'groove', -justify => 'left');
		my $tmp_fun = $CsgObj->instruments->{'-'.$pref.'_table'}->Text(-background => $COLOR{table_bgcolor}, -foreground => $COLOR{table_fgcolor}, -height=>1, -width =>4);
		my $tmp_def = $CsgObj->instruments->{'-'.$pref.'_table'}->Text(-background => $COLOR{table_bgcolor}, -foreground => $COLOR{table_fgcolor}, -height=>1, -width =>4);
		$CsgObj->instruments->{'-'.$pref.'_table'}->put(0, $n, $tmp_label);
		$CsgObj->instruments->{'-'.$pref.'_table'}->put(1, $n, $tmp_fun);
		$CsgObj->instruments->{'-'.$pref.'_table'}->get(1, $n)->Contents($CsgObj->instruments->{$pref.'_p'.($n+2).'_fun'}); 
		$CsgObj->instruments->{'-'.$pref.'_table'}->put(2, $n, $tmp_def);
		$CsgObj->instruments->{'-'.$pref.'_table'}->get(2, $n)->Contents($CsgObj->instruments->{$pref.'_p'.($n+2).'_def'}); 
  }
  $CsgObj->instruments->{'-'.$pref.'_table'}->form(
		-left=>['%1',0]
		,-top=>[$CsgObj->instruments->{'-'.$pref.'_com_text'},4]
		,-right=>['%99',0]
  );

  ## Delete button. 
  $CsgObj->instruments->{'-'.$pref.'_delete_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
	  -background =>$COLOR{'button_bgcolor'}
	  ,-foreground =>$COLOR{'button_fgcolor'}
	  ,-text=>'Delete'
	  ,-state=>'disabled'
	  ,-command=>\sub { &ins_del($pref) }
  )->form(
		-right=>['%99',4]
		, -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
  );

  ## Save as button. 
  $CsgObj->instruments->{'-'.$pref.'_saveas_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
	  -background =>$COLOR{'button_bgcolor'}
	  ,-foreground =>$COLOR{'button_fgcolor'}
	  ,-text=>'Save As'
	  ,-state=>'normal'
	  ,-command=>\sub {ins_sas($pref)}
  )->form(
		-right=>[$CsgObj->instruments->{'-'.$pref.'_delete_button'},4]
		, -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
  );

	## Save changes button. 
	$CsgObj->instruments->{'-'.$pref.'_save_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
		-background =>$COLOR{'button_bgcolor'}
		,-foreground =>$COLOR{'button_fgcolor'}
		,-text=>'Update'
		,-state=>'normal'
		,-command=>\&ins_update
	)->form(
	  -right=>[$CsgObj->instruments->{'-'.$pref.'_saveas_button'},4]
	  , -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
	);

	## New ins button. 
	$CsgObj->instruments->{'-'.$pref.'_new_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Menubutton(
	  -text=>'New',
	  -menuitems => [
		  ['command' => 'New Ins', -command => sub { &ins_new('ins') } ],
		  ['command' => 'New FX', -command => sub { &ins_new('fx') } ],
	  ]	
		,-background =>$COLOR{'button_bgcolor'}
		,-foreground =>$COLOR{'button_fgcolor'}
	)->form(
 	  -right=>[$CsgObj->instruments->{'-'.$pref.'_save_button'},-4]
 	  , -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},7]
 	);                 		

  ## Instrument text field (modifiable). 
  $CsgObj->instruments->{'-'.$pref.'_content_text'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Scrolled(
		'TextUndo'
		, -background=>$COLOR{input_bgcolor}
		, -foreground =>$COLOR{input_fgcolor}
		, -scrollbars => 'se' 
		, -wrap => 'word' 
		);
  $CsgObj->instruments->{'-'.$pref.'_content_text'}->form(
		-top=>[$CsgObj->instruments->{'-'.$pref.'_save_button'},8]
		, -left=>['%1',0], -right=>['%99',0]
		, -bottom=>['%98',0]
  );
  $CsgObj->instruments->{'-'.$pref.'_content_text'}->Contents(
		"instr ".$CsgObj->instruments->{$pref.'_id'}.
		$CsgObj->instruments->{$pref.'_content'}
  );
  ## ### Now the same with instrument 576
  $pref = "i576";
  $CsgObj->instruments->{$pref.'_author'} = "csound";
  $CsgObj->instruments->{$pref.'_name'} = "Gobal Reverb";
  $CsgObj->instruments->{$pref.'_comment'} = "An instrument that is receiving input from a global variable should have a higher number than any instrument that are producing output for that variable.(R. Pinkston)";
  $CsgObj->instruments->{$pref.'_id'} = 576;
  $CsgObj->instruments->{$pref.'_type'} = "fx";
  $CsgObj->instruments->{$pref.'_amp_type'} = "";
  $CsgObj->instruments->{$pref.'_freq_type'} = "";
  $CsgObj->instruments->{$pref.'_path'} = "internal";
  $CsgObj->instruments->{$pref.'_content'} = 
	" idur = p3 ;\n".
	" irvbtime = p4 ;\n".
	" asig reverb garvbsig,irvbtime ;\n".
	" outs asig,asig ;\n".
	" garvbsig = 0 ;\n".
	"endin ;\n";
  $CsgObj->instruments->{$pref.'_p3_fun'} = "dur";
  $CsgObj->instruments->{$pref.'_p3_def'} = "120";
  $CsgObj->instruments->{$pref.'_p4_fun'} = "rvt";
  $CsgObj->instruments->{$pref.'_p4_def'} = "120";

  ## Now create or refresh the corresponding tab (-$pref = not XML storable).
  if (exists $CsgObj->instruments->{"I576"}) { $Orcbook->delete($pref) }
  $CsgObj->instruments->{'-'.$pref.'_tab'} = $Orcbook->add($pref, -label=>$pref, -raisecmd=>\&book_open);

  $CsgObj->instruments->{"I576"} = &Csgrouper::Datem();

  ## File name, Title, Desc, Comments text flds
  $CsgObj->instruments->{'-'.$pref.'_frame'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Frame(-borderwidth=>4, -relief=>'groove');
  $CsgObj->instruments->{'-'.$pref.'_frame'}->form(-left=>['%1',0], -right=>['%99',0], -top=>['%1',4]);
  $CsgObj->instruments->{'-'.$pref.'_path_label'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Label( -textvariable=>\'File path: ' )->form(-top=>['%1',4],-left=>['%1',0]);
  $CsgObj->instruments->{'-'.$pref.'_path_entry'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->PathEntry( -textvariable=>\$CsgObj->instruments->{$pref.'_path'}, -background=>$COLOR{input_bgcolor}, -state=>'normal',  )->form(
	-left=>[$CsgObj->instruments->{'-'.$pref.'_path_label'},0]
	,-top=>['%1',4]
	,-right=>['%40',0]
  );

  $CsgObj->instruments->{'-'.$pref.'_author_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->LabEntry(
		-label => 'Author: '
		,-labelPack => ['-side', 'left', '-anchor', 'w' ]
		#,-labelFont => '9x15bold'
		,-background => $COLOR{input_bgcolor}
		,-foreground => $COLOR{input_fgcolor}
		,-relief => 'ridge'
		,-state => 'normal'
		,-textvariable =>\$CsgObj->instruments->{$pref.'_author'}
		,-width => 12
		,-validate => 'key'
		,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }
		,-invalidcommand => sub { }
  );
  $CsgObj->instruments->{'-'.$pref.'_author_text'}->form(   
		-top=>['%1',4]
		,-left=>[$CsgObj->instruments->{'-'.$pref.'_path_entry'},0]
  );

  $CsgObj->instruments->{'-'.$pref.'_name_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->LabEntry(
		-label => 'Ins. name: '
		,-labelPack => ['-side', 'left', '-anchor', 'w' ]
		#,-labelFont => '9x15bold'
		,-background => $COLOR{input_bgcolor}
		,-foreground => $COLOR{input_fgcolor}
		,-relief => 'ridge'
		,-state => 'normal'
		,-textvariable =>\$CsgObj->instruments->{$pref.'_name'}
		,-width => 12
		,-validate => 'key'
		,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }
		,-invalidcommand => sub { }
  );
  $CsgObj->instruments->{'-'.$pref.'_name_text'}->form(   
		-top=>['%1',4]
		,-left=>[$CsgObj->instruments->{'-'.$pref.'_author_text'},0]
  );

  ## ### Multi choice:
	$CsgObj->instruments->{'-'.$pref.'_type_text'} =
	$CsgObj->instruments->{'-'.$pref.'_frame'}->Menubutton(
		 -borderwidth=>1
		,-background => $COLOR{cbox_bgcolor}
		,-foreground => $COLOR{cbox_fgcolor}
		,-relief=>'groove'
		,-text=>'Ins. type'
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'Inst',
		-variable => \$CsgObj->instruments->{$pref.'_type'}
		,-value => 'ins'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'Fx',
		-variable => \$CsgObj->instruments->{$pref.'_type'}
		,-value => 'fx'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->separator();
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'amp',
		-variable => \$CsgObj->instruments->{$pref.'_amp_type'}
		,-value => 'amp'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'ampdb',
		-variable => \$CsgObj->instruments->{$pref.'_amp_type'}
		,-value => 'ampdb'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->separator();
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'cps',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'cps'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'cpspch',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'cpspch'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'midi',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'midi'
		,-underline => 0
	);
	
  $CsgObj->instruments->{'-'.$pref.'_type_text'}->form(   
		-top=>['%1',4]
		,-left=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]
  );

  $CsgObj->instruments->{'-'.$pref.'_com_label'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Label( -textvariable=>\'Comments: ' )->form(-left=>['%1',0],-top=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]);
		$CsgObj->instruments->{'-'.$pref.'_com_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Text(-state=>'normal', -background=>$COLOR{input_bgcolor}, -height=>'2')->form(
		-left=>[$CsgObj->instruments->{'-'.$pref.'_com_label'},0]
		,-top=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]
		,-right=>['%99',0]
		## XXX WARNING wrap option produces an error when not in scrolled text.
		);
		$CsgObj->instruments->{'-'.$pref.'_com_text'}->Contents($CsgObj->instruments->{$pref.'_comment'});
		
		## Default params table  with zeroes if no previous data in i576_p4 e.g.
		$parnum = 1;
		$CsgObj->instruments->{'-'.$pref.'_table'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Table(
		-rows => 3
		,-columns => ($parnum+1)
		,-relief=>'groove'
		,-scrollbars => 'se' 
		,-fixedrows => 1
		,-fixedcolumns => 1
		,-takefocus => 'on'
  );
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(0, 0, 'ind:');
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(1, 0, 'fun:');
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(2, 0, 'def:');
  for (my $n = 1; $n <= $parnum; $n++) {
	my $tmp_label = $CsgObj->instruments->{'-'.$pref.'_table'}->Label(-text =>"p".($n+2), -anchor => 'w', -relief =>'groove', -justify => 'left');
	my $tmp_fun = $CsgObj->instruments->{'-'.$pref.'_table'}->Text(-background => $COLOR{table_bgcolor}, -foreground => $COLOR{table_fgcolor}, -height=>1, -width =>4);
	my $tmp_def = $CsgObj->instruments->{'-'.$pref.'_table'}->Text(-background => $COLOR{table_bgcolor}, -foreground => $COLOR{table_fgcolor}, -height=>1, -width =>4);
	$CsgObj->instruments->{'-'.$pref.'_table'}->put(0, $n, $tmp_label);
	$CsgObj->instruments->{'-'.$pref.'_table'}->put(1, $n, $tmp_fun);
	$CsgObj->instruments->{'-'.$pref.'_table'}->get(1, $n)->Contents($CsgObj->instruments->{$pref.'_p'.($n+2).'_fun'}); 
	$CsgObj->instruments->{'-'.$pref.'_table'}->put(2, $n, $tmp_def);
	$CsgObj->instruments->{'-'.$pref.'_table'}->get(2, $n)->Contents($CsgObj->instruments->{$pref.'_p'.($n+2).'_def'}); 
  }
  $CsgObj->instruments->{'-'.$pref.'_table'}->form(
		-left=>['%1',0]
		,-top=>[$CsgObj->instruments->{'-'.$pref.'_com_text'},4]
		,-right=>['%99',0]
  );

  ## Delete button. 
  $CsgObj->instruments->{'-'.$pref.'_delete_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
	  -background =>$COLOR{'button_bgcolor'}
	  ,-foreground =>$COLOR{'button_fgcolor'}
	  ,-text=>'Delete'
	  ,-state=>'disabled'
	  ,-command=>\sub { &ins_del($pref) }
  )->form(
		-right=>['%99',4]
		, -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
  );

  ## Save as button. 
  $CsgObj->instruments->{'-'.$pref.'_saveas_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
	  -background =>$COLOR{'button_bgcolor'}
	  ,-foreground =>$COLOR{'button_fgcolor'}
	  ,-text=>'Save As'
	  ,-state=>'normal'
	  ,-command=>\sub {ins_sas($pref)}
  )->form(
	-right=>[$CsgObj->instruments->{'-'.$pref.'_delete_button'},4]
	, -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
  );

	## Save changes button. 
	$CsgObj->instruments->{'-'.$pref.'_save_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
		-background =>$COLOR{'button_bgcolor'}
		,-foreground =>$COLOR{'button_fgcolor'}
		,-text=>'Update'
		,-state=>'normal'
		,-command=>\&ins_update
	)->form(
	  -right=>[$CsgObj->instruments->{'-'.$pref.'_saveas_button'},4]
	  , -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
	);

	## New ins button. 
	$CsgObj->instruments->{'-'.$pref.'_new_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Menubutton(
	  -text=>'New',
	  -menuitems => [
		  ['command' => 'New Ins', -command => sub { &ins_new('ins') } ],
		  ['command' => 'New FX', -command => sub { &ins_new('fx') } ],
	  ]	
		,-background =>$COLOR{'button_bgcolor'}
		,-foreground =>$COLOR{'button_fgcolor'}
	)->form(
 	  -right=>[$CsgObj->instruments->{'-'.$pref.'_save_button'},-4]
 	  , -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},7]
 	);                 		

  ## Instrument text field (modifiable). 
  $CsgObj->instruments->{'-'.$pref.'_content_text'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Scrolled(
	'TextUndo'
	, -background=>$COLOR{input_bgcolor}
	, -foreground =>$COLOR{input_fgcolor}
	, -scrollbars => 'se' 
	, -wrap => 'word' 
  );
  $CsgObj->instruments->{'-'.$pref.'_content_text'}->form(
	-top=>[$CsgObj->instruments->{'-'.$pref.'_save_button'},8]
	, -left=>['%1',0], -right=>['%99',0]
	, -bottom=>['%98',0]
  );
  $CsgObj->instruments->{'-'.$pref.'_content_text'}->Contents(
	"instr ".$CsgObj->instruments->{$pref.'_id'}."\n".
	$CsgObj->instruments->{$pref.'_content'}
  );
  ## ### Now update F-tables and Global vars:
  my $orcinit = $Orcini_tw->Contents();
  my $ftb = $Ftb_tw->Contents();
  $ftb = "f 1 0 65536 10 1 ;	sine (internal).\n".$ftb if ($ftb !~ /\s*f\s+1\s+\d+.*\n/);
  $Ftb_tw->Contents($ftb);
  $orcinit = "garvbsig = 0 ;	global reverb (internal).\n".$orcinit if ($orcinit !~ /\s*garvbsig[\=\s]+.*\n/);
  $Orcini_tw->Contents($orcinit);
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END ins_def().

=item * ins_del($ins) : deletes an Orchestra tab.
=cut

sub ins_del {
  my ($ins) = @_;
  my $subname = "ins_del";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 0;
  if ($ins !~ /i\d+/) {
		&Csgrouper::says($subname, "Invalid name : $ins");
		$Csgrouper::DEBFLAG =  $oldebflag;
		return 0;
  }
  if ($ins =~ /(i1)|(i$Csgrouper::Types::MAXOBJ)/) {
		&Csgrouper::says($subname, "Can't delete internal instrument $ins.");
		$Csgrouper::DEBFLAG =  $oldebflag;
		return 0;
  }
  my $d = $mw->Dialog(-title => "Alert", -text => "Really delete instrument $ins ?", -buttons => ["Delete", "Cancel"]);
  if ($d->Show !~ /Delete/) {
		&Csgrouper::Debug($subname, "Deletion aborted", 1) ;
		$Csgrouper::DEBFLAG =  $oldebflag;
		&Csgrouper::says($subname,"Deletion aborted: $ins.");
		return 0;
  }
  my $i = $ins; $i =~ s/i//;
  delete $CsgObj->instruments->{"I$i"};
  if (exists $CsgObj->instruments->{'-'.$ins.'_tab'}) { $Orcbook->delete($ins) };
  &ins_update();
  &Csgrouper::says($subname,"Instrument deleted: $ins.");
  $Csgrouper::DEBFLAG =  $oldebflag;
  return 1;
} ## END ins_del

=item * ins_load() : loads orchestra tabs.
=cut

sub ins_load { 
  my $subname = "ins_load";
  { no warnings; &Csgrouper::says($subname, "@_" ,1); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 0;
  my ($instr,$name,$parnum,%tmp,$type,$var);
  for (my $i = 1; $i <= MAXOBJ; $i++) { 
		next if (not exists $Part->{"I$i"});
		my $pref = "i$i";
		$CsgObj->instruments->{"I".$i} = &Csgrouper::Datem();
		$CsgObj->instruments->{$pref.'_id'} = $Part->{$pref.'_id'};
		$CsgObj->instruments->{$pref.'_oldid'} = $Part->{$pref.'_oldid'};
		$CsgObj->instruments->{$pref.'_path'} = $Part->{$pref.'_path'};
		$CsgObj->instruments->{$pref.'_author'} = $Part->{$pref.'_author'};
		$CsgObj->instruments->{$pref.'_name'} = $Part->{$pref.'_name'};
		$CsgObj->instruments->{$pref.'_type'} = $Part->{$pref.'_type'};
		$CsgObj->instruments->{$pref.'_amp_type'} = $Part->{$pref.'_amp_type'};
		$CsgObj->instruments->{$pref.'_freq_type'}= $Part->{$pref.'_freq_type'};
		$CsgObj->instruments->{$pref.'_comment'} = $Part->{$pref.'_comment'};
		$CsgObj->instruments->{$pref.'_content'} = $Part->{$pref.'_content'};
		$CsgObj->instruments->{$pref.'_parnum'} = $Part->{$pref.'_parnum'};
		for (my $i = 1; $i <= $CsgObj->instruments->{$pref.'_parnum'}; $i++){ 
			$CsgObj->instruments->{$pref.'_p'.($i+2).'_fun'} = $Part->{$pref.'_p'.($i+2).'_fun'};
			$CsgObj->instruments->{$pref.'_p'.($i+2).'_def'} = $Part->{$pref.'_p'.($i+2).'_def'};
		} 
	
		## Now create or refresh the corresponding tab (-$pref = not XML storable).
		if (exists $CsgObj->instruments->{'-'.$pref.'_tab'}) { $Orcbook->delete($pref) }
		$CsgObj->instruments->{'-'.$pref.'_tab'} = $Orcbook->add($pref, -label=>$pref, -raisecmd=>\&book_open);
	
		## File name, Title, Desc, Comments text flds
		$CsgObj->instruments->{'-'.$pref.'_frame'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Frame(-borderwidth=>4, -relief=>'groove');
		$CsgObj->instruments->{'-'.$pref.'_frame'}->form(-left=>['%1',0], -right=>['%99',0], -top=>['%1',4]);
		$CsgObj->instruments->{'-'.$pref.'_path_label'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Label( -textvariable=>\'File path: ' )->form(-top=>['%1',4],-left=>['%1',0]);
		$CsgObj->instruments->{'-'.$pref.'_path_entry'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->PathEntry( -textvariable=>\$CsgObj->instruments->{$pref.'_path'}, -background=>$COLOR{input_bgcolor}, -state=>'normal',  )->form(
			-left=>[$CsgObj->instruments->{'-'.$pref.'_path_label'},0]
			,-top=>['%1',4]
			,-right=>['%40',0]
		);
	
		$CsgObj->instruments->{'-'.$pref.'_author_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->LabEntry(
			-label => 'Author: '
			,-labelPack => ['-side', 'left', '-anchor', 'w' ]
			,-background => $COLOR{input_bgcolor}
			,-foreground => $COLOR{input_fgcolor}
			,-relief => 'ridge'
			,-state => 'normal'
			,-textvariable =>\$CsgObj->instruments->{$pref.'_author'}
			,-width => 12
			,-validate => 'key'
			,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }	
		);
		$CsgObj->instruments->{'-'.$pref.'_author_text'}->form(   
			-top=>['%1',4]
			,-left=>[$CsgObj->instruments->{'-'.$pref.'_path_entry'},0]
		);
	
		$CsgObj->instruments->{'-'.$pref.'_name_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->LabEntry(
			-label => 'Ins. name: '
			,-labelPack => ['-side', 'left', '-anchor', 'w' ]
			,-background => $COLOR{input_bgcolor}
			,-foreground => $COLOR{input_fgcolor}
			,-relief => 'ridge'
			,-state => 'normal'
			,-textvariable =>\$CsgObj->instruments->{$pref.'_name'}
			,-width => 12
			,-validate => 'key'
			,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }
		);
		
		$CsgObj->instruments->{'-'.$pref.'_name_text'}->form(   
			-top=>['%1',4]
			,-left=>[$CsgObj->instruments->{'-'.$pref.'_author_text'},0]
		);
	
		## Multi-choice:
	$CsgObj->instruments->{'-'.$pref.'_type_text'} =
	$CsgObj->instruments->{'-'.$pref.'_frame'}->Menubutton(
		 -borderwidth=>1
		,-background => $COLOR{cbox_bgcolor}
		,-foreground => $COLOR{cbox_fgcolor}
		,-relief=>'groove'
		,-text=>'Ins. type'
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'Inst',
		-variable => \$CsgObj->instruments->{$pref.'_type'}
		,-value => 'ins'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'Fx',
		-variable => \$CsgObj->instruments->{$pref.'_type'}
		,-value => 'fx'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->separator();
		$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
			-label => 'amp',
			-variable => \$CsgObj->instruments->{$pref.'_amp_type'}
			,-value => 'amp'
			,-underline => 0
		);
		$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
			-label => 'ampdb',
			-variable => \$CsgObj->instruments->{$pref.'_amp_type'}
			,-value => 'ampdb'
			,-underline => 0
		);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->separator();
		$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
			-label => 'cps',
			-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
			,-value => 'cps'
			,-underline => 0
		);
		$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
			-label => 'cpspch',
			-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
			,-value => 'cpspch'
			,-underline => 0
		);
		$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
			-label => 'midi',
			-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
			,-value => 'midi'
			,-underline => 0
		);
		
		$CsgObj->instruments->{'-'.$pref.'_type_text'}->form(   
			-top=>['%1',4]
			,-left=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]
		);
	
		$CsgObj->instruments->{'-'.$pref.'_com_label'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Label( -textvariable=>\'Comments: ' )->form(-left=>['%1',0],-top=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]);
		$CsgObj->instruments->{'-'.$pref.'_com_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Text(-state=>'normal', -background=>$COLOR{input_bgcolor}, -height=>'2')->form(
			-left=>[$CsgObj->instruments->{'-'.$pref.'_com_label'},0]
			,-top=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]
			,-right=>['%99',0]
			## XXX WARNING wrap option produces an error when not in scrolled text.
		);
		
		$CsgObj->instruments->{'-'.$pref.'_com_text'}->Contents($CsgObj->instruments->{$pref.'_comment'});
		
		## Default params table  with zeroes if no previous data in i576_p4 e.g.
		$parnum = $CsgObj->instruments->{$pref.'_parnum'};
		$CsgObj->instruments->{'-'.$pref.'_table'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Table(
			-rows => 3
			,-columns => ($parnum+1)
			,-relief=>'groove'
			,-scrollbars => 'se' 
			,-fixedrows => 1
			,-fixedcolumns => 1
			,-takefocus => 'on'
		);
		$CsgObj->instruments->{'-'.$pref.'_table'}->put(0, 0, 'ind:');
		$CsgObj->instruments->{'-'.$pref.'_table'}->put(1, 0, 'fun:');
		$CsgObj->instruments->{'-'.$pref.'_table'}->put(2, 0, 'def:');
		for (my $n = 1; $n <= $parnum; $n++){
			my $tmp_label = $CsgObj->instruments->{'-'.$pref.'_table'}->Label(-text =>"p".($n+2), -anchor => 'w', -relief =>'groove', -justify => 'left');
			my $tmp_fun = $CsgObj->instruments->{'-'.$pref.'_table'}->Text(-background => $COLOR{table_bgcolor}, -foreground => $COLOR{table_fgcolor}, -height=>1, -width =>4);
			my $tmp_def = $CsgObj->instruments->{'-'.$pref.'_table'}->Text(-background => $COLOR{table_bgcolor}, -foreground => $COLOR{table_fgcolor}, -height=>1, -width =>4);
			$CsgObj->instruments->{'-'.$pref.'_table'}->put(0, $n, $tmp_label);
			$CsgObj->instruments->{'-'.$pref.'_table'}->put(1, $n, $tmp_fun);
			$CsgObj->instruments->{'-'.$pref.'_table'}->get(1, $n)->Contents($CsgObj->instruments->{$pref.'_p'.($n+2).'_fun'}); 
			&Csgrouper::Debug($subname, "pref_p_fun:".$CsgObj->instruments->{$pref.'_p'.($n+2).'_fun'});
			$CsgObj->instruments->{'-'.$pref.'_table'}->put(2, $n, $tmp_def);
			$CsgObj->instruments->{'-'.$pref.'_table'}->get(2, $n)->Contents($CsgObj->instruments->{$pref.'_p'.($n+2).'_def'}); 
		}
		$CsgObj->instruments->{'-'.$pref.'_table'}->form(
			-left=>['%1',0]
			,-top=>[$CsgObj->instruments->{'-'.$pref.'_com_text'},4]
			,-right=>['%99',0]
		);
	
		## Delete button. 
		my $state = 'normal';
		$CsgObj->instruments->{'-'.$pref.'_delete_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
			-background =>$COLOR{'button_bgcolor'}
			,-foreground =>$COLOR{'button_fgcolor'}
			,-text=>'Delete'
			,-state=>$state
			,-command=>\sub { &ins_del($pref) }
		)->form(
			-right=>['%99',4]
			, -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
		);
	
		## Save as button. 
		$CsgObj->instruments->{'-'.$pref.'_saveas_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
			-background =>$COLOR{'button_bgcolor'}
			,-foreground =>$COLOR{'button_fgcolor'}
			,-text=>'Save As'
			,-state=>$state
			,-command=>\sub {ins_sas($pref)}
		)->form(
			-right=>[$CsgObj->instruments->{'-'.$pref.'_delete_button'},4]
			, -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
		);
	
		## Save changes button. 
		$CsgObj->instruments->{'-'.$pref.'_save_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
			-background =>$COLOR{'button_bgcolor'}
			,-foreground =>$COLOR{'button_fgcolor'}
			,-text=>'Update'
			,-state=>$state
			,-command=>\&ins_update
		)->form(
			-right=>[$CsgObj->instruments->{'-'.$pref.'_saveas_button'},4]
			, -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
		);
	
		## Instrument text field (modifiable).        	
	
		## New ins button. 
		$CsgObj->instruments->{'-'.$pref.'_new_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Menubutton(
			-text=>'New',
			-menuitems => [
				['command' => 'New Ins', -command => sub { &ins_new('ins') } ],
				['command' => 'New FX', -command => sub { &ins_new('fx') } ],
			]	
			,-background =>$COLOR{'button_bgcolor'}
			,-foreground =>$COLOR{'button_fgcolor'}
		)->form(
			-right=>[$CsgObj->instruments->{'-'.$pref.'_save_button'},-4]
			, -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},7]
		);                 		
	
		$CsgObj->instruments->{'-'.$pref.'_content_text'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Scrolled(
			'TextUndo'
			, -background=>$COLOR{input_bgcolor}
			, -foreground =>$COLOR{input_fgcolor}
			, -scrollbars => 'se' 
			, -wrap => 'word' 
		);
	
		$CsgObj->instruments->{'-'.$pref.'_content_text'}->form(
			-top=>[$CsgObj->instruments->{'-'.$pref.'_save_button'},8]
			, -left=>['%1',0], -right=>['%99',0]
			, -bottom=>['%98',0]
		);
		$CsgObj->instruments->{'-'.$pref.'_content_text'}->Contents($CsgObj->instruments->{$pref.'_content'});
  }
  &Csgrouper::Debug($subname, "Instruments loaded.");
  END_INS_LOAD:
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END ins_load().

=item * ins_open($fh, $path, $type) : reads orchestra files.
=cut

sub ins_open { 
  my ($fh, $path, $type) = @_;
  my $subname = "ins_open";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my ($instr,$name,$parnum,%tmp,$var);
  $parnum = 0;
  while (<$fh>) { ## Our Global reverb and main F-table.
		my $line = $_ ;
		chomp $line;
		if ($line =~ /([^<>;]*)(instr\s\d+)(.*)/){
			$var = $line;
			$var =~ s/([^<>;]*)(instr\s+)(\d+)(.*)/$3/;
			$tmp{'_oldid'} = $var;
			## Don't record an old instrument number.
		}
		elsif ($line =~ /([^<]*)(<varid>)(.*)(<\/varid>.*)/){
			$instr = $line;
			$instr =~ s/([^<]*)(<varid>)(.*)(<\/varid>.*)/$3/;
		} ## Type:
		elsif ($line =~ /([^<]*)(<type>)(.*)(<\/type>.*)/){
			$type = $line;
			$type =~ s/([^<]*)(<type>)(.*)(<\/type>.*)/$3/;
		} ## Global vars: this meta property will be suppressed in the future.
		elsif ($line =~ /(.*)(<comment>)(.*)(<\/comment>.*)/){
			$var = $line;
			$var =~ s/(.*)(<comment>)(.*)(<\/comment>.*)/$3/;
			$tmp{'_comment'} = $var;
		}
		elsif ($line =~ /(.*)(<author>)(.*)(<\/author>.*)/){
			$var = $line;
			$var =~ s/(.*)(<author>)(.*)(<\/author>.*)/$3/;
			$tmp{'_author'} = $var;
		}
		elsif ($line =~ /(.*)(\<name\>)(.*)(<\/name>.*)/){
			$name = $line;
			$name =~ s/(.*)(<name>)(.*)(<\/name>.*)/$3/;
			$tmp{'_name'} = $name;
		}
		else {
			if ($line =~ /(.*)(\W+)(p\d+)(\s*.*)/){
			$var = $line;
			$var =~ s/(.*)(\W+)(p\d+)(\s*.*)/$3/;
			## $tmp{'_params'} .= "$var "; ## This var would remain only for the opening session.
			$tmp{'_parnum'}++; ## We need both:
			$parnum++;
			}
			$tmp{'_content'} .= "$line\n";
		}
  } 
  ## Set Inst var:
  ## We use a system similar to %{$CsgObj->sequences}.
  my $oldi = $instr;
  if ($instr !~ /\d+/ || $instr < 1 || $instr > MAXOBJ || exists $CsgObj->instruments->{"I".$instr}){
		&Csgrouper::Debug($subname, "Not a valid var id: $instr", 1);
		if ($type =~ /fx/i){
			for (my $n = MAXOBJ; $n > 0; $n--){
				if (not exists $CsgObj->instruments->{"I".$n}) {
				$instr = $n ;
				last;
				}
			}
		}
		else {
			$type = "ins";
			for (my $n = 1; $n <= MAXOBJ; $n++){
				if (not exists $CsgObj->instruments->{"I".$n}) {
				$instr = $n ;
				last;
				}
			}
		}
		if ($instr =~ /^($oldi)$/) {
			&Csgrouper::Debug($subname, "No way to record instrument.", 1);
			goto END_INS_OPEN;
		}
  }
  my $pref = "i$instr";
  while (my ($key,$val) = each %tmp) { $CsgObj->instruments->{$pref.$key} = $val }
  $CsgObj->instruments->{$pref.'_id'} = $instr;
  $CsgObj->instruments->{$pref.'_type'} = $type;
  $CsgObj->instruments->{$pref.'_amp_type'} = "";
  $CsgObj->instruments->{$pref.'_freq_type'} = "";
  $CsgObj->instruments->{$pref.'_path'} = $path;
  $CsgObj->instruments->{"I".$instr} = &Csgrouper::Datem();

  &Csgrouper::Debug($subname, "vid: ".$CsgObj->instruments->{$pref.'_id'});
  &Csgrouper::Debug($subname, "old: ".$CsgObj->instruments->{$pref.'_oldid'});
  &Csgrouper::Debug($subname, "typ: ".$CsgObj->instruments->{$pref.'_type'});
  &Csgrouper::Debug($subname, "nam: ".$CsgObj->instruments->{$pref.'_name'});
  &Csgrouper::Debug($subname, "pth: ".$CsgObj->instruments->{$pref.'_path'});
  ##&Csgrouper::Debug($subname, "par: ".$CsgObj->instruments->{$pref.'_params'});
  &Csgrouper::Debug($subname, "pnm: ".$CsgObj->instruments->{$pref.'_parnum'});
  &Csgrouper::Debug($subname, "com: ".$CsgObj->instruments->{$pref.'_comment'});
  &Csgrouper::Debug($subname, "con: ".$CsgObj->instruments->{$pref.'_content'});
  ## Now create or refresh the corresponding tab (-$pref = not XML storable).
  if (exists $CsgObj->instruments->{'-'.$pref.'_tab'}) { $Orcbook->delete($pref) }
  $CsgObj->instruments->{'-'.$pref.'_tab'} = $Orcbook->add($pref, -label=>$pref, -raisecmd=>\&book_open);

  ## File name, Title, Desc, Comments text flds
  $CsgObj->instruments->{'-'.$pref.'_frame'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Frame(-borderwidth=>4, -relief=>'groove');
  $CsgObj->instruments->{'-'.$pref.'_frame'}->form(-left=>['%1',0], -right=>['%99',0], -top=>['%1',4]);
  $CsgObj->instruments->{'-'.$pref.'_path_label'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Label( -textvariable=>\'File path: ' )->form(-top=>['%1',4],-left=>['%1',0]);
  $CsgObj->instruments->{'-'.$pref.'_path_entry'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->PathEntry( -textvariable=>\$CsgObj->instruments->{$pref.'_path'}, -background=>$COLOR{input_bgcolor}, -state=>'normal',  )->form(
		-left=>[$CsgObj->instruments->{'-'.$pref.'_path_label'},0]
		,-top=>['%1',4]
		,-right=>['%40',0]
  );

  $CsgObj->instruments->{'-'.$pref.'_author_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->LabEntry(
		-label => 'Author: '
		,-labelPack => ['-side', 'left', '-anchor', 'w' ]
		#,-labelFont => '9x15bold'
		,-background => $COLOR{input_bgcolor}
		,-foreground => $COLOR{input_fgcolor}
		,-relief => 'ridge'
		,-state => 'normal'
		,-textvariable =>\$CsgObj->instruments->{$pref.'_author'}
		,-width => 12
		,-validate => 'key'
		,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }
		,-invalidcommand => sub { }
  );
  $CsgObj->instruments->{'-'.$pref.'_author_text'}->form(   
		-top=>['%1',4]
		,-left=>[$CsgObj->instruments->{'-'.$pref.'_path_entry'},0]
  );
  
  $CsgObj->instruments->{'-'.$pref.'_name_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->LabEntry(
		-label => 'Ins. name: '
		,-labelPack => ['-side', 'left', '-anchor', 'w' ]
		#,-labelFont => '9x15bold'
		,-background => $COLOR{input_bgcolor}
		,-foreground => $COLOR{input_fgcolor}
		,-relief => 'ridge'
		,-state => 'normal'
		,-textvariable =>\$CsgObj->instruments->{$pref.'_name'}
		,-width => 12
		,-validate => 'key'
		,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }
		,-invalidcommand => sub { }
  );
  $CsgObj->instruments->{'-'.$pref.'_name_text'}->form(   
		-top=>['%1',4]
		,-left=>[$CsgObj->instruments->{'-'.$pref.'_author_text'},0]
  );

  ## ### Multi choice:
	$CsgObj->instruments->{'-'.$pref.'_type_text'} =
	$CsgObj->instruments->{'-'.$pref.'_frame'}->Menubutton(
		 -borderwidth=>1
		,-background => $COLOR{cbox_bgcolor}
		,-foreground => $COLOR{cbox_fgcolor}
		,-relief=>'groove'
		,-text=>'Ins. type'
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'Inst',
		-variable => \$CsgObj->instruments->{$pref.'_type'}
		,-value => 'ins'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'Fx',
		-variable => \$CsgObj->instruments->{$pref.'_type'}
		,-value => 'fx'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->separator();
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'amp',
		-variable => \$CsgObj->instruments->{$pref.'_amp_type'}
		,-value => 'amp'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'ampdb',
		-variable => \$CsgObj->instruments->{$pref.'_amp_type'}
		,-value => 'ampdb'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->separator();
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'cps',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'cps'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'cpspch',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'cpspch'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'midi',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'midi'
		,-underline => 0
	);
	
  $CsgObj->instruments->{'-'.$pref.'_type_text'}->form(   
		-top=>['%1',4]
		,-left=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]
  );

  $CsgObj->instruments->{'-'.$pref.'_com_label'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Label( -textvariable=>\'Comments: ' )->form(-left=>['%1',0],-top=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]);
  $CsgObj->instruments->{'-'.$pref.'_com_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Text(-state=>'normal', -background=>$COLOR{input_bgcolor}, -height=>'2')->form(
		-left=>[$CsgObj->instruments->{'-'.$pref.'_com_label'},0]
		,-top=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]
		,-right=>['%99',0]
		## XXX WARNING wrap option produces an error when not in scrolled text.
  );
  $CsgObj->instruments->{'-'.$pref.'_com_text'}->Contents($CsgObj->instruments->{$pref.'_comment'});
  
  ## Default params table  with zeroes if no previous data in i576_p4 e.g.
  $parnum = $CsgObj->instruments->{'-'.$pref.'_parnum'};
  $CsgObj->instruments->{'-'.$pref.'_table'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Table(
	-rows => 3
		,-columns => ($parnum+1)
		,-relief=>'groove'
		,-scrollbars => 'se' 
		,-fixedrows => 1
		,-fixedcolumns => 1
		,-takefocus => 'on'
  );
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(0, 0, 'ind:');
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(1, 0, 'fun:');
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(2, 0, 'def:');
  for (my $n = 1; $n <= $parnum; $n++) {
	my $tmp_label = $CsgObj->instruments->{'-'.$pref.'_table'}->Label(-text =>"p".($n+2), -anchor => 'w', -relief =>'groove', -justify => 'left');
	my $tmp_fun = $CsgObj->instruments->{'-'.$pref.'_table'}->Text(-background => $COLOR{table_bgcolor}, -foreground => $COLOR{table_fgcolor}, -height=>1, -width =>4);
	my $tmp_def = $CsgObj->instruments->{'-'.$pref.'_table'}->Text(-background => $COLOR{table_bgcolor}, -foreground => $COLOR{table_fgcolor}, -height=>1, -width =>4);
	$CsgObj->instruments->{'-'.$pref.'_table'}->put(0, $n, $tmp_label);
	$CsgObj->instruments->{'-'.$pref.'_table'}->put(1, $n, $tmp_fun);
	$CsgObj->instruments->{'-'.$pref.'_table'}->get(1, $n)->Contents($CsgObj->instruments->{$pref.'_p'.($n+2).'_fun'}); 
	$CsgObj->instruments->{'-'.$pref.'_table'}->put(2, $n, $tmp_def);
	$CsgObj->instruments->{'-'.$pref.'_table'}->get(2, $n)->Contents($CsgObj->instruments->{$pref.'_p'.($n+2).'_def'}); 
  }
  $CsgObj->instruments->{'-'.$pref.'_table'}->form(
		-left=>['%1',0]
		,-top=>[$CsgObj->instruments->{'-'.$pref.'_com_text'},4]
		,-right=>['%99',0]
  );

  ## Delete button. 
  $CsgObj->instruments->{'-'.$pref.'_delete_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
	  -background =>$COLOR{'button_bgcolor'}
	  ,-foreground =>$COLOR{'button_fgcolor'}
	  ,-text=>'Delete'
	  ,-state=>'normal'
	  ,-command=>\sub { &ins_del($pref) }
  )->form(
		-right=>['%99',4]
		,-top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
  );

  ## Save as button. 
  $CsgObj->instruments->{'-'.$pref.'_saveas_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
	  -background =>$COLOR{'button_bgcolor'}
	  ,-foreground =>$COLOR{'button_fgcolor'}
	  ,-text=>'Save As'
	  ,-state=>'normal'
	  ,-command=>\sub {ins_sas($pref)}
  )->form(
		-right=>[$CsgObj->instruments->{'-'.$pref.'_delete_button'},4]
		,-top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
  );

	## Save changes button. 
	$CsgObj->instruments->{'-'.$pref.'_save_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
		-background =>$COLOR{'button_bgcolor'}
		,-foreground =>$COLOR{'button_fgcolor'}
		,-text=>'Update'
		,-state=>'normal'
		,-command=>\&ins_update
	)->form(
	  -right=>[$CsgObj->instruments->{'-'.$pref.'_saveas_button'},4]
	  ,-top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
	);

 	## New ins button. 
	$CsgObj->instruments->{'-'.$pref.'_new_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Menubutton(
	  -text=>'New',
	  -menuitems => [
		  ['command' => 'New Ins', -command => sub { &ins_new('ins') } ],
		  ['command' => 'New FX', -command => sub { &ins_new('fx') } ],
	  ]	
		,-background =>$COLOR{'button_bgcolor'}
		,-foreground =>$COLOR{'button_fgcolor'}
	)->form(
 	   -right=>[$CsgObj->instruments->{'-'.$pref.'_save_button'},-4]
 	  ,-top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},7]
 	);                 		

  ## Instrument text field (modifiable). 
  $CsgObj->instruments->{'-'.$pref.'_content_text'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Scrolled(
		'TextUndo'
		,-background=>$COLOR{input_bgcolor}
		,-foreground =>$COLOR{input_fgcolor}
		,-scrollbars => 'se' 
		,-wrap => 'word' 
  );
  $CsgObj->instruments->{'-'.$pref.'_content_text'}->form(
		-top=>[$CsgObj->instruments->{'-'.$pref.'_save_button'},8]
		,-left=>['%1',0], -right=>['%99',0]
		,-bottom=>['%98',0]
  );
  $CsgObj->instruments->{'-'.$pref.'_content_text'}->Contents(
		"instr ".$CsgObj->instruments->{$pref.'_id'}."\n".
		$CsgObj->instruments->{$pref.'_content'}
  );
  END_INS_OPEN:
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END ins_open().

=item * ins_parnum($text) : extract parameter names of a Csound instrument text.
=cut

sub ins_parnum {
  my ($txt) = @_;
  my $subname = "ins_parnum";
  # { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my @lines = split /\n/,$txt;
  my ($params,$parnum,%tmp);
  foreach (@lines) { 
		my $line = $_ ;
		chomp $line;
		if ($line =~ /(.*)([^a-zA-Z0-9]+)(p\d+)([^a-zA-Z0-9]*)/){
			my $var = $line;
			my @tmp; 
			my @pars = $var =~ m/([^a-zA-Z0-9]{1}p\d+[^a-zA-Z0-9]*)/gi;
			&Csgrouper::Debug($subname, "\@vars: @pars");
			foreach (@pars) { 
				my $p = $_;
				$p =~ s/([^a-zA-Z0-9]{1})(p\d+)([^a-zA-Z0-9]*)/$2/;
				push @tmp, $p;
			}
			&Csgrouper::Debug($subname, "\@tmp: @tmp");
			foreach (@tmp) { $tmp{$_} = 1 }
		}
  } 
	while (my ($key,$val) = each %tmp) { $parnum++ }
  &Csgrouper::Debug($subname, $parnum);
  $Csgrouper::DEBFLAG =  $oldebflag;
  return $parnum;
} ## END ins_parnum().

=item * ins_new($type) : creates a new instrument or effect.
=cut

sub ins_new {
  my ($type) = @_;
  my $subname = "ins_new";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my $txt; 
  my $file = &Csgrouper::Datem('n'); $file = "i.$file.ins";
  my $fs = $mw->FileSelect(-directory => $Part->{'ins_path_pe'});
  my $newfile = $fs->Show;
  &Csgrouper::says($subname, $newfile);
  if (!(-f $newfile)) {
	$txt = "instr new";
	open (FH, "> $newfile") or  die "Can't w-open $newfile: $!";
	  print FH $txt;
	close FH;
	&Csgrouper::says($subname,"Instrument opened: $newfile.");
  }
  else { 
		open (FH, "< $newfile") or  die "Can't r-open $newfile: $!";
			while (<FH>) { $txt.= $_ }
		close FH;
		&Csgrouper::says($subname, $txt);
		&Csgrouper::says($subname,"Instrument opened: $newfile.");
  }
  open (FH, "< $newfile") or  die "Can't r-open $newfile: $!";
  &ins_open("FH",$newfile,$type);
  close FH;
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END ins_new

=item * ins_sas($ins) : saves an instrument as external file.
=cut

sub ins_sas {
  my ($ins) = @_;
  my $subname = "ins_sas";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  if ($ins !~ /i\d+/) {
	&Csgrouper::says($subname, "Invalid name : $ins");
	$Csgrouper::DEBFLAG =  $oldebflag;
	return 0;
  }
  &ins_update();
  my $txt = $CsgObj->instruments->{$ins.'_content'};
  my $file = &Csgrouper::Datem('n'); $file = "i.$file.ins";
  my $newfile = $mw->getSaveFile(-title => "Save instrument as:", -initialdir => $Part->{'run_path_pe'}."/bkp", -initialfile => $file);
  &Csgrouper::says($subname, $newfile);
  if ($newfile =~ /.+/) {
	open (FH, "> $newfile") or  die "Can't w-open $newfile: $!";
	  print FH $txt;
	close FH;
	&Csgrouper::says($subname,"Instrument saved as $newfile.");
  }
  else { &Csgrouper::says($subname,"Saving aborted.") }
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END ins_sas

=item * ins_update() : updates instruments tables.
=cut

sub ins_update {
  my $subname = "ins_update";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my (@len, $n);
  ## Here the case is not like a table we only need one numbering.
  ## Having destroyed $CsgObj->instruments->{"I$n"} is sufficient to skip saving all its data.
  for ($n = 1; $n <= MAXOBJ; $n++){ push @len, $n if (exists $CsgObj->instruments->{"I".$n}) } 
	&Csgrouper::Describe($subname, "@len");
  foreach (@len){
		$n = $_;
		my $pref = "i$n"; 
		## $CsgObj->instruments->{$pref.'_id'} Should be set already.
		## $CsgObj->instruments->{$pref.'_oldid'} Should be set already.
		## $CsgObj->instruments->{$pref.'_type'} should be set already;
		## $CsgObj->instruments->{$pref.'_amp_type'} should be set already;
		## $CsgObj->instruments->{$pref.'_freq_type'} should be set already;
		## $CsgObj->instruments->{$pref.'_author'} should be set already;
		## $CsgObj->instruments->{$pref.'_name'} should be set already;
		## $CsgObj->instruments->{$pref.'_path'}  Should be set already.
		$CsgObj->instruments->{$pref.'_comment'} = $CsgObj->instruments->{'-'.$pref.'_com_text'}->Contents();
		## Now the value of _content  is changed from what it was during ins_open and ready to be reloaded:
		$CsgObj->instruments->{$pref.'_content'} = $CsgObj->instruments->{'-'.$pref.'_content_text'}->Contents();
		## Now retrieve the new number of params:
		my $parnum = $CsgObj->instruments->{$pref.'_parnum'} = &ins_parnum($CsgObj->instruments->{$pref.'_content'}); 
		my $tot = $CsgObj->instruments->{'-'.$pref.'_table'}->totalColumns;
		## Delete old unused params if necessary:
		for (my $i = $parnum; $i <= $tot; $i++){ 
			delete $CsgObj->instruments->{$pref.'_p'.($i+2).'_fun'};
			delete $CsgObj->instruments->{$pref.'_p'.($i+2).'_def'};
		}
		## Get contents:
		## I don't know why totalcolumns returns real number of cols + 1...
		for (my $i = 1; $i < $CsgObj->instruments->{'-'.$pref.'_table'}->totalColumns; $i++){ 
			&Csgrouper::Debug($subname, "i=$pref col=$i parnum=$parnum");
			my $fun = $CsgObj->instruments->{'-'.$pref.'_table'}->get(1, $i)->Contents(); 
			my $def = $CsgObj->instruments->{'-'.$pref.'_table'}->get(2, $i)->Contents(); 
			$def =~ s/\n*//g; $fun =~ s/\n*//g; ## A Tk bug.
			$CsgObj->instruments->{$pref.'_p'.($i+2).'_fun'} = $fun//= ""; 				
			$CsgObj->instruments->{$pref.'_p'.($i+2).'_def'} = $def//= "1"; 
		} 
		## Clear table:
		$CsgObj->instruments->{'-'.$pref.'_table'}->clear;
		$CsgObj->instruments->{'-'.$pref.'_table'} = 
			$CsgObj->instruments->{'-'.$pref.'_frame'}->Table(
				-rows => 3
				,-columns => ($parnum+1)
				,-relief=>'groove'
				,-scrollbars => 'se' 
				,-fixedrows => 1
				,-fixedcolumns => 1
				,-takefocus => 'on'
				)->form(
					-left=>['%1',0]
					,-top=>[$CsgObj->instruments->{'-'.$pref.'_com_text'},4]
					,-right=>['%99',0]
				);
		$CsgObj->instruments->{'-'.$pref.'_table'}->put(0, 0, 'ind:');
		$CsgObj->instruments->{'-'.$pref.'_table'}->put(1, 0, 'fun:');
		$CsgObj->instruments->{'-'.$pref.'_table'}->put(2, 0, 'def:');
		## Redo table:
		for (my $i = 1; $i <= $parnum; $i++){ 
			my $tmp_label = $CsgObj->instruments->{'-'.$pref.'_table'}->Label(
				-text =>"p".($i+2)
				,-anchor => 'w'
				,-relief =>'groove'
				,-justify => 'left'
			);
			my $tmp_fun = $CsgObj->instruments->{'-'.$pref.'_table'}->Text(
				 -background => $COLOR{table_bgcolor}
				,-foreground => $COLOR{table_fgcolor}
				,-height=>1
				,-width =>4
			);
			my $tmp_def = $CsgObj->instruments->{'-'.$pref.'_table'}->Text(
				 -background => $COLOR{table_bgcolor}
				,-foreground => $COLOR{table_fgcolor}
				,-height=>1
				,-width =>4
			);
			$CsgObj->instruments->{'-'.$pref.'_table'}->put(0, $i, $tmp_label);

			$CsgObj->instruments->{'-'.$pref.'_table'}->put(1, $i, $tmp_fun);
			my $fun = $CsgObj->instruments->{$pref.'_p'.($i+2).'_fun'};
			$fun =~ s/\n*//g;
			my $tmp = $CsgObj->instruments->{'-'.$pref.'_table'}->get(1, $i);
			$tmp->Contents($fun); 

			$CsgObj->instruments->{'-'.$pref.'_table'}->put(2, $i, $tmp_def);
			my $def = $CsgObj->instruments->{$pref.'_p'.($i+2).'_def'};
			$def =~ s/\n*//g;
			$tmp = $CsgObj->instruments->{'-'.$pref.'_table'}->get(2, $i);
			$tmp->Contents($def); 
			
			&Csgrouper::Debug($subname, "pref: $pref len: @len tot: $tot : $i fun=$fun def=$def");
		} ## END for i < parnum. 
  }
  &set_ready(0);
  &Csgrouper::Describe($subname,"Csgrouper::Instruments globals updated.");
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END ins_update().

=item * menu_about() : displays menu 'about'.
=cut

sub menu_about {
  my $subname = 'menu_about';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  $mw->messageBox(-message=>"about");
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END menu_about().

=item * menu_bar() : creates main menu bar.
=cut

sub menu_bar { 
  my $subname = 'menu_bar';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  $Csgrouper::DEBFLAG =  $oldebflag;
  return [ map 
	['cascade', $_->[0], -menuitems => $_->[1]], 
	['~File', 
	  [ 
		['command', '~New', -accelerator, 'Ctrl-n', -command => \&menu_new], 
		'', 
		['command', '~Open', -command => \&menu_open], 
		['command', 'Reload', -command => \&reload], 
		'', 
		['command', 'Backup', -command => \&menu_bkp], 
		['command', '~Save', -command => \&menu_save], 
		['command', 'S~ave As ...', -command => \&menu_sas], 
		'', 
		['command', '~Quit', -accelerator, 'Ctrl-q', -command => \&menu_quit], 
		['command', 'Quit without saving', -command => \&exit], 
	  ], 
	], 
	['~Edit', 
	  [ 
		['command', 'Clear output ...', -accelerator, 'Ctrl-o', -command =>sub {$Output_tw->Contents('')}], 
		['command', 'Command ...', -accelerator, 'Ctrl-k', -command => \&cline], 
		'', 
		['command', 'Setup ...', -command => \&menu_setup], 
	  ], 
	], 
	['~Help', 
	  [ 
		['command', 'Manual', -command => \&menu_man], 
		'', 
		['command', 
		'About', -command => \&menu_about], 
	  ], 
	], 
  ]; 
} ## END menu_bar().

=item * menu_bkp() : does a backup of the active part file.
=cut

sub menu_bkp {
  my $subname = 'menu_bkp';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $date = &Csgrouper::Datem('n');
  my $file = $Partfile;
  $file =~ s/^(.*\/+)([^\/]+)$/$2/;
  &Csgrouper::Debug($subname, $file,1);
  if (!(-d $Part->{'run_path_pe'}."/bkp")){
	system("mkdir",$Part->{'run_path_pe'}."/bkp");
  }  
  die "Can't create bkp dir." if (!(-d $Part->{'run_path_pe'}."/bkp"));
  system("cp","$Partfile",$Part->{'run_path_pe'}."/bkp/$file.$date.bkp");
  &Csgrouper::says($subname,"Part file backed up.");
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END menu_about().

=item * menu_clear() : clears Output text widget.
=cut

sub menu_clear {
  my $subname = 'menu_clear';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  $Output_tw->Contents('');
  &Csgrouper::says($subname,"Outpur cleared.");
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END menu_copy().

=item * menu_copy() : not doing much yet.
=cut

sub menu_copy {
  my $subname = 'menu_copy';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
 	&Csgrouper::says($subname,"copy");
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END menu_copy().

=item * menu_cut() : not doing much yet.
=cut

sub menu_cut {
  my $subname = 'menu_cut';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END menu_cut().

=item * menu_quit() : quits.
=cut

sub menu_quit {
  my $subname = 'menu_quit';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  &csd_empty();
  &part_save();
  $Csgrouper::DEBFLAG =  $oldebflag;
  exit;
} ## END menu_quit().

=item * menu_man() : raises manual tab.
=cut

sub menu_man {
  my $subname = 'menu_man';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  $Book->raise("Man");
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END menu_man().

=item * menu_new() : not doing much yet.
=cut

sub menu_new {
  my $subname = 'menu_new';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $d = $mw->Dialog(-title => "Alert", -text => "Should this part be saved before opening new file?", -buttons => ["Yes", "No"]);
  if ($d->Show =~ /Yes/) {
		&Csgrouper::Describe($subname, "Saving present part file", 1);
		&part_save();
		&Csgrouper::says($subname,"Project saved.");
  }
  my $fs = $mw->FileSelect(-directory => $Part->{'part_path_pe'});
  my $newfile = $fs->Show;
  &Csgrouper::says($subname, $newfile);
  my $test = -1;
  $test = &part_default($newfile);
  &Csgrouper::says($subname, $test);
	if ($test != -1){
		my $pid=fork();
		die "Cannot fork: $!" if (! defined $pid);
		$newfile = $test;
		if (! $pid) {
			exec("/usr/bin/xterm", "-e", "$0 $newfile");
		}
  }
  else{
		&Csgrouper::Describe($subname, "Can't create file $newfile", 1);
	}
  $Csgrouper::DEBFLAG =  $oldebflag;
	return $test;
} ## END menu_new().

=item * menu_open() : not doing much yet.
=cut

sub menu_open {
  my $subname = 'menu_open';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $d = $mw->Dialog(-title => "Alert", -text => "Should this part be saved before opening new file?", -buttons => ["Yes", "No"]);
  if ($d->Show =~ /Yes/) {
		&Csgrouper::Describe($subname, "Saving present part file", 1);
		&part_save();
		&Csgrouper::says($subname,"Project saved.");
  }
  my $fs = $mw->FileSelect(-directory => $Part->{'part_path_pe'});
  my $newfile = $fs->Show;
  &Csgrouper::says($subname, $newfile);
	my $pid=fork();
	die "Cannot fork: $!" if (! defined $pid);
	if (! $pid) {
		exec("/usr/bin/xterm", "-e","$0 $newfile");
	}
  return 1;
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END menu_open().

=item * menu_paste() : not doing much yet.
=cut

sub menu_paste {
  my $subname = 'menu_paste';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END menu_paste().

=item * menu_sall() : not doing much yet.
=cut

sub menu_sall {
  my $subname = 'menu_sall';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END menu_sall().

=item * menu_sas() : saves part file as new file.
=cut

sub menu_sas {
  my $subname = 'menu_sas';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $date = &Csgrouper::Datem('n');
	system("cp","$Partfile", $Part->{'part_path_pe'}."/\.tmp");
	&Csgrouper::says($subname,"Old part file saved as temporary file.");
  &part_save();
  my $newfile = $mw->getSaveFile(-title => "Save part $Partfile as:", -initialdir => $Part->{'part_path_pe'}, -initialfile => $Partfile);
  &Csgrouper::says($subname, "$newfile");
  if ($newfile =~ /.+/) {
  	system("cp","$Partfile","$newfile");
  	&Csgrouper::says($subname,"Part file saved as $newfile.");
  }
  else { &Csgrouper::says($subname,"Saving aborted.") }
	system("cp", $Part->{'part_path_pe'}."/\.tmp", $Partfile );
	&Csgrouper::says($subname,"Old temporary file reopened as part file.");
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END menu_sas().

=item * menu_save() : saves whole project.
=cut

sub menu_save {
  my $subname = 'menu_save';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  &part_save();
  &Csgrouper::says($subname,"Project saved.");
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END menu_save().

=item * menu_setup() : raises setup tab.
=cut

sub menu_setup {
  my $subname = 'menu_setup';
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  $Book->pageconfigure("Setup", -state=> 'normal');
  # Explanation: the NoteBook method creates Frame objects that 
  # can be modified and enquired by the configure and cget methods.
  # $mw->messageBox(-message=>"setup");
  $Book->raise("Setup");
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END menu_setup().

=item * notes_sas() : saves notes as.
=cut

sub notes_sas {
  my $subname = "notes_sas";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 0;
  my $txt = $Notes_tw->Contents();
  my $file = &Csgrouper::Datem('n'); $file = "notes.$file.csd";
  my $newfile = $mw->getSaveFile(-title => "Save notes as:", -initialdir => $Part->{'run_path_pe'}."/bkp", -initialfile => $file);
  &Csgrouper::says($subname, $newfile);
  if ($newfile =~ /.+/) {
	open (FH, "> $newfile") or  die "Can't w-open $newfile: $!";
	  print FH $txt;
	close FH;
	&Csgrouper::says($subname,"Notes saved as $newfile.");
  }
  else { &Csgrouper::says($subname,"Saving aborted.") }
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END notes_sas.

=item * part_default() : creates a default part file.
=cut

sub part_default {
	my ($filename) = @_;
	$filename //= $Csgdef;
	$filename =~ s/([^.]+)(\.?.*)/$1/; ## Suppress previous suffixe.
	$filename .= ".xml"; ## Recreate it..
  my $subname = 'part_default';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  &Csgrouper::says($subname, "Creating file $filename..");
  open (FH, "> $filename") or  die "Can't w-open $filename: $!";
	print FH "<opt>\n"; ## The normal XML way of beggining.
	print FH "<csg_key>$Date</csg_key>\n"; ## The mandatory pair.
	print FH "</opt>\n";
  close FH;
  return $filename;
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END part_default().

=item * part_save() : record process step 3 (final): writes $Part to file.
=cut

sub part_save { 
  my $subname = 'part_save';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  #  $Csgrouper::DEBFLAG = 1;
  $Part->{'saved'} = &Csgrouper::Datem();
  &Csgrouper::says($subname, "Saving part file '".$Part->{csg_part}."' to $Partfile ..(".&Csgrouper::Datem().").");
  &setup_save(); ## Keep last preferences..
  &record('all');
  open (FH, "> $Partfile") or  die "Can't w-open $Partfile: $!";
	## SuppressEmpty => undef: in order to prevent XML to put an empty hash value in place of empty values.
	## Empty hash values (e.g. HASH(0x001C), containing parentheses, cannont be treated by valid_entry().
	my $text = XMLout($Part,AttrIndent => 1, NoIndent => 0, NoAttr => 1, SuppressEmpty => undef);
	$text =~ s/\s+\<\//\<\//g; ## Erase those empty lines put at the end of xml text containers!
	print FH $text;
  close FH;
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END part_save().

=item * part_reset() : resets $CSG defaults.
=cut

sub part_reset { 
  my $subname = 'part_reset';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $d = $mw->Dialog(-title => "Alert", -text => "Really reset these values to their Csg defaults ?", -buttons => ["Reset", "Cancel"]);
  if ($d->Show !~ /Reset/) {
	&Csgrouper::Debug($subname, "Reset aborted", 1) ;
	$Csgrouper::DEBFLAG =  $oldebflag;
	return 0;
  }
  &Resetall('reset');
  &pref_load;
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END part_save().


=item * pref_load() : load process step 2.b (from reload()): recreate the widgets states.
=cut

sub pref_load { ## See also : setup_save().
  my $pref = 0; 
  my $subname = "pref_load";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  ## Normal cases: We dont reload entries already mapped to variables like $part_title_le.
  ## Special cases (e.g. $variables as direct content for cb and labels):
  ## ### Other Prefs Tab:
  if (exists $Part->{'savenotes_enabled_cb'}) { 
	&Csgrouper::Debug($subname, $Part->{'savenotes_enabled_cb'});
	$notes_state = $Part->{'savenotes_enabled_cb'};
  } 
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END pref_load().

=item * refer() : record process step 1: create a $Part hash for the object.
=cut

sub refer { 
  my ($spell,$type,$ref) = @_;
  my $subname = 'refer';
  ## { no warnings; &Csgrouper::says($subname, "@_"); } ## Uncomment to debug.
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  $spell =~ s/([\$\%\@\ \t]+)(.+)(\s+)$/$2/;
  my $key = '-'.$spell;
  &Csgrouper::Debug($subname, "refer: $key");
  ## Let's store a reference to it in order to refresh the file contents:
  $Part->{$key} = {}; ## An anonymous hashref not XML storable.
  $Part->{$key}->{'xmlkey'} = $spell; ## The xml container name: = $Part->{key}.
  $Part->{$key}->{'reftype'} = $type;
  $Part->{$key}->{'reference'} = $ref; ## A hashref.
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END refer().

=item * record() : record process step 2: treats each type of $Part objects and records data into the storable var $Part.
=cut

sub record {  
  my ($target) = @_;
  my $subname = 'record';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  $target = 'all' if ($target !~/.+/);
  while (my ($key,$val) = each %{$Part}) {
		next if (($target !~ /^(all)$/) && ($target !~ /^($key)$/));
		next if ($key !~ /^(-.+)$/); ## Beggin the ref by a minus sign not stored by XML::Simple.
		my $data = "";
		if (not exists $val->{'reference'}) { next } 
		else { ## 2 values are stored in $Part for each container: type + reference.
			&Csgrouper::Debug($subname, "old: '".$val->{'xmlkey'}."' type: ".$val->{'reftype'});
			if ($val->{'reftype'} =~ /^(Text)|(TextUndo)$/){ ## The Text containers:
				&Csgrouper::Debug($subname, "ref : ".$val->{'reference'});
				$data = ${$val->{'reference'}}->Contents(); 
				&Csgrouper::Debug($subname, "data: $data");
				$Part->{$val->{'xmlkey'}} = $data; 
			}
			elsif ($val->{'reftype'} =~ /^(Entry)|(LabEntry)|(PathEntry)$/){ ## The Text containers:
				&Csgrouper::Debug($subname, "ref : ".$val->{'reference'});
				$data = ${${$val->{'reference'}}->cget(-textvariable)}; 
				&Csgrouper::Debug($subname, "data : $data");
				$Part->{$val->{'xmlkey'}} = $data; 
			}
			elsif ($val->{'reftype'} =~ /^(Cbox)$/){ ## The Text containers:
				&Csgrouper::Debug($subname, "ref : ".$val->{'reference'});
				$data = ${${$val->{'reference'}}->cget(-variable)}; 
				&Csgrouper::Debug($subname, "data : $data");
				$Part->{$val->{'xmlkey'}} = $data; 
			}
			elsif ($val->{'reftype'} =~ /^(SeqTable)$/){ ## The Seq Table:
				&Csgrouper::Debug($subname, "ref : ".$val->{'reference'});
				&seq_save();
				# Here %{$CsgObj->sequences} contains all the precomputing for the part:
				while (my ($key2,$val2) = each %{$CsgObj->sequences}) {
					next if ($key2 =~ /^(Seq_\d+)$/);
					$Part->{$key2} = $val2;
					&Csgrouper::Debug($subname, "$key2 => $val2");
				}
			}
			elsif ($val->{'reftype'} =~ /^(InsTab)$/){ ## The Csgrouper::Instruments Tab:
				&Csgrouper::Debug($subname, "ref : ".$val->{'reference'});
				&ins_update();
				while (my ($key2,$val2) = each %{$CsgObj->instruments}) {
					$Part->{$key2} = $val2;
					&Csgrouper::Debug($subname, "$key2 => $val2");
				}
			}
			&Csgrouper::Debug($subname, "new: '".$Part->{$val->{'xmlkey'}});
		}
  } 
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END record().

=item * reload() : load process step 1: loads/refreshes globals ($Part/$Csgrouper::Sequences/$Csgrouper::Instruments) from file.
=cut

sub reload { 
  my ($mode) = @_;
  my $subname = 'reload';
  { no warnings; &Csgrouper::says($subname, "@_",1); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  $mode //= ""; #/
  # $Csgrouper::DEBFLAG = 1;
  ## SuppressEmpty => undef: in order to prevent XML to put an empty hash value in place of empty values.
  ## Empty hash values (e.g. HASH(0x001C), containing parentheses, cannont be treated by valid_entry().
  ## Hereafter mode init2 (loading of a new file during a session) is a special case of mode init.
  if ($mode =~ /init/) { $Part = XMLin($Partfile, SuppressEmpty => undef) } ## Only at init time otherwise the Referred -keys are suppressed.
  ## For all modes:
  while (my ($key,$val) = each %Csgrouper::CSG) { 
		if (!(defined($Part->{$key})) || $Part->{$key} !~ /.+/) { $Part->{$key} = $val }
  } 
  if ($mode =~ /init/) { ## The content windows aren't yet constructed:
		## File Check 1:
		if (&check_csgfile($Partfile)==0) {
			&Csgrouper::Debug($subname, "Not a valid file : $Partfile..", 1) ;
			## The default file must contain a valid csg_ structure (or at least the key csg_key):
			my $file1 = $Partfile; $file1 =~ s/^(.+\/)([^\/]+)$/$2/;
			my $file2 = $Csgdef; $file2 =~ s/^(.+\/)([^\/]+)$/$2/;
			&part_default if ($file1 == $file2);
			&Csgrouper::Debug($subname, "Falling back to default.", 1) ;
			$Partfile = $Csgdef;
		}
  }
  else { 
		## File Check 2:
		if (!(defined($Part->{'csg_key'}))) {
			&Csgrouper::Debug($subname, "Not a valid file : $Partfile..", 1) ;
			## The default file must contain a valid csg structure (or at least the key csg_key):
			&Csgrouper::Error($subname, "Aborting") if ($Partfile =~ /^($Csgdef)$/);
			&Csgrouper::Debug($subname, "Falling back to default.", 1) ;
			$Partfile = $Csgdef;
		}
		&seq_load(); ## LOAD SEQUENCES FROM Part FILE.
		&ins_load(); ## LOAD INSTRUMENTS FROM Part FILE.
		&pref_load();	
		&Csgrouper::Debug($subname, "Loading part file..");
		$Notes_tw->Contents($Part->{'Notes_tw'}) ;
		## Load default values when necessary:
		while (my ($key,$val) = each %Csgrouper::CSG) {
			&Csgrouper::Debug($subname, "$key ===> $val");
			if (defined $Part->{$key} && $Part->{$key} !~ /.+/) {
			$Part->{$key} = $Csgrouper::CSG{$key};
			}
		}
		## XXX WARNING : if this log isn't recorded at init time a call to reload() is missing somewhere:
		&Csgrouper::says($subname,"Loaded part, connection and files for '$Partfile'.");
  } ## END else mode is not init.
  ## Both modes:
  &Csgrouper::Debug($subname, "mode: $mode");
  ## Params Not (toomuch) User-Configurable:
  ## Failsafe:
  if (!(-d $Part->{'part_path_pe'}) || !(&check_wdir($Part->{'part_path_pe'})==0)) { $Part->{'part_path_pe'} = $Csgrouper::CSG{'part_path_pe'} }
  if (!(-d $Part->{'run_path_pe'} ) || !(&check_wdir($Part->{'run_path_pe'})==0)) { $Part->{'run_path_pe'} = $Csgrouper::CSG{'run_path_pe'} }
  if (!(-d $Part->{'ins_path_pe'} ) || !(&check_wdir($Part->{'ins_path_pe'})==0)) { $Part->{'ins_path_pe'} = $Csgrouper::CSG{'ins_path_pe'} }
  if (!(-d $Part->{'csg_path_pe'} ) || !(&check_wdir($Part->{'csg_path_pe'})==0)) { $Part->{'csg_path_pe'} = $Csgrouper::CSG{'csg_path_pe'} }

  if (!($Part->{'db_name_le'} =~/.+/)) { $Part->{'db_name_le'} = $Csgrouper::CSG{'db_name_le'} }
  if (!($Part->{'db_user_le'} =~/.+/)) { $Part->{'db_user_le'} = $Csgrouper::CSG{'db_user_le'} }
  if (!($Part->{'db_password_le'} =~/.+/)) { $Part->{'db_password_le'} = $Csgrouper::CSG{'db_password_le'} }

  $Part->{'csg_part'} = $Partfile;
  &Csgrouper::Debug($subname, "Loaded part '$Partfile'");
  $Csgrouper::DEBFLAG =  $oldebflag;
  return 1;
} ## END reload().


  
=item * seq_add() : adds a new Tk row to the main sequences table.
=cut

sub seq_add {
  my @vals = @_;
  my $subname = "seq_add";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my $len = $Seq_tblw->totalRows;
  my $pref = "Tkrow_$len"; 
  my @params;
  die ("Not a valid table ($pref).") if ($len == 0);
  die ("Too many sequences ($len).") if ($len > MAXOBJ); ## We only have 576 sequence variables.
  my ($basebw, $base2bw, $idbw, $id2bw, $rowbw, $row2bw, $selcbw, $sel2cbw, $tmp);
  
  ## XXX WARNING: in some cases (marked with [***] hereafter) 
  ## the table menu objects should remain before the $vals[n] statements,
  ## otherwise  $CsgObj->sequences->{$pref.'_xxx'} are overwritten.

  ## ### TKTABLE:

	## To impede undefined warnings: $vals[$n] = "" unless defined $vals[$n]; or:
  for (my $n = 0; $n < scalar(@vals); $n++) { $vals[$n] //= "" } ## Modern Perl.
	&Csgrouper::Debug($subname, "vals @vals");

  ## 0 selbtn:
  $CsgObj->sequences->{$pref.'_sel'} = $vals[0] ;
  if ($vals[0] !~ /.+/) { $CsgObj->sequences->{$pref.'_sel'} = 1 }
  $selcbw = $Seq_tblw->Checkbutton(
		-variable =>\$CsgObj->sequences->{$pref.'_sel'}
		,-relief =>'ridge'
		,-onvalue=>1
		,-offvalue=>0
		,-state =>'normal'
		,-foreground =>$COLOR{'cbox_fgcolor'}
		,-background =>$COLOR{'cbox_bgcolor'}
		,-disabledforeground=>$COLOR{'cbox_disfgcolor'}
		,-command =>sub {&seq_proc($pref)}
 ); ## Note that the 'update' keyword is not passed to seq_proc() here.
   $sel2cbw = $Seq_tblw->Checkbutton(  ## For the other side of table row.
		-variable =>\$CsgObj->sequences->{$pref.'_sel'}
		,-relief =>'ridge'
		,-onvalue=>1
		,-offvalue=>0
		,-state =>'normal'
		,-foreground =>$COLOR{'cbox_fgcolor'}
		,-background =>$COLOR{'cbox_bgcolor'}
		,-disabledforeground=>$COLOR{'cbox_disfgcolor'}
		,-command =>sub {&seq_proc($pref)}
 ); ## Note that the 'update' keyword is not passed to seq_proc() here.
  $Seq_tblw->put($len, 0, $selcbw);
	## END selbtn.

	## 1 row label: not an @params slice nor a vals slice..(no need)
  $CsgObj->sequences->{$pref.'_ind'} = $len;
  $rowbw = $Seq_tblw->Label(
		-textvariable =>\$CsgObj->sequences->{$pref.'_ind'}
		,-background =>$COLOR{'cbox_bgcolor'}
		,-relief =>'ridge'
  );
  $row2bw = $Seq_tblw->Label( ## For the other side of table row.
  	-textvariable =>\$CsgObj->sequences->{$pref.'_ind'}
		,-background =>$COLOR{'cbox_bgcolor'}
		,-relief =>'ridge'
  );
  $Seq_tblw->put($len, 1, $rowbw);  
	## END row label.

  ## 2 varid btn: ### A sensible part:
  $CsgObj->sequences->{$pref.'_id'} = $vals[2] ;
  my $seqid = "Seq_".$vals[2];
  if ($vals[2] !~ /.+/) { ## Then a new sequence has to be attributed.
		for (my $i = 1; $i <= MAXOBJ; $i++){
			## XXX WARNING: $Sequence{"Seq_$i"} is NOT $CsgObj->sequences->{$pref.'_id'}!
			if (not exists $CsgObj->sequences->{"Seq_$i"}){
				$CsgObj->sequences->{$pref.'_id'} = $i ;
				$seqid = "Seq_$i";
				&Csgrouper::Debug($subname, $pref.'_id'."=$i");
				last;
			}
		}
  }
  ## Report this to Tkrowid in order to switch easily:
  $CsgObj->sequences->{"$seqid\_tid"} = $len;
  $idbw = $Seq_tblw->Button(
		-text =>$CsgObj->sequences->{$pref.'_id'}
		,-background =>$COLOR{'button_bgcolor'}
		,-foreground =>$COLOR{'button_fgcolor'}
		,-command =>sub {&seq_proc($pref,'update')}
  );
  $id2bw = $Seq_tblw->Button( ## For the other side of table row.
		-text =>$CsgObj->sequences->{$pref.'_id'}
		,-background =>$COLOR{'button_bgcolor'}
		,-foreground =>$COLOR{'button_fgcolor'}
		,-command =>sub {&seq_proc($pref,'update')}
  );
  $Seq_tblw->put($len, 2, $idbw);
  ## END varid.
  
	## 3 base label: not an @params slice nor a vals slice..(no need).
	## We want the serial base (from mode) indicated here:
  $CsgObj->sequences->{$pref.'_mode'} = $vals[23];
  if ($vals[23] !~ /.+/) { $CsgObj->sequences->{$pref.'_mode'} = $Csgrouper::CSG{'default_mode'} } 
  $CsgObj->sequences->{$pref.'_basis'} = length($CsgObj->sequences->{$pref.'_mode'});
		$CsgObj->sequences->{$pref.'_ind'} = $len;
		$basebw = $Seq_tblw->Label(
			-textvariable => \$CsgObj->sequences->{$pref.'_basis'}
			,-background =>$COLOR{'label_bgcolor'}
			,-relief =>'ridge'
		);
		$base2bw = $Seq_tblw->Label( ## For the other side of table row.
			-textvariable => \$CsgObj->sequences->{$pref.'_basis'}
			,-background =>$COLOR{'label_bgcolor'}
			,-relief =>'ridge'
		);
 $Seq_tblw->put($len, 3, $basebw);
	## END base label.

	## 4 name: orchestra name for the sequence (allegro? etc.).
  $CsgObj->sequences->{$pref.'_name'} = $vals[3] ;
  if ($vals[3] !~ /.+/) { $CsgObj->sequences->{$pref.'_name'} = 'seq name' }
  $Seq_tblw->put($len, 4, $Seq_tblw->Entry(
		-background =>$COLOR{'input_bgcolor'} 
		,-foreground =>$COLOR{'input_fgcolor'}
		,-width=>12
		,-textvariable=>\$CsgObj->sequences->{$pref.'_name'}
		,-validate => 'key'
		,-validatecommand => \sub{ &valid_entry($_[1],'text',$pref,1) } ## Don't unselect for such change..
		## Unfortunately valid_entry() will be called not only at key press
		## but also when the textvar is modified. To disable unwanted side-effects
		## like Sequence->ready state modification, we can use $STARTEXEC
		## locally in routines modifying this textvar.
		)
	);
	## END name.
	
	## 5 ins: instrument id.
  $CsgObj->sequences->{$pref.'_ins'} = $vals[4] ;
  if ($vals[4] !~ /i\d+.*/) { $CsgObj->sequences->{$pref.'_ins'} = 'i1' }
  $Seq_tblw->put($len, 5, $Seq_tblw->Entry(
			-background =>$COLOR{'input_bgcolor'}
			,-foreground =>$COLOR{'input_fgcolor'}
			,-width=>12
			,-textvariable=>\$CsgObj->sequences->{$pref.'_ins'}
			## Don't validate yet, we need freedom for param definitions:
			,-validate => 'key'
			,-validatecommand => sub{&valid_entry($_[1],'text',$pref)} 
		)
	);
	## END ins.
	
	## 6 n: numeric var.
  $CsgObj->sequences->{$pref.'_n'} = $vals[5];
  if ($vals[5] !~ /.+/) { $CsgObj->sequences->{$pref.'_n'} = '1' } 
  $Seq_tblw->put($len, 6, $Seq_tblw->Entry(
			-background =>$COLOR{'input_bgcolor'} 
			,-foreground =>$COLOR{'input_fgcolor'}
			,-width=>2
			,-textvariable=>\$CsgObj->sequences->{$pref.'_n'}
			,-validate => 'key'
			,-validatecommand => sub{&valid_entry($_[1],'float',$pref)} 
		)
	);
	## END n.
	
	## 7 x: numeric var.
  $CsgObj->sequences->{$pref.'_x'} = $vals[6];
  if ($vals[6] !~ /.+/) { $CsgObj->sequences->{$pref.'_x'} = '0' } 
  $Seq_tblw->put($len, 7, $Seq_tblw->Entry(
			-background =>$COLOR{'input_bgcolor'} 
			,-foreground =>$COLOR{'input_fgcolor'}
			,-width=>2
			,-textvariable=>\$CsgObj->sequences->{$pref.'_x'}
			,-validate => 'key'
			,-validatecommand => sub{ &valid_entry($_[1],'float',$pref) } 
		)
	);
	## END x.
	
	## 8 y: numeric var.
  $CsgObj->sequences->{$pref.'_y'} = $vals[7];
  if ($vals[7] !~ /.+/) { $CsgObj->sequences->{$pref.'_y'} = '0' } 
  $Seq_tblw->put($len, 8, $Seq_tblw->Entry(
			-background =>$COLOR{'input_bgcolor'} 
			,-foreground =>$COLOR{'input_fgcolor'}
			,-width=>2
			,-textvariable=>\$CsgObj->sequences->{$pref.'_y'}
			,-validate => 'key'
			,-validatecommand => sub{&valid_entry($_[1],'float',$pref)} 
		)
	);
	## END y.
	
	## 9 z: numeric var.
  $CsgObj->sequences->{$pref.'_z'} = $vals[8];
  if ($vals[8] !~ /.+/) { $CsgObj->sequences->{$pref.'_z'} = '0' } 
  $Seq_tblw->put($len, 9, $Seq_tblw->Entry(
			-background =>$COLOR{'input_bgcolor'} 
			,-foreground =>$COLOR{'input_fgcolor'}
			,-width=>2
			,-textvariable=>\$CsgObj->sequences->{$pref.'_z'}
			,-validate => 'key'
			,-validatecommand => sub{&valid_entry($_[1],'float',$pref)} 
		)
	);
	## END z.

	## 10 sets:  the post treatments sets.
  $CsgObj->sequences->{$pref.'_sets'} = $vals[9];
  if ($vals[9] !~ /.+/) { $CsgObj->sequences->{$pref.'_sets'} = '1' } 
  $Seq_tblw->put($len, 10, $Seq_tblw->Entry(
			-background =>$COLOR{'set_bgcolor'} 
			,-foreground =>$COLOR{'set_fgcolor'}
			,-width=>3
			,-textvariable=>\$CsgObj->sequences->{$pref.'_sets'}
			,-state => 'normal'
			,-validate => 'key'
			,-validatecommand => sub{&valid_entry($_[1],'digicom',$pref)} 
		)
	);
	## END sets.
	
	## 11 pre: the preceding sequence.
  $CsgObj->sequences->{$pref.'_pre'} = $vals[10];
  if ($vals[10] !~ /.+/) { $CsgObj->sequences->{$pref.'_pre'} = $CsgObj->sequences->{$pref.'_id'} } 
  $Seq_tblw->put($len, 11, $Seq_tblw->Entry(
			-background =>$COLOR{'button_bgcolor'}
			,-foreground =>$COLOR{'button_fgcolor'}
			,-width=>3
			,-textvariable=>\$CsgObj->sequences->{$pref.'_pre'}
			,-state => 'normal'
			,-validate => 'key'
			,-validatecommand => sub{ &valid_entry($_[1],'digit',$pref) } 
		)
	);
	## END pre.
	
	## 12 rep: 1 rep = twice the suite.
  $CsgObj->sequences->{$pref.'_rep'} = $vals[11];
  if ($vals[11] !~ /.+/) { $CsgObj->sequences->{$pref.'_rep'} = '0' } 
  $Seq_tblw->put($len, 12, $Seq_tblw->Entry(
			-background =>$COLOR{'input_bgcolor'} 
			,-foreground =>$COLOR{'input_fgcolor'}
			,-width=>3
			,-textvariable=>\$CsgObj->sequences->{$pref.'_rep'}
			,-state => 'normal'
			,-validate => 'key'
			,-validatecommand => sub { &valid_entry($_[1],'digit',$pref) }
		)
	);
	## END rep.
	
	## 13 fun menu : ### [****]
  $tmp = $Seq_tblw->Optionmenu(
		 -options => &fun_menu('seq')
		,-background =>$COLOR{'input_bgcolor'} 
		,-foreground =>$COLOR{'input_fgcolor'}
		,-variable =>\$CsgObj->sequences->{$pref.'_fun'}
		,-textvariable =>\$CsgObj->sequences->{$pref.'_funt'} 
		,-command=> sub { &valid_entry(0,'unset',$pref) }
  );
  $Seq_tblw->put($len, 13, $tmp);
	## END fun menu.
	
	## 13b funt:
  $CsgObj->sequences->{$pref.'_funt'} = $vals[12];
  if ($vals[12] !~ /.+/) { $CsgObj->sequences->{$pref.'_funt'} = $Csgrouper::Types::Funx{Suite}{menutext} } 
	## END funt.
	## 13c fun:
  $CsgObj->sequences->{$pref.'_fun'} = $vals[26]; ## Added at the end of the values array..
  if ($vals[26] !~ /.+/) { $CsgObj->sequences->{$pref.'_fun'} = 'Suite' } ## The most basic function.
	## END fun.
	
	## 14 exp: needed to expand the results in Supergrad and Powerp for instance.
  $CsgObj->sequences->{$pref.'_exp'} = $vals[13];
  if ($vals[13] !~ /.+/) { $CsgObj->sequences->{$pref.'_exp'} = '0' } 
  $tmp = $Seq_tblw->Checkbutton(
		-variable =>\$CsgObj->sequences->{$pref.'_exp'}
		,-relief =>'ridge'
		,-onvalue=>1
		,-offvalue=>0
		,-background =>$COLOR{'cbox_bgcolor'}
		,-foreground =>$COLOR{'cbox_fgcolor'}
		,-command=> sub {  &valid_entry(0,'unset',$pref) }
  );
  $Seq_tblw->put($len, 14, $tmp);
	## END exp.
	
	## 15 modo: (not in use yet).
  $CsgObj->sequences->{$pref.'_modo'} = $vals[14];
  if ($vals[14] !~ /.+/) { $CsgObj->sequences->{$pref.'_modo'} = '0' } 
  $tmp = $Seq_tblw->Checkbutton(
		-variable =>\$CsgObj->sequences->{$pref.'_modo'}
		,-relief =>'ridge'
		,-onvalue=>1
		,-offvalue=>0
		,-background =>$COLOR{'cbox_bgcolor'}
		,-foreground =>$COLOR{'cbox_fgcolor'}
		,-command=> sub {  &valid_entry(0,'unset',$pref) }
  );
  $Seq_tblw->put($len,15, $tmp); 
	## END modo.
	
	## 16 A:
  $CsgObj->sequences->{$pref.'_A'} = $vals[15];
  if ($vals[15] !~ /.+/) { $CsgObj->sequences->{$pref.'_A'} = $Csgrouper::CSG{'default_mode'} } 
  $Seq_tblw->put($len, 16, $Seq_tblw->Entry(
			-background =>$COLOR{'input_bgcolor'} 
			,-foreground =>$COLOR{'input_fgcolor'}
			,-width=>25
			,-textvariable=>\$CsgObj->sequences->{$pref.'_A'}
			,-state => 'normal'
			,-validate => 'key'
			,-validatecommand => sub { &valid_entry($_[1],'xphonic',$pref) } 
		)
	);

	## END A.
	
	## 17 Aoct:
  $CsgObj->sequences->{$pref.'_Aoct'} = $vals[16];
  if ($vals[16] !~ /.+/) { $CsgObj->sequences->{$pref.'_Aoct'} = $Csgrouper::CSG{'part_octs_le'} }  
  $Seq_tblw->put($len, 17, $Seq_tblw->Entry(
			-background =>$COLOR{'input_bgcolor'} 
			,-foreground =>$COLOR{'input_fgcolor'}
			, -width=>25
			,-textvariable=>\$CsgObj->sequences->{$pref.'_Aoct'}
			,-state => 'normal'
			,-validate => 'key'
			,-validatecommand => sub { &valid_entry($_[1],'xphonic',$pref) } 
		)
	);
	## END Aoct.
	
	## 18 Aroc:
  $CsgObj->sequences->{$pref.'_Aroc'} = $vals[17];
  if ($vals[17] !~ /.+/) { $CsgObj->sequences->{$pref.'_Aroc'} = 0 }  
  $tmp = $Seq_tblw->Checkbutton(
		-variable =>\$CsgObj->sequences->{$pref.'_Aroc'}
		,-relief =>'ridge'
		,-onvalue=>1
		,-offvalue=>0
		,-background =>$COLOR{'cbox_bgcolor'}
		,-foreground =>$COLOR{'cbox_fgcolor'}
		,-command=> sub { &valid_entry(0,'unset',$pref) }
  );
  $Seq_tblw->put($len, 18, $tmp);
	## END Aroc.
	
	## 19 B:
  $CsgObj->sequences->{$pref.'_B'} = $vals[18];
  if ($vals[18] !~ /.+/) { $CsgObj->sequences->{$pref.'_B'} = $Csgrouper::CSG{'default_mode'} }   
  $Seq_tblw->put($len, 19, $Seq_tblw->Entry(
			-background =>$COLOR{'input_bgcolor'} 
			,-foreground =>$COLOR{'input_fgcolor'}
			,-width=>25
			,-textvariable=>\$CsgObj->sequences->{$pref.'_B'}
			,-state => 'normal'
			,-validate => 'key'
			,-validatecommand => sub { &valid_entry($_[1],'xphonic',$pref) } 
		)
	);
	## END B.
	
	## 20 Boct:
  $CsgObj->sequences->{$pref.'_Boct'} = $vals[19];
  if ($vals[19] !~ /.+/) { $CsgObj->sequences->{$pref.'_Boct'} = $Csgrouper::CSG{'part_octs_le'} }  
  $Seq_tblw->put($len, 20, $Seq_tblw->Entry(
			-background =>$COLOR{'input_bgcolor'} 
			,-foreground =>$COLOR{'input_fgcolor'}
			,-width=>25
			,-textvariable=>\$CsgObj->sequences->{$pref.'_Boct'}
			,-state => 'normal'
			,-validate => 'key'
			,-validatecommand => sub{&valid_entry($_[1],'xphonic',$pref)} 
		)
	);
	## END Boct.
	
	## 21 Broc:
  $CsgObj->sequences->{$pref.'_Broc'} = $vals[20];
  if ($vals[20] !~ /.+/) { $CsgObj->sequences->{$pref.'_Broc'} = 0 }  
  $tmp = $Seq_tblw->Checkbutton(
		-variable =>\$CsgObj->sequences->{$pref.'_Broc'}
		,-relief =>'ridge'
		,-onvalue=>1
		,-offvalue=>0
		,-background =>$COLOR{'cbox_bgcolor'}
		,-foreground =>$COLOR{'cbox_fgcolor'}
		,-command=> sub { &valid_entry(0,'unset',$pref) }
  );
  $Seq_tblw->put($len, 21, $tmp); 
	## END Broc.
	
	## 22 ord: needed to choose a modif. order in trains.
  $CsgObj->sequences->{$pref.'_ord'} = $vals[21];
  if ($vals[21] !~ /.+/) { $CsgObj->sequences->{$pref.'_ord'} = $Csgrouper::CSG{'ord_series_le'} } 
  $Seq_tblw->put($len, 22, $Seq_tblw->Entry(
			-background =>$COLOR{'input_bgcolor'} 
			,-foreground =>$COLOR{'input_fgcolor'}
			,-width=>25
			,-textvariable=>\$CsgObj->sequences->{$pref.'_ord'}
			,-state => 'normal'
			,-validate => 'key'
			,-validatecommand => sub{&valid_entry($_[1],'xphonic',$pref)} 
		)
	);
	## END ord.
	
	## 23 sign: needed by trains - could serve other purposes in new funcs.
  $CsgObj->sequences->{$pref.'_sign'} = $vals[22];
  if ($vals[22] !~ /.+/) { $CsgObj->sequences->{$pref.'_sign'} = $Csgrouper::CSG{'part_signs_le'} }  
  $Seq_tblw->put($len, 23, $Seq_tblw->Entry(
			-background =>$COLOR{'input_bgcolor'} 
			,-foreground =>$COLOR{'input_fgcolor'}
			,-width=>25
			,-textvariable=>\$CsgObj->sequences->{$pref.'_sign'}
			,-state => 'normal'
			,-validate => 'key'
			,-validatecommand => sub{&valid_entry($_[1],'plusalnumin',$pref)} 
		)
	);
	## END sign.
	
	## 24 vals23 : mode: needed by every sequence.
	## Loading of this var already done; see above col 1.
  $Seq_tblw->put($len, 24, $Seq_tblw->Entry(
			-background =>$COLOR{'label_bgcolor'} 
			,-foreground =>$COLOR{'input_fgcolor'}
			,-width=>25
			,-textvariable=>\$CsgObj->sequences->{$pref.'_mode'}
			,-state => 'normal'
			,-validate => 'key'
			,-validatecommand => sub{ &valid_entry($_[1],'xphonic',$pref) }
		)
	);
	## END mode.
	
	## 25 tone: needed by every sequence.
  $CsgObj->sequences->{$pref.'_tone'} = $vals[24];
  if ($vals[24] !~ /.+/) { $CsgObj->sequences->{$pref.'_tone'} = 0 }  
  $Seq_tblw->put($len, 25, $Seq_tblw->Entry(
			-background =>$COLOR{'label_bgcolor'} 
			,-foreground =>$COLOR{'input_fgcolor'}
			,-width=>2
			,-textvariable=>\$CsgObj->sequences->{$pref.'_tone'}
			,-state => 'normal'
			,-validate => 'key'
			,-validatecommand => sub{&valid_entry($_[1],'xphonic',$pref)} 
		)
	);
	## END mode.
	
	## 26 com: a place to comment on the sequence.
  $CsgObj->sequences->{$pref.'_com'} = $vals[25];
  if ($vals[25] !~ /.+/) { $CsgObj->sequences->{$pref.'_com'} = $Csgrouper::CSG{'part_com_le'} }  
  $Seq_tblw->put($len, 26, $Seq_tblw->Entry(
			-background =>$COLOR{'input_bgcolor'} 
			,-foreground =>$COLOR{'input_fgcolor'}
			,-width=>25
			,-textvariable=>\$CsgObj->sequences->{$pref.'_com'}
			,-state => 'normal'
			,-validate => 'key'
			,-validatecommand => sub{ &valid_entry($_[1],'text',$pref,1) } ## Don't unselect for such change..
		)
	);
	## END com.
	
	## 26: base label (2):
  $Seq_tblw->put($len, 27, $base2bw);  ## Repeated for convenience.
	## END selbtn.
	
	## 27: selbtn (2):
  $Seq_tblw->put($len, 28, $id2bw);  ## Repeated for convenience.
	## END selbtn.
	
	## 28: rowlabel (2):
  $Seq_tblw->put($len, 29, $row2bw);  ## Repeated for convenience.
	## END rowlabel.
	## 29: sel (2):
  $Seq_tblw->put($len, 30, $sel2cbw);  ## Repeated for convenience.
	## END sel.
	## END TKTABLE.
	## Do what has to be done with these data, depending on $pref.'_sel':
	&seq_obj($pref);
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END seq_add().

=item * seq_del() : deletes rows from the main sequences table.
=cut

sub seq_del {
  my $subname = "seq_del";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my $pref = 0; 
  ## We are going to keep the hash values but delete and rewrite the old $Sequence pairs when present.
  my $table = $Tabs{'part'}->Table(
		-rows => 20
		,-columns => 30
		,-relief=>'raised'
		,-scrollbars => 's' 
		,-fixedrows => 1
		,-fixedcolumns => 0
		,-takefocus => 'on'
  );
  my $row = 0;
  &seq_header(\$table); ## Create the header row.
  my (@rows,$rows);
  for (my $i = 1; $i < MAXOBJ; $i++){ 
		$pref = "Tkrow_$i"; 
		next if (!(defined $CsgObj->sequences->{"$pref\_ind"}));
		next if ($CsgObj->sequences->{"$pref\_ind"} !~ /\d+/);
		$rows .= "$i," if ($CsgObj->sequences->{"$pref\_sel"} == 1);
  }
  $rows =~s/^(.*)(,)$/$1/;
  my $d = $mw->Dialog(-title => "Alert", -text => "Really delete rows ($rows) ?", -buttons => ["Delete", "Cancel"]);
  if ($d->Show !~ /Delete/) {
		&Csgrouper::Debug($subname, "Deletion aborted", 1) ;
		goto SEQ_DEL_END;
  }
  for (my $i = 1; $i < MAXOBJ; $i++){ 
		$pref = "Tkrow_$i"; 
		next if (!(defined $CsgObj->sequences->{"$pref\_id"}));
		my $id = "Seq_".$CsgObj->sequences->{"$pref\_id"};
		delete $CsgObj->sequences->{"Seq\_$id\_tid"}; ## Delete for both selected and copied rows.
		if ($CsgObj->sequences->{"$pref\_sel"} == 1) { ## Don't copy selected rows.
			delete $CsgObj->sequences->{$id}; ## Delete the Csg object reference. KEEP IT UP!
			delete $CsgObj->sequences->{"$pref\_sel"}; delete $Part->{"$pref\_sel"};
			delete $CsgObj->sequences->{$pref.'_ind'}; delete $Part->{$pref.'_ind'};
			## The Csg::Sequence object is $CsgObj->sequences->{'Seq_'.$CsgObj->sequences->{$pref.'_id'}};
			&Csgrouper::Debug($subname, $CsgObj->sequences->{$pref.'_id'}.": ".$CsgObj->sequences->{'Seq_'.$CsgObj->sequences->{$pref.'_id'}});
			delete $CsgObj->sequences->{$pref.'_id'}; delete $Part->{$pref.'_id'};
			delete $CsgObj->sequences->{$pref.'_name'}; delete $Part->{$pref.'_name'};
			delete $CsgObj->sequences->{$pref.'_ins'}; delete $Part->{$pref.'_ins'};
			delete $CsgObj->sequences->{$pref.'_n'}; delete $Part->{$pref.'_n'};
			delete $CsgObj->sequences->{$pref.'_x'}; delete $Part->{$pref.'_x'};
			delete $CsgObj->sequences->{$pref.'_y'}; delete $Part->{$pref.'_y'};
			delete $CsgObj->sequences->{$pref.'_z'}; delete $Part->{$pref.'_z'};
			delete $CsgObj->sequences->{$pref.'_sets'}; delete $Part->{$pref.'_sets'};
			delete $CsgObj->sequences->{$pref.'_pre'}; delete $Part->{$pref.'_pre'};
			delete $CsgObj->sequences->{$pref.'_rep'}; delete $Part->{$pref.'_rep'};
			delete $CsgObj->sequences->{"$pref\_funt"}; delete $Part->{"$pref\_funt"};
			delete $CsgObj->sequences->{"$pref\_fun"}; delete $Part->{"$pref\_fun"};
			delete $CsgObj->sequences->{"$pref\_exp"}; delete $Part->{"$pref\_exp"};
			delete $CsgObj->sequences->{"$pref\_modo"}; delete $Part->{"$pref\_modo"};
			delete $CsgObj->sequences->{$pref.'_A'}; delete $Part->{$pref.'_A'};
			delete $CsgObj->sequences->{$pref.'_Aoct'}; delete $Part->{$pref.'_Aoct'};
			delete $CsgObj->sequences->{"$pref\_Aroc"};delete $Part->{"$pref\_Aroc"};
			delete $CsgObj->sequences->{$pref.'_B'}; delete $Part->{$pref.'_B'};
			delete $CsgObj->sequences->{$pref.'_Boct'};delete $Part->{$pref.'_Boct'};
			delete $CsgObj->sequences->{"$pref\_Broc"}; delete $Part->{"$pref\_Broc"};
			delete $CsgObj->sequences->{$pref.'_ord'}; delete $Part->{$pref.'_ord'};
			delete $CsgObj->sequences->{$pref.'_sign'}; delete $Part->{$pref.'_sign'};
			delete $CsgObj->sequences->{$pref.'_mode'}; delete $Part->{$pref.'_mode'};
			delete $CsgObj->sequences->{$pref.'_tone'}; delete $Part->{$pref.'_tone'};
			delete $CsgObj->sequences->{$pref.'_com'}; delete $Part->{$pref.'_com'};
			&Csgrouper::Describe($subname, "$id: deleted");
			next;
		}
		my @vals;
		$vals[0] = delete $CsgObj->sequences->{"$pref\_sel"}; delete $Part->{"$pref\_sel"};
		$vals[1] = delete $CsgObj->sequences->{$pref.'_ind'}; delete $Part->{$pref.'_ind'};
		$vals[2] = delete $CsgObj->sequences->{$pref.'_id'}; delete $Part->{$pref.'_id'};
		$vals[3] = delete $CsgObj->sequences->{$pref.'_name'}; delete $Part->{$pref.'_name'};
		$vals[4] = delete $CsgObj->sequences->{$pref.'_ins'}; delete $Part->{$pref.'_ins'};
		$vals[5] = delete $CsgObj->sequences->{$pref.'_n'}; delete $Part->{$pref.'_n'};
		$vals[6] = delete $CsgObj->sequences->{$pref.'_x'}; delete $Part->{$pref.'_x'};
		$vals[7] = delete $CsgObj->sequences->{$pref.'_y'}; delete $Part->{$pref.'_y'};
		$vals[8] = delete $CsgObj->sequences->{$pref.'_z'}; delete $Part->{$pref.'_z'};
		$vals[9] = delete $CsgObj->sequences->{$pref.'_sets'}; delete $Part->{$pref.'_sets'};
		$vals[10] = delete $CsgObj->sequences->{$pref.'_pre'}; delete $Part->{$pref.'_pre'};
		$vals[11] = delete $CsgObj->sequences->{$pref.'_rep'}; delete $Part->{$pref.'_rep'};
		$vals[12] = delete $CsgObj->sequences->{"$pref\_funt"}; delete $Part->{"$pref\_funt"};
		$vals[13] = delete $CsgObj->sequences->{"$pref\_exp"}; delete $Part->{"$pref\_exp"};
		$vals[14] = delete $CsgObj->sequences->{"$pref\_modo"}; delete $Part->{"$pref\_modo"};
		$vals[15] = delete $CsgObj->sequences->{$pref.'_A'}; delete $Part->{$pref.'_A'};
		$vals[16] = delete $CsgObj->sequences->{$pref.'_Aoct'}; delete $Part->{$pref.'_Aoct'};
		$vals[17] = delete $CsgObj->sequences->{"$pref\_Aroc"};delete $Part->{"$pref\_Aroc"};
		$vals[18] = delete $CsgObj->sequences->{$pref.'_B'}; delete $Part->{$pref.'_B'};
		$vals[19] = delete $CsgObj->sequences->{$pref.'_Boct'};delete $Part->{$pref.'_Boct'};
		$vals[20] = delete $CsgObj->sequences->{"$pref\_Broc"}; delete $Part->{"$pref\_Broc"};
		$vals[21] = delete $CsgObj->sequences->{$pref.'_ord'}; delete $Part->{$pref.'_ord'};
		$vals[22] = delete $CsgObj->sequences->{$pref.'_sign'}; delete $Part->{$pref.'_sign'};
		$vals[23] = delete $CsgObj->sequences->{$pref.'_mode'}; delete $Part->{$pref.'_mode'};
		$vals[24] = delete $CsgObj->sequences->{$pref.'_tone'}; delete $Part->{$pref.'_tone'};
		$vals[25] = delete $CsgObj->sequences->{$pref.'_com'}; delete $Part->{$pref.'_com'};
		$vals[26] = delete $CsgObj->sequences->{"$pref\_fun"}; delete $Part->{"$pref\_fun"};
		for (my $i = 0; $i < scalar(@vals); $i++) { chomp $vals[$i] }
		&Csgrouper::Debug($subname, "vals: @vals");
		push @rows, [@vals];
  } ## END for i.
  push @rows, [] if (scalar @rows == 0); ## No empty table.
  $Seq_tblw->clear;
  &seq_header;
  my $oldstartexec = $STARTEXEC;
  $STARTEXEC = 1;
  foreach (@rows) { 
		&Csgrouper::Debug($subname, "|==> @$_ <==|"); 
		&seq_add(@$_) 
	}
	$STARTEXEC = $oldstartexec;
  $Seq_tblw->form(-top=>[$Part_frame2,4], -left=>['%2',4], -right=>['%98',4]);
  SEQ_DEL_END:
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END seq_del().

=item * seq_header() : creates headers for the main sequences table.
=cut

sub seq_header {
  ## Create the header:
  my $subname = "seq_header";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  $Seq_tblw->put(0, 0, 'sel');
  $Seq_tblw->put(0, 1, 'row');
  $Seq_tblw->put(0, 2, 'id');
  $Seq_tblw->put(0, 3, 'base');
  $Seq_tblw->put(0, 4, 'name');
  $Seq_tblw->put(0, 5, 'ins'); 
  $Seq_tblw->put(0, 6, 'n'); 
  $Seq_tblw->put(0, 7, 'x'); 
  $Seq_tblw->put(0, 8, 'y'); 
  $Seq_tblw->put(0, 9, 'z'); 
  $Seq_tblw->put(0, 10, 'set'); 
  $Seq_tblw->put(0, 11, 'pre'); 
  $Seq_tblw->put(0, 12, 'rep'); 
  $Seq_tblw->put(0, 13, 'fun'); 
  $Seq_tblw->put(0, 14, 'exp');
  $Seq_tblw->put(0, 15, 'mod');
  $Seq_tblw->put(0, 16, 'A');  
  $Seq_tblw->put(0, 17, 'Aoct'); 
  $Seq_tblw->put(0, 18, 'ran');
  $Seq_tblw->put(0, 19, 'B'); 
  $Seq_tblw->put(0, 20, 'Boct'); 
  $Seq_tblw->put(0, 21, 'ran');
  $Seq_tblw->put(0, 22, 'ord'); 
  $Seq_tblw->put(0, 23, 'signs'); 
  $Seq_tblw->put(0, 24, 'mode'); 
  $Seq_tblw->put(0, 25, 'tone'); 
  $Seq_tblw->put(0, 26, 'comments'); 
  $Seq_tblw->put(0, 27, 'base'); 
  $Seq_tblw->put(0, 28, 'id'); 
  $Seq_tblw->put(0, 29, 'row'); 
  $Seq_tblw->put(0, 30, 'sel'); 
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END seq_header().

=item * seq_load() : load process step 2.b (from reload()): recreate the widgets.
=cut

sub seq_load {
  my $pref = 0; 
  my $subname = "seq_load";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my $row = 0;
  my @rows;
  { no strict 'refs'; no warnings;
	for (my $i = 1; $i <= MAXOBJ; $i++){ 
	  $pref = "Tkrow_$i"; 
	  next if (!(defined $Part->{$pref.'_id'}));
	  my $id = 'Seq_'.$Part->{$pref.'_id'};
	  &Csgrouper::Debug($subname, "$pref\_id: $id"); 
	  my @vals;
	  $vals[0] = $CsgObj->sequences->{"$pref\_sel"} = $Part->{"$pref\_sel"};
	  $vals[1] = $CsgObj->sequences->{$pref.'_ind'} = $Part->{$pref.'_ind'};
	  $vals[2] = $CsgObj->sequences->{$pref.'_id'} = $Part->{$pref.'_id'};
	  $vals[3] = $CsgObj->sequences->{$pref.'_name'} = $Part->{$pref.'_name'};
	  $vals[4] = $CsgObj->sequences->{$pref.'_ins'} = $Part->{$pref.'_ins'};
	  $vals[5] = $CsgObj->sequences->{$pref.'_n'} = $Part->{$pref.'_n'};
	  $vals[6] = $CsgObj->sequences->{$pref.'_x'} = $Part->{$pref.'_x'};
	  $vals[7] = $CsgObj->sequences->{$pref.'_y'} = $Part->{$pref.'_y'};
	  $vals[8] = $CsgObj->sequences->{$pref.'_z'} = $Part->{$pref.'_z'};
	  $vals[9] = $CsgObj->sequences->{$pref.'_sets'} = $Part->{$pref.'_sets'};
	  $vals[10] = $CsgObj->sequences->{$pref.'_pre'} = $Part->{$pref.'_pre'};
	  $vals[11] = $CsgObj->sequences->{$pref.'_rep'} = $Part->{$pref.'_rep'};
	  $vals[12] = $CsgObj->sequences->{"$pref\_funt"} = $Part->{"$pref\_funt"};
	  $vals[13] = $CsgObj->sequences->{"$pref\_exp"} = $Part->{"$pref\_exp"};
	  $vals[14] = $CsgObj->sequences->{"$pref\_modo"} = $Part->{"$pref\_modo"};
	  $vals[15] = $CsgObj->sequences->{$pref.'_A'} = $Part->{$pref.'_A'};
	  $vals[16] = $CsgObj->sequences->{$pref.'_Aoct'} = $Part->{$pref.'_Aoct'};
	  $vals[17] = $CsgObj->sequences->{"$pref\_Aroc"} = $Part->{"$pref\_Aroc"};
	  $vals[18] = $CsgObj->sequences->{$pref.'_B'} = $Part->{$pref.'_B'};
	  $vals[19] = $CsgObj->sequences->{$pref.'_Boct'} = $Part->{$pref.'_Boct'};
	  $vals[20] = $CsgObj->sequences->{"$pref\_Broc"} = $Part->{"$pref\_Broc"};
	  $vals[21] = $CsgObj->sequences->{$pref.'_ord'} = $Part->{$pref.'_ord'};
	  $vals[22] = $CsgObj->sequences->{$pref.'_sign'} = $Part->{$pref.'_sign'};
	  $vals[23] = $CsgObj->sequences->{$pref.'_mode'} = $Part->{$pref.'_mode'};
	  $vals[24] = $CsgObj->sequences->{$pref.'_tone'} = $Part->{$pref.'_tone'};
	  $vals[25] = $CsgObj->sequences->{$pref.'_com'} = $Part->{$pref.'_com'};
	  $vals[26] = $CsgObj->sequences->{"$pref\_fun"} = $Part->{"$pref\_fun"};
	  for (my $i = 0; $i < scalar(@vals); $i++) { chomp $vals[$i] if (defined $vals[$i]) }
	  ## The Csgrouper::Sequence object: will be created by seq_add.
	  ## &Csgrouper::Debug($subname, "@vals");
	  push @rows, [@vals];
	}
	push @rows, [] if (scalar @rows == 0); ## No empty table.
	$Seq_tblw->clear;
	&seq_header;
	foreach (@rows) {
		&Csgrouper::Debug($subname, "|==> @$_ <==|"); 
		&seq_add(@$_) 
	}
	$Seq_tblw->form(-top=>[$Part_frame2,4], -left=>['%2',4], -right=>['%98',4]);
	$Csgrouper::DEBFLAG =  $oldebflag;
  } ## strict and warnings anew..
} ## END seq_load().	

=item * seq_obj() : recreates the Sequence object if tkrow is selected, otherwise delete it.
=cut

sub seq_obj { 
	my ($pref) = @_;
  my $subname = "seq_obj";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my $date = &Csgrouper::Datem('n');
	my @params;
	my $seqid = "Seq_".$CsgObj->sequences->{$pref.'_id'};
  push @params, 'sel'		=>$CsgObj->sequences->{$pref.'_sel'};
  push @params, 'sid'		=>$CsgObj->sequences->{$pref.'_id'}; ##  Was: "sid => $seqid" but why? ;
  push @params, 'name'	=>$CsgObj->sequences->{$pref.'_name'};
  push @params, 'ins'		=>$CsgObj->sequences->{$pref.'_ins'};
  push @params, 'n'			=>$CsgObj->sequences->{$pref.'_n'};
  push @params, 'x'			=>$CsgObj->sequences->{$pref.'_x'};
  push @params, 'y'			=>$CsgObj->sequences->{$pref.'_y'};
  push @params, 'z'			=>$CsgObj->sequences->{$pref.'_z'};
  push @params, 'sets'	=>$CsgObj->sequences->{$pref.'_sets'};
  push @params, 'pre'		=>$CsgObj->sequences->{$pref.'_pre'};
  push @params, 'rep'		=>$CsgObj->sequences->{$pref.'_rep'};
  push @params, 'funt'	=>$CsgObj->sequences->{$pref.'_funt'};
  push @params, 'fun'		=>$CsgObj->sequences->{$pref.'_fun'};
  push @params, 'exp'		=>$CsgObj->sequences->{$pref.'_exp'};
  push @params, 'modo'	=>$CsgObj->sequences->{$pref.'_modo'};
  push @params, 'A'			=>$CsgObj->sequences->{$pref.'_A'};
  push @params, 'Aoct'	=>$CsgObj->sequences->{$pref.'_Aoct'};
  push @params, 'Aroc'	=>$CsgObj->sequences->{$pref.'_Aroc'};
  push @params, 'B'			=>$CsgObj->sequences->{$pref.'_B'};
  push @params, 'Boct'	=>$CsgObj->sequences->{$pref.'_Boct'};
  push @params, 'Broc'	=>$CsgObj->sequences->{$pref.'_Broc'};
  push @params, 'ord'		=>$CsgObj->sequences->{$pref.'_ord'};
  push @params, 'sign'	=>$CsgObj->sequences->{$pref.'_sign'};
  push @params, 'mode'	=>$CsgObj->sequences->{$pref.'_mode'};
  push @params, 'tone'	=>$CsgObj->sequences->{$pref.'_tone'};
  push @params, 'com'		=>$CsgObj->sequences->{$pref.'_com'};
  push @params, 'cdat'	=>$date;
  push @params, 'mdat'	=>$date;
  push @params, 'tkrow'	=>$pref;
  push @params, 'seqid'	=>$seqid;
  push @params, 'paro'	=>$CsgObj;

  ## XXX NOTE: keep classes independant from interface! 
  ## Don't push @params, 'tkob'=>\%{$CsgObj->sequences}; 
  ## This would make a circular reference in part_save.

  ## Finally create the corresponding sequence object:
	&Csgrouper::Debug($subname, "$seqid params: @params");
	## This will delete any previous Sequence object:
  $CsgObj->sequences->{$seqid} = Csgrouper::Sequence->new(@params);
  ## XXX NOTE: A proof that Sequence object has been recorded 
  ## (otherwise: no seqobj value):
	&Csgrouper::Describe($subname, "$seqid before Build_tree: A: ".$CsgObj->sequences->{$seqid}->A." = seqobj: ".$CsgObj->sequences->{$seqid}->fun);

  ## The tree shall be built UNLESS :
  ## 		a) _sel is off; or 
  ## 		b) the time-related params are not valid (%SectionsH,  %SetsH , %TracksH).
  ## If Build_tree() fails, then the whole sequence will be destroyed (see below).

	$CsgObj->sequences->{$seqid}->Build_tree; 

  ## XXX NOTE: A proof that the tree object has been recorded:
  if (blessed($CsgObj->sequences->{$seqid}->tree)){
  	&Csgrouper::Describe($subname, "$seqid reporting changes to UI..");
  	## XXX NOTE on reporting changes from classes to UI:
  	## Here the possible changes are reported from classes into the UI containers.
  	## XXX NOTE on $STARTEXEC:
  	## valid_entry() has to be disabled by $STARTEXEC since the key validation
  	## applies also when changing the textvar of the entry... (this seems to be a bug).
  	my $oldstart = $STARTEXEC; $STARTEXEC = 1; ## Fake launch time.
  	while (my ($key,$val) = each %{$CsgObj->sequences->{$seqid}}) {
  		&Csgrouper::Debug($subname, "$key ==> $val");
  		if (exists $CsgObj->sequences->{$pref.'_'.$key}){
  			$CsgObj->sequences->{$pref.'_'.$key} = $CsgObj->sequences->{$seqid}->$key;
  		}
  	} 
		$STARTEXEC =  $oldstart; 
  	&Csgrouper::Describe($subname, "$seqid after Build_tree:  object tree: ".$CsgObj->sequences->{$seqid}->tree->tune." funt: ".$CsgObj->sequences->{$seqid}->funt." ready: ".$CsgObj->sequences->{$seqid}->ready);
  }
  else { 
  	## Here we see that the structure control must take place at tree creation
  	## since in case of failure, the whole object will be destroyed.
  	&Csgrouper::Describe($subname, "$seqid after Build_tree: tree object not present: Sequence object shall be freed.");
  	## Then unselect the row:
  	$CsgObj->sequences->{$pref.'_sel'} = 0;
  	## and delete the Sequence object too:
  	$CsgObj->sequences->{$seqid} = "";
  }
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END seq_obj().

=item * seq_proc() : processes an individual sequence.
=cut

sub seq_proc {
  my ($pref,$action) = @_;
  my $subname = "seq_proc";
  { no warnings; &Csgrouper::says($subname, "@_", 1); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my $req = "$pref Sequence object";
  my $state = 0;
 	&set_ready(0); ## As a modification might have occured.
	my $seqid = "Seq_".$CsgObj->sequences->{$pref.'_id'};
	## At present "update" and "record" do the same thing through different means.
	$CsgObj->sequences->{$pref.'_basis'} = length($CsgObj->sequences->{$pref.'_mode'});
  if ($action eq 'update') {
		&Csgrouper::Debug($subname, "HERE 1");
  	## Updating implies selecting..
		&Csgrouper::Debug($subname, "HERE 1.1");
		$CsgObj->sequences->{$pref.'_sel'} = 1;
		&seq_obj($pref);  ## Recreate the Sequence object.
		$state = 1;
		$req .= ": updated";
		if ( $CsgObj->sequences->{$seqid}->ready != 1){
			## Sequence->ready is set to 1 at row creation or by Build_tree() only.
			$CsgObj->sequences->{$pref.'_sel'} = 0;
			$CsgObj->sequences->{$seqid} = "";
			$req .= ": not ready: deleted";
			$state = 0;
		}
	} ## END action == update.
  else { ## Then action == (de)select through checkbox:
  	## When invoked through the checkbutton itself the state is updated before command is processed. 
 		&Csgrouper::Debug($subname, "HERE 2");
  	if ($CsgObj->sequences->{$pref.'_sel'} == 1) { ## Then it was 0 when pressing..
  		&Csgrouper::Debug($subname, "HERE 2.1");
			$req .= ": recorded";
			&Csgrouper::Debug($subname, "HERE");
			&seq_obj($pref);  ## Recreate the Sequence object.
			$state = 1;
			&Csgrouper::Debug($subname, "HERE 2.1.2".$CsgObj->sequences->{$seqid}->ready);
			## Here check that $CsgObj->sequences->{$seqid}->ready == 1
			## otherwise deselect the sequence: not ready.
			if ( $CsgObj->sequences->{$seqid}->ready != 1){
				$CsgObj->sequences->{$pref.'_sel'} = 0;
				$req .= ": not ready";
			}
		} ## END sel == 0 and orig == id. 
		else { ## checkbox has just been deselected, $state == 0: 
			## Destroy the Sequence object (not the tkrow).
			## This is a quick way to get rid of it. 
			## seq_obj() would have deleted it too, but slowly.
  		&Csgrouper::Debug($subname, "HERE 2.2");
			$CsgObj->sequences->{$seqid} = "";
			$req .= ": deleted";
		}
  } ## END action == (de)select.
	if ($state == 1) {	## print content of Sequence->tree.
		&Log(
			 "$seqid tree:\n".
				$CsgObj->sequences->{$seqid}->tree->tune."\n".
			  $CsgObj->sequences->{$seqid}->tree->octs."\n"
		)			
	}
  &Csgrouper::says($subname,$req,1);
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END seq_proc().

=item * seq_save() : record process step 2.b (from record()): refresh Global vars (TODO check this function).
=cut

sub seq_save {
  my $subname = "seq_save";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my $len = $Seq_tblw->totalRows;
  for (my $n = 1; $n < $len; $n++){
		my $pref = "Tkrow_$n"; 
		## All entries should be set already.
		$CsgObj->sequences->{$pref.'_ind'} = $Seq_tblw->get($n,1)->cget(-text);
		$CsgObj->sequences->{$pref.'_id'} = $Seq_tblw->get($n,2)->cget(-text);
  }
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END seq_save().

=item * seq_test() : recreate the Sequence object if tkrow is selected, otherwise delete it.
=cut

sub seq_test { 
  my $pref = "Tkrow_0";
  my $subname = "seq_test";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my $date = &Csgrouper::Datem('n');
	my @params;
	my $seqid = "Seq_0";
  push @params, 'sel'		=>	"1";
  push @params, 'sid'		=>	"0"; 
  push @params, 'name'	=>	"test sequence";
  push @params, 'ins'		=>	$Part->{'ins_param_le'} // $Csgrouper::CSG{'ins_param_le'};
  push @params, 'n'			=>	$Part->{'N_param_le'} // $Csgrouper::CSG{'N_param_le'};
  push @params, 'x'			=>	$Part->{'X_param_le'} // $Csgrouper::CSG{'X_param_le'};
  push @params, 'y'			=>	$Part->{'Y_param_le'} // $Csgrouper::CSG{'Y_param_le'};
  push @params, 'z'			=>	$Part->{'Z_param_le'} // $Csgrouper::CSG{'Z_param_le'};
  push @params, 'sets'	=>	"";
  push @params, 'pre'		=>	"0"; ## The sequence id itself (no previous sequence in tests).
  push @params, 'rep'		=>	"0"; ## No repetitions in tests.
  push @params, 'funt'	=>	$tanavar;
  push @params, 'fun'		=>	$anavar;
  push @params, 'exp'		=>	$Part->{'ana_exp_cb'} // $Csgrouper::CSG{'ana_exp'};
  push @params, 'modo'	=>	"1"; ## Always apply the displayed mode.
  push @params, 'A'			=>	$Part->{'A_series_le'} // $Csgrouper::CSG{'A_series_le'};
  push @params, 'Aoct'	=>	$Part->{'A_octs_le'} // $Csgrouper::CSG{'A_octs_le'};
  push @params, 'Aroc'	=>	$Part->{'ana_Aroc_cb'} // $Csgrouper::CSG{'ana_Aroc_cb'};
  push @params, 'B'			=>	$Part->{'B_series_le'} // $Csgrouper::CSG{'B_series_le'};
  push @params, 'Boct'	=>	$Part->{'B_octs_le'} // $Csgrouper::CSG{'B_octs_le'};
  push @params, 'Broc'	=>	$Part->{'ana_Broc_cb'} // $Csgrouper::CSG{'ana_Broc_cb'};
  push @params, 'ord'		=>	$Part->{'ord_series_le'} // $Csgrouper::CSG{'ord_series_le'};
  push @params, 'sign'	=>	$Part->{'signs_series_le'} // $Csgrouper::CSG{'signs_series_le'};
  push @params, 'mode'	=>	$Part->{'mod_series_le'} // $Csgrouper::CSG{'mod_series_le'};
  push @params, 'tone'	=>	$Part->{'ton_series_le'} // $Csgrouper::CSG{'ton_series_le'};
  push @params, 'com'		=>	"This is a test ($date).";
  push @params, 'cdat'	=>	$date;
  push @params, 'mdat'	=>	$date;
  push @params, 'tkrow'	=>	"Tkrow_0";
  push @params, 'seqid'	=>	$seqid;
  push @params, 'paro'	=>	$CsgObj;
  push @params, 'test'	=> 1;


  ## Finally create the corresponding sequence object:
	&Csgrouper::Debug($subname, "$seqid params: @params");
	## This will delete any previous Sequence object:
  $CsgObj->sequences->{$seqid} = Csgrouper::Sequence->new(@params);
  ## XXX NOTE: A proof that Sequence object has been recorded 
  ## (otherwise: no seqobj value):
	&Csgrouper::Describe($subname, "$seqid before Build_tree: A: ".$CsgObj->sequences->{$seqid}->A." = seqobj: ".$CsgObj->sequences->{$seqid}->fun);

  ## The tree shall be built UNLESS :
  ## 		a) _sel is off; or 
  ## 		b) the time-related params are not valid (%SectionsH,  %SetsH , %TracksH).
  ## If Build_tree() fails, then the whole sequence will be destroyed (see below).

	$CsgObj->sequences->{$seqid}->Build_tree; 

  ## XXX NOTE: A proof that the tree object has been recorded:
  if (blessed($CsgObj->sequences->{$seqid}->tree)){
  	&Csgrouper::Describe($subname, "$seqid reporting changes to UI..");
  	## XXX NOTE on reporting changes from classes to UI:
  	## Here the possible changes are reported from classes into the UI containers.
  	## XXX NOTE on $STARTEXEC:
  	## valid_entry() has to be disabled by $STARTEXEC since the key validation
  	## applies also when changing the textvar of the entry... (this seems to be a bug).
  	my $oldstart = $STARTEXEC; $STARTEXEC = 1; ## Fake launch time.
   	while (my ($key,$val) = each %{$CsgObj->sequences->{$seqid}}) {
  		&Csgrouper::Debug($subname, "$key ==> $val");
  		if (exists $CsgObj->sequences->{$pref.'_'.$key}){
  			$CsgObj->sequences->{$pref.'_'.$key} = $CsgObj->sequences->{$seqid}->$key;
  		}
  	} 
		$STARTEXEC =  $oldstart; 
  	&Csgrouper::Describe($subname, "$seqid after Build_tree:  object tree: ".$CsgObj->sequences->{$seqid}->tree->tune." funt: ".$CsgObj->sequences->{$seqid}->funt." ready: ".$CsgObj->sequences->{$seqid}->ready);
  }
  else { 
  	## Here we see that the structure control must take place at tree creation
  	## since in case of failure, the whole object will be destroyed.
  	&Csgrouper::Describe($subname, "$seqid after Build_tree: tree object not present: Sequence object shall be freed.");
  	## Then unselect the row:
  	$CsgObj->sequences->{$pref.'_sel'} = 0;
  	## and delete the Sequence object too:
  	$CsgObj->sequences->{$seqid} = "";
  }
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END seq_test().

=item * setup_save() : record process step x (this is the reverse of pref_load).
=cut

sub setup_save {
  my $pref = 0; 
  my $subname = "setup_save";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  &Csgrouper::says($subname, "Saving setup.");
  ## Special cases:
  $Part->{'savenotes_enabled_cb'} = $notes_state; 
  &Csgrouper::says($subname,"Setup saved.");
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END setup_save().

=item * struct_out() : report struct_ctl() de-selection of rows to the interface.
=cut

sub struct_out {
	my $test = $CsgObj->struct_ctl($Part->{'part_sections_le'});
	if ($test != 1) {
		&Csgrouper::Describe($subname, "no structure available");
		$ready_txt = "CSD: not ready";
		return 0;
	}
	for (my $tid = 1; $tid <= $Csgrouper::Types::MAXOBJ; $tid++){
		my $tpref = "Tkrow_$tid";	 	
		next if (not defined $CsgObj->sequences->{$tpref."_id"});
		## was badly: $CsgObj->sequences->{$tpref."_id"}//= "";
		next if ($CsgObj->sequences->{$tpref."_id"} !~ /\d+/);
		next if (not defined 	$CsgObj->sequences->{"Seq_".$CsgObj->sequences->{$tpref."_id"}}); 
		if ($CsgObj->sequences->{$tpref.'_sel'} == 0) {
			seq_proc($tpref); ## Destroy this invalid object.
		}
	}
	&Csgrouper::Describe($subname, "struct_ctl(): OK");
	$test = &Xfun();
	if ($test != 1) {
		&Csgrouper::Describe($subname, "something went wrong with Xfun()");
		$ready_txt = "CSD: not ready";
		return 0;
	}
	&Csgrouper::Describe($subname, "Xfun(): OK");
	$test = &Yfun();
	if ($test != 1) {
		&Csgrouper::Describe($subname, "something went wrong with Yfun()");
		$ready_txt = "CSD: not ready";
		return 0;
	}
	&Csgrouper::Describe($subname, "Yfun(): OK");
	&set_ready(1);
} ## END struct_out().

=item * set_ready() : set the overall state for the part.
=cut

sub set_ready {
	my ($value) = @_;
	if ($value == 1) {
		$ready_txt = "CSD: ready";
		$CsgObj->set_ready(1);
	}
	else {
		$ready_txt = "CSD: not ready";
		$CsgObj->set_ready(0);
	}
}	## END set_ready().
	
=item * valid_entry() : validates typed strings.
=cut

sub valid_entry{
  my ($entry,$type,$pref,$mode) = @_; ## See Csgrouper::Types.pm for type names.
  my $subname = "valid_entry";
  ## { no warnings; &Csgrouper::says($subname, "@_"); } ## Uncomment to debug.
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  $mode //= 0;
  &set_ready(0) unless ($mode == 1);
  $entry = "" if (not defined $entry);
  &Csgrouper::Debug($subname, "entry=$entry type=$type pref=$pref csgstart=$STARTEXEC");
  my $res = 1; my $test = 0;
  ## $STARTEXEC impedes from doing this at launch time and also when set
  ## explicitely by a routine.
  if (defined($pref) && $STARTEXEC == 0 && $mode != 1){ ## Deselect the row, it has to be checked again..
  	 my $seqid = "Seq_".$CsgObj->sequences->{$pref.'_id'};
  	 if (defined( $CsgObj->sequences->{$seqid}) && $CsgObj->sequences->{$pref.'_sel'} == 1) { $CsgObj->sequences->{$seqid}->set_ready(0) }
  	 $CsgObj->sequences->{$pref.'_sel'} = 0;
  	 &Csgrouper::Debug($subname,"Row $pref deselected.");
  	 goto ENDVALID if ($type =~ /unset/);
  }
  ## Unfortunately there is no way to proceede directly here with
  ## regexes like $entry !~ $Csgrouper::Types::REGEX{'alnum'}...
  ## See Types.pm.
  if ($type =~ /^(alnum)$/) { ## alphanumeric.
		if ($entry =~ $Csgrouper::Types::REGEX{'non_alnum'}) {
			&Csgrouper::Error($subname, "invalid char: $entry",0);
			$res = 0 ;  ## 0 = false
		}
  }
  elsif ($type =~ /^(digicom)$/) { ## digits + separators.
		if ($entry =~ $Csgrouper::Types::REGEX{'non_digicom'}) {
			&Csgrouper::Error($subname, "invalid char: $entry",0);
			$res = 0 ;
		}
  }
  elsif ($type =~ /^(digicominst)$/) { ## digits + separators + i.
		if ($entry =~ $Csgrouper::Types::REGEX{'non_digicominst'}) {
			&Csgrouper::Error($subname, "invalid char: $entry",0);
			$res = 0 ;
		}
  }
  elsif ($type =~ /^(digit)$/) { 
		if ($entry =~ $Csgrouper::Types::REGEX{'non_digit'})  { 
			&Csgrouper::Error($subname, "invalid char: $entry",0);
			$res = 0 ;
		}
  }
  elsif ($type =~ /^(float)$/) {
		if ($entry =~ $Csgrouper::Types::REGEX{non_float}) {
		 &Csgrouper::Error($subname, "invalid char: $entry",0);
		 $res = 0 ; 
		}
  }
  elsif ($type =~ /^(inst)$/) { # instruments
		if ($entry =~ $Csgrouper::Types::REGEX{non_inst}) {
			&Csgrouper::Error($subname, "invalid char: $entry",0);
			$res = 0 ;
		}
  }
  elsif ($type =~ /^(param)$/) { ## A-Z + =.
		if ($entry =~ $Csgrouper::Types::REGEX{non_param}) {
			&Csgrouper::Error($subname, "invalid char: $entry",0);
			$res = 0 ;
		}
  }
  elsif ($type =~ /^(plusalnumin)$/) { ## alnum + dots + minus + plus.
		if ($entry =~ $Csgrouper::Types::REGEX{non_plusalnumin}) {
			&Csgrouper::Error($subname, "invalid char: $entry",0);
			$res = 0 ;
		}
  }
  elsif ($type =~ /^(plusminus)$/) { 
		if ($entry =~ $Csgrouper::Types::REGEX{non_plusminus}) {
		 &Csgrouper::Error($subname, "invalid char: $entry",0);
		 $res = 0 ; 
		}
  }
  elsif ($type =~ /^(spalnumin)$/) { ## alnum + spaces + minus.
		if ($entry =~ $Csgrouper::Types::REGEX{non_spalnumin}) {
		 &Csgrouper::Error($subname, "invalid char: $entry",0);
		 $res = 0 ; 
		}
  }
  elsif ($type =~ /^(subset)$/) { ## digit + coma + semicolon.
		if ($entry =~ $Csgrouper::Types::REGEX{non_subset}) {
			&Csgrouper::Error($subname, "invalid char: $entry",0);
			$res = 0 ;
		}
  }
  elsif ($type =~ /^(text)$/) { ## alnum + space + dot + coma + semicolon + colon + minus + plus.
		if ($entry =~ $Csgrouper::Types::REGEX{non_text}) {
			&Csgrouper::Error($subname, "invalid char: $entry",0);
			$res = 0 ;
		}
  }
  elsif ($type =~ /^(xphonic)$/) { 
		if ($entry =~ $Csgrouper::Types::REGEX{'non_xphonic'}) {
			&Csgrouper::Error($subname, "invalid char: $entry",0);
		 $res = 0 ;
		}
  }
  $Csgrouper::DEBFLAG =  $oldebflag;
  ENDVALID:
  return $res;
} ## END valid_entry().

## END TK ANS SYSTEM SUBS.

## ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ### 
## ###  INTERFACE SUBS   (REVISED)    ###  ###  ###  ###  ###  ###  ###  ### 
## ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ### 
=back

=head1 Interface Subroutines

=head2 Control Subroutines

=over

=item * Log() : record some output.
=cut

sub Log {
  my ($data) = @_;
  my $subname = "Log";
  # { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my $date = &Csgrouper::Datem();
  $Output_tw->insert('1.0', "\n$date:\n$data\n");
  $Csgrouper::DEBFLAG =  $oldebflag;
  return 1;
} ## END Log().

=item * Resetall() : resets Default settings.
=cut

sub Resetall {
  my ($mode) = @_;
  my $subname = "Resetall";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  { no strict 'refs'; no warnings;
	## And set Globals to their Defaults:
	if ($mode =~ /init/){ 
	  $Author 	= $Part->{'part_author_le'} 		//= $Csgrouper::CSG{'part_author_le'}; 
	  $Intersil = $Part->{'part_intersil_le'} 	//= $Csgrouper::CSG{'part_intersil_le'}; 
	  $Comptype = $Part->{'part_comptype_mw'} 	//= $Csgrouper::CSG{'part_comptype_mw'}; 
	  $Durmin = $Part->{'part_durmin_le'} 	//= $Csgrouper::CSG{'part_durmin_le'}; 
	  $Durmax = $Part->{'part_durmax_le'} 	//= $Csgrouper::CSG{'part_durmax_le'}; 
	  $Durtype = $Part->{'part_durtype_mw'} 	//= $Csgrouper::CSG{'part_durtype_mw'}; 
	  $Rythmtype = $Part->{'part_rythmtype_mw'} 	//= $Csgrouper::CSG{'part_rythmtype_mw'}; 
	  $Steps 		= $Part->{'part_steps_le'} 			//= $Csgrouper::CSG{'part_steps_le'}; 
	  $Tempo 		= $Part->{'part_tempo_le'} 			//= $Csgrouper::CSG{'part_tempo_le'}; 
	  $Title 		= $Part->{'part_title_le'} 			//= $Csgrouper::CSG{'part_title_le'}; 
	  # Paths:
	  my $var;
	  $var = $Part->{'csg_path_pe'}; $var =~ /^(~\/.*)$/?  $Part->{'csg_path_pe'} = $var =~ s/^(~\/)(.*)$/$Csgrouper::INSTALLDIR$2/ : $Part->{'csg_path_pe'} = $Csgrouper::CSG{'csg_path_pe'};
	  $BasePath = $Part->{'csg_path_pe'}; 
	  
	  $var = $Part->{'csound_sf2path_pe'}; $var =~ /^(~\/.*)$/?  $Part->{'csound_sf2path_pe'} = $var =~ s/^(~\/)(.*)$/$Csgrouper::INSTALLDIR$2/ : $Part->{'csound_sf2path_pe'} = $Csgrouper::CSG{'csound_sf2path_pe'};
	  $Sf2Path 	= $Part->{'csound_sf2path_pe'}; 
	  
	  $var = $Part->{'run_path_pe'}; $var  =~ /^(~\/.*)$/?  $Part->{'run_path_pe'} = $var  =~ s/^(~\/)(.*)$/$Csgrouper::INSTALLDIR$2/ : $Part->{'run_path_pe'} = $Csgrouper::CSG{'run_path_pe'};
	  $var = $Part->{'render_path_pe'}; $var  =~ /^(~\/.*)$/?  $Part->{'render_path_pe'} = $var  =~ s/^(~\/)(.*)$/$Csgrouper::INSTALLDIR$2/ : $Part->{'render_path_pe'} = $Csgrouper::CSG{'render_path_pe'};
	  $var = $Part->{'bkp_path_pe'}; $var  =~ /^(~\/.*)$/?  $Part->{'bkp_path_pe'} = $var  =~ s/^(~\/)(.*)$/$Csgrouper::INSTALLDIR$2/ : $Part->{'bkp_path_pe'} = $Csgrouper::CSG{'bkp_path_pe'};
	  $var = $Part->{'ins_path_pe'}; $var  =~ /^(~\/.*)$/?  $Part->{'ins_path_pe'} = $var  =~ s/^(~\/)(.*)$/$Csgrouper::INSTALLDIR$2/ : $Part->{'ins_path_pe'} = $Csgrouper::CSG{'ins_path_pe'};
	  $var = $Part->{'part_path_pe'}; $var  =~ /^(~\/.*)$/?  $Part->{'part_path_pe'} = $var  =~ s/^(~\/)(.*)$/$Csgrouper::INSTALLDIR$2/ : $Part->{'part_path_pe'} = $Csgrouper::CSG{'part_path_pe'};
	  $var = $Part->{'part_path_pe'}; $var  =~ /^(~\/.*)$/?  $Part->{'part_path_pe'} = $var  =~ s/^(~\/)(.*)$/$Csgrouper::INSTALLDIR$2/ : $Part->{'part_path_pe'} = $Csgrouper::CSG{'part_path_pe'};
	  
	}
	elsif ($mode =~ /reset/){
	  $Author = $Csgrouper::CSG{'part_author_le'};
	  if (defined $Part->{'part_author_le'}) {
	  	$Part->{'part_author_le'} = $Author ; 
	  }
	  $Intersil = $Csgrouper::CSG{'part_intersil_le'};
	  if (defined $Part->{'part_intersil_le'}){
	  	$Part->{'part_intersil_le'} = $Intersil ;
	  }
	  $Comptype = $Csgrouper::CSG{'part_comptype_mw'};
	  if (defined $Part->{'part_comptype_mw'}){
	  	$Part->{'part_comptype_mw'} = $Comptype ;
	  }
	  $Durtype = $Csgrouper::CSG{'part_durtype_mw'};
	  if (defined $Part->{'part_durtype_mw'}){
	  	$Part->{'part_durtype_mw'} = $Durtype ;
	  }
	  $Durmin = $Csgrouper::CSG{'part_durmin_le'};
	  if (defined $Part->{'part_durmin_le'}){
	  	$Part->{'part_durmin_le'} = $Durmin ;
	  }
	  $Durmax = $Csgrouper::CSG{'part_durmax_le'};
	  if (defined $Part->{'part_durmax_le'}){
	  	$Part->{'part_durmax_le'} = $Durmax ;
	  }
	  $Rythmtype = $Csgrouper::CSG{'part_rythmtype_mw'};
	  if (defined $Part->{'part_rythmtype_mw'}){
	  	$Part->{'part_rythmtype_mw'} = $Rythmtype ;
	  }
	  $BasePath = $Csgrouper::CSG{'csg_path_pe'};
	  if (defined $Part->{'csg_path_pe'}){
	  	$Part->{'csg_path_pe'} = $BasePath ;
	  }
	  $Sf2Path = $Csgrouper::CSG{'csound_sf2path_pe'};
	  if (defined $Part->{'csound_sf2path_pe'}){
	  	$Part->{'csound_sf2path_pe'} = $Sf2Path ;
	  }
	  $Steps= $Csgrouper::CSG{'part_steps_le'};
		  if (defined $Part->{'part_steps_le'}){
		$Part->{'part_steps_le'} = $Steps ;
	  }
	  $Tempo= $Csgrouper::CSG{'part_tempo_le'};
	  if (defined $Part->{'part_tempo_le'}){
	  	$Part->{'part_tempo_le'} = $Tempo ;
	  }
	  $Title = $Csgrouper::CSG{'part_title_le'};
	  if (defined $Part->{'part_title_le'}) {
	  	$Part->{'part_title_le'} = $Title ; 
	  }
	} ## END if mode = reset;
	&set_ready(0); ## Not ready unless Eval is done.
  } ## END no strict refs; no warnings..
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END Resetall().

=back

=head2 Xfun Subroutines

=over

=item * Xfun() : applies csgrouper.pl main functions to sections of sequences representing sections of a part.
=cut

sub Xfun {
  my $subname = "Xfun";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
	my $osep = $Csgrouper::OBJSEP; my $ssep = $Csgrouper::SETSEP;
	my $test = 0; my %defaults; $CsgObj->defaults(\%defaults);
	for (my $g = 0; $g < $Csgrouper::Types::MAXOBJ; $g++){	
		next if (not defined $CsgObj->tracks->{$g});
		## These are the valid sets for group $g:
		&Csgrouper::Describe($subname, "sets for group $g=".join ' ',@{$CsgObj->sections->{$g}->{'sets'}});
		&Csgrouper::Describe($subname, "tracks=".join ' ',@{$CsgObj->tracks->{$g}});
		## Take track lists by group id:
		foreach (@{$CsgObj->tracks->{$g}}){
			my $track = $_; my @seqs = split /$osep$osep/,$track;
			&Csgrouper::Describe($subname, "track $track");
			my $scnt = 0; my $stot = scalar(@seqs);
			foreach (@seqs){
				my $tid = $_;  $scnt++;
				$tid =~ s/$osep//g;
				## 1 Recover real id:
				my $spref = "Seq_".$CsgObj->sequences->{"Tkrow_$tid\_id"};				
				&Csgrouper::Describe($subname, "Tkrow_$tid=$spref ($g:$scnt/$stot)");
				my @sets = split /$ssep/,$CsgObj->sequences->{$spref}->sets;
				&Csgrouper::Describe($subname, "sets for $spref=@sets");
				my $siz = 	$CsgObj->sequences->{$spref}->tree->size;
				my $sers = 	$CsgObj->sequences->{$spref}->tree->sers;
				my $base = 	$CsgObj->sequences->{$spref}->base;
				&Csgrouper::Describe($subname, "$spref: base=$base siz=$siz nser=$sers");
				## 2. Find other sequences in same sets:
				$CsgObj->inseth(&inseth(\@sets,$tid));
				## 3. Get Instrument Defaults:
				my %seqdef; $CsgObj->defaults->{$spref} = \%seqdef;
				&basedef(\%seqdef,$spref);
				## 4. Treat each note in sequence:
				&inote($spref);
				$test = 1;
			} ## END for seq.
		} ## END for track.
	} ## END for group.
  $Csgrouper::DEBFLAG =  $oldebflag;
	return $test;
} ## END Xfun().


=item * basedef($defaults,$seqid) : retrieves instrument params defaults for a sequence. 
=cut

sub basedef {
  my ($seqdef,$spref) = @_; 
  my $subname = "basedef";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  ##  Get Sequence Defaults:
	my $instr = $CsgObj->sequences->{$spref}->instr; ## Instr. id.
	my $parnum = $CsgObj->instruments->{$instr.'_parnum'}; ## Number of p-values.
	if ($Part->{'part_durtype_mw'} == 1) { ## Duration
		&Csgrouper::Describe($subname, "Duration set to random mode.");
	}
	elsif ($Part->{'part_durtype_mw'} == 2) {
		&Csgrouper::Describe($subname, "Duration set to fixed mode.");
	}
	for (my $p = 3; $p <= ($parnum+2); $p++){ 
		## Two accesses to the same parameter:	
		my $fun = $CsgObj->instruments->{$instr.'_p'.$p.'_fun'}; 
		my $def = $CsgObj->instruments->{$instr.'_p'.$p.'_def'};
		if ($def =~ /\d+\.\d*/) { $seqdef->{"p$p"} = $seqdef->{$fun} = $def } ## Preserve the last dot for special csound notation..
		elsif (eval($def)){ $seqdef->{"p$p"} = $seqdef->{$fun} = eval($def) }
		else { $seqdef->{"p$p"} = $seqdef->{$fun} = $def }
		## One could also have accessed this parameter by the content of Tk table:
		##	my $fun = $CsgObj->instruments->{'-'.$instr.'_table'}->get(1, $i)->Contents(); 
		##	my $def = $CsgObj->instruments->{'-'.$instr.'_table'}->get(2, $i)->Contents(); 
	} 
	if ($Csgrouper::DEBFLAG//= 0 == 1){
		say "parnum=$parnum";
		while (my ($key,$val) = each %{$seqdef}) { say "$key => $val" }
	}
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END basedef().

=item * inote($seqid) : stores note params into dedicated Note object containers.
=cut

sub inote {
  my ($spref) = @_; 
  my $subname = "inote";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my %parlist; 
  ## Starting point:
  my $sta = 0; my $ppref = $spref;
  ## Preceding sequence?
  if ($CsgObj->sequences->{$spref}->pre != $CsgObj->sequences->{$spref}->sid) {
  	$ppref = "Seq_".$CsgObj->sequences->{$spref}->pre;
  	my $index = $CsgObj->sequences->{$ppref}->tree->size - 1; 
  	my $lasta = $CsgObj->sequences->{$ppref}->tree->notes->{$index}->csph->{2}; 
  	my $lastdur = $CsgObj->sequences->{$ppref}->tree->notes->{$index}->csph->{3}; 
  	## This sequence should be recorded already so:
		&Csgrouper::Describe($subname, "ppref: $ppref index: $index lasta: $lasta last dur: $lastdur") ; 
  	$sta = $lasta+$lastdur;
  }
  ## Starting by a silence?
  if (defined $CsgObj->sequences->{$spref}->ipars->{sta}) {
  	$sta += $CsgObj->sequences->{$spref}->ipars->{sta};
  }
	for (my $i = 0; $i < $CsgObj->sequences->{$spref}->tree->size; $i++){
		%parlist = ();
		my $ref = $CsgObj->sequences->{$spref}->tree->notes->{$i};
		&Csgrouper::Debug($subname, "   sind=".$ref->sind." ind=".$ref->indi." gind=".$ref->gind);
		my $ins = $CsgObj->sequences->{$spref}->instr; ## Instr. id.
		my $parnum = $CsgObj->instruments->{$ins.'_parnum'}; ## Number of p-values.
		## 1. DEFAULT PARAM VALUES:
		## KEYWORD = "dur".
		## Here a modal composition in a small base will receive smaller average durations;
		## the final result needs to be normalized by $CsgObj->defaults->{$spref}->{dur}.
		## old: my $dur = &Csgrouper::Dodecad($ref->scmp1)+1; 
		my $dur = ((&Csgrouper::Dodecad($ref->val)%8)*(&Csgrouper::Dodecad($ref->indi)%8))/8;
		if ($Part->{'part_durtype_mw'} == 1) {
			$dur = (int(rand($Csgrouper::CSG{part_durmax_le})%8)*(&Csgrouper::Dodecad($ref->indi)%8))/8;
		}
		elsif ($Part->{'part_durtype_mw'} == 2) {
			$dur = $Part->{part_durmin_le}*$Part->{'part_rythmtype_mw'};
		}
		## Normalization.. comment it to allow durations of 0 sec.:
		$dur = $Csgrouper::CSG{part_durmin_le} if ($dur == 0);
		## Rythm type:
		my $rval = $dur*8; 
		&Csgrouper::Describe($subname, "dur: $dur") ; 
		if ($Part->{'part_rythmtype_mw'} == 1) { ## Mixed-.
			if ($rval == 1) { $rval++; &Csgrouper::Describe($subname, "rval++") }
			else { while (not($rval%3 == 0 || $rval%2 == 0)) { $rval--; &Csgrouper::Describe($subname, "rval--") } }
		}
		elsif ($Part->{'part_rythmtype_mw'} == 6) { ## Mixed+.
			if ($rval == 1) { $rval++; &Csgrouper::Describe($subname, "rval++") }
			else { while (not($rval%3 == 0 || $rval%2 == 0)) { $rval++; &Csgrouper::Describe($subname, "rval++") } }
		}
		elsif ($Part->{'part_rythmtype_mw'} == 2) { ## Binary-.
			if ($rval == 1) { $rval++; &Csgrouper::Describe($subname, "rval++")  }
			else { while ($rval%2 != 0) { $rval--; &Csgrouper::Describe($subname, "rval--")  } }
		}
		elsif ($Part->{'part_rythmtype_mw'} == 3) { ## Ternary-.
			if ($rval < 3) { $rval = 3; &Csgrouper::Describe($subname, "rval->3")  }
			else { while ($rval%3 != 0) { $rval--; &Csgrouper::Describe($subname, "rval--")  } }
		}
		elsif ($Part->{'part_rythmtype_mw'} == 4) { ## Binary+.
			if ($rval == 1) { $rval++; &Csgrouper::Describe($subname, "rval++")  }
			else { while ($rval%2 != 0) { $rval++; &Csgrouper::Describe($subname, "rval++")  } }
		}
		elsif ($Part->{'part_rythmtype_mw'} == 5) { ## Ternary+.
			if ($rval < 3) { $rval = 3; &Csgrouper::Describe($subname, "rval->3")  }
			else { while ($rval%3 != 0) { $rval++; &Csgrouper::Describe($subname, "rval++")  } }
		}
		$dur = $rval/8;
		&Csgrouper::Describe($subname, "new dur: $dur") ; 
		## The best solution remains to set $CsgObj->defaults->{$spref}->{dur} as factor:
		&Csgrouper::Debug($subname, "## dur=".$dur." new=".$CsgObj->defaults->{$spref}->{dur}*$dur);
		$dur = $CsgObj->defaults->{$spref}->{dur}*$dur; 
		$dur =~ s/^(.+\.\d{3})(.+)$/$1/;	
		$dur = ($Part->{part_durmin_le}*$Part->{'part_rythmtype_mw'}) if ($dur < ($Part->{part_durmin_le}*$Part->{'part_rythmtype_mw'}));
		$dur = ($Part->{part_durmin_le}*$Part->{part_durmax_le}*$Part->{'part_rythmtype_mw'}) if ($dur > ($Part->{part_durmin_le}*$Part->{part_durmax_le}*$Part->{'part_rythmtype_mw'}));
		$parlist{dur} = $dur;
		## KEYWORD = "fq1":
		my $freqtype = $CsgObj->instruments->{$ins.'_freq_type'};
		my $fq1; $freqtype//="cps";
		if ($freqtype =~ /^(cps)$/) { $parlist{fq1} = $fq1 = $ref->fq1 }
		elsif ($freqtype =~ /^(cpspch)$/) { $parlist{fq1} = $fq1 =  $ref->pc1 }
		elsif ($freqtype =~ /^(midi)$/){ $parlist{fq1} = $fq1 = $ref->mi1 }
		$fq1 =~ s/^(.+\.\d{3})(.+)$/$1/;	
		&Csgrouper::Describe($subname, "$ins : $freqtype : $fq1");
		## KEYWORD = "amp":
		my $amp = $CsgObj->defaults->{$spref}->{'amp'}//= "0"; $parlist{amp} = $amp;
		## KEYWORD = "atk":
		my $atk = $CsgObj->defaults->{$spref}->{'atk'}//= "0.01"; $parlist{atk} = $atk;
		## KEYWORD = "bnk":
		my $bnk = $CsgObj->defaults->{$spref}->{'bnk'}//= "0"; $parlist{bnk} = $bnk;
		## KEYWORD = "cro":
		my $cro = $CsgObj->defaults->{$spref}->{'cro'}//= "0"; $parlist{cro} = $cro;
		## KEYWORD = "del":
		my $del = $CsgObj->defaults->{$spref}->{'del'}//= "0.5"; $parlist{del} = $del;
		## KEYWORD = "ft1":
		my $ft1 = $CsgObj->defaults->{$spref}->{'ft1'}//= "1"; $parlist{ft1} = $ft1;
		## KEYWORD = "ft2":
		my $ft2 = $CsgObj->defaults->{$spref}->{'ft2'}//= "1"; $parlist{ft2} = $ft2;
		## KEYWORD = "ft3":
		my $ft3 = $CsgObj->defaults->{$spref}->{'ft3'}//= "1"; $parlist{ft3} = $ft3;
		## KEYWORD = "ft4":
		my $ft4 = $CsgObj->defaults->{$spref}->{'ft4'}//= "1"; $parlist{ft4} = $ft4;
		## KEYWORD = "gis":
		my $gis = $CsgObj->defaults->{$spref}->{'gis'}//= "0.5"; $parlist{gis} = $gis;
		## KEYWORD = "gl1":
		my $gl1 = $CsgObj->defaults->{$spref}->{'gl1'}//= "0"; $parlist{gl1} = $gl1;
		## KEYWORD = "gl2":
		my $gl2 = $CsgObj->defaults->{$spref}->{'gl2'}//= "0"; $parlist{gl2} = $gl2;
		## KEYWORD = "hd1":
		my $hd1 = $CsgObj->defaults->{$spref}->{'hd1'}//= "0"; $parlist{hd1} = $hd1;
		## KEYWORD = "hd2":
		my $hd2 = $CsgObj->defaults->{$spref}->{'hd2'}//= "0"; $parlist{hd2} = $hd2;
		## KEYWORD = "hm1":
		my $hm1 = $CsgObj->defaults->{$spref}->{'hm1'}//= "0"; $parlist{hm1} = $hm1;
		## KEYWORD = "hm2":
		my $hm2 = $CsgObj->defaults->{$spref}->{'hm2'}//= "0"; $parlist{hm2} = $hm2;
		## KEYWORD = "lfa":
		my $lfa = $CsgObj->defaults->{$spref}->{'lfa'}//= "0.1"; $parlist{lfa} = $lfa;
		## KEYWORD = "pa1":
		my $pa1 = $CsgObj->defaults->{$spref}->{'pa1'}//= "0.5"; $parlist{pa1} = $pa1;
		## KEYWORD = "pa2":
		my $pa2 = $CsgObj->defaults->{$spref}->{'pa2'}//= "0.5"; $parlist{pa2} = $pa2;
		## KEYWORD = "pcd":
		my $pcd = $CsgObj->defaults->{$spref}->{'pcd'}//= "1"; $parlist{pcd} = $pcd;
		## KEYWORD = "pnb":
		my $pnb = $CsgObj->defaults->{$spref}->{'pnb'}//= "0"; $parlist{pnb} = $pnb;
		## KEYWORD = "reg":
		my $reg = $CsgObj->defaults->{$spref}->{'reg'}//= "0"; $parlist{reg} = $reg;
		## KEYWORD = "rel":
		my $rel = $CsgObj->defaults->{$spref}->{'rel'}//= "0"; $parlist{rel} = $rel;
		## KEYWORD = "rvn":
		my $rvn = $CsgObj->defaults->{$spref}->{'rvn'}//= "0"; $parlist{rvn} = $rvn;
		## KEYWORD = "rvs":
		my $rvs = $CsgObj->defaults->{$spref}->{'rvs'}//= "0"; $parlist{rvs} = $rvs;
		## KEYWORD = "sff": sf2 file
		my $sff = $CsgObj->defaults->{$spref}->{'sff'}//= "Piano-Akai_Steinway_III.sf2"; $parlist{sff} = $sff;
		## KEYWORD = "sre": sf2 register
		my $sre = $CsgObj->defaults->{$spref}->{'sre'}//= "24:60:108"; $parlist{sre} = $sre;
		&Csgrouper::Debug($subname, "dur=".$dur." amp=".$amp." atk=".$atk);
		## KEYWORDS = "fq1", "pan", "gli", "hus", etc.:
		## These other params are treated below by overfun() based on 
		## their Note object defaults.
		## 2. OVERWRITE LIST OF PARAMS:
		my @sets = split /$Csgrouper::SETSEP/,$CsgObj->sequences->{$spref}->sets;
		&overfun(\%parlist,\@sets,$spref,$i);
		## Report changes to the note object (some additional values have been set by overfun):
		## 3. SET GLOBAL P VALUES:
		&setpval($parlist{amp}//= $amp,'amp',$spref,$i);
		&setpval($parlist{atk}//= $atk,'atk',$spref,$i);
		&setpval($parlist{del}//= $del,'del',$spref,$i);
		&setpval($parlist{dur}//= $dur,'dur',$spref,$i);
		&setpval($parlist{cro}//= $cro,'cro',$spref,$i);
		&setpval($parlist{bnk}//= $bnk,'bnk',$spref,$i);
		&setpval($parlist{fq1}//= $fq1,'fq1',$spref,$i); ## Set the three to fq1:
		&setpval($parlist{fq2}//= $fq1,'fq2',$spref,$i);
		&setpval($parlist{fq3}//= $fq1,'fq3',$spref,$i);
		&setpval($parlist{ft1}//= $ft1,'ft1',$spref,$i);
		&setpval($parlist{ft2}//= $ft2,'ft2',$spref,$i);
		&setpval($parlist{ft3}//= $ft3,'ft3',$spref,$i);
		&setpval($parlist{ft4}//= $ft4,'ft4',$spref,$i);
		&setpval($parlist{gl1}//= $gl1,'gl1',$spref,$i);
		&setpval($parlist{gl2}//= $gl2,'gl2',$spref,$i);
		&setpval($parlist{hd1}//= $hd1,'hd1',$spref,$i);
		&setpval($parlist{hd2}//= $hd2,'hd2',$spref,$i);
		&setpval($parlist{hm1}//= $hm1,'hm1',$spref,$i);
		&setpval($parlist{hm2}//= $hm2,'hm2',$spref,$i);
		&setpval($parlist{ins}//= $ins,'ins',$spref,$i);
		&setpval($parlist{lfa}//= $lfa,'lfa',$spref,$i);
		&setpval($parlist{pa1}//= $pa1,'pa1',$spref,$i);
		&setpval($parlist{pa2}//= $pa2,'pa2',$spref,$i);
		&setpval($parlist{pcd}//= $pcd,'pcd',$spref,$i);
		&setpval($parlist{pnb}//= $pnb,'pnb',$spref,$i);
		&setpval($parlist{reg}//= $reg,'reg',$spref,$i);
		&setpval($parlist{rel}//= $rel,'rel',$spref,$i);
		&setpval($parlist{rvn}//= $rvn,'rvn',$spref,$i);
		&setpval($parlist{rvs}//= $rvs,'rvs',$spref,$i);
		&setpval($parlist{sff}//= $sff,'sff',$spref,$i);
		&setpval($parlist{sre}//= $sre,'sre',$spref,$i);
		&setpval($parlist{sta}//= $sta,'sta',$spref,$i);
		$sta += $dur;
		## 4. SET LOCAL P VALUES:
		for (my $p = 4; $p <= ($parnum+2); $p++) { 
			my $fun = $CsgObj->instruments->{$ins.'_p'.$p.'_fun'};
			my $test = 0;
			foreach (@Csgrouper::Paramar) { $test = 1 if ($fun ~~ @{$_}) } 
			next if $test == 1;
			&Csgrouper::Debug($subname, "$p : inst fun:".$CsgObj->instruments->{$ins.'_p'.$p.'_fun'});	
			my $def = $CsgObj->instruments->{$ins.'_p'.$p.'_def'}; $def =~ s/\n//g;
			&setpval($def,$fun,$spref,$i);
		}
	} ## END for i note in tree.
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END inote().

=item * inseth($aref,$tkrowid) : retrieves set-related informations for a particular Tkrow id.
=cut

sub inseth {
  my ($aref,$tid) = @_;
  my $subname = "inseth";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my %inseth;
	foreach ( @{$aref}){
		my $set = $_;		
		$inseth{$set} = {};
		## Find special functions for this set:
		foreach (@XYfun) {
			my $varfun = $_;
			my $varname = "part_".$varfun."_le";
			my $vartext = $Part->{$varname}; ## The actual box contents.
			my $reg1 = $set.$Csgrouper::PARSEP;
			my $reg2 = $Csgrouper::SETSEP.$set.$Csgrouper::PARSEP;
			&Csgrouper::Describe($subname, "$varfun   $vartext");
			next if ( ($vartext !~ /^($reg1)(.*)/) &&
								($vartext !~ /($reg2)(.*)/)	);
			my @setpars = split /$Csgrouper::SETSEP/,$vartext;
			@{$inseth{$set}{$varfun}} = (); 
			foreach (@setpars) {
				my $settext = $_;
				next if ($settext !~ /^($set$Csgrouper::PARSEP.+)$/) ;
				my @pars = split /$Csgrouper::PARSEP/,$settext;
				my $subset = shift(@pars);
				&Csgrouper::Error($subname, "Set ($set) vs subset ($subset) mismatch. pars=@pars setpars=@setpars") if
					($subset != $set);
				@{$inseth{$set}{$varfun}} = @pars; 
			}
			&Csgrouper::Describe($subname, "$varfun pars for set $set =".join ' ',@{$inseth{$set}{$varfun}});
		}
	} ## END foreach set for this seq.
  $Csgrouper::DEBFLAG =  $oldebflag;
  return \%inseth;
} ## END inseth().

=item * overdef($defaults,$seqid) : was joined to basedef, but did not respect the logical hierarchy of defaults overwriting. 
=cut

sub overdef {
  my ($parlist,$spref,$i) = @_; 
  my $subname = "overdef";
  # { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
	if ($Csgrouper::DEBFLAG//= 0 == 1){
		&Csgrouper::Debug($subname, "$spref note $i, before: ");
		while (my ($key,$val) = each %{$parlist}) { say "$key => $val" }
	}
	## Now overwrite defaults with Sequence instrument params:								
	while ( my ($fun,$def) = each %{$CsgObj->sequences->{$spref}->ipars}) {
		## Named defaults have more scope than p-values: 
		## for xfun values will be given according to named defaults
		## so as to support any instrument architecture.
		&Csgrouper::Debug($subname, "\|".$fun." *=> ".$def."\|");
		next if ($fun =~ /^(sta)$/); ## This is treated in inote();
		if (eval($def)){ $parlist->{$fun} = eval($def) }
		else { $parlist->{$fun} = $def }
	}
	if ($Csgrouper::DEBFLAG//= 0 == 1){
		&Csgrouper::Debug($subname, "$spref note $i, after: ");
		while (my ($key,$val) = each %{$parlist}) { say "$key => $val" }
	}
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END overdef().

=item * overfun($parlistref,$setref) : applies set-related (non relationnal) xfun specifications to a note params.
=cut

sub overfun { 
  my ($parlist,$setref,$spref,$i) = @_; 
  my $subname = "overfun";
  # { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
	## 3.2 PARAM VALUES BY SET:
	## We don't accept absolute values that depend on duration for params like gli or pan
	## but only factors since duration can be changed later by yfuns.
	foreach (@{$setref}){ ## A note can be a member of various sets.
		## If several sets have different dur params, the higher set id will overwrite previous ones.
		my $set = $_;		
		## The following params are ordered:
		if (defined $CsgObj->inseth->{$set}{xdur}){
			## 3 cases : normal xfun, modification by factor or limit values.
			## Here do the normal Xfun computation if any..
			&Csgrouper::Describe($subname,"note $i ==========================> xdur a");
			goto ENDXDUR unless (defined ${$CsgObj->inseth->{$set}{xdur}}[0]);
			&Csgrouper::Describe($subname,"note $i ##########################> xdur b");
			my $exp0 = ${$CsgObj->inseth->{$set}{xdur}}[0];
			$exp0 = eval($exp0) if (eval($exp0));
			if (defined $CsgObj->inseth->{$set}{xdur}[1]){
				my $exp1 = ${$CsgObj->inseth->{$set}{xdur}}[1];
				$exp1 = eval($exp1) if (eval($exp1));
				## TODO : find something better to change duration.
				$parlist->{dur} = $exp1 if ($parlist->{dur} > $exp1);
				$parlist->{dur} = $exp0 if ($parlist->{dur} < $exp0);
			}
			else { ## Scalar factor:
				if ($exp0 < 0) { $parlist->{dur} = rand(abs($exp0)) }
				else { $parlist->{dur} = $parlist->{dur}*$exp0 }
			}
			ENDXDUR:
		} ## END if defined inseth->dur. 
		if (defined $CsgObj->inseth->{$set}{xamp}){
			## Here do the normal Xfun computation if any..
			&Csgrouper::Describe($subname,"note $i ==========================> xamp a");
			goto ENDXAMP unless (defined ${$CsgObj->inseth->{$set}{xamp}}[0]);
			&Csgrouper::Describe($subname,"note $i ##########################> xamp b");
			my $exp0 = ${$CsgObj->inseth->{$set}{xamp}}[0];
			$exp0 = eval($exp0) if (eval($exp0));
			if (defined $CsgObj->inseth->{$set}{xamp}[1]){
				my $exp1 = ${$CsgObj->inseth->{$set}{xamp}}[1];
				$exp1 = eval($exp1) if (eval($exp1));
				$parlist->{amp} = $exp1 if ($parlist->{amp} > $exp1);
				$parlist->{amp} = $exp0 if ($parlist->{amp} < $exp0);
			}
			else { ## Scalar factor (0.5) e.g.
				if ($exp0 < 0) { $parlist->{amp} = rand(abs($exp0)) }
				else { $parlist->{amp} = $parlist->{amp}*$exp0 }
			}
			ENDXAMP:
		} ## END if defined inseth->amp. 
		if (defined $CsgObj->inseth->{$set}{xhus}){
			## Here do the normal Xfun computation if any..
			my $ref = $CsgObj->sequences->{$spref}->tree->notes->{$i};
			goto ENDXHUS unless ($ref->scmp2 == 1 || $ref->scmp3 == 1); 
			$parlist->{amp} = 0;
			&Csgrouper::Describe($subname,"note $i ==========================> xhus a");
			## xhus sets xamp to 0..
			## No override for now: either the note is played or not.
			ENDXHUS:
		} ## END if defined inseth->amp. 
		if (defined $CsgObj->inseth->{$set}{xatk}){ ## ATTACK
			## Here do the normal Xfun computation if any..
			&Csgrouper::Describe($subname,"note $i ==========================> xatk a");
			goto ENDXATK unless (defined ${$CsgObj->inseth->{$set}{xatk}}[0]);
			&Csgrouper::Describe($subname,"note $i ##########################> xatk b");
			## Here we set both atk and rel.
			## 2 duration factor params whose sum is less than 1.
			my $exp0 = ${$CsgObj->inseth->{$set}{xatk}}[0];
			$exp0 = eval($exp0) if (eval($exp0));
			if (defined $CsgObj->inseth->{$set}{xatk}[1]){
				my $exp1 = ${$CsgObj->inseth->{$set}{xatk}}[1];
				$exp1 = eval($exp1) if (eval($exp1));
				$parlist->{atk} = ($exp0*$parlist->{atk});
				$parlist->{rel} = ($exp1*$parlist->{rel});
			}
			else { ## Scalar factor:
				goto ENDXATK if ($exp0*2 > 1);
				$parlist->{atk} = $exp0*$parlist->{atk};
				$parlist->{rel} = $exp0*$parlist->{rel};
			}
			ENDXATK:
		} ## END if defined inseth->atk. 
		if (defined $CsgObj->inseth->{$set}{xpan}){
			## Here do the normal Xfun computation if any..
			&Csgrouper::Describe($subname,"note $i ==========================> xpan a");
			goto ENDXPAN unless (defined ${$CsgObj->inseth->{$set}{xpan}}[0]);
			&Csgrouper::Describe($subname,"note $i ##########################> xpan b");
			## Here we set both pa1 and pa2.
			my $exp0 = ${$CsgObj->inseth->{$set}{xpan}}[0];
			$exp0 = eval($exp0) if (eval($exp0));
			## 3 factor params:
			if (defined $CsgObj->inseth->{$set}{xpan}[1]){
				my $exp1 = ${$CsgObj->inseth->{$set}{xpan}}[1];
				$exp1 = eval($exp1) if (eval($exp1));
				my $exp2 = ${$CsgObj->inseth->{$set}{xpan}}[2]//= (1-$exp1);
				$exp2 = eval($exp2) if (eval($exp2));
				goto ENDXPAN  if ($exp0>1);
				goto ENDXPAN  if ($exp1>1-$exp0);
				goto ENDXPAN  if ($exp2>1);
				$parlist->{pa1} = $exp0;
				$parlist->{pa2} = $exp1;
				$parlist->{del} = $exp2;
			}
			else { ## Scalar factor:
				goto ENDXPAN  if ($exp0 > 1); ## Each pan can be set from 0 to 1.
				$parlist->{pa1} = $exp0;
				$parlist->{pa2} = 1-$exp0;
				$parlist->{del} = 0.5; ## Default del.
			}
			ENDXPAN:
		} ## END if defined inseth->pan. 
		if (defined $CsgObj->inseth->{$set}{xgli}){
			## Here do the normal Xfun computation if any..
			goto ENDXGLI unless (defined $CsgObj->sequences->{$spref}->tree->notes->{($i+1)});
			my $ref = $CsgObj->sequences->{$spref}->tree->notes->{$i};
			my $targ = $CsgObj->sequences->{$spref}->tree->notes->{($i+1)};
			goto ENDXGLI unless ($ref->ocmp2 == $ref->ocmp3); ## indio == inoto
			my $ins = $CsgObj->sequences->{$spref}->instr; ## Instr. id.
			my $freqtype = $CsgObj->instruments->{$ins.'_freq_type'};
			&Csgrouper::Describe($subname,"note $i ==========================> xgli a");
			if ($freqtype =~ /midi/){
					goto ENDXGLI; ## No glissandi for midi notes?
			}
			elsif ($freqtype =~ /cps/) { ## cps and cpspch
				$parlist->{fq2} = $targ->fq1;
				$parlist->{fq3} = $targ->fq1 unless ($ref->ocmp1 == $ref->ocmp2); ## TODO : Check for a better criterium for gauss curve frequency shift here. 
				&Csgrouper::Debug($subname,"note $i xgli fq1=".$parlist->{fq1}." fq2=".$parlist->{fq2});
				$parlist->{pc2} = $targ->pc1;
				$parlist->{pc3} = $targ->pc1 unless ($ref->ocmp1 == $ref->ocmp2); ## TODO : Check for a better criterium for gauss curve frequency shift here. 
			}
			goto ENDXGLI unless (defined ${$CsgObj->inseth->{$set}{xgli}}[0]);
			&Csgrouper::Describe($subname,"note $i ##########################> xgli b");
			## Here we set both gl1,gl2 and hd1,hd2.
			## 4 factor params:
			my $exp0 = ${$CsgObj->inseth->{$set}{xgli}}[0];
			$exp0 = eval($exp0) if (eval($exp0));
			if (defined $CsgObj->inseth->{$set}{xgli}[1]){
				my $exp1 = ${$CsgObj->inseth->{$set}{xgli}}[1];
				$exp1 = eval($exp1) if (eval($exp1));
				my $exp2 = ${$CsgObj->inseth->{$set}{xgli}}[2];
				$exp2 = eval($exp2) if (eval($exp2));
				my $exp3 = ${$CsgObj->inseth->{$set}{xgli}}[3];
				$exp3 = eval($exp3) if (eval($exp3));
				goto ENDXGLI if (($exp0+
								  $exp1+
								 ($exp2//= 0)+
								 ($exp3//= 0))>1);
				$parlist->{gl1} = $exp0;
				$parlist->{hd1} = $exp1;
				$parlist->{gl2} = $exp2;
				$parlist->{hd2} = $exp3;
			}
			else { ## Scalar factor:
				goto ENDXGLI if (abs($exp0) > 1);
				$parlist->{gl1} = $exp0;
				$parlist->{hd1} = 1-$parlist->{gl1};
				$parlist->{gl2} = 0;
				$parlist->{hd2} = 0;
			}
			ENDXGLI:
		} ## END if defined inseth->gli. 
	} ## END foreach set.
	## Now that overwriting has been done at Set level, it must be
	## done at Sequence level too:
  $Csgrouper::DEBFLAG =  $oldebflag;
	&overdef($parlist,$spref,$i);
} ## END overfun().

=item * setpval($val,$fun,$seqid,$index) : reports a param value into its specific Note object containers.
=cut

sub setpval {
  my ($val,$fun,$spref,$i) = @_; 
  my $subname = "setpval";
  # { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  goto SETPVALEND unless (defined $val);
	my $ref = $CsgObj->sequences->{$spref}->tree->notes->{$i};
  ## $ref->$fun($val) unless (not $ref->meta->get_attribute($fun)); ## metaclass syntax.
	my $instr = $CsgObj->sequences->{$spref}->instr; ## Instr. id.
	my $parnum = $CsgObj->instruments->{$instr.'_parnum'}; ## Number of p-values.
	my @standard = qw(ins sta dur); my $norm = $Csgrouper::CSG{fractail};
	$val =~ s/^(.+\.\d{$norm})(.+)$/$1/; ## Normalize.
	if ($fun ~~ @standard) {
		if ($fun =~ /ins/) {
			$ref->csph->{1} = $val ;
			$ref->ins($val);
		}
		elsif ($fun =~ /sta/) {
			$ref->csph->{2} = $val ;
			$ref->sta($val);
		}
		elsif ($fun =~ /dur/) {
			$ref->csph->{3} = $val ;
			$ref->dur($val);
		}
		return 1;
	}
	for (my $p = 4; $p <= ($parnum+2); $p++) { 
		&Csgrouper::Debug($subname, "p=$p fun=$fun val=$val ifun=".$CsgObj->instruments->{$instr.'_p'.$p.'_fun'});	
		if ($CsgObj->instruments->{$instr.'_p'.$p.'_fun'} =~ /^($fun)$/){
			$ref->csph->{$p} = $val;	
			return 1;
		}
	}
	return 1;
	SETPVALEND:
	&Csgrouper::Debug($subname, "$spref : $i: couldn't set p-value for $fun = $val.");
  $Csgrouper::DEBFLAG = $oldebflag;
  return 0;
} ## END setpval().

## ###  END Xfun SUBS 

=back

=head2 Yfun Subroutines

=over

=item * Yfun() : applies relationnal functions to track contents. 
=cut

sub Yfun {
  my $subname = "Yfun";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
	my $osep = $Csgrouper::OBJSEP; my $ssep = $Csgrouper::SETSEP;
	my $test = 0; 
	my %inseth = %{$CsgObj->inseth};
	while (my($set,$val) = each %inseth){
		$test = 1; ## There can be no relationnal function request.
		my $funs;
		&Csgrouper::Describe($subname, "inseth $set =>");
		while (my($key,$cont) = each %$val){
			&Csgrouper::Describe($subname, "$key => ".join '' ,@$cont);
			$funs .= $key;
		}
		next if ($funs !~ /(yryc)|(yens)/);
		&yryc($set) if ($funs =~ /yryc/);
		&yens($set) if ($funs =~ /yens/);
	}
	return $test;
} ## END Yfun().

=item * yryc() : yryc relationnal function. 

The precedence question can be solved in different ways:

	a) by setting a "pcd" instrument param;
	b) by proposing a specific order for concerned sequences as optional string;
	c) letting the sub manage the question, in which case precedence is set to 1 
	   for every instrument and time inversion is allowed: the model instrument is
	   the first one, if the mime target note starts before the model note it's ok.

However there remain other issues to solve for rythmic canon. Suppose we have 
more than 2 sequences in the set, how will they behave? We could have  one model
and each other sequence as mime in its turn, or several models and mimes. 
We'll retain these 2 schemes of interaction: 

	scheme A. Default: The model interacts successively with each other sequence.
	scheme B. The sequences are ordered as pairs of model mime, in alternance:
	
		S1-mod => S2-mim
		S2-mod => S3-mim
		S3-mod => S1-mim

We could think of other schemes in the future like one model-mime schema repeated
with each other sequences (that is all sequences playing together under the same
mime definition).
		
Note class has a ryc attribute that is a num type and receives 0 as default
value. When the note is a model it will receive its own sequence id as value, when
it's a mime it will show the sequence id of the model followed by a dot and the 
model note id.

The number of notes between the model and the mime starting notes: this value is
set by the following criterium: int(int(@scmp1[$n])+2)/2 take from the model sequence. 
The main identifier is the index of the note and not its time location, thus
mime can precede models in some cases.

The problem of Sequence size: the rythmic canon ends as soon as there are no more
notes left in the model or in the mime sequence.

The problem of Sequence tail: all trailing notes after a mime section have to be 
updated with a new time location. This justifies the use of a specific subroutine
to this effect: timeline().


=cut

sub yryc {
	my ($set) = @_;
  my $subname = "yryc";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
	my $test = 0; 
	my %inseth = %{$CsgObj->inseth};
	my @setseqs =  @{$CsgObj->sets->{$set}->{'sids'}}; 
	my @setpars = @{$inseth{$set}{'yryc'}};
	## Define the model-mime scheme:
	my $scheme = $setpars[0]//= "";
	## Imposed order:
	my @ordseqs; my $model; my $mime;
	foreach (@setpars) { ## Put the required sequences first..
		my $seq = $_;
		push @ordseqs,$seq if ($seq ~~ @setseqs);
	}
	foreach (@setseqs) { ## Then the ones that were not in params..
		my $seq = $_;
		push @ordseqs,$seq unless ($seq ~~ @ordseqs);
	}
	if ($scheme =~ /B/i)  { ## The sequences are ordered as pairs of model mime, in alternance.
		## This model is more sutbile and generates less interactions.
		my $ndep = 0; my $sdep = 0;
		&Csgrouper::Describe($subname, "Scheme B (@ordseqs).");
		foreach (@ordseqs) {
			my $model = $_;	my $modspref = "Seq_".$model;	
			&Csgrouper::Describe($subname, "Model is now Seq. $model.");
			for ($sdep; $sdep < (@ordseqs); $sdep++) {
				my $mime = $ordseqs[$sdep]; my $mimspref = "Seq_".$mime;	
				next if ($model == $mime); $test = 0; my $prev;
				## Now define the model-mime gap (scmp1 value/2):
				next unless (defined $CsgObj->sequences->{$mimspref}->tree->notes->{$ndep});	
				my $gap = int((&Csgrouper::Dodecad($CsgObj->sequences->{$mimspref}->tree->notes->{$ndep}->scmp1)+2)/2);
				&Csgrouper::Describe($subname, "Mime is now Seq. $mime, gap=$gap.");
				for ($ndep; $ndep < $CsgObj->sequences->{$mimspref}->tree->size; $ndep++){
					my $modref = $CsgObj->sequences->{$modspref}->tree->notes->{($ndep)};
					next unless (defined $CsgObj->sequences->{$mimspref}->tree->notes->{($ndep+$gap)});	
					my $mimref = $CsgObj->sequences->{$mimspref}->tree->notes->{($ndep+$gap)};
					next unless ($test == 1 || $mimref->eqcmp1 =~ /$Csgrouper::OBJSEP$model$Csgrouper::OBJSEP/);	
					## In the following case we reached the starting point for this canon:
					if ($test == 0 && $mimref->eqcmp1 =~ /$Csgrouper::OBJSEP$model$Csgrouper::OBJSEP/) {
						&Csgrouper::Describe($subname, "Starting point reached at  note ".($ndep+$gap).".");
						$prev = $mimref->sta;
					}
					## In the following case we reached the stopping point for this canon:
					if ($test == 1 && $mimref->eqcmp1 =~ /$Csgrouper::OBJSEP$model$Csgrouper::OBJSEP/){
						&Csgrouper::Describe($subname, "Stopping point reached at  note ".($ndep+$gap).".");
						timeline($mimspref,($ndep+$gap),$prev,0);
						$test = 0;
						next ;
					}	
					$test = 1; ## We start a model-mime section:
					## Do the job:
					&setpval($modref->dur,'dur',$mimspref,($ndep+$gap));
					&setpval($prev,'sta',$mimspref,($ndep+$gap));
					$mimref->dur($modref->dur);
					$mimref->ryc("$model.$ndep");
					$prev += $mimref->dur; ## Prepare the next prev.
				}	## END for tree.
				last if ($test == 1); ##
			} ## END s in ordseqs.
		} ## END foreach ordseqs 1.
	} ## END scheme B.
	else { ## Default scheme: The model interacts successively with each other sequence.
		$model = shift @ordseqs; my $modspref = "Seq_".$model;	
		&Csgrouper::Describe($subname, "Scheme A (@ordseqs).");
		&Csgrouper::Describe($subname, "Model is Seq. $model.");
		foreach (@ordseqs) {
			my $mime = $_; 
			&Csgrouper::Describe($subname, "Treating Seq. $mime.");
			my $mimspref = "Seq_".$mime;	my $ndep = 0;
			next if ($model == $mime); $test = 0; my $prev;
			## Now define the model-mime gap (scmp1 value/2):
			next unless (defined $CsgObj->sequences->{$mimspref}->tree->notes->{$ndep});	
			my $gap = int((&Csgrouper::Dodecad($CsgObj->sequences->{$mimspref}->tree->notes->{$ndep}->scmp1)+2)/2);
			&Csgrouper::Describe($subname, "Mime is now Seq. $mime, gap=$gap.");
			for ($ndep; $ndep < $CsgObj->sequences->{$mimspref}->tree->size; $ndep++){
				next unless (defined $CsgObj->sequences->{$modspref}->tree->notes->{($ndep)});	
				my $modref = $CsgObj->sequences->{$modspref}->tree->notes->{($ndep)};
				next unless (defined $CsgObj->sequences->{$mimspref}->tree->notes->{($ndep+$gap)});	
				my $mimref = $CsgObj->sequences->{$mimspref}->tree->notes->{($ndep+$gap)};
				next unless ($test == 1 || $mimref->eqcmp1 =~ /$Csgrouper::OBJSEP$model$Csgrouper::OBJSEP/);	
				## In the following case we reached the starting point for this canon:
				if ($test == 0 && $mimref->eqcmp1 =~ /$Csgrouper::OBJSEP$model$Csgrouper::OBJSEP/) {
					&Csgrouper::Describe($subname, "Starting point reached at  note ".($ndep+$gap).".");
					$prev = $mimref->sta;
				}
				## In the following case we reached the stopping point for this canon:
				elsif ($test == 1 && $mimref->eqcmp1 =~ /$Csgrouper::OBJSEP$model$Csgrouper::OBJSEP/){
					&Csgrouper::Describe($subname, "Stopping point reached at  note ".($ndep+$gap).".");
					timeline($mimspref,($ndep+$gap),$prev,0);
					$test = 0;
					next ;
				}	
				$test = 1; ## We start a model-mime section:
				## Do the job:
				&setpval($modref->dur,'dur',$mimspref,($ndep+$gap));
				&setpval($prev,'sta',$mimspref,($ndep+$gap));
				$mimref->dur($modref->dur);
				$mimref->ryc("$model.$ndep");
				$prev += $modref->dur; ## Prepare the next prev.
			}	## END for tree.
		}## END foreach ordseqs 1.
	} ## END scheme A.
	return $test;
} ## END yryc().

=item *  tabs($n) : outputs spaces for printing purpose.
=cut

sub tabs { ## 
  my ($n) = @_; 
  my $subname = "tabs";
  # { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  my $out = "";
	for (my $i = 0; $i < $n; $i++){
		$out .= " ";
	} ## END for i note in tree.
  $Csgrouper::DEBFLAG =  $oldebflag;
  return $out;
} ## END timeline().

=item *  timeline($seqid) : resets notes start points of a sequence from most recent data.
=cut

sub timeline { ## 
  my ($spref,$note,$point,$silence) = @_; 
  my $subname = "timeline";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
  $note//=0; $point//=0;  $silence//=0;
	my $instr = $CsgObj->sequences->{$spref}->instr; ## Instr. id.
	my $parnum = $CsgObj->instruments->{$instr.'_parnum'}; ## Number of p-values.
  my $prevstart = $point; my $prevdur = $silence; my $start;
	&Csgrouper::Describe($subname, "Resetting notes for Seq $spref from note $note.");
	for (my $i = $note; $i < $CsgObj->sequences->{$spref}->tree->size; $i++){
		my $ref = $CsgObj->sequences->{$spref}->tree->notes->{$i};
		$start = $prevstart + $prevdur;
		&setpval($start,'sta',$spref,$i);
		$prevstart = $start; $prevdur = $ref->dur;
	} ## END for i note in tree.
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END timeline().

=item * yens() : yens relationnal function. 
=cut

sub yens {
	my ($set) = @_;
  my $subname = "yens";
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG;
  # $Csgrouper::DEBFLAG = 1;
	my @setseqs =  @{$CsgObj->sets->{$set}->{'sids'}}; 
	my %inseth = %{$CsgObj->inseth};
	&Csgrouper::Describe($subname, "Seqs for set $set = @setseqs.");
	## Find the precedence value for each sequence:
	my @preseqs; my @instpcd;
	for (my $r = 0; $r < scalar(@setseqs); $r++) {
		my $spref = "Seq_".$setseqs[$r];
	  $instpcd[$r] = "1$SEPA".$setseqs[$r]; ## Default precedence value.
		## Get precedence value:
		next if (not defined $CsgObj->defaults->{$spref}->{'pcd'});
		$instpcd[$r] = $CsgObj->defaults->{$spref}->{'pcd'}.$SEPA.$setseqs[$r] ;
	} ## END for setseqs
	## Recreate a precedence ordered list of sequences:
	sort @instpcd; splice @setseqs;
	foreach (@instpcd) { my $s = $_ ; $s =~ s/^(\d+$SEPA)(\d+)$/$2/; push @setseqs, $s } 
	&Csgrouper::Describe($subname, "PCD for set $set = @setseqs.");
	## List params:
	my @setpars = @{$inseth{$set}{'yens'}};
	## Define the model-mime scheme:
	my $scheme = $setpars[0]//= "";
	## Imposed order:
	my @ordseqs; my $model; my $mime;
	foreach (@setpars) { ## Put the required sequences first..
		my $seq = $_;
		push @ordseqs,$seq if ($seq ~~ @setseqs);
	}
	foreach (@setseqs) { ## Then the ones that were not in params..
		my $seq = $_;
		push @ordseqs,$seq unless ($seq ~~ @ordseqs);
	}
	my $test = 0; 
	if ($scheme =~ /B/i)  { ## The sequences are ordered as pairs of model mime, in alternance.
		## This model is more sutbile and generates less interactions.
		my $ndep = 0; my $sdep = 0;
		&Csgrouper::Describe($subname, "Scheme B (@ordseqs).");
		foreach (@ordseqs) {
			my $model = $_;	my $modspref = "Seq_".$model;	
			&Csgrouper::Describe($subname, "Model is now Seq. $model.");
			for ($sdep; $sdep < (@ordseqs); $sdep++) {
				my $mime = $ordseqs[$sdep]; my $mimspref = "Seq_".$mime;	
				&Csgrouper::Describe($subname, "Mime is now Seq. $mime.");
				next if ($model == $mime); $test = 0; my $prev;
				for ($ndep; $ndep < $CsgObj->sequences->{$mimspref}->tree->size; $ndep++){
					my $modref = $CsgObj->sequences->{$modspref}->tree->notes->{$ndep};
					next unless (defined $CsgObj->sequences->{$mimspref}->tree->notes->{$ndep});	
					my $mimref = $CsgObj->sequences->{$mimspref}->tree->notes->{$ndep};
					next unless ($test == 1 || $mimref->eqcmp2 =~ /$Csgrouper::OBJSEP$model$Csgrouper::OBJSEP/);	
					## In the following case we reached the starting point for this canon:
					if ($test == 0 && $mimref->eqcmp2 =~ /$Csgrouper::OBJSEP$model$Csgrouper::OBJSEP/) {
						&Csgrouper::Describe($subname, "Starting point reached at  note $ndep.");
						$prev = $modref->sta; ## Here we hope not to overlap previous notes but it's possible.
					}
					## In the following case we reached the stopping point for this canon:
					if ($test == 1 && $mimref->eqcmp2 =~ /$Csgrouper::OBJSEP$model$Csgrouper::OBJSEP/){
						&Csgrouper::Describe($subname, "Stopping point reached at  note $ndep.");
						timeline($mimspref,$ndep,$prev,0);
						$test = 0;
						next ;
					}	
					$test = 1; ## We start a model-mime section:
					## Do the job:
					&setpval($modref->dur,'dur',$mimspref,$ndep);
					&setpval($prev,'sta',$mimspref,$ndep);
					$mimref->dur($modref->dur);
					$mimref->ens("$model.$ndep");
					$prev += $modref->dur; ## Prepare the next prev.
				}	## END for tree.
				last if ($test == 1); ##
			} ## END s in ordseqs.
		} ## END foreach ordseqs 1.
	} ## END scheme B.
	else { ## Default scheme: The model interacts successively with each other sequence.
		$model = shift @ordseqs; my $modspref = "Seq_".$model;	
		&Csgrouper::Describe($subname, "Scheme A (@ordseqs).");
		&Csgrouper::Describe($subname, "Model is Seq. $model.");
		foreach (@ordseqs) {
			my $mime = $_; 
			&Csgrouper::Describe($subname, "Treating Seq. $mime.");
			my $mimspref = "Seq_".$mime;	my $ndep = 0;
			next if ($model == $mime); $test = 0; my $prev;
			&Csgrouper::Describe($subname, "Mime is now Seq. $mime.");
			for ($ndep; $ndep < $CsgObj->sequences->{$mimspref}->tree->size; $ndep++){
				my $modref = $CsgObj->sequences->{$modspref}->tree->notes->{$ndep};
				next unless (defined $CsgObj->sequences->{$mimspref}->tree->notes->{$ndep});	
				my $mimref = $CsgObj->sequences->{$mimspref}->tree->notes->{$ndep};
				next unless ($test == 1 || $mimref->eqcmp2 =~ /$Csgrouper::OBJSEP$model$Csgrouper::OBJSEP/);	
				## In the following case we reached the starting point for this canon:
				if ($test == 0 && $mimref->eqcmp2 =~ /$Csgrouper::OBJSEP$model$Csgrouper::OBJSEP/) {
					&Csgrouper::Describe($subname, "Starting point reached at  note $ndep.");
					$prev = $modref->sta; ## Here we hope not to overlap previous notes but it's possible.
				}
				## In the following case we reached the stopping point for this canon:
				if ($test == 1 && $mimref->eqcmp2 =~ /$Csgrouper::OBJSEP$model$Csgrouper::OBJSEP/){
					&Csgrouper::Describe($subname, "Stopping point reached at  note $ndep.");
					timeline($mimspref,$ndep,$prev,0);
					$test = 0;
					next ;
				}	
				$test = 1; ## We start a model-mime section:
				## Do the job:
				next unless (defined $modref &&defined $mimref); 
				&setpval($modref->dur,'dur',$mimspref,$ndep);
				&setpval($prev,'sta',$mimspref,$ndep); 
				$mimref->dur($modref->dur);
				$mimref->ens("$model.$ndep");
				$prev += $modref->dur; ## Prepare the next prev.
			}	## END for tree.
		}## END foreach ordseqs 1.
	} ## END scheme A.
	return $test;
} ## END yens().

## ###  END Yfun SUBS 

## ###  END INTERFACE SUBS 

## ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ### 
## ###  CALLBACK SUBS : INTERFACE PACKAGE  ###  ###  ###  ###  ###  ###  ### 
## ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ###  ### 

=back

=head2 Callback Subroutines (package Csgrouperinter)
=cut

package Csgrouperinter; ## A feedback access for Csgrouper class functions.

=over

=item * Compstr0($ser) : proper string: it will be easy to introduce some randomness in computation by replacing this sub with cmpstr4.
=cut

sub Compstr0 { 
  my ($ser) = @_; ## Self:
  my $subname = "Csgrouper::Compstr0";
  # { no warnings; &says($subname, "@_"); }
	return $ser;
} ## END Compstr0

=item *  Compstr1($series) : returns a comparison string for decision making (was notindex()).
=cut

sub Compstr1 { 
  my ($ser) = @_;
  my $subname = "Csgrouperinter::Compstr1";
  # { no warnings; &Csgrouper::says($subname, "@_"); }
  ## The use of Imap allows indistinct elements and modes.
	return &Csgrouper::Dimap(&Csgrouper::Powerp(&Csgrouper::Natural($ser),&Csgrouper::Imap($ser),2),$ser);
}

=item *  Compstr2($series) : returns a comparison string for decision making (was indexi()).
=cut

sub Compstr2 {
  my ($ser) = @_; 
  my $subname = "Csgrouperinter::Compstr2";
  # { no warnings; &Csgrouper::says($subname, "@_"); }
  ## The use of Imap allows indistinct elements and modes.
	return &Csgrouper::Dimap(&Csgrouper::Powerp(&Csgrouper::Natural($ser),&Csgrouper::Imap($ser),-1),$ser);
} ## END Compstr2

=item *  Compstr3($series) : returns a comparison string for decision making (was indexnot()).
=cut

sub Compstr3 { 
  my ($ser) = @_; 
  my $subname = "Csgrouperinter::Compstr3";
  # { no warnings; &Csgrouper::says($subname, "@_"); }
  ## The use of Imap allows indistinct elements and modes.
	return &Csgrouper::Dimap(&Csgrouper::Powerp(&Csgrouper::Natural($ser),&Csgrouper::Imap($ser),-2),$ser);
} ## END Compstr3

##  END FEEDBACK SUBS


=item *  Compstr4($series) : returns a random string for decision making.
=cut

sub Compstr4 { 
  my ($ser) = @_;
  my $subname = "Csgrouperinter::Compstr4";
  # { no warnings; &Csgrouper::says($subname, "@_"); }
  my @seq = split //,$ser;
  my @res;  
  foreach my $el (@seq) {
  	my $test = 0;
		while ($test == 0) {
			my $ran = int(rand(scalar(@seq)));
			$res[$ran]//=""; 
			if ($res[$ran] =~ /.+/) { next }
			else { 
				$res[$ran] = $el;
				$test = 1;
			}
		}
  }
	return join '',@res;
} ## END Compstr4

1;
__DATA__
=back

=head1 Data Section

=head2 Command lines

	&Csgrouper::says($subname, $Part->{'Seq_2_name'};
	&Csgrouper::says($subname, $Sequences{Seq_1_sel});
	$DEBUG = 1; $DEBUG = 0;
	print &Csgrouper::Map(&Csgrouper::Oppose("089AB2145673"),"089AB2145673"); ## (=289A14365B70).
	print &Csgrouper::Omap("089AB2145673"); ## (=289A14365B70).
	print &Csgrouper::Compstr4("302415");
	print &Csgrouper::Imap("22013"); 
	print $Man_top_tw->PathName;
  print $Man_top_tw->optionGet('foreground', ref $Man_top_tw); # Nice ref syntax!
  print $Man_top_tw->optionGet('background', ref $Man_top_tw); # Prints bisque default: #ffe4c4.
  print $Man_top_tw->optionGet('background', 'Csgrouper.pl'); # Class name for this program is file name capitalized.
  print $Man_top_tw->optionGet('background', 'Csgrouper'); # Suffixe can be ommited.  # Prints bisque default: #ffe4c4.
  print $mw->Frame(-class => 'the_frames');
  print $mw->optionGet('foreground', 'the_frames');
  
=head2 Coding notes

- Reminder about pack: 

	some elements like NoteBook tabs require not to be packed!
	
- Beware of the Text widget bug (see workaround in code).	

- Smart matching in perl 5.10 works with Moose or Modern::Perl, use it to explore an array (quicker than a loop): 

	&says $subname,  "array contains x" if (@a ~~ 'x');
	&says $subname,  "array contains x" if (@a ~~ /x/);
	
=head2 Colors

The Tk original colorpalette is grey but black text isn't too readable then and some objects like the manual Tk::Pod::Text do not accept color settings. $CsgObj->sequences->{Seq_n}. Fortunately there's another ready made palette available which was the original Tcl-Tk palette, named "bisque" and with correct display for black text. See how to make a color palette of my own. 

=head2 Bugs

=head3 Tk Bugs

The Tk::Notebook -Podtext problem: the Podtext parameter disturbs proper Tk display here. See : my $Man_top_tw = $Tabs{'man'}->Scrolled. Perlmonks 120323 fix: use Tk::option (actually Tk::Cmdline) to override default color. 
 
The Tk::Text control chars bug: see our workaround from Perlmonks.org.

The Tk::Pod::Text bug: overwrites the main window title with the head1 entry.

The Tk::Table size bug (long strings are not displayed - but is it a bug?). 

=head3 My own bugs history

111120	The struct_ctl section bug.
111018	The sequence deletion bug.

=head4 Description

While deleting multiple sequences but after objects have been created and struct_ctl has been run: lots of sequences but not all the possible sequences are created (stops at 571 instead of 576 why?) and this process ends up with this message:
	
 (in validation command executed by entry)
Tk::Error: Can't call method "set_ready" without a package or object reference at ~/Csgrouper/lib/csgrouper.pl line 5378.
 [\&main::__ANON__]
 (in validation command executed by entry)
	
When deleting the same sequences before struct_ctl, the job is done but ends like:

Tk::Error: Can't call method "set_ready" without a package or object reference at ~/Csgrouper/lib/csgrouper.pl line 5388.
 \\&main::__ANON__
 (in validation command executed by entry)

struct_ctl seems to be creating unnecessary sequences as Tkrow entries, when I delete my 4 sequences and keep 1  I only delete 4 of 576 = 572...

=head4 Solution

I had the following line in the begining of the struct_ctl() loop:

	$self->sequences->{$tpref."_id"}//= "";

so the object was created...


=cut
