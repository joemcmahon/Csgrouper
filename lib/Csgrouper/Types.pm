###############################################################################
## ### FILE INFO:
###############################################################################
## 110831.
## Some type definitions for Csgrouper.
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

=head1 Manual for Types.pm
=cut

## ###
package Csgrouper::Types; 
use Modern::Perl;
use lib (	"~/Csgrouper/lib");
use Moose;
use Moose::Util::TypeConstraints;
use Csgrouper;

=head1 Global Section 
=cut

our 	$DISTSI             = "d";
our 	$FUNOUT             = "o";
our 	$MAXBAS 						= 24; 	## Quarter notes.
our 	$MAXOBJ 						= 576; 	## $MAXBAS^2
our 	$MAXPAR 						= 80; 	## Csound Instrument params

## Function table:
## Don't forget to reference each new function here.
our @Funcs = qw /Dynana Dynatrain Gradomap Gradual Inana Intrain Invert Map Omap Oppose Oppgrad Powerp random Randcond Revert Smetana Suite Supergrad Train Trainspose Transpose Unmap/;
our %Funx;
foreach (@Funcs) { $Funx{$_} = {} }
$Funx{'arg_types'} = {};
## Now define some properties for each one of the 17 functions:
## By type-class:
## 0  *int,*int,*int
$Funx{'arg_types'}{'0'} = "*int,*int,*int"; ## This is the arg_class 0: no serial arg.
$Funx{'random'}{arg_class} = 0;
$Funx{'random'}{menutext} = "Random([base],xro,yoc)"; 
## 1  serial,octs: a serial root arg.
$Funx{'arg_types'}{'1'} = "serial,octs";
$Funx{'Revert'}{arg_class} = 1;
$Funx{'Revert'}{menutext} = "Revert(A,oct)"; 
$Funx{'Suite'}{arg_class} = 1;
$Funx{'Suite'}{menutext} = "Suite(A,oct)"; 
## 11  serial,octs,musbas,musbas
$Funx{'arg_types'}{'11'} = "serial,octs,musbas";
$Funx{'Invert'}{arg_class} = 11;
$Funx{'Invert'}{menutext} = "Invert(A,oct,xax)"; 
$Funx{'Oppose'}{arg_class} = 11;
$Funx{'Oppose'}{menutext} = "Oppose(A,oct,xax)"; 
## 12  serial,octs,serial,sign,octs
$Funx{'arg_types'}{'12'} = "serial,octs,num";
$Funx{'Transpose'}{arg_class} = 12;
$Funx{'Transpose'}{menutext} = "Transpose(A,oct,nin)"; 
## 2  unic: a unic root arg.
$Funx{'arg_types'}{'2'} = "unic";
$Funx{'Oppgrad'}{arg_class} = 2;
$Funx{'Oppgrad'}{menutext} = "Gradual(Opposite(A))"; 
## 21 unic,octs,unic,octs,arow
$Funx{'arg_types'}{'21'} = "unic,octs,unic,octs,arow";
$Funx{'Intrain'}{arg_class} = 21;
$Funx{'Intrain'}{menutext} = "Static(A,oct,B,oct,ord)"; 
$Funx{'Dynatrain'}{arg_class} = 21;
$Funx{'Dynatrain'}{menutext} = "Dynamic(A,oct,B,oct,ord)"; 
$Funx{'Train'}{arg_class} = 21;
$Funx{'Train'}{menutext} = "Train(A,oct,B,oct,ord)"; 
## 22 unic,octs,unic,sign,octs,arow
$Funx{'arg_types'}{'22'} = "unic,octs,unic,octs,arow";
$Funx{'Trainspose'}{arg_class} = 22;
$Funx{'Trainspose'}{menutext} = "Trainspose(A,oct,B,oct,ord,sig)"; 
## 3  arow: a row root arg.
$Funx{'arg_types'}{'3'} = "arow";
$Funx{'Gradual'}{arg_class} = 3;
$Funx{'Gradual'}{menutext} = "Gradual(A)".$DISTSI; 
$Funx{'Gradomap'}{arg_class} = 3;
$Funx{'Gradomap'}{menutext} = "Gradual(Omap(A))".$DISTSI; 
$Funx{'Supergrad'}{arg_class} = 3;
$Funx{'Supergrad'}{menutext} = "Supergrad(Omap(A))".$DISTSI; 
## 31  arow,octs
$Funx{'arg_types'}{'31'} = "arow,octs";
$Funx{'Omap'}{arg_class} = 31;
$Funx{'Omap'}{menutext} = "Omap(A,Aoct)".$DISTSI; 
## 32  arow,arow,int
$Funx{'arg_types'}{'32'} = "arow,arow,int";
$Funx{'Powerp'}{arg_class} = 32;
$Funx{'Powerp'}{menutext} = "Permute(A,B,n)".$DISTSI; 
## 33  arow,arow,octs
$Funx{'arg_types'}{'33'} = "arow,arow,octs";
$Funx{'Map'}{arg_class} = 33;
$Funx{'Map'}{menutext} = "Map(A,B,oct)".$DISTSI; 
$Funx{'Unmap'}{arg_class} = 33;
$Funx{'Unmap'}{menutext} = "Unmap(A,B,oct)".$DISTSI; 
## 34 arow,unic,arow,int
$Funx{'arg_types'}{'34'} = "arow,unic,arow,*int";
$Funx{'Dynana'}{arg_class} = 34;
$Funx{'Dynana'}{menutext} = "Dynana(A,B,ord)".$DISTSI; 
$Funx{'Inana'}{arg_class} = 34;
$Funx{'Inana'}{menutext} = "Inana(A,B,ord)".$DISTSI; 
$Funx{'Randcond'}{arg_class} = 34;
$Funx{'Randcond'}{menutext} = "Randcond(n,ord)".$DISTSI; 
$Funx{'Smetana'}{arg_class} = 34;
$Funx{'Smetana'}{menutext} = "Smetana(A)".$DISTSI; 

