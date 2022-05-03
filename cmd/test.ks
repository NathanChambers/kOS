lock cross to vectorCrossProduct(ship:up:vector, ship:facing:forevector).
lock orb to vectorCrossProduct(ship:up:vector, cross).

set drUp to vecDraw(ship:position, ship:up * 100, RGB(1,0,0), "U", 1.0, true).
set drCross to vecDraw(ship:position, cross * 100, RGB(1,0,0), "U", 1.0, true).
set drOrb to vecDraw(ship:position, orb * 100, RGB(1,0,0), "U", 1.0, true).