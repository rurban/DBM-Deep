package Test1;

use 5.6.0;

use strict;
use warnings;

use base 'TestBase';
use base 'TestSimpleHash';

sub setup : Test(startup) {
    my $self = shift;

    $self->{db} = DBM::Deep->new( $self->new_file );

    return;
}

1;
__END__