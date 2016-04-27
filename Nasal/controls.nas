##

var roundToNearest = func(n, m) {
	var x = int(n/m)*m;
	if((math.mod(n,m)) > (m/2) and n > 0)
			x = x + m;
	if((m - (math.mod(n,m))) > (m/2) and n < 0)
			x = x - m;
	return x;
}

var TRIM_RATE = 0.01;

var elevatorTrim = func {
	var ap_a_on = getprop("/autopilot/internal/CMDA");
	var ap_b_on = getprop("/autopilot/internal/CMDB");
	var stab_pos = num( getprop("/fdm/jsbsim/fcs/stabilizer-pos-unit") );
	var flaps_pos = num( getprop("/fdm/jsbsim/fcs/flap-pos-norm") );

	if (ap_a_on or ap_b_on) {
		autopilot737.ap_disengage();
	}

	setprop("fdm/jsbsim/fcs/stabilizer/stab-target", arg[0] * -17);

	if (stab_pos > 14.5 and arg[0]*-1 == 1) setprop( "fdm/jsbsim/fcs/stabilizer/stab-target", stab_pos );
	if (stab_pos < 3.95 and arg[0]*-1 == -1 and flaps_pos == 0) setprop( "fdm/jsbsim/fcs/stabilizer/stab-target", stab_pos );
	if (stab_pos < 0.05 and arg[0]*-1 == -1 and flaps_pos > 0) setprop( "fdm/jsbsim/fcs/stabilizer/stab-target", stab_pos );

	
	settimer( elev_trim_stop, 0.1 );
}

var elev_trim_stop = func {
  var stab_pos = num( getprop("/fdm/jsbsim/fcs/stabilizer-pos-unit") );
  setprop("fdm/jsbsim/fcs/stabilizer/stab-target", stab_pos);
}

var trim_handler = func {
  var old_trim = num( getprop("b737/controls/trim/stabilizer-old") );
  if ( old_trim == nil ) old_trim = 0.0;
  var new_trim = num( getprop("/controls/flight/elevator-trim") );
  if ( new_trim == nil ) new_trim = 0.0;
  var delta = new_trim - old_trim;
  setprop( "b737/controls/trim/stabilizer-old", new_trim );
  if( delta > 0.0 ) elevatorTrim(1);
  if( delta < 0.0 ) elevatorTrim(-1);
}
setlistener( "/controls/flight/elevator-trim", trim_handler );

var elev_trim_rate = func {
	var ap_a_on = getprop("/autopilot/internal/CMDA");
	var ap_b_on = getprop("/autopilot/internal/CMDB");
	var flaps_pos = num( getprop("/fdm/jsbsim/fcs/flap-pos-norm") );

	var trim_speed = 0.38;                                                    #Fastest with flaps extended and manual control
	if (flaps_pos == 0 and !ap_a_on and !ap_b_on) trim_speed = 0.2; #With flaps retracted and AP off
	if (flaps_pos > 0 and (ap_a_on or ap_b_on)) trim_speed = 0.2725;   #With flaps extended and AP on
	if (flaps_pos == 0 and (ap_a_on or ap_b_on)) trim_speed = 0.09;  #With flaps retracted and AP on
	setprop("fdm/jsbsim/fcs/stabilizer/trim-rate", trim_speed);
}
setlistener( "/autopilot/internal/CMDA", elev_trim_rate, 0, 0);
setlistener( "/autopilot/internal/CMDB", elev_trim_rate, 0, 0);
setlistener( "/fdm/jsbsim/fcs/flap-pos-norm", elev_trim_rate, 0, 0);
elev_trim_rate();

