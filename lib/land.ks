run once "0:/lib/utils".

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

////////////////////////////////////////////////////////////////////////////////

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