clearScreen.
copyPath("0:/lib/", "1:/lib/").
copyPath("0:/cmd/", "1:/cmd/").

run once "/lib/commands".
run once "/lib/utils".

launch(3).
local _tgtAlt is 75000.
local _tgtV is vis_viva(_tgtAlt, _tgtAlt).

lock _maxAcc to ship:maxthrust/ship:mass.
lock _vel to ship:velocity:orbit:mag.
//lock _angleCtrl to 1 - (((ship:velocity:orbit:mag / _tgtV) + (ship:apoapsis / _tgtAlt)) * 0.5).

lock _angleCtrl to 1 - (ship:apoapsis / _tgtAlt).
// lock throttle to 1.
lock steering to heading(90,90 * _angleCtrl).

// until ship:velocity:surface:mag > 10.


lock g to (constant:G * body:mass) / ((body:radius + ship:altitude)^2).

lock throttle to atc(g).

until _vel >= _tgtV {
    print g.
}