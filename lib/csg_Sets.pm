###############################################################################
## ### FILE INFO: csg_Sets.pm.
###############################################################################
## 070930 - 110925.
## Encoding of this document: iso 8859-1
## This set of analytic functions is kept apart for csgrouper.pl.


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

package csg_Sets;
use Modern::Perl;
use DBI;
use DB_File;
use Fcntl;
use Csgrouper;

#########################################################################
### VARIABLES ###########################################################
#########################################################################

## Global variables beggin uppercase.
our (@OUT, @SUITE, @TID);
our (%DEG, %GAP, %INTER, %OMI, %TYP);
our $BIGINT = (2**64)-1;
our $INTEG = (2**32)-1;
our $MEDINT = (2**24)-1;
our $SMALINT = (2**16)-1;
our $TININT = (2**8)-1;
our $MODCNT = 0;
our $NML; ## 36 for S12. XXX TODO: Revise that.
our	($SQL, $STH, $TLOG);
our ($SDEG, $STR, $STYP);

our (@A1, @A2, @A3, @A4);
our ($S1, $S2, $S3, $S4);
our (%H1, %H2, %H3, %H4);

my $Charset 	= $Csgrouper::CSG{'char_set'}; 

#########################################################################
### Subroutines #########################################################
#########################################################################

### A: csgrouper.pl :

## ###
sub Cmd_line {
	my $cmd = shift;
	## use global @OUT:
	return (eval ($cmd));
}

### END csgrouper.pl 

#########################################################################
### under construction ##################################################
#########################################################################

#########################################################################
### END under construction ##############################################
#########################################################################

#########################################################################
### Permutational functions (old)########################################
#########################################################################

## The following functions are quick and local,
## but in base <= 10 only.


## Map Degree of a permutation:
sub mdeg {
    my ($perm,$mode) = @_;
    $mode = 2  if ($mode !~ /.+/);
    my $deg = &sdeg(&smap(&sopp($perm),$perm)); 
    return $deg if ($mode != 1);
    my @msuite = ();
    @msuite = &sdeg(&smap(&sopp($perm),$perm),2);
    my @per;   
    for (my $n = 0; $n < (@msuite); $n++) {
       push @per, &suma($msuite[$n],$perm);
    }   
    return @per;
} # END mdeg()


sub natural { ## The well ordered permutation and test:
	my @s = split //,shift;
  my $subname = "natural";
	@s = sort(@s); my $res;
	foreach (@s) {$res .= $_}
	die ("Wrong string.") if ($Charset !~ /$res/);
	return $res;
} ## END natural().

# ## intervals:
sub notesum {
	my  ($not,$inter,$sign,$base) = @_; # Note is expressed in base 10,
	$base //= 10; my @resu;
	die "Digital base only. $!\n" if ($base > 10 or $base < 0);
 	$resu[0] = ($not + "$sign$inter") ;
	$resu[1] = "0";
	if ($resu[0] < 0 ) { $resu[0] += $base ; $resu[1] = -1 } 
	if ($resu[0] >= $base) { $resu[0] -= $base ; $resu[1] = 1 } 
	return @resu;
} # END notesum()
# 


## Opposite Degree of a permutation:
sub oppdeg {
	my ($perm,$mode) = @_;
	$mode = 0  if ($mode !~ /.+/);
	my $ind = $perm;
	$perm = &sopp($perm,"","1");
	my $targ = $perm;
	my $deg = 1;
	my @per; splice @per; # A perl bug: sometimes a local array remains loaded.
	push @per, $perm;
	goto ODEGEND if ($ind =~ /$perm/);
	while (++$deg){
		$targ = &sopp($targ,"","1");
		push @per, $targ ;
		last if ($ind =~ /$targ/);
	}
	ODEGEND:
	return @per if ($mode == 1);
	return $deg;
} # END oppdeg()

sub partel { ## Elementary partition of a permutation:
	my ($perm,$mode) = @_;
  my $subname = "partel";
	my @perm = split //, $perm;
	my @ind = split //,$Charset;
	my @partel;
	$mode //= 1;
	for (my $n = 0; $n < (@perm); $n++) {
		my $U = "";
		my $j = $perm[$n];
		my $J = $perm[$n];
		next if ("@partel" =~ /$J/);
		if ($J =~ /$ind[$n]/){ push @partel,$J }
		else {
			while ($U !~ /$J/){
				$U .= $J;
				$J = $perm[$j];
				$j = $J;
			}
			push @partel,$U;
		}	
	}		
	print "$perm -> @partel\n" if ($mode == 2);
	return @partel;
} ## END partel().