var stop_stab_move = func {
	var ap_a_on = getprop("/autopilot/internal/CMDA");
	var ap_b_on = getprop("/autopilot/internal/CMDB");
	if (!ap_a_on and !ap_b_on) setprop( "fdm/jsbsim/fcs/stabilizer/stab-target", getprop("/fdm/jsbsim/fcs/stabilizer-pos-unit") );
}
setlistener( "/autopilot/internal/CMDA", stop_stab_move, 0, 0);
setlistener( "/autopilot/internal/CMDB", stop_stab_move, 0, 0);
############################################
#### SPOILERS
############################################
var spoilers_control = func {
  var lever_pos = num( getprop("b737/controls/flight/spoilers-lever-pos") );

  if (lever_pos == 0) {
    setprop( "/controls/flight/speedbrake", 0.00 );
    if (getprop("/sim/messages/copilot") == "Spoilers DOWN!") { } else {
    if (getprop("sim/co-pilot")) setprop ("/sim/messages/copilot", "Spoilers DOWN!");}
    setprop("b737/sound/spoiler-auto", 0);
  }
  if (lever_pos == 1) {
    setprop( "/controls/flight/speedbrake", 0.00 );
    if (getprop("/sim/messages/copilot") == "Spoilers ARMED!") { } else {
    if (getprop("sim/co-pilot")) setprop ("/sim/messages/copilot", "Spoilers ARMED!");}
  }
  if (lever_pos == 2) setprop( "/controls/flight/speedbrake", 0.1625 );
  if (lever_pos == 3) {
    setprop( "/controls/flight/speedbrake", 0.325 );
    setprop( "/controls/flight/spoilers", 0 );
  }
  if (lever_pos == 4) {
    setprop( "/controls/flight/speedbrake", 0.4875 );

    var wow_right = getprop("/gear/gear[2]/wow");
    if (wow_right) setprop( "/controls/flight/spoilers", 1 );
    if (!wow_right) setprop( "/controls/flight/spoilers", 0 );

    var height = getprop("/position/altitude-agl-ft");
    var time = height / 70;
    if (time < 0.2 or time > 600) time = 0.2;
    settimer(spoilers_control, time);
  }
  if (lever_pos == 5) {
    setprop( "/controls/flight/speedbrake", 0.65 );

    var wow_right = getprop("/gear/gear[2]/wow");
    if (wow_right) setprop( "/controls/flight/spoilers", 1 );
    if (!wow_right) setprop( "/controls/flight/spoilers", 0 );

    if (getprop("/sim/messages/copilot") == "Spoilers at FLIGHT DETENT!") { } else {
    if (getprop("sim/co-pilot")) setprop ("/sim/messages/copilot", "Spoilers at FLIGHT DETENT!");}

    var height = getprop("/position/altitude-agl-ft");
    var time = height / 70;
    if (time < 0.2 or time > 600) time = 0.2;
    settimer(spoilers_control, time);
  }
  if (lever_pos == 6) {
    setprop( "/controls/flight/speedbrake", 1.00 );

    var wow_right = getprop("/gear/gear[2]/wow");
    if (wow_right) setprop( "/controls/flight/spoilers", 1 );
    if (!wow_right) setprop( "/controls/flight/spoilers", 0 );

    if (getprop("/sim/messages/copilot") == "Spoilers UP!") { } else {
    if (getprop("sim/co-pilot")) setprop ("/sim/messages/copilot", "Spoilers UP!");}

    var height = getprop("/position/altitude-agl-ft");
    var time = height / 70;
    if (time < 0.2 or time > 600) time = 0.2;
    settimer(spoilers_control, time);
  }
}

setlistener( "/b737/controls/flight/spoilers-lever-pos", spoilers_control, 0, 0 );

var landing_check = func{
	var air_ground = getprop("/b737/sensors/air-ground");
	var spin_up = getprop("/b737/sensors/main-gear-spin");
	var was_ia = getprop("/b737/sensors/was-in-air");
	var landing = getprop("/b737/sensors/landing");
	var lever_pos = num( getprop("b737/controls/flight/spoilers-lever-pos") );
	var throttle_1 = getprop("/autopilot/internal/servo-throttle[0]");
	var throttle_2 = getprop("/autopilot/internal/servo-throttle[1]");
	var ab_pos = getprop("/controls/gear/autobrakes");
	var ab_used = getprop("/fdm/jsbsim/fcs/autobrake/autobrake-used");

	if ((air_ground == "ground" or spin_up) and was_ia and throttle_1 < 0.05 and throttle_2 < 0.05 and !landing) { #normal landing
		if (lever_pos == 1) {
			setprop("b737/controls/flight/spoilers-lever-pos", 6);
			setprop("b737/sound/spoiler-auto", 1);
		}
		if (ab_pos > 0 and !ab_used) autobrake_apply();
		setprop("/b737/sensors/landing-time", getprop("/fdm/jsbsim/sim-time-sec"));
		settimer(func {setprop("/autopilot/internal/SPD", 0);},2);
		setprop("/b737/sensors/landing", 1);
	} elsif (air_ground == "ground" and !was_ia and spin_up and getprop("/controls/engines/engine[0]/throttle") < 0.05 and getprop("/controls/engines/engine[1]/throttle") < 0.05 and ab_pos == -1) { #Rejected take-off
		var GROUNDSPEED = getprop("/velocities/uBody-fps") * 0.593;
		setprop("/autopilot/internal/SPD", 0);
		if (lever_pos == 0) {
			setprop("b737/controls/flight/spoilers-lever-pos", 6);
			setprop("b737/sound/spoiler-auto", 1);
		}

		if (!ab_used and GROUNDSPEED > 88) { # 88 kts - value from AMM
			autobrake_apply();
		}
	}

    var height = getprop("/position/altitude-agl-ft");
    var time = height / 70;
    if (time < 0.2 or time > 600) time = 0.2;

    settimer(landing_check, time);
}
landing_check();


