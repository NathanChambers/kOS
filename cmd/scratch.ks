declare parameter orbAlt.

run once "1:/lib/utils".
local orbAlt is 100000.

local maxacc is ship:availablethrust / ship:mass.

local orbSMA is (ship:orbit:periapsis + body:radius + body:radius + orbAlt) / 2.
lock targetVel to vis_viva_sma(orbSMA, ship:orbit:periapsis).
local peVel is vis_viva_sma(orbit:semimajoraxis, ship:orbit:periapsis).

local mandv is targetVel - peVel.
local burntime is mandv / maxacc.

until orbit:eta:periapsis <= 60.

lock steering to ship:prograde.

until orbit:eta:periapsis <= burntime/2.

lock targetVel to vis_viva_sma(orbSMA, ship:altitude).
lock shipvel to ship:velocity:orbit:mag.
until shipvel >= targetVel {
    if shipvel + maxacc > targetVel {
        lock throttle to maxacc / (targetVel - shipvel).
    } else {
        lock throttle to 1.
    }
    
}
lock throttle to 0.
wait 1.