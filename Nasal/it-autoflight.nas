# IT AUTOFLIGHT System Controller
# Joshua Davidson (it0uchpods)
# V3.0.3 Stable
# This program is 100% GPL!

setprop("/it-autoflight/internal/vert-speed-fpm", 0);

setlistener("/sim/signals/fdm-initialized", func {
	var trueSpeedKts = getprop("/instrumentation/airspeed-indicator/true-speed-kt");
	var locdefl = getprop("/instrumentation/nav[0]/heading-needle-deflection-norm");
	var locdefl_b = getprop("/instrumentation/nav[1]/heading-needle-deflection-norm");
	var signal = getprop("/instrumentation/nav[0]/gs-needle-deflection-norm");
	var signal_b = getprop("/instrumentation/nav[1]/gs-needle-deflection-norm");
	var VS = getprop("/velocities/vertical-speed-fps");
	var TAS = getprop("/velocities/uBody-fps");
	var FPangle = 0;
	var bank_limit_sw = 0;
});

var ap_init = func {
	setprop("/it-autoflight/input/kts-mach", 0);
	setprop("/it-autoflight/input/ap1", 0);
	setprop("/it-autoflight/input/ap2", 0);
	setprop("/it-autoflight/input/athr", 0);
	setprop("/it-autoflight/input/fd1", 0);
	setprop("/it-autoflight/input/fd2", 0);
	setprop("/it-autoflight/input/hdg", 360);
	setprop("/it-autoflight/input/alt", 10000);
	setprop("/it-autoflight/input/vs", 0);
	setprop("/it-autoflight/input/fpa", 0);
	setprop("/it-autoflight/input/lat", 5);
	setprop("/it-autoflight/input/lat-arm", 0);
	setprop("/it-autoflight/input/vert", 7);
	setprop("/it-autoflight/input/trk", 0);
	setprop("/it-autoflight/input/toga", 0);
	setprop("/it-autoflight/input/bank-limit-sw", 0);
	setprop("/it-autoflight/output/ap1", 0);
	setprop("/it-autoflight/output/ap2", 0);
	setprop("/it-autoflight/output/athr", 0);
	setprop("/it-autoflight/output/fd1", 0);
	setprop("/it-autoflight/output/fd2", 0);
	setprop("/it-autoflight/output/loc-armed", 0);
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/output/thr-mode", 2);
	setprop("/it-autoflight/output/retard", 0);
	setprop("/it-autoflight/output/lat", 5);
	setprop("/it-autoflight/output/vert", 7);
	setprop("/it-autoflight/settings/use-nav2-radio", 0);
	setprop("/it-autoflight/internal/min-vs", -500);
	setprop("/it-autoflight/internal/max-vs", 500);
	setprop("/it-autoflight/internal/bank-limit-auto", 25);
	setprop("/it-autoflight/internal/bank-limit", 25);
	setprop("/it-autoflight/internal/alt", 10000);
	setprop("/it-autoflight/internal/fpa", 0);
	setprop("/it-autoflight/internal/top-of-des-nm", 0);
	setprop("/it-autoflight/mode/thr", "PITCH");
	setprop("/it-autoflight/mode/arm", "HDG");
	setprop("/it-autoflight/mode/lat", "T/O");
	setprop("/it-autoflight/mode/vert", "T/O CLB");
	setprop("/it-autoflight/input/spd-kts", 250);
	setprop("/it-autoflight/input/spd-mach", 0.68);
	ap_varioust.start();
	thrustmode();
}

