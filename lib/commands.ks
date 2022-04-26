@lazyglobal off.

run once "/lib/utils".

function launch {
    declare parameter _d is 10.
    from {local _t is _d.} until _t = 0 step {set _t to _t - 1.} do {
        print "T-" + _t.
        wait 1.
    }

    rcs OFF.
    sas OFF.
    stage.
}

function lko {
    declare parameter _alt.

    rcs OFF.
    sas OFF.

    lock aoa to 90 * (1 - (ship:apoapsis / _alt)).

    lock steering to heading(90,90).
    local throttleCtrl is 1.
    lock throttle to throttleCtrl.

    
    until ship:velocity:surface:mag >= 10.
    lock steering to heading(90,aoa).

    until ceiling(ship:apoapsis, 0) >= _alt {
        if ship:stagedeltav(ship:stagenum):current <= 0 {
            wait 0.5.
            stage.
        }

        local apoExp is 30/SHIP:OBT:ETA:APOAPSIS.
        if ship:altitude > 100 {
            if apoExp < 1 {
                set throttleCtrl to max((1/(SHIP:OBT:ETA:APOAPSIS - 30)), 0.01).
            }
        }
    }

    lock steering to ship:prograde.
    lock throttle to 0.
}

function land {
    rcs OFF.
    sas OFF.

    lock steering to ship:SRFRETROGRADE.

    local throttleCtrl is 0.
    lock throttle to throttleCtrl.
    local hoverAlt is 0.5.

    local max_acc is ship:maxthrust/ship:mass.
    lock ttg to (ship:bounds:bottomaltradar + hoverAlt) / max(abs(ship:verticalSpeed), 1).
    lock ttz to ship:velocity:surface:mag / max_acc.
    local inRange is 0.

    until ship:velocity:surface:mag <= hoverAlt {
        print "ING:" + (ttg/ttz).
        if ttg <= ttz {
            set inRange to 1.
        }
        
        if inRange = 1 {
            if(ttg > ttz) {
                set throttleCtrl to ((ship:velocity:surface:mag) / max_acc) * (1 / (ttg - ttz)).
            } else {
                set throttleCtrl to ((ship:velocity:surface:mag) / max_acc).
            }
        }
    }

    sas ON.
    lock throttle to 0.

    until ship:bounds:bottomaltradar <= 0.
}

function period {
    rcs OFF.
    sas OFF.

    declare parameter _arc.

    local p is ship:orbit:period - ((ship:orbit:period / 180) * _arc).
    print "orbital adj: " + (ship:orbit:period - p).

    local sma is (body:mu * ((p/(constant:pi * 2)) ^ 2)) ^ (1/3).
    local apo is orbit:apoapsis - (orbit:semimajoraxis - sma).
    local peri is orbit:periapsis.

    local v0 is getVivV(orbit:apoapsis, orbit:periapsis).
    print v0.

    local v1 is getVivV(apo, peri).
    print v1.

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

function exec {
    rcs OFF.
    sas OFF.

    local nd is nextnode.
    print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).

    lock max_acc to ship:maxthrust/ship:mass.
    local burn_duration to nd:deltav:mag/max_acc.
    print "Crude Estimated burn duration: " + round(burn_duration) + "s".

    wait until nd:eta <= (burn_duration/2 + 60).

    local np to nd:deltav.
    lock steering to np.

    wait until vang(np, ship:facing:vector) < 0.25.


    wait until nd:eta <= (burn_duration/2).


    local tset to 0.
    lock throttle to tset.

    local done to False.

    local dv0 to nd:deltav.
    until done
    {
        set tset to min(nd:deltav:mag/max_acc, 1).

        if vdot(dv0, nd:deltav) < 0
        {
            print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            lock throttle to 0.
            break.
        }

        if nd:deltav:mag < 0.1
        {
            print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            wait until vdot(dv0, nd:deltav) < 0.5.

            lock throttle to 0.
            print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            set done to True.
        }
    }

    unlock steering.
    unlock throttle.
    wait 1.

    remove nd.

    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}