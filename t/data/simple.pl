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

