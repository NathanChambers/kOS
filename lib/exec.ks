run once "0:/lib/utils".

function exec {
    function flow {
        list engines in elist.
        for eng in elist {
            if(eng:ignition = true) {
                return (eng:massflow / eng:maxmassflow).
            }
        }
        return 0.
    }

    sas off.
    rcs off.

    local nd is nextnode.
    lock maxacc to ship:availablethrust / ship:mass.
    local burntime is nd:deltav:mag / maxacc.

    lock steering to nd:deltav.

    until nd:eta <= (burntime / 2).

    local throttlePID is pidLoop(0.9, 1e-5, 1e-5, 0, maxacc).

    local lastdv is nd:deltav:mag.
    until false {
        if(lastdv < nd:deltav:mag) {
            break.
        }
        set lastdv to nd:deltav:mag.

        set throttlePID:setpoint to nd:deltav:mag.
        local acc is throttlePID:update(time:seconds, maxacc * flow()).
        lock throttle to atc(acc).
        wait 1/30.

        if(vectorAngle(nd:deltav, ship:facing:forevector) > 0.25) {
            unlock steering.
        }
    }

    print nd:deltav:mag.

    unlock steering.
    unlock throttle.

    set ship:control:pilotmainthrottle to 0.

    sas on.

    wait 0.5.

    remove nd.
}