package Compiler::TokenParseRules::Rule;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT = qw/apply/;

sub apply {
    my ($class, $tokens) = @_;

    my $state = {};
    if ($class->can('init_state')) {
        $state = $class->init_state();
    }

    if ($class->can('before_handle')) {
        $tokens = $class->before_handle($tokens);
    }

    return $tokens unless $class->can('handle_token');

    my @result_tokens = ();
    my $token;
    for $token (@$tokens) {
        ($token, $state) = $class->handle_token($token, $state);
        push @result_tokens, $token;
    }

    if ($class->can('after_handle')) {
        $tokens = $class->after_handle($tokens);
    }

    return \@result_tokens;
}

1;