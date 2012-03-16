###############################################################################
## ### FILE INFO:
###############################################################################
## 110831.
## A Series class for Csgrouper.
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

=head1 Manual for Series.pm

=head2 The Series construction scheme

First see some command lines:

	print $CsgObj->sequences->{Seq_1}->tree->tune; ## prints "0123456789AB"

=cut

## ###
package Csgrouper::Series; 
use Modern::Perl;
use lib (	"~/Csgrouper/lib");
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;
use Csgrouper::Types;
use Csgrouper::Note;

=head1 Attributes Section 

The series is readonly, but we keep a writer to be able to normalize it in some cases:  Internal attributes like tuni, can safely be set to Str which allows the empty str.

=cut

has 'paro'	=> (isa => 'Object', is => 'ro', required => 1); ## A way to refer to a parent object without being an extension of it.
has 'tune'	=> (isa => 'Csgrouper::Types::serial', is => 'ro', required => 1, writer => 'set_tune');
has 'octs'	=> (isa => 'Csgrouper::Types::musica', is => 'ro', required => 0, writer => 'set_octs');
has 'orig'	=> (isa => 'Str', is => 'ro', required => 1, default => "");

## RW attributes:
## axis is a serial index used by Inverse mainly.
has 'axis' => (isa => 'Csgrouper::Types::musind', is => 'rw', required => 0, default => 0); 
## unic is a wish-property to indicate wether to choose the whole sequence or
## limit ourselves to the first series. In border-line cases it makes the 
## normalization process augment or diminish the tune length at build time.
has 'unic' => (isa => 'Bool', is => 'rw', required => 0, default => 0);
has 'size' => (isa => 'Csgrouper::Types::posInt', is => 'ro', required => 0, writer => 'set_size');
has 'sers' => (isa => 'Csgrouper::Types::posInt', is => 'ro', required => 0, writer => 'set_sers');
has 'notes'=> (isa => 'HashRef', is => 'ro', required => 1, default => sub {{}}, writer => 'set_notes');
## Number of series in the tune:
has 'ready'	=> (isa => 'Bool', 		is => 'ro', required => 0, default => 0,writer => 'set_ready');

=head1 Subroutines Section

=head2 Private Subroutines

some additionnal properties:

=over 

=item * is_arow($self)
=cut

sub is_arow {
  my ($self) = @_;
 	my $subname = 'Series::is_arow';
  # { no warnings; &Csgrouper::says($subname, "@_"); }
	&Csgrouper::Error($subname,"Private method called.",1) 
    unless (caller)[0]->isa( ref($self) );
  my $str = ""; 
  foreach (split //,$self->tune) { 
  	return 0 if ($str =~ /$_/); 
  	$str .= $_ ;
  }
  return 1;
} ## END Series::is_arow();

=item * is_unic($self)
=cut

sub is_unic { ## The real state of uniqueness (not a wish like 'unic' attribute).
  my ($self) = @_;
 	my $subname = 'Series::is_unic';
  # { no warnings; &Csgrouper::says($subname, "@_"); }
	&Csgrouper::Error($subname,"Private method called.",1) 
    unless (caller)[0]->isa( ref($self) );
  return 0 if (length($self->tune) != $self->paro->base);
  return 1;
} ## END Series::is_unic();


