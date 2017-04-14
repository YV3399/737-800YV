# IT AUTOFLIGHT System Controller
# Joshua Davidson (it0uchpods)
# V3.0.0 Build 171
# This program is 100% GPL!

print("IT-AUTOFLIGHT: Please Wait!");

var ap_init = func {
	setprop("/it-autoflight/input/kts-mach", 0);
	setprop("/it-autoflight/input/ap1", 0);
	setprop("/it-autoflight/input/ap2", 0);
	setprop("/it-autoflight/input/athr", 0);
	setprop("/it-autoflight/input/cws", 0);
	setprop("/it-autoflight/input/fd1", 0);
	setprop("/it-autoflight/input/fd2", 0);
	setprop("/it-autoflight/input/hdg", 360);
	setprop("/it-autoflight/input/alt", 10000);
	setprop("/it-autoflight/input/vs", 0);
	setprop("/it-autoflight/input/fpa", 0);
	setprop("/it-autoflight/input/lat", 5);
	setprop("/it-autoflight/input/lat-arm", 0);
	setprop("/it-autoflight/input/vert", 7);
	setprop("/it-autoflight/input/prof-arm", 0);
	setprop("/it-autoflight/input/bank-limit", getprop("/it-autoflight/settings/default-bank-limit"));
	setprop("/it-autoflight/input/trk", 0);
	setprop("/it-autoflight/input/toga", 0);
	setprop("/it-autoflight/output/ap1", 0);
	setprop("/it-autoflight/output/ap2", 0);
	setprop("/it-autoflight/output/athr", 0);
	setprop("/it-autoflight/output/cws", 0);
	setprop("/it-autoflight/output/fd1", 0);
	setprop("/it-autoflight/output/fd2", 0);
	setprop("/it-autoflight/output/loc-armed", 0);
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/output/thr-mode", 2);
	setprop("/it-autoflight/output/retard", 0);
	setprop("/it-autoflight/output/lat", 5);
	setprop("/it-autoflight/output/vert", 7);
	setprop("/it-autoflight/output/prof-vert", 4);
	setprop("/it-autoflight/settings/min-pitch", -8);
	setprop("/it-autoflight/settings/max-pitch", 8);
	setprop("/it-autoflight/settings/use-nav2-radio", 0);
	setprop("/it-autoflight/settings/use-backcourse", 0);
	setprop("/it-autoflight/internal/min-pitch", -8);
	setprop("/it-autoflight/internal/max-pitch", 8);
	setprop("/it-autoflight/internal/alt", 10000);
	setprop("/it-autoflight/internal/prof-alt", 10000);
	setprop("/it-autoflight/internal/prof-wp-alt", 10000);
	setprop("/it-autoflight/internal/prof-mode", "XX");
	setprop("/it-autoflight/internal/cwsr", 0);
	setprop("/it-autoflight/internal/cwsp", 0);
	setprop("/it-autoflight/internal/fpa", 0);
	setprop("/it-autoflight/internal/prof-fpm", 0);
	setprop("/it-autoflight/internal/top-of-des-nm", 0);
	setprop("/it-autoflight/autoland/target-vs", "-650");
	setprop("/it-autoflight/mode/thr", "PITCH");
	setprop("/it-autoflight/mode/arm", "HDG");
	setprop("/it-autoflight/mode/lat", "T/O");
	setprop("/it-autoflight/mode/vert", "T/O CLB");
	setprop("/it-autoflight/mode/prof", "NONE");
	setprop("/it-autoflight/input/spd-kts", 250);
	setprop("/it-autoflight/input/spd-mach", 0.68);
	update_armst.start();
	thrustmode();
	print("IT-AUTOFLIGHT: Done!");
}

# AP 1 Master System
setlistener("/it-autoflight/input/ap1", func {
	var apmas = getprop("/it-autoflight/input/ap1");
	if (apmas == 0) {
		setprop("/it-autoflight/output/ap1", 0);
		setprop("/controls/flight/rudder", 0);
		if (getprop("/it-autoflight/sound/enableapoffsound") == 1) {
			setprop("/it-autoflight/sound/apoffsound", 1);
			setprop("/it-autoflight/sound/enableapoffsound", 0);	  
		}
	} else if (apmas == 1) {
		if ((getprop("/gear/gear[1]/wow") == 0) and (getprop("/gear/gear[2]/wow") == 0)) {
			setprop("/controls/flight/rudder", 0);
			setprop("/it-autoflight/input/cws", 0);
			setprop("/it-autoflight/output/ap1", 1);
			setprop("/it-autoflight/sound/enableapoffsound", 1);
			setprop("/it-autoflight/sound/apoffsound", 0);
		}
	}
});

# AP 2 Master System
setlistener("/it-autoflight/input/ap2", func {
	var apmas = getprop("/it-autoflight/input/ap2");
	if (apmas == 0) {
		setprop("/it-autoflight/output/ap2", 0);
		setprop("/controls/flight/rudder", 0);
		if (getprop("/it-autoflight/sound/enableapoffsound2") == 1) {
			setprop("/it-autoflight/sound/apoffsound2", 1);	
			setprop("/it-autoflight/sound/enableapoffsound2", 0);	  
		}
	} else if (apmas == 1) {
		if ((getprop("/gear/gear[1]/wow") == 0) and (getprop("/gear/gear[2]/wow") == 0)) {
			setprop("/controls/flight/rudder", 0);
			setprop("/it-autoflight/input/cws", 0);
			setprop("/it-autoflight/output/ap2", 1);
			setprop("/it-autoflight/sound/enableapoffsound2", 1);
			setprop("/it-autoflight/sound/apoffsound2", 0);
		}
	}
});

# AT Master System
setlistener("/it-autoflight/input/athr", func {
	var atmas = getprop("/it-autoflight/input/athr");
	if (atmas == 0) {
		setprop("/it-autoflight/output/athr", 0);
	} else if (atmas == 1) {
		setprop("/it-autoflight/output/athr", 1);
	}
});

