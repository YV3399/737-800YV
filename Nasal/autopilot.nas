##

##########################################################################
# Rotating VS knob
var adjust_vs_factor = func {
if (getprop("/autopilot/internal/VNAV-VS") == 1) {
	var vs_knob = getprop("/autopilot/settings/vertical-speed-knob");
	var vs = vs_knob * 50;

	if (vs_knob >  20) vs = vs + (vs_knob - 20) * 50;
	if (vs_knob < -20) vs = vs + (vs_knob + 20) * 50;

	setprop ("/autopilot/settings/vertical-speed-fpm", vs);
}
if (getprop("/autopilot/internal/VNAV-VS-armed")) {
	settimer(vs_button_press, 0.05);
}
}

setprop("/autopilot/internal/VNAV-VS", 1);
adjust_vs_factor(); # first run to create properties
setprop("/autopilot/internal/VNAV-VS", 0);
setlistener( "/autopilot/settings/vertical-speed-knob", adjust_vs_factor, 0, 0);

##########################################################################
# VS button
var vs_button_press = func {
var GS = getprop("/autopilot/internal/VNAV-GS");
var VS = getprop("/autopilot/internal/VNAV-VS");
if (!GS) {

if (VS) {
	setprop("/autopilot/internal/VNAV-VS", 0);

	setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/pitch-mode", "");
} else {
	if (getprop("/autopilot/internal/TOGA")) {
		var mcp_speed = getprop("/autopilot/settings/target-speed-kt");
		setprop("/autopilot/settings/target-speed-kt", mcp_speed + 20);
	}

	setprop("/autopilot/internal/VNAV-VS-armed", 0);
	reset_pitch_mode();

	var vs_fpm_current = getprop("/autopilot/internal/current-vertical-speed-fpm");

	if (vs_fpm_current < 1000 and vs_fpm_current > -1000) {
		var round_value = 50;
	} else {
		var round_value = 100;
	}
	vs_fpm_current = math.round(vs_fpm_current, round_value);

	if (vs_fpm_current < -7900) vs_fpm_current = -7900;
	if (vs_fpm_current > 6000) vs_fpm_current = 6000;

	var vs_knob = vs_fpm_current / 50;
	if (vs_fpm_current >  1000) vs_knob = vs_knob - (vs_fpm_current - 1000) / 100;
	if (vs_fpm_current < -1000) vs_knob = vs_knob - (vs_fpm_current + 1000) / 100;
	setprop("/autopilot/internal/VNAV-VS", 1);

	setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/pitch-mode", "V/S");

	speed_engage();

	setprop("/autopilot/settings/vertical-speed-knob", vs_knob);
	settimer(adjust_vs_factor, 0.1);
}
}
}

##########################################################################
# MCP ALT change while in ALT ACQ
var mcp_alt_change = func {
	var mcp_alt = getprop("/autopilot/settings/target-altitude-mcp-ft");
	var diff_acq = math.abs(getprop("/autopilot/settings/alt-acq-target-alt") - mcp_alt);
	var diff_hld = math.abs(getprop("/instrumentation/altimeter/indicated-altitude-ft") - mcp_alt);

	if (getprop("/autopilot/internal/VNAV-ALT-ACQ") and diff_acq > 100) {
		vs_button_press();
	}
	if (getprop("/autopilot/internal/VNAV-ALT") and diff_hld > 100) {
		setprop("/autopilot/internal/VNAV-VS-armed", 1);
	} else {
		setprop("/autopilot/internal/VNAV-VS-armed", 0);
	}
	setprop("/b737/sound/mcp-last-change", getprop("/sim/time/elapsed-sec"));
}
setlistener( "/autopilot/settings/target-altitude-mcp-ft", mcp_alt_change, 0, 0);

##########################################################################
# LVL CHG button
var lvlchg_button_press = func {

	if (getprop("/autopilot/internal/TOGA")) {
		var mcp_speed = getprop("/autopilot/settings/target-speed-kt");
		setprop("/autopilot/settings/target-speed-kt", mcp_speed + 20);
	}

var GS = getprop("/autopilot/internal/VNAV-GS");

if (!GS) {
	reset_pitch_mode();
	setprop("/autopilot/internal/VNAV-VS-armed", 0);

	if (getprop("/autopilot/internal/LVLCHG") == 1) {
		setprop("/autopilot/internal/LVLCHG", 0);

		setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/pitch-mode", "");

	} else {
		setprop("/autopilot/internal/SPD-SPEED", 0);
		setprop("/autopilot/internal/LVLCHG", 1);

		setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/pitch-mode", "MCP SPD");

		var alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		var alt_target = getprop("/autopilot/settings/target-altitude-mcp-ft");
		if (alt < alt_target) {
			n1_engage();
			setprop("/autopilot/settings/min-lvlchg-vs", 0);
			setprop("/autopilot/settings/max-lvlchg-vs", 6000);
		} else {
			retard_engage();
			setprop("/autopilot/settings/min-lvlchg-vs", -7800);
			setprop("/autopilot/settings/max-lvlchg-vs", 0);
		}
	}
}
}

##########################################################################
# Changeover button
var changeover_button_press = func {

	var a = getprop("/fdm/jsbsim/atmosphere/a-fps");
	var ias = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
	if ( ias == nil ) ias = 0.001;
	if ( ias < 1 ) ias = 100;
	var tas = getprop("/instrumentation/airspeed-indicator/true-speed-kt");
	if ( tas == nil ) tas = 0.001;
	if ( tas == 0 ) tas = 0.001;

	if (getprop("/autopilot/internal/SPD-IAS")) {
		var target_ias = getprop("/autopilot/settings/target-speed-kt");
		var target_mach = math.round((target_ias * tas/ias) / ( a * 0.5924838012959), 0.01);
		if (target_mach < 0.60) {}#target_mach = 0.60;
		else {
			if (target_mach > 0.89) target_mach = 0.89;
			
			setprop("/autopilot/settings/target-speed-mach", target_mach);

			setprop("/autopilot/internal/SPD-IAS", 0);
			setprop("/autopilot/internal/SPD-MACH", 1);
		}
	} else {
		var target_mach = getprop("/autopilot/settings/target-speed-mach");
		var target_ias = math.round((target_mach * ias * a * 0.5924838012959) / tas, 1);
		if (target_ias > 399) target_ias = 399;
		if (target_ias < 100) target_ias = 100;
		setprop("/autopilot/settings/target-speed-kt", target_ias);

		setprop("/autopilot/internal/SPD-MACH", 0);
		setprop("/autopilot/internal/SPD-IAS", 1);
	}
}

