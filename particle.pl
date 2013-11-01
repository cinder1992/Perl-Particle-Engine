#!/usr/bin/perl
use strict;
use warnings;
use SDL;
use SDLx::App;
use SDLx::Surface;
use SDL::Image;
use SDL::Rect;
use SDL::Event;
use SDLx::Text;
use partEngine::particle;
use constant SCREEN_W => 1024;
use constant SCREEN_H => 768;
my ($exiting, $time, $srcRect, $dstRect, $sprite, @particles, $event, @mouse, $colRect, $spawn);

my $app = SDLx::App->new(   #Create Window
  w => SCREEN_W,
  h => SCREEN_H,
  d => 32,
  title => "I'm a particle!",
  exit_on_quit => 1
);

$sprite = SDL::Image::load( 'spark.png' ) or die("Could not load image!"); #load the particle image
$srcRect = SDL::Rect->new(0,0,10,10); #define our rectangles
$dstRect = SDL::Rect->new(0,0,10,10); 
$colRect = SDL::Rect->new(200, 500, 400, 10);     #Define our hitbox
$spawn = 1;                                       #Make sure we have SOMETHING to process
$exiting = 0;
$event=SDL::Event->new();    # create one global event
@mouse = (0,0);
my $text = SDLx::Text->new;

while (!$exiting) {
  $time = SDL::get_ticks();           #Get our current running time in seconds
  if (($spawn)) {                              #first iteration?
    foreach my $i (0..100) {                 #Lets make 101 particles!
      my $velX = int(rand(200)-100);         #X-velocity randomiser
      my $velY = int(rand(400)-200);         #Y velocity randomiser
      my $x = $mouse[0];
      my $y = $mouse[1];
      $particles[$i] = particle->new([$velX,$velY], [$x, $y], $sprite, 500, $time, -2);
    }
    $spawn = 0;                            #This is no longer the first iteration
  }
  else {
    foreach my $i (0 .. $#particles) {          #go through ALL the particles!
      my $curTime = ($time - $particles[$i]->{_spawnTime}) / 1000; #Calculate the time difference between the original "Spawn Time" and the current time
      my $bounce = &hitSomething($i);        # Did we hit something?
      if ($bounce) {
        if (!$particles[$i]->{_inside}){   # Are we still inside the hitbox?
          $particles[$i]->{_vel}[1] = $particles[$i]->{_vel}[1] / $particles[$i]->{_coef};  #Calculate the coefficient of restitution
          if ($particles[$i]->{_vel}[1] >= -0.5) {            #are we below the threshhold velocity?
            $particles[$i]->{_vel}[1] = 0;
          }
        }
      }
      else {
        $particles[$i]->{_vel}[1] += $particles[$i]->{_grav}*$curTime;             #V = u + at
      }
      $particles[$i]->{_pos}[1] += $particles[$i]->{_vel}[1]*$curTime;           #S = vt
      $particles[$i]->{_pos}[0] += $particles[$i]->{_vel}[0]*$curTime;           #X velocity is constant... 
      if($bounce){                                                     #We're not inside, are we?
        $particles[$i]->{_inside} = 1;
      }
      else {
        $particles[$i]->{_inside} = 0;
      }
      $particles[$i]->{_spawnTime} = $time;   #Reset our timing for the next set of calculations
      $dstRect->x($particles[$i]->{_pos}[0]); #Set the destination rectangle's X position
      $dstRect->y($particles[$i]->{_pos}[1]); #same as above, except for Y.
      $app->blit_by( $particles[$i]->{_img}, $srcRect, $dstRect ); #Blit the particle to the surface
    }
  }
  $app->draw_rect( $colRect, [255,255,255,255] );      #render colision rectangle
  my $frametime = SDL::get_ticks() - $time;
  my $FPS = 0;
  if ($frametime) { $FPS = 1000 / $frametime; }
  $app->update(); #Render render render!
  $app->draw_rect([0, 0, SCREEN_W, SCREEN_H], [0, 0, 0, 255]); #
  $text->write_to( $app, "$FPS" );
  &handleEvents();
}
sub hitSomething {
  my $i = shift(@_);
  if (($particles[$i]->{_pos}[1] + 5 >= $colRect->y) 
  and ($particles[$i]->{_pos}[1] + 5<= $colRect->y + $colRect->h) 
  and ($particles[$i]->{_pos}[0] + 5 >= $colRect->x)
  and ($particles[$i]->{_pos}[0] + 5 <= $colRect->x + $colRect->w)){ #Did we hit something?
    return 1;
  }
  else{
    return 0;
  }
}
sub mouseEvent {
  my($mouse_mask, $mouse_x, $mouse_y) = @{SDL::Events::get_mouse_state()};
  @mouse = ($mouse_x, $mouse_y);
}

sub quitEvent {
  exit;
}
sub handleEvents {
  SDL::Events::pump_events();
  while(SDL::Events::poll_event($event)) {
    if($event->type == SDL_QUIT) {
      &quitEvent();
    }
    elsif($event->type == SDL_MOUSEBUTTONDOWN)
    {
      &mouseEvent($event);
      $spawn = 1
    }
  }
}

