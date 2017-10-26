# 737-800 Autoflight
# (c) Joshua Davidson (it0uchpods)

var buttonN1 = func {
	if (getprop("/it-autoflight/output/athr") == 1 and getprop("/it-autoflight/output/thr-mode") != 0) {
		setprop("/it-autoflight/input/athr", 0);
	} else {
		if (getprop("/it-autoflight/custom/athr-armed") == 1) {
			if (getprop("/it-autoflight/input/vert") == 9 or (getprop("/it-autoflight/input/vert") != 4 and getprop("/it-autoflight/input/vert") != 7)) {
				setprop("/it-autoflight/input/vert", 10);
				vertical();
			}
			setprop("/it-autoflight/input/athr", 1);
		}
	}
}

var buttonSPD = func {
	if (getprop("/it-autoflight/output/athr") == 1 and getprop("/it-autoflight/output/thr-mode") == 0) {
		setprop("/it-autoflight/input/athr", 0);
	} else {
		if (getprop("/it-autoflight/custom/athr-armed") == 1) {
			if (getprop("/it-autoflight/input/vert") == 10 or getprop("/it-autoflight/input/vert") == 4 or getprop("/it-autoflight/input/vert") == 7) {
				setprop("/it-autoflight/input/vert", 9);
				vertical();
			}
			setprop("/it-autoflight/input/athr", 1);
		}
	}
}

var buttonHDG = func {
	if (getprop("/it-autoflight/output/lat") == 0) {
		setprop("/it-autoflight/input/lat", 9);
	} else {
		setprop("/it-autoflight/input/lat", 0);
	}
}

var buttonLNAV = func {
	if (getprop("/it-autoflight/input/lat-arm") == 1) {
		setprop("/it-autoflight/input/lat", 0);
	} else {
		if (getprop("/it-autoflight/output/lat") == 1) {
			setprop("/it-autoflight/input/lat", 9);
		} else {
			setprop("/it-autoflight/input/lat", 1);
		}
	}
}

var buttonVORLOC = func {
	if (getprop("/it-autoflight/output/loc-armed") == 1) {
		if (getprop("/it-autoflight/output/lat") == 0) {
			setprop("/it-autoflight/input/lat", 0);
		} else if (getprop("/it-autoflight/output/lat") == 1) {
			setprop("/it-autoflight/input/lat", 1);
		} else if (getprop("/it-autoflight/output/lat") == 5) {
			setprop("/it-autoflight/input/lat", 5);
			setprop("/it-autoflight/output/loc-armed", 0);
		} else if (getprop("/it-autoflight/output/lat") == 4 or getprop("/it-autoflight/output/lat") == 9) {
			setprop("/it-autoflight/input/lat", 9);
		}
	} else {
		if (getprop("/it-autoflight/output/lat") == 2 and getprop("/it-autoflight/output/vert") != 2 and getprop("/it-autoflight/output/vert") != 6) {
			setprop("/it-autoflight/input/lat", 9);
		} else {
			setprop("/it-autoflight/input/lat", 2);
		}
	}
}

var buttonALT = func {
	if (getprop("/it-autoflight/output/vert") == 0) {
		setprop("/it-autoflight/input/vert", 9);
	} else {
		setprop("/it-autoflight/input/vert", 0);
	}
}

var buttonVS = func {
	if (getprop("/it-autoflight/output/vert") == 1) {
		setprop("/it-autoflight/input/vert", 9);
	} else {
		setprop("/it-autoflight/input/vert", 1);
	}
}

var buttonLVLCH = func {
	if (getprop("/it-autoflight/output/vert") == 4) {
		setprop("/it-autoflight/input/vert", 10);
	} else {
		setprop("/it-autoflight/input/vert", 4);
	}
}

var buttonAPPR = func {
	if (getprop("/it-autoflight/output/appr-armed") == 1) {
		if (getprop("/it-autoflight/output/vert") == 9) {
			setprop("/it-autoflight/input/vert", 9);
		} else if (getprop("/it-autoflight/output/vert") == 10) {
			setprop("/it-autoflight/input/vert", 10);
		}
		buttonVORLOC();
		setprop("/it-autoflight/output/loc-armed", 0);
		setprop("/it-autoflight/output/appr-armed", 0);
		setprop("/it-autoflight/mode/arm", " ");
	} else {
		if (getprop("/it-autoflight/output/vert") == 2 or getprop("/it-autoflight/output/vert") == 6) {
			setprop("/it-autoflight/input/vert", 9);
		} else {
			setprop("/it-autoflight/input/vert", 2);
		}
	}
}
