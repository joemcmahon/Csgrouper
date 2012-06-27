###############################################################################
## ### FILE INFO: Csgrouper.pm.
###############################################################################
## 110807.
## An object oriented set for Csgrouper.

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

## Encoding of this document: iso 8859-1
## END FILE INFO.

=head1 Manual for Csgrouper.pm 

=head2 Todo

=head2 The Csgrouper Objects  	

Every Csgrouper class objects has a boolean 'ready' attribute that dosn't have the same meaning depending on the object.

Csgrouper object is ready when time strutcture has been construed.

Sequence object is ready when the tree has been built.

Series object is ready when its note objects have been created.

Note object is ready when its minimal set of params (dur, freq, amp) have been set.

=head3 Instruments

Csg required parameters are specified in the Orchestra tab - for example attack = p10 - this information is then used by Csdata(). These parameters are attributed in the instrument table below each instrument param.

=head3 Score:

Csgrouper score tab is the csound .csd score file ready to import in Blue for example. 

=head3 F-tables:

=head3 Sequences:

=head4 Sets

Precedence is achieved through the attribution of sequences to sets of sequences later ordered by section.

As long as sets are not subject to grouping (see below) their content will be played simultaneously. For example, a set 10 containing sequences 22, 23, 24 can be the treated by meta function Xpan when the set number 11 will itself be subject to Xrep but not Xpan, and they finally will both be played together.

=head4 Sections

Now sets can be grouped so as to beggin only when previous ones have been played. To achieve this we group sets in the "Sections" field of the Part Tab. To pursue our example, a second section could beggin after sets 10 and 11 have finished. To do this we create 2 sections in the Sections field this way: 10,11;12,13. Now whatever happens to sets in the first section (10,11) will not concern sets in the second (12,13) and these will follow the first section as if it was a new composition. This is the manner we found to achieve non automated sections. A sequence can pertain to several sets but it will be repeated only when these sets do not pertain to the same section.

=head4 Preliminary sequences

Besides section groupings, preliminary sequences represent another means for temporal precedence. Each sequence has a preliminary sequence that defaults to the sequence itself. Leaving a sequence defaults to be its own preliminary let us free to assign it to any set whatsoever, but as soon as we bind two sequences together by means of preliminary sequencing, the set attribution becomes sensitive. This is the major potential source of errors in Csgrouper since a sequence cannot pertain to a set that is a member of a section that in turn does not contain its preliminary sequence. In such cases the function struct_ctl will ignore the concerned sequence and complain to stdout about the error. struct_ctl will also ignore sequences that are simply not selected.

=head3 Tracks

When struct_ctl has filtered out what could possibly result in a pertinent project writing, this function records a global hash called %TracksH representing the time branches in the various sections. These tracks are the last step before CSD production, however they do not yet represent real sound tracks in the sense that they show repeated, some content that later will only be played once. For instance, a section 1 could contain a first track written _1_2_ in %TracksH and meaning that sequence 1 is followed by sequence 2, but the same section can contain a second track written _1_3_ and meaning that sequence 1 is also followed by sequence 3. In the final csound file though, sequence 1 will only be played once. In %TracksH, the repetition of a preliminary only indicates a time position. 

B<NOTE on tracks:> 

As no more change can be made to the project at struct_ctl stage, the sequences in %TracksH are defined by row numbers not sequence ids (which were the original row numbers). This helps make things simpler in the following treatment, however when attributing a preliminary to a sequence one must refer to the sequence id because a later sequence addition or deletion will change whole bunches of row numbers but no sequence id.  

=head3 Information gathered by struct_ctl

	%SectionsH:
		$SectionsH{'size'} = total number of sections, additional section included; 
		@{${$SectionsH{$gnbr}}{'sets'}} = sets for section $gnbr, invalid ones included; 
		@{${$SectionsH{$gnbr}}{'sequences'}} = sequences for section $gnbr, invalid ones included; 
		@{${$SectionsH{$gnbr}}{'tracks'}} = tracks for section $gnbr: only valid sequences included; 
	
	%SetsH:
		$SetsH{'size'} = total number of sets; 
		@{$SetsH{'$s'}} = sets for sequence $s; 
	
	%TracksH:
		$TracksH{'size'} = total number of tracks (not sections); 
		@{$TracksH{$gnbr}} = the various tracks for section $gnbr, splits included;

B<NOTE on sections:>

The last SectionsH key refers to sets that pertain to no section and sequences that pertain to no set.

By default these orphans will be treated as an additional section at the end.

The order given to the sets in the Sections field will be the order of Xfun applications, thus for example. if we choosed to list sets of the first section as "11,10" instead of "10,11", then  if Xsec and Xryc were defined for these sets and a sequence 1 pertained to both of them when a sequence 2 pertained to set 10 only, sequence 1 would first be treated by Xsec before Xryc and this fact has huge consequences on the tempo of these sequences.

=head2 Subroutines

=head3 Naming

Names of subroutines that return non objectual values (like Datem) and that are meant to be called from various packages beggin uppercase, unlike object functions and attributes or purely local subs.  These uppercase subroutines are most of the time public.
  
=head3 Private Subroutines

=head3 Public Subroutines:

This is not the proper Object Oriented way of doing things, but as an interface may offer some command-line functions to test various permutational figures, I felt it was necessary to offer some flexibility here and not require serial objects to exist on each occasion. Some of the routines below are duplicated by Series.pm in an object oriented way with small differences in serial treatment (see revert(), invert()).

=head4 Express:

This is a subroutine used by Train(s) in order to print intermediary results.
The variable $CSG{Sflag} has to be set to 0 then the routine will set it to 33
after first call, enabling various data to be printed under special headers.
The calling scheme is thus:

	my $oldSflag = $Csgrouper::CSG{'Sflag'};
	$Csgrouper::CSG{'Sflag'} = 0;
	Train()..
	$Csgrouper::CSG{'Sflag'} = $oldSflag;

=head4 Difference between Gradomap and Supergrad:

Gradomap which is an unmapped suite of gradual omaps. Supergrad takes the omap of each preceding element till one is repeated. Then it checks the positionof of the repeated element in the suite, i.e. the cycle, and the number of elements (the degree).

=head4 Oppgrad:

When Gradual suite starts from a row and stops just before the Natural series, Oppgrad starts from the opposite of the original to reach it at the end.

=head4 RandCond(cols,params):

  param string in the form: "PARAM1=value1 PARAM2=value2" where :

 	param is taken among: ('DEG','CYC','ICT','INT','MOD','MOT','TYP'),

 	and values are type corresponding strings (deg, mod and mot are ints);
  
  Example: 

  	&Randcond(12,"DEG=10 TYP=01220130000 MOD=15 LIM=100");
  	
=head4 Trains:

	Don't forget that the 'steps' param is n.
=cut

package Csgrouper;
use Modern::Perl;
use POSIX qw(floor ceil);
use Moose;
use Moose::Util::TypeConstraints;
use Csgrouper::Types;

=head1 Global Section 

=cut

## ### Globals (Internal Settings):
## internals vars are typically *NOT* modified by anyone.
## BEWARE THAT Xml::Simple doesnt deal with multibyte (easily).
our 	$INSTALLDIR = $ENV{HOME};
our		$DEBFLAG							=	0; 	# Variable to test for bugs.
our		$DEBSUBS							=	'';	# Variable to test for bugs by subnames.
our 	$ERROR;
our 	$OBJSEP             	= '_';
our 	$GRPSEP             	= ';';
our 	$SETSEP             	= ','; 
our 	$PARSEP             	= '#'; ## § makes Xml::Simple fail ... 
our 	$CSGLOG             	= '';
our 	@Paramar							= (
		['name', 'description', 'comment'], ## head line
		['amp', 'amplitude', 'a direct value in the desired unit, e.g. 30 (db).'],
		['atk', 'attack duration factor [0,1]', '.'],
		['bnk', 'sf2 bank number', 'default=0'],
		['cro', 'crossfade factor', '>0<1'],
		['del', 'pan delay duration factor', '>0<1'],
		['dur', 'duration factor', 'a fraction of original duration for this instrument'],
		['gis', 'sf2 global var', 'ex: gisf1'],
		['fq1', 'frequency', 'csgrouper consider portamento and glissandi as'],
		['fq2', 'frequency', 'general params.'],
		['fq3', 'frequency', ''],
		['ft1', 'f-table id', 'an instrument may need to refer to several f-tables..'],
		['ft2', 'f-table id', 'for various params like wave, envelope, crossfade..'],
		['ft3', 'f-table id', 'buzz etc..'],
		['ft4', 'f-table id', ''],
		['gl1', 'phase 1 duration factor [0,1]', 'glissando (gli.)..'],
		['gl2', 'phase 2 duration factor [0,1]', 'overwritten by xgli'],
		['hd1', 'station 1 duration factor', ''],
		['hd2', 'station 2 duration factor', 'the gli/hd params must sum up to less than 1'],
		['hm1', 'number of harmonics in wave 1', ''],
		['hm2', 'number of harmonics in wave 2 (crossfade)', ''],
		['lfa', 'legato duration factor [0,1]', ''],
		['pa1', 'pan phase 1 side factor', '> 0.5 = left'],
		['pa2', 'pan phase 2 side factor', 'from pa1 to pa2 during del'],
		['pcd', 'precedence', '1-6: smaller values = preceding instruments'],
		['pnb', 'sf2 program number', 'default=0'],
		['reg', 'register', '*'],
		['rel', 'release duration factor [0,1]', ''],
		['rvn', 'fx number', 'selects an fx instrument'],
		['rvs', 'ratio of the sound sent to fx', '<1'],
		['sff', 'sf2 file', 'ex: Piano-Akai_Steinway_III.sf2'],
		['sre', 'sf2 register lowest:base:highest', 'ex: 24:60:107'],
);

our 	%Digh;
our 	@Digits = ("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");  
for 	(my $n = 0; $n < scalar(@Digits); $n++){ $Digh{$Digits[$n]} = $n };
our 	%Octh; ## List of base octaves for C.
my $n = 1.022; ## C-4; 8.176 = C-1.
for (my $i = 0; $i < $Csgrouper::Types::MAXBAS; $i++){	$Octh{$i} = $n ; $n = 2*$n } ## C0 = 4

our %CSG; ## Without "our" the hash wouldn't be accessible from csgrouper.

## Csgrouperinter Variables:  Revised 111122.
## An interface package made in order to overwrite some Csgrouper functions.;
	$CSG{'interface'}						=	"Csgrouperinter"; 
	$CSG{'comptype_mw'} 		= 0; ## Comparison function suffixe. Default = 0. Set it to 4 to get randomness in comparisons or define new functions and name them "CompstrN" with N>4;
	$CSG{'durtype_mw'} 		= 0; ## Duration type. Default = 0 = serial;
	$CSG{'rythmtype_mw'} 	= 1; ## Rythm type. Default = 1 = mixed;

## Setup Tabs:
	$CSG{'csg_path_pe'}				= "$INSTALLDIR/Csgrouper/";  ## Base path 
	$CSG{'run_path_pe'}				= "$INSTALLDIR/Csgrouper/run/";  
	$CSG{'render_path_pe'}		= "$INSTALLDIR/Csgrouper/run/sndout/";  
	$CSG{'bkp_path_pe'}				= "$INSTALLDIR/Csgrouper/run/bkp/";  
	$CSG{'ins_path_pe'}				= "$INSTALLDIR/Csgrouper/ins/"; 
	$CSG{'path_pe'}			= "$INSTALLDIR/Csgrouper/proj/"; 
	$CSG{'csound_sf2path_pe'}	= "$INSTALLDIR/Csgrouper/ins/sf2/"; 


## Csgrouper variables: Revised 111122.
	$CSG{'cs_midi'}						=	"48"; ## Rarely used.
	$CSG{'cs_after'}					=	""; ## Rarely used.
	$CSG{'cs_before'}					=	"i1 + 1 65"; ## Rarely used.
	
	$CSG{'csg_appl'} 					= "csgrouper"; ## Rarely used.
	$CSG{'csg_status'} 				= ""; ## Not used enough..
	# versioning: V.R.r : Version, Release, revision.
	$CSG{'csg_version'} 			= '2.0.2'; # 2.0.1 111122; 2.0.2 : 120625 (first important revision).
	$CSG{'csg_label'} 				= 2 ; ## Version
	$CSG{'cline'}							= '$CsgObj->sequences->{Seq_1}->tree->notes->{0}->Shownote()';
	$CSG{'char_set'} 					= '0123456789ABCDEFGHIJKLMN';
	$CSG{'default_mode'} 			= "0123456789AB"; ## Default mode for a whole project.
	$CSG{'default_tone'} 			= "0"; ## Default tone for a whole project.
	$CSG{'durmin_le'} 		= '0.125'; ## The minimal duration that will be multiplied by 1, 2 or 3 (depending on the binary, ternary or mixed rythm setup).
	$CSG{'durfac_le'} 		= '12'; ## A factor of dur_norm.
	## The normal minimal duration: result of durmin_le*rythm_type.
	$CSG{'ft_base'} 					= '10' ; ## The default ftable (a sine).
	$CSG{'ftb_ran'} 					= 90000; ## Randomness: Pseudo random f-tables ids start at this value.
	$CSG{'fractail'} 					= 4		 ; ## Floating tail length.
	$CSG{'min_amp'} 					=	'0'  ; ## Minimal amplitude under xsil.
	$CSG{'oct_max'} 					= '12'  ;
	$CSG{'oct_base'} 					= '7'  ; ## The native octave location from 0 to $CSG{'oct_max'}
	$CSG{'oct_range'}					= '1'  ; ## The native octave variation range.
	
	$CSG{'separator'}					= ":"  ; ## Unused yet.
	$CSG{'Sflag'} 						= 0		; ## Flag for train printings. 
	
## CSD Tab:
	$CSG{'sel_sect'}					= "0"  ; ## Unused yet. 0=Select all sections. 

## Series/Project Tab:
## Unfortunately the naming is not always rational here.
## In principle,  params refer to the Project tab, and the others
## to the Series tab, but not always. A suffixe denoting the type of
## Tk widget containing the value should be present, but is not always..,
## nor always the unique Tk container for the value.

	$CSG{'A_series_le'}				= "089AB2145673"; 
	$CSG{'A_octs_le'}					= "777888777888"; 
	$CSG{'ana_Aroc_cb'}				= 1    ;
	$CSG{'B_series_le'}				= "19A20345678B";
	$CSG{'B_octs_le'}					= "777888777888"; 
	$CSG{'ana_Broc_cb'}				= 1    ;
	$CSG{'ord_series_le'}			= "45BA19326780";  # Default order (Series tab).
	$CSG{'mod_series_le'}			= "0123456789AB";  # Default mode (Series tab only).
	$CSG{'ton_series_le'}			= "0";  # Default tone (Series tab only).
	$CSG{'signs_series_le'}		= "++++++++++++";  # Default signs (Series tab).
	$CSG{'ins_param_le'}			= "i1" ;
	$CSG{'N_param_le'}				= 1    ;
	$CSG{'X_param_le'}				= 1    ;
	$CSG{'Y_param_le'}				= 1    ;
	$CSG{'Z_param_le'}				= 1    ;
	$CSG{'ana_exp_cb'}				= 1    ;
	$CSG{'ana_line_cb'}				= 0    ;
	$CSG{'ana_sense_cb'}			= 1    ;
	$CSG{'base_param_le'}			= 12    ;
	$CSG{'range_param_le'}		= 3    ;
	$CSG{'signs_le'} 		= "++++++++++++"; # Default signs.
	$CSG{'octs_le'} 			= "777888777888"; # Default octs.
	$CSG{'com_le'} 			= "Some comments."; # Default com.
	$CSG{'author_le'}		= "Author Name";  ## Project Tab
	$CSG{'intersil_le'} 	= 2		; ## Silence between sections.
	$CSG{'Rflag_le'} 		= 0		; ## OK Random octaves flag (Octset mode).
	$CSG{'steps_le'} 		= 1		; ## Number of steps for trains.
	$CSG{'tempo_le'} 		= "t 0 60"	; ## Base number of "seconds" per minute (Scorp).
	$CSG{'title_le'} 		= "Default Title"; ## Project Tab

