package DBM::Deep::Hash;

use strict;

use base 'DBM::Deep';

sub TIEHASH {
    ##
    # Tied hash constructor method, called by Perl's tie() function.
    ##
    my $class = shift;
    my $args;
    if (scalar(@_) > 1) { $args = {@_}; }
    #XXX This use of ref() is bad and is a bug
    elsif (ref($_[0])) { $args = $_[0]; }
    else { $args = { file => shift }; }
    
    $args->{type} = $class->TYPE_HASH;

    return $class->_init($args);
}

sub FIRSTKEY {
	##
	# Locate and return first key (in no particular order)
	##
    my $self = DBM::Deep::_get_self($_[0]);

	##
	# Make sure file is open
	##
	if (!defined($self->fh)) { $self->_open(); }
	
	##
	# Request shared lock for reading
	##
	$self->lock( $self->LOCK_SH );
	
	my $result = $self->_get_next_key();
	
	$self->unlock();
	
	return ($result && $self->root->{filter_fetch_key})
        ? $self->root->{filter_fetch_key}->($result)
        : $result;
}

sub NEXTKEY {
	##
	# Return next key (in no particular order), given previous one
	##
    my $self = DBM::Deep::_get_self($_[0]);

	my $prev_key = ($self->root->{filter_store_key})
        ? $self->root->{filter_store_key}->($_[1])
        : $_[1];

	my $prev_md5 = $DBM::Deep::DIGEST_FUNC->($prev_key);

	##
	# Make sure file is open
	##
	if (!defined($self->fh)) { $self->_open(); }
	
	##
	# Request shared lock for reading
	##
	$self->lock( $self->LOCK_SH );
	
	my $result = $self->_get_next_key( $prev_md5 );
	
	$self->unlock();
	
	return ($result && $self->root->{filter_fetch_key})
        ? $self->root->{filter_fetch_key}->($result)
        : $result;
}

##
# Public method aliases
##
*first_key = *FIRSTKEY;
*next_key = *NEXTKEY;

1;
__END__