$Funx{'arg_types'}{'menucom1'} = $DISTSI." = distinct signs only"; 
$Funx{'arg_types'}{'menucom2'} = $FUNOUT." = already an output"; 


=head2 Function Type Classes


	0	*int,*int,*int
	1	serial,octs
	11	serial,octs,musbas,musbas
	12	serial,octs,serial,sign,octs
	2	unic
	21	unic,octs,unic,octs,arow
	22	unic,octs,unic,sign,octs,arow
	3	arow
	31	arow,octs
	32	arow,arow,int
	33	arow,arow,octs
	34	arow,unic,arow,int

=head2 Regular expressions

We encounter some problems with regex types in tk valid_entry() that require to treat them in complementary form.  

if ($entry =~ /$Csgrouper::Types::REGEX{not_digit}/): works

but if ($entry =~ /$Csgrouper::Types::REGEX{digit}/): doesn't..

nor: if ($entry !~ /$Csgrouper::Types::REGEX{digit}/), with $REGEX{digit}	= qr/[0-9]+/ and $REGEX{not_digit} = qr/[^0-9]+/ 
(inner parentheses do not change anything).

Here positive regexes are complete sequences, while complementary regexes are character-scoped. The complementary version dedicated to character validation, cannot provide a full validation for the constructed sequence:

	$REGEX{'alnum'}							= qr/[0-9_A-Za-z]+/o;
	$REGEX{'non_alnum'}					= qr/[^0-9_A-Za-z]+/o;
	$REGEX{'digicom'}						= qr/[0-9:,.-]+/o;
	$REGEX{'non_digicom'}				= qr/[^0-9:,.-]+/o; 
	$REGEX{'digit'}							= qr/^([0-9]+)$/o;
	$REGEX{'non_digit'}					= qr/[^0-9]+/o;
	$REGEX{'float'}							= qr/^(([+\-]?\d+[\.]?\d*)|([+\-]?\d*[\.]?\d+))$/o;
	$REGEX{'non_float'}					= qr/[^0-9\.\-\+]+/o;
	$REGEX{'inst'}							= qr/^(i[0-9]+)$/o;
	$REGEX{'non_inst'}					= qr/[^0-9i]+/o;
	$REGEX{'plusminus'}					= qr/[+-]+/o;
	$REGEX{'non_plusminus'}			= qr/[^+-]+/o; 
	$REGEX{'plusalnumin'}			  = qr/[0-9_A-Za-z +-]+/o; ## alnum + plus + minus.
	$REGEX{'non_plusalnumin'}		= qr/[^0-9_A-Za-z +-]+/o; 
	$REGEX{'spalnumin'}					= qr/[0-9_A-Za-z -]+/o; ## alnum + space + minus.
	$REGEX{'non_spalnumin'}			= qr/[^0-9_A-Za-z -]+/o; 
	$REGEX{'subset'}						= qr/[0-9,;]+/o; ## digit + coma + semicolon.
	$REGEX{'non_subset'}				= qr/[^0-9,;]+/o; 
	$REGEX{'text'}							= qr/[0-9_A-Za-z ,;:.+-]+/o;  ## alnum + space + dot + coma + semicolon + colon + minus + plus.
	$REGEX{'non_text'}					= qr/[^0-9_A-Za-z ,;:.+-]+/o; 
	$REGEX{'param'}							= qr/^([0-9 =A-Z]+)$/o; ## For Randcond params.
	$REGEX{'non_param'}					= qr/[^0-9 =A-Z]+/o;
	$REGEX{'xphonic'}						= qr/^([0-9ABCDEFGHIJKLMN]+)$/o;
	$REGEX{'non_xphonic'}				= qr/[^0-9ABCDEFGHIJKLMN]+/o;

