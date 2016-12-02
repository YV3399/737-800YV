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
	elec_init();
  	itaf.ap_init();			
	var autopilot = gui.Dialog.new("sim/gui/dialogs/autopilot/dialog", "Aircraft/737-800/Systems/autopilot-dlg.xml");
	setprop("/it-autoflight/settings/retard-enable", 1);  # Enable or disable automatic autothrottle retard.
	setprop("/it-autoflight/settings/retard-ft", 35);     # Add this to change the retard altitude, default is 50ft AGL.
	setprop("/it-autoflight/settings/land-flap", 0.750);  # Define the landing flaps here. This is needed for autoland, and retard.
	setprop("/it-autoflight/settings/land-enable", 0);    # Enable or disable automatic landing.
});

setlistener("/sim/signals/fdm-initialized", func {
  	setprop("/it-autoflight/settings/target-speed-kt", 100);
});

	setprop("/it-autoflight/ap_master", 0);
	setprop("/it-autoflight/ap_master2", 0);
	setprop("/it-autoflight/at_master", 0);
	setprop("/it-autoflight/fd_master", 0);
	setprop("/it-autoflight/fd_master2", 0);
	setprop("/it-autoflight/settings/target-speed-kt", 100);
	setprop("/it-autoflight/settings/target-mach", 0.68);
	setprop("/it-autoflight/settings/heading-bug-deg", 360);
	setprop("/it-autoflight/settings/target-altitude-ft", 10000);
	setprop("/it-autoflight/settings/target-altitude-ft-actual", 10000);
	setprop("/it-autoflight/settings/vertical-speed-fpm", 0);
	setprop("/it-autoflight/settings/vertical-speed-fpm-reduced", 0);
	setprop("/it-autoflight/loc1", 0);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/aplatmode", 0);
	setprop("/it-autoflight/apvertmode", 3);
	setprop("/it-autoflight/thr", 1);
	setprop("/it-autoflight/idle", 0);
	setprop("/it-autoflight/clb", 0);
	setprop("/it-autoflight/autothrarm", 0);
	setprop("/it-autoflight/apthrmode", 0);
	setprop("/it-autoflight/apthrmode2", 0);

setlistener("/it-autoflight/settings/vertical-speed-fpm", func {
	setprop("/it-autoflight/settings/vertical-speed-fpm-reduced", getprop("/it-autoflight/settings/vertical-speed-fpm") / 100);
});
	
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

## SOUNDS
#########

# seatbelt/no smoking sign triggers
setlistener("controls/switches/seatbelt-sign", func
 {
 props.globals.getNode("sim/sound/seatbelt-sign").setBoolValue(1);

 settimer(func
  {
  props.globals.getNode("sim/sound/seatbelt-sign").setBoolValue(0);
  }, 2);
 });
setlistener("controls/switches/no-smoking-sign", func
 {
 props.globals.getNode("sim/sound/no-smoking-sign").setBoolValue(1);

 settimer(func
  {
  props.globals.getNode("sim/sound/no-smoking-sign").setBoolValue(0);
  }, 2);
 });

setlistener("controls/switches/switch",
	func {
		if(!getprop("controls/switches/switch")) return;
 		settimer(
 			func {
  				props.globals.getNode("controls/switches/switch").setBoolValue(0);
 			}
 		, 0.1);
 	}
 );

var aglgears = func {
    var agl = getprop("/position/altitude-agl-ft") or 0;
    var aglft = agl - 8.004;  # is the position from the Boeing 737 above ground
    var aglm = aglft * 0.3048;
    setprop("/position/gear-agl-ft", aglft);
    setprop("/position/gear-agl-m", aglm);

    settimer(aglgears, 0.01);
}

aglgears();

##########  Fuel System ##########
setlistener("/sim/signals/fdm-initialized", func {
print("Fuel Nasal Controls: Initializing, please wait");
});

var fuelsys = func {

    var pump_left = getprop("/controls/fuel/tank[2]/pump-left");
    var pump_right = getprop("/controls/fuel/tank[2]/pump-right");

    if (!pump_left and !pump_right) {
        setprop("consumables/fuel/tank[2]/selected", 0);
    } else {
       setprop("consumables/fuel/tank[2]/selected", 1);
       boeing737.fuelsys();
    }
}

