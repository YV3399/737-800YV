# Boeing PFD FMA
# Joshua Davidson (it0uchpods)

setprop("/autopilot/display/throttle-mode-rectangle", 0);
setprop("/autopilot/display/roll-mode-rectangle", 0);
setprop("/autopilot/display/pitch-mode-rectangle", 0);
setprop("/autopilot/display/afds-mode-rectangle", 0);
setprop("/autopilot/display/throttle-mode-rectangle-time", 0);
setprop("/autopilot/display/roll-mode-rectangle-time", 0);
setprop("/autopilot/display/pitch-mode-rectangle-time", 0);
setprop("/autopilot/display/afds-mode-rectangle-time", 0);
setprop("/it-autoflight/custom/athr-deactivate", 0);
setprop("/controls/engines/throttle-cmd-norm", 0);

setlistener("sim/signals/fdm-initialized", func {
	loopFMA.start();
});

var loopFMA = maketimer(0.05, func {
	# Boxes
	var boxtime = getprop("/sim/time/elapsed-sec");
	if (getprop("/autopilot/display/throttle-mode-rectangle-time") + 10 >= boxtime) {
		setprop("/autopilot/display/throttle-mode-rectangle", 1);
	} else {
		setprop("/autopilot/display/throttle-mode-rectangle", 0);
	}
	if (getprop("/autopilot/display/roll-mode-rectangle-time") + 10 >= boxtime) {
		setprop("/autopilot/display/roll-mode-rectangle", 1);
	} else {
		setprop("/autopilot/display/roll-mode-rectangle", 0);
	}
	if (getprop("/autopilot/display/pitch-mode-rectangle-time") + 10 >= boxtime) {
		setprop("/autopilot/display/pitch-mode-rectangle", 1);
	} else {
		setprop("/autopilot/display/pitch-mode-rectangle", 0);
	}
	if (getprop("/autopilot/display/afds-mode-rectangle-time") + 10 >= boxtime) {
		setprop("/autopilot/display/afds-mode-rectangle", 1);
	} else {
		setprop("/autopilot/display/afds-mode-rectangle", 0);
	}
});

# Master Thrust
setlistener("/it-autoflight/output/thr-mode", func {
	var thr = getprop("/it-autoflight/output/thr-mode");
	var newthr = getprop("/autopilot/display/throttle-mode");
	if (thr == 0) {
		thrIdle.stop();
		setprop("/it-autoflight/custom/athr-deactivate", 0);
		if (newthr != "MCP SPD") {
			setprop("/autopilot/display/throttle-mode", "MCP SPD");
		}
	} else if (thr == 1) {
		thrIdle.start();
	} else if (thr == 2) {
		thrIdle.stop();
		setprop("/it-autoflight/custom/athr-deactivate", 0);
		if (newthr != "N1") {
			setprop("/autopilot/display/throttle-mode", "N1");
		}
	}
});

var thrIdle = maketimer(0.25, func {
	var newthr = getprop("/autopilot/display/throttle-mode");
	if (getprop("/controls/engines/throttle-cmd-norm") < 0.021) {
		setprop("/it-autoflight/custom/athr-deactivate", 1);
		if (newthr != "ARM") {
			setprop("/autopilot/display/throttle-mode", "ARM");
		}
	} else {
		setprop("/it-autoflight/custom/athr-deactivate", 0);
		if (newthr != "RETARD") {
			setprop("/autopilot/display/throttle-mode", "RETARD");
		}
	}
});

# Master Lateral
setlistener("/it-autoflight/mode/lat", func {
	var lat = getprop("/it-autoflight/mode/lat");
	var newlat = getprop("/autopilot/display/roll-mode");
	if (lat == "HDG") {
		if (newlat != "HDG") {
			setprop("/autopilot/display/roll-mode", "HDG");
		}
	} else if (lat == "LNAV") {
		if (newlat != "LNAV") {
			setprop("/autopilot/display/roll-mode", "LNAV");
		}
	} else if (lat == "LOC") {
		if (newlat != "LOC") {
			setprop("/autopilot/display/roll-mode", "LOC");
		}
	} else if (lat == "ALGN") {
		if (newlat != "ALIGN") {
			setprop("/autopilot/display/roll-mode", "ALIGN");
		}
	} else if (lat == "RLOU") {
		if (newlat != "ROLLOUT") {
			setprop("/autopilot/display/roll-mode", "ROLLOUT");
		}
	} else if (lat == "T/O") {
		if (newlat != "T/O") {
			setprop("/autopilot/display/roll-mode", "T/O");
		}
	} else if (lat == " ") {
		if (newlat != " ") {
			setprop("/autopilot/display/roll-mode", " ");
		}
	}
});

