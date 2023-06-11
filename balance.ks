SET TARGET_ALTITUDE TO 100000.
SET FUEL TO 7830.

// Altitude PID Constants
SET KP_A TO 0.1. 
SET KI_A TO 0.01.  
SET KD_A TO 0.2.

// Initialize error terms
SET error_prior_alt TO 0.
SET integral_alt TO 0.

// Initialize the time
SET t0 TO TIME:SECONDS.

// Get KSC coordinates
SET KSC TO LATLNG(-0.0972, -74.5577). 

// // Define function to get direction towards KSC launch pad
// FUNCTION LAUNCHPAD_DIRECTION {
//   PARAMETER pitch_angle.
//   LOCAL landing_direction IS HEADING(ANGLE_BETWEEN(SHIP:UP:VECTOR, KSC:POSITION), 0).
//   RETURN HEADING(landing_direction, pitch_angle).
// }

// // Lock steering to launchpad direction
// LOCK STEERING TO LAUNCHPAD_DIRECTION(80).  

LOCK THROTTLE TO 1. 
STAGE.    
LOCK STEERING TO UP.          

GEAR OFF.
PRINT (SHIP:LIQUIDFUEL).

WAIT UNTIL apoapsis > (TARGET_ALTITUDE). 

LOCK THROTTLE TO 0. 

WAIT UNTIL ALT:RADAR > (TARGET_ALTITUDE-10000). 

SET HOVER_ALTITUDE TO 100000.

PRINT "Entering PID loop for altitude hold.".

UNTIL (SHIP:LIQUIDFUEL/FUEL) < 0.30 { 
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

    rcs on.
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
UNTIL SHIP:airspeed < 5 AND ALT:RADAR < 50 {

    BRAKES ON.
    rcs on.

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
        LOCK THROTTLE TO 0.  // Cut engines if we're not there yet
    }

    IF ALT:RADAR < 1200 {
        GEAR ON.
    } ELSE {
        GEAR OFF.
    }

    IF ALT:RADAR < 20000 {
        BRAKES ON.
    } ELSE {
        BRAKES OFF.
    }

    IF SHIP:airspeed > 1000 {
        LOCK THROTTLE TO 0.5.
    } 

    IF ALT:RADAR > 2000 {
        LOCK STEERING TO LAUNCHPAD_DIRECTION(80). 
    } ELSE {
        LOCK STEERING TO UP. 
    }

    SET t0 TO TIME:SECONDS.
    WAIT 0.01.
}

PRINT "Fuel exhausted. Cut-off.".
LOCK THROTTLE TO 0.  // Cut-off the engine
GEAR ON.             // Deploy landing gear
