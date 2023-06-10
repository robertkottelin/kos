// Basic plane takeoff, circling and landing script
SET CRUISE_ALTITUDE TO 8000.  // Adjust this value based on your aircraft and terrain
SET TAKEOFF_SPEED TO 40.        // Speed at which the plane will take off
SET LANDING_SPEED TO 60.        // Speed at which the plane will land
SET RUNWAY_HEADING TO 90.       // Heading of the runway, adjust as needed

SET LANDING_ALTITUDE TO 600. 
SET FINISH_ALTITUDE TO 5.    // Altitude at which the plane starts to land
SET FLARE_ALTITUDE TO 200.       // Altitude at which the plane starts to flare
SET FLARE_PITCH TO 10.           // Increase in pitch during flare

CLEARSCREEN.

// TAKEOFF ________________________________________________________________________________
LOCK STEERING TO HEADING(RUNWAY_HEADING, 0).

PRINT "Starting engines...".
LOCK THROTTLE TO 1.

PRINT "Engines started. Takeoff.".
WAIT UNTIL GROUNDSPEED > TAKEOFF_SPEED.

PRINT "Incresing pitch...".
LOCK STEERING TO HEADING(RUNWAY_HEADING, 50).  // This will make the plane climb with a 10 degree pitch
WAIT UNTIL ALT:RADAR > 30.
GEAR OFF.
LOCK STEERING TO HEADING(RUNWAY_HEADING, 5).
WAIT UNTIL GROUNDSPEED > 500.
LOCK STEERING TO HEADING(RUNWAY_HEADING, 80).

// CRUISE ________________________________________________________________________________
WAIT UNTIL ALT:RADAR > CRUISE_ALTITUDE.
PRINT "Reaching cruise altitude...".
LOCK STEERING TO HEADING(RUNWAY_HEADING, 45).
WAIT 5.
LOCK STEERING TO HEADING(RUNWAY_HEADING, 0).
WAIT 5.
PRINT "Starting turn...".
LOCK THROTTLE TO 0.5.
LOCK STEERING TO HEADING(RUNWAY_HEADING, -45).
WAIT 10.
LOCK STEERING TO HEADING(RUNWAY_HEADING, -90).
WAIT 5.
LOCK STEERING TO HEADING(RUNWAY_HEADING + 180, -10).
WAIT 10.
// level plane
PRINT "Leveling plane...".


// LANDING ________________________________________________________________________________
PRINT "Starting descent...".
LOCK STEERING TO HEADING(RUNWAY_HEADING + 180, -10).  // Descending with a -5 degree pitch
LOCK THROTTLE TO 0.2.
WAIT UNTIL ALT:RADAR < LANDING_ALTITUDE.

PRINT "Preparing for landing...".
LOCK STEERING TO HEADING(RUNWAY_HEADING + 180, 5).

WAIT UNTIL ALT:RADAR < FLARE_ALTITUDE.
GEAR ON.

PRINT "Starting flare...".
LOCK STEERING TO HEADING(RUNWAY_HEADING + 180, FLARE_PITCH).  // Flare
LOCK THROTTLE TO 0.1.

WAIT UNTIL GROUNDSPEED < 2.


PRINT "Cutting engines for landing...".
LOCK THROTTLE TO 0.  // Cut throttle for landing

PRINT "Landed!".

