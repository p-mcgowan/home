#!/usr/bin/perl -w

use Data::Dumper;
use Bencode qw/bdecode/;
use DateTime;

my $fn = $ARGV[0];
open my $fh, "<", $fn; {
  local $/;
  $str = <$fh>;
}

close $fh;

$torrent = bdecode($str);
delete $torrent->{info}->{pieces};
warn Dumper keys (%{ $torrent });

printf "Files: \n";
foreach (@{ $torrent->{info}->{files} }) {
  printf "\t%-40s\t[ %8.2f MB ]\n", $_->{path}[0], $_->{length} / 1024**2;
}

print "Date: \n";
$dt = DateTime->from_epoch( epoch => $torrent->{"creation date"} );
printf "\t%s : %s\n", $dt->ymd, $dt->hms;

if ($torrent->{comment}) {
  printf "Comments:\n\t%s\n", $torrent->{comment};
}
if ($torrent->{'modified-by'}) {
  printf "Modified by\n\t%s\n", join( '', @{ $torrent->{'modified-by'} });
}
