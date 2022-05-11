run once "0:/lib/utils".
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