var ab_reset = func{
	var ab_pos = getprop("/controls/gear/autobrakes");
	var ab_used = getprop("/fdm/jsbsim/fcs/autobrake/autobrake-used");
	var ab_start_time = getprop("/fdm/jsbsim/fcs/autobrake/start-time-sec");

	if (ab_pos == 0 and ab_used) {
		setprop("/fdm/jsbsim/fcs/autobrake/autobrake-used", 0);
		setprop("/fdm/jsbsim/fcs/autobrake/start-time-sec", 0);
	}

}
setlistener( "/controls/gear/autobrakes", ab_reset, 0, 0);

var autobrake_apply = func {
	var ab_pos = getprop("/controls/gear/autobrakes");
	var ab_used = getprop("/fdm/jsbsim/fcs/autobrake/autobrake-used");
	var ab_start_time = getprop("/fdm/jsbsim/fcs/autobrake/start-time-sec");

	if (!ab_used) setprop("/fdm/jsbsim/fcs/autobrake/autobrake-in-use", 1);
	if (!ab_used) setprop("/fdm/jsbsim/fcs/autobrake/autobrake-used", 1);
	if (ab_start_time == 0 ) setprop("/fdm/jsbsim/fcs/autobrake/start-time-sec", getprop("/fdm/jsbsim/sim-time-sec"));

	if (ab_pos == 1) setprop("/fdm/jsbsim/fcs/autobrake/target-decel-fps_sec2", 4);
	if (ab_pos == 2) setprop("/fdm/jsbsim/fcs/autobrake/target-decel-fps_sec2", 5);
	if (ab_pos == 3) setprop("/fdm/jsbsim/fcs/autobrake/target-decel-fps_sec2", 7.2);
	if (ab_pos == 4) setprop("/fdm/jsbsim/fcs/autobrake/target-decel-fps_sec2",14);
	if (ab_pos == -1) setprop("/fdm/jsbsim/fcs/autobrake/target-decel-fps_sec2",25);
}

var left_brake = func {
	var ab_in_use = getprop("/fdm/jsbsim/fcs/autobrake/autobrake-in-use");
	var left_brake_cmd = getprop("/controls/gear/brake-left");
	var parking_brake_cmd = getprop("/controls/gear/brake-parking");

	if (ab_in_use) setprop("/fdm/jsbsim/fcs/autobrake/autobrake-in-use", 0);
	if (!parking_brake_cmd) {
		setprop("/fdm/jsbsim/fcs/brake-left-cmd", left_brake_cmd);
	} else {
		setprop("/fdm/jsbsim/fcs/brake-left-cmd", parking_brake_cmd);
	}
}
setlistener( "/controls/gear/brake-left", left_brake, 0, 0);

var right_brake = func {
	var ab_in_use = getprop("/fdm/jsbsim/fcs/autobrake/autobrake-in-use");
	var right_brake_cmd = getprop("/controls/gear/brake-right");
	var parking_brake_cmd = getprop("/controls/gear/brake-parking");

	if (ab_in_use) setprop("/fdm/jsbsim/fcs/autobrake/autobrake-in-use", 0);
	if (!parking_brake_cmd) {
		setprop("/fdm/jsbsim/fcs/brake-right-cmd", right_brake_cmd);
	} else {
		setprop("/fdm/jsbsim/fcs/brake-right-cmd", parking_brake_cmd);
	}
}
setlistener( "/controls/gear/brake-right", right_brake, 0, 0);

