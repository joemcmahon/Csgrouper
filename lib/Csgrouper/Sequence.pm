###############################################################################
## ### FILE INFO:
###############################################################################
## 110831.
## A Sequence class for Csgrouper.
## Encoding of this document: iso 8859-1


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

## END FILE INFO.

=head1 Manual for Sequence.pm

=head2 TODO

 - Octaves seem too low when set at random().

=head2 The Sequence construction scheme

	a) the Sequence object is created with default values as a Tkrow comes to life; created not with BUILD but with a sub that can be called many times with different values: Build_tree().
	b) each one of the validate subs for Tkrow entries checks that the input remains correct.
	c) a structure validation routine is called when the Sequence suite is about to be made.
	In case of error this sub refuses to output the suite, changes the selection to unselected, only the proper validation of this Tkrow can reset it to selected.

B<NOTE on modes>

Modes appear more and more like the main mandatory fields and we have to trust their lengths: Modes alone decide of the series base.

There is no question wether or not to apply a mode. Modes are always applied but as natural series, however necessary, their effect is simply null.

Thus, the checkbox called 'mod' or param 'modo' does not relate to modes and should be used freely as required in different other situations.

B<NOTE on Sequence failure>

in case of failure, the Sequence object is not created. A message is printed in stderr and the Tkrow sel checkbox is not checkable, but this last behaviour depends on csgrouper.pl only.

B<NOTE on trees>

The note tree is stored as well in our object. In Suite() one sees well how tree construction can make up for series flaws: lengths and modes are harmonized as much as possible without fatal error.

Some trees are too long to be displayed in a Series tab Tk table entry. In such cases (like when applying Gradual()), the tune is accessible through the command line:  print $CsgObj->sequences->{Seq_0}->tree->tune;

B<NOTE on  the difference between unic and base>

The latter can't be reset by a class or routine. Thus the validate sub for mode at interface level must be strong.
For any test the sub returns the tree. But analysis functions also feed an override @aoa.
Analysis functions are listed under the same classes as other ones. Randond() does not show in the sequence menu in reason of its unpredictable output, moderated by a time limit.

=cut

## ###
package Csgrouper::Sequence; 
use Modern::Perl;
use lib ("~/Csgrouper/lib");
use Moose;
use Moose::Util::TypeConstraints;
use Csgrouper::Types;

=head1 Attributes Section 

In csgrouper &seq_add(), $tkrow is a prefix like "Tkrow_1"; it is an accessor to the stored values of the Tk table row object.

In csgrouper.pl &seq_add(), $seqid is a %Csgrouper::Sequences key like "Seq_1"; its value is a reference to the present object.

=cut

has 'paro'	=> (isa => 'Object', is => 'ro', required => 1); ## A way to refer to a parent object without being an extension of it.
has 'tkrow' => (isa => 'Csgrouper::Types::tkrow', is => 'ro', required => 0);
has 'cdat'  => (isa => 'Str', is => 'ro', required => 0, default => sub{ &Csgrouper::datem('n') });

has 'seqid' => (isa => 'Str', is => 'rw', required => 0);

## The 25 standard Sequence params:
has 'sel'		=> (isa => 'Bool', is => 'ro', required => 1, writer => 'set_sel');
has 'sid'		=> (isa => 'Csgrouper::Types::sid', is => 'ro', required => 1, writer => 'set_sid');
has 'name'	=> (isa => 'Str', is => 'ro', required => 1, writer => 'set_name');
has 'ins'		=> (isa => 'Csgrouper::Types::ins', is => 'ro', required => 1, writer => 'set_ins'); ## Not the same as instr.
has 'instr' => (isa => 'Csgrouper::Types::ins', is => 'ro', required => 1, default => 'i1', writer => 'set_instr'); ## Both are needed.
has 'n'			=> (isa => 'Csgrouper::Types::num', is => 'ro', required => 1, writer => 'set_n');
has 'x'			=> (isa => 'Csgrouper::Types::num', is => 'ro', required => 1, writer => 'set_x');
has 'y'			=> (isa => 'Csgrouper::Types::num', is => 'ro', required => 1, writer => 'set_y');
has 'z'			=> (isa => 'Csgrouper::Types::num', is => 'ro', required => 1, writer => 'set_z');
has 'sets'	=> (isa => 'Csgrouper::Types::sets', is => 'ro', required => 0, writer => 'set_sets');
has 'pre'		=> (isa => 'Csgrouper::Types::sid', is => 'ro', required => 1, writer => 'set_pre');
has 'rep'		=> (isa => 'Int', is => 'ro', required => 0, default => 0, writer => 'set_rep');
has 'funt'	=> (isa => 'Str', is => 'ro', required => 0, writer => 'set_funt'); ## Useful?
has 'fun'		=> (isa => 'Csgrouper::Types::fun', is => 'ro', required => 1, writer => 'set_fun');
has 'exp'		=> (isa => 'Bool', is => 'ro', required => 1, writer => 'set_exp');
has 'modo'	=> (isa => 'Bool', is => 'ro', required => 1, writer => 'set_modo');
has 'A'			=> (isa => 'Csgrouper::Types::serial', is => 'ro', required => 1, writer => 'set_A', default => '0123456789AB');
has 'Aoct'	=> (isa => 'Csgrouper::Types::serial', is => 'ro', required => 1, writer => 'set_Aoct');
has 'Aroc'	=> (isa => 'Bool', is => 'ro', required => 1, writer => 'set_Aroc');
has 'B'			=> (isa => 'Csgrouper::Types::serial', is => 'ro', required => 1, writer => 'set_B');
has 'Boct'	=> (isa => 'Csgrouper::Types::serial', is => 'ro', required => 1, writer => 'set_Boct');
has 'Broc'	=> (isa => 'Bool', is => 'ro', required => 1, writer => 'set_Broc');
has 'ord'		=> (isa => 'Str', is => 'ro', required => 1, writer => 'set_ord');
has 'sign'	=> (isa => 'Str', is => 'ro', required => 1, writer => 'set_sign'); ## No use for random octs anymore but we keep it for anything new.
has 'tone'	=> (isa => 'Csgrouper::Types::musica', is => 'ro', required => 1, default => 0, writer => 'set_tone'); 
has 'mode'	=> (isa => 'Csgrouper::Types::serial', is => 'ro', required => 1, writer => 'set_mode');
has 'com'		=> (isa => 'Str', is => 'ro', required => 1, writer => 'set_com');

