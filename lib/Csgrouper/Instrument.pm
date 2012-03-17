###############################################################################
## ### FILE INFO: Csgrouper::Instrument.pm.
###############################################################################
## 111017. 
## A mere manual container.

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

=head1 Manual for Instrument.pm

At present this object only serves the purpose of providing a file to contain its manual. For instruments are centralized into the Csgrouper object. In the future however we might decide to make an objective mirror to the instrumental params, as has been done for Tkrows with Sequences. 

=head2 Instruments

Instruments are Csound text files, not written in Perl. 

Instruments variables are mainly accessed as csgrouper.pl $Part params though accessible through the Csgrouper main object ($CsgObj). Instrument params can correspond to params defined in the Types class and a dedicated table on top of the instrument tab allows to attribute these specific param names to instrument's p-values. However ther is no control on the names attributed there and in case of mismatch, the routine will simply assign default values (second line in the table) to csound parameters without warning.

The method for adding a Csgrouper defined instrument param to an instrument that did not posess this param consists in adding a line with pn = ivar,kvar or avar depending on the case. Now after an update, pn is listed in the param table and a default value as well as a predefined name can be attributed while the variable defined in the instrument text will contain this value and be usable anywhere within this instrument.

Any instrument parameter greater than 2 (because 1,2 are unmodifiable id and start time) can see its value ovewritten by a special mention following the instrument name as in 

	"i24,p5=f10,p6=0.5,p7=sub{&myfunction($CsgObj->class->attr)}" 
	
for example, where parameters overwriting strings will be parsed and evaluated by the subroutine Xfun(). These params however can in turn be overwritten by xfunctions set parameters (see csgrouper.pl manual: Parameter overwriting).

In order to add easily a new instrument param without overwriting or skipping a valid param name, the Tk table in the interface orchestra tab can be updated with each new param that would be inserted into the instrument text as a valid line containing an additionnal p-value. 

Note that saving a part where the score has been written already will store this content too, duplicating the orchestra records.
=cut
	
package Csgrouper::Instrument; 
use Modern::Perl;
use lib ("~/Csgrouper/lib");
use Moose;
use Moose::Util::TypeConstraints;
use Csgrouper::Types;

=head1 Attributes Section 

The standard params:

As we are creating the object naked, the only required attribute is the parent object:

Everything else will be done by BUILD.

=cut

has 'paro'	=> (isa => 'Object', is => 'ro', required => 1); ## A way to refer to a parent object without being an extension of it.
has 'ready'	=> (isa => 'Bool', 		is => 'ro', required => 0, default => 0,writer => 'set_ready');

__PACKAGE__->meta->make_immutable; 
no Moose; 

1;
__DATA__

=head1 Data Section

=cut
