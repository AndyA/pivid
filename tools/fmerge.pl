#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Path::Class;

use constant FRAME_FORMAT => '%010d.bmp';

my %O = (
  frames => 200,
  outdir => 'merged',
  index  => undef,
  last   => 0,
  delete => 0,
  work   => 'fmerge.work',
);

GetOptions(
  'frames:i' => \$O{frames},
  'outdir:s' => \$O{outdir},
  'index:i'  => \$O{index},
  'last'     => \$O{last},
  'delete'   => \$O{delete},
) or die;

my @f = map { find_image($_) } @ARGV;

my $outdir = dir( $O{outdir} );
$outdir->mkpath;
my $work = dir( $O{work} );
$work->mkpath;

my $next = defined $O{index} ? $O{index} : find_next_index($outdir);

while ( my @iname = splice @f, 0, $O{frames} ) {
  last unless $O{last} || @iname == $O{frames};
  my $oname = file( $outdir, sprintf FRAME_FORMAT, $next++ );
  merge( $oname, @iname );
  unlink @iname if $O{delete};
}

sub cmd(@) {
  my @cmd = @_;
  print "# ", join( ' ', @_ ), "\n";
  system @cmd and die;
}

sub merge {
  my ( $oname, @iname ) = @_;
  my $tmp = file( $work, $oname->basename );
  for my $i ( 0 .. $#iname ) {
    if ($i) {
      cmd
       convert => $iname[$i],
       $tmp,
       -fx => "(u+$i*v)/" . ( $i + 1 ),
       $tmp;
    }
    else {
      cmd cp => $iname[$i], $tmp;
    }
  }
  rename $tmp, $oname or die "Can't rename $tmp -> $oname: $!\n";
}

sub find_image {
  my $dir = shift;
  opendir my $dh, $dir or die "Can't read $dir: $!\n";
  return map { file( $dir, $_ ) } sort grep { /\.bmp$/i } readdir $dh;
}

sub find_next_index {
  my $dir = shift;
  my @f   = find_image($dir);
  return 0 unless @f;
  my $last = $f[-1]->basename;
  return $1 + 0 if $last =~ /(\d+)/;
  return 0;
}

# vim:ts=2:sw=2:sts=2:et:ft=perl

