# 737-800 FADEC by Joshua Davidson (it0uchpods)

setprop("/systems/thrust/n1/toga-lim", 0.0);
setprop("/systems/thrust/n1/clb-lim", 0.0);
setprop("/controls/engines/n1-limit", 0.0);

setlistener("/sim/signals/fdm-initialized", func {
	fadecLoopT.start();
});

var fadecLoop = func {
	var n1toga = getprop("/systems/thrust/n1/toga-lim");
	var n1clb = getprop("/systems/thrust/n1/clb-lim");
	if (getprop("/it-autoflight/output/vert") == 7) {
		setprop("/controls/engines/n1-limit", n1toga);
	} else {
		setprop("/controls/engines/n1-limit", n1clb);
	}
}

# Timers
var fadecLoopT = maketimer(0.5, fadecLoop);