##########################################################################
# SPEED knob behaviour
var speed_increase = func {
	if (getprop("/autopilot/internal/SPD-IAS")) {
		var target_ias = getprop("/autopilot/settings/target-speed-kt");
		target_ias = target_ias + 1;
		if (target_ias > 399) target_ias = 399;
		setprop("/autopilot/settings/target-speed-kt", target_ias);
	} else {
		var target_mach = getprop("/autopilot/settings/target-speed-mach");
		target_mach = target_mach + 0.01;
		if (target_mach > 0.89) target_mach = 0.89;
		setprop("/autopilot/settings/target-speed-mach", target_mach);
	}
}
var speed_decrease = func {
	if (getprop("/autopilot/internal/SPD-IAS")) {
		var target_ias = getprop("/autopilot/settings/target-speed-kt");
		target_ias = target_ias - 1;
		if (target_ias < 100) target_ias = 100;
		setprop("/autopilot/settings/target-speed-kt", target_ias);
	} else {
		var target_mach = getprop("/autopilot/settings/target-speed-mach");
		target_mach = target_mach - 0.01;
		if (target_mach < 0.60) target_mach = 0.60;
		setprop("/autopilot/settings/target-speed-mach", target_mach);
	}
}
##########################################################################
# N1 button
var n1_button_press = func {
var GS = getprop("/autopilot/internal/VNAV-GS");

if (!GS) {
	if (getprop("/autopilot/internal/SPD-N1")) {
		setprop("/autopilot/internal/SPD-N1", 0);

		setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/throttle-mode", "ARM");
	} else {
		n1_engage();
	}
}
}

var n1_engage = func {
var AT_arm = getprop("/autopilot/internal/SPD");
if (AT_arm) {
	setprop("/autopilot/internal/SPD-SPEED", 0);
	setprop("/autopilot/internal/TOGA", 0);
	setprop("/autopilot/internal/SPD-RETARD", 0);
	setprop("/autopilot/internal/SPD-N1", 1);
	setprop("/autopilot/internal/target-n1", getprop("/autopilot/settings/max-n1"));

	setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/throttle-mode", "N1");
}
}
##########################################################################
# SPEED button
var speed_button_press = func {
	if (getprop("/autopilot/internal/SPD-SPEED")) {
		setprop("/autopilot/internal/SPD-SPEED", 0);

		setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/throttle-mode", "ARM");
	} else {
		speed_engage();
	}

}

##########################################################################
# Engaging SPEED mode
var speed_engage = func {
var AT_arm = getprop("/autopilot/internal/SPD");
if (AT_arm) {
	setprop("/autopilot/internal/SPD-N1", 0);
	setprop("/autopilot/internal/TOGA", 0);
	setprop("/autopilot/internal/SPD-RETARD", 0);
	setprop("/autopilot/internal/SPD-SPEED", 1);

	setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/throttle-mode", "MCP SPD");
}
}

##########################################################################
# Engaging RETARD mode
var retard_engage = func {
var AT_arm = getprop("/autopilot/internal/SPD");
if (AT_arm) {
	setprop("/autopilot/internal/SPD-N1", 0);
	setprop("/autopilot/internal/TOGA", 0);
	setprop("/autopilot/internal/SPD-SPEED", 0);
	setprop("/autopilot/internal/SPD-RETARD", 1);

	setprop("/autopilot/internal/target-n1", 19.76);

	setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/throttle-mode", "RETARD");
}
}

var retard_check = func {
	var retard = getprop("/autopilot/internal/SPD-RETARD");
	if (retard) {
		if (getprop("/autopilot/internal/servo-throttle[0]") < 0.01) {
			setprop("/autopilot/internal/SPD-RETARD", 0);

			setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
			setprop("/autopilot/display/throttle-mode", "ARM");
		}
		settimer(retard_check, 0.2);
	}
}
setlistener( "/autopilot/internal/SPD-RETARD", retard_check, 0, 0);

var retard_27ft_check = func {
	var retard_cmd = getprop("/autopilot/logic/retard-27ft");
	if (retard_cmd) {
		retard_engage();
	}
}
setlistener("/autopilot/logic/retard-27ft", retard_27ft_check, 0, 0);

##########################################################################
# VNAV button
var vnav_button_press = func {

}

##########################################################################
# ALT HOLD button
var althld_button_press = func {

	if (getprop("/autopilot/internal/TOGA")) {
		var mcp_speed = getprop("/autopilot/settings/target-speed-kt");
		setprop("/autopilot/settings/target-speed-kt", mcp_speed + 20);
	}

	var GS = getprop("/autopilot/internal/VNAV-GS");

	if (!GS) {
		var alt_light = getprop("/autopilot/internal/VNAV-ALT-light");

		if (alt_light) {
			setprop("/autopilot/internal/VNAV-ALT", 0);

			setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
			setprop("/autopilot/display/pitch-mode", "");
		} else {
			setprop("/autopilot/internal/max-vs-fpm", 2000);
			setprop("/autopilot/internal/min-vs-fpm", -2000);

			alt_hold_engage();
		}
	}
}

##########################################################################
# ALT HOLD button light switch
var alt_hold_light = func {
	var mcp_alt = getprop("/autopilot/settings/target-altitude-mcp-ft");
	var diff_hld = math.abs(getprop("/instrumentation/altimeter/indicated-altitude-ft") - mcp_alt);
	var alt_hld = getprop("/autopilot/internal/VNAV-ALT");

	if (alt_hld and diff_hld > 50) {
		setprop("/autopilot/internal/VNAV-ALT-light", 1);
	} else {
		setprop("/autopilot/internal/VNAV-ALT-light", 0);
	}

	if (alt_hld) settimer(alt_hold_light, 0.5);
}
setlistener( "/autopilot/internal/VNAV-ALT", alt_hold_light, 0, 0);

