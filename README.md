# IRCBot-IRCBOT-Randomizer-Chat-Bot-
CONTENTS OF THIS FILE
---------------------
 * Current Stable Version   
 * Introduction
 * Requirements
 * Installation
 * Configuration
 * Troubleshooting
 * FAQ
 * Maintainers
 
CURRENT STABLE VERSION
----------------------
Current Version is: IRCBot Boga.

INTRODUCTION
------------
An IRC bot intended for RPG use.
The name is a throughly contrived recursive acronym.

This is a simple PERL script that processes IRC chat commands.  
The initial intent is to generate numbers to simulate the rolling of dice in RPGs.
Based on (taken almost completely from) http://archive.oreilly.com/pub/h/1964.

REQUIREMENTS
------------
IO::Socket

INSTALLATION
------------
Place IRCBot.pl in an appropriate directory.

CONFIGURATION
-------------
Set appropriate values for $server, $port, $channel, $nick, and $login.

TROUBLESHOOTING
---------------
No common troubleshooting exists as of yet.

FAQ
---
No questions at all as of yet.

MAINTAINERS
-----------
kbpickens https://github.com/kbpickens

TODO
----
* Add a shortcut for rolling D&D 5e's (dis-)advantage rolls.
* Expand to allow easy modification by users.
* Add command line options. [added: Boga]
* Add Fudge dice [added: Boga]
* Add exploding dice (roll maximum, add additional die). [added: Boga]
* Add success count rolling. [added: Boga]
    * Add old WoD botch mechanics. [added: Boga]
    * Add 10-/9-/8-again mechanics.
* Add help responder.
* Add roll and keep. [added: Capelin]
* Add quit command.
