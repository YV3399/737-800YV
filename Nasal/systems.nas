var altAlertModeSwitch = func {
	var warning_b = getprop("/b737/warnings/altitude-alert-b-conditions");
	var diff_0 = getprop("/b737/helpers/alt-diff-ft[0]");
	var diff_1 = getprop("/b737/helpers/alt-diff-ft[1]");

	if (warning_b) {
		var diff = diff_1;
	} else {
		var diff = diff_0;
	}

	if (diff < 600) {
		setprop("/b737/warnings/altitude-alert-mode", 1);
	} else {
		setprop("/b737/warnings/altitude-alert-mode", 0);
	}
}
setlistener( "/b737/warnings/altitude-alert", altAlertModeSwitch, 0, 0);

setprop("/controls/lighting/AFDSbrt","0");

setlistener("/sim/signals/fdm-initialized", func {
  	itaf.ap_init();				
	var autopilot = gui.Dialog.new("sim/gui/dialogs/autopilot/dialog", "Aircraft/737-800/Systems/autopilot-dlg.xml");
});

setlistener("/sim/signals/fdm-initialized", func {
  	setprop("/it-autoflight/settings/target-speed-kt", 100);
});

setprop("/it-autoflight/settings/target-altitude-ft-actual", 10000);

var timerstall = maketimer(5, func(){

	
	var alt_agl = getprop("/position/altitude-agl-ft") - 6.5; # get altitude above ground
	var curspd = getprop("/velocities/airspeed-kt"); # get IAS
	var getstallspd = getprop("instrumentation/weu/state/stall-speed"); # get stall speed
	
	if (alt_agl > 8 and curspd < getstallspd) { # if we are off the ground and if speed is less than stall speed
		setprop("/b737/sound/stall",1); # turn on the stall sound
		}
});
timerstall.start(); # begin the timer
setprop("/b737/sound/stall",0);

