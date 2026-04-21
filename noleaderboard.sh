#!/bin/bash

#curl -sS --compressed -X GET https://us-or-rly101.zwift.com/api/public/events/upcoming | json_xs -f json -t json-pretty > ~/zwift.json
cat ~/zwift.json | json_xs -f json -t none -e 'use Time::Piece; my $now = localtime; printf "<html>\n<head><title>No Leaderboard Group Rides</title></head>\n<tt>All times are %s</tt>\n<table>\n<tr><td><tt>Kilometers</tt></td><td><tt>Minutes</tt></td><td><tt>Laps</tt></td><td><tt>Activity</tt></td><td><tt>Link</tt></td>" , $now->strftime( "UTC%z (%Z)" ); EVENT: for my $event(@{$_}){ if( $event->{"eventType"} ne "GROUP_RIDE" ){ next; }; for my $rule( @{$event->{"rulesSet"}} ){ if( $rule eq "SHOW_RACE_RESULTS" ){ next EVENT; }; }; my $t = Time::Piece->strptime( substr( $event->{"eventStart"} , 0 , -9 ) , "%Y-%m-%dT%H:%M:%S" ); $t = $t + $now->tzoffset; printf "<tr>\n<td style=\"text-align:right\"><tt>% 7.2f</tt></td>\n<td style=\"text-align:right\"><tt>% 4d</tt></td>\n<td style=\"text-align:right\"><tt>% 4d</tt></td>\n<td><tt>%s %s</tt></td>\n<td><tt><a href=\"https://www.zwift.com/events/view/%d\">%-35s %s</a></tt></td>\n" , $event->{"distanceInMeters"} / 1000 ,  $event->{"durationInSeconds"} / 60 , $event->{"laps"} , $event->{"sport"} , $event->{"eventType"} , $event->{"id"} , $t->strftime( "%Y-%m-%d %H:%M:%S %A" ) , $event->{"name"} }; printf "</table>\n</html>\n";' 1> ~/noleaderboard.html 2> /dev/null

if [ -s ~/noleaderboard.html ]
then
    sudo cp ~/noleaderboard.html /var/www/html/
fi
