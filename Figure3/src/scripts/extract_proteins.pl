#!/nethome/cisseoh/perl5/perlbrew/perls/perl-5.20.3-thread-multi/bin/perl -w
#
#
use strict;
use Data::Dumper;
use IO::All;
use Carp; 
use feature 'say';

my ($clst,$group) = @ARGV;

# iterate overclus
my $f = io($clst);
$f->autoclose(0);
while(my $l = $f->getline || $f->getline){
chomp $l;
        get_protein_for_this_clst($l,$group);
}

# subs
sub get_protein_for_this_clst{
    my %h = ();
    my ($todind,$groupFile) = (@_);

    my $grp = io($groupFile);
       $grp->autoclose(0);
       while(my $l = $grp->getline || $grp->getline){
       chomp $l;
            if ($l =~ m/^$todind/){
            
                    
                my @data2 = split /\t/, $l;
                my $grpID = shift @data2;
                my $e2 = "";
                
                foreach $e2 (@data2){
                    if ($e2 =~ m/\,/){
                        my @tmp = split /\,/, $e2;
                        my $e3 = "";
                        foreach $e3 (@tmp){
                            #say "TEST3\t$e3";
                            say $e3;    
                        }
                    } else {
                        say $e2;
                    }
                    }
            } else {
                #                    say "TEST";
                }
            }
}
