// Initialize the time
SET t0 TO TIME:SECONDS.

STAGE.

SET TARGET_ALTITUDE TO 200.

// Altitude PID Constants
SET KP_A TO 0.1.
SET KI_A TO 0.01.
SET KD_A TO 0.2.

// Pitch PID Constants
SET KP_P TO 0.1.
SET KI_P TO 0.01.
SET KD_P TO 0.2.

// Initialize error terms
SET error_prior_alt TO 0.
SET integral_alt TO 0.
SET error_prior_pitch TO 0.
SET integral_pitch TO 0.

UNTIL SHIP:AVAILABLETHRUST < 0.9 {
    SET dt TO TIME:SECONDS - t0.
    // Thrust PID
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

    IF ALT:RADAR > 10 {
        GEAR OFF.
    } ELSE {
        GEAR ON.
    }

    LOCK THROTTLE TO throttle_setting.
    LOCK STEERING TO UP + R(0, pitch_adjust, 0).
    SET error_prior_alt TO error_alt.
    SET error_prior_pitch TO pitch_error.

    SET t0 TO TIME:SECONDS.
    WAIT 0.01.

    PRINT "___________________________________________".
    PRINT "PID loop for thrust control:".
    PRINT "___________________________________________".
    PRINT "Altitude PID Variables:".
    PRINT "Throttle Setting: " + throttle_setting.
    PRINT "Altitude Error: " + error_alt.
    PRINT "Derivative Altitude: " + derivative_alt.
    PRINT "Integral Altitude: " + integral_alt.
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
    PRINT "___________________________________________".
    CLEARSCREEN.
}

UNTIL SHIP:AVAILABLETHRUST < 0.8 {
    SET dt TO TIME:SECONDS - t0.
    // Thrust PID
    SET error_alt TO 10 - ALT:RADAR.
    SET derivative_alt TO (error_alt - error_prior_alt) / dt.
    SET throttle_setting TO KP_A * error_alt + KI_A * integral_alt + KD_A * derivative_alt.
    SET throttle_setting TO MAX(0, MIN(1, throttle_setting)).

    // Only accumulate error if throttle isn't at min/max to prevent integral windup
    IF throttle_setting < 1 AND throttle_setting > 0 {
        SET integral_alt TO integral_alt + error_alt * dt.
    } ELSE {
        SET integral_alt TO 0.
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

    IF ALT:RADAR > 10 {
        GEAR OFF.
    } ELSE {
        GEAR ON.
    }

    LOCK THROTTLE TO throttle_setting.
    LOCK STEERING TO UP + R(0, pitch_adjust, 0).
    SET error_prior_alt TO error_alt.
    SET error_prior_pitch TO pitch_error.

    SET t0 TO TIME:SECONDS.
    WAIT 0.01.

    PRINT "___________________________________________".
    PRINT "PID loop for thrust control:".
    PRINT "___________________________________________".
    PRINT "Altitude PID Variables:".
    PRINT "Throttle Setting: " + throttle_setting.
    PRINT "Altitude Error: " + error_alt.
    PRINT "Derivative Altitude: " + derivative_alt.
    PRINT "Integral Altitude: " + integral_alt.
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
    PRINT "___________________________________________".
    CLEARSCREEN.
}

UNTIL SHIP:AVAILABLETHRUST < 0.7 {
    SET dt TO TIME:SECONDS - t0.
    // Thrust PID
    SET error_alt TO 5 - ALT:RADAR.
    SET derivative_alt TO (error_alt - error_prior_alt) / dt.
    SET throttle_setting TO KP_A * error_alt + KI_A * integral_alt + KD_A * derivative_alt.
    SET throttle_setting TO MAX(0, MIN(1, throttle_setting)).

    // Only accumulate error if throttle isn't at min/max to prevent integral windup
    IF throttle_setting < 1 AND throttle_setting > 0 {
        SET integral_alt TO integral_alt + error_alt * dt.
    } ELSE {
        SET integral_alt TO 0.
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

    IF ALT:RADAR > 10 {
        GEAR OFF.
    } ELSE {
        GEAR ON.
    }

    LOCK THROTTLE TO throttle_setting.
    LOCK STEERING TO UP + R(0, pitch_adjust, 0).
    SET error_prior_alt TO error_alt.
    SET error_prior_pitch TO pitch_error.

    SET t0 TO TIME:SECONDS.
    WAIT 0.01.

    PRINT "___________________________________________".
    PRINT "PID loop for thrust control:".
    PRINT "___________________________________________".
    PRINT "Altitude PID Variables:".
    PRINT "Throttle Setting: " + throttle_setting.
    PRINT "Altitude Error: " + error_alt.
    PRINT "Derivative Altitude: " + derivative_alt.
    PRINT "Integral Altitude: " + integral_alt.
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
    PRINT "___________________________________________".
    CLEARSCREEN.
}