##########################################################################
# APP button
var app_button_press = func {

	var GS  = getprop("/autopilot/internal/VNAV-GS");
	var LOC = getprop("/autopilot/internal/LNAV-NAV");
	if (!GS) {
		if (getprop("/autopilot/internal/VNAV-GS-armed")) {

			setprop("/autopilot/internal/VNAV-GS-armed", 0);

			if (getprop("/autopilot/internal/LNAV-NAV-armed")) {
				setprop("/autopilot/internal/LNAV-NAV-armed", 0);
				setprop("/autopilot/display/roll-mode-armed", "");
			}

		} else {
			setprop("/autopilot/internal/VNAV-GS-armed", 1);

			if (LOC==0) {
				setprop("/autopilot/internal/LNAV-NAV-armed", 1);
				setprop("/autopilot/display/roll-mode-armed", "VOR/LOC");
			}
		}
	}
}

##########################################################################
# LNAV button
var lnav_button_press = func {
	var route_active = getprop("/autopilot/route-manager/active");
	var GS = getprop("/autopilot/internal/VNAV-GS");
	var crosstrack = getprop("/instrumentation/gps/wp/wp[1]/course-error-nm");
	var LNAV = getprop("/autopilot/internal/LNAV-NAV");

	if (LNAV) {
		setprop("/autopilot/internal/LNAV", 0);

		setprop("/autopilot/display/roll-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/roll-mode", "");
	} else {
		if (!GS and route_active) {
			if (math.abs(crosstrack) < 3) {
				lnav_engage();
			} else {
				var course_true = getprop("/instrumentation/gps/wp/leg-true-course-deg");
				var bearing_true = getprop("/autopilot/route-manager/wp/true-bearing-deg");
				var track_true = getprop("/orientation/track-deg");

				var track_rel = geo.normdeg180(track_true - course_true);
				var bearing_rel = geo.normdeg180(bearing_true - course_true);

				if (bearing_rel < 0) {
					if (track_rel < bearing_rel and track_rel > -180) {
						lnav_engage();
					}
				} else {
					if (track_rel > bearing_rel and track_rel < 180) {
						lnav_engage();
					}
				}
			}
		}
	}
}

var lnav_engage = func {
	setprop("/autopilot/internal/LNAV-NAV-armed", 0);
	setprop("/autopilot/display/roll-mode-armed", "");

	setprop("/autopilot/internal/LNAV-NAV", 0);
	setprop("/autopilot/internal/LNAV-HDG", 0);
	setprop("/autopilot/internal/LNAV", 1);

	setprop("/autopilot/display/roll-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/roll-mode", "LNAV");
}
##########################################################################
# HDG button
var hdg_button_press = func {
	var GS  = getprop("/autopilot/internal/VNAV-GS");
	var HDG = getprop("/autopilot/internal/LNAV-HDG");

	if (HDG) {
		setprop("/autopilot/internal/LNAV-HDG", 0);

		setprop("/autopilot/display/roll-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/roll-mode", "");
	} elsif (!GS) {
		hdg_mode_engage();
	}
}

##########################################################################
# VORLOC button
var vorloc_button_press = func {
	var GS  = getprop("/autopilot/internal/VNAV-GS");
	var vor_light = getprop("/autopilot/internal/LNAV-NAV-light");

	if (vor_light) {
		if (getprop("/autopilot/internal/LNAV-NAV-armed")){
			setprop("/autopilot/internal/LNAV-NAV-armed", 0);
			setprop("/autopilot/display/roll-mode-armed", "");
		} else {
			setprop("/autopilot/internal/LNAV-NAV", 0);

			setprop("/autopilot/display/roll-mode-last-change", getprop("/sim/time/elapsed-sec"));
			setprop("/autopilot/display/roll-mode", "");
		}
	} elsif (!GS) {
		setprop("/autopilot/internal/LNAV-NAV-armed", 1);
		setprop("/autopilot/display/roll-mode-armed", "VOR/LOC");
	}
}

##########################################################################
# CMDA button
var cmda_button_press = func {
	var cmdb  = getprop("/autopilot/internal/CMDB");
	var ailerons = getprop("/controls/flight/aileron");
	var elevator = getprop("/controls/flight/elevator");
	var GS  = getprop("/autopilot/internal/VNAV-GS");
	var GS_arm  = getprop("/autopilot/internal/VNAV-GS-armed");
	var alt_agl = getprop("/position/altitude-agl-ft") - 6.5;
	var nav1 = getprop("/instrumentation/nav[0]/frequencies/selected-mhz");
	var nav2 = getprop("/instrumentation/nav[1]/frequencies/selected-mhz");

	if (cmdb and (GS or GS_arm) and alt_agl > 800 and nav1 == nav2) {
		setprop("/autopilot/internal/CMDA", 1);
	} elsif (ailerons < 0.15 and ailerons > -0.15 and elevator < 0.15 and elevator > -0.15) {
		setprop("/autopilot/internal/elevator", elevator);
		setprop("/autopilot/internal/CMDA", 1);
		setprop("/autopilot/internal/CMDB", 0);
		setprop("/autopilot/internal/FCC-B-master", 0);
		setprop("/autopilot/internal/FCC-A-master", 1);
		if (getprop("/autopilot/internal/TOGA")) {
			var mcp_speed = getprop("/autopilot/settings/target-speed-kt");
			setprop("/autopilot/settings/target-speed-kt", mcp_speed + 20);
			setprop("/autopilot/internal/TOGA", 0);
			lvlchg_button_press();
		}
	}
}

##########################################################################
# CMDB button
var cmdb_button_press = func {
	var cmda  = getprop("/autopilot/internal/CMDA");
	var ailerons = getprop("/controls/flight/aileron");
	var elevator = getprop("/controls/flight/elevator");
	var GS  = getprop("/autopilot/internal/VNAV-GS");
	var GS_arm  = getprop("/autopilot/internal/VNAV-GS-armed");
	var alt_agl = getprop("/position/altitude-agl-ft") - 6.5;
	var nav1 = getprop("/instrumentation/nav[0]/frequencies/selected-mhz");
	var nav2 = getprop("/instrumentation/nav[1]/frequencies/selected-mhz");

	if (cmda and (GS or GS_arm) and alt_agl > 800 and nav1 == nav2) {
		setprop("/autopilot/internal/CMDB", 1);
	} elsif (ailerons < 0.15 and ailerons > -0.15 and elevator < 0.15 and elevator > -0.15) {
		setprop("/autopilot/internal/elevator", elevator);
		setprop("/autopilot/internal/CMDB", 1);
		setprop("/autopilot/internal/CMDA", 0);
		setprop("/autopilot/internal/FCC-A-master", 0);
		setprop("/autopilot/internal/FCC-B-master", 1);
		if (getprop("/autopilot/internal/TOGA")) {
			var mcp_speed = getprop("/autopilot/settings/target-speed-kt");
			setprop("/autopilot/settings/target-speed-kt", mcp_speed + 20);
			setprop("/autopilot/internal/TOGA", 0);
			lvlchg_button_press();
		}
	}
}

