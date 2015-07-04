#!/usr/bin/perl -w
# IRCBot (IRCBot Randomizer Chat Bot). v. Boga
#    Copyright (C) 2015 Kevin Pickens
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# IRCBot.pl
# Usage: perl IRCBot.pl

use strict;

# We will use a raw socket to connect to the IRC server.
use IO::Socket;

# The server to connect to and our details.
my $server = "irc.freenode.net";
# The port for the server.
my $port = 6665;

my $time=time;
# The channel which the bot will join.
my $channel = "#IRCBot$time";
# A semi-random IRC nick.
my $nick = "IRCBot$time";
# After testing, $login should be changed to a set value.
my $login = $nick;

print "Joining $channel.\n\n\n";

# Connect to the IRC server.
my $sock = new IO::Socket::INET(PeerAddr => $server,
                                PeerPort => $port,
                                Proto => 'tcp') or
                                    die "Can't connect\n";

# Log on to the server.
print $sock "NICK $nick\r\n";
print $sock "USER $login 8 * :IRCBot (IRCBOT-Randomizer-Chat-Bot)\r\n";

# Read lines from the server until it tells us we have connected.
while (my $input = <$sock>) {
  # Check the numerical responses from the server.
  if ($input =~ /004/) {
    # We are now logged in.
    last;
  } elsif ($input =~ /433/) {
    # Someone else is using the desired nickname, quit and let the user rerun later.
    die "Nickname is already in use.\r\n";
  }
}

# Join the channel.
print $sock "JOIN $channel\r\n";

# Keep reading lines from the server.
while (my $input = <$sock>) {
  chop $input;
  if ($input =~ /^PING(.*)$/i) {
    # We must respond to PINGs to avoid being disconnected.
    print $sock "PONG $1\r\n";
  } elsif ($input =~ /.*[: ]rolls [^\r\n]*.*$/i) {
    # I was having problems with a CR fouling up some regexes.
    $input =~ s/[\r]//;
    # This is the whole point of the bot.
    my $msg = $input;
    # Identify the NICK of the individual asking for dice rolls.
    my $roller=$msg;
    $roller =~ s/^:([^!]*)!.*/$1/;
    # Identify all dice combinations and roll them.
    my $dice = $msg;
    my $response = "rolled";
    while ($dice =~ m/(\d+)[dD](\d+)(([\+-bBkK])(\d+)([bB])?)?/g) {
      $response.= " [$1d$2$3]=";
      if($4 eq 'b'||$4 eq 'B') {
	if($6 eq 'b'||$6 eq 'B'){
          $response.=rollbeat($1,$2,$5,1);
        } else {
          $response.=rollbeat($1,$2,$5,0);
        }
      }elsif($4 eq 'k'||$4 eq 'K'){
        $response.=rollkeep($1,$2,$5,1);
      } else {
        $response.= roll($1,$2, $3);
      }
    }
    while ($dice =~ m/(\d+)[xX](\d+)/g) {
      $response.= " [$1d$2 (exploding)]=";
      $response.= rollexplode($1,$2);
    }
    while ($dice =~ m/(\d+)[dD][fF]/g) {
      $response.= " [$1dF]=";
      $response.= rollfudge($1);
    }
    # Assemble response string.  Why did I do it this way?!  I think it was part of the initial testing.
    $msg =~ s/^.*[: ]rolls ([^\r\n]*).*$/PRIVMSG $channel :$roller $response/i;
    print "$msg\n\n";
    print $sock "$msg\r\n";
  } else {
    # Print the raw line received by the bot.  I've left this for sanity testing by end-users to make sure it doesn't break the hosting IRCd.
    print "$input\n";
  }
}