sub perm { ## String permutation:
    my ($target,$agent) = @_; 
	die ("Not a valid permutation in base >= 10") if (length($target)>10);
	die ("Not a valid permutation in base >= 10") if (length($agent)>10);
    my $subname = "perm";
    my @targ = split //,$target;
    my @perm = split //,$agent; 
    my $res;
    for (my $i = 0; $i < (@perm); $i++){ $res .= $perm[$targ[$i]] }
    return $res;
} ## END perm().

## Which agent is required to obtain this perm?
sub permagent { 
	## This routine returns the permutation that is able to
	## produce $perm when permuting $targ. 
	## E.g.: (permagent("3021","2310") = "3012") =>  (perm("3021","3012") = "2310");
  my ($target,$perm) = @_;
  my @agent;
  my @target = split //,$target;
  my @perm = split //,$perm;
  for (my $n = 0; $n < scalar(@perm); $n++) { $agent[$target[$n]] = $perm[$n] }
  return join '',@agent;
}

## Permutation:
sub permute {
	my ($stref, $start, $pos) = @_;
	my @P = @{$stref};
	my $s = $P[$start];
	my $p = $P[$pos];
	$P[$start] = $p;
	$P[$pos] = $s;
  @{$stref} = @P; # This line, missing == order error!
	return @P;
}

sub powerp { ## Permutation of power n:
	my ($targ,$perm,$pow) = @_;
	my $subname = "powerp";
	die ("Not a valid permutation in base >= 10") if (length($perm)>10);
	die ("Not a valid permutation in base >= 10") if (length($targ)>10);
	my @perm = split //,$perm; 
	my $res = $targ;
  return &powerp($targ,$perm,(&sdeg($perm)+$pow)) if ($pow < 0);
  return &natural($targ) if ($pow == 0);
	for (my $n = 1; $n <= abs($pow); $n++){
			my @targ = split //,$res; $res = "";
			for (my $i = 0; $i < (@perm); $i++){ $res .= $perm[$targ[$i]] }
	}
	return $res;
} # END powerp()

## A more strict version of perma that I'd have to generalize.
sub recurse { ## Recursive permutations (bait):
	my ($ori, $sub, $level, $mode) = @_;
	my $subname = "recurse";
	my $t = natural($ori);
	die("Not a valid decimal permutation of distinct signs.\n") 
		if ( $Csgrouper::CSG{'char_set'} !~ /^($t)/);
	my 	@seq = split //,$t;
	my $lev = 0; my $len = scalar(@seq);
	my $cnt = 0;
	my $match = 0;
	if ($sub  =~ /^(stock)$/){ ##
		my $seq = natural($ori); ## Take the natural suite as a starting point.
		splice @SUITE; push @SUITE,$seq;
		say "recurse: $seq $len $sub $lev";
		$cnt++;
	}
	elsif ($sub =~ /test/){
		%TYP = ""; %DEG = "";  
		$SDEG = &sdeg($ori); $STYP = &styp($ori);
		if (!(exists($TYP{$STYP}))){ $TYP{$STYP} = scalar(@TID)+1;  push @TID, 1;  }
		print "$cnt\t$ori\t$STYP\t$TYP{$STYP}\n";
		goto RECUR;
	} 	
	elsif ($sub  =~ /indeg/){ # Check which series have got $STR into their degsuites
		$STR = $mode;
		@SUITE = &sdeg($ori,"2");
		if ("@SUITE" =~ /$STR/) {
			$match++;
			my $part = &partel($ori);
			print "$ori dsuite contains: $STR mtc: $match cnt: $cnt\tpart: $part\n"
		}
		goto RECUR;
	}
	elsif ($sub  =~ /^(permagent)$/){ ##
		$S1 = $ori; ## The tested perm.
		my $seq = natural($ori); ## Take the natural suite as a starting point.
		say "recurse: $seq $len $sub $lev";
		my $pa = &permagent($S1,$seq);
		my $verif = &perm($S1,$pa);
		say "perm($S1,$pa) = $verif (targ=$seq)";
		$cnt++;
	}
	elsif ($sub  =~ /^(rec1)$/){ ##
		my $seq = natural($ori); ## Take the natural suite as a starting point.
		say "recurse: $seq $len $sub $lev";
		$cnt++;
	}
	elsif ($sub  =~ /^(rec2)$/){ ##
		# my $seq = $ori; ## Take the natural suite as a starting point.
		my $seq = natural($ori); ## Take the natural suite as a starting point.
		say "recurse: $ori $len $sub $lev";
		$cnt++;
		@seq = split //,$seq;
	}
	&rec(\@seq, \$len, \$sub, $lev, \$cnt, \$match, \$mode);
	say "recurse results: $match";
} ## END recurse

