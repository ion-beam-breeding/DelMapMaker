#!/usr/local/bin/perl

#Copyright (c) 2015 Kotaro Ishii and Yusuke Kazama
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

use warnings;
use strict;
use Clone qw(clone);
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);

our $bias = 0;
GetOptions('d' => \$bias);
my $deletion;
our ($marker, $plant, $filename);
if (defined ($ARGV[3])) {
  $marker = $ARGV[0];
  $plant = $ARGV[1];
  $deletion = $ARGV[2];
  $filename = $ARGV[3].'.csv';
} else {
  print 'Usage: this.pl [-b] nmarker nmutant ndelelement outname',"\n";
  print 'nmarker: number of markers, nmutant: number of mutants',"\n";
  print 'ndelelement: number of deleted elements in the matrix representing PCR result',"\n";
  print 'outname: used for the name of output file',"\n";
  exit(1);
}

my $maxDeletion = 1; # difines max number of deletions (not elements) in each mutant
my $maxDelLength = int($marker*0.28 + 0.5); # defines max length of each deletion
my $matrix;
my $matrixtmp;

## Prepare a matrix

for (my $i = 0; $i < $plant; $i++) {
  for (my $j = 0; $j < $marker; $j++) {
    $matrix->[$i]->[$j] = 1;
  }
}

## Decide a location of deletion

$matrixtmp = clone ( $matrix );
for (my $i = 0; $i < $plant; $i++) {
  for (my $j = 0; $j < $maxDeletion; $j++) {
    $matrixtmp = &makeBreakage ($matrixtmp, $i, 2);
    if ( &countDeletion( $matrixtmp ) <= $deletion ) {
      $matrix = clone($matrixtmp);
    } else {
      last;
    }
  }
}

## Extend the deletion

$matrixtmp = clone ( $matrix );
LOOP: while (1) {
  for (my $i = 0; $i < $plant; $i++) {
    $matrixtmp = &extendBreakage( $matrixtmp, $i, int(rand($maxDelLength)+1) );
    if ( &countDeletion( $matrixtmp ) < $deletion ) {
    } elsif ( &countDeletion( $matrixtmp ) == $deletion ) {
      last LOOP;
    } else {
      $matrixtmp = clone ( $matrix );
    }
  }
}
$matrix = clone($matrixtmp);

&showMatrix( $matrix );
print "Deletions \=",&countDeletion( $matrix ),"\tOutput \= ",$filename,"\n";

###

sub makeBreakage {
  my $matrix = $_[0];
  my $tplant = $_[1];
  my $length = $_[2];

  my $tmarker;
  undef($tmarker);
  if ($bias) {
    while (! defined( $tmarker )) {
      my $i = int(&randn($marker/2, $marker/2)); #randn ( mean, sigma )
      if ($i >= 0 && $i <= $marker-1) {
        $tmarker = $i;
      }
    }
  } else {
    $tmarker = int(rand($marker));
  }

  my @deletion = ($tmarker, $tmarker);
  while ($deletion[1] - $deletion[0] + 1 < $length) {
    if ( int(rand(2)) ) {
      if ( $deletion[1] < $marker-1 ) {
        $deletion[1]++;
      }
    } else {
      if ( $deletion[0] > 0 ) {
        $deletion[0]--;
      }
    }
  }
  for ( my $i = $deletion[0]; $i <= $deletion[1]; $i++ ) {
    $matrix->[$tplant]->[$i] = 0;
  }
  return ( $matrix );
}

sub extendBreakage {
  my $matrix = $_[0];
  my $iplant = $_[1];
  my $length = $_[2];
  my @candidate;
  my $state;

  for (my $i = 0; $i < $length; $i++) {
    $state = $matrix->[$iplant]->[0];
    @candidate = ();
    if ( $matrix->[$iplant]->[0] == 0) {
      push (@candidate, 0);
    }
    for ( my $imarker = 1; $imarker <= $marker-1; $imarker++ ) {
      if ( $matrix->[$iplant]->[$imarker] == 0 && $state == 1 ) {
        push (@candidate, $imarker-1);
      } elsif ( $matrix->[$iplant]->[$imarker] == 1 && $state == 0 ) {
        push (@candidate, $imarker);
      }
      $state = $matrix->[$iplant]->[$imarker];
    }
    if ( $matrix->[$iplant]->[$marker-1] == 0) {
      push (@candidate, $marker-1);
    }
    $matrix->[$iplant]->[$candidate[int(rand(@candidate))]] = 0;
  }
  return ( $matrix );
}
  

sub countDeletion {
  my $matrix = $_[0];
  my $count = 0;
  for ( my $plant = 0; $plant <= $#{$matrix}; $plant++ ) {
    for ( my $marker = 0; $marker <= $#{$matrix->[$plant]}; $marker++ ) {
      if ( $matrix->[$plant]->[$marker] == 0 ) {
        $count++;
      }
    }
  }
  return ($count);
}

sub showMatrix {
  my $matrix = $_[0];
  open (OUT, ">$filename");
  print OUT 'Marker,Marker1';
  for (my $imarker = 2; $imarker <= $marker; $imarker++) {
    print OUT "\,Marker$imarker";
  }
  print OUT "\n";
  for ( my $iplant = 0; $iplant < $plant; $iplant++ ) {
    my $i = $iplant+1;
    print OUT "Mutant$i";
    for ( my $imarker = 0; $imarker < $marker; $imarker++ ) {
      print $matrix->[$iplant]->[$imarker],',';
      print OUT "\,$matrix->[$iplant]->[$imarker]";
    }
    print "\n";
    print OUT "\n";
  }
}

sub randn {
  my ($mean, $sigma) = @_;
  my ($r1, $r2) = (rand(), rand());
  while ($r1 == 0) { $r1 = rand(); }
  return ($sigma * sqrt(-2 * log($r1)) * sin(2 * 3.14159265359 * $r2)) + $mean;
}