## Csgrouper.pm does offer some public analysis functions in order to be able to 
## obtain information in a wide variety of ways. The serial creation functions
## however are mostly private as they enter in the overall csgrouper object system.
## Among them, only Randond will remain public as its incompleteness and
## time dependance doesn't allow to include it in the object system.

## Other properties created by subs:
has 'start'				=> (isa => 'Num', 		is => 'ro', required => 0, default => 0, 				writer => 'set_start');
has 'stop' 				=> (isa => 'Num', 		is => 'ro', required => 0, default => -1, 			writer => 'set_stop');
## This syntax is like a lazy builder except we use a writer (so as to be able to rebuild the object):
has 'tree' 				=> (isa => 'Ref', 		is => 'ro', required => 0, default => sub {{}}, writer => 'set_tree');
has 'root' 				=> (isa => 'Ref', 		is => 'ro', required => 0, default => sub {{}}, writer => 'set_root');
has 'ready'				=> (isa => 'Bool', 		is => 'ro', required => 1, default => 1, 				writer => 'set_ready');
has 'aoa'					=> (isa => 'Ref', 		is => 'ro', required => 0, default => sub {[]}, writer => 'set_aoa');
has 'test'				=> (isa => 'Bool', 		is => 'ro', required => 0, default => 0);
## This has to be set by interface seq_add, and valid_entry.
has 'base'				=> (isa => 'Csgrouper::Types::musbas', 	is => 'rw', required => 1, writer => 'set_base');
has 'ipars'				=> (isa => 'Ref', 		is => 'ro', required => 0, default => sub {{}}, writer => 'set_ipars');


=head1 Subroutines Section

=head2 Private Subroutines:

=over

=item * BUILDARGS($orig,$class) : validate args and correct their contents in order to avoid any object construction failure (this method is called before object creation).
=cut

