run once "0:/lib/utils".

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