# Master Vertical
setlistener("/it-autoflight/mode/vert", func {
	var vert = getprop("/it-autoflight/mode/vert");
	var newvert = getprop("/autopilot/display/pitch-mode");
	var newvertarm = getprop("/autopilot/display/pitch-mode-armed");
	if (vert == "ALT HLD") {
		if (newvert != "ALT HLD") {
			setprop("/autopilot/display/pitch-mode", "ALT HLD");
		}
	} else if (vert == "ALT CAP") {
		if (newvert != "ALT ACQ") {
			setprop("/autopilot/display/pitch-mode", "ALT ACQ");
		}
	} else if (vert == "V/S") {
		if (newvert != "V/S") {
			setprop("/autopilot/display/pitch-mode", "V/S");
		}
	} else if (vert == "G/S") {
		if (newvert != "G/S") {
			setprop("/autopilot/display/pitch-mode", "G/S");
		}
	} else if (vert == "SPD CLB") {
		if (newvert != "MCP SPD") {
			setprop("/autopilot/display/pitch-mode", "MCP SPD");
		}
	} else if (vert == "SPD DES") {
		if (newvert != "MCP SPD") {
			setprop("/autopilot/display/pitch-mode", "MCP SPD");
		}
	} else if (vert == "FPA") {
		if (newvert != "FPA") {
			setprop("/autopilot/display/pitch-mode", "FPA");
		}
	} else if (vert == "LAND") {
		if (newvert != "G/S") {
			setprop("/autopilot/display/pitch-mode", "G/S");
		}
		if (newvertarm != "FLARE") {
			setprop("/autopilot/display/pitch-mode-armed", "FLARE");
		}
	} else if (vert == "FLARE") {
		if (newvert != "FLARE") {
			setprop("/autopilot/display/pitch-mode", "FLARE");
		}
		if (newvertarm != " ") {
			setprop("/autopilot/display/pitch-mode-armed", " ");
		}
	} else if (vert == "ROLLOUT") {
		if (newvert != "ROLLOUT") {
			setprop("/autopilot/display/pitch-mode", "ROLLOUT");
		}
		if (newvertarm != " ") {
			setprop("/autopilot/display/pitch-mode-armed", " ");
		}
	} else if (vert == "T/O CLB") {
		if (newvert != "T/O") {
			setprop("/autopilot/display/pitch-mode", "T/O");
		}
		if (newvertarm != " ") {
			setprop("/autopilot/display/pitch-mode-armed", " ");
		}
	} else if (vert == "G/A CLB") {
		if (newvert != "G/A") {
			setprop("/autopilot/display/pitch-mode", "G/A");
		}
		if (newvertarm != " ") {
			setprop("/autopilot/display/pitch-mode-armed", " ");
		}
	} else if (vert == " ") {
		if (newvert != " ") {
			setprop("/autopilot/display/pitch-mode", " ");
		}
	}
});

# Arm LOC
setlistener("/it-autoflight/output/loc-armed", func {
	var loca = getprop("/it-autoflight/output/loc-armed");
	if (loca) {
		setprop("/autopilot/display/roll-mode-armed", "LOC");
	} else {
		setprop("/autopilot/display/roll-mode-armed", " ");
	}
});

# Arm G/S
setlistener("/it-autoflight/output/appr-armed", func {
	var appa = getprop("/it-autoflight/output/appr-armed");
	if (appa) {
		setprop("/autopilot/display/pitch-mode-armed", "G/S");
	} else {
		setprop("/autopilot/display/pitch-mode-armed", " ");
	}
});

# CMD or FD or CWS
var apfd = func {
	var ap1 = getprop("/it-autoflight/output/ap1");
	var ap2 = getprop("/it-autoflight/output/ap2");
	var cwsa = getprop("/it-cws/cwsa-output");
	var cwsb = getprop("/it-cws/cwsb-output");
	var fd1 = getprop("/it-autoflight/output/fd1");
	var fd2 = getprop("/it-autoflight/output/fd2");
	var newapfd = getprop("/autopilot/display/afds-mode");
	if (ap1 or ap2) {
		if (newapfd != "CMD") {
			setprop("/autopilot/display/afds-mode", "CMD");
		}
	} else if (cwsa or cwsb) {
		if (newapfd != "CWS") {
			setprop("/autopilot/display/afds-mode", "CWS");
		}
	} else if (fd1 or fd2) {
		if (newapfd != "FD") {
			setprop("/autopilot/display/afds-mode", "FD");
		}
	} else {
		if (newapfd != " ") {
			setprop("/autopilot/display/afds-mode", " ");
		}
	}
}

# Update CMD or FD or CWS
setlistener("/it-autoflight/output/ap1", func {
	apfd();
});
setlistener("/it-autoflight/output/ap2", func {
	apfd();
});
setlistener("/it-autoflight/output/fd1", func {
	apfd();
});
setlistener("/it-autoflight/output/fd2", func {
	apfd();
});
setlistener("/it-cws/cwsa-output", func {
	apfd();
});
setlistener("/it-cws/cwsb-output", func {
	apfd();
});

# Boxes
setlistener("/autopilot/display/throttle-mode", func {
	if (getprop("/autopilot/display/throttle-mode") != " " and getprop("/autopilot/display/throttle-mode") != "ARM") {
		setprop("/autopilot/display/throttle-mode-rectangle-time", getprop("/sim/time/elapsed-sec"));
	}
});

setlistener("/autopilot/display/roll-mode", func {
	if (getprop("/autopilot/display/roll-mode") != " ") {
		setprop("/autopilot/display/roll-mode-rectangle-time", getprop("/sim/time/elapsed-sec"));
	}
});

setlistener("/autopilot/display/pitch-mode", func {
	if (getprop("/autopilot/display/pitch-mode") != " ") {
		setprop("/autopilot/display/pitch-mode-rectangle-time", getprop("/sim/time/elapsed-sec"));
	}
});

setlistener("/autopilot/display/afds-mode", func {
	if (getprop("/autopilot/display/afds-mode") != " ") {
		setprop("/autopilot/display/afds-mode-rectangle-time", getprop("/sim/time/elapsed-sec"));
	}
});
