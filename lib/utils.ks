@lazyglobal off.

function getVivV {
    declare parameter _ap.
    declare parameter _pe.
    local _a is (body:radius + _ap + body:radius + _pe) / 2.
    return sqrt(body:mu * ((2/(body:radius+_pe)) - (1/_a))).
}.

function gdrag {
    return (body:mu * ship:mass) / ((body:radius + ship:altitude)^2).
}

function atc {
    declare parameter _a.
    return choose (ship:mass * _a) / ship:availablethrust if ship:availableThrust > 0 else 0.
}