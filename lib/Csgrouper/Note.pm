###############################################################################
## ### FILE INFO: Note.pm.
###############################################################################
## 110831.
## A Note class for Csgrouper.
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

=head1 Manual for Note.pm

=cut

## ###
package Csgrouper::Note; 
use Modern::Perl;
use lib ("~/Csgrouper/lib");
use Moose;
use Moose::Util::TypeConstraints;
use Csgrouper::Types;


=head1 Attributes Section 

The standard params:

Indice of this note within its sequence is object name within its hash.

Here many attributes are redundant as their information is already present in the correspondant series object - but these repetitions are useful for note treatment.

As we are creating the object naked, the only required attribute is the parent object:

Everything else will be done by BUILD.

=cut

has 'paro'	=> (isa => 'Object', is => 'ro', required => 1); ## A way to refer to a parent object without being an extension of it.
has 'ready'	=> (isa => 'Bool', 		is => 'ro', required => 0, default => 0,writer => 'set_ready');

## Indices:
## Indice of this note within its series:
has 'indi'	=> (isa => 'Csgrouper::Types::musind', is => 'ro', required => 1); 
## Indice of this note within its tune:
has 'gind'	=> (isa => 'Csgrouper::Types::posInt', is => 'ro', required => 1); 
## Serial index (indice of this series within its tune):
has 'sind'	=> (isa => 'Csgrouper::Types::posInt', is => 'ro', required => 1); 
## Serial type (a row or not):
# has 'type'	=> (isa => 'Bool', is => 'ro', required => 0, writer => 'set_type'); ## Serial index.
has 'csph'	=> (isa => 'Ref', is => 'rw', required => 0); ## Csd params.

## Serial components:
has 'val'	=> (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0);
has 'inv'	=> (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0);
has 'rev'	=> (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0);
has 'opp'	=> (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0);
has 'voc'	=> (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0);
has 'ioc'	=> (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0);
has 'roc'	=> (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0);
has 'ooc'	=> (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0);

## Comparative properties:
has 'scmp0' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); ## self (could be random)
has 'scmp1' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); ## notindex
has 'scmp2' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); ## indexi
has 'scmp3' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); ## indexnote
has 'icmp0' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); 
has 'icmp1' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); 
has 'icmp2' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); 
has 'icmp3' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); 
has 'rcmp0' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); 
has 'rcmp1' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); 
has 'rcmp2' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); 
has 'rcmp3' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); 
has 'ocmp0' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); 
has 'ocmp1' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); 
has 'ocmp2' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); 
has 'ocmp3' => (isa => 'Csgrouper::Types::musica', is => 'rw', required => 0); 

## (see the writers for eqcmp* below).
has 'idcmp0' => (isa => 'Bool', is => 'rw', default => 0, required => 0); ## id: For comparison of notes and indexes within the sequence itself:
has 'idcmp1' => (isa => 'Bool', is => 'rw', default => 0, required => 0); ## (notindex)
has 'idcmp2' => (isa => 'Bool', is => 'rw', default => 0, required => 0); ## (indexi)
has 'idcmp3' => (isa => 'Bool', is => 'rw', default => 0, required => 0); ## (indexnote)
has 'eqcmp0' => (isa => 'Str', is => 'rw', default => $Csgrouper::OBJSEP, required => 0); ## eq: For comparison of notes between sequences.
has 'eqcmp1' => (isa => 'Str', is => 'rw', default => $Csgrouper::OBJSEP, required => 0); ## (notindex)
has 'eqcmp2' => (isa => 'Str', is => 'rw', default => $Csgrouper::OBJSEP, required => 0); ## (indexi)
has 'eqcmp3' => (isa => 'Str', is => 'rw', default => $Csgrouper::OBJSEP, required => 0); ## (indexnote)