around BUILDARGS => sub {
	 my ($orig,$class) = @_;
	 my $oldebflag = $Csgrouper::DEBFLAG; 
   # $Csgrouper::DEBFLAG = 1;
	 my $subname = 'Sequence::BUILDARGS';
   { no warnings; &Csgrouper::says($subname, "@_"); }
	 my @params = @_; my %paramh;
	 for (my $n = 0; $n < scalar(@params); $n = $n+2) {
	 	 my ($key, $val) = ($params[$n],$params[$n+1]);
	 	 $paramh{$key} = $val; 
	 	 &Csgrouper::Debug($subname, "$key => $val");
	 } ## END foreach param.
   my @param2; my $test = 0;
	 if (not (&Csgrouper::Types::is_fun($paramh{'fun'}))){
		 &Csgrouper::Describe($subname, "fun => $paramh{'fun'} NOT FUN : FALLING BACK TO DEFAULTS");
		 $paramh{'fun'} = 'Suite';	$test .= 'fun '; ## The basic function.
	 } ## END fun.
	 if (not (&Csgrouper::Types::is_inst($paramh{'ins'}))){
		 &Csgrouper::Describe($subname, "ins => $paramh{'ins'} NOT INS : FALLING BACK TO DEFAULTS");
		 $paramh{'ins'} = 'i1';	$test .= 'ins '; ## The basic instrument. 	 	 	 
	 } ## END fun.
	 if (not (&Csgrouper::Types::is_serial($paramh{'mode'}))){
		 &Csgrouper::Describe($subname, "mode => $paramh{'mode'} NOT SERIAL : FALLING BACK TO DEFAULTS");
		 $paramh{'mode'} = $Csgrouper::CSG{'default_mode'}; $test .= 'mode '; 	
	 } ## END mode.
	 if (not (&Csgrouper::Types::is_serial($paramh{'A'}))){
		 &Csgrouper::Describe($subname, "A => $paramh{'A'} NOT SERIAL : FALLING BACK TO DEFAULTS");
		 $paramh{'A'} = $paramh{'mode'};	$test .= 'A '; ## Must come after 'mode' has been checked. 	 	 	 
	 } ## END A.
	 if (not (&Csgrouper::Types::is_serial($paramh{'Aoct'}))){
		 &Csgrouper::Describe($subname, "Aoct => $paramh{'Aoct'} NOT SERIAL : FALLING BACK TO DEFAULTS");
		 $paramh{'Aoct'} = $paramh{'mode'};	$test .= 'Aoct '; ## Then this oct suite is not good but valid.. 	 	 	 
	 } ## END Aoct.
	 if (not (&Csgrouper::Types::is_serial($paramh{'B'}))){
		 &Csgrouper::Describe($subname, "B => $paramh{'B'} NOT SERIAL : FALLING BACK TO DEFAULTS");
		 $paramh{'B'} = $paramh{'mode'};	$test .= 'B '; ## Must come after 'mode' has been checked. 	 	 	 
	 } ## END B.
	 if (not (&Csgrouper::Types::is_serial($paramh{'Boct'}))){
		 &Csgrouper::Describe($subname, "Boct => $paramh{'Boct'} NOT SERIAL : FALLING BACK TO DEFAULTS");
		 $paramh{'Boct'} = $paramh{'mode'};	$test .= 'Boct '; ## Then this oct suite is not good but valid.. 	 	 	 
	 } ## END Boct.
	 if  (not (&Csgrouper::Types::is_num($paramh{'n'}))){
		 &Csgrouper::Describe($subname, "n => $paramh{'n'} NOT NUM : FALLING BACK TO DEFAULTS");
		 $paramh{'n'} = 0;	$test .= 'n '; 
	 } ## END n.
	 if  (not (&Csgrouper::Types::is_num($paramh{'x'}))){
		 &Csgrouper::Describe($subname, "x => $paramh{'x'} NOT NUM : FALLING BACK TO DEFAULTS");
		 $paramh{'x'} = 0;	$test .= 'x '; 
	 } ## END x.
	 if  (not (&Csgrouper::Types::is_num($paramh{'y'}))){
		 &Csgrouper::Describe($subname, "y => $paramh{'y'} NOT NUM : FALLING BACK TO DEFAULTS");
		 $paramh{'y'} = 0;	$test .= 'y '; 
	 } ## END y.
	 if  (not (&Csgrouper::Types::is_num($paramh{'z'}))){
		 &Csgrouper::Describe($subname, "z => $paramh{'z'} NOT NUM : FALLING BACK TO DEFAULTS");
		 $paramh{'z'} = 0;	$test .= 'z '; 
	 } ## END z.
	 if  (not (Csgrouper::Types::is_set($paramh{'sets'}))){
		 &Csgrouper::Describe($subname, "sets => $paramh{'sets'} NOT SETS : FALLING BACK TO DEFAULTS");
		 $paramh{'sets'} = "";	$test .= 'sets '; 
	 } ## END sets.
	 if  (not (&Csgrouper::Types::is_sid($paramh{'pre'}))){
		 &Csgrouper::Describe($subname, "pre => $paramh{'pre'} NOT SID : FALLING BACK TO DEFAULTS");
		 $paramh{'pre'} = $paramh{'sid'};	$test .= 'pre '; 
	 } ## END pre.
	 if  (not $paramh{'rep'} == 0 || not (&Csgrouper::Types::is_sid($paramh{'rep'}))){ ## let's limit rep to MAXOBJ too.
		 &Csgrouper::Describe($subname, "rep => $paramh{'rep'} NOT < MAXOBJ : FALLING BACK TO DEFAULTS");
		 $paramh{'rep'} = 0;	$test .= 'rep '; 
	 } ## END rep.
	 if  (not ($paramh{'exp'} =~ /^([01]{1})$/)){ 
		 &Csgrouper::Describe($subname, "exp => $paramh{'exp'} NOT BOOL : FALLING BACK TO DEFAULTS");
		 $paramh{'exp'} = 0;	$test .= 'exp '; 
	 } ## END exp.
	 if  (not ($paramh{'modo'} =~ /^([01]{1})$/)){ 
		 &Csgrouper::Describe($subname, "modo => $paramh{'modo'} NOT BOOL : FALLING BACK TO DEFAULTS");
		 $paramh{'modo'} = 0;	$test .= 'modo '; 
	 } ## END modo.
	 if  (not ($paramh{'Aroc'} =~ /^([01]{1})$/)){ 
		 &Csgrouper::Describe($subname, "Aroc => $paramh{'Aroc'} NOT BOOL : FALLING BACK TO DEFAULTS");
		 $paramh{'Aroc'} = 0;	$test .= 'Aroc '; 
	 } ## END Aroc.
	 if  (not ($paramh{'Broc'} =~ /^([01]{1})$/)){ 
		 &Csgrouper::Describe($subname, "Broc => $paramh{'Broc'} NOT BOOL : FALLING BACK TO DEFAULTS");
		 $paramh{'Broc'} = 0;	$test .= 'Broc.'; 
	 } ## END Broc.
	 if (
	 	 	(not ($paramh{'tone'} =~ /^(.{1})$/)) ||
	 	 	(not (&Csgrouper::Types::is_musica($paramh{'tone'})))||
	 	 	(&Csgrouper::Dodecad($paramh{'tone'}) >= length($paramh{'mode'}))
	 	 	){ 
		 &Csgrouper::Describe($subname, "tone => $paramh{'tone'} NOT BOOL : FALLING BACK TO DEFAULTS");
		 $paramh{'tone'} = 0;	$test .= 'tone '; 
	 } ## END Broc.
	 if ($test ne 0) {
	 	 $paramh{'name'} = "AUTORECONF: ".$paramh{'name'};
	 }
	 $paramh{'base'} = length($paramh{'mode'});
 	 while (my ($key,$val) = each (%paramh)){ push @param2, ($key , $val) }
 	 &Csgrouper::Debug($subname, "@params");
 	 &Csgrouper::Debug($subname, "@param2");
	$Csgrouper::DEBFLAG = $oldebflag;
	return $class->$orig(@param2);
}; ## END Sequence::BUILDARGS().

sub BUILD {
	my ($self) = @_;
	my $subname = 'Sequence::BUILD';
  { no warnings; &Csgrouper::says($subname, "@_"); }
 	## Create the iparam array:
 	my @a = split(/\,/,$self->ins);
	$self->set_instr(shift(@a));
	if (scalar(@a)>0){
	 	 &Csgrouper::Describe($subname, "Seq_".$self->sid." ipars: @a");
	 	 &Csgrouper::Describe($subname, "Seq_".$self->sid." instr: ".$self->instr);
	 	 my %ah;
	 	 foreach (@a){
	 	 	 my ($key,$val) = split(/=/,$_);
	 	 	 	 $ah{$key} = $val;	 
	 	 }
	 	 $self->set_ipars(\%ah);
	}
}

=item * out_mode($self) : modal exclusion.
=cut

