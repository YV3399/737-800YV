# IT AUTOFLIGHT System Controller by Joshua Davidson (it0uchpods/411).
# V3.0.0 Build 111
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
	setprop("/it-autoflight/input/spd-kts", 200);
	setprop("/it-autoflight/input/spd-mach", 0.68);
	setprop("/it-autoflight/input/hdg", 360);
	setprop("/it-autoflight/input/alt", 10000);
	setprop("/it-autoflight/input/vs", 0);
	setprop("/it-autoflight/input/lat", 5);
	setprop("/it-autoflight/input/vert", 7);
	setprop("/it-autoflight/input/bank-limit", 30);
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
	setprop("/it-autoflight/settings/min-pitch", -8);
	setprop("/it-autoflight/settings/max-pitch", 8);
	setprop("/it-autoflight/internal/min-pitch", -8);
	setprop("/it-autoflight/internal/max-pitch", 8);
	setprop("/it-autoflight/internal/alt", 10000);
	setprop("/it-autoflight/internal/cwsr", 0);
	setprop("/it-autoflight/internal/cwsp", 0);
    setprop("/it-autoflight/autoland/target-vs", "-650");
    setprop("/it-autoflight/mode/lat", "T/O");
    setprop("/it-autoflight/mode/vert", "T/O CLB");
	thrustmode();
	update_arms();
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
	setprop("/controls/flight/rudder", 0);
	setprop("/it-autoflight/output/ap1", 1);
	setprop("/it-autoflight/sound/enableapoffsound", 1);
	setprop("/it-autoflight/sound/apoffsound", 0);
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
	setprop("/controls/flight/rudder", 0);
	setprop("/it-autoflight/output/ap2", 1);
	setprop("/it-autoflight/sound/enableapoffsound2", 1);
	setprop("/it-autoflight/sound/apoffsound2", 0);
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
	setprop("/it-autoflight/sound/enableapoffsound", 1);
	setprop("/it-autoflight/sound/apoffsound", 0);		  
	setprop("/it-autoflight/sound/enableapoffsound2", 1);
	setprop("/it-autoflight/sound/apoffsound2", 0);
	setprop("/it-autoflight/output/ap1", 0);
	setprop("/it-autoflight/output/ap2", 0);
	setprop("/it-autoflight/internal/cws-roll-deg", getprop("/orientation/roll-deg"));
	setprop("/it-autoflight/internal/cws-pitch-deg", getprop("/orientation/pitch-deg"));
	cwsrollt.start();
	cwspitcht.start();
	setprop("/it-autoflight/output/cws", 1);
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
  lateral();
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
	alandt.stop();
	alandt1.stop();
	setprop("/it-autoflight/output/loc-armed", 0);
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/output/lat", 1);
	setprop("/it-autoflight/mode/lat", "LNAV");
	setprop("/it-autoflight/mode/arm", " ");
  } else if (latset == 2) {
	setprop("/instrumentation/nav/signal-quality-norm", 0);
	setprop("/it-autoflight/output/loc-armed", 1);
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/mode/arm", "LOC");
  } else if (latset == 3) {
	alandt.stop();
	alandt1.stop();
	setprop("/it-autoflight/output/loc-armed", 0);
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/output/lat", 0);
	setprop("/it-autoflight/mode/lat", "HDG");
	setprop("/it-autoflight/mode/arm", " ");
    var hdgnow = int(getprop("/orientation/heading-magnetic-deg")+0.5);
	setprop("/it-autoflight/input/hdg", hdgnow);
  } else if (latset == 4) {
	setprop("/it-autoflight/output/lat", 4);
	setprop("/it-autoflight/mode/lat", "ALGN");
  } else if (latset == 5) {
	setprop("/it-autoflight/output/lat", 5);
  }
}

