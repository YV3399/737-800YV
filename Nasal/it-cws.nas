# B737-800 CWS System by Joshua Davidson (it0uchpods)
# V0.1.0

#######
# CWS #
#######

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/it-cws/cwsa", 0);
	setprop("/it-cws/cwsb", 0);
	setprop("/it-cws/cwsa-output", 0);
	setprop("/it-cws/cwsb-output", 0);
});

setlistener("/it-autoflight/output/ap1", func {
	if (getprop("/it-autoflight/output/ap1") == 1) {
		setprop("/it-cws/cwsa", 0);
		setprop("/it-cws/cwsb", 0);
	}
});

setlistener("/it-autoflight/output/ap2", func {
	if (getprop("/it-autoflight/output/ap2") == 1) {
		setprop("/it-cws/cwsa", 0);
		setprop("/it-cws/cwsb", 0);
	}
});

setlistener("/it-cws/cwsa", func {
	if (getprop("/gear/gear[0]/wow") == 0 and getprop("/gear/gear[1]/wow") == 0 and getprop("/gear/gear[2]/wow") == 0) {
		if (getprop("/it-cws/cwsa") == 1) {
			setprop("/it-cws/cwsa-output", 1);
			setprop("/it-autoflight/input/ap1", 0);
			setprop("/it-autoflight/input/ap2", 0);
		} else if (getprop("/it-cws/cwsa") == 0) {
			setprop("/it-cws/cwsa-output", 0);
		}
	} else {
		setprop("/it-cws/cwsa", 0);
		setprop("/it-cws/cwsa-output", 0);
	}
});

setlistener("/it-cws/cwsb", func {
	if (getprop("/gear/gear[0]/wow") == 0 or getprop("/gear/gear[1]/wow") == 0 or getprop("/gear/gear[2]/wow") == 0) {
		if (getprop("/it-cws/cwsb") == 1) {
			setprop("/it-cws/cwsb-output", 1);
			setprop("/it-autoflight/input/ap1", 0);
			setprop("/it-autoflight/input/ap2", 0);
		} else if (getprop("/it-cws/cwsb") == 0) {
			setprop("/it-cws/cwsb-output", 0);
		}
	} else {
		setprop("/it-cws/cwsb", 0);
		setprop("/it-cws/cwsb-output", 0);
	}
});

setlistener("/gear/gear[1]/wow", func {
	if (getprop("/gear/gear[1]/wow") == 1) {
		setprop("/it-cws/cwsa", 0);
	}
	if (getprop("/gear/gear[1]/wow") == 1) {
		setprop("/it-cws/cwsb", 0);
	}
});

setlistener("/gear/gear[2]/wow", func {
	if (getprop("/gear/gear[2]/wow") == 1) {
		setprop("/it-cws/cwsa", 0);
	}
	if (getprop("/gear/gear[2]/wow") == 1) {
		setprop("/it-cws/cwsb", 0);
	}
});