# CWS Master System
setlistener("/it-autoflight/input/cws", func {
	var cwsmas = getprop("/it-autoflight/input/cws");
	if (cwsmas == 1) {
		if ((getprop("/gear/gear[1]/wow") == 0) and (getprop("/gear/gear[2]/wow") == 0)) {
			setprop("/it-autoflight/input/ap1", 0);
			setprop("/it-autoflight/input/ap2", 0);
			setprop("/it-autoflight/internal/cws-roll-deg", getprop("/orientation/roll-deg"));
			setprop("/it-autoflight/internal/cws-pitch-deg", getprop("/orientation/pitch-deg"));
			cwsrollt.start();
			cwspitcht.start();
			setprop("/it-autoflight/output/cws", 1);
		}
	} else if (cwsmas == 0) {
		cwsrollt.stop();
		cwspitcht.stop();
		setprop("/it-autoflight/output/cws", 0);
		setprop("/controls/flight/aileron-trim", 0);
	}
});

# Flight Director 1 Master System
setlistener("/it-autoflight/input/fd1", func {
	var fdmas = getprop("/it-autoflight/input/fd1");
	if (fdmas == 0) {
		setprop("/it-autoflight/output/fd1", 0);
	} else if (fdmas == 1) {
		setprop("/it-autoflight/output/fd1", 1);
	}
});

# Flight Director 2 Master System
setlistener("/it-autoflight/input/fd2", func {
	var fdmas = getprop("/it-autoflight/input/fd2");
	if (fdmas == 0) {
		setprop("/it-autoflight/output/fd2", 0);
	} else if (fdmas == 1) {
		setprop("/it-autoflight/output/fd2", 1);
	}
});

# Master Lateral
setlistener("/it-autoflight/input/lat", func {
	if ((getprop("/gear/gear[1]/wow") == 0) and (getprop("/gear/gear[2]/wow") == 0)) {
		lateral();
	} else {
		lat_arm();
	}
});

var lateral = func {
	var latset = getprop("/it-autoflight/input/lat");
	if (latset == 0) {
		alandt.stop();
		alandt1.stop();
		lnavwptt.stop();
		setprop("/it-autoflight/output/loc-armed", 0);
		setprop("/it-autoflight/output/appr-armed", 0);
		setprop("/it-autoflight/output/lat", 0);
		setprop("/it-autoflight/mode/lat", "HDG");
		setprop("/it-autoflight/mode/arm", " ");
	} else if (latset == 1) {
		if (getprop("/autopilot/route-manager/route/num") > 0 and getprop("/autopilot/route-manager/active") == 1) {
			alandt.stop();
			alandt1.stop();
			lnavwptt.start();
			setprop("/it-autoflight/output/loc-armed", 0);
			setprop("/it-autoflight/output/appr-armed", 0);
			setprop("/it-autoflight/output/lat", 1);
			setprop("/it-autoflight/mode/lat", "LNAV");
			setprop("/it-autoflight/mode/arm", " ");
		} else {
			gui.popupTip("Please make sure you have a route set, and that it is Activated!");
		}
	} else if (latset == 2) {
		if (getprop("/it-autoflight/output/lat") == 2) {
			# Do nothing because VOR/LOC is active
		} else {
			setprop("/instrumentation/nav[0]/signal-quality-norm", 0);
			setprop("/instrumentation/nav[1]/signal-quality-norm", 0);
			setprop("/it-autoflight/output/loc-armed", 1);
			setprop("/it-autoflight/mode/arm", "LOC");
		}
	} else if (latset == 3) {
		alandt.stop();
		alandt1.stop();
		lnavwptt.stop();
		setprop("/it-autoflight/output/loc-armed", 0);
		setprop("/it-autoflight/output/appr-armed", 0);
		var hdgnow = int(getprop("/orientation/heading-magnetic-deg")+0.5);
		setprop("/it-autoflight/input/hdg", hdgnow);
		setprop("/it-autoflight/output/lat", 0);
		setprop("/it-autoflight/mode/lat", "HDG");
		setprop("/it-autoflight/mode/arm", " ");
	} else if (latset == 4) {
		lnavwptt.stop();
		setprop("/it-autoflight/output/lat", 4);
		setprop("/it-autoflight/mode/lat", "ALGN");
	} else if (latset == 5) {
		lnavwptt.stop();
		setprop("/it-autoflight/output/lat", 5);
	}
}

var lat_arm = func {
	var latset = getprop("/it-autoflight/input/lat");
	if (latset == 0) {
		setprop("/it-autoflight/input/lat-arm", 0);
		setprop("/it-autoflight/mode/arm", "HDG");
	} else if (latset == 1) {
		if (getprop("/autopilot/route-manager/route/num") > 0 and getprop("/autopilot/route-manager/active") == 1) {
			setprop("/it-autoflight/input/lat-arm", 1);
			setprop("/it-autoflight/mode/arm", "LNV");
		} else {
			gui.popupTip("Please make sure you have a route set, and that it is Activated!");
		}
	} else if (latset == 3) {
		var hdgnow = int(getprop("/orientation/heading-magnetic-deg")+0.5);
		setprop("/it-autoflight/input/hdg", hdgnow);
		setprop("/it-autoflight/input/lat-arm", 0);
		setprop("/it-autoflight/mode/arm", "HDG");
	}
}

# Master Vertical
setlistener("/it-autoflight/input/vert", func {
	if ((getprop("/gear/gear[1]/wow") == 0) and (getprop("/gear/gear[2]/wow") == 0)) {
		vertical();
	} else {
		vert_arm();
	}
});

