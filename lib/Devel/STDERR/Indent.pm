#!/usr/bin/perl

package Devel::STDERR::Indent;
use base qw/Exporter/;

use strict;
use warnings;

use vars qw/$VERSION @EXPORT_OK/;

BEGIN {
	$VERSION = "0.01";
	
	@EXPORT_OK = qw/indent/;
}

sub indent () {
	__PACKAGE__->new;
}

sub new {
	my $class = shift;

	my $old = $SIG{__WARN__};
	my $delegate = $old || sub {
		my $str = shift;
		$str =~ s/^\t//g; # remove one level of indentation
		print STDERR $str
	};

	$SIG{__WARN__} = sub {
		my $str = shift;
		$str =~ s/^/\t/g;
		&$delegate($str);
	};

	bless {
		old => $old,
	}, $class;
}

sub DESTROY {
	my $self = shift;
	$SIG{__WARN__} = $self->{old};
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Devel::STDERR::Indent - Indents STDERR to aid in print-debugging recursive algorithms.

=head1 SYNOPSIS

	use Devel::STDERR::Indent qw/indent/;

	sub factorial {
		my $h = indent; # causes indentation

		my $n = shift;
		warn "computing factorial $n"; # indented based on call depth

		if ($n == 0) {
			return 1
		} else {
			my $got = factorial($n - 1);
			warn "got back $got, multiplying by $n";
			return $n * $got;
		}
	}

=head1 DESCRIPTION

When debugging recursive code it's useful, but often too much trouble to have
your traces indented.

This module makes it easy - call the indent function, and keep the thing you
got back around until the sub exits.

This will wrap $SIG{__WARN__} with something that adds one level of indentation
to strings (c<s/^/\t/g>) and then delegates to the previous $SIG{__WARN__}
handler.

When the handle is destroyed (due to garbage collection), the wrapping is undone.

=cut


