SET TARGET_ALTITUDE TO 20000.

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
UNTIL SHIP:airspeed < 10 and ALT:RADAR < 1000{
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

SET Kp TO 0.1.  // Proportional constant
SET Ki TO 0.01.  // Integral constant
SET Kd TO 0.2.  // Derivative constant

SET target_speed TO -2.  // Target vertical speed in m/s

SET integral TO 0.  // Integral part of the error
SET last_error TO 0.  // Error from the last run of the loop

LOCK throttle TO 1.  // Start at full throttle

UNTIL ALT:RADAR < 5 {  // End condition
    SET error TO target_speed - SHIP:VERTICALSPEED.
    SET derivative TO error - last_error.
    SET integral TO integral + error.

    LOCK throttle TO 0.1 + Kp * error + Ki * integral + Kd * derivative.
    
    WAIT 0.01.  // Wait a small amount of time before next loop iteration

    SET last_error TO error.  // Update last error
    // Steerin up
    LOCK STEERING TO UP.
}

LOCK throttle TO 0.  // Cut throttle when altitude is below 100