var vertical = func {
	var vertset = getprop("/it-autoflight/input/vert");
	if (vertset == 0) {
		alandt.stop();
		alandt1.stop();
		prof_sys_stop();
		setprop("/it-autoflight/output/appr-armed", 0);
		setprop("/it-autoflight/output/vert", 0);
		setprop("/it-autoflight/mode/vert", "ALT HLD");
		if (getprop("/it-autoflight/output/loc-armed")) {
			setprop("/it-autoflight/mode/arm", "LOC");
		} else {
			setprop("/it-autoflight/mode/arm", " ");
		}
		var altnow = int((getprop("/instrumentation/altimeter/indicated-altitude-ft")+50)/100)*100;
		setprop("/it-autoflight/input/alt", altnow);
		setprop("/it-autoflight/internal/alt", altnow);
		thrustmode();
	} else if (vertset == 1) {
		alandt.stop();
		alandt1.stop();
		prof_sys_stop();
		setprop("/it-autoflight/output/appr-armed", 0);
		var altinput = getprop("/it-autoflight/input/alt");
		setprop("/it-autoflight/internal/alt", altinput);
		var vsnow = int(getprop("/velocities/vertical-speed-fps")*0.6)*100;
		setprop("/it-autoflight/input/vs", vsnow);
		setprop("/it-autoflight/output/vert", 1);
		setprop("/it-autoflight/mode/vert", "V/S");
		if (getprop("/it-autoflight/output/loc-armed")) {
			setprop("/it-autoflight/mode/arm", "LOC");
		} else {
			setprop("/it-autoflight/mode/arm", " ");
		}
		thrustmode();
	} else if (vertset == 2) {
		if (getprop("/it-autoflight/output/lat") == 2) {
			# Do nothing because VOR/LOC is active
		} else {
			setprop("/instrumentation/nav[0]/signal-quality-norm", 0);
			setprop("/instrumentation/nav[1]/signal-quality-norm", 0);
			setprop("/it-autoflight/output/loc-armed", 1);
		}
		if ((getprop("/it-autoflight/output/vert") == 2) or (getprop("/it-autoflight/output/vert") == 6)) {
			# Do nothing because G/S or LAND or FLARE is active
		} else {
			setprop("/instrumentation/nav[0]/gs-rate-of-climb", 0);
			setprop("/instrumentation/nav[1]/gs-rate-of-climb", 0);
			setprop("/it-autoflight/output/appr-armed", 1);
			setprop("/it-autoflight/mode/arm", "ILS");
			setprop("/it-autoflight/autoland/target-vs", "-650");
		}
	} else if (vertset == 3) {
		alandt.stop();
		alandt1.stop();
		prof_sys_stop();
		var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		var alt = getprop("/it-autoflight/internal/alt");
		var dif = calt - alt;
		var pitchdeg = getprop("/it-autoflight/internal/target-pitch");
		if (calt < alt) {
			setprop("/it-autoflight/internal/max-pitch", pitchdeg);
		} else if (calt > alt) {
			setprop("/it-autoflight/internal/min-pitch", pitchdeg);
		}
		minmaxtimer.start();
		thrustmode();
		setprop("/it-autoflight/output/vert", 0);
		setprop("/it-autoflight/mode/vert", "ALT CAP");
	} else if (vertset == 4) {
		alandt.stop();
		alandt1.stop();
		prof_sys_stop();
		setprop("/it-autoflight/output/appr-armed", 0);
		var altinput = getprop("/it-autoflight/input/alt");
		setprop("/it-autoflight/internal/alt", altinput);
		var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		var alt = getprop("/it-autoflight/internal/alt");
		var dif = calt - alt;
		if (dif < 250 and dif > -250) {
			alt_on();
		} else {
			flch_on();
		}
		if (getprop("/it-autoflight/output/loc-armed")) {
			setprop("/it-autoflight/mode/arm", "LOC");
		} else {
			setprop("/it-autoflight/mode/arm", " ");
		}
	} else if (vertset == 5) {
		alandt.stop();
		alandt1.stop();
		prof_sys_stop();
		fpa_calct.start();
		setprop("/it-autoflight/output/appr-armed", 0);
		var altinput = getprop("/it-autoflight/input/alt");
		setprop("/it-autoflight/internal/alt", altinput);
		var fpanow = (int(10*getprop("/it-autoflight/internal/fpa")))*0.1;
		setprop("/it-autoflight/input/fpa", fpanow);
		setprop("/it-autoflight/output/vert", 5);
		setprop("/it-autoflight/mode/vert", "FPA");
		if (getprop("/it-autoflight/output/loc-armed") == 1) {
			setprop("/it-autoflight/mode/arm", "LOC");
		} else {
			setprop("/it-autoflight/mode/arm", " ");
		}
		thrustmode();
	} else if (vertset == 6) {
		setprop("/it-autoflight/output/vert", 6);
		setprop("/it-autoflight/mode/vert", "LAND");
		setprop("/it-autoflight/mode/arm", " ");
		thrustmode();
		alandt.stop();
		alandt1.start();
		prof_sys_stop();
		setprop("/it-autoflight/autoland/target-vs", "-650");
	} else if (vertset == 7) {
		alandt.stop();
		alandt1.stop();
		prof_sys_stop();
		setprop("/it-autoflight/output/vert", 7);
		setprop("/it-autoflight/mode/arm", " ");
		var altinput = getprop("/it-autoflight/input/alt");
		setprop("/it-autoflight/internal/alt", altinput);
		prof_sys_stop();
		thrustmodet.start();
	} else if (vertset == 8) {
		if (getprop("/autopilot/route-manager/route/num") > 0 and getprop("/autopilot/route-manager/active") == 1 and getprop("/it-autoflight/internal/prof-wp-alt") >= 100) {
			alandt.stop();
			alandt1.stop();
			setprop("/it-autoflight/output/appr-armed", 0);
			setprop("/it-autoflight/output/vert", 8);
			prof_run();
			setprop("/it-autoflight/mode/vert", "VNAV");
			setprop("/it-autoflight/mode/arm", " ");
			var altinput = getprop("/it-autoflight/input/alt");
			setprop("/it-autoflight/internal/alt", altinput);
			if (getprop("/it-autoflight/output/loc-armed")) {
				setprop("/it-autoflight/mode/arm", "LOC");
			} else {
				setprop("/it-autoflight/mode/arm", " ");
			}
			prof_maint.start();
		} else {
			gui.popupTip("Please make sure you have a route, and waypoints with altitude restrictions set, and that the route is Activated!");
		}
	}
}

var vert_arm = func {
	var vertset = getprop("/it-autoflight/input/vert");
	if (vertset == 8) {
		if (getprop("/autopilot/route-manager/route/num") > 0 and getprop("/autopilot/route-manager/active") == 1 and getprop("/it-autoflight/internal/prof-wp-alt") >= 100) {
			setprop("/it-autoflight/input/prof-arm", 1);
			setprop("/it-autoflight/mode/prof", "ARMED");
		} else {
			gui.popupTip("Please make sure you have a route, and waypoints with altitude restrictions set, and that the route is Activated!");
		}
	} else {
		setprop("/it-autoflight/input/prof-arm", 0);
		setprop("/it-autoflight/mode/prof", "NONE");
	}
}

