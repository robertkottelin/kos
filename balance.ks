SET TARGET_ALTITUDE TO 200.
SET FUEL TO 2880.

// Altitude PID Constants
SET KP_A TO 0.1. 
SET KI_A TO 0.01.  
SET KD_A TO 0.2.

// Initialize error terms
SET error_prior_alt TO 0.
SET integral_alt TO 0.

// Initialize the time
SET t0 TO TIME:SECONDS.

LOCK THROTTLE TO 0.8. 
STAGE.              

GEAR OFF.
PRINT (SHIP:LIQUIDFUEL).

WAIT UNTIL ALT:RADAR > TARGET_ALTITUDE - 5.  // Close to target altitude

PRINT "Entering PID loop for altitude hold.".

UNTIL (SHIP:LIQUIDFUEL/2880) < 0.90 { 
    SET dt TO TIME:SECONDS - t0.
    
    // Altitude PID
    SET error_alt TO TARGET_ALTITUDE - ALT:RADAR.
    SET derivative_alt TO (error_alt - error_prior_alt) / dt.
    SET throttle_setting TO KP_A * error_alt + KI_A * integral_alt + KD_A * derivative_alt.
    SET throttle_setting TO MAX(0, MIN(1, throttle_setting)).
    
    // Only accumulate error if throttle isn't at min/max to prevent integral windup
    IF throttle_setting < 1 AND throttle_setting > 0 {
        SET integral_alt TO integral_alt + error_alt * dt.
    } ELSE {
        SET integral_alt TO 0.
    }
    
    LOCK THROTTLE TO throttle_setting.
    SET error_prior_alt TO error_alt.

    // Pitch PID
    LOCK STEERING TO UP.
    
    SET t0 TO TIME:SECONDS.
    WAIT 0.01.
    PRINT "Remaining fuel:" + (SHIP:LIQUIDFUEL/2880).
}

PRINT "Starting descent.".

function countdown {
    parameter i.

    lock STEERING to LOOKDIRUP(UP:VECTOR, FACING:TOPVECTOR).
    lock THROTTLE to 1.

    until i <= 0 {
        HUDTEXT(i, 1, 4, 100, RED, false).
        set i to i-1.
        wait 1.
    }

    set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
    stage.
    print "LIFTOFF!".
}

local offset is ALT:RADAR + 1.

local thrott is 0.
lock THROTTLE to thrott.

wait until VERTICALSPEED < 0.

local speed is AIRSPEED.
local t is MISSIONTIME.
local gSurf is BODY:MU / BODY:RADIUS^2.
local g is BODY:MU / (BODY:RADIUS + ALTITUDE)^2.
local aNet is g.
local prevQ is SHIP:Q.

local runmode is 1.

until ALT:RADAR <= offset {
    if MISSIONTIME - t > 0.5 {
        set g to BODY:MU / (BODY:RADIUS + ALTITUDE)^2.
        set aNet to (aNet + (AIRSPEED - speed) / (MISSIONTIME - t) + thrott * MAXTHRUST / SHIP:MASS)/2.
        set speed to AIRSPEED.
        set t to MISSIONTIME.

        print "g: " + g + "        " at(0,14).
        print "aNet: " + aNet + "       " at(0,15).
        print "Q: " + SHIP:Q + "       " at(0,16).

        if prevQ > SHIP:Q {
            set aNet to g.
        }
        set prevQ to SHIP:Q.
    }

    // Wait for suicide altitude
    if runmode = 1 {
        local aEst is (aNet - g) * 0.6 + gSurf.
        local a is MAXTHRUST / SHIP:MASS - aEst.
        local stopDist is (AIRSPEED - 1)^2 / (2 * a).

        print "Max A: " + a + "       " at(0,18).
        print "Speed: " + AIRSPEED + "        " at(0,19).
        print "Target Alt: " + stopDist + "        " at(0,20).
        if (stopDist >= (ALT:RADAR - offset)) {
            set runmode to 2.
        }
    }

    // Slow down!
    if runmode = 2 {
        //local aEst is (aNet - g) / 2 + gSurf.
        local a is (AIRSPEED - 1)^2 / (2 * (ALT:RADAR - offset)).
        local thrust is (a + gSurf) * SHIP:MASS.

        set thrott to thrust / (MAXTHRUST + 0.001).
        print "Target A: " + a + "        " at(0,22).
        print "Thrust: " + thrust + "        " at(0,23).
        print "Throttle: " + thrott + "         " at(0,24).

        if thrott < 0.8 or ALT:RADAR <= offset {
            set thrott to 0.
            set runmode to 1.
        }
    }
}


print "Landing... " + AIRSPEED.
local twr is (MAXTHRUST + 0.001) / SHIP:MASS / g.
set thrott to 0.95 / twr.

wait until SHIP:STATUS = "LANDED".

print "Landed".
set thrott to 0.

wait 60.