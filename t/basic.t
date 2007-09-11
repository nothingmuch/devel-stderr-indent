#!/usr/bin/perl

use strict;
use warnings;

use Test::More ( $] >= 5.008 ? ( tests => 3 ) : ( skip_all => "need open scalar ref for this test" ) );

my $m; BEGIN { use_ok($m = "Devel::STDERR::Indent") }

can_ok($m, "indent");

sub factorial {
	my $h = Devel::STDERR::Indent::indent;

	my $n = shift;
	warn "computing $n\n";

	if ($n == 0) {
		return 1
	} else {
		my $got = factorial($n - 1);
		warn "return $got * $n\n";
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

	is($output, $expected, "output was indented");
}