# Helpers
var lnavwpt = func {
	if (getprop("/autopilot/route-manager/route/num") > 0) {
		if (getprop("/autopilot/route-manager/wp/dist") <= 1.0) {
			var wptnum = getprop("/autopilot/route-manager/current-wp");
			if ((wptnum + 1) < getprop("/autopilot/route-manager/route/num")) {
				setprop("/autopilot/route-manager/current-wp", wptnum + 1);
			}
		}
	}
}

var flch_on = func {
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/output/vert", 4);
	thrustmodet.start();
}
var alt_on = func {
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/output/vert", 0);
	setprop("/it-autoflight/mode/vert", "ALT CAP");
	setprop("/it-autoflight/internal/max-pitch", 8);
	setprop("/it-autoflight/internal/min-pitch", -5);
	minmaxtimer.start();
}

var fpa_calc = func {
	var VS = getprop("/velocities/vertical-speed-fps");
	var TAS = getprop("/velocities/uBody-fps");
	if(TAS < 10) TAS = 10;
	if(VS < -200) VS =-200;
	if (abs(VS/TAS) <= 1) {
		var FPangle = math.asin(VS/TAS);
		FPangle *=90;
		setprop("/it-autoflight/internal/fpa", FPangle);
	}
}

setlistener("/it-autoflight/input/kts-mach", func {
	var modez = getprop("/it-autoflight/input/kts-mach");
	if (modez == 0) {
		var iasnow = int(getprop("/instrumentation/airspeed-indicator/indicated-speed-kt")+0.5);
		setprop("/it-autoflight/input/spd-kts", iasnow);
	} else if (modez == 1) {
		var machnow = (int(1000*getprop("/velocities/mach")))*0.001;
		setprop("/it-autoflight/input/spd-mach", machnow);
	}
});

# Takeoff Modes
# Lat Active
var latarms = func {
	if (getprop("/position/gear-agl-ft") >= getprop("/it-autoflight/settings/lat-agl-ft")) {
		setprop("/it-autoflight/input/lat", getprop("/it-autoflight/input/lat-arm"));
	}
}

# TOGA
setlistener("/it-autoflight/input/toga", func {
	if (getprop("/it-autoflight/input/toga") == 1) {
		setprop("/it-autoflight/input/vert", 7);
		vertical();
		setprop("/it-autoflight/output/loc-armed", 0);
		setprop("/it-autoflight/output/appr-armed", 0);
		setprop("/it-autoflight/input/toga", 0);
		togasel();
	}
});

var togasel = func {
	if ((getprop("/gear/gear[1]/wow") == 0) and (getprop("/gear/gear[2]/wow") == 0)) {
		var iasnow = int(getprop("/instrumentation/airspeed-indicator/indicated-speed-kt")+0.5);
		setprop("/it-autoflight/input/spd-kts", iasnow);
		setprop("/it-autoflight/input/kts-mach", 0);
		setprop("/it-autoflight/mode/vert", "G/A CLB");
		setprop("/it-autoflight/input/lat", 3);
	} else {
		setprop("/it-autoflight/input/lat", 5);
		lateral();
		setprop("/it-autoflight/mode/lat", "T/O");
		setprop("/it-autoflight/mode/vert", "T/O CLB");
	}
}

setlistener("/it-autoflight/mode/vert", func {
	var vertm = getprop("/it-autoflight/mode/vert");
	if (vertm == "T/O CLB") {
		reduct.start();
	} else {
		reduct.stop();
	}
});

setlistener("/it-autoflight/mode/lat", func {
	var vertm = getprop("/it-autoflight/mode/lat");
	if (vertm == "T/O") {
		latarmt.start();
	} else {
		latarmt.stop();
	}
});

var toga_reduc = func {
	if (getprop("/position/gear-agl-ft") >= getprop("/it-autoflight/settings/reduc-agl-ft")) {
		if (getprop("/it-autoflight/input/prof-arm") == 1) {
			setprop("/it-autoflight/input/vert", 8);
		} else {
			setprop("/it-autoflight/input/vert", 4);
		}
	}
}

# Altitude Capture and FPA Timer Logic
setlistener("/it-autoflight/output/vert", func {
	var vertm = getprop("/it-autoflight/output/vert");
	if (vertm == 1) {
		altcaptt.start();
		fpa_calct.stop();
		setprop("/it-autoflight/mode/prof", "NONE");
	} else if (vertm == 4) {
		altcaptt.start();
		fpa_calct.stop();
		setprop("/it-autoflight/mode/prof", "NONE");
	} else if (vertm == 5) {
		altcaptt.start();
		setprop("/it-autoflight/mode/prof", "NONE");
	} else if (vertm == 7) {
		altcaptt.start();
		fpa_calct.stop();
		setprop("/it-autoflight/mode/prof", "NONE");
	} else if (vertm == 8) {
		altcaptt.stop();
		fpa_calct.stop();
	} else {
		altcaptt.stop();
		fpa_calct.stop();
		setprop("/it-autoflight/mode/prof", "NONE");
	}
});

# Altitude Capture
var altcapt = func {
	var vsnow = getprop("/it-autoflight/internal/vert-speed-fpm");
	if ((vsnow >= 0 and vsnow < 500) or (vsnow < 0 and vsnow > -500)) {
		setprop("/it-autoflight/internal/captvs", 100);
		setprop("/it-autoflight/internal/captvsneg", -100);
	} else  if ((vsnow >= 500 and vsnow < 1000) or (vsnow < -500 and vsnow > -1000)) {
		setprop("/it-autoflight/internal/captvs", 150);
		setprop("/it-autoflight/internal/captvsneg", -150);
	} else  if ((vsnow >= 1000 and vsnow < 1500) or (vsnow < -1000 and vsnow > -1500)) {
		setprop("/it-autoflight/internal/captvs", 200);
		setprop("/it-autoflight/internal/captvsneg", -200);
	} else  if ((vsnow >= 1500 and vsnow < 2000) or (vsnow < -1500 and vsnow > -2000)) {
		setprop("/it-autoflight/internal/captvs", 300);
		setprop("/it-autoflight/internal/captvsneg", -300);
	} else  if ((vsnow >= 2000 and vsnow < 3000) or (vsnow < -2000 and vsnow > -3000)) {
		setprop("/it-autoflight/internal/captvs", 450);
		setprop("/it-autoflight/internal/captvsneg", -450);
	} else  if ((vsnow >= 3000 and vsnow < 4000) or (vsnow < -3000 and vsnow > -4000)) {
		setprop("/it-autoflight/internal/captvs", 650);
		setprop("/it-autoflight/internal/captvsneg", -650);
	} else  if ((vsnow >= 4000 and vsnow < 5000) or (vsnow < -4000 and vsnow > -5000)) {
		setprop("/it-autoflight/internal/captvs", 1000);
		setprop("/it-autoflight/internal/captvsneg", -1000);
	} else  if ((vsnow >= 5000) or (vsnow < -5000)) {
		setprop("/it-autoflight/internal/captvs", 1250);
		setprop("/it-autoflight/internal/captvsneg", -1250);
	}
	var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var alt = getprop("/it-autoflight/internal/alt");
	var dif = calt - alt;
	if (dif < getprop("/it-autoflight/internal/captvs") and dif > getprop("/it-autoflight/internal/captvsneg")) {
		setprop("/it-autoflight/input/vert", 3);
		setprop("/it-autoflight/output/thr-mode", 0);
	}
	var altinput = getprop("/it-autoflight/input/alt");
	setprop("/it-autoflight/internal/alt", altinput);
}

