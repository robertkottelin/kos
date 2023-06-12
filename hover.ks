// Set the hover altitude.
SET TARGET_ALTITUDE TO 50.

// PID constants
SET KP TO 0.2.
SET KI TO 0.05.
SET KD TO 0.1.

// Initialize error and integral values
SET error_prior TO LIST(0, 0, 0, 0).
SET integral TO LIST(0, 0, 0, 0).

WAIT 0.01. // Avoid division by zero error on first loop

// Initialize the time
SET t0 TO TIME:SECONDS.

// Calculate starboard vector and up vector
LOCK starboardRotation TO SHIP:FACING * R(0,90,0).
LOCK starVec TO starboardRotation:VECTOR.
LOCK currentUpVec TO SHIP:UP:VECTOR.

// PID loop for hovering control
UNTIL ABORT {
    SET dt TO TIME:SECONDS - t0.

    IF dt <= 0.0001 {
        SET dt TO 0.0001.
    }

    // Get the current error.
    SET error TO TARGET_ALTITUDE - SHIP:ALTITUDE.
    SET pitch_error TO 90 - VECTORANGLE(UP:FOREVECTOR, FACING:FOREVECTOR).
    SET roll_error TO 90 - VANG(starVec, currentUpVec). // calculate roll error as you described

    // Apply separate PID controller for each action group (which is associated with each engine)
    FOR idx IN RANGE(0, 4) {
        SET error_prior_engine TO error_prior[idx].
        SET integral_engine TO integral[idx].
        
        // Altitude PID for each engine
        SET derivative TO (error - error_prior_engine) / dt.
        SET throttle_setting TO KP * error + KI * integral_engine + KD * derivative.
        SET throttle_setting TO MAX(0, MIN(1, throttle_setting)).
        
        IF throttle_setting < 1 AND throttle_setting > 0 {
            SET integral_engine TO integral_engine + error * dt.
        } ELSE {
            SET integral_engine TO 0.
        }
        
        SET error_prior[idx] TO error.
        SET integral[idx] TO integral_engine.

        // Adjust throttle based on pitch and roll
        IF idx = 0 OR idx = 1 { // Front and back engines control pitch
            SET throttle_setting TO throttle_setting + KP * pitch_error.
        } ELSE { // Left and right engines control roll
            SET throttle_setting TO throttle_setting + KP * roll_error.
        }
        
        // Toggle action group for engine on/off depending on throttle setting
        IF throttle_setting > 0.5 {
            AG(idx+1, true). // Enable action group (idx+1 because AG0 is not valid)
        }.
        ELSE {
            AG(idx+1, false). // Disable action group
        }.


    }

    SET t0 TO TIME:SECONDS.
    WAIT 0.01.
}
