package test::class;

use strict;

use RPC::ExtDirect Action => 'test';
use RPC::ExtDirect::Event;

sub ping : ExtDirect(0) { \1 }

sub ordered : ExtDirect(3) {
    my $class = shift;

    return [ splice @_, 0, 3 ];
}

sub named : ExtDirect(params => ['arg1', 'arg2', 'arg3']) {
    my ($class, %arg) = @_;

    return { %arg };
}

sub named_no_strict : ExtDirect(params => ['arg1', 'arg2'], strict => !1) {
    my ($class, %arg) = @_;

    return { %arg };
}

sub handle_form : ExtDirect(formHandler) {
    my ($class, %arg) = @_;

    delete $arg{_env};

    my @fields = grep { !/^file_uploads/ } keys %arg;

    my %result;
    @result{ @fields } = @arg{ @fields };

    return \%result;
}

sub handle_upload : ExtDirect(formHandler) {
    my ($class, %arg) = @_;

    my @uploads = @{ $arg{file_uploads} };

    my @result
        = map { { name => $_->{basename}, size => $_->{size} } }
              @uploads;

    return \@result;
}

our $EVENTS = [
    'foo',
    [ 'foo', 'bar' ],
    { foo => 'qux', bar => 'baz', },
];

sub handle_poll : ExtDirect(pollHandler) {
    my ($class) = @_;

    return RPC::ExtDirect::Event->new('foo', shift @$EVENTS);
}

1;