sub rec { ## Recursive permutations (bait):
	my ( $aref, $lenref, $subref, $lev, $cntref, $matchref, $modref) = @_;
	my $subname = "rec";
	my @p1 = @{$aref}; 
	for (my $pos = $lev; $pos < $$lenref; $pos++) {
		my @p2 = permute(\@p1,$lev,$pos);
		my $str = join '', @p2;
		my $oldsub = $$subref;
		if (!($pos == $lev)) {
			$$cntref++;
			if ($$subref  =~ /^(stock)$/){ 
				push @SUITE,$str;
			}
			elsif ($$subref  =~ /test/){
				$STYP = &styp($str,"0");
				if (!(exists($TYP{$STYP}))){ $TYP{$STYP} = scalar(@TID)+1; push @TID, 1; }
				print "$$cntref\t$str\t$STYP\t$TYP{$STYP}\n";
				goto RECURS;
			}
			elsif ($$subref  =~ /^(permagent)$/){ ##
				my $pa = &permagent($S1,$str);
				my $verif = &perm($S1,$pa);
				say "perm($S1,$pa) = $verif (targ=$str)";
			}
			elsif ($$subref  =~ /indeg/){ # Check which series have got $STR into their degsuites
				@SUITE = &sdeg($str,"2");
				if ("@SUITE" =~ /$STR/) {
					$$matchref++;
					my $part = &Partel($str,"2");
					print "$str dsuite contains: $STR mtc: $$matchref cnt: $$cntref\tpart: $part\n"
				}
				goto RECURS;
			}
			elsif ($$subref  =~ /^(rec1)$/){ 
				say "$$cntref (1): $str" if ($$modref == 1);
				my $newstr = $str;
				&recurse($newstr,'rec2',0,1);
			}
			elsif ($$subref  =~ /^(rec2)$/){ 
				say "\t$$cntref (2): $str" if ($$modref == 1);
			}
		} ## End if pos..
		&rec(\@p2, $lenref, $subref, $lev+1, $cntref, $matchref, $modref);
	} ## End for.
} ## END rec

sub savtyp {
	# syntax: hap \%h4.
	my $Tref = \%TYP; 
	my $Dref = \%DEG; 
	my $subname = "savtyp";
	my $date = &datem("print");
	my ($a,$b,$c);
	open SVTIN, "> ~/type.last" or die ("Can't open type.last",$subname);
	print SVTIN "$date:\n";
	while (($a,$b) = each %$Tref) { 
		$c++;	
		print SVTIN "\$TYP{'$a'} = $b; ";
	} 
	print SVTIN "cnt=$c\n";
	$c=0;
	while (($a,$b) = each %$Dref) { 
		$c++;	
		print SVTIN "\$DEG{'$a'} = $b; ";
	} 
	print SVTIN "cnt=$c\n";
	close SVTIN or die ("Can't close type.last",$subname);
} ## END savtyp()

## Degree of a permutation:
sub sdeg { ## Degree 
	my ($perm,$mode) = @_;
	my $subname = "sdeg";
	die ("Not a valid permutation in base >= 10") if (length($perm)>10);
	my $targ = $perm;
	my $deg = 1; $mode = 2 unless (defined $mode);
	my @per; # splice @per; # A perl bug: sometimes a local array remains loaded.
	push @per, $perm;
	goto SDEGEND if ($Charset =~ /^($perm)/);
	while (++$deg){
		$targ = &powerp($targ,$perm,1);
		push @per, $targ ;
		last if ($Charset =~ /$targ/);
	}
	SDEGEND:
	return @per if ($mode == 2);
	return $deg;
} # END sdeg()

