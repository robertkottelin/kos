SET TARGET_ALTITUDE TO 50000.

SET t0 TO TIME:SECONDS.

SET LAUNCH_LONGITUDE TO SHIP:LONGITUDE.
SET LAUNCH_LATITUDE TO SHIP:LATITUDE.
CLEARSCREEN.

PRINT "Launch Longitude:" + SHIP:LONGITUDE.
PRINT "Launch Latitude:" + SHIP:LATITUDE. 
PRINT "Mission goal: Ascent to +" + TARGET_ALTITUDE + "m and land on the beach of the south pole arctic.".
PRINT "Ship's Liquid Fuel: " + SHIP:LIQUIDFUEL.
PRINT "Checking vehicle status...".
// WAIT 2.
PRINT "Checks complete, starting takeoff".

LOCK THROTTLE TO 0.6. 
STAGE.
PRINT "Ascent started.".    
LOCK STEERING TO HEADING(185, 90). 

GEAR OFF.
WAIT UNTIL ALT:RADAR > 2000.
LOCK STEERING TO HEADING(185, 80). 
LOCK THROTTLE TO 0.5. 
WAIT UNTIL ALT:RADAR > 10000.
LOCK STEERING TO HEADING(185, 70). 
WAIT UNTIL ALT:RADAR > 15000.
LOCK STEERING TO HEADING(185, 60). 
WAIT UNTIL ALT:RADAR > 20000.
LOCK STEERING TO HEADING(185, 45). 

WAIT UNTIL apoapsis > (TARGET_ALTITUDE + 10000). 
PRINT "Approaching target apoapsis.".
LOCK THROTTLE TO 0.1. 
WAIT UNTIL ALT:RADAR > (TARGET_ALTITUDE). 

LOCK STEERING TO HEADING(185, 0). 
LOCK THROTTLE TO 1.
PRINT "Trajectory placement in progress.".

SET targetLat TO -90.  // Latitude of South Pole
SET targetLon TO 0.  // Longitude of South Pole

UNTIL addons:tr:IMPACTPOS:LAT < -74.3 {  
    SET impactLat TO addons:tr:IMPACTPOS:LAT.
    SET impactLon TO addons:tr:IMPACTPOS:LNG.
    CLEARSCREEN.
    PRINT "___________________________________________".
    PRINT "Trajectory placement in progress.".
    PRINT "Impact Latitude: " + impactLat.
    PRINT "Impact Longitude: " + impactLon.
    PRINT "Ship's Liquid Fuel: " + SHIP:LIQUIDFUEL.
    PRINT "Altitude: " + ALT:RADAR.


    // Otherwise, make adjustments to your course as necessary here
    lock throttle to 1.
    LOCK STEERING TO HEADING(188, 0).

    WAIT 0.01.
}

LOCK THROTTLE TO 0.

WAIT UNTIL SHIP:LONGITUDE < -60.

LOCK THROTTLE TO 0.  // Cut engines for descent
LOCK STEERING TO UP.

// Main descent loop. Suicide burn.
UNTIL SHIP:airspeed < 5 AND ALT:RADAR < 50 {
    CLEARSCREEN.
    PRINT "___________________________________________".
    PRINT "Trajectory set. Preparing approach and suicide burn".
    PRINT "Landing Longitude:" + SHIP:LONGITUDE.
    PRINT "Landing Latitude:" + SHIP:LATITUDE. 
    PRINT "Ship's Liquid Fuel: " + SHIP:LIQUIDFUEL.
    PRINT "Ship Altitude: " + ALT:RADAR.
    PRINT "Engines signal nominal".

    // IF ALT RADAR THEN BRAKE

    IF SHIP:LATITUDE < -55 {
        BRAKES ON.
        PRINT "Brakes engaged.".
    } ELSE {
        BRAKES OFF.
        PRINT "Brakes disengaged.".

    }
    // rcs on.

    PRINT "___________________________________________".
    PRINT "___________________________________________".
    PRINT "Suicide burn calculations:".
    PRINT "___________________________________________".
    // Calculate current acceleration at full throttle
    SET max_acc TO SHIP:MAXTHRUST / SHIP:MASS.
    PRINT "Maximum Acceleration (max thrust / ship mass): " + max_acc.


    // Calculate gravity
    SET g TO 9.81.  // gravity at Kerbin surface, adjust as needed

    // Calculate initial speed
    SET v_0 TO SHIP:airspeed.
    PRINT "Current speed: " + v_0.

    // Calculate stopping time
    SET t_stop TO v_0 / (max_acc - g).
    PRINT "Stopping Time (Initial Speed / (Max Acceleration - Gravity)): " + t_stop.

    // Calculate stopping distance
    SET dist_stop TO (v_0^2) / (2*(max_acc - g)).
    PRINT "Stopping Distance (Initial Speed^2 / (2 * (Max Acceleration - Gravity))): " + dist_stop.

    IF ALT:RADAR <= (dist_stop + 12) {  // start burn at calculated altitude + safety buffer
        LOCK THROTTLE TO 1.  // Full throttle for hoverslam
        PRINT "Suicide burn initiated.".
    } ELSE {
        LOCK THROTTLE TO 0.
    }

    IF ALT:RADAR < 1300 {
        GEAR ON.
        PRINT "Landing gear deployed and locked.".
    } ELSE {
        GEAR OFF.
    }

    IF SHIP:airspeed > 1500 and ALT:RADAR <= 35000 {
        LOCK THROTTLE TO 0.3.
        PRINT "Hull temperature too hot, reducing entry speed.".
    } ELSE {
        PRINT "Hull temperature ok.".

    }

    IF ALT:RADAR > 15 {
        LOCK STEERING TO SHIP:SRFRETROGRADE.
    } ELSE {
        LOCK STEERING TO UP.
        IF ALT:RADAR < 12 and SHIP:GROUNDSPEED < 12 {
            LOCK THROTTLE TO 0.
        }
        // TODO: PID loop for entering hovering before touchdown?
    }

    SET t0 TO TIME:SECONDS.
    WAIT 0.01.
}

PRINT "Descent successfull.".
PRINT "Cutting engines.".
LOCK THROTTLE TO 0.
PRINT "Mission accomplished!".
