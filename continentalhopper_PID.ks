SET TARGET_ALTITUDE TO 2000.

SET t0 TO TIME:SECONDS.

SET LAUNCH_LONGITUDE TO SHIP:LONGITUDE.
SET LAUNCH_LATITUDE TO SHIP:LATITUDE.
CLEARSCREEN.

PRINT "Launch Longitude:" + SHIP:LONGITUDE.
PRINT "Launch Latitude:" + SHIP:LATITUDE. 
PRINT "Mission goal: Ascent to +" + TARGET_ALTITUDE.
PRINT "Ship's Liquid Fuel: " + SHIP:LIQUIDFUEL.

LOCK THROTTLE TO 0.6. 
STAGE.
PRINT "Ascent started.".    
LOCK STEERING TO UP.

GEAR OFF.

WAIT UNTIL apoapsis > (TARGET_ALTITUDE). 
PRINT "Approaching target apoapsis.".
LOCK THROTTLE TO 0.1. 
WAIT UNTIL ALT:RADAR > (TARGET_ALTITUDE - 1000). 

LOCK THROTTLE TO 0.


// Main descent loop. Suicide burn.
UNTIL SHIP:airspeed < 10 {
    CLEARSCREEN.
    PRINT "___________________________________________".
    PRINT "Trajectory set. Preparing approach and suicide burn".
    PRINT "Landing Longitude:" + SHIP:LONGITUDE.
    PRINT "Landing Latitude:" + SHIP:LATITUDE. 
    PRINT "Ship's Liquid Fuel: " + SHIP:LIQUIDFUEL.
    PRINT "Ship Altitude: " + ALT:RADAR.
    PRINT "Engines signal nominal".

    Brakes on. 
    rcs on.

    PRINT "___________________________________________".
    PRINT "___________________________________________".
    PRINT "Suicide burn calculations:".
    PRINT "___________________________________________".

    // Calculate gravity
    SET g TO 9.81.  // gravity at Kerbin surface, adjust as needed

    // Calculate current acceleration at full throttle
    SET max_acc TO SHIP:MAXTHRUST / SHIP:MASS.
    PRINT "Maximum Acceleration (max thrust / ship mass): " + max_acc + " m/s^2".

    // Calculate initial speed
    SET v_0 TO SHIP:airspeed.
    PRINT "Current speed: " + v_0 + " m/s".

    // Calculate stopping time
    SET t_stop TO v_0 / (max_acc - g).
    PRINT "Stopping Time (Initial Speed / (Max Acceleration - Gravity)): " + t_stop + " s".

    // Calculate stopping distance
    SET dist_stop TO (v_0^2) / (2*(max_acc - g)).
    PRINT "Stopping Distance (Initial Speed^2 / (2 * (Max Acceleration - Gravity))): " + dist_stop + " m".

    IF ALT:RADAR <= (dist_stop + 40) {  // start burn at calculated altitude + safety buffer
        LOCK THROTTLE TO 1.  // Full throttle for hoverslam
        PRINT "Suicide burn initiated.".
        IF SHIP:airspeed > 10 {
            LOCK STEERING TO SHIP:SRFRETROGRADE.
        } ELSE {
            LOCK STEERING TO UP.
        }
    } ELSE {
        LOCK THROTTLE TO 0.
    }

    IF ALT:RADAR < 500 {
        GEAR ON.
        PRINT "Landing gear deployed and locked.".
    } ELSE {
        GEAR OFF.
    }

    IF SHIP:airspeed > 1500 and ALT:RADAR <= 40000 {
        LOCK THROTTLE TO 0.4.
        PRINT "Hull temperature too hot, reducing entry speed.".
    } ELSE {
        PRINT "Hull temperature ok.".

    }

    SET t0 TO TIME:SECONDS.
    WAIT 0.01.
}
GEAR ON.

SET TARGET_ALTITUDE TO 40.
SET TARGET_SPEED TO -45.

// Altitude PID Constants
SET KP_A TO 0.1.
SET KI_A TO 0.01.
SET KD_A TO 0.2.

// Pitch PID Constants
SET KP_P TO 0.1.
SET KI_P TO 0.01.
SET KD_P TO 0.2.

// Speed PID Constants
SET KP_S TO 0.1.
SET KI_S TO 0.01.
SET KD_S TO 0.2.

// Initialize error terms
SET error_prior_alt TO 0.
SET integral_alt TO 0.
SET error_prior_pitch TO 0.
SET integral_pitch TO 0.
SET error_prior_speed TO 0.
SET integral_speed TO 0.

UNTIL SHIP:AVAILABLETHRUST < 0.9 {
    SET dt TO TIME:SECONDS - t0.
    // Speed PID
    SET error_speed TO TARGET_SPEED - SHIP:VERTICALSPEED.
    SET derivative_speed TO (error_speed - error_prior_speed) / dt.
    SET throttle_setting TO KP_S * error_speed + KI_S * integral_speed + KD_S * derivative_speed.
    SET throttle_setting TO MAX(0, MIN(1, throttle_setting)).

    // Only accumulate error if throttle isn't at min/max to prevent integral windup
    IF throttle_setting < 1 AND throttle_setting > 0 {
        SET integral_speed TO integral_speed + error_speed * dt.
    } ELSE {
        SET integral_speed TO 0.
    }
    
    // Pitch PID
    SET pitch_error TO VECTORANGLE(UP:FOREVECTOR, FACING:FOREVECTOR).
    SET derivative_pitch TO (pitch_error - error_prior_pitch) / dt.
    SET pitch_adjust TO KP_P * pitch_error + KI_P * integral_pitch + KD_P * derivative_pitch.
    SET pitch_adjust TO MAX(-1, MIN(1, pitch_adjust)).

    IF ABS(pitch_adjust) < 0.9 {
        SET integral_pitch TO integral_pitch + pitch_error * dt.
    } ELSE {
        SET integral_pitch TO 0.
    }


    LOCK THROTTLE TO throttle_setting.
    LOCK STEERING TO UP + R(0, pitch_adjust, 0).
    SET error_prior_speed TO error_speed.
    SET error_prior_pitch TO pitch_error.

    SET t0 TO TIME:SECONDS.
    WAIT 0.01.

    PRINT "___________________________________________".
    PRINT "PID loop for thrust control:".
    PRINT "___________________________________________".
    PRINT "Altitude PID Variables:".
    PRINT "Throttle Setting: " + throttle_setting.
    PRINT "Altitude Error: " + error_speed.
    PRINT "Derivative Altitude: " + derivative_speed.
    PRINT "Integral Altitude: " + integral_speed.
    PRINT "Altitude: " + ALT:RADAR.
    PRINT "Target Altitude: " + TARGET_ALTITUDE.
    PRINT "Time: " + dt.
    PRINT "Fuel: " + SHIP:AVAILABLETHRUST.
    PRINT "___________________________________________".
    PRINT "PID loop for gimball control:".
    PRINT "___________________________________________".
    PRINT "Pitch PID Variables:".
    PRINT "Pitch Adjust: " + pitch_adjust.
    PRINT "Pitch Error: " + pitch_error.
    PRINT "Derivative Pitch: " + derivative_pitch.
    PRINT "Integral Pitch: " + integral_pitch.
    PRINT "____________________________________________".
    CLEARSCREEN.
}


PRINT "Descent successfull.".
PRINT "Cutting engines.".
LOCK THROTTLE TO 0.
PRINT "Mission accomplished!".