=cut

our 	%REGEX; 
	$REGEX{'alnum'}							= qr/[0-9_A-Za-z]+/o;
	$REGEX{'non_alnum'}					= qr/[^0-9_A-Za-z]+/o;
	$REGEX{'digicom'}						= qr/[0-9§:#,.-]+/o;
	$REGEX{'non_digicom'}				= qr/[^0-9§:#,.-]+/o; 
	$REGEX{'digicominst'}						= qr/[0-9i§:#,.-]+/o;
	$REGEX{'non_digicominst'}				= qr/[^0-9i§:#,.-]+/o; 
	$REGEX{'digit'}							= qr/^([0-9]+)$/o;
	$REGEX{'non_digit'}					= qr/[^0-9]+/o;
	$REGEX{'float'}							= qr/^(([+\-]?\d+[\.]?\d*)|([+\-]?\d*[\.]?\d+))$/o;
	$REGEX{'non_float'}					= qr/[^0-9\.\-\+]+/o;
	$REGEX{'inst'}							= qr/^(i[0-9]+)$/o;
	$REGEX{'non_inst'}					= qr/[^0-9i]+/o;
	$REGEX{'plusminus'}					= qr/[+-]+/o;
	$REGEX{'non_plusminus'}			= qr/[^+-]+/o; 
	$REGEX{'plusalnumin'}			  = qr/[0-9_A-Za-z +-]+/o; ## alnum + plus + minus.
	$REGEX{'non_plusalnumin'}		= qr/[^0-9_A-Za-z +-]+/o; 
	$REGEX{'spalnumin'}					= qr/[0-9_A-Za-z -]+/o; ## alnum + space + minus.
	$REGEX{'non_spalnumin'}			= qr/[^0-9_A-Za-z -]+/o; 
	$REGEX{'subset'}						= qr/[0-9,;]+/o; ## digit + coma + semicolon.
	$REGEX{'non_subset'}				= qr/[^0-9,;]+/o; 
	$REGEX{'text'}							= qr/[0-9_A-Za-z =)(#,;:.+-]+/o;  ## alnum + space + dot + coma + semicolon + colon + minus + plus.
	$REGEX{'non_text'}					= qr/[^0-9_A-Za-z =)(#,;:.+-]+/o; 
	$REGEX{'param'}							= qr/^([0-9 =A-Z]+)$/o; ## For Randcond params.
	$REGEX{'non_param'}					= qr/[^0-9 =A-Z]+/o;
	$REGEX{'xphonic'}						= qr/^([0-9ABCDEFGHIJKLMN]+)$/o;
	$REGEX{'non_xphonic'}				= qr/[^0-9ABCDEFGHIJKLMN]+/o;
	
=head1 Subroutines Section

=head2 Public Subroutines

The following subs correspond to types.

=over 

=cut

subtype 'Csgrouper::Types::arow'
  => as Str
  => where { &is_arow($_) } 
  => message {  &arow_error($_) }; 

=item * is_arow($self)
=cut

sub is_arow {
  my $s = shift;
  return 0 if (not is_serial($s)); ## A must.
  my $str = "";
  foreach (split(//,$s)) { 
  	return 0 if ($str =~ /$_/); 
  	$str .= $_ ;
  }
  return 1;
} ## END Csgrouper::Types::is_arow().

sub arow_error {
	my $p = shift;
	return "$p is not a schoenbergian row." if ($p =~ /.+/);
	return "the schoenbergian row is not defined.";
} ## END Csgrouper::Types::arow_error().

## ###
subtype 'Csgrouper::Types::fun'
  => as Str
  => where { is_fun($_) } 
  => message { &fun_error($_) }; 

=item * is_fun($self)
=cut

sub is_fun {
  my $s = shift;
	my $test = 0;
	foreach (@Funcs) {$test = 1 if ($_ =~ /^($s)$/) }
  return $test;
} ## END Csgrouper::Types::is_fun().

sub fun_error {
	my $p = shift;
	return "$p is not a Csgrouper function." if ($p =~ /.+/);
	return "the function is not defined.";
} ## END Csgrouper::Types::fun_error().

## ###
subtype 'Csgrouper::Types::ins'
  => as Str
  => where { &is_inst($_) } 
  => message { &inst_error($_) }; 

=item * is_inst($self)
=cut

sub is_inst { ## This leaves room for inst params:
  my $s = shift; my $pref = "i"; my $test = 1;
	my $suf = $s; $suf =~ s/^(i)(\d+),?.*$/$2/; ## e.g. "i23,p5=f10,p6=0.5"
  if ($s !~ /^(i)(\d+),?.*$/) { $test = 0 }
	elsif ($suf !~ /^(\d+)$/) { $test = 0 }
	elsif ($suf > $Csgrouper::Types::MAXOBJ || $suf < 1) { $test = 0 }
  return $test;
} ## END Csgrouper::Types::is_inst().

sub inst_error {
	my $p = shift;
	return "$p is not a Csound instrument name." if ($p =~ /.+/);
	return "the instrument is not defined.";
} ## END Csgrouper::Types::inst_error().

## ###
subtype 'Csgrouper::Types::musbas'
  => as Str
  => where { &is_musbas($_) } 
  => message { &musbas_error($_) }; 

=item * is_musbas($self)
=cut

sub is_musbas {
  my $s = shift; my $test = 0;
	$test = 1 if ($s == int($s) && $s > 1 && $s <= $MAXBAS);
  return $test;
} ## END Csgrouper::Types::is_musbas().

sub musbas_error {
	my $p = shift;
	return "$p is not a known musical base.";
} ## END Csgrouper::Types::musbas_error().

## ###
subtype 'Csgrouper::Types::musica'
  => as Str
  => where { &is_musica($_) } 
  => message { &musica_error($_) }; 

=item * is_musica($self)
=cut

sub is_musica {
  my $s = shift; my $test = 0;
	$test = 1 if ($s !~ /[^0-9ABCDEFGHIJKLMN]+/ && $s =~ /.+/);
  return $test;
} ## END Csgrouper::Types::is_musica().

sub musica_error {
	my $p = shift;
	return  "$p is not a musical note.";
} ## END Csgrouper::Types::musica_error().


## ###
subtype 'Csgrouper::Types::musind'
  => as Int
  => where { $_ > -1 && $_ < $MAXBAS } # No empty string allowed. 
  => message { &musind_error($_) }; 

=item * is_musind($self)
=cut

sub is_musind {
  my $s = shift; my $test = 0;
	$test = 1 if ( $s == int($s) && $s > -1 && $s < $MAXBAS );
  return $test;
} ## END Csgrouper::Types::is_musind().

sub musind_error {
	my $p = shift;
	return "$p is not a known musical index." if ($p =~ /.+/);
	return "the musical index is not defined.";
} ## END Csgrouper::Types::musind_error().

## ###
subtype 'Csgrouper::Types::num'
  => as Str
  => where { is_num($_) } 
  => message { &num_error($_) }; 
  
=item * is_num($self)
=cut

sub is_num {
  my $s = shift;
  return 1 if ($s =~ /^([\+\-]?\d*\.?\d*)$/);  ## allows "." as well as "+" and ".01" and "0.1".
  return 0;
} ## END Csgrouper::Types::is_num().

sub num_error {
	my $p = shift;
	return "$p is not a Csgrouper num." if ($p =~ /.+/);
	return "the number is not defined.";
} ## END Csgrouper::Types::num_error().


## ###
subtype 'Csgrouper::Types::posInt',
	as 'Int',
	where { &is_posInt($_) },
	message { &posInt_error($_) };

=item * is_posInt($self)
=cut

sub is_posInt {
  my $s = shift;
  return 1 if (($s >= 0) && !($s =~ /[^0-9]+/));
  return 0;
} ## END Csgrouper::Types::is_posInt().

sub posInt_error {
	my $p = shift;
	return "$p is not a Csgrouper posInt." if ($p =~ /.+/);
	return "the posInt is not defined.";
} ## END Csgrouper::Types::posInt_error().

## ###
subtype 'Csgrouper::Types::serial'
  => as Str
  => where { &is_serial($_) } 
  => message {  &serial_error($_) }; 

=item * is_serial($self)
=cut

sub is_serial {
  my $s = shift;
  my @s = split //,$s;
  my $l = length($s);
  my $test = 1;
  return 0 if ($l < 2); # No unary series.
  foreach (@s) { 
  	my $t = &Csgrouper::Dodecad($_); 
  	$test = 0 if ($t >= $l || $t < 0 || $Csgrouper::CSG{'char_set'} !~ /$_/); 
  }
  return $test;
} ## END Csgrouper::Types::is_serial().

sub serial_error {
	my $p = shift;
	return "$p is not a Csgrouper series." if ($p =~ /.+/);
	return "the series is not defined.";
} ## END Csgrouper::Types::serial_error().

## ###
subtype 'Csgrouper::Types::sets'
  => as Str
  => where { &is_set($_) } 
  => message { &set_error($_) }; ## In case of failure.
  
=item * is_set($self)
=cut

sub is_set {
  my $s = shift;
	return 1 if ($s !~ /[^0-9\-\,]+/);
	return 0;
} ## END Csgrouper::Types::is_set().

sub set_error {
	my $p = shift;
	return "$p is not a Csgrouper set." if ($p =~ /.+/);
	return "the set is not defined.";
} ## END Csgrouper::Types::set_error().

## ###
subtype 'Csgrouper::Types::sid'
  => as Str
  => where { &is_sid($_) } 
  => message {  &sid_error($_) }; ## In case of failure.

=item * is_sid($self)
=cut

sub is_sid {
  my $s = shift;
	return 1 if ($s == int($s) && $s >= 0 && $s < $MAXOBJ);
	return 0;
} ## END Csgrouper::Types::is_sid().

sub sid_error {
	my $p = shift;
	return "$p is not a Csgrouper series ID." if ($p =~ /.+/);
	return "the series ID is not defined.";
} ## END Csgrouper::Types::sid_error().

## ###
subtype 'Csgrouper::Types::tkrow'
  => as Str
  => where { &is_tk_row($_) } 
  => message {  &tkrow_error($_)  }; ## In case of failure.

=item * is_tk_row($self)
=cut

sub is_tk_row {
  my $s = shift;
  my $pref = "Tkrow_"; my $test = 1;
	my $suf = $s; $suf =~ s/^(Tkrow_)(\d+)$/$2/;
  if ($s !~ /^(Tkrow_)(\d+)$/) { $test = 0 }
	elsif ($suf !~ /^(\d+)$/) { $test = 0 }
	elsif ($suf > $Csgrouper::Types::MAXOBJ || $suf < 0) { $test = 0 }
  return $test;
} ## END Csgrouper::Types::is_tk_row().

sub tkrow_error {
	my $p = shift;
	return "$p is not a Csgrouper Tk row." if ($p =~ /.+/);
	return "the Tk row is not defined.";
} ## END Csgrouper::Types::tkrow_error().

## ### WARNING: Two arguments:
subtype 'Csgrouper::Types::unic'
  => as Str
  => where { &is_unic(@_) } 
  => message {  &unic_error(@_) }; 

=item * is_unic($self) : Almost like serial but checks corresponding base.
=cut

sub is_unic { ## 
  my ($s,$base) = @_;
  return 0 if (not is_serial($s)); ## A must.
  return 0 if (length($s) != $base); 
  return 1;
} ## END Csgrouper::Types::is_unic().

sub unic_error {
	my $p = shift;
	return "$p is not a Csgrouper unic series." if ($p =~ /.+/);
	return "the series is not defined.";
} ## END Csgrouper::Types::unic_error().

__PACKAGE__->meta->make_immutable; 
no Moose; 

1;
__DATA__

=back

=head1 Data Section

	
