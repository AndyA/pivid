#!/usr/bin/env perl

use strict;
use warnings;

use POSIX qw( mkfifo );
use Path::Class;

for my $h264 (@ARGV) {
  my $nals = analyse($h264);
  show_idr( $h264, $nals );
}

sub show_idr {
  my ( $name, $nals ) = @_;
  my $frame = 0;
  my @run   = ();
  for my $nal (@$nals) {
    my $nut = $nal->{NAL}{nal_unit_type};
    if ( $nut == 1 ) {    # non-IDR
      my $fn = $nal->{SLICE_HEADER}{frame_num};
      $frame = $fn if $frame < $fn;
    }
    elsif ( $nut == 5 ) {    # IDR
      my $nf = $frame + 1;
      $frame = 0;
      if   ( @run && $run[-1][0] == $nf ) { $run[-1][1]++ }
      else                                { push @run, [$nf, 1] }
    }
  }
  print "$name: ",
   join( ', ', map { $_->[1] == 1 ? $_->[0] : join( ' x ', @$_ ) } @run ),
   "\n";
}

sub analyse {
  my $h264 = shift;
  my $fifo = file("$h264.fifo");
  $fifo->parent->mkpath;
  $fifo->remove;
  mkfifo "$fifo", 0600 or die "Can't create $fifo: $!\n";
  my $pid = fork;
  defined $pid or die "Can't fork: $!\n";
  unless ($pid) {
    exec 'h264_analyze', -o => "$fifo", $h264;
    die;
  }
  open my $fh, '<', $fifo or die "Can't read $fifo: $!\n";
  my ($tag);
  my @nal = ();
  while (<$fh>) {
    chomp( my $line = $_ );
    if ( $line =~ /^={3,}\s+([^=]+)={3,}$/ ) {
      ( $tag = uc trim($1) ) =~ s/\W+/_/g;
      push @nal, {} if $tag eq 'NAL';
    }
    elsif ( $line =~ /^\s*(\w+(?:\[\d+\])?)\s*:\s*(.+)/ ) {
      my ( $k, $v ) = ( $1, $2 );
      $v =~ s/\s*\(.+?\)\s*$//;
      $nal[-1]{$tag}{$k} = trim($v) if @nal;
    }
  }
  close $fh;
  $fifo->remove;
  return \@nal;
}

sub trim {
  my $str = shift;
  for ($str) { s/^\s+//; s/\s+$// }
  return $str;
}

# vim:ts=2:sw=2:sts=2:et:ft=perl

