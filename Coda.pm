# -*- perl -*-
#
# Coda  -  a global destructor that closes stdout, with error-checking
#
# Why `Coda'?  Here are some definitions:
# coda: A few measures added beyond the natural termination of a composition.
#    [1913 Webster]
# coda: the closing section of a musical composition [syn: {finale}]
#    [From WordNet (r) 2.0 (August 2003)]
#
#
# This package is intended to be "use"d very early on.
# It simply sets up actions to be executed at the end of execution.
#
# $Id: Coda.pm,v 1.6 2005/02/14 09:00:26 meyering Exp $

package Coda;

use strict;
use warnings;

our $ME = $0;
(our $VERSION = '$Revision: 1.6 $ ') =~ tr/[0-9].//cd;

# Set $? to this value upon failure to close stdout.
our $Exit_status = 1;

END {
    # Nobody ever checks the status of print()s.  That's okay, because
    # if any do fail, we're usually[*] guaranteed to get an indicator
    # when we close() the file handle.
    # [*] Beware the exception: due to a long-standing bug in Perl,
    # still not fixed in 5.003 to 5.9.1.  See the report and patch here:
    # http://www.xray.mpe.mpg.de/mailing-lists/perl5-porters/2004-12/msg00072.html
    #
    # If stdout is already closed, we're done.
    defined fileno STDOUT
      or return;
    # Close stdout now, and if that succeeds, simply return.
    close STDOUT
      and return;

    # Errors closing stdout.  Indicate that, and hope stderr is OK.
    warn "$ME: closing standard output: $!\n";

    # Don't be so arrogant as to assume that we're the first END handler
    # defined, and thus the last one invoked.  There may be others yet
    # to come.  $? will be passed on to them, and to the final _exit().
    #
    # If it isn't already an error, make it one (and if it _is_ an error,
    # preserve the value: it might be important).
    $? ||= $Exit_status;
}

1;

__DATA__

=head1	NAME

Coda - establish a global destructor that closes stdout, with error-checking

=head1	SYNOPSIS

    use Coda;

=head1	DESCRIPTION

Coda defines a global destructor handler that closes STDOUT and reports
any failure.  If the close fails, it means some script output was lost.
This is reported as an error to STDERR.  If the incoming exit status is
zero, set it to one, so the script will exit with error status.

=head1	AUTHOR

Jim Meyering <jim@meyering.net>, Ed Santiago <esm@pobox.com>

=cut