// Basic plane takeoff, circling and landing script
SET CRUISE_ALTITUDE TO 8000.  // Adjust this value based on your aircraft and terrain
SET TAKEOFF_SPEED TO 150.        // Speed at which the plane will take off
SET LANDING_SPEED TO 70.        // Speed at which the plane will land
SET RUNWAY_HEADING TO 90.       // Heading of the runway, adjust as needed

SET LANDING_ALTITUDE TO 150. 
SET FINISH_ALTITUDE TO 5.    // Altitude at which the plane starts to land
SET FLARE_ALTITUDE TO 20.       // Altitude at which the plane starts to flare
SET FLARE_PITCH TO 10.           // Increase in pitch during flare

CLEARSCREEN.

SET RUNWAY_LATITUDE TO SHIP:LATITUDE.
SET RUNWAY_LONGITUDE TO SHIP:LONGITUDE.

PRINT "Runway latitude: " + RUNWAY_LATITUDE.
PRINT "Runway longitude: " + RUNWAY_LONGITUDE.

brakes on.
// TAKEOFF ________________________________________________________________________________
LOCK STEERING TO HEADING(RUNWAY_HEADING, 2).

STAGE.  // Activate engines
rcs on. 
LOCK THROTTLE TO 1.
brakes off.

PRINT "Taking off ".

WAIT UNTIL GROUNDSPEED > TAKEOFF_SPEED.

PRINT "Incresing pitch...".
LOCK STEERING TO HEADING(RUNWAY_HEADING, 10). 
WAIT UNTIL ALT:RADAR > 5.
GEAR OFF.
WAIT 5.
LOCK STEERING TO HEADING(RUNWAY_HEADING, 20). 
WAIT UNTIL ALT:RADAR > CRUISE_ALTITUDE.
PRINT "Reached cruise altitude...".
LOCK STEERING TO HEADING(RUNWAY_HEADING, 0). 

LOCK THROTTLE TO 0.6.
// CRUISE ________________________________________________________________________________


// LOCK STEERING TO HEADING(RUNWAY_HEADING + 45, 0).
// WAIT 10.
// LOCK STEERING TO HEADING(RUNWAY_HEADING + 90, 0).
// WAIT 15.
// LOCK STEERING TO HEADING(RUNWAY_HEADING + 135, 0).
// WAIT 10.
// LOCK STEERING TO HEADING(RUNWAY_HEADING + 180, 0).
// WAIT 90.
// LOCK STEERING TO HEADING(RUNWAY_HEADING + 225, 0).
// WAIT 5.
// LOCK STEERING TO HEADING(RUNWAY_HEADING + 270, 0).
// WAIT 5.
// LOCK STEERING TO HEADING(RUNWAY_HEADING + 350, 0).
// PRINT "Searching runway latitude...".
// WAIT UNTIL SHIP:LATITUDE > (RUNWAY_LATITUDE - 0.034).
// PRINT "Latitude match...".
// // WAIT UNTIL SHIP:LONGITUDE < RUNWAY_LONGITUDE + 0.005 AND SHIP:LONGITUDE > RUNWAY_LONGITUDE - 0.005.
// LOCK STEERING TO HEADING(RUNWAY_HEADING, 0).

PRINT "Ship longitude: " + SHIP:longitude.
PRINT "Searching runway longitude...".
PRINT "longitude match...".


UNTIL SHIP:LONGITUDE > (RUNWAY_LONGITUDE - 0.81) AND SHIP:LONGITUDE < (-90) { 
    PRINT "Ship longitude: " + SHIP:longitude.
    WAIT 1.
    LOCK STEERING TO HEADING(90, 0). 
}


// LANDING ________________________________________________________________________________
PRINT "Starting descent...".
BRAKES ON.
LOCK STEERING TO HEADING(RUNWAY_HEADING, -20).  // Descending with a -5 degree pitch
LOCK THROTTLE TO 0.
WAIT UNTIL ALT:RADAR < LANDING_ALTITUDE.

PRINT "Preparing for landing...".
LOCK STEERING TO HEADING(RUNWAY_HEADING, 2).
LOCK THROTTLE TO 0.05.

WAIT UNTIL ALT:RADAR < FLARE_ALTITUDE.
GEAR ON.
BRAKES OFF.

PRINT "Starting flare...".
LOCK STEERING TO HEADING(RUNWAY_HEADING, 7).  // Flare
WAIT UNTIL ALT:RADAR < 9.
LOCK STEERING TO HEADING(RUNWAY_HEADING, 8).  // Flare
LOCK THROTTLE TO 0.
WAIT UNTIL ALT:RADAR < 2.
LOCK STEERING TO HEADING(RUNWAY_HEADING, 3).
WAIT UNTIL GROUNDSPEED < 65.
BRAKES ON.

PRINT "Landed!".

