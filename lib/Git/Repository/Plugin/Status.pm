use strict;
use warnings;
package Git::Repository::Plugin::Status;
#ABSTRACT: Show the working tree status

use Git::Repository::Plugin;
our @ISA = qw(Git::Repository::Plugin);

sub _keywords { return qw(status); }

sub status {
    ...;
}

1;

=encoding utf8
