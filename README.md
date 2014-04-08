# NAME

Dist::Zilla::Plugin::Test::PAUSE::Permissions - Generate a test to verify PAUSE permissions

# VERSION

version 0.001

# SYNOPSIS

In your `dist.ini`:

    [Test::PAUSE::Permissions]

# DESCRIPTION

This is a [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) plugin that runs at the
[gather files](https://metacpan.org/pod/Dist::Zilla::Role::FileGatherer) stage, providing a
[Test::PAUSE::Permisisons](https://metacpan.org/pod/Test::PAUSE::Permisisons) test, named `xt/release/pause-permissions.t`).

# SUPPORT

Bugs may be submitted through [the RT bug tracker](https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-Test-PAUSE-Permissions)
(or [bug-Dist-Zilla-Plugin-Test-PAUSE-Permissions@rt.cpan.org](mailto:bug-Dist-Zilla-Plugin-Test-PAUSE-Permissions@rt.cpan.org)).
I am also usually active on irc, as 'ether' at `irc.perl.org`.

# SEE ALSO

- [Test::PAUSE::Permisisons](https://metacpan.org/pod/Test::PAUSE::Permisisons)

# AUTHOR

Karen Etheridge <ether@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Karen Etheridge.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