# Min and Max Pitch Reset
var minmax = func {
	var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var alt = getprop("/it-autoflight/internal/alt");
	var dif = calt - alt;
	if (dif < 50 and dif > -50) {
		setprop("/it-autoflight/internal/max-pitch", 8);
		setprop("/it-autoflight/internal/min-pitch", -5);
		var vertmode = getprop("/it-autoflight/output/vert");
		if (vertmode == 1 or vertmode == 2 or vertmode == 4 or vertmode == 5 or vertmode == 6 or vertmode == 7) {
			# Do not change the vertical mode because we are not trying to capture altitude.
		} else {
			setprop("/it-autoflight/mode/vert", "ALT HLD");
		}
		minmaxtimer.stop();
	}
}

# Thrust Mode Selector
var thrustmode = func {
	var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var alt = getprop("/it-autoflight/internal/alt");
	var vertm = getprop("/it-autoflight/output/vert");
	if (vertm == 4) {
		if (calt < alt) {
			setprop("/it-autoflight/output/thr-mode", 2);
			setprop("/it-autoflight/mode/thr", " PITCH");
			setprop("/it-autoflight/mode/vert", "SPD CLB");
		} else if (calt > alt) {
			setprop("/it-autoflight/output/thr-mode", 1);
			setprop("/it-autoflight/mode/thr", " PITCH");
			setprop("/it-autoflight/mode/vert", "SPD DES");
		} else {
			setprop("/it-autoflight/output/thr-mode", 0);
			setprop("/it-autoflight/mode/thr", "THRUST");
			setprop("/it-autoflight/input/vert", 3);
		}
	} else if (vertm == 7) {
		setprop("/it-autoflight/output/thr-mode", 2);
		setprop("/it-autoflight/mode/thr", " PITCH");
	} else if (vertm == 8) {
		thrustmodet.stop();
	}  else {
		setprop("/it-autoflight/output/thr-mode", 0);
		setprop("/it-autoflight/mode/thr", "THRUST");
		thrustmodet.stop();
	}
}

# ILS and Autoland
# Retard
setlistener("/controls/flight/flaps", func {
	var flapc = getprop("/controls/flight/flaps");
	var flapl = getprop("/it-autoflight/settings/land-flap");
	if (flapc >= flapl) {
		retardt.start();
	} else {
		retardt.stop();
	}
});

var retardchk = func {
	if (getprop("/it-autoflight/settings/retard-enable") == 1) {
		var altpos = getprop("/position/gear-agl-ft");
		var retardalt = getprop("/it-autoflight/settings/retard-ft");
		var aton = getprop("/it-autoflight/output/athr");
		if (altpos < retardalt) {
			if (aton == 1) {
				setprop("/it-autoflight/output/retard", 1);
				setprop("/it-autoflight/mode/thr", "RETARD");
				atofft.start();
			} else {
				setprop("/it-autoflight/output/retard", 0);
				thrustmode();
			}
		}
	}
}

var atoffchk = func{
	var gear1 = getprop("/gear/gear[1]/wow");
	var gear2 = getprop("/gear/gear[2]/wow");
	if (gear1 == 1 or gear2 == 1) {
		setprop("/it-autoflight/input/athr", 0);
		setprop("/controls/engines/engine[0]/throttle", 0);
		setprop("/controls/engines/engine[1]/throttle", 0);
		setprop("/controls/engines/engine[2]/throttle", 0);
		setprop("/controls/engines/engine[3]/throttle", 0);
		setprop("/controls/engines/engine[4]/throttle", 0);
		setprop("/controls/engines/engine[5]/throttle", 0);
		setprop("/controls/engines/engine[6]/throttle", 0);
		setprop("/controls/engines/engine[7]/throttle", 0);
		atofft.stop();
	}
}

# LOC and G/S arming
var update_arms = func {
	update_locarmelec();
	update_apparmelec();
}

var update_locarmelec = func {
	var loca = getprop("/it-autoflight/output/loc-armed");
	if (loca) {
		locarmcheck();
	} else {
		return 0;
	}
}

var update_apparmelec = func {
	var appra = getprop("/it-autoflight/output/appr-armed");
	if (appra) {
		apparmcheck();
	} else {
		return 0;
	}
}

var locarmcheck = func {
	var locdefl = getprop("instrumentation/nav[0]/heading-needle-deflection-norm");
	var locdefl_b = getprop("instrumentation/nav[1]/heading-needle-deflection-norm");
	if ((locdefl < 0.9233) and (getprop("instrumentation/nav[0]/signal-quality-norm") > 0.99) and (getprop("/it-autoflight/settings/use-nav2-radio") == 0)) {
		make_loc_active();
	} else if ((locdefl_b < 0.9233) and (getprop("instrumentation/nav[1]/signal-quality-norm") > 0.99) and (getprop("/it-autoflight/settings/use-nav2-radio") == 1)) {
		make_loc_active();
	} else {
		return 0;
	}
}

var make_loc_active = func {
	setprop("/it-autoflight/output/loc-armed", 0);
	setprop("/it-autoflight/output/lat", 2);
	setprop("/it-autoflight/mode/lat", "LOC");
	if (getprop("/it-autoflight/output/appr-armed") == 1) {
		# Do nothing because G/S is armed
	} else {
		setprop("/it-autoflight/mode/arm", " ");
	}
}