##########################################################################
# CWSA button
var cwsa_button_press = func {

}

##########################################################################
# CWSB button
var cwsb_button_press = func {

}

##########################################################################
# APDSNG button
var apdsng_button_press = func {
	if (getprop("/b737/sound/apdisco")) {
		setprop("/b737/sound/apdisco", 0);
	} else {
		var cmda = getprop("/autopilot/internal/CMDA");
		var cmdb = getprop("/autopilot/internal/CMDB");
		if (cmda or cmdb) {
			ap_disengage();
			settimer(func {setprop("/b737/sound/apdisco", 0);}, 3.7);
		}
	}
}

##########################################################################
# AT switch logic
var at_arm_switch = func {
	var at_arm = getprop("/autopilot/internal/SPD");
	if (!at_arm) {
		setprop("/autopilot/internal/SPD-N1", 0);
		setprop("/autopilot/internal/TOGA", 0);
		setprop("/autopilot/internal/SPD-SPEED", 0);
		setprop("/autopilot/internal/SPD-RETARD", 0);

		setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/throttle-mode", "");
	} else {
		setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/throttle-mode", "ARM");
	}
}
setlistener("/autopilot/internal/SPD", at_arm_switch, 0, 0);

##########################################################################
# Automatic AP disengage at 350 ft if no FLARE armed
var apdsng = func {
	var apdsng = getprop("/autopilot/logic/ap-disengage-350ft");
	if (apdsng) {
		ap_disengage();
		setprop("/autopilot/logic/ap-disengage-350ft", 0);
	}
}
setlistener("/autopilot/logic/ap-disengage-350ft", apdsng, 0, 0);

##########################################################################
# AUTOPILOT DISENGAGE FUNCTION
var ap_disengage = func {
	setprop("/autopilot/internal/CMDA", 0);
	setprop("/autopilot/internal/CMDB", 0);
	var fd_left = getprop("/instrumentation/flightdirector/fd-left-on");
	var fd_right = getprop("/instrumentation/flightdirector/fd-right-on");
	var added_fcc = getprop("/autopilot/internal/FCC-added");

	if (added_fcc == "A") {
		setprop("/autopilot/internal/FCC-added", "");
		setprop("/autopilot/internal/FCC-A-master", 0);
	} elsif (added_fcc == "B") {
		setprop("/autopilot/internal/FCC-added", "");
		setprop("/autopilot/internal/FCC-B-master", 0);
	}

	if (!fd_left and !fd_right) {
		setprop("/autopilot/internal/FCC-A-master", 0);
		setprop("/autopilot/internal/FCC-B-master", 0);
	} elsif (fd_left and !fd_right) {
		setprop("/autopilot/internal/FCC-A-master", 1);
		setprop("/autopilot/internal/FCC-B-master", 0);
	} elsif (!fd_left and fd_right) {
		setprop("/autopilot/internal/FCC-A-master", 0);
		setprop("/autopilot/internal/FCC-B-master", 1);
	}

	setprop("/b737/sound/apdisco", 1);
}

##########################################################################
# Determining master FCC from FD switch
var fd_switch_left = func {
	var fd_left = getprop("/instrumentation/flightdirector/fd-left-on");
	var fd_right = getprop("/instrumentation/flightdirector/fd-right-on");
	var fcc_a = getprop("/autopilot/internal/FCC-A-master");
	var fcc_b = getprop("/autopilot/internal/FCC-B-master");
	var cmda  = getprop("/autopilot/internal/CMDA");
	var cmdb  = getprop("/autopilot/internal/CMDB");

	if (!cmda and !cmdb and !fcc_b and fd_left) {
		setprop("/autopilot/internal/FCC-A-master", 1);
	} elsif (!cmda and !cmdb and !fcc_b and !fd_left and !fd_right) {
		setprop("/autopilot/internal/FCC-A-master", 0);
		reset_pitch_roll_modes();
	} elsif (!cmda and !cmdb and !fcc_b and !fd_left and fd_right) {
		setprop("/autopilot/internal/FCC-A-master", 0);
		setprop("/autopilot/internal/FCC-B-master", 1);
	}
}
var fd_switch_right = func {
	var fd_left = getprop("/instrumentation/flightdirector/fd-left-on");
	var fd_right = getprop("/instrumentation/flightdirector/fd-right-on");
	var fcc_a = getprop("/autopilot/internal/FCC-A-master");
	var fcc_b = getprop("/autopilot/internal/FCC-B-master");
	var cmda  = getprop("/autopilot/internal/CMDA");
	var cmdb  = getprop("/autopilot/internal/CMDB");

	if (!cmda and !cmdb and !fcc_a and fd_right) {
		setprop("/autopilot/internal/FCC-B-master", 1);
	} elsif (!cmda and !cmdb and !fcc_a and !fd_right and !fd_left) {
		setprop("/autopilot/internal/FCC-B-master", 0);
		reset_pitch_roll_modes();
	} elsif (!cmda and !cmdb and !fcc_a and !fd_right and fd_left) {
		setprop("/autopilot/internal/FCC-B-master", 0);
		setprop("/autopilot/internal/FCC-A-master", 1);
	}
}

setlistener("/instrumentation/flightdirector/fd-right-on", fd_switch_right, 0, 0);
setlistener("/instrumentation/flightdirector/fd-left-on", fd_switch_left, 0, 0);

