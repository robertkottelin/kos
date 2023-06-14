runoncepath("0:/fall/utilities/importFall").
importFall("landingDataModel").
importFall("hoverSlamModel").
importFall("glideController").
importFall("landingController").

local ldata is landingDataModel(ship:geoposition).

lock steering to up.
lock throttle to 1.

// [ Launch ]
wait 1.
stage.
gear off.


// [ Ascent ]
wait until ship:apoapsis > 200000.
lock throttle to 0.
rcs on.

// [ Gliding Prep ]
local glide is glideController(ldata).


// [ Gliding ]
wait until ship:verticalspeed < 0.
when alt:radar < 50 then { gear on. }

lock steering to glide["getSteering"]().

// [Landing Prep]
local hoverslam is hoverSlamModel(10).
local landing is landingController(ldata, hoverslam, 5, 0.4).
lock throttle to landing["getThrottle"]().

// [ Powered Landing ]
wait until throttle > 0 and alt:Radar < 5000.
lock steering to landing["getSteering"]().

wait until landing["completed"]().
lock throttle to 0.
rcs off.
wait until false.