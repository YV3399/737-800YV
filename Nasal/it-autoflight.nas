# IT AUTOFLIGHT System Controller by Joshua Davidson (it0uchpods/411).
# V3.0.0 Milestone 2 Build 54H

print("IT-AUTOFLIGHT: Please Wait!");
setprop("/it-autoflight/settings/retard-enable", 1);  # Do not change this here! See IT-AUTOFLIGHT's Help.txt
setprop("/it-autoflight/settings/retard-ft", 50);     # Do not change this here! See IT-AUTOFLIGHT's Help.txt
setprop("/it-autoflight/settings/land-flap", 0.6);    # Do not change this here! See IT-AUTOFLIGHT's Help.txt
setprop("/it-autoflight/settings/land-enable", 1);    # Do not change this here! See IT-AUTOFLIGHT's Help.txt

var ap_init = func {
	setprop("/it-autoflight/ap_master", 0);
	setprop("/it-autoflight/ap_master2", 0);
	setprop("/it-autoflight/at_master", 0);
	setprop("/it-autoflight/fd_master", 0);
	setprop("/it-autoflight/fd_master2", 0);
	setprop("/it-autoflight/loc-armed", 0);
	setprop("/it-autoflight/appr-armed", 0);
	setprop("/it-autoflight/autothrarm", 0);
	setprop("/it-autoflight/apthrmode", 0);
	setprop("/it-autoflight/apthrmode2", 0);
	setprop("/it-autoflight/settings/target-speed-kt", 200);
	setprop("/it-autoflight/settings/target-mach", 0.68);
	setprop("/it-autoflight/settings/heading-bug-deg", 360);
	setprop("/it-autoflight/settings/target-altitude-ft", 10000);
	setprop("/it-autoflight/settings/target-altitude-ft-actual", 10000);
	setprop("/it-autoflight/settings/vertical-speed-fpm", 0);
	setprop("/it-autoflight/settings/bank-limit", 30);
	setprop("/it-autoflight/settings/min-pitch", -4);
	setprop("/it-autoflight/settings/max-pitch", 8);
	setprop("/it-autoflight/internal/min-pitch", -4);
	setprop("/it-autoflight/internal/max-pitch", 8);
	setprop("/it-autoflight/settings/vertical-speed-fpm", 0);
	setprop("/it-autoflight/aplatset", 0);
	setprop("/it-autoflight/apvertset", 4);
	setprop("/it-autoflight/retard", 0);
    setprop("/it-autoflight/autoland/target-vs", "-500");
	setprop("/it-autoflight/settings/use-true-hdg-error", 0);
	update_arms();
	print("IT-AUTOFLIGHT: Done!");
}

# AP 1 Master System
setlistener("/it-autoflight/ap_mastersw", func {
  var apmas = getprop("/it-autoflight/ap_mastersw");
  if (apmas == 0) {
	setprop("/it-autoflight/ap_master", 0);
	if (getprop("/it-autoflight/enableapoffsound") == 1) {
	  setprop("/it-autoflight/apoffsound", 1);	
	  setprop("/it-autoflight/enableapoffsound", 0);	  
	}
  } else if (apmas == 1) {
	setprop("/it-autoflight/ap_master", 1);
	setprop("/it-autoflight/enableapoffsound", 1);
	setprop("/it-autoflight/apoffsound", 0);
	setprop("/controls/flight/rudder", 0);
  }
});

# AP 2 Master System
setlistener("/it-autoflight/ap_mastersw2", func {
  var apmas = getprop("/it-autoflight/ap_mastersw2");
  if (apmas == 0) {
	setprop("/it-autoflight/ap_master2", 0);
	if (getprop("/it-autoflight/enableapoffsound2") == 1) {
	  setprop("/it-autoflight/apoffsound2", 1);	
	  setprop("/it-autoflight/enableapoffsound", 0);	  
	}
  } else if (apmas == 1) {
	setprop("/it-autoflight/ap_master2", 1);
	setprop("/it-autoflight/enableapoffsound2", 1);
	setprop("/it-autoflight/apoffsound2", 0);
	setprop("/controls/flight/rudder", 0);
  }
});

# AT Master System
setlistener("/it-autoflight/at_mastersw", func {
  var atmas = getprop("/it-autoflight/at_mastersw");
  if (atmas == 0) {
	setprop("/it-autoflight/at_master", 0);
  } else if (atmas == 1) {
	setprop("/it-autoflight/at_master", 1);
  }
});

