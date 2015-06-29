#!/usr/local/bin/perl -w
# IRCBot.pl
# IRCBot (IRCBot Randomizer Chat Bot).
# Usage: perl IRCBot.pl
# Currently Copyright 2015 Kevin Pickens.  Licensing is being sorted out.  
# You are granted a non-exclusive license to use, and/or modify this program as you see fit for any purpose.  
# You are granted a non-exclusive license to distribute this program for profit or not for profit as long as this header is included and any derivative is distributed under the same conditions.
# This bot is based on http://archive.oreilly.com/pub/h/1964.  Any restrictions put in place by that source supercede any permissions granted by this 
use strict;

# We will use a raw socket to connect to the IRC server.
use IO::Socket;
use Data::Dumper;

# The server to connect to and our details.
my $server = "irc.server.somewhere";
# The port for the server.
my $port = 6665;

my $time=time;
# The channel which the bot will join.
my $channel = "#IRCBot$time";
# A semi-random IRC nick.
my $nick = "IRCBot$time";
# After testing, $login should be changed to a set value.
my $login = $nick;


# Connect to the IRC server.
my $sock = new IO::Socket::INET(PeerAddr => $server,
                                PeerPort => $port,
                                Proto => 'tcp') or
                                    die "Can't connect\n";

# Log on to the server.
print $sock "NICK $nick\r\n";
print $sock "USER $login 8 * :IRCBot (IRCBOT-Randomizer-Chat-Bot)\r\n";

# Log on to the server.
print $sock "NICK $nick\r\n";
print $sock "USER $login 8 * :RTC Bot (CONNECTION TEST)\r\n";

# Read lines from the server until it tells us we have connected.
while (my $input = <$sock>) {
  # Check the numerical responses from the server.
  if ($input =~ /004/) {
    # We are now logged in.
    last;
  } elsif ($input =~ /433/) {
    die "Nickname is already in use.";
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
    # This is the whole point of the bot.
    my $msg = $input;
    $msg =~ s/[\r]//;
    my $roller=$msg;
    $roller =~ s/^:([^!]*)!.*/$1/;
    my $dice = $msg;
    my $response = "rolled";
    while ($dice =~ m/(\d+)[dD](\d+)([\+-]\d+)?/g) {
      $response.= " [$1d$2$3]=";
      $response.= roll($1,$2,$3);
    }
    $msg =~ s/^.*[: ]rolls ([^\r\n]*).*$/PRIVMSG $channel :$roller $response/i;
    print "$msg\n\n";
    print $sock "$msg\r\n";
  } else {
    # Print the raw line received by the bot.
    print "$input\n";
  }
}

sub roll {
  my ($dice,$sides,$bonus)=@_;
  my $each=int(rand($sides)+1);
  my $total=$each+$bonus;
  my $return="(";
  $return.=$each;
  for (my $i=1;$i<$dice;$i++) {
    $each=int(rand($sides)+1);
    $return.=", ".$each;
    $total+=$each;
  }
  $return.=")$bonus=$total";
  return $return;
}
