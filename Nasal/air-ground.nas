## Controls systems that depend on the air-ground sensor
# (also called "squat-switch") position.  This assumes
# the airplane always starts on the ground (just like the
# real airplane).

var was_in_air = func{
	var air_ground = getprop("/b737/sensors/air-ground");
	var was_ia = getprop("/b737/sensors/was-in-air");
	var GROUNDSPEED = getprop("/velocities/uBody-fps") * 0.593; 

	if (!air_ground and !was_ia) {
		setprop("/b737/sensors/was-in-air", "true");
		setprop("/b737/sensors/lift-off-time", getprop("/sim/time/elapsed-sec"));
		setprop("/b737/sensors/landing", 0);
	}
	if (!air_ground and was_ia) setprop("/b737/sensors/was-in-air", "true");
	if (air_ground and !was_ia) setprop("/b737/sensors/was-in-air", "false");
	if (air_ground and was_ia) {
		if (GROUNDSPEED < 30){
			setprop("/b737/sensors/was-in-air", "false");
			#copilot.copilot.init();
		} else {
			settimer (was_in_air, 2);
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