# 737 Thrust Logic System by Joshua Davidson (it0uchpods/411)

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/controls/engines/n1lim", 0.96);
	setprop("/controls/engines/n1limx100", 96);
	thrustlim.start();
});

var thrustlim = maketimer(0.5, func {
	if (getprop("/it-autoflight/output/vert") == 7) {
		setprop("/controls/engines/n1lim", 0.96);
		setprop("/controls/engines/n1limx100", 96);
	} else {
		setprop("/controls/engines/n1lim", 0.89);
		setprop("/controls/engines/n1limx100", 89);
	}
});