var apparmcheck = func {
	var signal = getprop("/instrumentation/nav[0]/gs-needle-deflection-norm");
	var signal_b = getprop("/instrumentation/nav[1]/gs-needle-deflection-norm");
	if ((signal <= -0.000000001) and (getprop("/it-autoflight/settings/use-nav2-radio") == 0) and (getprop("/it-autoflight/output/lat") == 2)) {
		make_appr_active();
	} else if ((signal_b <= -0.000000001) and (getprop("/it-autoflight/settings/use-nav2-radio") == 1) and (getprop("/it-autoflight/output/lat") == 2)) {
		make_appr_active();
	} else {
		return 0;
	}
}

var make_appr_active = func {
	prof_sys_stop();
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/output/vert", 2);
	setprop("/it-autoflight/mode/vert", "G/S");
	setprop("/it-autoflight/mode/arm", " ");
	if (getprop("/it-autoflight/settings/land-enable") == 1){
		alandt.start();
	}
	thrustmode();
}

# Autoland Stage 1 Logic (Land)
var aland = func {
	var ap1 = getprop("/it-autoflight/output/ap1");
	var ap2 = getprop("/it-autoflight/output/ap2");
	if (getprop("/position/gear-agl-ft") <= 100) {
		if (ap1 or ap2) {
			setprop("/it-autoflight/input/lat", 4);
			setprop("/it-autoflight/input/vert", 6);
		} else {
			alandt.stop();
			alandt1.stop();
		}
	}
}

var aland1 = func {
	var aglal = getprop("/position/gear-agl-ft");
	var flarealt = getprop("/it-autoflight/settings/flare-altitude");
	if (aglal <= flarealt and aglal > 5) {
		setprop("/it-autoflight/mode/vert", "FLARE");
		setprop("/it-autoflight/autoland/target-vs", "-120");
	}
	if ((getprop("/it-autoflight/output/ap1") == 0) and (getprop("/it-autoflight/output/ap2") == 0)) {
		alandt.stop();
		alandt1.stop();
		setprop("/it-autoflight/output/loc-armed", 0);
		setprop("/it-autoflight/output/lat", 2);
		setprop("/it-autoflight/mode/lat", "LOC");
		setprop("/it-autoflight/output/appr-armed", 0);
		setprop("/it-autoflight/output/vert", 2);
		setprop("/it-autoflight/mode/vert", "G/S");
		setprop("/it-autoflight/mode/arm", " ");
	}
	var gear1 = getprop("/gear/gear[1]/wow");
	var gear2 = getprop("/gear/gear[2]/wow");
	if (gear1 == 1 or gear2 == 1) {
		setprop("/it-autoflight/input/ap1", 0);
		setprop("/it-autoflight/input/ap2", 0);
		alandt1.stop();
	}
}

# Autoland Stage 2 Logic (Rollout)
# Not yet working, planned.

# VNAV Profile Mode
var prof_main = func {
	if (getprop("/autopilot/route-manager/route/num") > 0 and getprop("/autopilot/route-manager/active") == 1) {
		var altinput = getprop("/it-autoflight/input/alt");
		setprop("/it-autoflight/internal/alt", altinput);
		var wp_curr = getprop("/autopilot/route-manager/current-wp");
		var vnav_alt_wp = getprop("/autopilot/route-manager/route/wp",wp_curr,"altitude-ft");
		if (getprop("/it-autoflight/internal/prof-wp-alt") == vnav_alt_wp) {
			# Do nothing
		} else {
			setprop("/it-autoflight/internal/prof-wp-alt", vnav_alt_wp);
		}
		vnav_alt_selector();
		if (getprop("/it-autoflight/internal/prof-wp-alt") < 100) {
			setprop("/it-autoflight/input/vert", 4);
		}
	} else {
		setprop("/it-autoflight/input/vert", 4);
	}
}

var prof_sys_stop = func {
	prof_maint.stop();
	vnav_altcaptt.stop();
	vnav_minmaxt.stop();
	vnav_des_fpmt.stop();
	vnav_des_todt.stop();
	setprop("/it-autoflight/mode/prof", "NONE");
}

setlistener("/it-autoflight/input/alt", func {
	if (getprop("/it-autoflight/output/vert") == 8) {
		vnav_alt_selector();
		prof_run();
	}
});

setlistener("/it-autoflight/internal/prof-wp-alt", func {
	if (getprop("/it-autoflight/output/vert") == 8) {
		vnav_alt_selector();
		prof_run();
	}
});

setlistener("/autopilot/route-manager/current-wp", func {
	if (getprop("/it-autoflight/output/vert") == 8) {
		vnav_alt_selector();
		prof_run();
	}
});

var prof_run = func {
	if (getprop("/autopilot/route-manager/route/num") > 0 and getprop("/autopilot/route-manager/active") == 1) {
		var wp_curr = getprop("/autopilot/route-manager/current-wp");
		var wptnum = getprop("/autopilot/route-manager/current-wp");
		var vnav_alt_wp = getprop("/autopilot/route-manager/route/wp",wp_curr,"altitude-ft");
		if ((wptnum - 1) < getprop("/autopilot/route-manager/route/num")) {
			var vnav_alt_wp_prev = getprop("/autopilot/route-manager/route/wp",wp_curr - 1,"altitude-ft");
			var altcurr = getprop("/instrumentation/altimeter/indicated-altitude-ft");
			if (vnav_alt_wp_prev >= 100) {
				if (vnav_alt_wp_prev > vnav_alt_wp) {
					vnav_des_todt.start();
					setprop("/it-autoflight/internal/prof-mode", "DES");
				} else if (vnav_alt_wp_prev == vnav_alt_wp) {
					vnav_des_todt.stop();
					setprop("/it-autoflight/internal/top-of-des-nm", 0);
					setprop("/it-autoflight/internal/prof-mode", "XX");
				} else if (vnav_alt_wp_prev <= vnav_alt_wp) {
					vnav_des_todt.stop();
					setprop("/it-autoflight/internal/top-of-des-nm", 0);
					setprop("/it-autoflight/internal/prof-mode", "CLB");
				}
			} else if (vnav_alt_wp_prev < 100) {
				if (altcurr > vnav_alt_wp) {
					vnav_des_todt.start();
					setprop("/it-autoflight/internal/prof-mode", "DES");
				} else if (altcurr == vnav_alt_wp) {
					vnav_des_todt.stop();
					setprop("/it-autoflight/internal/top-of-des-nm", 0);
					setprop("/it-autoflight/internal/prof-mode", "XX");
				} else if (altcurr <= vnav_alt_wp) {
					vnav_des_todt.stop();
					setprop("/it-autoflight/internal/top-of-des-nm", 0);
					setprop("/it-autoflight/internal/prof-mode", "CLB");
				}
			}
		} else {
			vnav_des_todt.stop();
			setprop("/it-autoflight/internal/top-of-des-nm", 0);
		}
		if (vnav_alt_wp >= 100) {
			if (getprop("/it-autoflight/internal/prof-mode") == "CLB") {
				var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
				var valt = getprop("/it-autoflight/internal/prof-alt");
				var vdif = calt - valt;
				if (vdif > 250 or vdif < -250) {
					prof_clb();
				} else {
					vnav_alt_sel();
				}
			} else if (getprop("/it-autoflight/internal/prof-mode") == "DES") {
				var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
				var valt = getprop("/it-autoflight/internal/prof-alt");
				var vdif = calt - valt;
				if (vdif > 250 or vdif < -250) {
					prof_des_spd();
				} else {
					vnav_alt_sel();
				}
			} else if (getprop("/it-autoflight/internal/prof-mode") == "XX") {
				# Do nothing for now
			}
		} else {
			setprop("/it-autoflight/input/vert", 4);
		}
	} else {
		setprop("/it-autoflight/input/vert", 4);
	}
}