## Standard and time components:
has 'ins'	=> (isa => 'Str', is => 'rw', required => 0, default => "i1");
has 'sta'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => '+');
has 'dur'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 1);
## Envelope components:
has 'att'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0.1);
has 'gl1'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0);
has 'hd1'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0);
has 'gl2'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0);
has 'hd2'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0);
has 'rel'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0.1);
has 'pan'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 1);
has 'pa1'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0.5);
has 'pa2'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0.5);
has 'del'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0);
has 'cro'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 1); ## Crossfade
has 'ac1'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 1); ## Amplitude correction factor 1
has 'ac2'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 1); 
## Frequency components:
has 'amp'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 60);
has 'fq1'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 440); ## Start frequency
has 'fq2'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 440); ## Mid frequency
has 'fq3'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 440); ## Last frequency
has 'pc1'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 8.09); ## Cpspch representation
has 'pc2'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 8.09);
has 'pc3'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 8.09);
has 'mi1'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 69); ## Midi equivalent
has 'mi2'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 69); 
has 'mi3'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 69);
has 'car'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0.01); ## FM Carry
has 'mod'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0.01); ## FM modulation factor
has 'hm1'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0); ## Harmonics 1 
has 'hm2'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 10); ## Harmonics 2
## Effects components:
has 'rvn'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 1); ## Reverb number
has 'rvs'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0.5); ## Reverb send ratio
has 'fx1'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0); 
has 'fx2'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0); 
has 'fx3'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0); 
has 'fx4'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => 0); 
## F-tables:
has 'ft1'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 1, default => $Csgrouper::CSG{'ft_base'}); 
has 'ft2'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => $Csgrouper::CSG{'ft_base'});  
has 'ft3'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => $Csgrouper::CSG{'ft_base'});  
has 'ft4'	=> (isa => 'Csgrouper::Types::num', is => 'rw', required => 0, default => $Csgrouper::CSG{'ft_base'});  
## xfun states:
has 'sil'	=> (isa => 'Csgrouper::Types::num',is => 'rw', required => 1, default => 0);
## yfun states:
has 'ryc'	=> (isa => 'Csgrouper::Types::num',is => 'rw', required => 1, default => 0);
has 'ens'	=> (isa => 'Csgrouper::Types::num',is => 'rw', required => 1, default => 0);

=head1 Subroutines Section

=head2 Private Subroutines

=over 

=item * BUILD($self) : Internal Moose method called after the object has been created.
=cut

## Build subs:
sub BUILD { ## 
  my ($self) = @_;  
 	# my $subname = 'Note::BUILD';
  # &Csgrouper::Debug($subname, "@_");
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
 	# &Csgrouper::Debug($subname, $self->gind);
 	## A place to override defaults and param values with some post-computation.
	# $self->sta();
	# $self->dur();
	# ## Envelope components:
	# $self->att();
	# $self->gl1();
	# $self->hd1();
	# $self->gl2();
	# $self->hd2();
	# $self->rel();
	# $self->pan();
	# $self->pa1();
	# $self->pa2();
	# $self->del(); ## delay
	# $self->cro(); ## Crossfade
	# $self->ac1(); ## Amplitude correction factor 1
	# $self->ac2(); 
	# ## Frequency components:
	# $self->amp();
	# $self->fq1(); ## Start frequency
	# $self->fq2(); ## Mid frequency
	# $self->fq3(); ## Last frequency
	# $self->pc1(); ## Cpspch representation
	# $self->pc2();
	# $self->pc3();
	# $self->mi1(); ## Midi equivalent
	# $self->mi2(); 
	# $self->mi3();
	# $self->car(); ## FM Carry
	# $self->mod(); ## FM modulation factor
	# $self->hm1(); ## Harmonics 1 
	# $self->hm2(); ## Harmonics 2
	# ## Effects components:
	# $self->rvn(); ## Reverb number
	# $self->rvs(); ## Reverb send ratio
	# $self->fx1(); 
	# $self->fx2(); 
	# $self->fx3(); 
	# $self->fx4(); 
	# ## F-tables:
	# $self->ft1(); 
	# $self->ft2(); 
	# $self->ft3(); 
	# $self->ft4(); 
	&freqset($self);
	## Intrument params to be defined at instrument processing:
	my %csph;
	for (my $i = 1; $i < $Csgrouper::Types::MAXPAR; $i++) { $csph{"$i"} = 0} 
	$self->csph(\%csph);
} ## END BUILD().