## :
sub out_mode{
	my ($self) = @_;
	my $subname = 'Sequence::out_mode';
  { no warnings; &Csgrouper::says($subname, "@_"); }
	my $oldebflag = $Csgrouper::DEBFLAG; 
	# $Csgrouper::DEBFLAG = 1;
	&Csgrouper::Error($subname,"Private method called.",1) 
    unless (caller)[0]->isa( ref($self) );
	my @mode = split //,$self->mode;
  my $base = scalar(@mode); 
  ## This value is determinant: if the mode length is not wanted then the series
  ## object will be reduced without possible autocorrection.
	my @charset = split //,$Csgrouper::CSG{'char_set'};
	my $validmode = "";	my $outofmode = ""; ## Initialize them.
	## $mode will not be larger than $base:
	splice(@charset,$base);
	## If $mode is dodecaphonic ('0123456789AB') then $outofmode will remain empty:	
	for (my $i = 0; $i < $base; $i++) {  
		## Possible errors have already been trapped by Types.
		$outofmode .= $charset[$i] if (not($charset[$i] ~~ @mode)); 
	} 
	$Csgrouper::DEBFLAG =	$oldebflag;
	return($outofmode);
} ## END Sequence::out_mode().

=item * random($self) : returns random permutation(s) in a particular mode.

The checkbox 'mod' has to be checked in order to reproduce the random choice each time the part is reloaded.
Otherwise random() will be run only once and replaced afterwards by a neutral AUTORECONF Suite() function and param 'A' will display the random output previously obtained.

=cut

sub random { ## Adapted 110905.
	my ($self) = @_;
	## Init:
	my $subname = 'Sequence::random';
  { no warnings; &Csgrouper::says($subname, "@_"); }
	my $oldebflag = $Csgrouper::DEBFLAG; 
	# $Csgrouper::DEBFLAG = 1;
	&Csgrouper::Error($subname,"Private method called.",1) 
    unless (caller)[0]->isa( ref($self) );
	## Vars:
	my (%modeh, @outmode);
	my (@excl, $new, $octs, $octaves, $series, $test);
	my ($rc,$ro,$rs) ; ## Random note, oct, sign.
	my $unic = 0; 
	## Length control and mode:
	my $outofmode = &out_mode($self); ## Resets dodecaphonic mode in case of error.
	my @mode = split //,$self->mode;
	foreach (@mode) { $modeh{$_}++ }; ## $modeh{n} == The number of occurences of n.
	@outmode = split //,$outofmode if (defined $outofmode);
	my $cols = length($self->mode); 
	my $rows = $self->x;
	my $baseoct = $self->y;
	my $orange = $self->z;
	&Csgrouper::Error($subname,"Not a valid serial length: $cols",1) if ($cols < 2 || $cols > 12);
	## Other tests:
	if ($rows !~ /.+/ || $rows > $Csgrouper::Types::MAXOBJ || $rows < 1) { $rows = 1 }
	$unic = 1 if ($rows == 1);
	$baseoct = $Csgrouper::CSG{'oct_base'} if (int($baseoct) < 1 || (not($Csgrouper::CSG{char_set} =~ /$baseoct/)));
	$orange = $Csgrouper::CSG{'oct_range'} if ($orange > 11-&Csgrouper::Decab($baseoct) || &Csgrouper::Decab($baseoct)-$orange < 0); ## Some notes wouldn't be heared.
	&Csgrouper::Debug($subname,"($rows,$baseoct,$orange) mode: @mode out: @outmode ");
	## Main loop:
	my $n = 0;
	until ($n == $rows){
		$new = ""; $octs = ""; splice @excl; 
		my %locmodeh;
		while (my ($key,$val) = each(%modeh)) { $locmodeh{$key} = $val };	## Clone (deep copy).
		@excl = @outmode; ## Outmode = excluded.
		for (my $i = 0; $i < $cols; $i++){ 
			$test = 0; 
			until ($test == 1) {
				$rs = "+"; $rs = "-" if (int(rand(2))==0 && $orange > 0); 
				my $int;
				{ no warnings; $int = eval("$baseoct $rs ".int(rand($orange+1))) } 
				$ro = &Csgrouper::Decadod($int); # rand(x) returns < x.
				$rc = &Csgrouper::Decadod(int(rand($cols))); # rand(cols) selects < cols.
				my $subtest = 0;
				if (scalar @excl > 0) { foreach (@excl) { $subtest++ if ($_ eq $rc) } } ## Smart matching is not too good at this...
				if ($subtest == 0)  { ## Either @excl is empty or it does not contain $rc.
					$test = 1; $new .= $rc; $octs .= $ro;
					$locmodeh{$rc}--;
					push @excl, $rc if ($locmodeh{$rc} == 0); ## Already seen enough times.
				}
			} ## END until test.
		} ## END for my cols.
		++$n;
		&Csgrouper::Describe($subname,"$new $octs");
		$series .= $new; $octaves .= $octs;
	} ## END until rows.
	$Csgrouper::DEBFLAG =	$oldebflag;
	return($series,$octaves,$unic); 
} ## END Sequence::random().

=back

=head2 Public Subroutines

=over

=item * Build_tree($self) : main object (re)creation.
=cut

