# IT AUTOFLIGHT System Controller by Joshua Davidson (it0uchpods/411).
# V3.0.0 Milestone 3 Build 78

print("IT-AUTOFLIGHT: Please Wait!");
setprop("/it-autoflight/settings/retard-enable", 1);   # Do not change this here! See IT-AUTOFLIGHT's Help.txt
setprop("/it-autoflight/settings/retard-ft", 50);      # Do not change this here! See IT-AUTOFLIGHT's Help.txt
setprop("/it-autoflight/settings/land-flap", 0.6);     # Do not change this here! See IT-AUTOFLIGHT's Help.txt
setprop("/it-autoflight/settings/land-enable", 1);     # Do not change this here! See IT-AUTOFLIGHT's Help.txt
setprop("/it-autoflight/autoland/flare-altitude", 20); # Do not change this here! See IT-AUTOFLIGHT's Help.txt

var ap_init = func {
	setprop("/it-autoflight/input/kts-mach", 0);
	setprop("/it-autoflight/input/ap1", 0);
	setprop("/it-autoflight/input/ap2", 0);
	setprop("/it-autoflight/input/athr", 0);
	setprop("/it-autoflight/input/fd1", 0);
	setprop("/it-autoflight/input/fd2", 0);
	setprop("/it-autoflight/input/spd-kts", 200);
	setprop("/it-autoflight/input/spd-mach", 0.68);
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
	setprop("/it-autoflight/settings/min-pitch", -4);
	setprop("/it-autoflight/settings/max-pitch", 8);
	setprop("/it-autoflight/internal/min-pitch", -4);
	setprop("/it-autoflight/internal/max-pitch", 8);
	setprop("/it-autoflight/internal/alt", 10000);
    setprop("/it-autoflight/autoland/target-vs", "-500");
	update_arms();
	print("IT-AUTOFLIGHT: Done!");
}

# AP 1 Master System
setlistener("/it-autoflight/input/ap1", func {
  var apmas = getprop("/it-autoflight/input/ap1");
  if (apmas == 0) {
	setprop("/it-autoflight/output/ap1", 0);
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
  var latset = getprop("/it-autoflight/input/lat");
  if (latset == 0) {
	setprop("/it-autoflight/output/loc-armed", 0);
	setprop("/it-autoflight/output/appr-armed", 0);
	setprop("/it-autoflight/output/lat", 0);
	setprop("/it-autoflight/mode/lat", "HDG");
	setprop("/it-autoflight/mode/arm", " ");
  } else if (latset == 1) {
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
  }
});

# Master Vertical
setlistener("/it-autoflight/input/vert", func {
  var vertset = getprop("/it-autoflight/input/vert");
  if (vertset == 0) {
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
	flchthrust();
  } else if (vertset == 1) {
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
	flchthrust();
  } else if (vertset == 2) {
	setprop("/instrumentation/nav/signal-quality-norm", 0);
	setprop("/it-autoflight/output/loc-armed", 1);
	setprop("/instrumentation/nav/gs-rate-of-climb", 0);
	setprop("/it-autoflight/output/appr-armed", 1);
	setprop("/it-autoflight/mode/arm", "ILS");
  } else if (vertset == 3) {
	var pitchdeg = getprop("/orientation/pitch-deg");
	var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var alt = getprop("/it-autoflight/internal/alt");
	var dif = calt - alt;
    if (calt < alt) {
      setprop("/it-autoflight/internal/max-pitch", pitchdeg);
    } else if (calt > alt) {
      setprop("/it-autoflight/internal/min-pitch", pitchdeg);
    }
	minmaxtimer.start();
	setprop("/it-autoflight/output/vert", 0);
	setprop("/it-autoflight/mode/vert", "ALT CAP");
  } else if (vertset == 4) {
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
	# VNAV not ready yet, so do nothing
  } else if (vertset == 6) {
	setprop("/it-autoflight/output/vert", 6);
	setprop("/it-autoflight/mode/vert", "LAND 3");
	setprop("/it-autoflight/mode/arm", " ");
	flchthrust();
	alandt.stop();
	alandt1.start();
    setprop("/it-autoflight/autoland/target-vs", "-500");
  }
});

var flch_on = func {
  setprop("/it-autoflight/output/appr-armed", 0);
  setprop("/it-autoflight/output/vert", 4);
  flchtimer.start();
}
var alt_on = func {
  setprop("/it-autoflight/output/appr-armed", 0);
  setprop("/it-autoflight/output/vert", 0);
  setprop("/it-autoflight/mode/vert", "ALT CAP");
  setprop("/it-autoflight/internal/max-pitch", 8);
  setprop("/it-autoflight/internal/min-pitch", -4);
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
  var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
  var alt = getprop("/it-autoflight/internal/alt");
  var dif = calt - alt;
  if (dif < 500 and dif > -500) {
    setprop("/it-autoflight/input/vert", 3);
    setprop("/it-autoflight/output/thr-mode", 0);
  }
  var altinput = getprop("/it-autoflight/input/alt");
  setprop("/it-autoflight/internal/alt", altinput);
}

# FLCH Thrust Mode Selector
var flchthrust = func {
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
  } else {
	setprop("/it-autoflight/output/thr-mode", 0);
	  setprop("/it-autoflight/mode/thr", "THRUST");
	flchtimer.stop();
  }
}

# Min and Max Pitch Reset
var minmax = func {
  var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
  var alt = getprop("/it-autoflight/internal/alt");
  var dif = calt - alt;
  if (dif < 100 and dif > -100) {
      setprop("/it-autoflight/internal/max-pitch", 8);
      setprop("/it-autoflight/internal/min-pitch", -4);
	  var vertmode = getprop("/it-autoflight/output/vert");
	  if (vertmode == 1 or vertmode == 2 or vertmode == 4) {
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
		flchthrust();
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
	if (getprop("/it-autoflight/settings/land-enable") == 1){
	  alandt.start();
	}
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
	flchthrust();
  } else {
	return 0;
  }
}

# Autoland Stage 1 Logic (Land)
var aland = func {
  var ap1 = getprop("/it-autoflight/output/ap1");
  var ap2 = getprop("/it-autoflight/output/ap2");
  if (ap1 or ap2) {
    if (getprop("/position/gear-agl-ft") <= 150) {
      setprop("/it-autoflight/input/vert", 6);
    }
  }
}
var aland1 = func {
  var aglal = getprop("/position/gear-agl-ft");
  var flarealt = getprop("/it-autoflight/autoland/flare-altitude");
  if (aglal <= flarealt and aglal > 5) {
	setprop("/it-autoflight/mode/vert", "FLARE");
    setprop("/it-autoflight/autoland/target-vs", "-120");
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
# Coming soon, for now we just disconnect the AP on touch down.

# Timers
var altcaptt = maketimer(0.5, altcapt);
var flchtimer = maketimer(0.5, flchthrust);
var minmaxtimer = maketimer(0.5, minmax);
var retardt = maketimer(0.5, retardchk);
var atofft = maketimer(0.5, atoffchk);
var alandt = maketimer(0.5, aland);
var alandt1 = maketimer(0.5, aland1);