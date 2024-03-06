#!/nethome/cisseoh/perl5/perlbrew/perls/perl-5.20.3-thread-multi/bin/perl -w
#
#
use strict;
use Data::Dumper;
use IO::All;
use Carp; 
use feature 'say';

my ($pf) = $ARGV[0];

my $f = io($pf);
$f->autoclose(0);
while(my $l = $f->getline || $f->getline){
chomp $l;
        next if $l =~m/^#/;
        my ($dom) = $l =~/(PF\d+\.\d)/;  # PF13532.5
        say $dom;
}

