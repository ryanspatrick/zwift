#!/bin/bash

#curl -sS --compressed -X GET https://us-or-rly101.zwift.com/api/public/events/upcoming | json_xs -f json -t json-pretty > ~/zwift.json
cat ~/zwift.json | json_xs -f json -t none -e 'use Time::Piece; my $now = localtime; printf "<html>\n<head><title>Group Rides with a Pace Under 1.5W/Kg or 30km/h (20mi/h)</title></head>\n<tt>All times are %s</tt>\n<table>\n<tr><td><tt>Low Pace</tt></td><td><tt>High Pace</tt></td><td><tt>Kilometers</tt></td><td><tt>Minutes</tt></td><td><tt>Laps</tt></td><td><tt>Link</tt></td>" , $now->strftime( "UTC%z (%Z)" ); EVENT:for my $event(@{$_}){ if( $event->{"sport"} eq "RUNNING" || $event->{"eventType"} ne "GROUP_RIDE" ){ next; } my $t = Time::Piece->strptime( substr( $event->{"eventStart"} , 0 , -9 ) , "%Y-%m-%dT%H:%M:%S" ); $t = $t + $now->tzoffset; for my $group(@{$event->{"eventSubgroups"}}){ if( ( $group->{"paceType"} eq 1 && ( $group->{"toPaceValue"} > 1.5 || $group->{"toPaceValue"} == 0 ) ) || ( $group->{"paceType"} eq 2 && $group->{"toPaceValue"} > 30 ) ){ next; }; printf "<tr>\n<td style=\"text-align:right\"><tt>%.1f</tt></td><td style=\"text-align:right\"><tt>%.1f</tt></td><td style=\"text-align:right\"><tt>% 7.2f</tt></td>\n<td style=\"text-align:right\"><tt>% 4d</tt></td>\n<td style=\"text-align:right\"><tt>% 4d</tt></td>\n<td><tt><a href=\"https://www.zwift.com/events/view/%d\">%-35s %s</a></tt></td>\n" , $group->{"fromPaceValue"} , $group->{"toPaceValue"} , $event->{"distanceInMeters"} / 1000 ,  $event->{"durationInSeconds"} / 60 , $event->{"laps"} , $event->{"id"} , $t->strftime( "%Y-%m-%d %H:%M:%S %A" ) , $group->{"name"}; } }; printf "</table>\n</html>\n";' 1> ~/pace.html 2> /dev/null

if [ -s ~/pace.html ]
then
    sudo cp ~/pace.html /var/www/html/
fi
