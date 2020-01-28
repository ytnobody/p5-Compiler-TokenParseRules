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

1;