=item * freqset($note,$oct) : sets 3 different frequency formats.
=cut

sub freqset {
	my ($self) = @_;
	## Init:
	my $subname = 'Note::freqset';
	my $oldebflag = $Csgrouper::DEBFLAG; 
	# $Csgrouper::DEBFLAG = 1;
  # &Csgrouper::Debug($subname, "@_");
	&Csgrouper::Error($subname,"Private method called.",1) 
    unless (caller)[0]->isa( ref($self) );
	my $octs = &Csgrouper::Dodecad($self->voc,$subname); $octs//=  8;
	my $note = &Csgrouper::Dodecad($self->val,$subname);
	## The main switch:
	my $ncps = &Csgrouper::Elacs($note,$octs,$self->paro->paro->base);
	my $midi = &Csgrouper::Midi($ncps);
	my ($ncpspch, $ncpsoct) = &Csgrouper::Scale($ncps,12);
	$ncpspch = "0$ncpspch" if (length($ncpspch)==1);
	$ncpspch = "$ncpsoct.$ncpspch";
	## voc = cpspch oct $octs
	$self->fq1($ncps); $self->fq2($ncps);$self->fq3($ncps);
	$self->mi1($midi); $self->mi2($midi); $self->mi3($midi); 
	$self->pc1($ncpspch); $self->pc2($ncpspch); $self->pc3($ncpspch); 
	$Csgrouper::DEBFLAG =	$oldebflag;
	return 1;
} ## END freqset().

=item * Num() : sorts numerically.
=cut

sub Num { $a <=> $b } ## END Num()


=item * set_eqcmp*() : a writer for eqcmp* properties.
=cut
sub set_eqcmp0 {
	my ($self,$val) = @_;
	my $osep = $Csgrouper::OBJSEP;
	$self->eqcmp0($self->eqcmp0.$val.$osep) unless ($self->eqcmp0 =~ /$val$osep/);
}

sub set_eqcmp1 {
	my ($self,$val) = @_;
	my $osep = $Csgrouper::OBJSEP;
	$self->eqcmp1($self->eqcmp1.$val.$osep) unless ($self->eqcmp1 =~ /$val$osep/);
}

sub set_eqcmp2 {
	my ($self,$val) = @_;
	my $osep = $Csgrouper::OBJSEP;
	$self->eqcmp2($self->eqcmp2.$val.$osep) unless ($self->eqcmp2 =~ /$val$osep/);
}

sub set_eqcmp3 {
	my ($self,$val) = @_;
	my $osep = $Csgrouper::OBJSEP;
	$self->eqcmp3($self->eqcmp3.$val.$osep) unless ($self->eqcmp3 =~ /$val$osep/);
}
=back

=head2 Public Subroutines

=over

=item * Shownote($self) : main object display.
=cut

sub Shownote {
	my ($self) = @_;
	## Init:
	my $subname = 'Note::Shownote';
  { no warnings; &Csgrouper::says($subname, "@_"); }
	my $oldebflag = $Csgrouper::DEBFLAG; 
	# $Csgrouper::DEBFLAG = 1;
	&Csgrouper::says($subname,"Main object:");
	for my $key (sort keys %{$self}){
		say("$key \t\t=> ".$self->{$key});
	}
	&Csgrouper::says($subname,"Csound hash:");
	for my $key (sort Num keys %{$self->csph}){
		say("$key \t\t=> ".${$self->csph}{$key});
	}
	$Csgrouper::DEBFLAG =	$oldebflag;
	return 1;
} ## END Shownote().


__PACKAGE__->meta->make_immutable; 
no Moose; 

1;
__DATA__

=back

=head1 Data Section

=head2 Command line

Acces to a particular note is done via a call like:

  print $CsgObj->sequences->{Seq_1}->tree->notes->{3}->val; ## prints "2"
	
	
=cut
