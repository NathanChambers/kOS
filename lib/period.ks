run once "0:/lib/utils".

function period {
    sas OFF.

    declare parameter _arc.

    local p is ship:orbit:period - ((ship:orbit:period / 180) * _arc).
    print "orbital adj: " + (ship:orbit:period - p).

    local sma is (body:mu * ((p/(constant:pi * 2)) ^ 2)) ^ (1/3).
    local apo is orbit:apoapsis - (orbit:semimajoraxis - sma).
    local peri is orbit:periapsis.

    local v0 is vis_viva(orbit:apoapsis, orbit:periapsis).
    local v1 is vis_viva(apo, peri).

    local diff is v1 - v0.
    print diff.

    local start is ship:orbit:periapsis.

    local man0 to node(time:seconds + SHIP:OBT:ETA:periapsis, 0, 0, diff).
    add man0.

    exec().

    wait 2.

    if abs(start - ship:obt:periapsis) < abs(start - ship:obt:apoapsis) {
        local man1 to node(time:seconds + SHIP:OBT:ETA:periapsis, 0, 0, -diff).
        add man1.
    } else {
        local man1 to node(time:seconds + SHIP:OBT:ETA:apoapsis, 0, 0, -diff).
        add man1.
    }

    exec().
}