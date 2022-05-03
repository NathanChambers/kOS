run once "/lib/utils".

wait 3.
stage.

sas OFF.

local logPath is "0:logs/data.csv".

lock g to gdrag().
lock maxAcc to ship:availablethrust / ship:mass.
local orbitAlt is 75000.
local throttleCtrl is 1.

lock dt to (ship:apoapsis + ship:verticalspeed) / orbitAlt.
lock aoaCtrl to 90 * (1 - dt).

lock throttle to throttleCtrl.
lock steering to heading(90, aoaCtrl).
lock velRef to ship:velocity:surface.

local aoaPID is pidLoop(1, 1e-5, 0.2, -g, g).
set aoaPID:setpoint to 0.

until ship:velocity:surface:mag > 10.

local orbital is false.

log strfmt("{0}, {1}", list(orbitAlt, orbV(orbitAlt))) to logPath.

until ship:apoapsis > orbitAlt {
    set aoaPID:setpoint to aoaCtrl.

    if ship:stagedeltav(ship:stagenum):current <= 0 {
        wait 0.5.
        stage.
    }

    if orbital = false and vectorAngle(ship:velocity:orbit, ship:facing:forevector) < 1 {
        lock velRef to ship:velocity:orbit.
        set orbital to true.
    }

    local aoaVel is 90 - vectorAngle(ship:up:vector, velRef).
    local aoaThrottle is aoaPID:update(time:seconds, aoaVel).

    set throttleCtrl to atc((maxAcc * (1-dt)) + aoaThrottle) * (1 - ship:q).
    print strfmt("[ORB:{0}} {1} : {2} : {3} : {4}", list(orbital, round(aoaCtrl), round(aoaVel), aoaPID:output, aoaPID:error)).

    log strfmt("{0}, {1}, {2}", list(ship:altitude, ship:velocity:orbit:mag, throttle)) to logPath.

    wait (1/30).
}

set throttleCtrl to 0.

wait 3.