## Csound Tab 
	$CSG{'audio_driver_mbw'}	= "alsa"; 
	$CSG{'csound_hbuffer_le'}	= "1024"; 
	$CSG{'csound_ksmps_le'}		= "1"; 
	$CSG{'csound_nchnls_le'}	= "2";  
	$CSG{'csound_params_le'}	= ""; 
	$CSG{'csound_path_pe'}		= "/usr/bin/csound"; 
	$CSG{'csound_sample_mbw'}	= "SHORT"; 
	$CSG{'csound_sbuffer_le'}	= 256; 
	$CSG{'csound_sr_le'}			= 44100;  
	$CSG{'midi_driver_mbw'}		= "alsa"; 
	$CSG{'realtime_params_le'}= "";  

## Notes Tab:
	$CSG{'Notes_tw'} 					= 'Some notes.'; ## Notes Tab

## Check that csgrouper.pl modifications to defaults appear hereafter:
our @Internals							= (
		['name', 'description', 'comment'], ## head line
		['application', $CSG{'csg_appl'}, ""],
		['status', $CSG{'csg_status'}, ""],
		['version', $CSG{'csg_version'}, ""],
		['label', $CSG{'csg_label'}, ""],
		['Base path', $CSG{'csg_path_pe'}, ""],
		['Run path', $CSG{'run_path_pe'}, ""],
		['Render path', $CSG{'render_path_pe'}, ""],
		['Bkp path', $CSG{'bkp_path_pe'}, ""],
		['Inst path', $CSG{'ins_path_pe'}, ""],
		['Project path', $CSG{'path_pe'}, ""],
		['Sf2 path', $CSG{'csound_sf2path_pe'}, ""],
		['char. set', $CSG{'char_set'}, ""],
		['separator (sep.)', $CSG{'separator'}, ""],
		['object sep.', $OBJSEP, ""],
		['param. sep.', $PARSEP, "Required for Xfuns."],
		['set sep.', $SETSEP, ""],
		['section sep.', $GRPSEP, ""],
		['Ft base', $CSG{'ft_base'}, "The default ftable (a sine)."],
		['Random Ft range', $CSG{'ftb_ran'}, "Pseudo random f-tables ids start at this value."],
		['Default mode', $CSG{'default_mode'}, ""],
		['Default tone', $CSG{'default_tone'}, ""],
		['Minimal duration', $CSG{'durmin_le'}, "Minimal duration (multiplied by rythm setup)."],
		['Maximal duration', $CSG{'durfac_le'}, "A factor for the minimal duration."],
		['Fractional length', $CSG{'fractail'}, "Tail length for floats."],
		['Octave max', $CSG{'oct_max'}, "The maximal octave value for cpspch."],
		['Octave base', $CSG{'oct_base'}, "The default octave location from 0 to oct_max."],
		['Octave range', $CSG{'oct_range'}, "The default octave variation range."],
		['Minimal amplitude', $CSG{'min_amp'}, "Minimal amplitude under xsil."],
		['Sflag', $CSG{'Sflag'}, "Flag for train printings."],
		['Rflag', $CSG{'Rflag_le'}, "Random octaves flag (Octset mode)."],
		['Steps', $CSG{'steps_le'}, "Number of steps for trains."],
		['Tempo', $CSG{'tempo_le'}, "Default number of 'seconds' per 'minute'."],
);
		
		## END Globals

=head1 Attributes Section 

=head2 time-related Csgrouper containers

Cf. %sections,  %sets , %tracks 

The staves container will receive sequences object refs, one by one, later as soon they get validated  by struct_ctl.

Finally, the Csgrouper object is just printed through write_csd, but all the computations have been done at sequence creation.
=cut

has 'testh' 			=> (isa => 'HashRef', is => 'rw', required => 1, default => sub { { 'key1'=>'val1' } });

has 'sequences' 	=> (isa => 'HashRef', is => 'rw', required => 1, default => sub {{}});
has 'instruments'	=> (isa => 'HashRef', is => 'rw', required => 1, default => sub {{}});
has 'inseth'			=> (isa => 'HashRef', is => 'rw', required => 1, default => sub {{}});
has 'defaults'		=> (isa => 'HashRef', is => 'rw', required => 1, default => sub {{}});
has 'ftables'			=> (isa => 'HashRef', is => 'rw', required => 1, default => sub {{}});

has 'sections' 			=> (isa => 'HashRef', is => 'ro', required => 1, default => sub {{}}, writer => 'set_sections');
has 'sets' 				=> (isa => 'HashRef', is => 'ro', required => 1, default => sub {{}}, writer => 'set_sets');
has 'tracks' 			=> (isa => 'HashRef', is => 'ro', required => 1, default => sub {{}}, writer => 'set_tracks');

has 'staves' 			=> (isa => 'Ref', 		is => 'ro', required => 1, default => sub {{}}, writer => 'set_staves');
has 'stfcnt'			=> (isa => 'Num', 		is => 'ro', required => 1, default => 0, 				writer => 'set_stafcnt');
has 'ready'				=> (isa => 'Bool', 		is => 'ro', required => 1, default => 0, 				writer => 'set_ready');


## END Attributes.

=head1 Subroutines Section 

=head2 Private subroutines

=over 

=item * struct_ctl($self,$string) : The mandatory preliminary for csd writing.

Remainder: apart from sequences, there are several time objects that more or less overlap:

Sets are attributed to the original sequences in order to enable some particular post-treatment (Xamp, Xatk etc.) for them.

Sections are unions of sets that correspond to general sections in the score: sets of sequences 1,3,4 e.g. can pertain to the first section and will be played first.
when a set pertains to 2 different sections, its sequences will be played twice.

Tracks are suites of sequences established by means of the 'pre' sequence parameter.
these tracks aren't yet the csd tracks since each splitting counts as one track: e.g: _1_3_ and _1_4_ are tracks, but in csound, sequence _1_ is played only once.

Now it is a goal of struct_ctl() to check that everything has been done appropriately in sections and sets attribution and to correct things if possible and necessary.

The most common error that could have been made in this attribution process consists in not having selected a sequence that is preliminary to a selected one; the most tricky one consists in having attributed a preliminary whose set does not pertain to the same section. These impossible situations are then ruled out.");

Information gathered by struct_ctl():
%SectionsH:
$SectionsH{'size'} = 'total number of sections, additional section included'; 
@{${$SectionsH{$gnbr}}{'sets'}} = 'sets for section $gnbr, invalid ones included'; 
@{${$SectionsH{$gnbr}}{'sequences'}} = 'sequences for section $gnbr, invalid ones included' ; 
@{${$SectionsH{$gnbr}}{'tracks'}} = 'tracks for section $gnbr: only valid sequences included' ; 

The last SectionsH key refers to sets that pertain to no section and sequences that pertain to no set.
By default these orphans will be treated as an additional section at the end.

%SetsH:
$SetsH{'size'} = 'total number of sets'; 
@{$SetsH{'$s'}} = 'sets for sequence $s' ; 

%TracksH:
$TracksH{'size'} = 'total number of tracks'; 
@{$TracksH{$gnbr}} = 'the various tracks for section $gnbr, splits included';

=cut

