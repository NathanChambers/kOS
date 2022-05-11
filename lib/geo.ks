run once "0:/lib/utils".
function geo {
    
    sas OFF.

    local tgt is body:rotationperiod.
    local sma is (body:mu * ((tgt/(constant:pi * 2))^2))^(1/3).
    local _alt is sma - body:radius.

    hof_t(_alt, _alt).
}