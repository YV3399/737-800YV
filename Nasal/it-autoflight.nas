# IT AUTOFLIGHT System Controller by Joshua Davidson (it0uchpods/411).
# V3.0.0 Milestone 1.

print("IT-AUTOFLIGHT: Please Wait!");

var ap_init = func {
	setprop("/it-autoflight/ap_master", 0);
	setprop("/it-autoflight/ap_master2", 0);
	setprop("/it-autoflight/at_master", 0);
	setprop("/it-autoflight/fd_master", 0);
	setprop("/it-autoflight/fd_master2", 0);
	setprop("/it-autoflight/loc1", 0);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/aplatmode", 0);
	setprop("/it-autoflight/aphldtrk", 0);
	setprop("/it-autoflight/apvertmode", 3);
	setprop("/it-autoflight/aphldtrk2", 0);
	setprop("/it-autoflight/thr", 1);
	setprop("/it-autoflight/idle", 0);
	setprop("/it-autoflight/clb", 0);
	setprop("/it-autoflight/autothrarm", 0);
	setprop("/it-autoflight/apthrmode", 0);
	setprop("/it-autoflight/apthrmode2", 0);
	setprop("/it-autoflight/settings/target-speed-kt", 200);
	setprop("/it-autoflight/settings/target-mach", 0.68);
	setprop("/it-autoflight/settings/idlethr", 0);
	setprop("/it-autoflight/settings/clbthr", 900);
	setprop("/it-autoflight/settings/heading-bug-deg", 360);
	setprop("/it-autoflight/settings/target-altitude-ft", 10000);
	setprop("/it-autoflight/settings/target-altitude-ft-actual", 10000);
	setprop("/it-autoflight/settings/vertical-speed-fpm", 0);
	setprop("/it-autoflight/settings/bank-limit", 30);
	setprop("/it-autoflight/min-pitch", -4);
	setprop("/it-autoflight/max-pitch", 8);
	setprop("/it-autoflight/internal/min-pitch", -4);
	setprop("/it-autoflight/internal/max-pitch", 8);
	setprop("/it-autoflight/settings/vertical-speed-fpm", 0);
	setprop("/it-autoflight/aplatset", 0);
	setprop("/it-autoflight/apvertset", 4);
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
	setprop("/it-autoflight/loc1", 0);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/aplatmode", 0);
	setprop("/it-autoflight/aphldtrk", 0);
  } else if (latset == 1) {
	setprop("/it-autoflight/loc1", 0);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/aplatmode", 1);
	setprop("/it-autoflight/aphldtrk", 1);
  } else if (latset == 2) {
	setprop("/instrumentation/nav/signal-quality-norm", 0);
	setprop("/it-autoflight/loc1", 1);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/apilsmode", 0);
  } else if (latset == 3) {
	setprop("/it-autoflight/loc1", 0);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/aplatmode", 0);
	setprop("/it-autoflight/aphldtrk", 0);
    var hdgnow = int(getprop("/orientation/heading-magnetic-deg")+0.5);
	setprop("/it-autoflight/settings/heading-bug-deg", hdgnow);
  }
});

# Master Vertical
setlistener("/it-autoflight/apvertset", func {
  var vertset = getprop("/it-autoflight/apvertset");
  if (vertset == 0) {
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/apvertmode", 0);
	setprop("/it-autoflight/aphldtrk2", 0);
	setprop("/it-autoflight/apilsmode", 0);
    var altnow = int((getprop("/instrumentation/altimeter/indicated-altitude-ft")+50)/100)*100;
	setprop("/it-autoflight/settings/target-altitude-ft", altnow);
	setprop("/it-autoflight/settings/target-altitude-ft-actual", altnow);
	flchthrust();
  } else if (vertset == 1) {
    var altinput = getprop("/it-autoflight/settings/target-altitude-ft");
	setprop("/it-autoflight/settings/target-altitude-ft-actual", altinput);
	var vsnow = int(getprop("/velocities/vertical-speed-fps")*0.6)*100;
	setprop("/it-autoflight/settings/vertical-speed-fpm", vsnow);
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/apvertmode", 1);
	setprop("/it-autoflight/aphldtrk2", 0);
	setprop("/it-autoflight/apilsmode", 0);
	flchthrust();
  } else if (vertset == 2) {
	setprop("/instrumentation/nav/signal-quality-norm", 0);
	setprop("/it-autoflight/loc1", 1);
	setprop("/instrumentation/nav/gs-rate-of-climb", 0);
	setprop("/it-autoflight/app1", 1);
	setprop("/it-autoflight/apilsmode", 1);
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
	setprop("/it-autoflight/aphldtrk2", 0);
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
  }
});
var flch_on = func {
  setprop("/it-autoflight/app1", 0);
  setprop("/it-autoflight/apvertmode", 4);
  setprop("/it-autoflight/aphldtrk2", 2);
  setprop("/it-autoflight/apilsmode", 0);
  flchtimer.start();
}
var alt_on = func {
  setprop("/it-autoflight/app1", 0);
  setprop("/it-autoflight/apvertmode", 0);
  setprop("/it-autoflight/aphldtrk2", 0);
  setprop("/it-autoflight/apilsmode", 0);
  setprop("/it-autoflight/internal/max-pitch", 8);
  setprop("/it-autoflight/internal/min-pitch", -4);
}

setlistener("/it-autoflight/apthrmode", func {
	var thrset = getprop("it-autoflight/apthrmode");
	if (thrset == 0) {
		var iasnow = int(getprop("/instrumentation/airspeed-indicator/indicated-speed-kt")+0.5);
		setprop("/it-autoflight/settings/target-speed-kt", iasnow);
	} else if (thrset == 1) {
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
    } else if (calt > alt) {
      setprop("/it-autoflight/apthrmode2", 1);
    } else {
	  setprop("/it-autoflight/apthrmode2", 0);
	  setprop("/it-autoflight/apvertset", 3);
	}
  } else {
	setprop("/it-autoflight/apthrmode2", 0);
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

var atarmchk = func {
  var altpos = getprop("/position/gear-agl-ft");
  if (altpos >= 10) {
	setprop("/it-autoflight/at_mastersw", 1);
	setprop("/it-autoflight/autothrarm", 0);
  }
}

# Timers
var altcaptt = maketimer(0.5, altcapt);
var flchtimer = maketimer(0.5, flchthrust);
var minmaxtimer = maketimer(0.5, minmax);
var atarmt = maketimer(0.5, atarmchk);

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
  var loc1 = getprop("/it-autoflight/loc1");
  if (loc1) {
  locarmcheck();
  } else {
  return 0;
  }
}

var update_apparmelec = func {
  var app1 = getprop("/it-autoflight/app1");
  if (app1) {
  apparmcheck();
  } else {
  return 0;
  }
}

var locarmcheck = func {
  var locdefl = getprop("instrumentation/nav/heading-needle-deflection-norm");
  if ((locdefl < 0.9233) and (getprop("instrumentation/nav/signal-quality-norm") > 0.99)) {
    setprop("/it-autoflight/loc1", 0);
    setprop("/it-autoflight/aplatmode", 2);
	setprop("/it-autoflight/aphldtrk", 1);
  } else {
	return 0;
  }
}

var apparmcheck = func {
  var signal = getprop("/instrumentation/nav/gs-needle-deflection-norm");
  if (signal <= -0.000000001) {
	setprop("/it-autoflight/app1", 0);
	setprop("/it-autoflight/apvertmode", 2);
	setprop("/it-autoflight/aphldtrk2", 1);
	flchthrust();
  } else {
	return 0;
  }
}