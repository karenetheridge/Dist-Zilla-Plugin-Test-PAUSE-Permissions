use strict;
use warnings;
package Dist::Zilla::Plugin::Test::PAUSE::Permissions;
# ABSTRACT: Generate a test to verify PAUSE permissions
# KEYWORDS: plugin test author PAUSE permissions
# vim: set ts=8 sts=4 sw=4 tw=115 et :

our $VERSION = '0.003';

use Moose;
with (
    'Dist::Zilla::Role::FileGatherer',
    'Dist::Zilla::Role::TextTemplate',
    'Dist::Zilla::Role::PrereqSource',
);

use Path::Tiny;
use namespace::autoclean;

sub filename { path(qw(xt release pause-permissions.t))->stringify }

has username => (
    is => 'ro', isa => 'Str|Undef',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $stash = $self->zilla->stash_named('%PAUSE');
        return if not $stash;

        my $username = $stash->username;
        $self->log_debug([ 'using PAUSE id "%s" from Dist::Zilla config', $username ]) if $username;
        $username;
    },
);

around dump_config => sub
{
    my ($orig, $self) = @_;
    my $config = $self->$orig;

    my $data = {
        blessed($self) ne __PACKAGE__ ? ( version => $VERSION ) : (),
    };
    $config->{+__PACKAGE__} = $data if keys %$data;

    return $config;
};

sub register_prereqs
{
    my $self = shift;

    $self->zilla->register_prereqs(
        {
            type  => 'requires',
            phase => 'develop',
        },
        'Test::PAUSE::Permissions' => '0',
    );
}

sub gather_files
{
    my $self = shift;

    require Dist::Zilla::File::InMemory;
    $self->add_file(Dist::Zilla::File::InMemory->new(
        name => $self->filename,
        content => $self->fill_in_string(
            <<'TEST',
use strict;
use warnings;

# this test was generated with {{ ref $plugin }} {{ $plugin->VERSION }}

use Test::More;
BEGIN {
    plan skip_all => 'Test::PAUSE::Permissions required for testing pause permissions'
        if $] < 5.010;
}
use Test::PAUSE::Permissions;

all_permissions_ok({{ $username ? qq{'$username'} : '' }});
TEST
            {
                dist => \($self->zilla),
                plugin => \$self,
                username => \($self->username),
            },
        ),
    ));
}

__PACKAGE__->meta->make_immutable;
__END__

=pod

=head1 SYNOPSIS

In your F<dist.ini>:

    [Test::PAUSE::Permissions]

=head1 DESCRIPTION

This is a L<Dist::Zilla> plugin that runs at the
L<gather files|Dist::Zilla::Role::FileGatherer> stage, providing a
L<Test::PAUSE::Permissions> test, named F<xt/release/pause-permissions.t>).

=for Pod::Coverage filename gather_files register_prereqs

=head1 SEE ALSO

=for :list
* L<Test::PAUSE::Permissions>

=cut