var reset_pitch_roll_modes = func {
	reset_pitch_mode();
	reset_roll_mode();

	setprop("/autopilot/internal/VNAV-VS-armed", 0);
	setprop("/autopilot/internal/VNAV-GS-armed", 0);
	setprop("/autopilot/internal/VNAV-FLARE-armed", 0);

	setprop("/autopilot/internal/LNAV-NAV-armed", 0);

	setprop("/autopilot/display/pitch-mode-armed", "");
	setprop("/autopilot/display/roll-mode-armed", "");
}

var reset_pitch_mode = func {
	setprop("/autopilot/internal/VNAV-ALT-ACQ", 0);
	setprop("/autopilot/internal/VNAV-VS", 0);
	setprop("/autopilot/internal/VNAV", 0);
	setprop("/autopilot/internal/LVLCHG", 0);
	setprop("/autopilot/internal/TOGA", 0);
	setprop("/autopilot/internal/GA", 0);
	setprop("/autopilot/internal/VNAV-ALT", 0);
	setprop("/autopilot/internal/VNAV-GS", 0);
	setprop("/autopilot/internal/VNAV-FLARE", 0);

	setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/pitch-mode", "");
}

var reset_roll_mode = func {
	setprop("/autopilot/internal/LNAV", 0);
	setprop("/autopilot/internal/LNAV-NAV", 0);
	setprop("/autopilot/internal/LNAV-HDG", 0);
	setprop("/autopilot/internal/GA-ROLL", 0);

	setprop("/autopilot/display/roll-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/roll-mode", "");
}
##########################################################################
##########################################################################
# Engaging ALT ACQ mode
var alt_acq_engage = func {

	var fcc_a = getprop("/autopilot/internal/FCC-A-master");
	var fcc_b = getprop("/autopilot/internal/FCC-B-master");
	if (fcc_a) {
		var alt_diff = getprop("/b737/helpers/alt-diff-ft[0]");
		var alt = getprop("/instrumentation/altimeter[0]/indicated-altitude-ft");
	} else {
		var alt_diff = getprop("/b737/helpers/alt-diff-ft[1]");
		var alt = getprop("/instrumentation/altimeter[1]/indicated-altitude-ft");
	}

	if (getprop("/autopilot/internal/VNAV-VS") or getprop("/autopilot/internal/LVLCHG") or getprop("/autopilot/internal/VNAV") or getprop("/autopilot/internal/TOGA") or getprop("/autopilot/internal/GA")) {
		var current_vs = getprop("/autopilot/internal/current-vertical-speed-fpm");
		var possible_engage_alt =  math.abs(current_vs * 0.15);


		if (alt_diff < 50 or alt_diff < possible_engage_alt) {

			if (getprop("/autopilot/internal/TOGA")) {
				var mcp_speed = getprop("/autopilot/settings/target-speed-kt");
				setprop("/autopilot/settings/target-speed-kt", mcp_speed + 20);
			}

			reset_pitch_mode();

			setprop("/autopilot/internal/VNAV-ALT-ACQ", 1);
			setprop("/autopilot/settings/alt-acq-target-alt", getprop("/autopilot/settings/target-altitude-mcp-ft"));

			setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
			setprop("/autopilot/display/pitch-mode", "ALT ACQ");

			speed_engage();
			if (current_vs > 0) {
				setprop("/autopilot/internal/max-vs-fpm", current_vs);
				setprop("/autopilot/internal/min-vs-fpm", -300);
			} else {
				setprop("/autopilot/internal/max-vs-fpm", 300);
				setprop("/autopilot/internal/min-vs-fpm", current_vs);
			}
		}
	}
	if (getprop("/autopilot/internal/VNAV-ALT-ACQ")) {
		if (alt_diff < 35) {
			var delta = getprop("/autopilot/settings/target-altitude-mcp-ft") - alt;
			setprop("/autopilot/settings/alt-hold-delta", delta);
			alt_hold_engage();
		}
	}
}
setlistener( "/b737/helpers/alt-diff-ft", alt_acq_engage, 0, 0);

##########################################################################
# Engaging ALT HOLD mode
var alt_hold_engage = func {

	if (getprop("/autopilot/internal/TOGA")) {
		var mcp_speed = getprop("/autopilot/settings/target-speed-kt");
		setprop("/autopilot/settings/target-speed-kt", mcp_speed + 20);
	}

	var delta = getprop("/autopilot/settings/alt-hold-delta");
	setprop("/autopilot/settings/alt-hold-delta", 0);

	if (getprop("/autopilot/internal/FCC-A-master")) {
		var alt_current = getprop("/instrumentation/altimeter[0]/pressure-alt-ft") + delta;
	} else {
		var alt_current = getprop("/instrumentation/altimeter[1]/pressure-alt-ft") + delta;
	}
	reset_pitch_mode();
	setprop("/autopilot/settings/target-alt-hold-ft", alt_current);
	setprop("/autopilot/internal/VNAV-ALT", 1);

	setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/pitch-mode", "ALT HOLD");

	speed_engage();
}

##########################################################################
# Arming FLARE mode
var flare_arm = func {
	var flare_arm = getprop("/autopilot/logic/flare-arm");
	if (flare_arm) {
		setprop("/autopilot/internal/VNAV-VS-armed", 0);
		setprop("/autopilot/internal/VNAV-FLARE-armed", 1);

		var fcc_a = getprop("/autopilot/internal/FCC-A-master");
		var fcc_b = getprop("/autopilot/internal/FCC-B-master");

		if (fcc_a) {
			setprop("/autopilot/internal/FCC-B-master", 1);
			setprop("/autopilot/internal/FCC-added", "B");
		} elsif (fcc_b) {
			setprop("/autopilot/internal/FCC-A-master", 1);
			setprop("/autopilot/internal/FCC-added", "A");
		}
	}
}
setlistener("/autopilot/logic/flare-arm", flare_arm, 0, 0);

##########################################################################
# Engaging FLARE mode
var flare_50ft_check = func {
	var flare_cmd = getprop("/autopilot/logic/flare-50ft");
	if (flare_cmd) {
		reset_pitch_mode();
		setprop("/autopilot/internal/VNAV-FLARE", 1);

		setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/pitch-mode", "FLARE");
		setprop("/autopilot/internal/VNAV-FLARE-armed", 0);
	}
}
setlistener("/autopilot/logic/flare-50ft", flare_50ft_check, 0, 0);

