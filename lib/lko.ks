run once "0:/lib/utils".

function lko {
    declare parameter orbitAlt.
    declare parameter orbitInc.

    rcs OFF.
    sas OFF.

    lock g to gdrag().
    lock maxAcc to ship:availablethrust / ship:mass.
    local orbitVel is orbV(orbitAlt).

    local throttleCtrl is 1.

    lock dt to (ship:apoapsis + ship:verticalspeed) / orbitAlt.
    lock aoaCtrl to 90 * (1 - dt).

    lock throttle to throttleCtrl.
    lock steering to heading(90 + orbitInc, aoaCtrl, 180).
    lock velRef to choose ship:velocity:surface if NAVMODE = "SURFACE" else ship:velocity:orbit.

    local aoaPID is pidLoop(1, 1e-5, 0.2, -g, g).
    set aoaPID:setpoint to 0.

    until ship:velocity:surface:mag > 10.

    until ship:apoapsis > orbitAlt {
        set aoaPID:setpoint to aoaCtrl.

        if ship:stagedeltav(ship:stagenum):current <= 0 {
            wait 0.5.
            stage.
        }

        local aoaVel is 90 - vectorAngle(ship:up:vector, velRef).
        local aoaThrottle is aoaPID:update(time:seconds, aoaVel).

        set throttleCtrl to atc((maxAcc * (1-dt)) + aoaThrottle) * (1 - ship:q).

        wait (1/30).
    }
}