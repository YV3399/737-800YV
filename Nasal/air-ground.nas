## Controls systems that depend on the air-ground sensor
# (also called "squat-switch") position.  This assumes
# the airplane always starts on the ground (just like the
# real airplane).

var update_timer_air_ground = maketimer(2, func was_in_air() );
 
 var air_ground = 0;
 var was_ia = 0;
 var GROUNDSPEED = 0;

var was_in_air = func{
	 air_ground = getprop("/b737/sensors/air-ground");
	 was_ia = getprop("/b737/sensors/was-in-air");
         GROUNDSPEED = getprop("/velocities/uBody-fps") * 0.593; 

	if (!air_ground and !was_ia) {
		setprop("/b737/sensors/was-in-air", "true");
		setprop("/b737/sensors/lift-off-time", getprop("/sim/time/elapsed-sec"));
		setprop("/b737/sensors/landing", 0);
	}
	if (!air_ground and was_ia)
                 return;
         if (air_ground and !was_ia)
 		return;
 
	if (air_ground and was_ia) {
		if (GROUNDSPEED < 30){
			setprop("/b737/sensors/was-in-air", "false");
			#copilot.copilot.init();
                        update_timer_air_ground.stop();
		} else {
			if (!update_timer_air_ground.isRunning)
 				update_timer_air_ground.start();
		}
	}
}
setlistener( "/b737/sensors/air-ground", was_in_air, 0, 0);


var lift_off = func {
	var wow_nose = getprop("/gear/gear/wow");
	var wow_left = getprop("/gear/gear[1]/wow");
	var wow_right = getprop("/gear/gear[2]/wow");
	var was_ia = getprop("/b737/sensors/was-in-air");

	if (!wow_nose and !wow_right and !wow_left and was_ia) {
		setprop("/b737/sensors/lift-off-time", getprop("/sim/time/elapsed-sec"));
		setprop("/b737/sensors/landing", 0);
	}
}