sub Build_tree { 
	my ($self) = @_;
	my $subname = 'Sequence::Build_tree';
  { no warnings; &Csgrouper::says($subname, "@_"); }
	## Preliminary tests:
	my $seqid = $self->seqid;
	$self->set_ready(0); ## Set it to "not ready" first.
	if ($self->sel == 0){ ## We simply don't have this sequence yet:
		&Csgrouper::Describe($subname,"No tree for unselected row $seqid.");
		return;
	}
	my $oldebflag = $Csgrouper::DEBFLAG; 
	my $oldRflag = $Csgrouper::CSG{'part_Rflag_le'};
	my $oldSflag = $Csgrouper::CSG{'Sflag'};
	my $oldsteps = $Csgrouper::CSG{'part_steps_le'};
	my $oldobase = $Csgrouper::CSG{'oct_base'};
	# $Csgrouper::DEBFLAG = 1;
	&Csgrouper::Debug($subname,$self->name);
	my $fun = $self->fun;
	my @aoargs; push @aoargs, $fun;
	my $argclass = $Csgrouper::Types::Funx{$fun}{arg_class};
	my $base = length($self->mode); $self->set_base($base);
	my (@aoa, $longtune, $longocts, $octree, $octs, $outofmode, $over, $rep, $tree, $tune ,$unic);
	$over = 0; ## aoa override for analysis.
	&Csgrouper::Debug($subname, "$seqid : fun: $fun arg_class: $argclass base: $base");
	## 1. Create the long tune according to arg class:
	if ($argclass =~ /^0/) { 
		if ($fun eq "random") { ## RANDOM : the sole function in this class at present.
			push @aoargs, ("mod=".$self->mode,"row=".$self->x,"boc=".$self->y,"orn=".$self->z,"dyn=".$self->modo);
			($tune,$octs,$unic) = &random($self); ## random() manages possible repetitions.
			$self->set_root(
				Csgrouper::Series->new(
					 tune=>$tune ## Intone() is already done by random().
					,octs=>$octs
			    ,paro=>$self
					,unic=>$unic
					,orig=>$seqid
				)
			);
			&Csgrouper::Debug($subname, "tune: ".$self->root->tune);
			if ($self->modo != 1){ 
				## Then we don't want to change this sequence each time the part gets reloaded so:
				$self->set_fun('Suite');
				## This will show in the interface that fun has been changed:
				$self->set_funt($Csgrouper::Types::Funx{'Suite'}{menutext}.$Csgrouper::Types::FUNOUT);
			}
			$self->set_A($tune); ## Report the root tune in A anyway.
			$self->set_Aoct($octs);
			$unic = $self->root->unic; ## Was it changed by Csgrouper::Series?
			$longtune = $self->root->tune; 
			$longocts = $self->root->octs;
		} ## END random().
	} ## END argclass 0. 
	elsif ($argclass =~ /^1/) { 
		$outofmode = &out_mode($self);
		&Csgrouper::Debug($subname, "out_mode: $outofmode base: $base");
		$unic = &Csgrouper::Types::is_unic($self->A,$base);
		## Is Aoct meant to be a random sequence?
		if ($self->Aroc == 1) { $self->set_Aoct(&Csgrouper::Octset(length($self->A),1)) }
		$self->set_root(
			Csgrouper::Series->new(
				 tune=>&Csgrouper::Intone($self->A,$self->mode,$self->tone,$base)
				,octs=>$self->Aoct
			  ,paro=>$self
				,unic=>$unic
				,orig=>$seqid
			)
		);
		$unic = $self->root->unic; ## Was it changed by Csgrouper::Series?
		&Csgrouper::Debug($subname, "root: ".$self->root->tune." unic: $unic rep: ".$self->rep);
		if ($fun eq "Invert") { 
			push @aoargs, ("ori=".$self->A,"oct=".$self->Aoct);
			($longtune,$longocts) =  &Csgrouper::Invert($self->A,$self->Aoct,$base,$self->x,'p');
			$longtune = &Csgrouper::Intone($longtune,$self->mode,$self->tone,$base);
		} ## END Invert();
		elsif ($fun eq "Oppose") { 
			push @aoargs, ("ori=".$self->A,"oct=".$self->Aoct);
			($longtune,$longocts) =  &Csgrouper::Oppose($self->A,$self->Aoct,$base,$self->x,'p');
			$longtune = &Csgrouper::Intone($longtune,$self->mode,$self->tone,$base);
		} ## END Oppose();
		elsif ($fun eq "Revert") { 
			push @aoargs, ("ori=".$self->A,"oct=".$self->Aoct);
			($longtune,$longocts) =  &Csgrouper::Revert($self->A,$self->Aoct,$base,'p');
			$longtune = &Csgrouper::Intone($longtune,$self->mode,$self->tone,$base);
		} ## END Revert();
		elsif ($fun eq "Suite") { 
			push @aoargs, ("ori=".$self->A,"oct=".$self->Aoct);
			$longtune =  $self->root->tune;	$longocts = $self->root->octs;
		} ## END Suite();
		elsif ($fun eq "Transpose") {
			push @aoargs, ("ori=".$self->A,"oct=".$self->Aoct,"int=".$self->n);
			($longtune,$longocts) =  &Csgrouper::Transpose($self->A,$self->Aoct,$self->n,$base,'p');
			$longtune = &Csgrouper::Intone($longtune,$self->mode,$self->tone,$base);
		} ## END Suite();
	} ## END argclass == 1.
	elsif ($argclass =~ /^2/) { ## Series is (or will be reduced to) a unique row.
		if  ($fun eq "Intrain") { 
		  $Csgrouper::CSG{'part_steps_le'} = $self->n unless (($self->n < 1) || ($self->n > $base/2) || ($base/$self->n != int($base/$self->n)));
		  $Csgrouper::CSG{'part_Rflag_le'} = $self->Aroc unless ($self->Aroc !~ /1|0/);
		  $Csgrouper::CSG{'Sflag'} = 0; ## Express()
			push @aoargs, ("ori=".$self->A,"oct=".$self->Aoct,"key=".$self->B,"oct=".$self->Boct,"ord=".$self->ord);
			@aoa = &Csgrouper::Intrain($self->A,$self->Aoct,$self->B,$self->Boct,$self->ord);
			foreach (@{$aoa[0]}) { $longtune .= &Csgrouper::Intone($_,$self->mode,$self->tone,$base) }
			foreach (@{$aoa[1]}) { $longocts .= $_ }
			push @aoargs, "len=".scalar(@{$aoa[0]});
		}
		elsif  ($fun eq "Dynatrain") { 
		  $Csgrouper::CSG{'part_steps_le'} = $self->n unless (($self->n < 1) || ($self->n > $base/2) || ($base/$self->n != int($base/$self->n)));
		  $Csgrouper::CSG{'part_Rflag_le'} = $self->Aroc unless ($self->Aroc !~ /1|0/);
		  $Csgrouper::CSG{'Sflag'} = 0; ## Express()
			push @aoargs, ("ori=".$self->A,"oct=".$self->Aoct,"key=".$self->B,"oct=".$self->Boct,"ord=".$self->ord);
			@aoa = &Csgrouper::Dynatrain($self->A,$self->Aoct,$self->B,$self->Boct,$self->ord);
			foreach (@{$aoa[0]}) { $longtune .= &Csgrouper::Intone($_,$self->mode,$self->tone,$base) }
			foreach (@{$aoa[1]}) { $longocts .= $_ }
			push @aoargs, "len=".scalar(@{$aoa[0]});
		}
		elsif  ($fun eq "Oppgrad") { 
		  $Csgrouper::CSG{'part_Rflag_le'} = $self->Aroc unless ($self->Aroc !~ /1|0/);
			push @aoargs, ("ori=".$self->A);
			if ($self->exp == 1){
				@aoa = &Csgrouper::Oppgrad($self->A,'p');
				foreach (@{$aoa[0]}) { $longtune .= &Csgrouper::Intone($_,$self->mode,$self->tone,$base) }
				foreach (@{$aoa[1]}) { $longocts .= $_ }
			}
			else { 	
				my ($deg,$row,$octs) = &Csgrouper::Oppgrad($self->A);
				push @aoargs, ("deg=$deg"); 
				$longtune = $row;
				$longocts = $octs;
			}
		}
		elsif  ($fun eq "Train") { 
		  $Csgrouper::CSG{'part_steps_le'} = $self->n unless (($self->n < 1) || ($self->n > $base/2) || ($base/$self->n != int($base/$self->n)));
		  $Csgrouper::CSG{'part_Rflag_le'} = $self->Aroc unless ($self->Aroc !~ /1|0/);
		  $Csgrouper::CSG{'Sflag'} = 0; ## Express()
			push @aoargs, ("ori=".$self->A,"oct=".$self->Aoct,"key=".$self->B,"oct=".$self->Boct,"ord=".$self->ord);
			@aoa = &Csgrouper::Train($self->A,$self->Aoct,$self->B,$self->Boct,$self->ord);
			foreach (@{$aoa[0]}) { $longtune .= &Csgrouper::Intone($_,$self->mode,$self->tone,$base) }
			foreach (@{$aoa[1]}) { $longocts .= $_ }
			push @aoargs, "len=".scalar(@{$aoa[0]});
		}
		elsif  ($fun eq "Trainspose") { 
		  $Csgrouper::CSG{'part_steps_le'} = $self->n unless (($self->n < 1) || ($self->n > $base/2) || ($base/$self->n != int($base/$self->n)));
		  $Csgrouper::CSG{'part_Rflag_le'} = $self->Aroc unless ($self->Aroc !~ /1|0/);
		  $Csgrouper::CSG{'Sflag'} = 0; ## Express()
			push @aoargs, ("ori=".$self->A,"oct=".$self->Aoct,"key=".$self->B,"oct=".$self->Boct,"ord=".$self->ord,"sig=".$self->sign);
			@aoa = &Csgrouper::Trainspose($self->A,$self->Aoct,$self->B,$self->Boct,$self->ord,$self->sign);
			foreach (@{$aoa[0]}) { $longtune .= &Csgrouper::Intone($_,$self->mode,$self->tone,$base) }
			foreach (@{$aoa[1]}) { $longocts .= $_ }
			push @aoargs, "len=".scalar(@{$aoa[0]});
		}
	}  ## END argclass == 2. 
	elsif ($argclass =~ /^3/) { ## A schoenbergian row.
		if ((not &Csgrouper::Types::is_arow($self->A)) ## Target.
				|| (not &Csgrouper::Types::is_unic($self->B,$base)) ## Keys.
				|| ((not $self->fun =~ /Randcond/) && (not &Csgrouper::Types::is_arow($self->ord)))  ## Ord.
				|| (not &Csgrouper::Types::is_unic($self->mode,$base)) ## mode.
			 ) 
		{
			&Csgrouper::Error($subname, "Can't analyze when keys (B), root (A), ord or mode are not Schoenberg-compatible rows. Use indistinct signs in mode only.");
		}
		$outofmode = &out_mode($self);
		&Csgrouper::Debug($subname, "out_mode: $outofmode base: $base");
		$unic = &Csgrouper::Types::is_unic($self->A,$base);
		## Is Aoct meant to be a random sequence?
		if ($self->Aroc == 1) { $self->set_Aoct(&Csgrouper::Octset(length($self->A),1)) }
		$self->set_root(
			Csgrouper::Series->new(
				 tune=>&Csgrouper::Intone($self->A,$self->mode,$self->tone,$base)
				,octs=>$self->Aoct
				,unic=>$unic
				,orig=>$seqid
				,paro=>$self
			)
		);
		## Override this if necessary:
		$longtune = $self->root->tune; 
		$longocts = $self->root->octs;
		&Csgrouper::Debug($subname, "root: ".$self->root->tune." unic: $unic rep: ".$self->rep);
		## ### ### ANALYSIS FUNCTIONS:
		## These functions allow indistinct signs so intone() series are OK (except for ord):
		if ($fun eq "Dynana") { 
			@aoa = &Csgrouper::Dynana($self->root->tune,&Csgrouper::Intone($self->B,$self->mode,$self->tone,$base),$self->ord,$self->exp);
			unshift(@aoa,["Dynana","row=".$self->root->tune,"key=".&Csgrouper::Intone($self->B,$self->mode,$self->tone,$base),"ord=".$self->ord,":"]);
			$self->set_aoa(\@aoa) if ($self->test);
			$over = 1; ## Override @aoa recording.
		} ## END Dynana();
		elsif ($fun eq "Inana") { 
			@aoa = &Csgrouper::Inana($self->root->tune,&Csgrouper::Intone($self->B,$self->mode,$self->tone,$base),$self->ord,$self->exp);
			unshift(@aoa,["Inana","row=".$self->root->tune,"key=".&Csgrouper::Intone($self->B,$self->mode,$self->tone,$base),"ord=".$self->ord,":"]);
			$self->set_aoa(\@aoa) if ($self->test);
			$over = 1; 
		} ## END Inana();
		elsif ($fun eq "Randcond") {
			if($self->n > $Csgrouper::Types::MAXBAS){
				&Csgrouper::Error($subname,"Invalid size n=".$self->n);
			}
			$base = $self->n;
			@aoa = $longtune = &Csgrouper::Randcond($self->n,$self->ord);
			unshift(@aoa,["Randcond","col=".$self->n,"ord=".$self->ord,":"]);
			$self->set_aoa(\@aoa) if ($self->test);
			$over = 1; 
		} ## END Inana();
		elsif  ($fun eq "Smetana") { 
			@aoa = &Csgrouper::Smetana($self->A);
			unshift(@aoa,["Smetana","row=".$self->A,":"]);
			$self->set_aoa(\@aoa);
			$over = 1; 
		} ## ### ### END OF ANALYSIS FUNCTIONS.
		elsif  ($fun eq "Gradomap") { 
			## Random octs? Here they are treated directly by Gradomap.
			my $newobase = $self->Aoct; $newobase =~ s/(.{1})(.*)/$1/; $Csgrouper::CSG{'oct_base'} = $newobase;
		  $Csgrouper::CSG{'part_Rflag_le'} = $self->Aroc unless ($self->Aroc !~ /1|0/);
			push @aoargs, ("ori=".$self->A);
			## (erase $longtune to get rid of it).
			if ($self->exp == 1){
				@aoa = &Csgrouper::Gradomap($self->A,'p');
				foreach (@{$aoa[0]}) { $longtune .= &Csgrouper::Intone($_,$self->mode,$self->tone,$base) }
				foreach (@{$aoa[1]}) { $longocts .= $_ }
			}
			else { 	
				my ($deg,$row,$octs) = &Csgrouper::Gradomap($self->A);
				push @aoargs, ("deg=$deg");
				$longtune = $row;
				$longocts = $octs;
			}
		}
		elsif  ($fun eq "Gradual") { 
			my $newobase = $self->Aoct; $newobase =~ s/(.{1})(.*)/$1/; $Csgrouper::CSG{'oct_base'} = $newobase;
		  $Csgrouper::CSG{'part_Rflag_le'} = $self->Aroc unless ($self->Aroc !~ /1|0/);
			push @aoargs, ("ori=".$self->A);
			if ($self->exp == 1){
				
				@aoa = &Csgrouper::Gradual($self->A,'p');
				foreach (@{$aoa[0]}) { $longtune .= &Csgrouper::Intone($_,$self->mode,$self->tone,$base) }
				foreach (@{$aoa[1]}) { $longocts .= $_ }
			}
			else { 	push @aoargs, ("deg=".&Csgrouper::Gradual($self->A)) }
		}
		elsif  ($fun eq "Map") { 
			my $newobase = $self->Aoct; $newobase =~ s/(.{1})(.*)/$1/; $Csgrouper::CSG{'oct_base'} = $newobase;
			if ($self->Broc == 1) { $longocts = &Csgrouper::Octset(length($self->A),1) }
			else { $longocts = $self->Aoct}
			push @aoargs, ("ori=".$self->A,"map=".$self->B);
			$longtune = &Csgrouper::Map($self->A,$self->B);
			$longtune = &Csgrouper::Intone($longtune,$self->mode,$self->tone,$base);
		}
		elsif  ($fun eq "Omap") { 
			my $newobase = $self->Aoct; $newobase =~ s/(.{1})(.*)/$1/; $Csgrouper::CSG{'oct_base'} = $newobase;
			if ($self->Broc == 1) { $longocts = &Csgrouper::Octset(length($self->A),1) }
			else { $longocts = $self->Aoct}
			push @aoargs, ("ori=".$self->A);
			$longtune = &Csgrouper::Omap($self->A);
			$longtune = &Csgrouper::Intone($longtune,$self->mode,$self->tone,$base);
		}
		elsif  ($fun eq "Powerp") { 
			## Random octs? Here they are treated directly by Powerp.
			my $newobase = $self->Aoct; $newobase =~ s/(.{1})(.*)/$1/; $Csgrouper::CSG{'oct_base'} = $newobase;
		  $Csgrouper::CSG{'part_Rflag_le'} = $self->Aroc unless ($self->Aroc !~ /1|0/);
			push @aoargs, ("ori=".$self->A,"per=".$self->B,"pow=".$self->n,"exp=".$self->exp);
			if ($self->exp == 1){
				## This way the original A series is included at start:
				## (erase $longtune to get rid of it).
				@aoa = &Csgrouper::Powerp($self->A,$self->B,$self->n,'a');
				foreach (@{$aoa[0]}) { $longtune .= &Csgrouper::Intone($_,$self->mode,$self->tone,$base) }
				foreach (@{$aoa[1]}) { $longocts .= $_ }
			}
			else {
				($longtune,$longocts) = &Csgrouper::Powerp($self->A,$self->B,$self->n,'p');
				$longtune = &Csgrouper::Intone($longtune,$self->mode,$self->tone,$base);
			}
			$Csgrouper::CSG{'part_Rflag_le'} = $oldRflag;
		}
		elsif  ($fun eq "Supergrad") { 
			my $newobase = $self->Aoct; $newobase =~ s/(.{1})(.*)/$1/; $Csgrouper::CSG{'oct_base'} = $newobase;
		  $Csgrouper::CSG{'part_Rflag_le'} = $self->Aroc unless ($self->Aroc !~ /1|0/);
			push @aoargs, ("ori=".$self->A);
			if ($self->exp == 1){
				@aoa = &Csgrouper::Supergrad($self->A,'p');
				foreach (@{$aoa[0]}) { $longtune .= &Csgrouper::Intone($_,$self->mode,$self->tone,$base) }
				foreach (@{$aoa[1]}) { $longocts .= $_ }
			}
			else { 	
				my ($deg,$cycle,$row,$octs) = &Csgrouper::Supergrad($self->A);
				push @aoargs, ("deg=$deg","cyc=$cycle"); 
				$longtune = $row;
				$longocts = $octs;
			}
			$Csgrouper::CSG{'part_Rflag_le'} = $oldRflag;
		}
		elsif  ($fun eq "Unmap") { 
			my $newobase = $self->Aoct; $newobase =~ s/(.{1})(.*)/$1/; $Csgrouper::CSG{'oct_base'} = $newobase;
			if ($self->Broc == 1) { $longocts = &Csgrouper::Octset(length($self->A),1) }
			else { $longocts = $self->Aoct}
			push @aoargs, ("ori=".$self->A,"map=".$self->B);
			$longtune = &Csgrouper::Unmap($self->A,$self->B);
			$longtune = &Csgrouper::Intone($longtune,$self->mode,$self->tone,$base);
		}
	} ## END argclass == 3. 
	else { &Csgrouper::Error($subname, "Not a valid arg class: $argclass") }
	## 2. Record the longtune as tree:
	$rep = ($self->rep)+1; 
	until ($rep-- == 0){ ## Let's repeat it..
		$tree .= $longtune;
		$octree .= $longocts;
	}
	$unic = 0 if ($self->rep > 0); ## Its value is already set for the series length.
	$self->set_tree(
	Csgrouper::Series->new(
			 tune=>$tree
			,octs=>$octree
			,unic=>$unic
			,orig=>$seqid
			,paro=>$self
		)
	);
	&Csgrouper::Debug($subname, "tree: ".$self->tree->tune);
	&Csgrouper::Debug($subname, "octs: ".$self->tree->octs);
	&Csgrouper::Debug($subname, "base: ".$self->base);
	## The following yields an error since unic is Bool (not "0"):
	## &Csgrouper::Debug($subname, "unic: ".$self->tree->unic);
	unless ($over == 1) {
		@aoa = ($self->tree->tune,$self->tree->octs);
		unshift(@aoa,[@aoargs]);
	}
	$self->set_aoa(\@aoa) if ($self->test);
	## XXX NOTE on class independance:
	## The interface will then have to report changes into the concerned variables
	## (A,A_oct,fun,funt,etc..). This must not be done here in order to leave our
	## classes independant vis-à-vis the interface.
	$self->set_ready(1); ## If we're not dead yet, then we're ready..
	&Csgrouper::Describe($subname, "ready: ".$self->ready); 
	$Csgrouper::CSG{'part_steps_le'} = $oldsteps;
	$Csgrouper::CSG{'part_Rflag_le'} = $oldRflag;
	$Csgrouper::CSG{'Sflag'} = $oldSflag;
	$Csgrouper::CSG{'oct_base'} = $oldobase;
	$Csgrouper::DEBFLAG =  $oldebflag;
	return $self; ## For convenience.
} ## END Sequence::Build_tree.

