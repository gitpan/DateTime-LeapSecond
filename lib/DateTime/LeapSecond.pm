package DateTime::LeapSecond;

use 5.005;
use strict;

use vars qw( $VERSION );
use vars qw( @RD @LEAP_SECONDS %RD_LENGTH );

$VERSION = '0.03';

# Generates a Perl binary decision tree
sub _make_utx {
    my ($beg, $end, $tab, $op) = @_;
    my $step = int(($end - $beg) / 2);
    my $tmp;
    if ($step <= 0) {
        $tmp = "${tab}return $LEAP_SECONDS[$beg + 1];\n";  
        return $tmp;
    }
    $tmp  = "${tab}if (\$val < " . $RD[$beg + $step] . ") {\n";
    $tmp .= _make_utx ($beg, $beg + $step, $tab . "    ", $op);
    $tmp .= "${tab}}\n";
    $tmp .= "${tab}else {\n";
    $tmp .= _make_utx ($beg + $step, $end, $tab . "    ", $op);
    $tmp .= "${tab}}\n";
    return $tmp;
}

# Process BEGIN data and write binary tree decision table
sub _init {
    my $value = 32 - 24;
    while (@_) {
        my ( $year, $mon, $mday, $leap_seconds ) = 
           ( shift, shift, shift, shift );
        # print "$year,$mon,$mday\n";

        my $utc_epoch = _ymd2rd( $year, ( $mon =~ /Jan/i ? 1 : 7 ), $mday );

        $value++;
        push @LEAP_SECONDS, $value;
        push @RD, $utc_epoch;

        $RD_LENGTH{ $utc_epoch - 1 } = $leap_seconds;

        # warn "$year,$mon,$mday = $utc_epoch +$value";
    }

    push @LEAP_SECONDS, ++$value;

    my $tmp;

    # write binary tree decision table

    $tmp  = "sub leap_seconds {\n";
    $tmp .= "    my \$val = shift;\n";
    $tmp .= _make_utx (-1, 1 + $#RD, "    ", "+");
    $tmp .= "}\n";

    # NOTE: uncomment the line below to see the code:
    warn $tmp;

    eval $tmp;

}

# copied from DateTimePP.pm
sub _ymd2rd
{
    use integer;
    my ( $y, $m, $d ) = @_;
    my $adj;

    # make month in range 3..14 (treat Jan & Feb as months 13..14 of
    # prev year)
    if ( $m <= 2 )
    {
        $y -= ( $adj = ( 14 - $m ) / 12 );
        $m += 12 * $adj;
    }
    elsif ( $m > 14 )
    {
        $y += ( $adj = ( $m - 3 ) / 12 );
        $m -= 12 * $adj;
    }

    # make year positive (oh, for a use integer 'sane_div'!)
    if ( $y < 0 )
    {
        $d -= 146097 * ( $adj = ( 399 - $y ) / 400 );
        $y += 400 * $adj;
    }

    # add: day of month, days of previous 0-11 month period that began
    # w/March, days of previous 0-399 year period that began w/March
    # of a 400-multiple year), days of any 400-year periods before
    # that, and 306 days to adjust from Mar 1, year 0-relative to Jan
    # 1, year 1-relative (whew)

    $d += ( $m * 367 - 1094 ) / 12 + $y % 100 * 1461 / 4 +
          ( $y / 100 * 36524 + $y / 400 ) - 306;
}

sub extra_seconds {
    exists $RD_LENGTH{ $_[0] } ? $RD_LENGTH{ $_[0] } : 0
}

sub day_length {
    exists $RD_LENGTH{ $_[0] } ? 86400 + $RD_LENGTH{ $_[0] } : 86400
}

sub initialize {
    # this table: ftp://62.161.69.5/pub/tai/publication/leaptab.txt
    # known accurate until (at least): 2003-12-31
    #
    # There are no leap seconds before 1972, because that's the
    # year this system was implemented.
    #
    # year month day number-of-leapseconds
    #
    _init ( qw(
1972  Jan. 1  +1 
1972  Jul. 1  +1
1973  Jan. 1  +1
1974  Jan. 1  +1
1975  Jan. 1  +1
1976  Jan. 1  +1
1977  Jan. 1  +1
1978  Jan. 1  +1
1979  Jan. 1  +1
1980  Jan. 1  +1
1981  Jul. 1  +1
1982  Jul. 1  +1
1983  Jul. 1  +1
1985  Jul. 1  +1
1988  Jan. 1  +1
1990  Jan. 1  +1
1991  Jan. 1  +1
1992  Jul. 1  +1
1993  Jul. 1  +1
1994  Jul. 1  +1
1996  Jan. 1  +1
1997  Jul. 1  +1
1999  Jan. 1  +1
    ) );
}

__PACKAGE__->initialize;

1;
__END__

=head1 NAME

DateTime::LeapSecond - DEPRECATED: use "DateTime" distribution instead

=head1 SYNOPSIS

  use DateTime;
  use DateTime::LeapSecond;

  print "Leap seconds between years 1990 and 2000 are ";
  print Date::Leapsecond::leap_seconds( $utc_rd_2000 ) - 
        Date::Leapsecond::leap_seconds( $utc_rd_1990 ); 

=head1 DESCRIPTION

This module is used to calculate leap seconds for a given Rata Die
day.  It is mostly intended for use by the DateTime.pm, rather than
for external users.

This library is known to be accurate for dates until december 2003.

There are no leap seconds before 1972, because that's the year this
system was implemented.

B<NOTE: As of DateTime.pm 0.16, DateTime.pm implements this code in XS
internally.  It also includes this module in the distribution in case
the XS code cannot be compiled.>

=over 4

=item * leap_seconds( $rd )

Returns the number of accumulated leap seconds for a given day,
in the range 9 .. 32.

=item * extra_seconds( $rd )

Returns the number of leap seconds for a given day,
in the range -2 .. 2.

=item * day_length( $rd )

Returns the number of seconds for a given day,
in the range 86398 .. 86402.

=back

=head1 AUTHOR

Fl�vio Soibelmann Glock, E<lt>fglock@pucrs.brE<gt>

=head1 COPYRIGHT

Copyright (c) 2003 Fl�vio Soibelmann Glock.  All rights reserved.
This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included
with this module.

=head1 SEE ALSO

E<lt>http://hpiers.obspm.fr/eop-pc/earthor/utc/leapsecond.htmlE<gt>

http://datetime.perl.org

=cut
