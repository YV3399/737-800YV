# 737 Thrust Logic System by Joshua Davidson (it0uchpods/411)

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/controls/engines/n1lim", 0.99);
	setprop("/controls/engines/n1limx100", 99);
	print("Thrust System ... OK!");
});