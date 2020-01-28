package Compiler::TokenParseRules::PackageName;
use strict;
use warnings;

use Compiler::TokenParseRules::Rule;
use Compiler::TokenParseRules::BlockLevel;

sub init_state {
    {
        mode => "noop",
        package_name => "main",
        defined_level => {},
    };
}

sub before_handle {
    my ($class, $tokens) = @_;
    Compiler::TokenParseRules::BlockLevel->apply($tokens);
}

sub handle_token {
    my ($class, $token, $state) = @_;

    my $defined_level = $state->{defined_level}{$state->{package_name}};

    if (defined $defined_level && $defined_level > $token->{block_level}) {
        $state->{package_name} = "main";
    }

    $token->{package} = $state->{package_name};

    if ($token->{name} eq "Package") {
        $state->{package_name} = "";
        $state->{mode} = "listen";
        return ($token, $state);
    }

    if ($state->{mode} eq "listen" && $token->{name} =~ /^Namespace(Resolver)?$/) {
        $state->{package_name} .= $token->{data};
        $state->{mode} = "listen";
        return ($token, $state);
    }

    if ($state->{mode} eq "listen" && $token->{name} eq "SemiColon") {
        $state->{mode} = "nope";
        $state->{defined_level}{$state->{package_name}} = $token->{block_level};
        return ($token, $state);
    }

    return ($token, $state);
}

sub after_handle {
    my ($class, $tokens) = @_;
    my @return_tokens = @$tokens;
    use Data::Dumper;
    my @namespace_definition_tokens = _extract_namespace_definition_tokens(@return_tokens);
    for my $def_token (@namespace_definition_tokens) {
        my ($begin, $end, $replace) = @$def_token;
        @return_tokens = _apply_namespace_definition_tokens($begin, $end, $replace, @return_tokens);
    }
    return @return_tokens;
}

sub _extract_namespace_definition_tokens {
    my @tokens = @_;
    my @namespace_tokens_list = ();

    my @namespace_tokens = undef;
    my ($token, $i, $begin, $end);
    for $i (0 .. $#tokens) {
        $token = $tokens[$i];

        if (!defined $begin && $token->{name} eq "Package") {
            $begin = $i;
            @namespace_tokens = ($token);
        }
        elsif (defined $begin) {
            push @namespace_tokens, $token;
        }

        if (defined $begin && $token->{name} eq "SemiColon") {
            $end = $i;
            my $package_name = $token->{package};
            push @namespace_tokens_list, [$begin, $end, [_fill_package($package_name, @namespace_tokens)]];
            $begin = $end = undef;
            @namespace_tokens = undef;
        }
    }

    return @namespace_tokens_list;
}

sub _fill_package {
    my ($package_name, @tokens) = @_;
    map {$_->{package} = $package_name; $_} @tokens;
}

sub _apply_namespace_definition_tokens {
    my ($begin, $end, $replace, @tokens) = @_;
    my @return_tokens;
    my $i;
    for $i (0 .. $#tokens) {
        my $row = $i >= $begin && $i <= $end ? $replace->[$i-$begin] : $tokens[$i];
        push @return_tokens, $row;
    }
    return @return_tokens;
}

1;