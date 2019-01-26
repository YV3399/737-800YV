# B737-800 Systems File

# :)
print(" ____ ______ ____ ______      ___   ___   ___  ");
print("|  _ \____  |___ \____  |    / _ \ / _ \ / _ \ ");
print("| |_) |  / /  __) |  / /____| (_) | | | | | | |");
print("|  _ <  / /  |__ <  / /______> _ <| | | | | | |");
print("| |_) |/ /   ___) |/ /      | (_) | |_| | |_| |");
print("|____//_/   |____//_/        \___/ \___/ \___/ ");
print("-----------------------------------------------------------------------");
print("(c) 2017-2018 Gabriel Hernandez (YV3399), Joshua Davidson (it0uchpods)");
print("Report all bugs on GitHub Issues tab, or the forums. :)");
print("Enjoy your flight!!!");
print("-----------------------------------------------------------------------");
print(" ");

setprop("/instrumentation/attitude-indicator/spin", 1);
setprop("/options/OHPtemp", 1);

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
	systems.elec_init();
	systems.hyd_init();
	boeing737.shaketimer.start();
});

setprop("/it-autoflight/input/kts-mach", 0);
setprop("/it-autoflight/input/ap1", 0);
setprop("/it-autoflight/input/ap2", 0);
setprop("/it-autoflight/input/athr", 0);
setprop("/it-autoflight/input/fd1", 0);
setprop("/it-autoflight/input/fd2", 0);
setprop("/it-autoflight/input/spd-kts", 100);
setprop("/it-autoflight/input/spd-mach", 0.5);
setprop("/it-autoflight/input/hdg", 360);
setprop("/it-autoflight/input/alt", 10000);
setprop("/it-autoflight/input/vs", 0);
setprop("/it-autoflight/input/lat", 0);
setprop("/it-autoflight/input/vert", 4);
setprop("/it-autoflight/input/bank-limit", 30);
setprop("/it-autoflight/input/trk", 0);
setprop("/it-autoflight/output/ap1", 0);
setprop("/it-autoflight/output/ap2", 0);
setprop("/it-autoflight/output/at", 0);
setprop("/it-autoflight/output/fd1", 0);
setprop("/it-autoflight/output/fd2", 0);
setprop("/it-autoflight/output/loc-armed", 0);
setprop("/it-autoflight/output/appr-armed", 0);
setprop("/it-autoflight/output/thr-mode", 0);
setprop("/it-autoflight/output/retard", 0);
setprop("/it-autoflight/internal/alt", 10000);
	
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
 setlistener("controls/doors/cockpitdoor/sound",
	func {
		if(!getprop("controls/doors/cockpitdoor/sound")) return;
 		settimer(
 			func {
  				props.globals.getNode("controls/doors/cockpitdoor/sound").setBoolValue(0);
 			}
 		, 3);
 	}
 );
setlistener("controls/lighting/landing-lights",
	func {
		if(getprop("controls/lighting/landing-lights")) setprop("controls/lighting/landing-lights-norm",1); else setprop("controls/lighting/landing-lights-norm",0);
	}
);


var aglgears = func {
    var agl = getprop("/position/altitude-agl-ft") or 0;
    var aglft = agl - 8.194;  # is the position from the Boeing 737 above ground
    var aglm = aglft * 0.3048;
    setprop("/position/gear-agl-ft", aglft);
    setprop("/position/gear-agl-m", aglm);

    settimer(aglgears, 0.01);
}

aglgears();

# selected engine system
props.globals.initNode("sim/input/selected/SelectedEngine738", 0, "INT");
setlistener("sim/input/selected/SelectedEngine738", func {
	a = getprop("sim/input/selected/SelectedEngine738");
	if (a == 0) {
		setprop("sim/input/selected/engine", 1);
		setprop("sim/input/selected/engine[1]", 1);
	} else if(a == 1) {
		setprop("sim/input/selected/engine", 0);
		setprop("sim/input/selected/engine[1]", 1);

	} else if(a == -1) {
		setprop("sim/input/selected/engine", 1);
		setprop("sim/input/selected/engine[1]", 0);
	}
});