# AP 1 Master System
setlistener("/it-autoflight/input/ap1", func {
	var apmas = getprop("/it-autoflight/input/ap1");
	if (apmas == 0) {
		setprop("/it-autoflight/output/ap1", 0);
		setprop("/controls/flight/aileron", 0);
		setprop("/controls/flight/elevator", 0);
		setprop("/controls/flight/rudder", 0);
		if (getprop("/it-autoflight/sound/enableapoffsound") == 1) {
			setprop("/it-autoflight/sound/apoffsound", 1);
			setprop("/it-autoflight/sound/enableapoffsound", 0);	  
		}
	} else if (apmas == 1) {
		if ((getprop("/gear/gear[1]/wow") == 0) and (getprop("/gear/gear[2]/wow") == 0)) {
			setprop("/controls/flight/rudder", 0);
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
		setprop("/controls/flight/aileron", 0);
		setprop("/controls/flight/elevator", 0);
		setprop("/controls/flight/rudder", 0);
		if (getprop("/it-autoflight/sound/enableapoffsound2") == 1) {
			setprop("/it-autoflight/sound/apoffsound2", 1);	
			setprop("/it-autoflight/sound/enableapoffsound2", 0);	  
		}
	} else if (apmas == 1) {
		if ((getprop("/gear/gear[1]/wow") == 0) and (getprop("/gear/gear[2]/wow") == 0)) {
			setprop("/controls/flight/rudder", 0);
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
		setprop("/it-autoflight/output/retard", 0);
		thrustmode();
		setprop("/it-autoflight/output/athr", 1);
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
		setprop("/it-autoflight/output/loc-armed", 0);
		setprop("/it-autoflight/output/appr-armed", 0);
		setprop("/it-autoflight/output/lat", 0);
		setprop("/it-autoflight/mode/lat", "HDG");
		setprop("/it-autoflight/mode/arm", " ");
	} else if (latset == 1) {
		if (getprop("/autopilot/route-manager/route/num") > 0 and getprop("/autopilot/route-manager/active") == 1) {
			alandt.stop();
			alandt1.stop();
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
		setprop("/it-autoflight/output/loc-armed", 0);
		setprop("/it-autoflight/output/appr-armed", 0);
		var hdgnow = int(getprop("/orientation/heading-magnetic-deg")+0.5);
		setprop("/it-autoflight/input/hdg", hdgnow);
		setprop("/it-autoflight/output/lat", 0);
		setprop("/it-autoflight/mode/lat", "HDG");
		setprop("/it-autoflight/mode/arm", " ");
	} else if (latset == 4) {
		setprop("/it-autoflight/output/lat", 4);
		setprop("/it-autoflight/mode/lat", "ALGN");
	} else if (latset == 5) {
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
	}
});

var vertical = func {
	var vertset = getprop("/it-autoflight/input/vert");
	if (vertset == 0) {
		alandt.stop();
		alandt1.stop();
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
		}
	} else if (vertset == 3) {
		alandt.stop();
		alandt1.stop();
		var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		var alt = getprop("/it-autoflight/internal/alt");
		var dif = calt - alt;
		var vsnow = getprop("/it-autoflight/internal/vert-speed-fpm");
		if (calt < alt) {
			setprop("/it-autoflight/internal/max-vs", vsnow);
		} else if (calt > alt) {
			setprop("/it-autoflight/internal/min-vs", vsnow);
		}
		minmaxtimer.start();
		thrustmode();
		setprop("/it-autoflight/output/vert", 0);
		setprop("/it-autoflight/mode/vert", "ALT CAP");
	} else if (vertset == 4) {
		alandt.stop();
		alandt1.stop();
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
	} else if (vertset == 7) {
		alandt.stop();
		alandt1.stop();
		setprop("/it-autoflight/output/vert", 7);
		setprop("/it-autoflight/mode/arm", " ");
		var altinput = getprop("/it-autoflight/input/alt");
		setprop("/it-autoflight/internal/alt", altinput);
		thrustmodet.start();
	}
}

# Helpers
var ap_various = func {
	trueSpeedKts = getprop("/instrumentation/airspeed-indicator/true-speed-kt");
	if (trueSpeedKts > 420) {
		if (getprop("/it-autoflight/settings/auto-bank-max-deg") < 10) {
			setprop("/it-autoflight/internal/bank-limit-auto", 5);
		} else if (getprop("/it-autoflight/settings/auto-bank-max-deg") < 15) {
			setprop("/it-autoflight/internal/bank-limit-auto", 10);
		} else {
			setprop("/it-autoflight/internal/bank-limit-auto", 15);
		}
	} else if (trueSpeedKts > 340) {
		if (getprop("/it-autoflight/settings/auto-bank-max-deg") < 10) {
			setprop("/it-autoflight/internal/bank-limit-auto", 5);
		} else if (getprop("/it-autoflight/settings/auto-bank-max-deg") < 15) {
			setprop("/it-autoflight/internal/bank-limit-auto", 10);
		} else if (getprop("/it-autoflight/settings/auto-bank-max-deg") < 20) {
			setprop("/it-autoflight/internal/bank-limit-auto", 15);
		} else {
			setprop("/it-autoflight/internal/bank-limit-auto", 20);
		}
	} else {
		if (getprop("/it-autoflight/settings/auto-bank-max-deg") < 10) {
			setprop("/it-autoflight/internal/bank-limit-auto", 5);
		} else if (getprop("/it-autoflight/settings/auto-bank-max-deg") < 15) {
			setprop("/it-autoflight/internal/bank-limit-auto", 10);
		} else if (getprop("/it-autoflight/settings/auto-bank-max-deg") < 20) {
			setprop("/it-autoflight/internal/bank-limit-auto", 15);
		} else if (getprop("/it-autoflight/settings/auto-bank-max-deg") < 25) {
			setprop("/it-autoflight/internal/bank-limit-auto", 20);
		} else if (getprop("/it-autoflight/settings/auto-bank-max-deg") < 30) {
			setprop("/it-autoflight/internal/bank-limit-auto", 25);
		} else {
			setprop("/it-autoflight/internal/bank-limit-auto", 30);
		}
	}
	
	bank_limit_sw = getprop("/it-autoflight/input/bank-limit-sw");
	if (bank_limit_sw == 0) {
		setprop("/it-autoflight/internal/bank-limit", getprop("/it-autoflight/internal/bank-limit-auto"));
	} else if (bank_limit_sw == 1) {
		setprop("/it-autoflight/internal/bank-limit", 5);
	} else if (bank_limit_sw == 2) {
		setprop("/it-autoflight/internal/bank-limit", 10);
	} else if (bank_limit_sw == 3) {
		setprop("/it-autoflight/internal/bank-limit", 15);
	} else if (bank_limit_sw == 4) {
		setprop("/it-autoflight/internal/bank-limit", 20);
	} else if (bank_limit_sw == 5) {
		setprop("/it-autoflight/internal/bank-limit", 25);
	} else if (bank_limit_sw == 6) {
		setprop("/it-autoflight/internal/bank-limit", 30);
	}
	
	if (getprop("/autopilot/route-manager/route/num") > 0 and getprop("/autopilot/route-manager/active") == 1) {
		if (getprop("/autopilot/route-manager/wp/dist") <= 1.0) {
			if ((getprop("/autopilot/route-manager/current-wp") + 1) < getprop("/autopilot/route-manager/route/num")) {
				setprop("/autopilot/route-manager/current-wp", getprop("/autopilot/route-manager/current-wp") + 1);
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
	setprop("/it-autoflight/internal/max-vs", 500);
	setprop("/it-autoflight/internal/min-vs", -500);
	minmaxtimer.start();
}

var fpa_calc = func {
	VS = getprop("/velocities/vertical-speed-fps");
	TAS = getprop("/velocities/uBody-fps");
	if (TAS < 10) TAS = 10;
	if (VS < -200) VS =-200;
	if (abs(VS/TAS) <= 1) {
		FPangle = math.asin(VS/TAS);
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
		setprop("/it-autoflight/input/athr", 1);
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
		setprop("/it-autoflight/input/vert", 4);
	}
}

# Altitude Capture and FPA Timer Logic
setlistener("/it-autoflight/output/vert", func {
	var vertm = getprop("/it-autoflight/output/vert");
	if (vertm == 1) {
		altcaptt.start();
		fpa_calct.stop();
	} else if (vertm == 4) {
		altcaptt.start();
		fpa_calct.stop();
	} else if (vertm == 5) {
		altcaptt.start();
	} else if (vertm == 7) {
		altcaptt.start();
		fpa_calct.stop();
	} else {
		altcaptt.stop();
		fpa_calct.stop();
	}
});

# Altitude Capture
var altcapt = func {
	var vsnow = getprop("/it-autoflight/internal/vert-speed-fpm");
	if ((vsnow >= 0 and vsnow < 500) or (vsnow < 0 and vsnow > -500)) {
		setprop("/it-autoflight/internal/captvs", 100);
		setprop("/it-autoflight/internal/captvsneg", -100);
	} else  if ((vsnow >= 500 and vsnow < 1000) or (vsnow < -500 and vsnow > -1000)) {
		setprop("/it-autoflight/internal/captvs", 200);
		setprop("/it-autoflight/internal/captvsneg", -200);
	} else  if ((vsnow >= 1000 and vsnow < 1500) or (vsnow < -1000 and vsnow > -1500)) {
		setprop("/it-autoflight/internal/captvs", 300);
		setprop("/it-autoflight/internal/captvsneg", -300);
	} else  if ((vsnow >= 1500 and vsnow < 2000) or (vsnow < -1500 and vsnow > -2000)) {
		setprop("/it-autoflight/internal/captvs", 400);
		setprop("/it-autoflight/internal/captvsneg", -400);
	} else  if ((vsnow >= 2000 and vsnow < 3000) or (vsnow < -2000 and vsnow > -3000)) {
		setprop("/it-autoflight/internal/captvs", 600);
		setprop("/it-autoflight/internal/captvsneg", -600);
	} else  if ((vsnow >= 3000 and vsnow < 4000) or (vsnow < -3000 and vsnow > -4000)) {
		setprop("/it-autoflight/internal/captvs", 900);
		setprop("/it-autoflight/internal/captvsneg", -900);
	} else  if ((vsnow >= 4000 and vsnow < 5000) or (vsnow < -4000 and vsnow > -5000)) {
		setprop("/it-autoflight/internal/captvs", 1200);
		setprop("/it-autoflight/internal/captvsneg", -1200);
	} else  if ((vsnow >= 5000) or (vsnow < -5000)) {
		setprop("/it-autoflight/internal/captvs", 1500);
		setprop("/it-autoflight/internal/captvsneg", -1500);
	}
	var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var alt = getprop("/it-autoflight/internal/alt");
	var dif = calt - alt;
	if (dif < getprop("/it-autoflight/internal/captvs") and dif > getprop("/it-autoflight/internal/captvsneg")) {
		if (vsnow > 0 and dif < 0) {
			setprop("/it-autoflight/input/vert", 3);
			setprop("/it-autoflight/output/thr-mode", 0);
			setprop("/it-autoflight/mode/thr", "THRUST");
		} else if (vsnow < 0 and dif > 0) {
			setprop("/it-autoflight/input/vert", 3);
			setprop("/it-autoflight/output/thr-mode", 0);
			setprop("/it-autoflight/mode/thr", "THRUST");
		}
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
		setprop("/it-autoflight/internal/max-vs", 500);
		setprop("/it-autoflight/internal/min-vs", -500);
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
	if (getprop("/it-autoflight/output/vert") == 4) {
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
	} else if (getprop("/it-autoflight/output/vert") == 7) {
		setprop("/it-autoflight/output/thr-mode", 2);
		setprop("/it-autoflight/mode/thr", " PITCH");
	} else {
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
setlistener("/it-autoflight/output/loc-armed", func {
	check_arms();
});

setlistener("/it-autoflight/output/appr-armed", func {
	check_arms();
});

var check_arms = func {
	if (getprop("/it-autoflight/output/loc-armed") or getprop("/it-autoflight/output/appr-armed")) {
		update_armst.start();
	} else {
		update_armst.stop();
	}
}

var update_arms = func {
	if (getprop("/it-autoflight/output/loc-armed")) {
		locdefl = getprop("/instrumentation/nav[0]/heading-needle-deflection-norm");
		locdefl_b = getprop("/instrumentation/nav[1]/heading-needle-deflection-norm");
		if ((locdefl < 0.9233) and (getprop("/instrumentation/nav[0]/signal-quality-norm") > 0.99) and (getprop("/it-autoflight/settings/use-nav2-radio") == 0)) {
			make_loc_active();
		} else if ((locdefl_b < 0.9233) and (getprop("/instrumentation/nav[1]/signal-quality-norm") > 0.99) and (getprop("/it-autoflight/settings/use-nav2-radio") == 1)) {
			make_loc_active();
		} else {
			return 0;
		}
	}
	if (getprop("/it-autoflight/output/appr-armed")) {
		signal = getprop("/instrumentation/nav[0]/gs-needle-deflection-norm");
		signal_b = getprop("/instrumentation/nav[1]/gs-needle-deflection-norm");
		if (((signal < 0 and signal >= -0.30) or (signal > 0 and signal <= 0.30)) and (getprop("/it-autoflight/settings/use-nav2-radio") == 0) and (getprop("/it-autoflight/output/lat") == 2)) {
			make_appr_active();
		} else if (((signal_b < 0 and signal_b >= -0.30) or (signal_b > 0 and signal_b <= 0.30)) and (getprop("/it-autoflight/settings/use-nav2-radio") == 1) and (getprop("/it-autoflight/output/lat") == 2)) {
			make_appr_active();
		} else {
			return 0;
		}
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

var make_appr_active = func {
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/output/vert", 2);
	setprop("/it-autoflight/mode/vert", "G/S");
	setprop("/it-autoflight/mode/arm", " ");
	if (getprop("/it-autoflight/settings/land-enable") == 1) {
		alandt.start();
	}
	thrustmode();
}

# Autoland Stage 1 Logic (Land)
var aland = func {
	var ap1 = getprop("/it-autoflight/output/ap1");
	var ap2 = getprop("/it-autoflight/output/ap2");
	var landoption = getprop("/it-autoflight/settings/autoland-without-ap");
	if (getprop("/position/gear-agl-ft") <= 100) {
		if (ap1 == 1 or ap2 == 1) {
			setprop("/it-autoflight/input/lat", 4);
			setprop("/it-autoflight/input/vert", 6);
		} else if (ap1 == 0 and ap2 == 0 and landoption) {
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
	if (aglal <= 50 and aglal > 5) {
		setprop("/it-autoflight/mode/vert", "FLARE");
	}
	if ((getprop("/it-autoflight/output/ap1") == 0) and (getprop("/it-autoflight/output/ap2") == 0) and (getprop("/it-autoflight/settings/autoland-without-ap") == 0)) {
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
var reduct = maketimer(0.5, toga_reduc);
var latarmt = maketimer(0.5, latarms);
var fpa_calct = maketimer(0.1, fpa_calc);
var ap_varioust = maketimer(1, ap_various);
