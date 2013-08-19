package Git::Repository::Plugin::Status;
#ABSTRACT: Show the working tree status

use strict;
use warnings;
use 5.006;
use Carp;
use Scalar::Util qw(blessed);

use Git::Repository::Plugin;
our @ISA = qw(Git::Repository::Plugin);

use Git::Repository::Command;
use Git::Repository::Status;

sub _keywords { return qw(status); }

our $FORMAT = qr{^([ MARCDU?!])([ MARCDU?!]) ([^\0]+)\0$};

sub status {
	my ($r,@cmd) = @_;

    # pick up unsupported status options
    my @badopts = do {
        my $options = 1;
        grep {/^(--short|-s|--long|--column=.*|-b)$/}
        grep { $options = 0 if $_ eq '--'; $options } @cmd;
    };
    croak "status() cannot parse @badopts. "
        . 'Use run( status => ... ) to parse the output yourself'
        if @badopts;

	# TODO: -b shows branch and tracking - maybe interesting (?)

	@cmd = (qw(status -z --porcelain), @cmd);
	my $cmd = Git::Repository::Command->new($r, @cmd);

	my $fh = $cmd->stdout;
	local $/ = "\0";

	my @files;

	while(1) {
		my $line1 = <$fh>;
		NEXT: last unless defined $line1;

#print STDERR "LINE1: $line1\n";
		croak "error parsing output of `git @cmd`"
		    unless $line1 =~ $FORMAT;
		my @args = ($1,$2,$3);

		my $line2 = <$fh>;
#print STDERR "LINE2: $line2\n" if defined $line2;
		if (defined $line2 && $line2 !~ $FORMAT) { # PATH2
			chomp $line2;
			push @files, Git::Repository::Status->new(
			  @args[0..1], $line2, $args[2]);
		} else {
			push @files, Git::Repository::Status->new(@args);
			$line1 = $line2;
			goto NEXT;
		}
	}

	return @files;
}

1;

=head1 SYNOPSIS

...

=encoding utf8

=cut