var parking_brake = func {
	var parking_brake_cmd = getprop("/controls/gear/brake-parking");

	setprop("/fdm/jsbsim/fcs/brake-right-cmd", parking_brake_cmd);
	setprop("/fdm/jsbsim/fcs/brake-left-cmd", parking_brake_cmd);
}
setlistener( "/controls/gear/brake-parking", parking_brake, 0, 0);

var parking_brake_set = func {
	setprop("/controls/gear/brake-parking", 1);
	setprop("/sim/menubar/visibility", "true");
}
settimer (parking_brake_set, 2);

# EFIS controls

var efis_ctrl = func(n, knob, action) {
	if (knob == "RANGE") {
		var range_knob = getprop("/instrumentation/efis["~n~"]/inputs/range-knob") + action;
		if (range_knob < 0) range_knob = 0;
		if (range_knob > 7) range_knob = 7;
		setprop("/instrumentation/efis["~n~"]/inputs/range-nm", 10*math.pow(2,range_knob-1));
		setprop("/instrumentation/efis["~n~"]/inputs/range-knob",range_knob);
	} elsif (knob == "MODE") {
		var mode_knob = getprop("instrumentation/efis["~n~"]/mfd/mode-num") + action;
		if (mode_knob < 0) mode_knob = 0;
		if (mode_knob > 3) mode_knob = 3;
		if (mode_knob == 0) {setprop("instrumentation/efis["~n~"]/mfd/display-mode", "APP"); setprop("instrumentation/efis["~n~"]/trk-selected", 0);}
		if (mode_knob == 1) {setprop("instrumentation/efis["~n~"]/mfd/display-mode", "VOR"); setprop("instrumentation/efis["~n~"]/trk-selected", 0);}
		if (mode_knob == 2) {setprop("instrumentation/efis["~n~"]/mfd/display-mode", "MAP"); setprop("instrumentation/efis["~n~"]/trk-selected", 1);}
		if (mode_knob == 3) {setprop("instrumentation/efis["~n~"]/mfd/display-mode", "PLAN"); setprop("instrumentation/efis["~n~"]/trk-selected", 0);}
		setprop("instrumentation/efis["~n~"]/mfd/mode-num", mode_knob);
	} elsif (knob == "BARO") {
		var pressureUnit = getprop("instrumentation/efis["~n~"]/inputs/kpa-mode");
		var baroStdSet = getprop("instrumentation/efis["~n~"]/inputs/setting-std");
		if (baroStdSet == 0) {
			if (pressureUnit == 1) {
				var altimeter_setting = roundToNearest(getprop("instrumentation/altimeter["~n~"]/setting-hpa"), 1);
				setprop("instrumentation/altimeter["~n~"]/setting-hpa", altimeter_setting + action);
			} else {
				var altimeter_setting = roundToNearest(getprop("instrumentation/altimeter["~n~"]/setting-inhg"), 0.01);
				setprop("instrumentation/altimeter["~n~"]/setting-inhg", altimeter_setting + action*0.01);
			}
		} else {
			setprop("instrumentation/efis["~n~"]/inputs/baro-previous-show", 1);
			if (pressureUnit == 1) {
				var altimeter_setting = roundToNearest(getprop("instrumentation/efis["~n~"]/inputs/baro-previous"), 1);
				setprop("instrumentation/efis["~n~"]/inputs/baro-previous", altimeter_setting + action);
			} else {
				var altimeter_setting = roundToNearest(getprop("instrumentation/efis["~n~"]/inputs/baro-previous"), 0.01);
				setprop("instrumentation/efis["~n~"]/inputs/baro-previous", altimeter_setting + action*0.01);
			}
		}
	} elsif (knob == "STD") {
		var baroStdSet = getprop("instrumentation/efis["~n~"]/inputs/setting-std");
		var pressureUnit = getprop("instrumentation/efis["~n~"]/inputs/kpa-mode");
		if (baroStdSet == 0) {
			setprop("instrumentation/efis["~n~"]/inputs/baro-previous-show", 0);
			if (pressureUnit == 1) {
				var altimeter_setting = roundToNearest(getprop("instrumentation/altimeter["~n~"]/setting-hpa"), 1);
				setprop("instrumentation/efis["~n~"]/inputs/baro-previous", altimeter_setting);
			} else {
				var altimeter_setting = roundToNearest(getprop("instrumentation/altimeter["~n~"]/setting-inhg"), 0.01);
				setprop("instrumentation/efis["~n~"]/inputs/baro-previous", altimeter_setting);
			}
			setprop("instrumentation/altimeter["~n~"]/setting-inhg", 29.92);
			setprop("instrumentation/efis["~n~"]/inputs/setting-std", 1);
		} else {
			if (pressureUnit == 1) {
				var altimeter_setting = roundToNearest(getprop("instrumentation/efis["~n~"]/inputs/baro-previous"), 1);
				setprop("instrumentation/altimeter["~n~"]/setting-hpa", altimeter_setting);
			} else {
				var altimeter_setting = roundToNearest(getprop("instrumentation/efis["~n~"]/inputs/baro-previous"), 0.01);
				setprop("instrumentation/altimeter["~n~"]/setting-inhg", altimeter_setting);
			}
			setprop("instrumentation/efis["~n~"]/inputs/setting-std", 0);
		}
	} elsif (knob == "BAROUNIT") {
		var pressureUnit = getprop("instrumentation/efis["~n~"]/inputs/kpa-mode");
		if (pressureUnit == 1 and action == -1) {
			setprop("instrumentation/efis["~n~"]/inputs/baro-previous", getprop("instrumentation/efis["~n~"]/inputs/baro-previous")*0.0295300586467);
			setprop("instrumentation/efis["~n~"]/inputs/kpa-mode", 0);
		} elsif (pressureUnit == 0 and action == 1) {
			setprop("instrumentation/efis["~n~"]/inputs/baro-previous", getprop("instrumentation/efis["~n~"]/inputs/baro-previous")/0.0295300586467);
			setprop("instrumentation/efis["~n~"]/inputs/kpa-mode", 1);
		}
	}
}

