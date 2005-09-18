#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

my $m; BEGIN { use_ok($m = "Devel::STDERR::Indent") }

can_ok($m, "indent");

sub factorial {
	my $h = Devel::STDERR::Indent::indent;

	my $n = shift;
	warn "computing $n";

	if ($n == 0) {
		return 1
	} else {
		my $got = factorial($n - 1);
		warn "return $got * $n";
		return $n * $got;
	}
}

{
	my $output;
	my $expected = <<OUTPUT;
computing 3
	computing 2
		computing 1
			computing 0
		return 1 * 1
	return 1 * 2
return 2 * 3
OUTPUT

	{
		open my $h, ">", \$output;
		local *STDERR = $h;

		factorial(3);
	}

	$output =~ s/ at .*$//gm;

	is($output, $expected, "output was indented");
}

