run once "/lib/utils".

local asc is 197.90.
local start is body:position.

local pen is 68.5.

local forward is V(0,0,-1) * (body:radius * 2).
set drawForward to VECDRAW(start,forward,RGB(1,0,0),"forward",1.0, true, 0.1, false).

local right is V(cos(asc - 90),0,sin(asc - 90)) * (body:radius * 2).
set drawRight to VECDRAW(start,right,RGB(0,1,0),"right",1.0, true, 0.1, false).

local ff is V(cos(pen),0,sin(pen)) * (body:radius * 2).
set drawFf to VECDRAW(start,ff,RGB(0,0,1),"45",1.0, true, 0.1, false).

local north is body:north:vector * (body:radius * 2).
set drawNorth to VECDRAW(start,north,RGB(0,1,0),"north",1.0, false, 0.1, false).

until round(Body:ROTATIONANGLE,2) = pen {
    print strfmt("{0}:{1}", list(round(Body:ROTATIONANGLE,2), asc)).
}

set kuniverse:timewarp:warp to 0.
print "go".

