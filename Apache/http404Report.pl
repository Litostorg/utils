#!/usr/bin/perl

#   Author :        ADW 04/15
#
#   Use :           Takes a space separated list of urls and referrers
#                   and parse them into a report listing
#                   a) All urls (sorted numerically descending by freq)
#                   b) Each url and a list of referrers, both sorted as above.
#
#   Note :          Meant to be used in conjunction with http404report.sh
#                   but can be used to do the same report on any sets of data.
#

use strict;
use warnings;

#use Data::Dumper;
#$Data::Dumper::Indent = 1;
use Getopt::Std qw(getopts);

# Don't buffer output.
$| = 1;

## Globals
# Hash of counts of the number of times a url was listed.
my %hash404sCountU;     

# Hash of hash of counts of the number of times a referrer was listed, per url.
my %hash404sCountR;

# For a list of all the urls, print the url and/or a list of all the referrers
# sorted numerically decending by frequency (in both cases).
sub printUrls
{
    my ($printUrl, $printReferer) = (@_);

    # Sort by the frequency descending.
    my @urls =
        sort { $hash404sCountU{$b} <=> $hash404sCountU{$a} }
        keys(%hash404sCountU);
    foreach my $url (@urls)
    {
        my $count = $hash404sCountU{$url};
        print("$count : $url\n") if ($printUrl);;
        printReferrers($url) if ($printReferer);
    }

    print("\n") if ($printUrl);
}

# Per url, print a list of referrers sorted by frequency numerically descending.
sub printReferrers
{
    my ($url) = (@_);

    # Again sort by frequency descending for this url.
    my @referrers =
        sort { $hash404sCountR{$url}{$b}
               <=>
               $hash404sCountR{$url}{$a}
             } keys(%{ $hash404sCountR{$url} });
    foreach my $referrer (@referrers)
    {
        my $count = $hash404sCountR{$url}-> {$referrer};
        print("\t$count: $referrer\n");
    }
    print("\n");

    return;
}


## MAIN

my %opts;
getopts("hru", \%opts);

if ($opts{h})
{
    print("Usage: $ARGV[0] [-h] [-u] [-r]\n");
    print("   -h: this message\n");
    print("   -u: print a list of uri's\n");
    print("   -r: print a list of uri's and referrers\n");
    exit(0);
}

# Parse the input and construct the hashes.
# Format: <url> <referrer>
while (my $input = <STDIN>)
{
    chomp($input);

    my ($url, $referrer) = split(/ /, $input);

    $referrer =~ s/"//g;

    $hash404sCountU{$url}++;
    $hash404sCountR{$url}-> {$referrer}++;
}

# print(Dumper(\%hash404sCountU) . "\n");
# print(Dumper(\%hash404sCountR) . "\n");

# Print a list of all the urls listed, sorted by frequency descending.
if ($opts{u})
{
    print("INVALID URIs:\n");
    printUrls(1, 0);
}

# Print a list of all the urls listed and for each url the list of referrers.
# Both sorted numerically descending.
if ($opts{r})
{
    print("INVALID URIs (and referrers):\n");
    printUrls(1, 1);
}

exit(0);

## END MAIN
# vim: autoindent:expandtab:tabstop=4