# Flight Director 1 Master System
setlistener("/it-autoflight/fd_mastersw", func {
  var fdmas = getprop("/it-autoflight/fd_mastersw");
  if (fdmas == 0) {
	setprop("/it-autoflight/fd_master", 0);
  } else if (fdmas == 1) {
	setprop("/it-autoflight/fd_master", 1);
  }
});

# Flight Director 2 Master System
setlistener("/it-autoflight/fd_mastersw2", func {
  var fdmas = getprop("/it-autoflight/fd_mastersw2");
  if (fdmas == 0) {
	setprop("/it-autoflight/fd_master2", 0);
  } else if (fdmas == 1) {
	setprop("/it-autoflight/fd_master2", 1);
  }
});

# Master Lateral
setlistener("/it-autoflight/aplatset", func {
  var latset = getprop("/it-autoflight/aplatset");
  if (latset == 0) {
	setprop("/it-autoflight/loc-armed", 0);
	setprop("/it-autoflight/appr-armed", 0);
	setprop("/it-autoflight/aplatmode", 0);
	setprop("/it-autoflight/txtlatmode", "HDG");
	setprop("/it-autoflight/txtarmmode", " ");
  } else if (latset == 1) {
	setprop("/it-autoflight/loc-armed", 0);
	setprop("/it-autoflight/appr-armed", 0);
	setprop("/it-autoflight/aplatmode", 1);
	setprop("/it-autoflight/txtlatmode", "LNAV");
	setprop("/it-autoflight/txtarmmode", " ");
  } else if (latset == 2) {
	setprop("/instrumentation/nav/signal-quality-norm", 0);
	setprop("/it-autoflight/loc-armed", 1);
	setprop("/it-autoflight/appr-armed", 0);
	setprop("/it-autoflight/txtarmmode", "LOC");
  } else if (latset == 3) {
	setprop("/it-autoflight/loc-armed", 0);
	setprop("/it-autoflight/appr-armed", 0);
	setprop("/it-autoflight/aplatmode", 0);
	setprop("/it-autoflight/txtlatmode", "HDG");
	setprop("/it-autoflight/txtarmmode", " ");
    var hdgnow = int(getprop("/orientation/heading-magnetic-deg")+0.5);
	setprop("/it-autoflight/settings/heading-bug-deg", hdgnow);
  } else if (latset == 4) {
	setprop("/it-autoflight/aplatmode", 4);
	setprop("/it-autoflight/txtlatmode", "LAND");
  }
});

# Master Vertical
setlistener("/it-autoflight/apvertset", func {
  var vertset = getprop("/it-autoflight/apvertset");
  if (vertset == 0) {
	setprop("/it-autoflight/appr-armed", 0);
	setprop("/it-autoflight/apvertmode", 0);
	setprop("/it-autoflight/txtvertmode", "ALT HLD");
	if (getprop("/it-autoflight/loc-armed")) {
	  setprop("/it-autoflight/txtarmmode", "LOC");
	} else {
	  setprop("/it-autoflight/txtarmmode", " ");
	}
    var altnow = int((getprop("/instrumentation/altimeter/indicated-altitude-ft")+50)/100)*100;
	setprop("/it-autoflight/settings/target-altitude-ft", altnow);
	setprop("/it-autoflight/settings/target-altitude-ft-actual", altnow);
	flchthrust();
  } else if (vertset == 1) {
    var altinput = getprop("/it-autoflight/settings/target-altitude-ft");
	setprop("/it-autoflight/settings/target-altitude-ft-actual", altinput);
	var vsnow = int(getprop("/velocities/vertical-speed-fps")*0.6)*100;
	setprop("/it-autoflight/settings/vertical-speed-fpm", vsnow);
	setprop("/it-autoflight/appr-armed", 0);
	setprop("/it-autoflight/apvertmode", 1);
	setprop("/it-autoflight/txtvertmode", "V/S");
	if (getprop("/it-autoflight/loc-armed")) {
	  setprop("/it-autoflight/txtarmmode", "LOC");
	} else {
	  setprop("/it-autoflight/txtarmmode", " ");
	}
	flchthrust();
  } else if (vertset == 2) {
	setprop("/instrumentation/nav/signal-quality-norm", 0);
	setprop("/it-autoflight/loc-armed", 1);
	setprop("/instrumentation/nav/gs-rate-of-climb", 0);
	setprop("/it-autoflight/appr-armed", 1);
	setprop("/it-autoflight/txtarmmode", "ILS");
  } else if (vertset == 3) {
	var pitchdeg = getprop("/orientation/pitch-deg");
	var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var alt = getprop("/it-autoflight/settings/target-altitude-ft-actual");
	var dif = calt - alt;
    if (calt < alt) {
      setprop("/it-autoflight/internal/max-pitch", pitchdeg);
    } else if (calt > alt) {
      setprop("/it-autoflight/internal/min-pitch", pitchdeg);
    }
	minmaxtimer.start();
	setprop("/it-autoflight/apvertmode", 0);
	setprop("/it-autoflight/txtvertmode", "ALT CAP");
  } else if (vertset == 4) {
	var altinput = getprop("/it-autoflight/settings/target-altitude-ft");
	setprop("/it-autoflight/settings/target-altitude-ft-actual", altinput);
    var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
    var alt = getprop("/it-autoflight/settings/target-altitude-ft-actual");
	var dif = calt - alt;
	if (dif < 550 and dif > -550) {
	  alt_on();
    } else {
	  flch_on();
	}
	if (getprop("/it-autoflight/loc-armed")) {
	  setprop("/it-autoflight/txtarmmode", "LOC");
	} else {
	  setprop("/it-autoflight/txtarmmode", " ");
	}
  } else if (vertset == 5) {
	# VNAV not ready yet, so do nothing
  } else if (vertset == 6) {
	setprop("/it-autoflight/apvertmode", 6);
	setprop("/it-autoflight/txtvertmode", "LAND");
	setprop("/it-autoflight/txtarmmode", " ");
	flchthrust();
	alandt.stop();
	alandt1.start();
    setprop("/it-autoflight/autoland/target-vs", "-500");
  }
});

