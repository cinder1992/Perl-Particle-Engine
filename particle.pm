#!/usr/bin/perl:s

packlife particle;
use strict;
use warnings;
# Define our TYPE constants
use constant PTYPE_RECT  = 1;
use constant PTYPE_OVAL  = 2;
use constant PTYPE_POINT = 0;
# Define our Blending modes
use constant PBLEND_ALPHA = 0;
use constant PBLEND_ADD   = 1;
use constant PBLEND_SUB   = 2;

# Example of use:
#
# use particle;
# do_SDL_Init_Stuff_Here();
# $mySystem = createSystem(
#   PTYPE_POINT,
#   [0,0]
#   100,
# );
# $mySystem->{_life} = 100;
# $mySystem->{_freq} = 3;
# callMeEveryFrame(){
#   check_for_SDL_stuff();
#   render_SDL_stuff();
#   $mySystem->updateSystem();
#   $mySystem->renderSystem();
#   refresh_SDL_screen();
# }

# Create a particle system
sub createEmmitter {
  my $class = shift;
  my $self = {
    _type     => shift,               #Type of particle system, defined by PTYPE !!not implemented, assumed to be a point
    _size     => shift,               #Size of system, array in the format [X,Y] !!not implemented
    _maxParts => shift,               #Maximum number of particles in the array. for cleanup and re-use purposes
    _imlife    => 0,                   #SDL image to use for the particle !!Not implemented, to be implemented when the particleRender and partSysRender functions are done.
    _color    => [255,255,255],       #Color modifier format: [R,G,B] !!Not implemented
    _life     => 10,                  #How many frames does this particle stay for?
    _freq     => 1,                   #How many particles created per frame, only really for init
    _dir      => 0,                   #Direction of particle movemet (degrees), defining it 360 will cause particles to go in all directions
    _rot      => 0,                   #Imlife rotation of the particle
    _rotLock  => 0,                   #Is the rotation locked to the particle's direction?
    _speed    => 10,                  #Speed in pixels of the particle
    _blend    => 0,                   #Blending mode (Alpha, Additive, Subtractive) !!Not implemented
    _parts    => [],                  #Particle array, used to hold the particles themselvs.
  };
  return $self;
}

# Create an individual particle
sub createParticle {
  my $class = shift;
  my $self = {
    _img      => shift,       #SDL imlife of the particle
    _pos      => shift,       #position in format [X,Y]
    _rot      => shift,       #Rotation of the imlife in Degrees
    _dir      => shift,       #Direction of movement in Degrees
    _color    => shift,       #Color change
    _life     => shift,       #Maximum life for the particle
    _totLife  => 0,           #Current life, initialised as 0
  };
  return $self;
}

# Update the particle with the selected values
sub updateParticle {
  my ( $self, @pos, $rot, $dir, @color ) = @_;

  $self->{_pos}        = @pos   if defined(@pos  );     #format: [X,Y]
  $self->{_rot}        = $rot   if defined($rot  );
  $self->{_dir}        = $dir   if defined($dir  );
  $self->{_color}      = @color if defined(@color);     #format: [R,G,B,A]
  $self->{_totLife}++
}
  
# Check wether or not a particle is dead
sub isDead {
  my ( $self ) = @_;
  if ($self->{_life} >= $self->{_totLife}){
    return 1;
  }
  else{
    return 0;
  }
}

#Calculate each particle in the system's speed, direction change, etc. etc.
sub updateEmmitter {
  my ( $self ) = @_;
  # check if the aray is full first
  if (!($#{$self->{_parts}} >= $self->{_maxParts})) {
    # Create new particles
    #make sure we don't accidently overflow!
    for (my $i = 0; ($i >= $self->{_freq}) and ($i+ $#{$self->{_parts}} <= ); $i++) {
      # calculate the life, direction, and rotation of the particle
      my $life  = $self->{_life};
      my $dir   = $self->{_dir};
      my $rot   = $self->{_rot};
      # calculate the address of the particle
      my $curOffset = }+$i;
      # create the particle
      ${$self->{_parts}}[$curOffset] = &createParticle(     #I have no idea if I can access an array within a hash like this, or even call functions like this o_o
        $self->{_img},
        [0,0],
        $rot,
        $dir,
        $self->{color},
        $life
      );
    }
  }
  foreach my $i (@{$self->{_parts}}) {
    #Calculate wether or not a particle needs to be refreshed
    if(${$self->{_parts}}[$i]->isDead();) {
      my $life  = $self->{_life};
      my $dir   = $self->{_dir};
      my $rot   = $self->{_rot};
#      ${$self->{_parts}}[$i]->refreshParticle(); #lets put in the refresh/cleanup later and instead just overwrite the particle
       ${$self->{_parts}}[$i] = &createParticle(
        $self->{_img},
        [0,0],
        $rot,
        $dir,
        $self->{color},
        $life
      );
    }
    else {
      #I suppose I should put the speed/distance/lifecolor/etc functionshere
    }
  }
}

#Note, I need to put the renderSystem(); here.