sub struct_ctl {
  my ($self,$gstring) = @_;  
  my $subname = "Csgrouper::struct_ctl";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
  # $DEBFLAG = 1;
  my (%SectionsH, %SetsH, %TracksH); ## hoa: Each splitted track counts as one track: e.g. _1_2_3_, _1_2_4_, etc..
  $self->set_sections(\%SectionsH);
  $self->set_sets(\%SetsH);
  $self->set_tracks(\%TracksH);
  my @sections = split /$GRPSEP/, $gstring;
  &Debug($subname,"0. Sections: @sections");
  my $gnbr = scalar @sections;
  # 1. Dispatch sets in section arrays (the order of sections is the musical execution order):
  for (my $n = 0; $n < $gnbr; $n++) {
		$SectionsH{$n} = {}; 
		## Important:
		## The order given to the sets here will be the order of Xfun applications.
		my @sets = split /$SETSEP/, $sections[$n];
		@{${$SectionsH{$n}}{'sets'}} = @sets; 
		@{${$SectionsH{$n}}{'sequences'}} = (); 
		@{${$SectionsH{$n}}{'tracks'}} = (); 
		&Describe($subname,"1.1 section=$n: sets=@{${$SectionsH{$n}}{'sets'}}");
  }
  # 2. Create a last "additional" section for sequences or sets that wouldn't pertain to any section:
  $SectionsH{$gnbr} = {}; $SectionsH{'size'} = $gnbr+1;
  @{${$SectionsH{$gnbr}}{'sets'}} = (); 
  @{${$SectionsH{$gnbr}}{'sequences'}} = (); 
  @{${$SectionsH{$gnbr}}{'tracks'}} = (); 
  # 3. Dispatch sequences in set arrays by row ids:
  for (my $id = 1; $id <= $Csgrouper::Types::MAXOBJ; $id++){
		my $tpref = "Tkrow_$id";
		next if (not defined $self->sequences->{$tpref."_id"});
		next if ($self->sequences->{$tpref."_id"} !~ /\d+/);
		next if (not defined $self->sequences->{"Seq_".$self->sequences->{$tpref."_id"}}); ## Ids attributed at sequence creation: there can be gaps after row reordering.
		my $sid = $self->sequences->{$tpref."_id"};
		&Describe($subname,$tpref."=".'Seq_'.$sid);
		my @sets = split /,/, $self->sequences->{"$tpref\_sets"};
		## As we are going to treat everything in one shot now, the id can be the row number (not varid).
		## Because each sequence item is named after the row number (Tkrow_$id_item) it's more convenient to
		## identify them that way now (and no further sequence can be created in the meantime).
		foreach (@sets) { 
			my $s = $_;
			if (not defined $SetsH{$s}){
				$SetsH{'size'}++ ;
				@{${$SetsH{$s}}{'tids'}} = ();
				@{${$SetsH{$s}}{'sids'}} = ();
			}
			push @{${$SetsH{$s}}{'tids'}}, $id unless ($id ~~ @{${$SetsH{$s}}{'tids'}}); ## This is a tkrow id.
			push @{${$SetsH{$s}}{'sids'}}, $sid unless ($sid ~~ @{${$SetsH{$s}}{'sids'}}); ## This is a sequence id.
			## Now try to find if a set doesn't pertain to any section:
			my $test = 0;
			for (my $g = 0; $g < scalar(@sections); $g++) {
				foreach (@{${$SectionsH{$g}}{'sets'}}){ $test = 1 if ($s == $_); }
			}
			if ($test == 0) { ## put the orphan into additional section..
				push @{${$SectionsH{$gnbr}}{'sets'}}, $s  ;
				&Describe($subname,"3.1.1 section=$gnbr sets=@{${$SectionsH{$gnbr}}{'sets'}} (additional section)");
			}
		} 
		## Now if a sequence doesn't pertain to any set
		## again put the orphan into additional section..
		if (scalar @sets == 0) { push @{${$SectionsH{$gnbr}}{'sequences'}}, $id }
  } ## END 3.
  &Describe($subname,"3.2 Total number of sections=$SectionsH{'size'} (SectionsH{'size'})");
  ## 4. We know that foreach (@{${$SectionsH{$n}}{'sets'}}), its sequences are stored
  ## in @{${$SetsH{$_}}{'tids'}}. Let's consider this:
  for (my $n = 0; $n <= $gnbr; $n++) {
		## If the anonymous section doesn't contain any set, it won't appear in the following list.
		my %seen;
		foreach (@{${$SectionsH{$n}}{'sets'}}){
			my $set = $_;
			my @seqa;
			## Note that trying to represent an undefined @{${$SetsH{$_}}{'tids'}} is false 
			## and stops the loop without raising error.
			if (defined @{${$SetsH{$set}}{'tids'}}){
				@seqa =  @{${$SetsH{$set}}{'tids'}} ;
			}
			{ no warnings; ## Some uninitialized vars:
				&Describe($subname,"4.1.1 section=$n: set=$set tids=".join ' ',@seqa);
			}
			## Create a set of unique tkrow sequence ids for this section:
			foreach (@seqa) {
				my $seq = $_;
				if (not defined $seen{$seq}) {
					push @{${$SectionsH{$n}}{'sequences'}}, $seq;
					$seen{$seq}++;
				}
			}
		}
  } ## end 4.
  &Describe($subname,"4.2 Total number of sets=$SetsH{'size'} (SetsH{'size'})");
  ## 5. Here create the tracks according to sequence concatenation,
  ## verifying that the sequence is selected and that no sequence  
  ## in a section is concatenated to a sequence in another.
	for (my $n = 0; $n <= $gnbr; $n++) {
		## Treat each section in turn:
		my @section_sequences; 
		&Describe($subname,"5.1 section=$n sequences=@{${$SectionsH{$n}}{'sequences'}}"); 
		## A. suppress non-selected sequences and create the root set:
		foreach (@{${$SectionsH{$n}}{'sequences'}}) {
			my $tid = $_; my $tpref = "Tkrow_$tid"; 
			## Sel. test:
			if (not ($self->sequences->{"Seq_".$self->sequences->{"$tpref\_id"}} =~ /^Csgrouper::Sequence=HASH\(/)) {
				&Describe($subname,"5.1.1 $tpref doesn't exist or not selected."); 
				next;
			}
			if ($self->sequences->{"$tpref\_sel"} == 0) {
				$self->sequences->{"Seq_".$self->sequences->{"$tpref\_id"}}->set_sel(0);
				&Describe($subname,"5.1.1b $tpref ignored: not selected."); 
				next;
			}
			## If the sequence is auto-referent then it is a root sequence,
			## and its track array will be expanded later.
			## Note that the list is a list of row numbers, not varids.
			if ($self->sequences->{"$tpref\_pre"} == $self->sequences->{"$tpref\_id"}) { 
				&Describe($subname,"5.1.1c $tpref is a root sequence.");
				push @{$TracksH{$n}}, "_$tid\_" 
			}
			else { 
				my $prevseq = $self->sequences->{$tpref.'_pre'}; ## Wait! This is a Seq id!
				my $prevrow = $self->sequences->{"Seq_$prevseq\_tid"};
				my $failure = &track_origin($self, $prevrow, 0, \@{${$SectionsH{$n}}{'sequences'}});
				if ($failure == 0){
					$self->sequences->{"Seq_".$self->sequences->{$tpref.'_id'}}->set_sel(0);
					&Describe($subname,"5.1.2 $tpref ignored: previous ($prevseq->$prevrow) does not pertain to section ($n)."); 
				}
				elsif ($failure < 0){
						$self->sequences->{"Seq_".$self->sequences->{$tpref.'_id'}}->set_sel(0);
					&Describe($subname,"5.1.2b $tpref ignored: a preliminary of ($prevrow) was not selected ($failure)."); 
				}
				else {
					## Set test 2:
					## Find a valid set for $tpref:
					my $test = 0;
					my @gsets = split /,/,$self->sequences->{$tpref.'_sets'};
					for (my $z = 0; $z < scalar(@{${$SectionsH{$n}}{'sets'}}); $z++) {
						my $set = ${${$SectionsH{$n}}{'sets'}}[$z];
						for (my $w = 0; $w < scalar(@gsets); $w++) { $test = 1 if ($set == $gsets[$w]) }
					}
					if ($test == 1){ push @section_sequences, $tid }
					else {  
						$self->sequences->{"Seq_".$self->sequences->{$tpref.'_id'}}->set_sel(0);
						&Describe($subname,"5.1.3. $tpref ignored: no set pertaining to the same section $n.");
						next;
					}
				}
			} ## Prepare for the next step. 
		} ## End A
		&Describe($subname, "5.2 set of root tracks for section $n: @{$TracksH{$n}}") if (defined $TracksH{$n});
		&Describe($subname, "5.3 set of followers for section $n=@section_sequences");
		## B. Let's create the track set for this section:
		my @newtracks; my $locnt = 0;
		while (scalar @section_sequences > 0 and $locnt < $Csgrouper::Types::MAXOBJ){ ## *** A required loop control (see *** below);
			my @newsection; $locnt++;
			my $tid = $section_sequences[0]; my $test = 0; my $tpref = "Tkrow_$tid"; 
			my $prevseq =  $self->sequences->{$tpref.'_pre'}; 
			my $id =  $self->sequences->{"$tpref\_id"};
			&Describe($subname, "5.3.1 $tpref: id=$id  prev=$prevseq section_sequences=@section_sequences");
			## Is a root track the previous for this one?
			if (defined $TracksH{$n}) {
				for (my $i = 0; $i < scalar(@{$TracksH{$n}}); $i++){
					my $row = ${$TracksH{$n}}[$i]; $row =~ s/(.*\_)(\d+)(\_)$/$2/;
					if ($self->sequences->{"Tkrow_$row\_pre"} == $prevseq){
						push @newtracks, ${$TracksH{$n}}[$i]."_".$tid."_";
						&Describe($subname, "5.3.1.1 new track: @newtracks");
						$test = 1; ## This one is done..
					}
				} ## end for tracks
			}
			if ($test == 0){ ## Otherwise the seq has found a previous already.
				## Is another recorded track the previous for this one?
				for (my $i = 0; $i < scalar(@newtracks); $i++){
					my $row = $newtracks[$i]; $row =~ s/(.*\_)(\d+)(\_)$/$2/;
					&Describe($subname, "5.3.2.1 $newtracks[$i] id=".$self->sequences->{"Tkrow_$row\_id"}." prev=$prevseq");
					## The following condition occurs when a matching track is recorded in @newtrack
					## but not yet reported to @{$TracksH{$n}}.
					my $prevrow = $self->sequences->{"Seq_$prevseq\_tid"};
					if ($self->sequences->{"Tkrow_$row\_id"} == $prevseq){
						$newtracks[$i] =  $newtracks[$i]."_".$tid."_";
						&Describe($subname, "5.3.2.2 new track2: @newtracks");
						$test = 1; ## This one is done..
					}
					elsif ($newtracks[$i] =~ /_$prevrow\_/ && $newtracks[$i] !~ /.+(_$tid\_)$/){
						## This condition avoided a double treatment of this track.	
						my $newtrack = $newtracks[$i]; 
						$newtrack =~ s/(.+)(_$prevrow\_)(.*)/$1$2\_$tid\_/;
						push @newtracks, $newtrack;
						&Describe($subname, "5.3.2.3 new track3: @newtracks");
						$test = 1; ## This one is done..
					}
				} ## end for tracks
			}
			## *** Neither "shift @section_sequences" nor "foreach (@section_sequences)" at the begining of this loop (see *** above)
			## can provide what we get here: the ability to create the tracks independantly of sequence order.
			if ($test == 1) { $section_sequences[0] = "" } ## Not an elsif since test might have changed..
			else { $section_sequences[0] = ""; push @section_sequences, $tid } ## put it at the end.
			foreach (@section_sequences) { push @newsection, $_ if ($_ =~ /.+/) }
			@section_sequences = @newsection;
			&Describe($subname, "5.3.4 newsection: @section_sequences");
		} ## end foreach section_sequences
		## What about root tracks without followers:
		if (scalar (@newtracks) > 0) { 
			foreach (@{$TracksH{$n}}){
				my $track = $_; my $isolated = 1;
				foreach (@newtracks) { $isolated = 0 if ($_ =~ /^($track.*)$/) }
				push @newtracks,$track if ($isolated == 1); 
			}
			@{$TracksH{$n}} = @newtracks;
		}
		## &Debug($subname,"HERE section=$n/$gnbr"); 
		&Describe($subname, "5.4 tracks=@{$TracksH{$n}}") if (defined $TracksH{$n});
  } ## end 5.
  ## 6. Now we can display the sequences that are ready to be treated:
  &Describe($subname, "6. Tracks ready to be treated:");
  if (not(defined $TracksH{0})){
		&Describe($subname,"0");
		return 0;
  }
  else {
		for (my $n = 0; $n <= $gnbr; $n++) {
			if (defined $TracksH{$n}) {  
				$TracksH{'size'} += scalar(@{$TracksH{$n}});
				&Describe($subname, "6.1 tracks for section $n=@{$TracksH{$n}}");
			}
		} ## end 6.
		&Describe($subname,"7. Total number of tracks=".$TracksH{'size'}." (TracksH{'size'})");
  }
  my $test = &comp_tracks($self);
  return $test;
  $DEBFLAG =  $oldebflag;
} ## END struct_ctl().



=item * track_origin($self, $prevrow, $rcnt, $sectionref) : recursively surch a previous sequence to which this one is a follow-up.
=cut

sub track_origin { ## Recursive.
  my ($self, $prevrow, $rcnt, $sectionref) = @_;
  my $subname = "Csgrouper::track_origin";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
  # $DEBFLAG = 1;
  &Debug($subname,"0. @{$sectionref} rec=$rcnt");
  return 0 if (!($prevrow ~~ @{$sectionref}));
  foreach (@{$sectionref}) {
		&Debug($subname,"1. section $_ rec=$rcnt");
		if ($prevrow == $_) {
			my $newprevrow = $self->sequences->{"Seq_".$self->sequences->{"Tkrow_$prevrow\_pre"}."\_tid"};
			&Debug($subname,"2. newprev=$newprevrow for Tkrow=$prevrow rec=$rcnt");
			if ($self->sequences->{"Tkrow_$newprevrow\_sel"} == 0) { return(-$newprevrow) } ## A failure (negative).
			elsif ($prevrow != $newprevrow) { 
				return(&track_origin($self, $newprevrow,++$rcnt,$sectionref)) 
			} ## Recursion.
			else { return $prevrow } ## Our will..
		}
  } ## END foreach;
  $DEBFLAG =  $oldebflag;
  return 0; ## A failsafe (normally unuseful)..
} ##  END track_origin()

=item * track_origin($self, $prevrow, $rcnt, $sectionref) : recursively surch a previous sequence to which this one is a follow-up.

Here sequences are treated set-wise in the same manner as their X-fun treatment. But to bring something the compared sequences have to pertain to different tracks, because sequences in one single track behave just like they were in fact one sole sequence.
A further problem is conveyed by the time position of respective sequences, e.g. too far away one from each other will lead to an impossibility to make correct structural shapes. But it's going to be the task of each structural Xfun to handle this kind of problems.
For instance an ensemble play will only be recognized by the listener if the implied sequences share the same position into their respective tracks. However this doesn't render this shape unfeasible. It would just disappear making the ensemble play sound like another kind of formal repetition.

=cut

sub comp_tracks { 
  my ($self) = @_;
  my $subname = "Csgrouper::comp_tracks";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
  # $DEBFLAG = 1;
  &Debug($subname,"");
 	my $osep = $Csgrouper::OBJSEP; my $ssep = $Csgrouper::SETSEP;
	for (my $g = 0; $g < $Csgrouper::Types::MAXOBJ; $g++){	
		next if (not defined $self->tracks->{$g});
		## These are the valid sets for section $g:
		&Csgrouper::Describe($subname, "* sets for section $g=".join ' ',@{$self->sections->{$g}->{'sets'}});
		&Csgrouper::Describe($subname, "* tracks for section $g=".join ' ',@{$self->tracks->{$g}});
		## Take track lists by section id:
		foreach (@{$self->tracks->{$g}}){
			my $track = $_; my @seqs = split /$osep$osep/,$track;
			&Csgrouper::Describe($subname, "** track $track");
			my $scnt = 0; my $stot = scalar(@seqs);
			foreach (@seqs){
				my $tid = $_;  $scnt++;
				$tid =~ s/$osep//g;
				## 1 Recover real id:
				my $spref = "Seq_".$self->sequences->{"Tkrow_$tid\_id"};				
				&Csgrouper::Describe($subname, "Tkrow_$tid=$spref ($g:$scnt/$stot)");
				my $siz =  $self->sequences->{$spref}->tree->size;
				my $sers = $self->sequences->{$spref}->tree->sers;
				my $base = $self->sequences->{$spref}->base;
				&Csgrouper::Describe($subname, "*** $spref: base=$base siz=$siz nser=$sers");
				## Now create the set of sequences to compare (note: there will 
				## be redundancy here since a same sequence can pertain to 
				## different sets, additionnally each sequence being treated in
				## turn, the same data will be processed once when the sequence
				## is the treated one, and also when it's the compared one).
				my @sets = split /$ssep/,$self->sequences->{$spref}->sets;
				&Csgrouper::Describe($subname, "*** sets for $spref=@sets");
				foreach (@sets){
					my $set = $_; ## Now find which other sequences are members of this set
					## in other tracks of this section.
					&Csgrouper::Describe($subname, "**** set $set");
					foreach (@{$self->tracks->{$g}}){
						my $subtrack = $_; 
						next if $subtrack =~ /^($track)$/; ## Skip it not only if this is the same track,
						next if $subtrack =~ /$osep$tid$osep/; ## but also when this track contains the source for comparison.
						## So we hope to ensure we wont compare a time position that is beyond our time-scope.
						my @subseqs = split /$osep$osep/,$subtrack;
						my @sharingset;
						foreach (@subseqs){
							my $subtid = $_;  
							$subtid =~ s/$osep//g;
							## 1 Recover real id:
							my $subsnbr = $self->sequences->{"Tkrow_$subtid\_id"};	
							my $subspref = "Seq_".$self->sequences->{"Tkrow_$subtid\_id"};	
							my @subsets = split /$ssep/,$self->sequences->{$subspref}->sets;
							if ($set ~~ @subsets) { ## No comparison when this set doesn't pertain to the target's set of sets.
								## This location allows comparison of spref with subspref under each one of their common sets.
								&Csgrouper::Describe($subname, "***** comp. of $spref (".$self->sequences->{$spref}->tree->size." notes) with $subspref (".$self->sequences->{$subspref}->tree->size." notes).");
								my $max = $self->sequences->{$spref}->tree->size;
								$max = $self->sequences->{$subspref}->tree->size if ($self->sequences->{$subspref}->tree->size < $max);
								for (my $n = 0; $n < $max; $n++){
									## A. Internal comparisons:
									## idcmp0 : Does the value of this note equal the value of its tone?
									{ no warnings; ## Comparisons between non numeric values.
										&Csgrouper::Debug($subname, "***** note $n");
										if ($self->sequences->{$spref}->tree->notes->{$n}->scmp0 == $self->sequences->{$spref}->tone) {
											$self->sequences->{$spref}->tree->notes->{$n}->idcmp0(1) ;
											## These values deserve to be printed for more than debugging purposes.
											&Csgrouper::Debug($subname, "idcmp0=".$self->sequences->{$spref}->tree->notes->{$n}->idcmp0);
										}
										## idcmp1 : Does the value of transformation 1 of this note equal the value of its index?
										if ($self->sequences->{$spref}->tree->notes->{$n}->scmp1 == $self->sequences->{$spref}->tone) {
											$self->sequences->{$spref}->tree->notes->{$n}->idcmp1(1); 
											&Csgrouper::Debug($subname, "idcmp1=".$self->sequences->{$spref}->tree->notes->{$n}->idcmp1);
										}
										## idcmp2 : Does the value of transformation 2 this note equal the value of its index?
										if ($self->sequences->{$spref}->tree->notes->{$n}->scmp2 == $self->sequences->{$spref}->tone) {
											$self->sequences->{$spref}->tree->notes->{$n}->idcmp2(1); 
											&Csgrouper::Debug($subname, "idcmp2=".$self->sequences->{$spref}->tree->notes->{$n}->idcmp2);
										}
										## idcmp3 : Does the value of transformation 3 this note equal the value of its index?
										if ($self->sequences->{$spref}->tree->notes->{$n}->scmp3 == $self->sequences->{$spref}->tone) {
											$self->sequences->{$spref}->tree->notes->{$n}->idcmp3(1);
											&Csgrouper::Debug($subname, "idcmp3=".$self->sequences->{$spref}->tree->notes->{$n}->idcmp3);
										}
										## B. External comparisons:
										## eqcmp0 : Does the value of this note equal the value of its corresponding note in the compared sequence?
										if ($self->sequences->{$spref}->tree->notes->{$n}->scmp0 == $self->sequences->{$subspref}->tree->notes->{$n}->scmp0) {
											$self->sequences->{$spref}->tree->notes->{$n}->set_eqcmp0($subsnbr);
											&Csgrouper::Debug($subname, "eqcmp0=".$self->sequences->{$spref}->tree->notes->{$n}->eqcmp0);
										}
										## eqcmp1 : Does the value of transformation 1 of this note equal the value of its corresponding note in the compared sequence?
										if ($self->sequences->{$spref}->tree->notes->{$n}->scmp1 == $self->sequences->{$subspref}->tree->notes->{$n}->scmp1) {
											$self->sequences->{$spref}->tree->notes->{$n}->set_eqcmp1($subsnbr) ;
											&Csgrouper::Debug($subname, "eqcmp1=".$self->sequences->{$spref}->tree->notes->{$n}->eqcmp1);
										}
										## eqcmp2 : Does the value of transformation 2 of this note equal the value of its corresponding note in the compared sequence?
										if ($self->sequences->{$spref}->tree->notes->{$n}->scmp2 == $self->sequences->{$subspref}->tree->notes->{$n}->scmp2) {
											$self->sequences->{$spref}->tree->notes->{$n}->set_eqcmp2($subsnbr) ;
											&Csgrouper::Debug($subname, "eqcmp2=".$self->sequences->{$spref}->tree->notes->{$n}->eqcmp2);
										}
										## eqcmp3 : Does the value of transformation 3 of this note equal the value of its corresponding note in the compared sequence?
										if ($self->sequences->{$spref}->tree->notes->{$n}->scmp3 == $self->sequences->{$subspref}->tree->notes->{$n}->scmp3) {
											$self->sequences->{$spref}->tree->notes->{$n}->set_eqcmp3($subsnbr) ;
											&Csgrouper::Debug($subname, "eqcmp3=".$self->sequences->{$spref}->tree->notes->{$n}->eqcmp3);
										}
									} ## END no warnings.
								} ## END for (my $n..).
							} ## END if ($set..).
						} ## END foreach (@subseqs). 
						Csgrouper::Describe($subname, "***** subtrack $subtrack");
					} ## END foreach (@{$self->tracks->{$g}});
				} ## END foreach (@sets);
			} ## END foreach (@seqs).
		} ## END foreach (@{$self->tracks->{$g}}).
	} ## END foreach section.
  $DEBFLAG =  $oldebflag;
  return 1; ## Normal exit.
} ##  END comp_tracks()

## END Private subs.
=back
=cut
#########################################################################
## Public Subs (available from other objects in the Csgrouper section):

=head2 Public subroutines

=cut

=head3 Helpers

=over

 

=item * says($sub,$mess, $mode) : tool for stdout message printing.
=cut

sub says {
  my ($sub,$mess, $mode) = @_;
  $mode //= 0; 
  $mess //= "";
  my $subname = 'Csgrouper::says';
	if ($mode == 1) { $CSG{'csg_status'} = "$sub : $mess" }
	say "$sub : $mess";
} ## END Csgrouper::says().
=back

=head3 Global subs

=over

=item * Anadtrain($rowref,$signref,$keyref,$ordref,$targref) : D-train analysis printing.
=cut

sub Anadtrain {
  my ($rowref,$signref,$keyref,$ordref,$targref) = @_;
  my $subname = 'Csgrouper::Anadtrain';
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my @output; my @tmp;
  push @tmp, "index:";
  for (my $i = 0; $i < scalar(@$rowref); $i++) { push @tmp, &Decadod($i,$subname) }
  push @output, [@tmp]; splice @tmp;
  push @tmp, "series:";
  foreach (@$rowref) { push @tmp, &Decadod($_,$subname) }
  push @output, [@tmp]; splice @tmp;
  push @tmp, "target:";
  foreach (@$targref) { push @tmp, &Decadod($_,$subname) }
  push @output, [@tmp]; splice @tmp;
  push @tmp, "order:";
  foreach (@$ordref) { push @tmp, &Decadod($_,$subname) }
  push @output, [@tmp]; splice @tmp;
  push @tmp, "key:";
  foreach (@$keyref) { push @tmp, &Decadod($_,$subname) }
  push @output, [@tmp]; splice @tmp;
  push @tmp, "sign-key:";
  foreach (@$signref) { push @tmp, $_ }
  push @output, [@tmp]; splice @tmp;
  $DEBFLAG =  $oldebflag;
  return @output;
} ## END Anadtrain().

=item * Anaitrain($rowref,$sign2ref,$key2ref,$signref,$keyref,$ordref,$targref) : I-train analysis printing.
=cut

sub Anaitrain {
  ## I-Train analysis printing.
  my ($rowref,$sign2ref,$key2ref,$signref,$keyref,$ordref,$targref) = @_;
  my $subname = 'Csgrouper::Anaitrain';
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my @output; my @tmp;
  push @tmp, "index:";
  for (my $i = 0; $i<scalar(@{$rowref}); $i++) { push @tmp, &Decadod($i,$subname) }
  push @output, [@tmp]; splice @tmp;
  push @tmp, "series:";
  foreach (@$rowref) { push @tmp, &Decadod($_,$subname) }
  push @output, [@tmp]; splice @tmp;
  push @tmp, "target:";
  foreach (@$targref) { push @tmp, &Decadod($_,$subname) }
  push @output, [@tmp]; splice @tmp;
  push @tmp, "choice:";
  foreach (@$key2ref) { push @tmp, &Decadod($_,$subname) }
  push @output, [@tmp]; splice @tmp;
  push @tmp, "signs:";
  foreach (@$sign2ref) { push @tmp, $_ }
  push @output, [@tmp]; splice @tmp;
  push @tmp, "order:";
  foreach (@$ordref) { push @tmp, &Decadod($_,$subname) }
  push @output, [@tmp]; splice @tmp;
  push @tmp, "key:";
  foreach (@$keyref) { push @tmp, &Decadod($_,$subname) }
  push @output, [@tmp]; splice @tmp;
  push @tmp, "sign-key:";
  foreach (@$signref) { push @tmp, $_ }
  push @output, [@tmp]; splice @tmp;
  $DEBFLAG =  $oldebflag;
  return @output;
} ## END Anaitrain().

=item * Anas($seq,$mode) : analyzes interval contents of a series within 1 octave.
=cut

sub Anas { ## Revised 110519.
  my ($seq,$mode) = @_;
  my @seq = split //,$seq;
  my $subname = "Csgrouper::Anas";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my ($i,$n,$ret,$allint,$intern,@inter,@intercnt); 
  foreach (@seq) { push @intercnt, '0' } ;
  for ($i = 0; $i < (@seq)-1; $i++){
    if (&Dodecad($seq[$i],$subname) >= &Dodecad($seq[$i+1],$subname)) { $intern = &Dodecad($seq[$i],$subname)-&Dodecad($seq[$i+1],$subname);}
    else { $intern = &Dodecad($seq[$i+1],$subname)-&Dodecad($seq[$i],$subname);} 
    ++$intercnt[$intern] ;
    push @inter , &Decadod($intern,$subname);
  }
  for ($i = 0; $i < (@intercnt); $i++) { $intercnt[$i] = &Decadod($intercnt[$i],$subname); }   
  my $int = join '', @inter; 
  my $ict = join '', @intercnt; 
  $DEBFLAG =  $oldebflag;
  return ($int,$ict);
} ## END Anas().

=item * Baseb($value,$base,$obase,$mode,$opts) : base conversion.
=cut

sub Baseb { ## Revised 110519. 
  my ($value,$base,$obase,$mode,$opts) = @_;
  my $subname = "Csgrouper::Baseb";
  ## { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  $obase = $Csgrouper::Types::MAXBAS unless (defined($obase) && $obase =~ /.+/);
  $base = 10 unless (defined($base) && $obase =~ /.+/);
  $mode = 0 unless (defined($mode) && $mode =~ /.+/);
  if ($obase < 2 || $obase > 62) {
    &Error("$subname($value,$base,$obase,$mode,$opts)","Invalid original base.");
  }
  if ($base < 2 || $base > 62) {
    &Error("$subname($value,$base,$obase,$mode,$opts)","Invalid target base.");
  }
  ## Put it in base 10:
  my $newval = &Decab($value,$obase);
  my $res = ($newval%$base);
  if ($res >= 2 && $res < 62) { $res = $Digits[$res] }
  my @res = $res;
  for ($newval = int($newval/$base);$newval >= 1; $newval = int($newval/$base)) {
    $res = ($newval%$base);
    $res = $Digits[$res];
    unshift @res, $res ;
    # &Debug($subname, "=> base(): val: $value, res: @res", 1);
  }
  # Permutational mode:
  if ($mode == 1) {
    for (my $i = $base-(scalar(@res)); $i > 0; $i--){ unshift @res,"0" }
  }
  my $rslt = join "",@res;
  $DEBFLAG =  $oldebflag;
  return $rslt;
} ## END Baseb().

=item * Composind($target,$agent) : permutationnal.
=cut

sub Composind { ## Revised 110519.
	my ($t,$g) = @_;
  my @target = split //,$t; 
  my @agent = split //,$g;
  my $subname = 'Csgrouper::Composind';
  ## { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my (@agent_by_char, $cnt, $result, @tmp_result, @target_by_char);
  for (my $i = 0; $i < (@agent); $i++) { # We create char-indice pairs.
    $target[$i] = [$target[$i],$i]; $agent[$i] = [$agent[$i],$i];
  }
  @target_by_char = sort {@$a[0] cmp @$b[0]} @target; # We order pairs according to the char.	
  @agent_by_char = sort {${$a}[0] cmp ${$b}[0]} @agent;
  @tmp_result = map { [ @$_ ] } @target_by_char; # Bait modifying sequence: note the indispensable call to map().
  for (my $i = 0; $i < (@agent_by_char); $i++){ ${$tmp_result[$i]}[1] = ${$target_by_char[${$agent_by_char[$i]}[1]]}[1] }
  foreach (sort {${$a}[1] <=> ${$b}[1]} @tmp_result) { $result .= ${$_}[0] }
  $DEBFLAG =  $oldebflag;
  return $result;
} ## END Composind().

=item * Compstr0($ser) : proper string.
=cut

sub Compstr0 { 
  my ($ser) = @_; ## Deordering:
  my $subname = "Csgrouper::Compstr0";
  # { no warnings; &says($subname, "@_"); }
	return $ser;
} ## END Compstr0

=item * Compstr0($ser) : comparison string for decision making (was notindex).
=cut

sub Compstr1 { 
  my ($ser) = @_; 
  my $subname = "Csgrouper::Compstr1";
  # { no warnings; &says($subname, "@_"); }
  ## The use of Imap allows indistinct elements and modes.
	return &Dimap(&Powerp(&Natural($ser),&Imap($ser),2),$ser);
}

=item * Compstr2($ser) : comparison string for decision making (was indexi).
=cut

sub Compstr2 { 
  my ($ser) = @_;
  my $subname = "Csgrouper::Compstr2";
  # { no warnings; &says($subname, "@_"); }
  ## The use of Imap allows indistinct elements and modes.
	return &Dimap(&Powerp(&Natural($ser),&Imap($ser),-1),$ser);
} ## END Compstr2

=item * Compstr3($ser) : comparison string for decision making (was indexnot).
=cut

sub Compstr3 { 
  my ($ser) = @_; 
  my $subname = "Csgrouper::Compstr3";
  # { no warnings; &says($subname, "@_"); }
  ## The use of Imap allows indistinct elements and modes.
	return &Dimap(&Powerp(&Natural($ser),&Imap($ser),-2),$ser);
} ## END Compstr3

=item * Compstr4($ser) : random string.
=cut

sub Compstr4 { 
  my ($ser) = @_; ## Deordering:
  my $subname = "Csgrouper::Compstr4";
  # { no warnings; &says($subname, "@_"); }
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

=item * Dimap($ser,$set) : Indexical demapping.
=cut

sub Dimap {
	my ($ser,$set) = @_;
  my @seq = split //,$ser;
  my @set = sort(split //,$set);
  my $n = 0; my $res;
  my %h = map { $Digits[$n++] => $_ } (@set);
  return join('',map{ $h{$_} } (@seq));
} ## END Dimap()

=item * Cpspchnote($note,$opts) : Dodecaphonic note to Csound cpspch values.
=cut

sub Cpspchnote { ## Revised 110519.
  ## A future function Cpspchoct will produce an octave value 
  ## when Cpspch() will bring both together.
  my ($note,$opts) = @_;
  my $subname = 'Csgrouper::Cpspchnote';
  ## { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  $note = 11 if ($note =~ /B/i);
  $note = 10 if ($note =~ /A/i);
  $DEBFLAG =  $oldebflag;
  return "0".$note if ($note < 10);
  if ($note > 11 || $note < 0 || int($note)!=$note) {
    &Error("$subname($note)","No such note: $note.",0);
  }
  return $note;
} ## END Cpspchnote().

=item * Cyclan($note,$mode) : analyses contents of a series in smallest cyclic intervals.
=cut

sub Cyclan { ## Revised 110519.
  my ($s,$mode) = @_;
  my @seq = split //,$s;
  my $subname = "Csgrouper::Cyclan";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my ($i,$n,$ret,$allint,$intern,@inter,@intercnt); 
  my $base = (@seq);
  my $b = sprintf("%0.f",($base)/2); # = ceil(1/2*base) +1
  while ($b >= 0) { push @intercnt, '0'; $b--;} ;
  for ($i = 0; $i < (@seq)-1; $i++){
    if (abs(&Dodecad($seq[$i],$subname)+2*$base-&Dodecad($seq[$i+1],$subname))%$base <= abs(&Dodecad($seq[$i+1],$subname)+2*$base-&Dodecad($seq[$i],$subname))%$base) { $intern = abs(&Dodecad($seq[$i],$subname)+2*$base-&Dodecad($seq[$i+1],$subname))%$base;}
    else { $intern = abs(&Dodecad($seq[$i+1],$subname)+2*$base-&Dodecad($seq[$i],$subname))%$base;} 
    ++$intercnt[$intern] ;
    push @inter , &Decadod($intern,$subname);
  }
  if (abs(&Dodecad($seq[$i],$subname)+2*$base-&Dodecad($seq[0],$subname))%$base <= abs(&Dodecad($seq[0],$subname)+2*$base-&Dodecad($seq[$i],$subname))%$base) { $intern = abs(&Dodecad($seq[$i],$subname)+2*$base-&Dodecad($seq[0],$subname))%$base;}
  else { $intern = abs(&Dodecad($seq[0],$subname)+2*$base-&Dodecad($seq[$i],$subname))%$base;} 
  ++$intercnt[$intern] ;
  push @inter , &Decadod($intern,$subname);
  for ($i = 0; $i < (@intercnt); $i++) {
    $intercnt[$i] = &Dodecad($intercnt[$i],$subname); 
  }   
  my $cyn = join '', @inter;
  my $cyc = join '', @intercnt;
  &Debug($subname, "Cyclan: $cyn $cyc", 1) if ($DEBFLAG != 0);
  $DEBFLAG =  $oldebflag;
  return ($cyn,$cyc);
} ## END Cyclan().

=item * Decab($value,$base,$opts) : Translation of any based (2-62) value into a decimal value.
=cut

sub Decab { ## Revised 110621.
  my ($value,$base,$opts) = @_;
  my $subname = "Csgrouper::Decab";
  ## { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  $base = $Csgrouper::Types::MAXBAS unless (defined($base) && $base =~ /.+/);
  my @value = split //,$value;
  my $res = 0;
  my $x = (@value) - 1;
  my @newval = @value;
  if ($base < 2 || $base > 62) {
    &Error("$subname($value,$base,$opts)","Invalid original base: $base.");
  }
  for (my $n = 0; $n < (@newval); $n++){ 
    $newval[$n] = $Digh{$newval[$n]};
    if ($newval[$n] >= $base) {
      &Error("$subname($value,$base,$opts)","Invalid value $newval[$n] in base $base.");
    }
  }
  foreach (@newval) {
    my $digit = $_;
    $res = $res + ($digit * ($base ** $x)); --$x;
    &Debug($subname, "$res + ($digit * ($base ** $x)) = $res", 0); 
  }
  $DEBFLAG =  $oldebflag;
  return $res;
} ## END Decab().

=item * Datem($mode) : the date.
=cut

sub Datem {
  my ($mode) = @_;  # mode = d|t.n|p
  my $subname = "Csgrouper::Datem";   
  ## { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my ($hstr,$msep,$str, $time, $tsep,$ysep); 
  # Backward compatibility:
  if (not defined $mode) { $mode = "" }
  elsif ($mode =~ /digit/) { $mode = "n" } ## legacy..
  elsif ($mode =~ /print/) { $mode = "p" } 
  my @date = localtime ; 
  my $year = $date[5] + 1900 ;
  my $month = $date[4] + 1 ; $month = "0".$month  if (length ($month) == 1);
  my $day = $date[3]; $day = "0".$day  if (length ($day) == 1);
  my $hour = $date[2]; $hour = "0".$hour  if (length ($hour) == 1);
  my $min = $date[1]; $min = "0".$min  if (length ($min) == 1);
  my $sec = $date[0]; $sec = "0".$sec  if (length ($sec) == 1);
  if ($mode =~ /n/) { $ysep = ""; $tsep = ""; $msep = '' } # Nbr string: no sep.
  elsif ($mode =~ /p/) { $ysep = ' ' ; $tsep = ' '; $msep = ' ' } # Space separated print.
  else { $ysep = "-"; $tsep = ":"; $msep = '_' }; # Default separators.
  $day = "$year$ysep$month$ysep$day";
  $time = "$hour$tsep$min$tsep$sec";
  $DEBFLAG =  $oldebflag;
  if ($mode =~ /d/) { return $day } # Only the day.
  elsif ($mode =~ /t/) { return $time } # Only the time.
  else { return "$day$msep$time" } # Both (default).
} # END Datem().

=item * Debug($sub,$string,$opt) : debug messages.
=cut

sub Debug { ## &Debug(sub,msg,1) = &Error(sub,msg,0)..
  my ($sub,$string,$opt) = @_; ## .. a forced warning = a non fatal error.
  my $subname = '"Csgrouper::Debug'; $opt = 0 if (not defined $opt);
  ## { no warnings; &says($subname, "@_"); }
  my $msg = "DEBUG"; $msg = "WARNING" if ($opt == 1);
  if ($opt == 1 || $DEBSUBS =~ /$sub/ || ($DEBFLAG//= 0 == 1)) {
		print STDERR " *** $msg: $sub: $string ***\n";
  }
} ## END Debug().
                                    
=item * Decadod($n,$sub) : digit to xphonic.
=cut

sub Decadod { 
  my ($n,$sub) = @_; $sub //="";
  my $subname = "Csgrouper::Decadod";
  ## { no warnings; &says($subname, "@_"); }
  my $res = $n;
  if ($n =~ $Csgrouper::Types::REGEX{digit}){
  	$res = $Digits[$n] ;
  }	
  else { &Error($subname,"$n is no valid arg. ($sub)",0) } ## A non fatal error.
  return $res;
} ## END Decadod().

=item * Describe($sub,$string) : STDOUT messages.
=cut

sub Describe { ## 
  my ($sub,$string) = @_;
  my $subname = 'Describe';
  ## { no warnings; &says($subname, "@_"); }
  my $msg = "DESCR";
  print STDOUT " *** $msg: $sub: $string ***\n";
} ## END Describe().
                  
=item * Digsort($ser) : sorts digits (was iden).
=cut

sub Digsort { ## Revised 110519.
  my @s = split //,$_[0];
  my $subname = "Csgrouper::Digsort";
  ## { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  @s = sort(@s); my $res;
  foreach (@s) { $res .= $_ }
  $DEBFLAG =  $oldebflag;
  return $res;
} ## END Digsort().

=item * Dodecad($ser) : Xphonic to digit.
=cut

sub Dodecad { 
  my ($n,$sub) = @_; $sub //="";
  my $subname = "Csgrouper::Dodecad";
  ## { no warnings; &says($subname, "@_"); }
	my $res = $n;
  {no warnings; ## Sometimes $n must be uninitialized:
		if ($n =~ $Csgrouper::Types::REGEX{xphonic}){
			if (exists $Digh{$n}){ $res = $Digh{$n} }
		}
		else { &Error($subname,"$n is no valid arg. ($sub)",0) }## A non fatal error.
	}
  return $res;
} ## END Dodecad().
    
=item * Dynana($row,$keys,$ord,$mode) : d-Train Analysis : ord = distinct elements.
=cut

sub Dynana { ## Revised 111002.
  my ($row,$keys,$ord,$mode) = @_;
  my $subname = 'Csgrouper::Dynana';
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  $mode//= 0;
  my @row = split //, $row;
  my @keys = split //, $keys;
  my @ord = split //, $ord;
  my $base = length($row);
  if (scalar(@ord) > scalar(@row)) {
    &Error("$subname($row,$keys,$ord,$mode)","Length of order should not exceed length of series.",0);
  }
  my ($el, @keys2, @ord2, @signs2, $imin, $imax, $l2, $o, @out);
  my @row2 = @row;
  my @target = @keys;
  @ord = @row if (scalar(@ord)<=1);
  @ord2 = reverse(@ord); # This is peculiar to this train.
  ## interval definition
  for (my $a = 0; $a <scalar(@row); $a++){
    my $src = &Dodecad($row2[&Dodecad($ord2[$a],$subname)],$subname);
    my $target = &Dodecad($keys[&Dodecad($ord2[$a],$subname)],$subname);
    my ($leap, $sign, $oct);
    if ($src > $target){
      ($leap,$oct) = &Notesum($src,$target,"-",$base); $sign = "-";
    }
    elsif ($src < $target){ 
      ($leap,$oct) = &Notesum($target,$src,"-",$base); $sign = "+";
    }
    else { $imin = $imax = $leap = 0; $sign = "+" }
    RECORD:
    for (my $i = $a; $i <(@row); $i++) {
      ($l2,$o)= &Notesum(&Dodecad($row2[&Dodecad($ord2[$i],$subname)],$subname),$leap,$sign,$base);
      $row2[&Dodecad($ord2[$i],$subname)]=&Decadod($l2,$subname); }
      $signs2[$a]=$sign;
      $keys2[$a]=$leap;
    }
  my ($key,$signs);
  for $el(@keys2){ $key .= &Decadod($el,$subname) }
  for $el(@signs2){ $signs .= $el } 
  if ($mode == 1) {
    @out = &Anadtrain(\@row,\@signs2,\@keys2,\@ord,\@target) ;
    unshift @out, ["","d-Train", "Analysis:"];
  }
  $DEBFLAG =  $oldebflag;
  return @out if ($mode == 1);
  return ($key, $signs);
} ## END Dynana().

=item * Dynatrain($row,$octs,$keys,$kocts,$ord) : Dynamic intervals train : ord = distinct elements.
=cut

sub Dynatrain { ## Revised 111008.
  my ($row,$octs,$keys,$kocts,$ord) = @_;
  my $subname = "Csgrouper::Dynatrain";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  &Debug($subname, "Dynamic:");
  my @row = split //, $row;
  my @oldoct = split //, $octs;
  my @newkeys = split //, $keys;
  my @kocts = split //, $kocts;
  my @ord = split //, $ord;
  $CSG{'steps_le'} = 1 if ($CSG{'steps_le'} !~ /.+/);
  my $oldsflag = $CSG{'Sflag'}; $CSG{'Sflag'} = 0 if ($CSG{'Sflag'} !~ /.+/);
  ## Control:
  die("Length of order should not exceed length of series.\n",$subname)  if ((@ord) > (@row));
  die("Step should be a divisor of series length.\n",$subname) if ((@row)/$CSG{'steps_le'} != int((@row)/$CSG{'steps_le'}));
  my ($newkeys,$newsigns) = Dynana($row,$keys,$ord);
  &Describe($subname, "key: $newkeys signs:$newsigns");
  my @keys = split //, $newkeys; my @signs = split //, $newsigns;
  my @suite; my $n = 0; my $m = $CSG{'steps_le'};
  ## Steps:
  for (my $s = 0; $s < $CSG{'steps_le'}; $s++) { push @suite, &Dodecad($ord[$s],$subname) }
  my $i = (@suite)-1;
  my (@outrows, @outocts);
	my @new = @row; # The series modifies itself not the base model.
  until ($n == (@keys)){
    my $j = 0; my @oct = @oldoct;
		foreach (@suite){
			last if ($j == (@suite));
			my $interval = &Dodecad($keys[$i],$subname);
			my $note = &Dodecad($new[$suite[$j]],$subname);
			my $sign = $signs[$i];
			my ($newnote, $newoct) = &Notesum($note,$interval,$sign,length($row));
			{ no warnings; ## Some of these aren't initialised?
				$new[$suite[$j]]= &Decadod($newnote,$subname);
				$oct[$suite[$j]]= $oldoct[$suite[$j]]+$newoct+$kocts[$suite[$j]];
				++$j;	--$i;
			}
		}
		## Here a non avoidabale non fatal Dodecad error at the end:
		push @suite, &Dodecad($ord[++$n],$subname);
		$i = (@suite)-1;
		if ($n == $m){
			$m = $m+$CSG{'steps_le'};	
			if ($CSG{'Sflag'} != 1) { &Express(\@new,\@oct,$n-1) } ## Express resets $CSG{'Sflag'} to 33.
			else  { &Printcs(\@new,\@oct,$n-1) }
			my $news = join '',@new;
			my $octs = join '',@oct;
			push @outrows, $news; push @outocts, $octs;
		}
  }
  $CSG{'Sflag'} =  $oldsflag;
  $DEBFLAG =  $oldebflag;
  return ([@outrows],[@outocts]);
} ## END Dynatrain().

=item * Error($sub, $string, $opt) : error messages and actions.
=cut

sub Error { ## This sub can be used for warnings as well as fatal errors.
  my ($sub, $string, $opt) = @_;
  my $subname = 'ERROR';
  ## { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  $opt = "1" unless defined($opt);
  # $DEBFLAG = 1;
  $ERROR .= $sub;
  my $pref = ""; $pref = "(non fatal): " if ($opt == 0);
  print STDERR ("*** $subname: $pref$sub : $string  ***\n");
  $CSG{'csg_status'} = "$subname $pref$sub : $string";
  $DEBFLAG =  $oldebflag;
  if ($opt != 0) { 
  	# $mw->messageBox(-message=>"$subname : $sub : $string") if ($BehavOpt !~ /q/);
  	die("$sub : $string");
  };
  return;
} ## END Error().

=item * Express($newref,$octref,$index) : sequence printing (was nprint).
=cut

## ###TODO correct or better suppress!
sub Express { ## cf Train, Intrain, Dynatrain, Trainspose
  my ($newref,$octref,$index) = @_;
  my $subname = "Csgrouper::Express";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  if ($CSG{'Sflag'} != 33){
    print STDOUT "index:							                             octaves:\n";
    print STDOUT "0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N; 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N;  \n\n";
  }
  foreach (@$newref) { print STDOUT $_." "}
  for (my $a = scalar(@$newref); $a < $Csgrouper::Types::MAXBAS; ++$a){ print STDOUT "  " }
  print STDOUT "; ";
  foreach (@$octref) { print STDOUT $_." " }
  for (my $a = scalar(@$newref); $a < $Csgrouper::Types::MAXBAS; ++$a) { print STDOUT "  " }
  print STDOUT  " : ".( &Decadod($index,$subname))." : ";
  foreach (@$newref) { print STDOUT $_ }; print STDOUT "\n";
  $CSG{'Sflag'} = 33;
  $DEBFLAG =  $oldebflag;
} ## END Express

=item * Gradomap($perm,$opt) : gradual Opposite Mapping:  distinct elements only.
=cut

sub Gradomap { ## Revised 111008.
  my ($perm,$opt) = @_;
  my $subname = "Csgrouper::Gradomap";
  { no warnings; &says($subname, "@_"); }
  $opt //= "";
  my $deg = &Gradual(&Omap($perm));
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my @msuite; my $len = length($perm);
  @msuite = &Gradual(&Omap($perm),'a');
  my (@per,@octs,$octrow,$row);
  for (my $n = 0; $n < (@msuite); $n++) {
  	$row = &Unmap($msuite[$n],$perm);
  	push @per, $row;
    $octrow = &Octset($len,$CSG{'Rflag_le'}); 
    push @octs, $octrow;
  }   
  $DEBFLAG =  $oldebflag;
  if ($opt =~ /a/) { return(@per) } 
  elsif ($opt =~ /p/) { return([@per], [@octs]) } 
  else { return ($deg, $row, $octrow) } # Opt=last.
} ## END Gradomap().

=item * Gradual($perm,$opt) : degree of a permutation.
=cut

sub Gradual { ## Revised 110708. cf sdeg().
  my ($row,$opt) = @_;
  my $subname = "Csgrouper::Gradual";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  $opt //= "";
  my $ind = &Natural($row);
  my $targ = $row;
  my $deg = 1;
  my (@per,@octs,$octrow);
  my $len = length($row);
  push @per, $row; # CSG{'Rflag_le'} decides wether to use random octs or not:
  $octrow = &Octset($len,$CSG{'Rflag_le'}); push @octs, $octrow;
  goto SDEGEND if ($ind =~ /$row/);
  while (++$deg){
    $targ = &Composind($targ,$row);
    $octrow = &Octset($len,$CSG{'Rflag_le'}); 
    last if ($ind =~ /$targ/);
    push @per, $targ; push @octs, $octrow;
  }
  SDEGEND: 
  $DEBFLAG =  $oldebflag;
  if ($opt =~ /a/i) { return @per } # Opt=a is reserved to array output - priority.
  elsif ($opt =~ /p/i) { return([@per], [@octs]) } 
  else { return $deg } # Defaults to scalar output.
} ## END Gradual().


=item * Imap($ser) : indexical mapping.
=cut

sub Imap { 
	my ($ser) = @_;
  my @seq = split //,$ser;
  my $n = 0; my $res;
  my %h = map { $Digits[$n++] => $_ } (sort(@seq));
  foreach (@seq) {
  	my $val = $_;
  	for (my $i = 0; $i < scalar(@seq); $i++) {
  		if ($h{$Digits[$i]} =~ /$val/) { $res .= $Digits[$i]; $h{$Digits[$i]} = ""}
  	}
  }	
  return $res;
} ## END Imap()

=item * Inana($row,$keys,$ord,$mode) : i-Train Analysis: ord = distinct elements.
=cut

sub Inana { ## Revised 111003.
  my ($row,$keys,$ord,$mode) = @_;
  my $subname = 'Csgrouper::Inana';
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my @row = split //,  $row;
  my @keys = split //, $keys;
  my @ord = split //, $ord;
  my $base = length($row);
  if (scalar(@ord) > scalar(@row)) {
    &Error("$subname($row,$keys,$ord,$mode)","Length of order should not exceed length of series.",0);
  }
  my (@keys2, @out, @signs2, @signs);
  my @target = @keys;
  @ord = @row if ((@ord)==0);
  ## Interval definition:
  for (my $a = 0; $a <(@row); $a++){
    my $src = &Dodecad($row[$a],$subname);
    my $target = &Dodecad($keys[$a],$subname);
    my ($leap, $sign, $oct) ;
    if ($src > $target){
	    ($leap,$oct) = &Notesum($src,$target,"-",$base); $sign = "-";
    }
    elsif ($src < $target){ 
	    ($leap,$oct) = &Notesum($target,$src,"-",$base); $sign = "+";
    }
    else { $leap = 0; $sign = "+" }
    RECORD:
    $signs2[$a]=$sign;
    $keys2[$a]=&Decadod($leap,$subname);
  }
  ## Reorder:
  splice @keys; splice @signs;
  for (my $a = 0; $a <(@ord); $a++){
    unshift @keys, $keys2[&Dodecad($ord[$a],$subname)];
    unshift @signs, $signs2[&Dodecad($ord[$a],$subname)];
  }
  if ($mode == 1) { 
    @out = &Anaitrain(\@row,\@signs2,\@keys2,\@signs,\@keys,\@ord,\@target) ;
    unshift @out, ["","i-Train", "Analysis:"];
  }
  my $key = join '',@keys;
  my $signs = join '', @signs;
  $DEBFLAG =  $oldebflag;
  return (@out) if ($mode == 1);
  return ($key, $signs);
} ## END Inana().

=item * Intone($seq, $modus, $tonus, $base) : applies tone and mode to a series.

XXX Note: this way of using modes requires a certain knowhow because it's more extended than the normal modal practice. To use a normal mode shouldn't require expressing things in it afterwards. Thus the Intone() sub achieves something else, it provides a way to translate any non modal sequence according to some translation table that is called here a "mode". When the sequence is  already written in a particular mode, nothing will happen provided that the mode passed as param to Intone is the natural sequence for its base, because then, each note in the original sequence will be translated to itself, no change.

However, when the mode contains other signs than its indices in some places the returned sequence will differ at each of these signs, showing the ones displayed by the mode. 

Tone is a way to transpose the input so that the note zero becomes the tone and so on for each other note.
=cut

sub Intone {
	## &Csgrouper::Intone("089AB2145673","0123456789AB","0","12") == "089AB2145673".
	my ($seq, $modus, $tonus, $base) = @_; 
  my @row = split //, $seq;
  my @mode = split //, $modus;
  my $subname = "Csgrouper::Intone";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $new; 
  foreach (@row) { 
  	## First take the available note from mode:
    my $note = $mode[&Dodecad($_)];
    ## Then express it on a new base (
    &Debug($subname,"$_=n=$note");
    my ($newmode,$oct) = 
    	&Decadod(
    		 &Notesum(
    		 	  &Dodecad($note)
    		 	 ,&Dodecad($tonus)
    		 	 ,'+'
    		 	 ,$base
    		 )
    	);
    $new .= $newmode;
  }
  # &Describe($subname,"$seq => $new");
  $Csgrouper::DEBFLAG =  $oldebflag;
  return $new;
} ## END Intone().

=item * Intrain($row,$octs,$keys,$kocts,$ord) : intervals train: ord = distinct elements.
=cut

sub Intrain { ## Revised 111008.
  my ($row,$octs,$keys,$kocts,$ord) = @_;
  my $subname = 'Csgrouper::Intrain';
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  &Debug($subname, "Static:");
  my @row = split //, $row;
  my @oldoct = split //, $octs;
  my @kocts = split //, $kocts;
  my @ord = split //, $ord;
  $CSG{'steps_le'} = 1 if ($CSG{'steps_le'} !~ /.+/);
  my $oldsflag = $CSG{'Sflag'}; $CSG{'Sflag'} = 0 if ($CSG{'Sflag'} !~ /.+/);
  ## Control:
  die("Length of order should not exceed length of series.\n",$subname)  if ((@ord) > (@row));
  die("Step should be a divisor of series length.\n",$subname) if ((@row)/$CSG{'steps_le'} != int((@row)/$CSG{'steps_le'}));
  my ($newkeys,$newsigns) = Inana($row,$keys,$ord,'0'); # $mod = 0: no print.
  my @keys = split //, $newkeys; my @signs = split //, $newsigns;
  my @suite; my $n = 0; my $m = $CSG{'steps_le'};
  ## Steps:
  for (my $s = 0; $s < $CSG{'steps_le'}; $s++) { push @suite, &Dodecad($ord[$s],$subname) }
  my $i =  (@suite)-1; my (@outrows, @outocts);
  until ($n >= (@keys)){
    my @new = @row;
    my @oct = @oldoct;
    my $j = 0;
    foreach (@suite){
      last if ($j == (@suite));
      my $interval = &Dodecad($keys[$i],$subname);
      my $note = &Dodecad($new[$suite[$j]],$subname);
      my $sign = $signs[$i];
      my ($newnote, $newoct) = &Notesum($note,$interval,$sign,length($row));
      &Debug($subname,"newnote: $newnote, newoct: $newoct");
      $new[$suite[$j]]= &Decadod($newnote,$subname);
      $oct[$suite[$j]] = $oldoct[$suite[$j]]+$newoct+$kocts[$suite[$j]];
      ++$j; --$i;
    }
    ## Here a non avoidabale non fatal Dodecad error at the end:
    push @suite, &Dodecad($ord[++$n],$subname);
    $i = (@suite)-1;
		if ($n == $m){
			$m = $m+$CSG{'steps_le'};	
			if ($CSG{'Sflag'} != 1) { &Express(\@new,\@oct,$n-1) } ## Express resets $CSG{'Sflag'} to 33.
			else  { &Printcs(\@new,\@oct,$n-1) }
			my $news = join '',@new; my $octs = join '',@oct; 
			push @outrows, $news; push @outocts, $octs;
		}
  }
  $CSG{'Sflag'} =  $oldsflag;
  $DEBFLAG =  $oldebflag;
  return ([@outrows],[@outocts]);
} ## END Intrain().

=item * Invert($notes, $octaves, $base, $axis, $opt) : dodecaphonic inverse (long sequences and indistinct signs allowed).
=cut

sub Invert { ## Revised 111002.
  my ($notes, $octaves, $base, $axis, $opt) = @_; 
  my $subname = "Csgrouper::Invert";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1; 
  my @seq = split //,$notes; 
  my @octs = split(//,($octaves //="")); 
  $base //= length($notes);
  $base = length($CSG{'char_set'}) if ($base > length($CSG{'char_set'}));
  $axis //= &Dodecad($seq[0],$subname);
  $opt //="";
  my ($inv, $invocts, $newseq, $newocts,@outnotes,@outocts);
  $inv = $invocts = $newseq = $newocts = "";
  &Debug($subname, "base=$base axis=$axis");
  for (my $n = 0; $n < (@seq); $n++){
    # An arithmetic definition for Invert: $res = $res.($axis-($seq[$n]-$axis))%($base+1);
    my $c = &Dodecad($seq[$n],$subname);
    my $sign = "+";  my ($thisnote, $newnote, $thisoct);
    if ($c > $axis) { ($thisnote,$thisoct) = &Notesum($c,$axis,"-",$base); $sign = "-" }
    if ($c < $axis) { ($thisnote,$thisoct) = &Notesum($axis,$c,"-",$base); $sign = "+" }
    if ($c == $axis) { $thisnote = "0"; $sign = "+" }
    ($newnote, $thisoct) = &Notesum($axis,$thisnote,$sign,$base);
    if (defined $octs[$n]){ $thisoct += $octs[$n] }
    else { $thisoct = $CSG{'oct_base'} } 
    $thisoct = "0" unless ($thisoct > 0);
    $thisoct = $base-1 unless ($thisoct < $base);
    &Debug($subname, "base=$base inv=$inv n=$n axis=$axis thisnote=$thisnote sign=$sign newnote=$newnote thisoct=$thisoct");
    $inv .= &Decadod($newnote,$subname);
    $newseq .= &Decadod($newnote,$subname);
    $newocts .= $thisoct;
    $invocts .= $thisoct;
		if (($n>0) && (($n+1)%$base == 0)){ # The series is ready to be recorded.
			push @outnotes, $newseq; push @outocts, $newocts; 
			$newseq = $newocts = "";
		} ## Otherwise some last notes will be left so:
  }
  if ($newseq =~ /.+/) {
		my $len = length($newseq);
		for (my $n = 0; $n < ($base-$len); $n++) { 
			$newseq .= "0"; $newocts .= "0"; # Fill missing notes.
		} 
		push @outnotes, $newseq; push @outocts, $newocts; 
  }
  $DEBFLAG =  $oldebflag;
  if ($opt =~ /s/) { return ([@outnotes], [@outocts]) } ## Serial.
  elsif ($opt =~ /p/) { return ($inv, $invocts) } ## Raw notes and octs.
  return $inv; ## One sequence, no octs.
} ## END Invert().

=item * Map($perm,$map) : mapping P on M: distinct elements only.
=cut

sub Map { ## Revised 111008.
  my ($perm,$map) = @_;
  my $subname = "Csgrouper::Map";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
  # $DEBFLAG = 1;
  my @perm = split //, $perm; 
  my @map = split //, $map;
  my ($i, $n, $res);
  for ($i = 0; $i < scalar(@perm); $i++) {
    for ($n = 0; $n < scalar(@map); $n++) { last if ($map[$n] =~ /$perm[$i]/) }		
    $res .= &Decadod($n,$subname);
  }
  $DEBFLAG =  $oldebflag; 
  return $res;
} ## END Map().

=item * Midi($cps) : CPS to midi note conversion. 
=cut

sub Midi { ## Revised 111008.
  my ($cps) = @_;
  my $subname = "Csgrouper::Midi";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
  # $DEBFLAG = 1;
  my ($y); 
  &Error($subname,"Invalid cps: $cps < 1.022") if ($cps < 1.022); ## Absolute zero.
  $y = 12*(&Blog(2,($cps/440)));
  &Debug($subname,"cps=$cps y=$y");
  $y = $y+69;
  if ($y >= 0){
  	if ($y >= POSIX::floor($y)+0.5) { return POSIX::floor($y)+1 }
  	else { return POSIX::floor($y) }
  }
  else { ## the midi note y is negative, its dodecaphonic position is y % 12.
  	if ($y >= POSIX::floor($y)+0.5) { return POSIX::floor($y)+1 }
  	else { return POSIX::floor($y) }
  }
  $DEBFLAG =  $oldebflag; 
} ## END Midi().

=item * Scale($cps,$base) : Cps to scale conversion. To get the real midi note, add 69 when $base=12. 
=cut

sub Scale { ## Revised 111008.
  my ($cps,$base) = @_;
  my $subname = "Csgrouper::Scale";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
  # $DEBFLAG = 1;
  my ($res,$oct,$soc);
  $oct = 0; $soc = 2*(1.022); # Based on C-4.
  &Error($subname,"Invalid cps: $cps < 1.022") if ($cps < 1.022);
  while ($soc < $cps) { $soc = 2*$soc; $oct++ }
  $res = $base*(&Blog(2,($cps/$soc))); 
  if ($res >= int($res)+0.5) { $res = int($res)+1 }
  else { $res = int($res) }
  &Debug($subname,"y=$res");
  $DEBFLAG =  $oldebflag; 
  return(($res % $base),$oct);
} ## END Scale().

=item * Elacs($s,$x) : Scale to cps conversion.
=cut

sub Elacs { ## Revised 111008.
  my ($note,$oct,$base) = @_;
  my $subname = "Csgrouper::Elacs";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
	# $DEBFLAG = 1;
  my ($res,$n,$cps);
  &Error($subname,"Invalid note: $note < 0") if ($note < 0);
  &Error($subname,"Invalid oct: $oct < 0") if ($oct < 0);
  $n = 0; $cps = 1.022; # Based on C-4 == oct0.
  while ($n < $oct) { $cps = 2*$cps; $n++}
  my $rslt = (2**($note/$base))*$cps;
  &Debug($subname,"cps=$cps (2**$note\/$base)*$cps ==".(2**($note/$base))."*$cps == $rslt");
  $DEBFLAG =  $oldebflag; 
  return($rslt);
} ## END Elacs().

=item * Blog($n,$x) : Log[$x]($n). 
=cut

sub Blog {
  my ($n,$x) = @_;
  my $subname = "Csgrouper::Blog";
  #{ no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
  # $DEBFLAG = 1;
  $DEBFLAG =  $oldebflag; 
  return log($x)/log($n);
} ## END Blog().

=item * Natural($ser) : natural permutation corresponding to str.
=cut

sub Natural { ## Revised 111002.
	my ($str) = @_;
  my $subname = "Csgrouper::Natural";
  # { no warnings; &says($subname, "@_"); }
  my @tmp = split(//,$CSG{char_set});
  splice(@tmp,length($str));
	return(join '',@tmp);
} ## END Csgrouper::Natural().

=item * Notesum($note,$inter,$sign,$base,$opt) : returns (note and 1,0, or -1 for the octave).
=cut

sub Notesum { ## Revised 111002.
  my ($note,$inter,$sign,$base,$opt) = @_; # Note is expressed in base 10.
  my $subname = "Csgrouper::Notesum";
  ## { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  $DEBFLAG = 0; ## No debug!
  $base //= $Csgrouper::Types::MAXBAS; ## Here the base refers to the sign index.
  $opt //= 'n'; ## Normal behaviour (note).
	my @res;
  { no warnings; ## Sometimes vars must be uninitialised:
		&Debug($subname,"$note,$inter,$sign,$base,$opt (a)");
		{ no warnings;
			$res[0] = ($note + "$sign$inter") ; ## The n-phonic sum.
		}
		$res[1] = "0"; ## The number of octaves up or down that we'll get after summing.
		&Debug($subname,"$note,$inter,$sign,$base,$opt b: @res");  
		## This sub can be used to create octave rows alone, but for octaves 
		## we don't care about an octave of the octave! so let's reach limits:
		if ($opt =~ /o/){ ## Cf. Series.pm.
			if ($res[0] < 0) { $res[0] = 0 } 
			elsif ($res[0] > $base) { $res[0] = $base } 
		}
		else { ## Normal behaviour (for notes):
			if ($res[0] < 0) { $res[0] += $base ; $res[1] = -1 } 
			elsif ($res[0] >= $base) { $res[0] -= $base ; $res[1] = 1 } 
		}
		&Debug($subname,"$note,$inter,$sign,$base,$opt c: @res");
  }
  $DEBFLAG =  $oldebflag;
  return @res;
} ## END Notesum().

=item * Num() : sorts numerically.
=cut

sub Num { $a <=> $b } ## END Num()

=item * Numchop($fract) : chops long fractions.
=cut

sub Numchop {
  my ($fract) = @_;
  my $subname = "Csgrouper::Numchop";
  # { no warnings; &says($subname, "@_"); }
  return $fract if ($fract !~ /\./);
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my ($int,$tail) = split /\./, $fract;
  $int =~ s/^(0*)(\d+)$/$2/;
  $int = "0" if ($int !~ /.+/);
  $tail =~ s/^([0-9]{$CSG{'fractail'}})(\d+)$/$1/;
  $DEBFLAG =  $oldebflag;
  return "$int.$tail";
} ## END Numchop().

=item * Octset($siz,$mode) : sets a random octave string.
=cut

sub Octset { ## Revised 110519.
  my ($siz,$mode) = @_;
  my $subname = "Csgrouper::Octset";
  ## { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my $octstr = "";
  $mode = 1 if ($mode !~ /.+/);
  # my  @c =  qw/0 1 2 2 2 3 3 3 3 4 4 4 5 5 6 7/; # Too low.
  my  @c =  qw/4 5 6 6 6 7 7 7 7 8 8 8 8 8 9 9/; # This is the range and probability.
  for (my $i = 0; $i < $siz; $i++) { 
		if ($mode == 1) { $octstr .= $c[int(rand(16))] }  
		else { $octstr .= $CSG{'oct_base'} } # No randomness
  } 
  $DEBFLAG =  $oldebflag;
  return $octstr;
} ## END Octset().


=item * Omap($row) : opposite mapping: distinct elements only.
=cut

sub Omap { ## Revised 111008.
  ## = &Powerp(&Oppose($row),&Powerp(&Natural($row),$row,-1)).
  ## Indistinct signs not allowed (this would yield a string containing a 'C').
  my ($row) = @_;
  my $subname = "Csgrouper::Omap";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
  # $DEBFLAG = 1;
  my @perm = split //,&Oppose($row); 
  my @map = split //, $row;
  my ($res,$n);
  for (my $i = 0; $i < scalar(@perm); $i++){
    for ($n = 0; $n < scalar(@map); $n++) { last if ($map[$n] =~ /$perm[$i]/)}
    $res .= &Decadod($n,$subname);
  }
  &Debug($subname, "$row => $res rowlen: ".scalar(@perm)." maplen: ".scalar(@map));
  $DEBFLAG = $oldebflag;
  ## To remain consistent with other subs, return array refs:
	return $res;
} ## END Omap().

=item * Oppose($notes, $octs, $base, $axis, $opt) : dodecaphonic Opposite  (long sequences and indistinct signs allowed).
=cut

sub Oppose { ## Revised 111007.
  my ($notes, $octs, $base, $axis, $opt) = @_;
  my $subname = 'Csgrouper::Oppose';
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
  # $DEBFLAG = 1;
  $base //= length($notes);
  $base = length($CSG{'char_set'}) if ($base > length($CSG{'char_set'}));
  $opt //= "";
  if ($opt =~ /s/) {  ## Serial.
		my @array = &Invert($notes,$octs,$base,$axis,$opt); 
		my $rows = join '',@{$array[0]};
		my $octs = join '',@{$array[1]};
		return(&Revert($rows,$octs,$base,$opt));
  }
  elsif ($opt =~ /p/) { ## Raw notes and octs.
		my @array = &Invert($notes,$octs,$base,$axis,$opt); 
		return(&Revert($array[0],$array[1],$base,$opt));
  } ## One sequence, no octs:
	return(&Revert(&Invert($notes,$octs,$base,$axis),$octs,$base)); 
} ## END Oppose().

=item * Oppgrad($row,$opt) : opposite Degree of a permutation.
=cut

sub Oppgrad { # Revised 111008.
  my ($row,$opt) = @_;
  my $subname = 'Csgrouper::Oppgrad';
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
  # $DEBFLAG = 1;
  my $ind = $row;
  $opt //= "";
  $row = &Oppose($row);
  my $targ = $row; my $deg = 1; my $len = length($row);
  my $octrow = &Octset($len,$CSG{'Rflag_le'});
  my (@per,@octs); 
  push @per, $row; push @octs, $octrow;
  goto OPPDEGEND if ($ind =~ /$row/);
  while (++$deg){
    $targ = &Oppose($targ);
    $octrow = &Octset($len,$CSG{'Rflag_le'});
    push @per, $targ ;
    push @octs, $octrow;
    last if ($ind =~ /$targ/);
    if (scalar(@per)>1000) { ## Todo: Find the highest for base 24..
    	&Error($subname,"$ind: $row: $targ ".scalar(@per), 1);
    }
  }
  OPPDEGEND:
  $DEBFLAG =  $oldebflag;
  if ($opt =~ /a/) { return (@per) }
  elsif ($opt =~ /p/) { return ([@per], [@octs]) } 
  else { return ($deg,$targ,$octrow) }
} ## END Oppgrad().

=item * Partel($row,$opt) : elementary partition of a series.
=cut

sub Partel { ## Revised 110519.
  my ($row,$mode) = @_;
  my $subname = "Csgrouper::Partel";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  $mode = 0 if ($mode !~ /.+/);
  my @perm = split //, $row;
  my @partel;
  for (my $n = 0; $n < (@perm); $n++) {
    my $U = "";
    my $j = &Dodecad($perm[$n],$subname);
    my $J = $perm[$n];
    next if ("@partel" =~ /$J/);
    if ($J =~ /$Digits[$n]/){ push @partel,$J }
    else {
      while ($U !~ /$J/){
        $U .= $J;
        $J = $perm[$j];
        $j = &Dodecad($J,$subname);
      }
      push @partel,$U;
    }	
  }		
  &Debug($subname, "$row -> @partel");
  $DEBFLAG =  $oldebflag;
  return @partel;
} ## END Partel().

=item * Powerp($target,$agent,$pow,$opt) : permutation of power n: distinct elements only.
=cut

sub Powerp { ## Revised 111003.
  my ($target,$agent,$pow,$opt) = @_;
  $opt //="";
  my $subname = "Csgrouper::Powerp";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
  # $DEBFLAG = 1;
  my (@rslt,@octs,$octrow);
  my $len = length($target);
  $pow = 1 if ($pow !~ /\d+/);
  return &Powerp($target,$agent,(&Gradual($agent)+$pow),$opt) if ($pow < 0);
  if ($pow == 0) {
		$target = &Natural($target);
		$octrow = &Octset($len,$CSG{'Rflag_le'});
  }
  else {
		for (my $n = 1; $n <= abs($pow); $n++){
			$target = Composind($target,$agent);
			$octrow = &Octset($len,$CSG{'Rflag_le'});
			push @rslt, $target;
			push @octs, $octrow;
		}
  }
  $DEBFLAG =  $oldebflag;
  if ($opt =~ /p/) { return ($target, $octrow) }
  elsif ($opt =~ /a/) { return ([@rslt], [@octs]) } # $opt=P (expand and print).
  else { return $target }
} ## END Powerp().

=item * Printcs($newref,$octref,$index) : little csound test.
=cut

## ### :
sub Printcs {
  my ($newref,$octref,$index) = @_;
  my $subname = "Csgrouper::Printcs";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
  # $DEBFLAG = 1;
  print STDOUT "\n\nseries $index:\n" if ($index =~/.+/);
  my $c = 0;
  foreach (@$newref) { 
    my $note = Cpspchnote($_);
    $note = $note+$CSG{cs_midi};
    print STDOUT $CSG{cs_before}.$note.$CSG{cs_after}.$$octref[$c++]."\n"; 
  }		
} ## END Printcs.

=item * Ptype($str) : permutationnal type string.
=cut

sub Ptype { ## Revised 110519.
  my ($str) = @_;
  my $subname = "Csgrouper::Ptype";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my @partel = &Partel($str,"0");
  &Debug($subname, "partel: @partel");
  @partel = sort(@partel);
  my (@len,@type);
  for (my $n = 0; $n <= length($str); $n++) { $len[$n] = 0 }
  for (my $n = 0; $n < (@partel); $n++) { my $l = length($partel[$n]); $len[$l]++; }
  for (my $n = 0; $n <= length($str); $n++) { $len[$n] = &Decadod($len[$n],$subname) }
  shift(@len);
  my $ret;
  foreach (@len){$ret = $ret.$_};
  $DEBFLAG =  $oldebflag;
  return $ret;
} ## END Ptype().

=item * Randcond($cols,$par) : conditional Randomness (distinct signs only).
=cut

sub Randcond { ## Revised 111003.
  # Example: &Randcond(12,"ICT=0231100 CYC=0111210000100 DEG=10 TYP=01220130000 MOD=15 LIM=1000")
  my ($cols,$par) = @_;
  my $subname = "Csgrouper::Randcond";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  ## length control
  if ($cols !~ /.+/) { $cols = $CSG{'base_param_le'} }
  elsif ($cols !~/^(\d+)$/||$cols > $Csgrouper::Types::MAXBAS||$cols<2) { $cols = $CSG{'base_param_le'} }
  my (%cond, @excl, @new, @par, $condsiz, $excl, $lim, $n, $new, $octrow, $rc, $res, $test);
  @par = split / /,$par; 
  foreach (@par) { 
	  my ($key,$val) = split /=/,$_; 
	  $cond{$key}=$val; 
	  &Debug($subname, "No condition called $key (cf: DEG GAP INT MOD MOT TYP LIM).", 1) if ("DEG GAP INT MOD MOT TYP LIM" !~ /$key/);
  }
  $cond{'LIM'} //= 1000;  $cond{'LIM'} = 1000 unless ($cond{'LIM'} > 0); 
  $lim = 0; 
  $condsiz = scalar(@par)-1;
  &Debug($subname, "par: @par cond: $condsiz lim: $cond{'LIM'}");
  until ($lim == $cond{'LIM'}){
    $condsiz = 0;
    foreach ('DEG','CYC','ICT','INT','MOD','MOT','TYP') { ++$condsiz if (exists $cond{$_}) } 
    &Debug($subname, "condsiz: $condsiz");
    $lim++;	$new = ""; splice @excl; splice @new; 
    ## @excl must be empty at start since we are dealing with schoenbergian rows only.
    &Debug($subname, "lim: $lim");
    for (my $i = 0; $i < $cols; $i++){ 
      $excl = "@excl";
      $test = 0;
      until ($test == 1) {
        $rc = &Decadod(int(rand($cols)),$subname);
        if ($excl !~ /$rc/){ 
        	$test = 1; 
        	$new .= $rc; 
        	push @excl, $rc; ## Distinct signs.
        	push @new, $rc; 
        }
      }
    } 
    if (exists $cond{'CYC'}){
      my ($cyn,$cyc) = &Cyclan($new);
      if ($cyc =~ /^($cond{'CYC'})/) { $condsiz-- } 
    }
    if (exists $cond{'DEG'}){
      my ($deg) = &Gradual($new);
      if ($deg == $cond{'DEG'}){ $condsiz-- } 
    }
    if (exists $cond{'ICT'}){
      my ($int,$ict) = &Anas($new);
      if ($ict =~ /^($cond{'ICT'})/) { $condsiz-- } 
    }
    if (exists $cond{'MOD'}){
      my ($mod,$row,$oct) = &Gradomap($new);
      if ($mod == $cond{'MOD'}){ $condsiz-- } 
    }
    if (exists $cond{'MOT'}){
      my $mot =  &Ptype(&Map(&Oppose($new),$new));
      if ($mot == $cond{'MOT'}){ $condsiz-- } 
    }
    if (exists $cond{'TYP'}){
      my ($typ) = &Ptype($new);
      if ($typ =~ /^($cond{'TYP'})/){ $condsiz-- } 
    }
    last if ($condsiz == 0);
  }
  $DEBFLAG =  $oldebflag;
  if ($condsiz > 0) {
    &Error($subname, "No match in $cond{'LIM'} attempts (last = $new). Limit can be increased with LIM=n",0);
    $new = "";
    for (my $n = 0; $n < $cols; $n++) { $new .= '0' };
    # $new = &Natural($new);
  }
  return $new;
} ## END Randcond().

=item * Revert($notes, $octaves, $base, $opt) : dodecaphonic Reverse  (long sequences and indistinct signs allowed).
=cut

sub Revert { ## Revised 111007.
  my ($notes, $octaves, $base, $opt) = @_;
  my $subname = "Csgrouper::Revert";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
  # $DEBFLAG = 1;
  $base //= length($notes);
  $base = length($CSG{'char_set'}) if ($base > length($CSG{'char_set'}));
  $opt //= ""; 
  my @row = split //, $notes;
  my @octs = split //, ($octaves//="");
  my ($reverse, $revocts, $newrow, $newocts, @outnotes, @outocts);
  $reverse = $revocts = $newrow = $newocts = "";
  for (my $n = 0; $n < (@row); $n++){
		my $thisoct = $octs[$n] //= $CSG{'oct_base'};
		$reverse = $row[$n].$reverse;
		$revocts = $thisoct.$revocts;
		$newrow = $row[$n].$newrow;
		$newocts = $thisoct.$newocts;
		if (($n>0) && (($n+1)%$base == 0)){ # The series is ready to be recorded.
			push @outnotes, $newrow; push @outocts, $newocts; 
			$newrow = $newocts = "";
		} ## Otherwise some last notes will be left so:
  }
  if ($newrow =~ /.+/) {
		my $len = length($newrow);
		for (my $n = 0; $n < ($base-$len); $n++) { $newrow .= "0"; $newocts .= "+0";} # fill missing notes
		push @outnotes, $newrow; push @outocts, $newocts; 
  }
  $DEBFLAG = $oldebflag;
  if ($opt =~ /s/) { return ([@outnotes], [@outocts]) } # Serial.
  elsif ($opt =~ /p/) { return ($reverse, $revocts) } ## Raw notes and octs.
  return $reverse; ## One sequence, no octs.
} ## END Revert().

=item * Smetana($row) : series analysis: distinct elements only.
=cut

sub Smetana {
  my ($row) = @_;
  my $subname = "Csgrouper::Smetana";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
 	&Debug($subname, "s=$row");
  my ($deg,$inv,$len,$map,$mod,$mot,$oc,$opd,$opt,$opp,$rev,$rw,$ser,$tone,$typ);
  my (@ana,@cyc,@mdeg,@oppdeg,@out,@prt,@sdeg);
  my $base = length($row);
  $rev 		= &Revert($row,$base); # $notes, $octaves, $opt
  $opp 		= &Oppose($row);
  $inv 		= &Invert($row);
  $map 		= &Map($opp,$row);
 	&Debug($subname, "s=$row : r=$rev : i=$inv : o=$opp : m=$map");
  @sdeg 	= &Gradual($row,'a');
  @oppdeg = &Oppgrad($row,'a');
 	&Debug($subname, "!!!!!!!!!! HERE !!!!!!!!!!");
  @mdeg 	= &Gradomap($row,'a');
  $len 		= length($row);
  push @out, [("S: $row", "I: $inv", "R: $rev", "O: $opp", "M: $map")];
  my @names = (['Gradual','Suite:'],['Opposite','Suite:'],['Gradual','Omap', 'Suite','(unmapped):']);
  my $n = 0;
  foreach (\@sdeg, \@oppdeg, \@mdeg) {
    my $ref = $_; my @set;
    push @out, $names[$n++];
    push @out, [("ind", "ser", "int", "ict", "cyn", "cyc", "deg", "odg", "mod", "typ", "opt", "mot", "par")];
    for (my $n = 0; $n < scalar(@{$ref}); $n++) {
      $ser = ${$ref}[$n];
      &Debug($subname, "${$ref}[$n]");
      @ana = &Anas($ser); @cyc = &Anas($ser); 
      $opp = &Oppose($ser); $map =  &Map($opp,$ser); 
      $deg = &Gradual($ser); ($opd,$rw,$oc) = &Oppgrad($ser); ($mod,$rw,$oc) = &Gradomap($ser);
      $typ = &Ptype($ser); $opt = &Ptype($opp); $mot = &Ptype($map); 
      @prt = &Partel($ser,0) if ($CSG{'char_set'} !~ /$ser/);
      @set = ($n+1, $ser, $ana[0], $ana[1], $cyc[0], $cyc[1], $deg, $opd, $mod, $typ, $opt, $mot, "@prt");
	    &Debug($subname, "set: @set");
	    push @out, [@set];
    }
  }
  $DEBFLAG =  $oldebflag;
  return @out;
} ## END Smetana().

=item * Sortofblue() : sorts for Blue output.
=cut

sub Sortofblue {
  my @a_fields = split / /,$a;
  my @b_fields = split / /,$b;
  $a_fields[1] <=> $b_fields[1];
} ## END Sortofblue().

=item * Supergrad($row, $opt) : power omap suite:  distinct elements only.
=cut

sub Supergrad { ## Revised 111003.
  my ($row, $opt) = @_;
  my $subname = "Csgrouper::Supergrad";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG;
  # $DEBFLAG = 1;
  &Debug($subname, $row);
  my ($map,%subset,$deg,$cycle,$octrow,@octs,@rslt);
  $subset{$row} = $deg = 0;
  my $len = length($row);
  while ($map = &Omap($row)) {
    ++$deg; $row = $map;
    $octrow = &Octset($len,$CSG{'Rflag_le'});
    push @rslt, $map ; push @octs, $octrow ;
    &Debug($subname,"deg: $deg: $map");
    if (defined($subset{$map})) {
      $cycle = $subset{$map};
      &Debug($subname,"cycle = $cycle");
      last;
    };
    $subset{$map}=$deg;
  };
  $DEBFLAG = $oldebflag;
  if ($opt =~ /a/) { return(@rslt) } 
  elsif ($opt =~ /l/) { return ($map,$octrow) } # Opt=last.
  elsif ($opt =~ /p/) { return ([@rslt], [@octs]) }
  else { return ($deg,$cycle,$map,$octrow) }
} ## END Supergrad().

=item * Tabs($n) : tabs.
=cut

sub Tabs {
  my ($n) = @_;
  my $subname = "Csgrouper::Tabs";
  ## { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my $t;
  for (my $c = 0; $c < $n; $c++) { $t .=" " }
  $t = " " if ($t !~ / /);
  $DEBFLAG =  $oldebflag;
  return $t;
} ## END Tabs().

=item * Train($row,$octs,$keys,$kocts,$ord) : train : ord = distinct elements.
=cut

sub Train { ## Revised 111003.
  ## Indistinct signs allowed.
  my ($row,$octs,$keys,$kocts,$ord) = @_;
  my $subname = "Csgrouper::Train";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  &Debug($subname, "Train:");
  my @row = split //, $row;
  my @ord = split //, $ord;
  my @keys = split //, $keys;
  $CSG{'steps_le'} = 1 if ($CSG{'steps_le'} !~ /.+/);
  my $oldsflag = $CSG{'Sflag'}; $CSG{'Sflag'} = 0 if ($CSG{'Sflag'} !~ /.+/);
  ## Control:
  die("Length of order should not exceed length of series.\n",$subname)  if ((@ord) > (@row));
  die("Step should be a divisor of series length.\n",$subname) if ((@row)/$CSG{'steps_le'} != int((@row)/$CSG{'steps_le'}));
  my @oldoct = split //, $octs; my @kocts = split //, $kocts;
  my @suite;  my $n = 0;  my $m = $CSG{'steps_le'};
  for (my $s = 0; $s < $CSG{'steps_le'}; $s++) { push @suite, &Dodecad($ord[$s],$subname) }
  my $i =  scalar(@suite)-1; my (@outrows, @outocts, @oct);
  until ($n == scalar(@keys)){
    my @new = @row; my $j = 0; 
    for (my $g = 0; $g < scalar(@row); $g++) { $oct[$g]=$oldoct[$g] };
    foreach (@suite){
      last if ($j == scalar(@suite));
      $new[$suite[$j]]=$keys[$i];
      $oct[$suite[$j]]=$kocts[$suite[$j]];
      ++$j; --$i;
    }
    ## Hereafter a non avoidable non fatal Dodecad error at the end:
    push @suite, &Dodecad($ord[++$n],$subname);
    $i = scalar(@suite)-1;
    if ($n == $m){
      $m = $m+$CSG{'steps_le'};  
      if ($CSG{'Sflag'} != 1) {&Express(\@new,\@oct,$n-1)} 
			else  { &Printcs(\@new,\@oct,$n-1) } ## A little csound test.
      my $news = join '',@new;
      my $octs = join '',@oct;
      push @outrows, $news; push @outocts, $octs;
    }
  }
  $CSG{'Sflag'} = $oldsflag;
  return ([@outrows],[@outocts]);
} ## END Train().

=item * Trainspose($row,$octs,$keys,$kocts,$ord,$signs) : trainsposition: ord = distinct elements.
=cut

sub Trainspose { ## Revised 111008.
  my ($row,$octs,$keys,$kocts,$ord,$signs) = @_;
  my $subname = "Csgrouper::Trainspose";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my @row = split //, $row;
  my @oldoct = split //, $octs;
  my @keys = split //, $keys;
  my @kocts = split //, $kocts;
  my @ord = split //, $ord;
  my @signs = split //, $signs;
  &Debug($subname, "Trainsposition:");
  $CSG{'steps_le'} = 1 if ($CSG{'steps_le'} !~ /.+/);
  my $oldsflag = $CSG{'Sflag'}; $CSG{'Sflag'} = 0 if ($CSG{'Sflag'} !~ /.+/);
  ## Control:
  die("Length of order should not exceed length of series.\n",$subname)  if ((@ord) > (@row));
  die("Step should be a divisor of series length.\n",$subname) if ((@row)/$CSG{'steps_le'} != int((@row)/$CSG{'steps_le'}));
  my @oct = @oldoct; my @last = @row; my @new ;
  my $n = my $s = 0;  my $m = $CSG{'steps_le'};
  my (@outrows, @outocts);
  until ($n == (@keys)){
    @new = @last;
    for ($s = $n; $s < $n+$CSG{'steps_le'}; $s++) {
      my $place = &Dodecad($ord[$s],$subname);
      my $note = &Dodecad($new[$place],$subname);
      my $interval = &Dodecad($keys[$s],$subname);
	  	my $sign = $signs[$s];
	  	&Debug($subname,"note: $note, place: $place, inter: $interval, sign: $sign");
      my ($newnote, $newoct) = &Notesum($note,$interval,$sign,length($row));
      $new[$place] = &Decadod($newnote,$subname);
      $oct[$place] = $oldoct[$place]+$newoct+$kocts[$place];
    }
    @last = @new;
    ++$n;
    if ($n == $m){
      $m = $m+$CSG{'steps_le'};  
      if ($CSG{'Sflag'} != 1) {&Express(\@new,\@oct,$n-1)} 
      else { &Printcs(\@new,\@oct,$n-1) } ## A little csound test.
	  my $newrow = "@new"; $newrow =~ s/ //g;
	  my $newocts = "@oct"; $newocts =~ s/ //g;
	  push @outrows, $newrow; push @outocts, $newocts;
    }
  }
  $CSG{'Sflag'} =  $oldsflag;
  $DEBFLAG =  $oldebflag;
  return ([@outrows],[@outocts]);
} ## END Trainspose().

=item * Trans($row,$step,$sign) : translation.
=cut

sub Trans {
  my ($row,$step,$sign) = @_;
  my $subname = "Csgrouper::Trans";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my @row = split //, $row;
  my $max;
  foreach (@row){ my $note = &Dodecad($_,$subname); $max = $note if ($max < $note);};
  # &Debug($subname, "max=$max");
  my $new;
  ## die ("Dodecaphonic steps only. $!\n","Trans") if ("0123456789AB" !~ /$step/ or length($step) != 1);
  for (my $i = 0; $i < (@row); $i++) {
    my $note = &Dodecad($row[$i],$subname);
    $step = &Dodecad($step,$subname);
    my ($trans,$oct) = &Notesum($note,$step,$sign,$max);
    $new = $new.&Decadod($trans,$subname);
  }
  $DEBFLAG =  $oldebflag;
  return $new;
} ## END Trans().

=item * Transform($q, $p) : transformed permutation (was transt).

Examples:

Tq(id) = id:

	print &Transform("201345","012345")
  012345

Tq(p o r) = Tq(p) o Tq(r):

	print &Transform("421053",&Powerp("201345","340152"))
  250143

  print &Powerp(&Transform("421053","201345"),&Transform("421053","340152"))
  250143

Tp(p)=p:

	print &Transform("421053","421053")
  421053
=cut

sub Transform {
  my ($q, $p) = @_;
  my $subname = "Csgrouper::Transform";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my $res = &Powerp(&Powerp(&Digsort($q),$q,"-1"),&Powerp($p,$q,"1"),"1");
  $DEBFLAG =  $oldebflag;
  return $res;
} ## END Transform().

=item * Transpose($notes,$octs,$inter,$base,$opt) : simple Transposition.
=cut

sub Transpose { ## Revised 111003.
  ## Allows indistinct elements and long sequences.
  my ($notes,$octs,$inter,$base,$opt) = @_;
  my $subname = "Csgrouper::Transpose";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  $base //= length($notes);
  $base = length($CSG{'char_set'}) if ($base > length($CSG{'char_set'}));
  $inter //= 0;
  my $addoct = int($inter/$base);
  $inter = $inter%$base;
  my @row = split //, $notes; 
  if (length($notes) != length($octs)){
  	$octs = "";
  	foreach(@row){ $octs.= $CSG{oct_base} }
  }
  my @oldocts = split //, $octs;
  &Debug($subname,"o=$octs");
  my ($newrow, $newocts, $trans, $transocts);
  my (@newrow, @newocts, @outnotes, @outocts);
  my $sign = "-"; $sign = "+" if ($inter >= 0); $inter = abs($inter);
  for (my $n = 0; $n < length($notes); $n++){
    my ($new, $oct) = &Notesum(&Dodecad($row[$n],$subname),$inter,$sign,$base);
    $newrow .= &Decadod($new,$subname);
    $trans .= &Decadod($new,$subname);
		my $newoct = $oldocts[$n]+$oct+$addoct;
		$newocts .= Decadod($newoct,$subname);
		$transocts .= Decadod($newoct,$subname);
		if (($n>0) && (($n+1)%$base == 0)){ # The series is ready to be recorded.
			push @outnotes, $newrow; push @outocts, $newocts; 
			$newrow = $newocts = "";
		} ## Otherwise some last notes will be left so:
  }
  if ($newrow =~ /.+/) {
  	my $len = length($newrow);
		for (my $n = 0; $n < ($base-$len); $n++) { $newrow .= "0"; $newocts .= "+0";} # fill missing notes
		push @outnotes, $newrow; push @outocts, $newocts; 
  }
  $DEBFLAG =  $oldebflag;
  if ($opt =~ /s/) { return ([@outnotes], [@outocts]) } ## Serial.
  elsif ($opt =~ /p/) { return ($trans, $transocts) } ## Raw notes and octs.
  return $trans; ## One sequence, no octs.
} ## END Transpose().

=item * Typeset($row,$mode,$opts) : type set of a given extended permutation (made with the highest digits for this type).
=cut

sub Typeset { ## Revised 110519.
  my ($row,$mode,$opts) = @_;
  my $subname = "Csgrouper::Typeset";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my @row = split //, $row;
  my $base = scalar(@row);
  my $max = &Baseb($base-1,$base,10);
  $mode = 1 if ($mode !~ /.+/);
  foreach (@row) {  
    my $note = $_;
    if (&Baseb($note,10,$base) > $base) {
      &Error("$subname($note,$opts)","No such note: $note.");
    }
  }
  my (@typeset, @res);
  for (my $n = 0; $n < (@row); $n++) { $res[&Baseb($row[$n],10,$base)]++; }
  @res = reverse(sort(@res));
  &Debug($subname, "@res");
  my $prev = $res[0];
  for (my $n=0; $n <(@res); $n++) { 
	  # &Debug($subname, "n: $n max: $max");
	  for (my $i = 0; $i < $res[$n]; $i++) { push @typeset,$max };
	  $max = &Baseb(&Baseb($max,10,$base)-1,$base,10);
  }
  $DEBFLAG =  $oldebflag;
  return @typeset if ($mode == 2);
  return join '', @typeset ;
} ## END Typeset().

=item * Unmap($perm,$map) : unmapping P on M:  distinct elements only.
=cut

sub Unmap { ## Revised 111008.
  my ($perm,$map) = @_;
  my $subname = "Csgrouper::Unmap";
  # { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my @perm = split //, $perm; 
  my @map = split //, $map;
  my ($i,$res);
  for ($i = 0; $i < scalar(@perm); $i++){ $res .= $map[&Dodecad($perm[$i],$subname)]; }
  $DEBFLAG =  $oldebflag;
  return $res;
} ## END Unmap().

=item * Zchop($before,$after) : creates a Sn-1 sequence from a zero-start seq.
=cut

sub Zchop {
  my ($before,$after) = split /0/, $_[0];
  my $subname = "Csgrouper::Zchop";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  my $base = '0'.$after.$before;
  my @base = split //,$base;
  my $new;
  die ("Not a Ztrans sequence. $!\n","Zchop") if ($base[0] != 0);
  for (my $i = 1; $i < (@base); $i++) {
    my $note = &Decadod(&Dodecad($base[$i],$subname)-1);
    $new = $new.$note;
  }
  $DEBFLAG =  $oldebflag;
  return $new;
} ## END Zchop().

=item * Ztrans($before,$after) : creates a translation starting at 0.
=cut

sub Ztrans {
  my ($before,$after) = split /0/, $_[0];
  my $subname = "Csgrouper::Ztrans";
  { no warnings; &says($subname, "@_"); }
  my $oldebflag = $DEBFLAG; 
  # $DEBFLAG = 1;
  $DEBFLAG =  $oldebflag;
  return '0'.$after.$before;
} ## END Ztrans().


## END Public subs.

__PACKAGE__->meta->make_immutable; ## Another BestPractice for speed.
no Moose::Util::TypeConstraints;
no Moose; ## Not really useful when using namespace::autoclean.
## END Package Csgrouper.

1;
__DATA__

=back

=head1 Data Section

=head2 Coding notes

- Rule 1: Do not define as attribute a property that depends on a given attribute, instead make it a simple class sub.