var flch_on = func {
  setprop("/it-autoflight/appr-armed", 0);
  setprop("/it-autoflight/apvertmode", 4);
  flchtimer.start();
}
var alt_on = func {
  setprop("/it-autoflight/appr-armed", 0);
  setprop("/it-autoflight/apvertmode", 0);
  setprop("/it-autoflight/txtvertmode", "ALT CAP");
  setprop("/it-autoflight/internal/max-pitch", 8);
  setprop("/it-autoflight/internal/min-pitch", -4);
}

setlistener("/it-autoflight/apthrmode", func {
	var modez = getprop("it-autoflight/apthrmode");
	if (modez == 0) {
		var iasnow = int(getprop("/instrumentation/airspeed-indicator/indicated-speed-kt")+0.5);
		setprop("/it-autoflight/settings/target-speed-kt", iasnow);
	} else if (modez == 1) {
		var machnow = (int(1000*getprop("/velocities/mach")))*0.001;
		setprop("/it-autoflight/settings/target-mach", machnow);
	}
});

# Capture Logic
setlistener("/it-autoflight/apvertmode", func {
  var vertm = getprop("/it-autoflight/apvertmode");
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
  var alt = getprop("/it-autoflight/settings/target-altitude-ft-actual");
  var dif = calt - alt;
  if (dif < 500 and dif > -500) {
    setprop("/it-autoflight/apvertset", 3);
    setprop("/it-autoflight/apthrmode2", 0);
  }
  var altinput = getprop("/it-autoflight/settings/target-altitude-ft");
  setprop("/it-autoflight/settings/target-altitude-ft-actual", altinput);
}

# FLCH Thrust Mode Selector
var flchthrust = func {
  var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
  var alt = getprop("/it-autoflight/settings/target-altitude-ft-actual");
  var vertm = getprop("/it-autoflight/apvertmode");
  if (vertm == 4) {
    if (calt < alt) {
	  setprop("/it-autoflight/apthrmode2", 2);
	  setprop("/it-autoflight/txtthrmode", "PITCH");
	    setprop("/it-autoflight/txtvertmode", "CLB THR");
    } else if (calt > alt) {
      setprop("/it-autoflight/apthrmode2", 1);
	  setprop("/it-autoflight/txtthrmode", "PITCH");
	    setprop("/it-autoflight/txtvertmode", "IDLE DES");
    } else {
	  setprop("/it-autoflight/apthrmode2", 0);
	  setprop("/it-autoflight/txtthrmode", "THRUST");
	  setprop("/it-autoflight/apvertset", 3);
	}
  } else {
	setprop("/it-autoflight/apthrmode2", 0);
	  setprop("/it-autoflight/txtthrmode", "THRUST");
	flchtimer.stop();
  }
}

# Min and Max Pitch Reset
var minmax = func {
  var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
  var alt = getprop("/it-autoflight/settings/target-altitude-ft-actual");
  var dif = calt - alt;
  if (dif < 100 and dif > -100) {
      setprop("/it-autoflight/internal/max-pitch", 8);
      setprop("/it-autoflight/internal/min-pitch", -4);
	  var vertmode = getprop("/it-autoflight/apvertmode");
	  if (vertmode == 1 or vertmode == 2 or vertmode == 4) {
	    # Do not change the vertical mode because we are not trying to capture altitude.
	  } else {
	    setprop("/it-autoflight/txtvertmode", "ALT HLD");
	  }
	  minmaxtimer.stop();
  }
}

# Autothrottle arm
setlistener("/it-autoflight/autothrarm", func {
  var atarm = getprop("/it-autoflight/autothrarm");
  if (atarm == 0) {
	atarmt.stop();
  } else if (atarm == 1) {
	atarmt.start();
  }
});

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

var atarmchk = func {
  var altpos = getprop("/position/altitude-agl-ft");
  if (altpos >= 50) {
	setprop("/it-autoflight/at_mastersw", 1);
	setprop("/it-autoflight/autothrarm", 0);
  }
}

var retardchk = func {
  if (getprop("/it-autoflight/settings/retard-enable") == 1) {
    var altpos = getprop("/position/gear-agl-ft");
    var retardalt = getprop("/it-autoflight/settings/retard-ft");
    var aton = getprop("/it-autoflight/at_master");
    if (altpos < retardalt) {
	  if (aton == 1) {
	    setprop("/it-autoflight/retard", 1);
	      setprop("/it-autoflight/txtthrmode", "RETARD");
		atofft.start();
	  } else {
	    setprop("/it-autoflight/retard", 0);
		flchthrust();
	  }
    }
  }
}

var atoffchk = func{
  var gear1 = getprop("/gear/gear[1]/wow");
  var gear2 = getprop("/gear/gear[2]/wow");
  if (gear1 == 1 or gear2 == 1) {
	setprop("/it-autoflight/at_mastersw", 0);
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
setlistener("/it-autoflight/settings/heading-bug-deg", func {
  setprop("/autopilot/settings/heading-bug-deg", getprop("/it-autoflight/settings/heading-bug-deg"));
});

# LOC and G/S arming
var update_arms = func {
  update_locarmelec();
  update_apparmelec();

  settimer(update_arms, 0.5);
}

var update_locarmelec = func {
  var loca = getprop("/it-autoflight/loc-armed");
  if (loca) {
    locarmcheck();
  } else {
    return 0;
  }
}

var update_apparmelec = func {
  var appra = getprop("/it-autoflight/appr-armed");
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
    setprop("/it-autoflight/loc-armed", 0);
    setprop("/it-autoflight/aplatmode", 2);
	setprop("/it-autoflight/txtlatmode", "LOC");
	if (getprop("/it-autoflight/appr-armed") == 1) {
	  # Do nothing because G/S is armed
	} else {
	  setprop("/it-autoflight/txtarmmode", " ");
	}
  } else {
	return 0;
  }
}

var apparmcheck = func {
  var signal = getprop("/instrumentation/nav/gs-needle-deflection-norm");
  if (signal <= -0.000000001) {
	setprop("/it-autoflight/appr-armed", 0);
	setprop("/it-autoflight/apvertmode", 2);
	setprop("/it-autoflight/txtvertmode", "G/S");
	setprop("/it-autoflight/txtarmmode", " ");
	flchthrust();
  } else {
	return 0;
  }
}

# Autoland Stage 1 Logic (Land)
var aland = func {
  if (getprop("/position/gear-agl-ft") <= 150) {
    setprop("/it-autoflight/apvertset", 6);
  }
}
var aland1 = func {
  var aglal = getprop("/position/gear-agl-ft");
  if (aglal <= 20 and aglal > 5) {
	setprop("/it-autoflight/txtvertmode", "FLARE");
    setprop("/it-autoflight/autoland/target-vs", "-200");
  }
  var gear1 = getprop("/gear/gear[1]/wow");
  var gear2 = getprop("/gear/gear[2]/wow");
  if (gear1 == 1 or gear2 == 1) {
    setprop("/it-autoflight/ap_mastersw", 0);
    setprop("/it-autoflight/ap_mastersw2", 0);
	alandt1.stop();
  }
}

# Autoland Stage 2 Logic (Rollout)
# Coming soon, for now we just disconnect the AP on touch down.

# Timers
var altcaptt = maketimer(0.5, altcapt);
var flchtimer = maketimer(0.5, flchthrust);
var minmaxtimer = maketimer(0.5, minmax);
var atarmt = maketimer(0.5, atarmchk);
var retardt = maketimer(0.5, retardchk);
var atofft = maketimer(0.5, atoffchk);
var alandt = maketimer(0.5, aland);
var alandt1 = maketimer(0.5, aland1);