## Dodecaphonic Inverse:
sub sinv {
	my ($notes,$octaves,$mode,$base,$axis) = @_; ## Was: ($ser,$o,$mode).
	my $subname = "sinv";
	my @seq = split //,$notes;
	my @octs = split(//,($octaves //="")); 
  $base //= length($notes); $base = 10 if ($base > 10);
  $axis //= $seq[0];
  $mode //= 1;
	## length control
	die("Length of series should be less than 11.\n",$subname) if ((@seq) > 10);
	die("Length of series should be greater than 0.\n",$subname) if ((@seq) < 1);	
	my $inv = "";	my $newocts = ""; 
	for (my $n = 0; $n < (@seq); $n++){
		# An arithmetic definition for sinv: $res = $res.($axis-($seq[$n]-$axis))%($base+1);
		my $c = $seq[$n];
		my $sign = "+";
		my ($newnote, $newoct, $thisoct, $thinote);
		if ($c > $axis) { ($thinote,$thisoct) = notesum($c,$axis,"-",$base); $sign = "-" }
		if ($c < $axis) { ($thinote,$thisoct) = notesum($axis,$c,"-",$base); $sign = "+" }
		if ($c == $axis) { $thinote = "0"; $sign = "+" }
		($newnote, $newoct) = notesum($axis,$thinote,$sign,$base);
    if (defined $octs[$n]){ $newoct += $octs[$n] }
    else { $newoct = "2" } 
		# print "$n -> $axis = $thinote $sign = $newnote $newoct\n";
		$inv = $inv.$newnote;
		$newocts = $newocts.$newoct;
	}
	return $inv if ($mode == 1);
	return ($inv,$newocts,$mode);
} # END sinv()

## Mapping S on P (indexically):
# smap(s,p) can be defined by powerp() as p^-1(s):
# examples:
# print smap(sinv("0B1A29384756","","","1"),"0B1A29384756");
# 021436587A9B
# print powerp(sinv("0B1A29384756","","","1"),powerp("0123456789AB","0B1A29384756","-1"),"1");
# 021436587A9B
sub smap {
	my @perm = split //, shift;
	my @map = split //, shift;
	my ($res,$n);
	for (my $i = 0; $i < (@perm); $i++){
		for ($n = 0; $n < (@map); $n++) { last if ($map[$n] =~ /$perm[$i]/)}		
		$res .= $n;
	}
	return $res;
} # END smap()

## Opposite:
sub sopp {
	return srev(sinv(@_)); ## @_ = ($notes,$octaves,$base,$axis,$mode).
} # END sopp()

## Create the series of an elementary partition:
sub spart {
	my ($spart,$mode) = @_;
	my @spart = split / /,$spart;
	my $ind = $spart ; $ind =~ s/ //g; 
	my @ind = split //,$ind;
	@ind = sort(@ind); $ind = "@ind"; $ind =~ s/ //g; 
	my $subname = "spart";
	my $date = datem("print");
	$mode //= 1;
	my @perm = @ind; 
	for (my $n = 0; $n < (@spart); $n++) {
		my @U = split //,$spart[$n];
		print "u: $n @U :\n" if ($mode == 1);
		for (my $i = 0; $i < (@U); $i++) {
			print "\ti: $i : @perm\n" if ($mode == 1);
			next if ($U[$i+1] !~ /.+/);
			my $j = $U[$i];
			my $k = $U[$i+1];
			my $l = $perm[$j];
			print "\t\tjkl: $j,$k,$l\n" if ($mode == 1);
			$perm[$j] = $perm[$k];
			print "\t\t\t @perm\n" if ($mode == 1);
			$perm[$k] = $l;
			print "\t\t\t @perm\n" if ($mode == 1);
		}
	}
	my $perm = "@perm"; $perm =~ s/ //g;
	print "@spart -> $perm \n" if ($mode == 2);
	return $perm;
} ## END spart()

## Reverse:
sub srev {
	my ($notes,$octaves,$mode) = @_; 
	my @seq = split //, $notes;
	$mode //= 1;
	my @octs = split //,($octaves//="");
	## length control
	my $subname = "srev";
	die("Length of series should be less than 13.\n",$subname) if ((@seq) > 13);
	die("Length of series should be greater than 0.\n",$subname) if ((@seq) < 1);	
	my $rev = "";	my $newocts = "";
	foreach (@seq){ $rev = $_.$rev}
	for (my $n = 0; $n < (@seq); $n++){
		my $oct = $octs[$n]//=2;
		$newocts = $oct.$newocts;
	}
	return $rev if ($mode == 1);
	return ($rev,$newocts,$mode);
} # END srev()

## type:
sub styp {
	my $str = shift;
	my @partel = &partel($str);
	@partel = sort(@partel);
	my (@len,@type);
	for (my $n = 0; $n <= length($str); $n++) { $len[$n] = 0 }
	for (my $n = 0; $n < (@partel); $n++) { my $l = length($partel[$n]); $len[$l]++; }
	shift(@len);
	my $ret;
	foreach (@len){$ret = $ret.$_};
	return $ret;
} # END styp()

## Unmapping S on P:
sub suma {
	my @perm = split //, shift;
	my @map = split //, shift;
	my $res;
	for (my $i = 0; $i < (@perm); $i++){ $res .= $map[$perm[$i]]; }
	return $res;
} # END suma()

## Demapping of a degree suite:
sub sumadeg {
	my ($perm,$map) = @_;
	my $targ = $perm;
	my $deg = 1;
	my @per; splice @per; # A perl bug: sometimes a local array remains loaded.
	my $umap = &suma($perm,$map);
	push @per, $umap;
	goto SDEGEND if ($Charset =~ /$perm/);
	while (++$deg){
		$targ = &powerp($targ,$perm,1);
		$umap = &suma($targ,$map);
		push @per, $umap ;
		last if ($Charset =~ /$targ/);
	}
	SDEGEND:
	return @per;
} # END sumadeg()

## Producing the demapped degree suite of a series:
sub sumasuite {
	my ($perm) = @_;
	my $omap = &smap(&sopp($perm),$perm);
	return &sumadeg($omap,$perm);
} # END sdeg()

# Transformee Tq(p):
# Examples:
# Tq(id) = id:
# print &transt("201345","012345")
# 012345
# Tq(p o r) = Tq(p) o Tq(r):
# print &transt("421053",&powerp("201345","340152")); #*
# 250143
# print &powerp(&transt("421053","201345"),&transt("421053","340152"))
# 250143
# Tp(p)=p:
# print &transt("421053","421053")
# 421053
sub transt {
	my $q = shift;
	my $p = shift;
	return &powerp(&powerp(&natural($q),$q,"-1"),&powerp($p,$q,"1"),"1");
} ## END transt()

## Translations
sub trans {
	my ($base,$step,$sign) = @_;
	my @base = split //, $base;
	my $max;
	foreach (@base){my $note = $_; $max = $note if ($max < $note);};
	# print "max=$max\n";
	my $new;
	die ("Digital steps only. $!\n","trans") if ($step !~ /^([0123456789]{1})$/);
	for (my $i = 0; $i < (@base); $i++) {
		my $note = $base[$i];
		$step = $step;
		my ($trans,$oct) = notesum($note,$step,$sign,$max);
		$new .= $trans;
	}
	return $new;

} ## END trans()

sub zchop {
	my $base = shift;
	my @base = split //, $base;
	my $new;
	die ("Not a ztrans sequence. $!\n","zchop") if ($base[0] != 0);
	for (my $i = 1; $i < (@base); $i++) {
		my $note = $base[$i]-1;
		$new .= $note;
	}
	return $new;
} ## END zchop()

sub ztrans { ## TODO: 110917: now that we have a ztrans permutation, translate this func.
	my $base = shift;
	my @base = split //, $base;
	my $flag = 0;
	my $new;
	for (my $i = 0; $i < (@base); $i++) {
		my $note = $base[$i];
		if ($note == 0 or $flag == 1) { $flag = 1; $new = $new.$note }
	}
	for (my $i = 0; $i < (@base); $i++) {
		my $note = $base[$i];
		if ($note == 0) { last }
		else { $new = $new.$note }
	}
	return $new;

} ## END ztrans()

#########################################################################
### END Permutational functions (old) ###################################
#########################################################################

#########################################################################
### HELPERS  ############################################################
#########################################################################

## Help:
sub hsnprint {
	my $subname = 'hprint';
	while(<DATA>){
		print $_;
	}	
} # END hsnprint()

#########################################################################
### END HELPERs #########################################################
#########################################################################

sub help { 
 	while (<DATA>) { print $_ } ;
}
1;
__DATA__

## csg_Sets.pm HELP:	 

In these functions base is always <= 10.

	
## csg_Sets.pm EXAMPLES:

&csg_Sets::sinv("0123");
&csg_Sets::srev("0123");
&csg_Sets::sopp("0123","3333","1","4","1");

# sopp/sinv/srev: opposite/inverse/reverse, par1: base, par2: octs. 
my ($a,$b) =  sopp( "0186397254","3333333333","2"); print "$a $b";
my ($a,$b) =  sinv( "0186397254","3333333333","2"); print "$a $b";
my ($a,$b) =  srev( "0186397254","3333333333","2"); print "$a $b";

# Which permutations match a string under a given function:
perma("0123","db","0","1") ## string function mode level
	## level = 1 will exclude all permutations involving the first sign.

## Show the elementary partition for a given series:
spart("034872516",2)