## Build subs:
sub BUILD { ## Internal Moose method called after the object has been created.
  my ($self) = @_;  
 	my $subname = 'Series::BUILD';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $notes = $self->tune; $notes =~ s/\ //g; $self->set_tune($notes); 
  my $octs = $self->octs; $octs =~ s/\ //g; $self->set_octs($octs); 
  my $tlen = length($self->tune);
  my $olen = length($self->octs);
  my $base = $self->paro->base; 
  my @notes = split //,$self->tune;
  my ($newocts, $newtune);
  my $notestr = ""; my $rowtest = 1;
  ## Base takes a fatal precedence over each note:
  foreach (@notes) { 	&Csgrouper::Error($subname, "not a proper base for @notes : $base\n") if (&Csgrouper::Dodecad($_,$subname) >= $base) }
  ## Here we are going to correct the data when needed:
  { no warnings; 
  	&Csgrouper::Describe($subname, "ori: ".$self->orig." tune: ");
		&Csgrouper::Describe($subname, "octs: ".$self->octs);
		&Csgrouper::Describe($subname, "unic: ".$self->unic);
		&Csgrouper::Describe($subname, "base: ".$self->paro->base);
	}
  if ($self->is_unic) { 
    if ($self->unic ne 1) { &Csgrouper::Describe($subname, $self->tune." unic changed to 1.") } ; 
    $self->unic(1); 
  } ## No choice. The original params were not valid nor fatal.
  ## Series length/base mismatches entail modifications only:
  if ($tlen < $base) { ## Augment series size:
  	$newtune = $self->tune;
  	for (my $i = $tlen; $i < $base; $i++){		
  		 $newtune .= "0"; ## Neutral base tone.
  	}
   	&Csgrouper::Describe($subname, $self->tune.": augmented to $newtune, unic set to 1.");
  	$self->set_tune($newtune);
  	$self->unic(1); ## Again: no choice.
  	$tlen = $base;
 }
  elsif (($tlen > $base) && ($tlen % $base != 0)) { 
  	## Verify that series size % base == 0 otherwise augment its size:
  	if ($self->unic == 0) {
  	  $newtune = $self->tune;
  	  while ($tlen % $base != 0){		
    		$newtune .= "0"; ## Neutral base tone.
    		$tlen++;
  	  }
  	  &Csgrouper::Describe($subname, $self->tune.": augmented to $newtune.");
  	  $self->set_tune($newtune);
  	} ## END unic=0.
  	## Attribute 'unic' has consequences on the normalization process unless 
  	## tune length is valid. This is why we can't rely on this attribute to 
  	## determinate the length of our tune: a series object can contain several 
  	## series and have the unic attribute set on, we'll then splice it.
  	else { ## Reducing the tune to series 1: as unic=1 with more than 1 series:
  	  my @newtune = split //, $self->tune;
  	  splice @newtune, $base;
  	  $newtune = join('',@newtune);
  	  &Csgrouper::Describe($subname, $self->tune.": augmented to $newtune.");
  	  $self->set_tune($newtune);
  	  $tlen = $base;
  	}
  }
  if ($tlen > $olen) { ## Augment octave size:
  	$newocts = $self->octs;
  	for (my $i = $olen; $i < $tlen; $i++){		
  		 $newocts .= $Csgrouper::CSG{'oct_base'};
  	}
  	&Csgrouper::Describe($subname, $self->octs.": augmented to $newocts.");
  	$self->set_octs($newocts);
  }
  elsif ($tlen < $olen) { ## Diminish it:
  	my @octs = split //,$self->octs;
  	splice (@octs,$tlen);
  	foreach (@octs) { $newocts .= $_ };
  	&Csgrouper::Describe($subname, $self->octs.": reduced to $newocts.");
  	$self->set_octs($newocts);
  }
  { no warnings; 
  	&Csgrouper::Describe($subname, "new: ".$self->orig." tune: ");
		&Csgrouper::Describe($subname, "octs: ".$self->octs);
		&Csgrouper::Describe($subname, "unic: ".$self->unic);
  }
  ## Now we can construct the real object properties:
  ## reverse, inverse, opposite, etc. are made FOR EACH of the serial components.
  { no strict 'refs';
		my @monoseries = $self->tune =~ m/.{$base}/gi;
		$self->set_sers(scalar(@monoseries));
		my @monoocts = $self->octs =~ m/.{$base}/gi;
		## In the future some of these serial elements could be suppressed in favour of
		## the note hash:
		my (@scmp0,@scmp1,@scmp2,@scmp3,@icmp0,@icmp1,@icmp2,@icmp3,@rcmp0,@rcmp1,@rcmp2,@rcmp3,@ocmp0,@ocmp1,@ocmp2,@ocmp3);
		my (@tuni,@tunr,@tuno,@octi,@octr,@octo);
		## Comparison string are interface dependant though models are available in the main class.
		for(my $i = 0; $i < scalar(@monoseries); $i++) {
			{ no warnings; ## Some values aren't initialised:
				my $series = $monoseries[$i];
				my $octs = $monoocts[$i];
				my ($invser,$invocts) = &invert($self,$series,$octs);
				push (@tuni,split(//,$invser));
				push (@octi,split(//,$invocts));
				my ($revser,$revocts) = &revert($self,$series,$octs);
				push (@tunr,split(//,$revser));
				push (@octr,split(//,$revocts));
				my ($oppser,$oppocts) = &revert($self,$invser,$invocts);
				push (@tuno,split(//,$oppser));
				push (@octo,split(//,$oppocts));
				my $fun;
				## A choice at interface level allows to change the comparison func:
				$fun = $Csgrouper::CSG{interface}."::Compstr".$Csgrouper::CSG{part_comptype_mw};
				push (@scmp0,split(//,&$fun($series)));
				push (@icmp0,split(//,&$fun($invser)));
				push (@rcmp0,split(//,&$fun($revser)));
				push (@ocmp0,split(//,&$fun($oppser)));
				$fun = $Csgrouper::CSG{interface}."::Compstr1";
				push (@scmp1,split(//,&$fun($series)));
				push (@icmp1,split(//,&$fun($invser)));
				push (@rcmp1,split(//,&$fun($revser)));
				push (@ocmp1,split(//,&$fun($oppser)));
				$fun = $Csgrouper::CSG{interface}."::Compstr2";
				push (@scmp2,split(//,&$fun($series)));
				push (@icmp2,split(//,&$fun($invser)));
				push (@rcmp2,split(//,&$fun($revser)));
				push (@ocmp2,split(//,&$fun($oppser)));
				$fun = $Csgrouper::CSG{interface}."::Compstr3";
				push (@scmp3,split(//,&$fun($series)));
				push (@icmp3,split(//,&$fun($invser)));
				push (@rcmp3,split(//,&$fun($revser)));
				push (@ocmp3,split(//,&$fun($oppser)));	
			}
		}
		my @tune = split //,$self->tune; ## Long arrays:
		my @octs = split //,$self->octs;
		&Csgrouper::Describe($subname, "cmp0: ".join('',@scmp0));
		&Csgrouper::Describe($subname, "cmp1: ".join('',@scmp1));
		&Csgrouper::Describe($subname, "cmp2: ".join('',@scmp2));
		&Csgrouper::Describe($subname, "cmp3: ".join('',@scmp3));
		
		$self->set_size(length($self->tune));
		my %noteh;  $self->set_notes(\%noteh);
		my $x = -1; my $serialindex = 0; 
		for (my $n = 0; $n < scalar(@tune); $n++){
			if ($x == $self->paro->base-1){
				$x = 0; $serialindex++;
			}
			else { $x++ }
			## The Note Object:
			$self->notes->{$n} = Csgrouper::Note->new(
				 paro => $self
				 ## Indices:
				,indi => $x
				,sind => $serialindex
				,gind => $n
				 ## Serial components:
				,val => $tune[$n]
				,inv => $tune[$n]
				,rev => $tunr[$n]
				,opp => $tuno[$n]
				,voc => $octs[$n]
				,ioc => $octi[$n]
				,roc => $octr[$n]
				,ooc => $octo[$n]
				## Comparative properties:
				,scmp0 => $scmp0[$n]
				,scmp1 => $scmp1[$n]
				,scmp2 => $scmp2[$n]
				,scmp3 => $scmp3[$n]
				,icmp0 => $icmp0[$n]
				,icmp1 => $icmp1[$n]
				,icmp2 => $icmp2[$n]
				,icmp3 => $icmp3[$n]
				,rcmp0 => $rcmp0[$n]
				,rcmp1 => $rcmp1[$n]
				,rcmp2 => $rcmp2[$n]
				,rcmp3 => $rcmp3[$n]
				,ocmp0 => $ocmp0[$n]
				,ocmp1 => $ocmp1[$n]
				,ocmp2 => $ocmp2[$n]
				,ocmp3 => $ocmp3[$n]
			);
		}
		&Csgrouper::Describe($subname, "tune: ".$self->tune);
		&Csgrouper::Describe($subname, "octs: ".$self->octs);
		&Csgrouper::Describe($subname, "len: ".length($self->tune));
		&Csgrouper::Describe($subname, "series: ".($serialindex+1));
  } ## END no strict refs.
  $self->set_ready(1);
  $Csgrouper::DEBFLAG = $oldebflag;
} ## END Series::BUILD().

=item * invert($self,$series,$octs) : a local strict version for dodecaphonic inverse.
=cut

sub invert { ## Private method. Requires monadic series.
  my ($self,$series,$octs) = @_;
  my $subname = "Series::invert";
  # { no warnings; &Csgrouper::says($subname, "@_"); }
	&Csgrouper::Error($subname,"Private method called.",1) 
    unless (caller)[0]->isa( ref($self) );
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my @row = split //,$series; 
  my @octs = split //,$octs; 
  my ($newseries, $newocts);
  my $axis = &Csgrouper::Dodecad($row[$self->axis],$subname); 
  for (my $n = 0; $n < scalar(@row); $n++){
		my $rown = &Csgrouper::Dodecad($row[$n],$subname);
		# An arithmetic definition for Inv: $res = $res.($axis-($rown-$axis))%($base+1);
		my $sign = '+'; my ($int, $thisnote, $thisoct, $waste);
		if ($rown > $axis) { ($int,$thisoct) = &Csgrouper::Notesum($rown,$axis,'-',$self->paro->base); $sign = '-' }
		if ($rown < $axis) { ($int,$thisoct) = &Csgrouper::Notesum($axis,$rown,'-',$self->paro->base); $sign = '+' }
		if ($rown == $axis) { $int = 0; $sign = '+' }
		($thisnote, $thisoct) = &Csgrouper::Notesum($axis,$int,$sign,$self->paro->base); ## thisoct is now 0, 1 or -1...
		## Base is always max for octaves. But we can't hear more than around base 13.
		($thisoct, $waste) = &Csgrouper::Notesum(&Csgrouper::Dodecad($octs[$n],$subname),$thisoct,'+',$Csgrouper::Types::MAXBAS,'o'); 
		&Csgrouper::Debug($subname, "n=$n int=$int sign=$sign new=$thisnote thisoct=$thisoct");
		$newseries .= &Csgrouper::Decadod($thisnote,$subname); $newocts .= &Csgrouper::Decadod($thisoct,$subname);
  }
  $Csgrouper::DEBFLAG = $oldebflag;
  return($newseries,$newocts); 
} ## END Series::invert().

=item * revert($self,$series,$octs) : a local strict version for dodecaphonic revert.
=cut

sub revert { ## Private method. Requires monadic series.
  my ($self,$series,$octs) = @_;
  my $subname = "Series::revert";
  { no warnings; &Csgrouper::says($subname, "@_"); }
	&Csgrouper::Error($subname,"Private method called.",1) 
    unless (caller)[0]->isa( ref($self) );
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $newseries = join('',(reverse(split(//,$series))));
  my $newocts = join('',(reverse(split(//,$octs))));
  $Csgrouper::DEBFLAG = $oldebflag;
  return($newseries,$newocts); 
} ## END Series::revert().


__PACKAGE__->meta->make_immutable; 
no Moose; 

1;
__DATA__

=back

=head1 Data Section

=head2

=cut

