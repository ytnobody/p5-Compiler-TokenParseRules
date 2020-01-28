{
    package 
        Foo::Bar;

    use strict;
    use warnings;

    our $default_y = 10;

    sub sum {
        my ($x, $y) = @_;
        $y = $default_y if !$y;
        $x + $y;
    }

    1;
}

{
    package 
        Foo::Hoge;

    use strict;
    use warnings;

    sub to_hash {
        my ($x, $y) = @_;
        {x => $x, y => $y};
    }

    1;
}

my $x = "hoge";
