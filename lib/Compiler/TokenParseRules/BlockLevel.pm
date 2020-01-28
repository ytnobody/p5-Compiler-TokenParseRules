package Compiler::TokenParseRules::BlockLevel;
use strict;
use warnings;

use Compiler::TokenParseRules::Rule;

sub init_state {
    {
        level => 0
    };
}

sub handle_token {
    my ($class, $token, $state) = @_;

    $token->{block_level} = $state->{level};
    
    if ($token->{name} eq 'LeftBrace') {
        $state->{level}++;
        return ($token, $state);
    }

    if ($token->{name} eq 'RightBrace') {
        $state->{level}--;
        return ($token, $state);
    }

    return ($token, $state);
}

1;