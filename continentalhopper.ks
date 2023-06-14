SET TARGET_ALTITUDE TO 70000.
SET FUEL TO 19440.

// Altitude PID Constants
SET KP_A TO 0.1. 
SET KI_A TO 0.01.  
SET KD_A TO 0.2.

// Initialize error terms
SET error_prior_alt TO 0.
SET integral_alt TO 0.


// Initialize the time
SET t0 TO TIME:SECONDS.

SET LAUNCH_LONGITUDE TO SHIP:LONGITUDE.
SET LAUNCH_LATITUDE TO SHIP:LATITUDE.

PRINT "Launch Longitude:" + SHIP:LONGITUDE.
PRINT "Launch Latitude:" + SHIP:LATITUDE. 

LOCK THROTTLE TO 0.6. 
STAGE.    
LOCK STEERING TO UP.          

GEAR OFF.
PRINT (SHIP:LIQUIDFUEL).

WAIT UNTIL apoapsis > (TARGET_ALTITUDE + 5000). 


LOCK THROTTLE TO 0. 

SET HOVER_ALTITUDE TO 70000.

LOCK STEERING TO HEADING(185, 35). 
LOCK THROTTLE TO 1.
WAIT 28. 
LOCK THROTTLE TO 0.


// SET targetLat TO -90.  // Latitude of South Pole
// SET targetLon TO 0.  // Longitude of South Pole
// SET targetRange TO 0.1.  // Range within which we consider the craft as "over" the South Pole

// WAIT UNTIL TRAJECTORY:HASIMPACT {
//     SET impactLat TO TRAJECTORY:IMPACTPOS:LAT.
//     SET impactLon TO TRAJECTORY:IMPACTPOS:LNG.

//     // Calculate the difference between current impact point and South Pole
//     SET diffLat TO ABS(impactLat - targetLat).
//     SET diffLon TO ABS(impactLon - targetLon).

//     // If the impact point is within target range of the South Pole, exit the loop
//     IF (diffLat < targetRange) AND (diffLon < targetRange) {
//         BREAK.
//     }

//     // Otherwise, make adjustments to your course as necessary here

//     WAIT 0.01.
// }


WAIT UNTIL ALT:RADAR > (TARGET_ALTITUDE). 
PRINT "Entering PID loop for altitude hold.".

UNTIL (SHIP:LIQUIDFUEL/FUEL) < 0.70 { 
    SET dt TO TIME:SECONDS - t0.
    
    // Altitude PID
    SET error_alt TO HOVER_ALTITUDE - ALT:RADAR.
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

    //rcs on.
    // Pitch PID
    LOCK STEERING TO UP.  
    
    SET t0 TO TIME:SECONDS.
    WAIT 0.01.
    PRINT "Remaining fuel:" + (SHIP:LIQUIDFUEL/FUEL).
}

PRINT "Starting descent.".

LOCK THROTTLE TO 0.  // Cut engines for descent
LOCK STEERING TO UP.

// Main descent loop. Suicide burn.
UNTIL SHIP:airspeed < 10 AND ALT:RADAR < 50 {
    
    BRAKES ON.
    // rcs on.

    // Calculate current acceleration at full throttle
    SET max_acc TO SHIP:MAXTHRUST / SHIP:MASS.

    // Calculate gravity
    SET g TO 9.81.  // gravity at Kerbin surface, adjust as needed

    // Calculate initial speed
    SET v_0 TO SHIP:airspeed.

    // Calculate stopping time and distance
    SET t_stop TO v_0 / (max_acc - g).
    SET dist_stop TO (v_0^2) / (2*(max_acc - g)).

    IF ALT:RADAR <= (dist_stop + 10) {  // start burn at calculated altitude + safety buffer
        LOCK THROTTLE TO 1.  // Full throttle for hoverslam
    } ELSE {
        LOCK THROTTLE TO 0.
    }
    
    IF ALT:RADAR > 14 and SHIP:GROUNDSPEED > 10 {
        LOCK STEERING TO SHIP:SRFRETROGRADE.
    } ELSE {
        LOCK STEERING TO UP.
    }

    IF ALT:RADAR < 1300 {
        GEAR ON.
    } ELSE {
        GEAR OFF.
    }

    IF SHIP:airspeed > 1300 and ALT:RADAR <= 50000 {
        LOCK THROTTLE TO 0.2.
    } 

    SET t0 TO TIME:SECONDS.
    WAIT 0.01.
}

PRINT "Fuel exhausted. Cut-off.".
LOCK THROTTLE TO 0.  // Cut-off the engine
GEAR ON.             // Deploy landing gear