# VNAV Top of Descent
var vnav_des_tod = func {
	if (getprop("/autopilot/route-manager/route/num") > 0 and getprop("/autopilot/route-manager/active") == 1) {
		var wp_curr = getprop("/autopilot/route-manager/current-wp");
		var vnav_alt_wp = getprop("/autopilot/route-manager/route/wp",wp_curr,"altitude-ft");
		var alt_curr = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		var dist = getprop("/autopilot/route-manager/wp/dist");
		var vdist = dist - 1;
		var alttl = abs(alt_curr - vnav_alt_wp);
		setprop("/it-autoflight/internal/top-of-des-nm", (alttl / 1000) * 3);
		if (vdist < getprop("/it-autoflight/internal/top-of-des-nm")) {
			vnav_des_todt.stop();
			var salt = getprop("/it-autoflight/internal/alt");
			var valt = getprop("/it-autoflight/internal/prof-wp-alt");
			var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
			var sdif = abs(calt - salt);
			var vdif = abs(calt - valt);
			if (sdif <= vdif) {
				setprop("/it-autoflight/internal/prof-alt", getprop("/it-autoflight/internal/alt"));
			} else if (sdif > vdif) {
				setprop("/it-autoflight/internal/prof-alt", getprop("/it-autoflight/internal/prof-wp-alt"));
			}
			var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
			var valt = getprop("/it-autoflight/internal/prof-alt");
			var vdif = calt - valt;
			if (vdif > 550 or vdif < -550) {
				prof_des_spd();
			} else {
				vnav_alt_sel();
			}
		}
	}
}

# VNAV Altitude Selector
var vnav_alt_selector = func {
	var salt = getprop("/it-autoflight/internal/alt");
	var valt = getprop("/it-autoflight/internal/prof-wp-alt");
	var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var sdif = abs(calt - salt);
	var vdif = abs(calt - valt);
	if (getprop("/it-autoflight/internal/prof-mode") == "CLB") {
		if (sdif <= vdif) {
			setprop("/it-autoflight/internal/prof-alt", getprop("/it-autoflight/internal/alt"));
		} else if (sdif > vdif) {
			setprop("/it-autoflight/internal/prof-alt", getprop("/it-autoflight/internal/prof-wp-alt"));
		}
	} else if (getprop("/it-autoflight/internal/prof-mode") == "DES") {
		var dist = getprop("/autopilot/route-manager/wp/dist");
		var vdist = dist - 1;
		if (vdist < getprop("/it-autoflight/internal/top-of-des-nm")) {
			if (sdif <= vdif) {
				setprop("/it-autoflight/internal/prof-alt", getprop("/it-autoflight/internal/alt"));
			} else if (sdif > vdif) {
				setprop("/it-autoflight/internal/prof-alt", getprop("/it-autoflight/internal/prof-wp-alt"));
			}
		}
	}
}

# VNAV Selector
var vnav_alt_sel = func {
	setprop("/it-autoflight/internal/max-pitch", 8);
	setprop("/it-autoflight/internal/min-pitch", -5);
	setprop("/it-autoflight/output/thr-mode", 0);
	setprop("/it-autoflight/output/prof-vert", 0);
	setprop("/it-autoflight/mode/thr", "THRUST");
	setprop("/it-autoflight/mode/prof", "VNAV CAP");
	vnav_minmaxt.start();
}

# VNAV Climb
var prof_clb = func {
	vnav_des_fpmt.stop();
	setprop("/it-autoflight/output/thr-mode", 2);
	setprop("/it-autoflight/mode/thr", " PITCH");
	setprop("/it-autoflight/output/prof-vert", 4);
	setprop("/it-autoflight/mode/prof", "VNAV SPD");
	vnav_altcaptt.start();
}

# VNAV Descent
var prof_des_spd = func {
	vnav_des_fpmt.stop();
	setprop("/it-autoflight/output/thr-mode", 1);
	setprop("/it-autoflight/mode/thr", " PITCH");
	setprop("/it-autoflight/output/prof-vert", 4);
	setprop("/it-autoflight/mode/prof", "VNAV SPD");
	vnav_altcaptt.start();
}
var prof_des_pth = func {
	vnav_des_fpmt.start();
	setprop("/it-autoflight/output/thr-mode", 0);
	setprop("/it-autoflight/mode/thr", "THRUST");
	setprop("/it-autoflight/output/prof-vert", 1);
	setprop("/it-autoflight/mode/prof", "VNAV PTH");
	vnav_altcaptt.start();
}
var vnav_des_fpm = func {
	if (getprop("/autopilot/route-manager/route/num") > 0 and getprop("/autopilot/route-manager/active") == 1) {
		var gndspd = getprop("/velocities/groundspeed-kt");
		var desfpm = ((gndspd * 0.5) * 10);
		setprop("/it-autoflight/internal/prof-fpm", desfpm);
	}
}

