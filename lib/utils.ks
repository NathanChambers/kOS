@lazyglobal off.

function vis_viva {
    declare parameter _ap.
    declare parameter _pe.
    local _a is (body:radius + _ap + body:radius + _pe) / 2.
    return sqrt(body:mu * ((2/(body:radius+_pe)) - (1/_a))).
}.

function vis_viva_alt {
    declare parameter _alt.
    return sqrt(body:mu * ((2/(body:radius+_alt)) - (1/orbit:semimajoraxis))).
}.

function vis_viva_sma {
    declare parameter _sma.
    declare parameter _alt.
    return sqrt(body:mu * ((2/(body:radius+_alt)) - (1/_sma))).
}.

function gdrag {
    return (body:mu * ship:mass) / ((body:radius + ship:altitude)^2).
}

function gforce {
    return (constant:G * body:mass) / ((body:radius + ship:altitude)^2).
}

function atc {
    declare parameter _a.
    return choose (ship:mass * _a) / ship:availablethrust if ship:availableThrust > 0 else 0.
}

function twrToAcc {
    declare parameter _twr.
    return _twr * constant:g0 * ship:mass.
}

function angVel {
    declare parameter _sma.
    declare parameter _body is body.
    return (360/(2 * constant:pi)) * sqrt(_body:mu/(_sma^3)).
}

function hohTransferTime {
    declare parameter _transfSMA.
    declare parameter _body is body.
    return 2 * constant:pi * sqrt(_transfSMA^3/_body:mu).
}

function timeTravel {
    declare parameter _time.
    kuniverse:timewarp:warpto(time:seconds + _time).
}