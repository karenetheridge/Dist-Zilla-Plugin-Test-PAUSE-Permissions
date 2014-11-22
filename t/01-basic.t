use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Warnings 0.009 ':no_end_test', ':all';
use Test::DZil;
use Path::Tiny;
use Safe::Isa;
use File::pushd 'pushd';

# ensure this loads, as well as getting prereqs autodetected
use Test::PAUSE::Permissions ();

{
    my $tzil = Builder->from_config(
        { dist_root => 't/does-not-exist' },
        {
            add_files => {
                path(qw(source dist.ini)) => simple_ini(
                    [ GatherDir => ],
                    [ 'Test::PAUSE::Permissions' ],
                    [ '%PAUSE' => { username => 'username', password => 'password' } ],
                ),
                path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
            },
        },
    );

    $tzil->chrome->logger->set_debug(1);
    $tzil->build;

    my $build_dir = path($tzil->tempdir)->child('build');
    my $file = $build_dir->child(qw(xt release pause-permissions.t));
    ok(-e $file, 'test created');

    my $content = $file->slurp_utf8;
    unlike($content, qr/[^\S\n]\n/m, 'no trailing whitespace in generated test');

    like($content, qr/^all_permissions_ok\('username'\);$/m, 'username extracted from stash and passed to test');

    subtest 'run the generated test' => sub
    {
        my $wd = pushd $build_dir;

        # ensure we don't call out to the network when running the test
        local $ENV{RELEASE_TESTING};
        allow_warnings(1);
        do $file;
        allow_warnings(0);
        note 'ran tests successfully', return if not $@;
        # FIXME: it looks like newer Test::More alphas use a different class now
        die $@ if $@->$_isa('Test::Builder::Exception');
        fail('got exception'), local $Data::Dumper::Maxdepth = 2, diag explain $@;
    };

    diag 'got log messages: ', explain $tzil->log_messages
        if not Test::Builder->new->is_passing;
}

{
    my $tzil = Builder->from_config(
        { dist_root => 't/does-not-exist' },
        {
            add_files => {
                path(qw(source dist.ini)) => simple_ini(
                    [ GatherDir => ],
                    [ 'Test::PAUSE::Permissions' ],
                ),
                path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
            },
        },
    );

    $tzil->chrome->logger->set_debug(1);
    $tzil->build;

    my $build_dir = path($tzil->tempdir)->child('build');
    my $file = $build_dir->child(qw(xt release pause-permissions.t));
    ok(-e $file, 'test created');

    my $content = $file->slurp_utf8;
    unlike($content, qr/[^\S\n]\n/m, 'no trailing whitespace in generated test');

    like($content, qr/^all_permissions_ok\(\);$/m, 'no username passed to test');

    diag 'got log messages: ', explain $tzil->log_messages
        if not Test::Builder->new->is_passing;
}

had_no_warnings if $ENV{AUTHOR_TESTING};
done_testing;