# Master Vertical
setlistener("/it-autoflight/input/vert", func {
  vertical();
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
    var altinput = getprop("/it-autoflight/input/alt");
	setprop("/it-autoflight/internal/alt", altinput);
	var vsnow = int(getprop("/velocities/vertical-speed-fps")*0.6)*100;
	setprop("/it-autoflight/input/vs", vsnow);
	setprop("/it-autoflight/output/appr-armed", 0);
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
	  # Do nothing because VORLOC is active
	} else {
	  setprop("/instrumentation/nav/signal-quality-norm", 0);
	  setprop("/it-autoflight/output/loc-armed", 1);
	}
	setprop("/instrumentation/nav/gs-rate-of-climb", 0);
	setprop("/it-autoflight/output/appr-armed", 1);
	setprop("/it-autoflight/mode/arm", "ILS");
    setprop("/it-autoflight/autoland/target-vs", "-650");
  } else if (vertset == 3) {
	alandt.stop();
	alandt1.stop();
	var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var alt = getprop("/it-autoflight/internal/alt");
	var dif = calt - alt;
	var pitchdeg = getprop("/orientation/pitch-deg");
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
	var altinput = getprop("/it-autoflight/input/alt");
	setprop("/it-autoflight/internal/alt", altinput);
    var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
    var alt = getprop("/it-autoflight/internal/alt");
	var dif = calt - alt;
	if (dif < 550 and dif > -550) {
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
	# FPA not ready yet, so do nothing
  } else if (vertset == 6) {
	setprop("/it-autoflight/output/vert", 6);
	setprop("/it-autoflight/mode/vert", "LAND 3");
	setprop("/it-autoflight/mode/arm", " ");
	thrustmode();
	alandt.stop();
	alandt1.start();
    setprop("/it-autoflight/autoland/target-vs", "-650");
  } else if (vertset == 7) {
	setprop("/it-autoflight/output/vert", 7);
	setprop("/it-autoflight/mode/arm", " ");
	togasel();
	thrustmode();
	alandt.stop();
	alandt1.stop();
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
  setprop("/it-autoflight/internal/min-pitch", -8);
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

# Capture Logic
setlistener("/it-autoflight/output/vert", func {
  var vertm = getprop("/it-autoflight/output/vert");
	if (vertm == 1) {
      altcaptt.start();
    } else if (vertm == 4) {
      altcaptt.start();	
	} else {
	  altcaptt.stop();
    }
});

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
  } else {
	setprop("/it-autoflight/output/thr-mode", 0);
	setprop("/it-autoflight/mode/thr", "THRUST");
	thrustmodet.stop();
  }
}

# Min and Max Pitch Reset
var minmax = func {
  var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
  var alt = getprop("/it-autoflight/internal/alt");
  var dif = calt - alt;
  if (dif < 100 and dif > -100) {
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

# For Canvas Nav Display.
setlistener("/it-autoflight/input/hdg", func {
  setprop("/autopilot/settings/heading-bug-deg", getprop("/it-autoflight/input/hdg"));
});

# TOGA
setlistener("/it-autoflight/input/toga", func {
  if (getprop("/it-autoflight/input/toga") == 1) {
	setprop("/it-autoflight/input/vert", 7);
	setprop("/it-autoflight/output/loc-armed", 0);
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/input/toga", 0);
  }
});

var togasel = func {
  if ((getprop("/gear/gear[1]/wow") == 0) and (getprop("/gear/gear[2]/wow") == 0)) {
    setprop("/it-autoflight/mode/vert", "G/A CLB");
  } else {
	setprop("/it-autoflight/input/lat", 5);
	setprop("/it-autoflight/mode/lat", "T/O");
    setprop("/it-autoflight/mode/vert", "T/O CLB");
  }
}

# LOC and G/S arming
var update_arms = func {
  update_locarmelec();
  update_apparmelec();

  settimer(update_arms, 0.5);
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
  var locdefl = getprop("instrumentation/nav/heading-needle-deflection-norm");
  if ((locdefl < 0.9233) and (getprop("instrumentation/nav/signal-quality-norm") > 0.99)) {
    setprop("/it-autoflight/output/loc-armed", 0);
    setprop("/it-autoflight/output/lat", 2);
	setprop("/it-autoflight/mode/lat", "LOC");
	if (getprop("/it-autoflight/output/appr-armed") == 1) {
	  # Do nothing because G/S is armed
	} else {
	  setprop("/it-autoflight/mode/arm", " ");
	}
  } else {
	return 0;
  }
}

var apparmcheck = func {
  var signal = getprop("/instrumentation/nav/gs-needle-deflection-norm");
  if (signal <= -0.000000001) {
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/output/vert", 2);
	setprop("/it-autoflight/mode/vert", "G/S");
	setprop("/it-autoflight/mode/arm", " ");
	if (getprop("/it-autoflight/settings/land-enable") == 1){
	  alandt.start();
	}
	thrustmode();
  } else {
	return 0;
  }
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

# Timers
var altcaptt = maketimer(0.5, altcapt);
var thrustmodet = maketimer(0.5, thrustmode);
var minmaxtimer = maketimer(0.5, minmax);
var retardt = maketimer(0.5, retardchk);
var atofft = maketimer(0.5, atoffchk);
var alandt = maketimer(0.5, aland);
var alandt1 = maketimer(0.5, aland1);
var cwsrollt = maketimer(0.1, cwsroll);
var cwspitcht = maketimer(0.1, cwspitch);
