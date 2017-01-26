# This file converts the IT-AUTOFLIGHT Mode numbers, and converts them into text strings needed for the Canvas PFD. 
# I have also modified the PFD, so that this works correctly. I will update this file as I update IT-AUTOFLIGHT, if needed.
# Joshua Davidson (it0uchpods/411)

# Speed or Mach?
var speedmach = func {
  if (getprop("/it-autoflight/output/vert") == 4) {
    # Do nothing because it's in FLCH mode.
  } else {
    if (getprop("/it-autoflight/input/kts-mach") == 0) {
      setprop("/autopilot/display/throttle-mode", "SPEED");
    } else if (getprop("/it-autoflight/input/kts-mach") == 1) {
      setprop("/autopilot/display/throttle-mode", "MACH");
    }
  }
}

# Update Speed or Mach
setlistener("/it-autoflight/input/kts-mach", func {
  speedmach();
});

# Master Thrust
setlistener("/it-autoflight/output/thr-mode", func {
  var latset = getprop("/it-autoflight/output/thr-mode");
  if (latset == 0) {
	speedmach();
  } else if (latset == 1) {
	setprop("/autopilot/display/throttle-mode", "IDLE");
  } else if (latset == 2) {
	setprop("/autopilot/display/throttle-mode", "THR CLB");
  }
});

# Master Lateral
setlistener("/it-autoflight/mode/lat", func {
  var lat = getprop("/it-autoflight/mode/lat");
  if (lat == "HDG") {
	setprop("/autopilot/display/roll-mode", "HDG");
  } else if (lat == "LNAV") {
	setprop("/autopilot/display/roll-mode", "LNAV");
  } else if (lat == "LOC") {
	setprop("/autopilot/display/roll-mode", "LOC");
  } else if (lat == "ALGN") {
	setprop("/autopilot/display/roll-mode", "ALIGN");
  } else if (lat == "T/O") {
	setprop("/autopilot/display/roll-mode", "T/O");
  }
});

# Master Vertical
setlistener("/it-autoflight/mode/vert", func {
  var vert = getprop("/it-autoflight/mode/vert");
  if (vert == "ALT HLD") {
	setprop("/autopilot/display/pitch-mode", "ALT HLD");
  } else if (vert == "ALT CAP") {
	setprop("/autopilot/display/pitch-mode", "ALT CAP");
  } else if (vert == "V/S") {
	setprop("/autopilot/display/pitch-mode", "V/S");
  } else if (vert == "G/S") {
	setprop("/autopilot/display/pitch-mode", "G/S");
  } else if (vert == "SPD CLB") {
	setprop("/autopilot/display/pitch-mode", "MCP SPD");
  } else if (vert == "SPD DES") {
	setprop("/autopilot/display/pitch-mode", "MCP SPD");
  } else if (vert == "FPA") {
	setprop("/autopilot/display/pitch-mode", "FPA");
  } else if (vert == "LAND 3") {
	setprop("/autopilot/display/pitch-mode", "LAND 3");
    setprop("/autopilot/display/pitch-mode-armed", "FLARE");
  } else if (vert == "FLARE") {
	setprop("/autopilot/display/pitch-mode", "FLARE");
    setprop("/autopilot/display/pitch-mode-armed", " ");
  } else if (vert == "T/O CLB") {
	setprop("/autopilot/display/pitch-mode", "T/O");
    setprop("/autopilot/display/pitch-mode-armed", " ");
  } else if (vert == "G/A CLB") {
	setprop("/autopilot/display/pitch-mode", "G/A");
    setprop("/autopilot/display/pitch-mode-armed", " ");
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

# AP or FD
var apfd = func {
  var ap1 = getprop("/it-autoflight/output/ap1");
  var ap2 = getprop("/it-autoflight/output/ap2");
  var cws = getprop("/it-autoflight/output/cws");
  var fd1 = getprop("/it-autoflight/output/fd1");
  var fd2 = getprop("/it-autoflight/output/fd2");
  if (ap1 or ap2) {
    setprop("/autopilot/display/afds-mode[0]", "CMD");
  } else if (cws) {
    setprop("/autopilot/display/afds-mode[0]", "CWS");
  } else if (fd1 or fd2) {
    setprop("/autopilot/display/afds-mode[0]", "FD");
  } else {
    setprop("/autopilot/display/afds-mode[0]", " ");
  }
}

# Update AP or FD
setlistener("/it-autoflight/output/ap1", func {
  apfd();
});
setlistener("/it-autoflight/output/ap2", func {
  apfd();
});
setlistener("/it-autoflight/output/cws", func {
  apfd();
});
setlistener("/it-autoflight/output/fd1", func {
  apfd();
});
setlistener("/it-autoflight/output/fd2", func {
  apfd();
});