__PACKAGE__->meta->make_immutable; 
no Moose; 

1;
__DATA__

=back

=head1	Data Section

Params:
	
	my $seqid = "Seq_".$CsgObj ->sequences->{$pref.'_id'};

	push @params, 'sel' =>$CsgObj ->sequences->{$pref.'_sel'};
	push @params, 'sid' =>$CsgObj ->sequences->{$pref.'_id'}; 
	push @params, 'name' =>$CsgObj ->sequences->{$pref.'_name'};
	push @params, 'ins' =>$CsgObj ->sequences->{$pref.'_ins'};
	push @params, 'n' =>$CsgObj ->sequences->{$pref.'_n'};
	push @params, 'x' =>$CsgObj ->sequences->{$pref.'_x'};
	push @params, 'y' =>$CsgObj ->sequences->{$pref.'_y'};
	push @params, 'z' =>$CsgObj ->sequences->{$pref.'_z'};
	push @params, 'sets' =>$CsgObj ->sequences->{$pref.'_sets'};
	push @params, 'pre' =>$CsgObj ->sequences->{$pref.'_pre'};
	push @params, 'rep' =>$CsgObj ->sequences->{$pref.'_rep'};
	push @params, 'funt' =>$CsgObj ->sequences->{$pref.'_funt'};
	push @params, 'fun' =>$CsgObj ->sequences->{$pref.'_fun'};
	push @params, 'exp' =>$CsgObj ->sequences->{$pref.'_exp'};
	push @params, 'modo' =>$CsgObj ->sequences->{$pref.'_modo'};
	push @params, 'A' =>$CsgObj ->sequences->{$pref.'_A'};
	push @params, 'Aoct' =>$CsgObj ->sequences->{$pref.'_Aoct'};
	push @params, 'Aroc' =>$CsgObj ->sequences->{$pref.'_Aroc'};
	push @params, 'B' =>$CsgObj ->sequences->{$pref.'_B'};
	push @params, 'Boct' =>$CsgObj ->sequences->{$pref.'_Boct'};
	push @params, 'Broc' =>$CsgObj ->sequences->{$pref.'_Broc'};
	push @params, 'ord' =>$CsgObj ->sequences->{$pref.'_ord'};
	push @params, 'sign' =>$CsgObj ->sequences->{$pref.'_sign'};
	push @params, 'mode' =>$CsgObj ->sequences->{$pref.'_mode'};
	push @params, 'tone' =>$CsgObj ->sequences->{$pref.'_tone'};
	push @params, 'com' =>$CsgObj ->sequences->{$pref.'_com'};
	push @params, 'cdat' =>$date;
	push @params, 'mdat' =>$date;
	push @params, 'tkrow' =>$pref;
	push @params, 'seqid' =>$seqid;

