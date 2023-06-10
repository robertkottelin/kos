SET TARGET_ALTITUDE TO 50.
SET TARGET_PITCH TO 90. // Straight up

// Altitude PID Constants
SET KP_A TO 0.1. 
SET KI_A TO 0.01.  
SET KD_A TO 0.2.

// Pitch PID Constants
SET KP_P TO 0.5. 
SET KI_P TO 0.2.  
SET KD_P TO 0.1.

// Initialize error terms
SET error_prior_alt TO 0.
SET integral_alt TO 0.

SET error_prior_pitch TO 0.
SET integral_pitch TO 0.

// Initialize the time
SET t0 TO TIME:SECONDS.

LOCK THROTTLE TO 0.5.  // Full throttle for takeoff
STAGE.               // Launch

GEAR OFF.

WAIT UNTIL ALT:RADAR > TARGET_ALTITUDE - 5.  // Close to target altitude

PRINT "Entering PID loop for altitude hold.".

UNTIL SHIP:LIQUIDFUEL < 0.01 {  // Until fuel runs out
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
}

PRINT "Fuel exhausted. Cut-off....".
LOCK THROTTLE TO 0.  // Cut-off the engine
