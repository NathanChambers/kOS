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
    declare parameter orbitAlt.

    rcs OFF.
    sas OFF.

    lock g to gdrag().
    lock maxAcc to ship:availablethrust / ship:mass.
    local orbitVel is orbV(orbitAlt).

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

        clearscreen.
        print strfmt("VEL:{0} / {1}", list(round(orbitVel, 2), round(ship:velocity:orbit:mag, 2))).
        print strfmt("ALT:{0} / {1}", list(round(orbitAlt, 2), round(ship:altitude, 2))).

        wait (1/30).
    }
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
    lock tti to ship:velocity:surface:mag / max_acc.
    local inRange is 0.

    until ship:velocity:surface:mag <= hoverAlt {
        print "ING:" + (ttg/tti).
        if ttg <= tti {
            set inRange to 1.
        }
        
        if inRange = 1 {
            if(ttg > tti) {
                set throttleCtrl to ((ship:velocity:surface:mag) / max_acc) * (1 / (ttg - tti)).
            } else {
                set throttleCtrl to ((ship:velocity:surface:mag) / max_acc).
            }
        }
    }

    sas ON.
    lock throttle to 0.

    until ship:bounds:bottomaltradar <= 0.
}

function land2 {
    sas OFF.

    lock g to gdrag().
    local acc is ship:availableThrust / ship:mass.
    lock vel to ship:velocity:surface:mag.
    lock radar to ship:bounds:bottomaltradar.

    lock steering to ship:srfretrograde.
    lock throttle to 0.

    lock dir to ship:velocity:surface:normalized.
    lock burntime to (vel / acc).
    lock v0 to 0.5 * (dir * acc) * (burntime ^ 2).
    lock v1 to 0.5 * (ship:up * (g * ship:mass)) * (burntime ^ 2).
    lock v2 to ship:velocity:surface - v0 + v1.

    
    //lock ignAlt to vel + ((g * ship:mass) * (burntime ^ 2)).
    lock ignAlt to vel - ((g * ship:mass) * (burntime ^ 2)).

    until radar <= v2:mag {
        //print "D-" + round(radar - ignAlt).
        print v2:mag.
    }

    print "BURN:" + radar.

    local thrust is acc.
    lock throttle to atc(thrust).

    until vel <= 1 or radar <= 1.

    print "CUT:" + vel + " : " + radar.

    lock throttle to 0.
    sas ON.
}

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

function hof {
    sas OFF.

    declare parameter _alt.
    declare parameter _fromPe is true.
    declare parameter _eta is -1.

    if _eta < 0 {
        set _eta to choose orbit:eta:periapsis if _fromPe = true else orbit:eta:apoapsis.
    }

    local _fromAlt is choose orbit:periapsis if _fromPe = true else orbit:apoapsis.

    local sma is ((body:radius * 2) + (_fromAlt + _alt)) / 2.
    local _toV is vis_viva_sma(sma, _fromAlt).
    local _fromV is vis_viva_alt(_fromAlt).
    local _dV is _toV - _fromV.

    local nd to node(time:seconds + _eta, 0, 0, _dV).
    add nd.

    exec().

    wait 0.5.

    remove nd.
}

function hof_t {
    
    sas OFF.

    declare parameter _ap.
    declare parameter _pe.
    
    if not _ap = _pe {
        if _ap <= _pe or _pe >= _ap {
            local temp is _ap.
            set _ap to _pe.
            set _pe to temp.
        }
    }

    local _fromPE is true.
    if _pe < orbit:periapsis {
        set _fromPE to false.
    }

    hof(choose _pe if _fromPE = true else _ap, _fromPE).
    hof(choose _pe if _fromPE = true else _ap, not _fromPE).
}

function trans {
    declare parameter _to.
    declare parameter _from is body.

    lock toTgt to _to:position - _from:position.
    lock toShip to ship:position - _from:position.
    lock toTgtDot to vectorCrossProduct(toTgt, _from:north:vector).

    local startingOrbit is (_from:radius + ship:altitude).
    local arrivalOrbit is _from:radius + _from:altitudeof(_to:position).
    local transfSMA is (startingOrbit + arrivalOrbit)/2.
    local THoh is 2 * constant:pi * sqrt(transfSMA^3/_from:mu).
    local angVelShip is angVel(startingOrbit, _from).
    local angVelTgt is angVel(arrivalOrbit, _from).
    local phaseAngle is 180 - ((1/2) * (THoh * angVelTgt)).

    lock closing to vectorDotProduct(toShip, toTgtDot) < 0.
    lock angle to choose vectorAngle(toTgt, toShip) if closing else -vectorAngle(toTgt, toShip).

    local delta is angle - phaseAngle.
    if angle < phaseAngle {
        set delta to 360 - (phaseAngle - angle).
    } else if angle < 0 {
        set delta to (phaseAngle + abs(angle)) / abs(angle).
    }

    local tot is delta / angVelShip.
    local gf is (constant:G * _from:mass) / (arrivalOrbit^2).
    local tgtAlt is (sqrt((constant:g * mun:mass)/gf) - _to:radius) / 2.
    local vTransfSMA is (startingOrbit + (arrivalOrbit - tgtAlt))/2.

    local vPark is sqrt(_from:Mu * ( (2/startingOrbit) - (1/startingOrbit) )).
    local vTransfPeri is sqrt(_from:mu * ( (2/startingOrbit) - (1/(vTransfSMA)) )).
    local nd to node(time:seconds + tot, 0, 0, vTransfPeri - vPark).
    add nd.

    exec().

    wait 0.5.
    remove nd.

    until body = _to.

    hof(_to:radius * 2).


    // hof(toAlt, true, tot).

    // until _from = _to.

    // hof(tgtAlt).
}

function geo {
    
    sas OFF.

    local tgt is body:rotationperiod.
    local sma is (body:mu * ((tgt/(constant:pi * 2))^2))^(1/3).
    local _alt is sma - body:radius.

    hof_t(_alt, _alt).
}

function exec {
    rcs ON.
    sas OFF.

    local nd is nextnode.
    print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).

    lock acc to ship:maxthrust/ship:mass.
    local burn_duration to nd:deltav:mag/acc.
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
        set tset to min(nd:deltav:mag/acc, 1).

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

    rcs OFF.
    sas ON.
}