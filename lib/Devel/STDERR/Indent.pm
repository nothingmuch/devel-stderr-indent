#!/usr/bin/perl

package Devel::STDERR::Indent;
use base qw/Exporter/;

use strict;
use warnings;

use vars qw/$VERSION @EXPORT_OK $STRING/;

BEGIN {
	$VERSION = "0.04";
	
	@EXPORT_OK = qw/indent $STRING/;

	$STRING = "\t";
}

sub indent () {
	__PACKAGE__->new;
}

my $count = 0;
my $old;

sub new {
	my $class = shift;

	if (++$count == 1) {
		$old = $SIG{__WARN__};

		my $delegate = $old || sub {
			my $str = shift;
			print STDERR $str
		};

		$SIG{__WARN__} = sub {
			my $str = shift;
			$str =~ s/^/$STRING x ($count - 1)/gme;
			&$delegate($str);
		};
	}

	bless { }, $class;
}

sub DESTROY {
	my $self = shift;
	if (--$count == 0) {
		$SIG{__WARN__} = $old;
	}
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

This will wrap $SIG{__WARN__} with something that adds as many repetitions of
C<$Devel::STDERR::Indent::STRING> as there are live instances of the class
(minus one):

	s/^/$STRING x ($count - 1)/ge

When the handle is destroyed (due to garbage collection), $count is
decremented.

=head1 EXPORTS

All exports are optional, and may be accessed fully qualified instead.

=over 4

=head1 indent

Returns an object which you keep around for as long as you want another indent
level:

	my $h = $indent;
	# ... all warnings are indented by one additional level
	$h = undef; # one indentation level removed

=head1 $STRING

The string to repeat (defaults to C<"\t">).

=back

=head1 VERSION CONTROL

This module is maintained using Darcs. You can get the latest version from
L<http://nothingmuch.woobling.org/Devel-STDERR-Indent/>, and use C<darcs send>
to commit changes.

=cut