# Subroutine to roll the dice.
#****f* roll
# FUNCTION
#   Rolls a given die/dice combination.
# SYNOPSIS
sub roll 
# INPUTS
#   $dice -- the number of dice to roll
#   $sides -- the number of sides per die
#   $bonus -- any modifier to the roll positive or negative
# SOURCE
{
  # Set all of the parts of a roll.
  my ($dice,$sides,$bonus)=@_;
  # Roll the first die.
  my $each=int(rand($sides)+1);
  # Begin adding the rolls and the bonus (or penalty).
  my $total=$each+$bonus;
  # Begin building the result string.
  my $return="(".$each;
  # Roll all of the remaining dice.
  for (my $i=1;$i<$dice;$i++) {
    $each=int(rand($sides)+1);
    $return.=", ".$each;
    $total+=$each;
  }
  # Finish the result string.
  $return.=")$bonus=$total";
  return $return;
}
#****
#****f* rollbeat
# FUNCTION
#   Rolls a given die/dice combination.
# SYNOPSIS
sub rollbeat
# INPUTS
#   $dice -- the number of dice to roll
#   $sides -- the number of sides per die
#   $target -- number to beat
#   $botches -- whether 1s offset successes
# SOURCE
{
  # Set all of the parts of a roll.
  my ($dice,$sides,$target,$botches)=@_;
  # Roll the first die.
  my $each=int(rand($sides)+1);
  # Begin adding the rolls and the bonus (or penalty).
  my $total=0;
  $total=($each>=$target?1:0);
  print "$each / $total\n";
  if($botches){$total=($each==1?$total-1:$total);}
  # Begin building the result string.
  my $return="(".$each;
	$return.=($each>=$target?"+":"");
  if($botches){$return.=($each==1?"-":"");}
  # Roll all of the remaining dice.
  for (my $i=1;$i<$dice;$i++) {
    $each=int(rand($sides)+1);
    $return.=", ".$each;
	$return.=($each>=$target?"+":"");
	if($botches){$return.=($each==1?"-":"");}
    $total+=($each>=$target?1:0);
  #print "$each / $total\n";
    if($botches){$total=($each==1?$total-1:$total);}
  }
  # Finish the result string.
  $return.=")=$total successes";
  return $return;
}
#****


#****f* rollexplode
# FUNCTION
#   Rolls a given exploding die/dice combination.
# SYNOPSIS
sub rollexplode
# INPUTS
#   $dice -- the number of dice to roll
#   $sides -- the number of sides per die
# SOURCE
{
  # Set all of the parts of a roll.
  my ($dice,$sides)=@_;
  # Begin adding the rolls.
  my $total=0;
  # Begin building the result string.
  my $return="(";
  # Roll all of the dice.
  for (my $i=1;$i<=$dice;$i++) {
  my $dieroll=int(rand($sides)+1);
  my $each=$dieroll;
  while ($dieroll==$sides) {
	$dieroll=int(rand($sides)+1);
	$each+=$dieroll;
  }
  $return.=$i>1?", ":"".$each;
  if($each>=$sides){
	$return.="*";
  }
  $total+=$each;
  }
  # Finish the result string.
  $return.=")=$total";
  return $return;
}
#****

#****f* rollfudge
# FUNCTION
#   Rolls a given Fudge die/dice combination.
# SYNOPSIS
sub rollfudge
# INPUTS
#   $dice -- the number of dice to roll
# SOURCE
{
  # Set all of the parts of a roll.
  my ($dice)=@_;
  # Define sides.
  my @sides=('-','=','+');
  # Roll the first die.
  my $each=int(rand(3));
  # Begin adding the rolls and the bonus (or penalty).
  my $total=$each;
  # Begin building the result string.
  my $return="(".$sides[$each];
  # Roll all of the remaining dice.
  for (my $i=1;$i<$dice;$i++) {
    $each=int(rand(3));
    $return.=", ".$sides[$each];
    $total+=$each;
  }
  # Finish the result string.
  $total-=$dice;
  my $plus=$total>0?'+':'';
  $return.=")=$plus$total levels";
  return $return;
}
#****

#****f* rollkeep
# FUNCTION
#   Rolls a given die/dice combination.
# SYNOPSIS
sub rollkeep
# INPUTS
#   $dice -- the number of dice to roll
#   $sides -- the number of sides per die
#   $keep -- the number of rolled dice to keep
#   $high -- whether to keep high or low rolls
# SOURCE
{
  # Set all of the parts of a roll.
  my ($dice,$sides,$keep,$high)=@_;
  # Roll the first die.
  my $each=int(rand($sides)+1);
  # Roll all of the remaining dice.
  my @rolls=($each);
  for (my $i=1;$i<$dice;$i++) {
    $each=int(rand($sides)+1);
	push @rolls, $each;
  }
  my $total=0;
  my $return="(";
  my @sorted;
  if($high){
    @sorted = sort {$b <=> $a} @rolls;
  } else {
    @sorted = sort {$a <=> $b} @rolls;
  }
  for (my $i=0;$i<$dice;$i++) {
	if($i>0){
	  $return.=", "
	}
	$return.=$sorted[$i];
	if($i<$keep){
	  $total+=$sorted[$i];
	  $return.="k";
	}
print "$return\n";
  }
  # Finish the result string.
  $return.=")=$total";
  return $return;
}
#****

