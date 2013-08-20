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

    @cmd = (qw(status -z --porcelain), @cmd);
    my $cmd = Git::Repository::Command->new($r, @cmd);

    my $fh = $cmd->stdout;
    local $/ = "\0";

    my @files;

    while(1) {
        my $line1 = <$fh>;
        NEXT: last unless defined $line1;

        croak "error parsing output of `git @cmd`"
            unless $line1 =~ $FORMAT;
        my @args = ($1,$2,$3);

        my $line2 = <$fh>;
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

    # load the Status plugin
    use Git::Repository 'Status';

    # get the status of all files
    my @status = Git::Repository->status('--ignored');

    # print all ignored files
    for (@status) {
        say $_->path1 if $_->ignored;
    }

=head1 DESCRIPTION

This module adds the C<status> method to L<Git::Repository> to get the status
of a git working tree in form of L<Git::Repository::Status> objects. See
L<Git::Repository::Status> for how to make use of the status information.

=head1 OPTIONS

The following options to the git status command can be used:

=over 4

=item -u[<mode>] or --untracked-files[=<mode>]

Include untracked files with modes C<no>, C<normal>, or C<all>.

=item --ignored

Include ignored files.

=item --ignore-submodules[=<when>]

Ignore changes to submodules when looking for changes (C<none>, C<untracked>,
C<dirty> or C<all>).

=back

=head1 SEE ALSO

L<https://www.kernel.org/pub/software/scm/git/docs/git-status.html>

=encoding utf8

=cut
