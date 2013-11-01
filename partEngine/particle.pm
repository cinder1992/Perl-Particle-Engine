#!/usr/bin/perl

package particle;
use strict;
use warnings;

sub new {
  my $className = shift;
  my $self = {
    _is        => "particle", #sanity check
    _vel       => shift,
    _pos       => shift,
    _img       => shift,
    _grav      => shift,
    _inside    => 0,
    _spawnTime => shift,
    _coef      => shift 
  };
  bless($self, $className);
  return $self;
}

sub setPos {
  my ($self, @pos) = @_;
  $self->{_pos} = @pos;
  return 0;
} return 1;