# VNAV Capture
var vnav_altcapt = func {
	var vsnow = getprop("/it-autoflight/internal/vert-speed-fpm");
	if ((vsnow >= 0 and vsnow < 500) or (vsnow < 0 and vsnow > -500)) {
		setprop("/it-autoflight/internal/captvs", 100);
		setprop("/it-autoflight/internal/captvsneg", -100);
	} else  if ((vsnow >= 500 and vsnow < 1000) or (vsnow < -500 and vsnow > -1000)) {
		setprop("/it-autoflight/internal/captvs", 150);
		setprop("/it-autoflight/internal/captvsneg", -150);
	} else  if ((vsnow >= 1000 and vsnow < 1500) or (vsnow < -1000 and vsnow > -1500)) {
		setprop("/it-autoflight/internal/captvs", 200);
		setprop("/it-autoflight/internal/captvsneg", -200);
	} else  if ((vsnow >= 1500 and vsnow < 2000) or (vsnow < -1500 and vsnow > -2000)) {
		setprop("/it-autoflight/internal/captvs", 300);
		setprop("/it-autoflight/internal/captvsneg", -300);
	} else  if ((vsnow >= 2000 and vsnow < 3000) or (vsnow < -2000 and vsnow > -3000)) {
		setprop("/it-autoflight/internal/captvs", 450);
		setprop("/it-autoflight/internal/captvsneg", -450);
	} else  if ((vsnow >= 3000 and vsnow < 4000) or (vsnow < -3000 and vsnow > -4000)) {
		setprop("/it-autoflight/internal/captvs", 650);
		setprop("/it-autoflight/internal/captvsneg", -650);
	} else  if ((vsnow >= 4000 and vsnow < 5000) or (vsnow < -4000 and vsnow > -5000)) {
		setprop("/it-autoflight/internal/captvs", 1000);
		setprop("/it-autoflight/internal/captvsneg", -1000);
	} else  if ((vsnow >= 5000) or (vsnow < -5000)) {
		setprop("/it-autoflight/internal/captvs", 1250);
		setprop("/it-autoflight/internal/captvsneg", -1250);
	}
	var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var valt = getprop("/it-autoflight/internal/prof-alt");
	var vdif = calt - valt;
	if (vdif < getprop("/it-autoflight/internal/captvs") and vdif > getprop("/it-autoflight/internal/captvsneg")) {
		vnav_capture_alt();
	}
}

var vnav_capture_alt = func {
	vnav_altcaptt.stop();
	vnav_des_fpmt.stop();
	var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var alt = getprop("/it-autoflight/internal/alt");
	var valt = getprop("/it-autoflight/internal/prof-alt");
	var pitchdeg = getprop("/orientation/pitch-deg");
	if (calt < valt) {
		setprop("/it-autoflight/internal/max-pitch", pitchdeg);
	} else if (calt > valt) {
		setprop("/it-autoflight/internal/min-pitch", pitchdeg);
	}
	vnav_minmaxt.start();
	setprop("/it-autoflight/output/thr-mode", 0);
	setprop("/it-autoflight/output/prof-vert", 0);
	setprop("/it-autoflight/mode/thr", "THRUST");
	setprop("/it-autoflight/mode/prof", "VNAV CAP");
}

# VNAV Min and Max Pitch Reset
var vnav_minmax = func {
	var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var valt = getprop("/it-autoflight/internal/prof-alt");
	var vdif = calt - valt;
	if (vdif < 50 and vdif > -50) {
		setprop("/it-autoflight/internal/max-pitch", 8);
		setprop("/it-autoflight/internal/min-pitch", -5);
		var vertmode = getprop("/it-autoflight/output/prof-vert");
		if (vertmode == 0) {
			setprop("/it-autoflight/mode/prof", "VNAV HLD");
		}
		vnav_minmaxt.stop();
	}
}

# CWS
var cwsroll = func {
  var ail = getprop("/controls/flight/aileron");
  if (ail < 0.05 and ail > -0.05) {
	if (getprop("/it-autoflight/internal/cwsr") == 0) {
      setprop("/it-autoflight/internal/cws-roll-deg", getprop("/orientation/roll-deg"));
	}
	setprop("/it-autoflight/internal/cwsr", 1);
  } else {
	setprop("/it-autoflight/internal/cwsr", 0);
  }
}

var cwspitch = func {
	var elv = getprop("/controls/flight/elevator");
	if (elv < 0.05 and elv > -0.05) {
		if (getprop("/it-autoflight/internal/cwsp") == 0) {
			setprop("/it-autoflight/internal/cws-pitch-deg", getprop("/orientation/pitch-deg"));
		}
		setprop("/it-autoflight/internal/cwsp", 1);
	} else {
		setprop("/it-autoflight/internal/cwsp", 0);
	}
}

# For Canvas Nav Display.
setlistener("/it-autoflight/input/hdg", func {
	setprop("/autopilot/settings/heading-bug-deg", getprop("/it-autoflight/input/hdg"));
});

setlistener("/it-autoflight/internal/alt", func {
	setprop("/autopilot/settings/target-altitude-ft", getprop("/it-autoflight/internal/alt"));
});

# Timers
var update_armst = maketimer(0.5, update_arms);
var altcaptt = maketimer(0.5, altcapt);
var thrustmodet = maketimer(0.5, thrustmode);
var minmaxtimer = maketimer(0.5, minmax);
var retardt = maketimer(0.5, retardchk);
var atofft = maketimer(0.5, atoffchk);
var alandt = maketimer(0.5, aland);
var alandt1 = maketimer(0.5, aland1);
var cwsrollt = maketimer(0.1, cwsroll);
var cwspitcht = maketimer(0.1, cwspitch);
var reduct = maketimer(0.5, toga_reduc);
var latarmt = maketimer(0.5, latarms);
var fpa_calct = maketimer(0.1, fpa_calc);
var lnavwptt = maketimer(1, lnavwpt);
var prof_maint = maketimer(0.5, prof_main);
var vnav_altcaptt = maketimer(0.5, vnav_altcapt);
var vnav_minmaxt = maketimer(0.5, vnav_minmax);
var vnav_des_fpmt = maketimer(0.5, vnav_des_fpm);
var vnav_des_todt = maketimer(0.5, vnav_des_tod);
