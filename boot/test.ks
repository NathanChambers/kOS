clearScreen.
copyPath("0:/lib/", "1:/lib/").
copyPath("0:/cmd/", "1:/cmd/").

run once "/lib/commands".

launch(3).

lock throttle to 1.
until ship:altitude > 100.

lock throttle to 0.
until ship:verticalspeed < 0.

lock throttle to atc(constant:g0 - 2.5).

until ship:bounds:bottomaltradar <= 1.
lock throttle to 0.
until throttle <= 0.