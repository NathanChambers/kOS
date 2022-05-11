run once "0:/lib/utils".

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