BEGIN {
    say "1..6";
}
{
    use v5-inline;
    use v5.10.0;
    $| = 1;
    say "ok 1 - First message from Perl 5";
    use Data::Printer;
    if (1) {
        say "ok 2 - Conditional message from Perl 5";
    }
    raku {
        say "ok 3 - Message from Raku";
        $*OUT.flush;
        if True {
            say "ok 4 - Conditional message from Raku";
            $*OUT.flush;
        }
    }
    say "ok 5 - Last message from Perl 5";
}

if True {
    say "ok 6 - Still alive";
    $*OUT.flush;
}
