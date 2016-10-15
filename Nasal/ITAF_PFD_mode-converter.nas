# This file converts the IT-AUTOFLIGHT Mode numbers, and converts them into text strings needed for the Canvas PFD. 
# I have also modified the PFD, so that this works correctly. I will update this file as I update IT-AUTOFLIGHT, if needed.
# I will add the ARM switch and functions later.
# Joshua Davidson (it0uchpods/411)

# Speed or Mach?
var speedmach = func {
  if (getprop("/it-autoflight/apvertmode") == 4) {
    # Do nothing because it's in FLCH mode.
  } else {
    if (getprop("/it-autoflight/apthrmode") == 0) {
      setprop("/autopilot/display/throttle-mode", "SPEED");
    } else if (getprop("/it-autoflight/apthrmode") == 1) {
      setprop("/autopilot/display/throttle-mode", "MACH");
    }
  }
}

# Update Speed or Mach
setlistener("/it-autoflight/apthrmode", func {
  speedmach();
});

# Master Thrust
setlistener("/it-autoflight/apthrmode2", func {
  var latset = getprop("/it-autoflight/apthrmode2");
  if (latset == 0) {
	speedmach();
  } else if (latset == 1) {
	setprop("/autopilot/display/throttle-mode", "IDLE");
  } else if (latset == 2) {
	setprop("/autopilot/display/throttle-mode", "THR CLB");
  }
});

# Master Lateral
setlistener("/it-autoflight/aplatmode", func {
  var latset = getprop("/it-autoflight/aplatmode");
  if (latset == 0) {
	setprop("/autopilot/display/roll-mode", "HDG");
  } else if (latset == 1) {
	setprop("/autopilot/display/roll-mode", "LNAV");
  } else if (latset == 2) {
	setprop("/autopilot/display/roll-mode", "LOC");
  }
});

# Master Vertical
setlistener("/it-autoflight/apvertmode", func {
  var latset = getprop("/it-autoflight/apvertmode");
  if (latset == 0) {
	setprop("/autopilot/display/pitch-mode", "HOLD");
  } else if (latset == 1) {
	setprop("/autopilot/display/pitch-mode", "V/S");
  } else if (latset == 2) {
	setprop("/autopilot/display/pitch-mode", "G/S");
  } else if (latset == 4) {
	setprop("/autopilot/display/pitch-mode", "MCP SPD");
  }
});

# Arm LOC
setlistener("/it-autoflight/loc-armed", func {
  var loc-armed = getprop("/it-autoflight/loc-armed");
  if (loc-armed) {
    setprop("/autopilot/display/roll-mode-armed", "LOC");
  } else {
    setprop("/autopilot/display/roll-mode-armed", " ");
  }
});

# Arm G/S
setlistener("/it-autoflight/appr-armed", func {
  var appr-armed = getprop("/it-autoflight/appr-armed");
  if (appr-armed) {
    setprop("/autopilot/display/pitch-mode-armed", "G/S");
  } else {
    setprop("/autopilot/display/pitch-mode-armed", " ");
  }
});

# AP or FD
var apfd = func {
  var ap1 = getprop("/it-autoflight/ap_master");
  var ap2 = getprop("/it-autoflight/ap_master2");
  var fd1 = getprop("/it-autoflight/fd_master");
  var fd2 = getprop("/it-autoflight/fd_master2");
  if (ap1 or ap2) {
    setprop("/autopilot/display/afds-mode[0]", "AP");
  } else if (fd1 or fd2) {
    setprop("/autopilot/display/afds-mode[0]", "FD");
  } else {
    setprop("/autopilot/display/afds-mode[0]", " ");
  }
}

# Update AP or FD
setlistener("/it-autoflight/ap_master", func {
  apfd();
});
setlistener("/it-autoflight/ap_master2", func {
  apfd();
});
setlistener("/it-autoflight/fd_master", func {
  apfd();
});
setlistener("/it-autoflight/fd_master2", func {
  apfd();
});

