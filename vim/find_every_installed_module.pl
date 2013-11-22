#!/usr/local/bin/perl

use strict;
use warnings;

use File::Find 'find';

my $LIST_DIR = $ENV{HOME} . "/.vim/";
my $LIST_FILE = "file_that_every_installed_perl_module";

unless (-e $LIST_DIR) {
  mkdir $LIST_DIR or die "Couldn't create Directory $LIST_DIR:$! \n";
}

open (my $FH, '>', "$LIST_DIR$LIST_FILE");

my %already_seen;

for my $incl_dir (@INC) {
  print $incl_dir . "\n";
  find {
    wanted => sub {
      my $file = $_;

      return unless $file =~ /\.pm\z/;

      $file =~ s{^\Q$incl_dir/\E}{ };
      $file =~ s{/}{::}g;
      $file =~ s{\.pm\z} {};
      
      $file =~ s{^.*\b[a-z_0-9]+::}{ };
      $file =~ s{^\d+\.\d+\.\d+::(?:[a-z_][a-z_0-9]*::)?}{ };
      return if $file =~ m{^::};

      print $FH $file . "\n" unless $already_seen{$file}++;
    },
    no_chdir => 1,
  }, $incl_dir;
}
