#!/usr/local/bin/perl

use strict;
use warnings;

use URI;
use Mozilla::CA;
use LWP::UserAgent;
use HTTP::Request;
use JSON;

use constant CORE_URL => "https://graph.facebook.com/";

if ($#ARGV != 1) {
  die "Usage : fbphoto.pl <access_token> <facebook user id>";
}

my $access_token = $ARGV[0];
my $user_id = $ARGV[1];
my $fields = "id,name,albums.fields(photos)";

my $uri = URI->new(CORE_URL . $user_id);

$uri->query_form(
  fields => $fields,
  access_token => $access_token
);

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new(GET => $uri);
my $res = $ua->request($req);

die $res->status_line unless ($res->is_success);

my $json = decode_json($res->content);
my $album_data = $json->{albums}->{data};

foreach my $album (@$album_data) {
  my $album_name = $album->{id};
  
  unless (-d $album_name ) {
    `mkdir $album_name`;
  }
  
  print "album id : $album_name" . "\n";
  my $photo_data = $album->{photos}->{data};

  foreach my $photos (@$photo_data) {
    print "downloading : $photos->{source}" . "\n";
    my $res = $ua->get($photos->{source});
    open (FH, '>', "$album_name/$photos->{id}.jpg") or die "Coundn't open file : $!";
    binmode FH;
    print FH $res->content;
    close(FH);
    sleep(1);
  }
}
