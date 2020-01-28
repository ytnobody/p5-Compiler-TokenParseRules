use strict;
use warnings;
use Test::More;
use Compiler::TokenParseRules::PackageName;
use Compiler::TokenParseRules::BlockLevel;
use Compiler::Lexer;
use File::Spec;

sub tokenize {
    my $file = shift;
    open my $fh, '<', $file;
    my $source = do {local $/; <$fh>};
    close $fh;

    my $lexer = Compiler::Lexer->new(filename => $file, verbose => 1);
    return $lexer->tokenize($source);
}

use Data::Dumper;


# my $tokens = tokenize(File::Spec->catfile(qw/t data simple.pl/));
# warn Dumper(
#     Compiler::TokenParseRules::PackageName->apply($tokens)
# );


my $tokens = tokenize(File::Spec->catfile(qw/t data blocked.pl/));
warn Dumper(
    Compiler::TokenParseRules::PackageName->apply($tokens)
);


# my $tokens = tokenize(File::Spec->catfile(qw/t data blocked.pl/));
# warn Dumper(
#     Compiler::TokenParseRules::BlockLevel->apply($tokens)
# );




ok 1;
done_testing;
