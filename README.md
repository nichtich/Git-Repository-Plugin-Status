# NAME

Git::Repository::Plugin::Status - Show the working tree status

# SYNOPSIS

    # load the Status plugin
    use Git::Repository 'Status';

    # get the status of all files, including ignored files
    my @status = Git::Repository->new->status('--ignored');

    # print all tracked files
    for (@status) {
        say $_->path1 if $_->tracked;
    }

# DESCRIPTION

This module adds method `status` to module [Git::Repository](https://metacpan.org/pod/Git::Repository) to get the
status of a git working tree in form of [Git::Repository::Status](https://metacpan.org/pod/Git::Repository::Status) objects. See
[Git::Repository::Status](https://metacpan.org/pod/Git::Repository::Status) for how to make use of the status information.

# OPTIONS

The following options to the git status command can be used:

- -u\[<mode>\] or --untracked-files\[=<mode>\]

    Include untracked files with modes `no`, `normal`, or `all`.

- --ignored

    Include ignored files.

- --ignore-submodules\[=<when>\]

    Ignore changes to submodules when looking for changes (`none`, `untracked`,
    `dirty` or `all`).

# SEE ALSO

[https://www.kernel.org/pub/software/scm/git/docs/git-status.html](https://www.kernel.org/pub/software/scm/git/docs/git-status.html)

# AUTHOR

Jakob Voß

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Jakob Voß.

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.