##########################################################################
# THR HLD at FMA
var thr_hld_84kts = func {
	var thr_hld = getprop("/autopilot/logic/thr-hld-84kts");
	if (thr_hld) {
		setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/throttle-mode", "THR HLD");
	}
}
setlistener("/autopilot/logic/thr-hld-84kts", thr_hld_84kts, 0, 0);

##########################################################################
# ARM at FMA after THR HLD
var at_arm_toga = func {
	var arm = getprop("/autopilot/logic/at-arm-toga");
	if (arm) {
		setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/throttle-mode", "ARM");
	}
}
setlistener("/autopilot/logic/at-arm-toga", at_arm_toga, 0, 0);

##########################################################################
# Engaging HDG SEL mode
var hdg_mode_engage = func {
	reset_roll_mode();
	setprop("/autopilot/internal/LNAV-HDG", 1);

	setprop("/autopilot/display/roll-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/roll-mode", "HDG SEL");
}

##########################################################################
# Armed VOR/LOC mode behaviour
var vorloc_armed = func {
if (getprop("/autopilot/internal/LNAV-NAV-armed")) {

	if (getprop("/autopilot/internal/FCC-A-master")) {
		var deflection = getprop("/instrumentation/nav[0]/heading-needle-deflection-norm");
		var course = getprop("/instrumentation/nav[0]/radials/target-radial-deg");
		var delta_target_heading = getprop("/autopilot/internal/target-heading-shift-nav1");
		var in_range = getprop("/instrumentation/nav[0]/in-range");
		var signal = getprop("/instrumentation/nav[0]/signal-quality-norm");
	} else {
		var deflection = getprop("/instrumentation/nav[1]/heading-needle-deflection-norm");
		var course = getprop("/instrumentation/nav[1]/radials/target-radial-deg");
		var delta_target_heading = getprop("/autopilot/internal/target-heading-shift-nav2");
		var in_range = getprop("/instrumentation/nav[1]/in-range");
		var signal = getprop("/instrumentation/nav[1]/signal-quality-norm");
	}

	var delta_current_heading = geo.normdeg180(getprop("/orientation/heading-deg") - course);

	if(((deflection < 0.2 and deflection > -0.2) or (deflection < 0.99 and deflection > -0.99 and math.abs(delta_target_heading) < math.abs(delta_current_heading))) and in_range and signal > 0.99){
		vorloc_mode_engage();
	}

	settimer(vorloc_armed, 0.5);
}
}

setlistener( "/autopilot/internal/LNAV-NAV-armed", vorloc_armed, 0, 0);

##########################################################################
# Armed GS mode behaviour
var app_armed = func {
if (getprop("/autopilot/internal/VNAV-GS-armed")) {

	if (getprop("/autopilot/internal/FCC-A-master")) {
		var deflection = getprop("/instrumentation/nav[0]/gs-needle-deflection-norm");
		var in_range = getprop("/instrumentation/nav[0]/gs-in-range");
		var signal = getprop("/instrumentation/nav[0]/signal-quality-norm");
	} else {
		var deflection = getprop("/instrumentation/nav[1]/gs-needle-deflection-norm");
		var in_range = getprop("/instrumentation/nav[1]/gs-in-range");
		var signal = getprop("/instrumentation/nav[1]/signal-quality-norm");
	}
	var LOC = getprop("/autopilot/internal/LNAV-NAV");
	if(deflection < 0.2 and deflection > -0.2 and LOC and in_range and signal > 0.99){
		gs_engage();
	}

	settimer(app_armed, 0.5);
}
}

setlistener( "/autopilot/internal/VNAV-GS-armed", app_armed, 0, 0);

##########################################################################
# Engaging VOR/LOC mode
var vorloc_mode_engage = func {
	setprop("/autopilot/internal/LNAV", 0);
	setprop("/autopilot/internal/LNAV-HDG", 0);
	setprop("/autopilot/internal/LNAV-NAV", 1);

	setprop("/autopilot/display/roll-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/roll-mode", "VOR/LOC");
	setprop("/autopilot/internal/LNAV-NAV-armed", 0);
	setprop("/autopilot/display/roll-mode-armed", "");
}

##########################################################################
# Engaging GLIDESLOPE	 mode
var gs_engage = func {
	reset_pitch_mode();
	setprop("/autopilot/internal/VNAV-GS", 1);

	setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/pitch-mode", "G/S");
	setprop("/autopilot/internal/VNAV-GS-armed", 0);
	setprop("/autopilot/internal/VNAV-VS-armed", 0);

	speed_engage();
}

##########################################################################
# TOGA button
var toga_button = func {
	var was_ia = getprop("/b737/sensors/was-in-air");
	if (!was_ia) {
		toga_engage();
	} else {
		var alt_agl = getprop("/position/altitude-agl-ft") - 6.5;
		var toga = getprop("/autopilot/internal/TOGA");
		if (!toga and alt_agl < 2000) { ga_engage(); }
	}
}

##########################################################################
# Engaging TOGA mode
var toga_engage = func {
	reset_pitch_mode();
	reset_roll_mode();
	setprop("/autopilot/internal/SPD-N1", 0);
	setprop("/autopilot/internal/SPD-SPEED", 0);
	setprop("/autopilot/internal/SPD-RETARD", 0);
	setprop("/autopilot/internal/TOGA", 1);

	#var derate_20k = getprop("/instrumentation/fmc/derated-to/method-derate-20k");
	#var assumed = getprop("/instrumentation/fmc/derated-to/method-assumed");
	#if (!derate_20k and !assumed) {
	#	var takeoff_n1 = getprop("/autopilot/settings/to-n1-22k");
	#} elsif (derate_20k and !assumed) {
	#	var takeoff_n1 = getprop("/autopilot/settings/to-n1-20k");
	#} elsif (!derate_20k and assumed) {
	#	var max_n1 = getprop("/autopilot/settings/assumed-max-n1-22k");
	#	var delta_n1 = getprop("/autopilot/settings/assumed-n1-delta-22k");
	#	var takeoff_n1 = max_n1 - delta_n1;
	#} elsif (derate_20k and assumed) {
	#	var max_n1 = getprop("/autopilot/settings/assumed-max-n1-20k");
	#	var delta_n1 = getprop("/autopilot/settings/assumed-n1-delta-20k");
	#	var takeoff_n1 = max_n1 - delta_n1;
	#}

	var takeoff_n1 = getprop("/autopilot/settings/to-n1-26k");

	setprop("/autopilot/internal/target-n1", takeoff_n1);

	setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/toga-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/pitch-mode", "TO/GA");
	setprop("/autopilot/internal/VNAV-VS-armed", 0);
	setprop("/autopilot/internal/VNAV-GS-armed", 0);
	setprop("/autopilot/internal/VNAV-FLARE-armed", 0);
	setprop("/autopilot/internal/LNAV-NAV-armed", 0);
	setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
	setprop("/autopilot/display/throttle-mode", "N1");

	setprop("/autopilot/settings/fcca-target-bank", 0);
	setprop("/autopilot/settings/fccb-target-bank", 0);
}

