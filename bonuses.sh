#!/bin/bash

#wget -q -O ~/zwift.json http://us-or-rly101.zwift.com/api/public/events/upcoming
cat ~/zwift.json | json_xs -f json -t json-pretty > ~/zwift.temp
mv ~/zwift.temp ~/zwift.json
cat ~/zwift.json | json_xs -f json -t none -e 'use Time::Piece; my $now = localtime; printf "<html>\n<head><title>Bonus XP Events</title></head>\n<tt>All times are %s</tt>\n<table>\n<tr><td><tt>Kilometers</tt></td><td><tt>Minutes</tt></td><td><tt>Laps</tt></td><td><tt>Activity</tt></td><td><tt>Link</tt></td>" , $now->strftime( "UTC%z (%Z)" ); EVENT: for my $event(@{$_}){ for my $group( @{$event->{"eventSubgroups"}} ){ for my $rule( @{$group->{"tags"}} ){ if( $rule =~ m/powerup.percent.*[^0-9]3,[0-9]/ || $rule =~ m/arch.powerup.*,3[^0-9]/ ){ my $t = Time::Piece->strptime( $event->{"eventStart"} , "%Y-%m-%dT%H:%M:%S.000%z" ); $t = $t + $now->tzoffset; printf "<tr>\n<td style=\"text-align:right\"><tt>% 7.2f</tt></td>\n<td style=\"text-align:right\"><tt>% 4d</tt></td>\n<td style=\"text-align:right\"><tt>% 4d</tt></td><td><tt>%s %s</tt></td><td><tt><a href=\"https://www.zwift.com/events/view/%d\">%-35s %s %s</a></tt></td>\n" , $group->{"distanceInMeters"} / 1000 , $group->{"durationInSeconds"} / 60 , $group->{"laps"} , $event->{"sport"} , $event->{"eventType"} , $event->{"id"} , $t->strftime( "%Y-%m-%d %H:%M:%S %A" ) , $event->{"name"} , $rule; next EVENT; }}};} printf "</table>\n</html>\n";' 1> ~/bonuses.html #2> /dev/null

sudo cp ~/bonuses.html /var/www/html/
sudo chmod a+r /var/www/html/bonuses.html