#tiller controls

var tiller_left = func() {
	var tiller = gui.Dialog.new("/sim/gui/dialogs/b737/menu/dialog","Aircraft/737-800/Dialogs/tiller-steering.xml");
    tiller.open();
    var tillerpos = getprop("/fdm/jsbsim/fcs/tiller-cmd-norm");
    tillerpos = tillerpos -  0.05;
    if ( tillerpos < -1 ) tillerpos = -1;
    interpolate("/fdm/jsbsim/fcs/tiller-cmd-norm", tillerpos, 0.3);
}

var tiller_left_small = func() {
	var tiller = gui.Dialog.new("/sim/gui/dialogs/b737/menu/dialog","Aircraft/737-800/Dialogs/tiller-steering.xml");
    tiller.open();
    var tillerpos = getprop("/fdm/jsbsim/fcs/tiller-cmd-norm");
    tillerpos = tillerpos -  0.02;
    if ( tillerpos < -1 ) tillerpos = -1;
    interpolate("/fdm/jsbsim/fcs/tiller-cmd-norm", tillerpos, 0.3);
}

var tiller_right = func() {
	var tiller = gui.Dialog.new("/sim/gui/dialogs/b737/menu/dialog","Aircraft/737-800/Dialogs/tiller-steering.xml");
    tiller.open();
    var tillerpos = getprop("/fdm/jsbsim/fcs/tiller-cmd-norm");
    tillerpos = tillerpos +  0.05;
    if ( tillerpos > 1 ) tillerpos = 1;
    interpolate("/fdm/jsbsim/fcs/tiller-cmd-norm", tillerpos, 0.3);
}

var tiller_right_small = func() {
	var tiller = gui.Dialog.new("/sim/gui/dialogs/b737/menu/dialog","Aircraft/737-800/Dialogs/tiller-steering.xml");
    tiller.open();
    var tillerpos = getprop("/fdm/jsbsim/fcs/tiller-cmd-norm");
    tillerpos = tillerpos +  0.02;
    if ( tillerpos > 1 ) tillerpos = 1;
    interpolate("/fdm/jsbsim/fcs/tiller-cmd-norm", tillerpos, 0.3);
}

var tiller_center = func() {
	var tiller = gui.Dialog.new("/sim/gui/dialogs/b737/menu/dialog","Aircraft/737-800/Dialogs/tiller-steering.xml");
    tiller.open();
    interpolate("/fdm/jsbsim/fcs/tiller-cmd-norm", 0, 0.5);
}