##########################################################################
# Engaging Go-Around mode
var ga_engage = func{
	var ga = getprop("/autopilot/internal/GA");

	if (ga) {
		setprop("/autopilot/internal/target-n1", getprop("/autopilot/settings/ga-n1"));

		if (getprop("sim/co-pilot")) {
			setprop("/sim/messages/copilot", "Maximum Go Around thrust!");
		}
	} else {
		var track = getprop("/orientation/track-deg");
		setprop("/autopilot/settings/ga-track-deg", track);

		setprop("/autopilot/internal/VNAV-VS-armed", 0);
		setprop("/autopilot/internal/VNAV-GS-armed", 0);
		setprop("/autopilot/internal/VNAV-FLARE-armed", 0);
		setprop("/autopilot/display/pitch-mode-armed", "");

		setprop("/autopilot/internal/SPD-N1", 0);
		setprop("/autopilot/internal/SPD-SPEED", 0);
		setprop("/autopilot/internal/SPD-RETARD", 0);

		reset_pitch_mode();
		reset_roll_mode();

		setprop("/autopilot/internal/GA", 1);
		setprop("/autopilot/internal/GA-ROLL", 1);

		setprop("/autopilot/internal/target-n1", getprop("/autopilot/settings/ga-n1") - getprop("/autopilot/settings/reduced-ga-n1-delta"));

		setprop("/autopilot/display/pitch-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/toga-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/pitch-mode", "TO/GA");

		setprop("/autopilot/display/throttle-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/throttle-mode", "GA");

		setprop("/autopilot/display/roll-mode", "");

		var cmda  = getprop("/autopilot/internal/CMDA");
		var cmdb  = getprop("/autopilot/internal/CMDB");
		if (cmda and !cmdb) {
			ap_disengage();
		} elsif (!cmda and cmdb) {
			ap_disengage();
		}

		if (getprop("sim/co-pilot") and getprop("/sim/messages/copilot")!="Go Around") {
			setprop("/sim/messages/copilot", "Go Around");
		}
	}
}
var ga_speed_round = func {
	var ga = getprop("/autopilot/internal/GA");
	if (!ga) {
		var mcp_speed = getprop("/autopilot/settings/target-speed-kt");
		mcp_speed = math.round(mcp_speed, 1);
		setprop("/autopilot/settings/target-speed-kt", mcp_speed);

		var cmda  = getprop("/autopilot/internal/CMDA");
		var cmdb  = getprop("/autopilot/internal/CMDB");
		if (cmda and cmdb) {
			var added_fcc = getprop("/autopilot/internal/FCC-added");

			if (added_fcc == "A") {
				setprop("/autopilot/internal/FCC-added", "");
				setprop("/autopilot/internal/FCC-A-master", 0);
				setprop("/autopilot/internal/CMDA", 0);
			} elsif (added_fcc == "B") {
				setprop("/autopilot/internal/FCC-added", "");
				setprop("/autopilot/internal/FCC-B-master", 0);
				setprop("/autopilot/internal/CMDB", 0);
			}
		}
	}
}
setlistener("/autopilot/internal/GA", ga_speed_round, 0, 0);
##########################################################################
# Calculating turn anticipation distance
var turn_anticipate = func {
if (getprop("/autopilot/internal/LNAV")){
	var gnds_mps = getprop("/instrumentation/gps/indicated-ground-speed-kt") * 0.5144444444444;
	var current_course = getprop("/instrumentation/gps/wp/leg-true-course-deg");
	var wp_fly_to = getprop("/autopilot/route-manager/current-wp") + 1;
	if (wp_fly_to < 0) wp_fly_to = 0;
	var next_course = getprop("/autopilot/route-manager/route/wp["~wp_fly_to~"]/leg-bearing-true-deg");
	var max_bank_limit = getprop("/autopilot/settings/maximum-bank-limit");

	var delta_angle = math.abs(geo.normdeg180(current_course - next_course));
	var max_bank = delta_angle * 1.5;
	if (max_bank > max_bank_limit) max_bank = max_bank_limit;
	var radius = (gnds_mps * gnds_mps) / (9.81 * math.tan(max_bank/57.2957795131));
	var time = 0.64 * gnds_mps * delta_angle * 0.7 / (360 * math.tan(max_bank/57.2957795131));
	var delta_angle_rad = (180 - delta_angle) / 114.5915590262;
	var R = radius/math.sin(delta_angle_rad);
	var dist_coeff = delta_angle * -0.011111 + 2;
	if (dist_coeff < 1) dist_coeff = 1;
	var turn_dist = math.cos(delta_angle_rad) * R * dist_coeff / 1852;

	setprop("/instrumentation/gps/config/over-flight-distance-nm", turn_dist);
	if (getprop("/sim/time/elapsed-sec")-getprop("/autopilot/internal/wp-change-time") > 60) {
		setprop("/autopilot/internal/wp-change-check-period", time);
	}

	settimer(turn_anticipate, 5);
}
}
setlistener("/autopilot/internal/LNAV", turn_anticipate, 0, 0);

var wp_change = func {
	setprop("/autopilot/internal/wp-change-time", getprop("/sim/time/elapsed-sec"));

}
setlistener("/autopilot/route-manager/current-wp", wp_change, 0, 0);
##########################################################################
##########################################################################
# Rectangles for mode change
var roll_mode_change = func {
	var last_change = getprop("/autopilot/display/roll-mode-last-change");
	var current_time = getprop("/sim/time/elapsed-sec");
	var period = current_time - last_change;

	if (period <= 10) {
		setprop("/autopilot/display/roll-mode-rectangle", 1);
		settimer(roll_mode_change, 0.5);
	} else {
		setprop("/autopilot/display/roll-mode-rectangle", 0);
	}
}
var pitch_mode_change = func {
	var last_change = getprop("/autopilot/display/pitch-mode-last-change");
	var current_time = getprop("/sim/time/elapsed-sec");
	var period = current_time - last_change;

	if (period <= 10) {
		setprop("/autopilot/display/pitch-mode-rectangle", 1);
		settimer(pitch_mode_change, 0.5);
	} else {
		setprop("/autopilot/display/pitch-mode-rectangle", 0);
	}
}
var throttle_mode_change = func {
	var last_change = getprop("/autopilot/display/throttle-mode-last-change");
	var current_time = getprop("/sim/time/elapsed-sec");
	var period = current_time - last_change;
	var at_arm = getprop("/autopilot/internal/SPD");

	if (period <= 10 and at_arm) {
		setprop("/autopilot/display/throttle-mode-rectangle", 1);
		settimer(throttle_mode_change, 0.5);
	} else {
		setprop("/autopilot/display/throttle-mode-rectangle", 0);
	}
}
var afds_mode_change = func {
	var last_change = getprop("/autopilot/display/afds-mode-last-change[0]");
	var current_time = getprop("/sim/time/elapsed-sec");
	var period = current_time - last_change;

	if (period <= 10) {
		setprop("/autopilot/display/afds-mode-rectangle[0]", 1);
		settimer(afds_mode_change, 0.5);
	} else {
		setprop("/autopilot/display/afds-mode-rectangle[0]", 0);
	}
}
setlistener( "/autopilot/display/roll-mode", roll_mode_change, 0, 0);
setlistener( "/autopilot/display/pitch-mode", pitch_mode_change, 0, 0);
setlistener( "/autopilot/display/throttle-mode", throttle_mode_change, 0, 0);
setlistener( "/autopilot/display/afds-mode[0]", afds_mode_change, 0, 0);

var afds_mode_recognize = func {
	var CMDA = getprop("/autopilot/internal/CMDA");
	var CMDB = getprop("/autopilot/internal/CMDB");
	var fd = getprop("/instrumentation/flightdirector/fd-left-on");
	var GS  = getprop("/autopilot/internal/VNAV-GS");
	var GS_armed  = getprop("/autopilot/internal/VNAV-GS-armed");
	var LOC = getprop("/autopilot/internal/LNAV-NAV");
	var flare_arm = getprop("/autopilot/internal/VNAV-FLARE-armed");

	if (CMDA == 0 and CMDB == 0 and fd == 0) {
		var afdsMode = "";
	} elsif (CMDA == 0 and CMDB == 0 and fd == 1) {
		var afdsMode = "FD";
	} elsif ((CMDA == 1 or CMDB == 1) and GS == 0 and GS_armed == 0) {
		var afdsMode = "CMD";
	} elsif ((CMDA == 1 or CMDB == 1) and (GS == 1 or GS_armed == 1) and LOC == 1 and flare_arm == 0) {
		var afdsMode = "SINGLE CH";
	} elsif (CMDA == 1 and CMDB == 1 and flare_arm == 1) {
		var afdsMode = "CMD";
	} else {
		var afdsMode = getprop("/autopilot/display/afds-mode[0]");
	}
	if (afdsMode != getprop("/autopilot/display/afds-mode[0]")) {
		setprop("/autopilot/display/afds-mode-last-change", getprop("/sim/time/elapsed-sec"));
		setprop("/autopilot/display/afds-mode[0]", afdsMode);
	}
	
	settimer(afds_mode_recognize, 0.5);
}

afds_mode_recognize();

####################################
## Display ARMED PITCH MODE
var pitch_arm_change = func {
	var gs_arm = getprop("/autopilot/internal/VNAV-GS-armed");
	var vs_arm = getprop("/autopilot/internal/VNAV-VS-armed");
	var flare_arm = getprop("/autopilot/internal/VNAV-FLARE-armed");
	if (gs_arm and vs_arm) {
		setprop("/autopilot/display/pitch-mode-armed", "G/S V/S");
	} elsif (!gs_arm and vs_arm) {
		setprop("/autopilot/display/pitch-mode-armed", "V/S");
	} elsif (gs_arm and !vs_arm) {
		setprop("/autopilot/display/pitch-mode-armed", "G/S");
	} elsif (flare_arm) {
		setprop("/autopilot/display/pitch-mode-armed", "FLARE");
	} else {
		setprop("/autopilot/display/pitch-mode-armed", "");
	}
}
setlistener( "/autopilot/internal/VNAV-GS-armed", pitch_arm_change, 0, 0);
setlistener( "/autopilot/internal/VNAV-VS-armed", pitch_arm_change, 0, 0);
setlistener( "/autopilot/internal/VNAV-FLARE-armed", pitch_arm_change, 0, 0);

##########################################################################
# Expanded - not-expanded localizer deviation scale check
var localizer_expanded = func {
	var expanded = getprop("/autopilot/display/localizer_expanded");
	var LOC = getprop("/autopilot/internal/LNAV-NAV");
	var track = getprop("/orientation/track-magnetic-deg");
	var mcp_course = getprop("/instrumentation/nav[0]/radials/selected-deg");
	var deflection = getprop("instrumentation/nav[0]/heading-needle-deflection-norm");
	var groundspeed = getprop("/instrumentation/gps/indicated-ground-speed-kt");
	var radio_alt = getprop("instrumentation/radar-altimeter/radar-altitude-ft");

	if (!expanded) {
		var trk_crs_diff = math.abs(geo.normdeg180(track - mcp_course));
		if ( math.abs(deflection) < 0.42 and trk_crs_diff < 5 and LOC) setprop("/autopilot/display/localizer_expanded", 1);
	} else {
		if (!LOC and (groundspeed < 30 or radio_alt > 200)) setprop("/autopilot/display/localizer_expanded", 0);
	}

	settimer(localizer_expanded, 0.1);
}
setlistener("/autopilot/internal/LNAV-NAV", localizer_expanded, 0, 0);
