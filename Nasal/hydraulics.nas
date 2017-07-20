# 737-800 Hydraulic System
# Joshua Davidson (it0uchpods)

#############
# Init Vars #
#############

setlistener("/sim/signals/fdm-initialized", func {
	var a_eng1_pump_sw = getprop("/controls/hydraulic/a-eng1-pump");
	var a_eng2_pump_sw = getprop("/controls/hydraulic/a-eng2-pump");
	var b_elec1_pump_sw = getprop("/controls/hydraulic/b-elec1-pump");
	var b_elec2_pump_sw = getprop("/controls/hydraulic/b-elec2-pump");
	var a_b_cross_pump_sw = getprop("/controls/hydraulic/a-b-cross-pump");
	var stby_pump_sw = getprop("/controls/hydraulic/stby-pump");
	var a_psi = getprop("/systems/hydraulic/a-psi");
	var b_psi = getprop("/systems/hydraulic/b-psi");
	var stby_psi = getprop("/systems/hydraulic/stby-psi");
	var acL = getprop("/systems/electrical/bus/acL");
	var acR = getprop("/systems/electrical/bus/acR");
	var n2_1 = getprop("/engines/engine[0]/n2");
	var n2_2 = getprop("/engines/engine[1]/n2");
});

var hyd_init = func {
	setprop("/controls/hydraulic/a-eng1-pump", 0);
	setprop("/controls/hydraulic/a-eng2-pump", 0);
	setprop("/controls/hydraulic/b-elec1-pump", 0);
	setprop("/controls/hydraulic/b-elec2-pump", 0);
	setprop("/controls/hydraulic/a-b-cross-pump", 0);
	setprop("/controls/hydraulic/stby-pump", 0);
	setprop("/systems/hydraulic/a-psi", 0);
	setprop("/systems/hydraulic/b-psi", 0);
	setprop("/systems/hydraulic/stby-psi", 0);
	setprop("/controls/gear/brake-parking", 0);
	hyd_timer.start();
}

#######################
# Main Hydraulic Loop #
#######################

var master_hyd = func {
	a_eng1_pump_sw = getprop("/controls/hydraulic/a-eng1-pump");
	a_eng2_pump_sw = getprop("/controls/hydraulic/a-eng2-pump");
	b_elec1_pump_sw = getprop("/controls/hydraulic/b-elec1-pump");
	b_elec2_pump_sw = getprop("/controls/hydraulic/b-elec2-pump");
	a_b_cross_pump_sw = getprop("/controls/hydraulic/a-b-cross-pump");
	stby_pump_sw = getprop("/controls/hydraulic/stby-pump");
	a_psi = getprop("/systems/hydraulic/a-psi");
	b_psi = getprop("/systems/hydraulic/b-psi");
	stby_psi = getprop("/systems/hydraulic/stby-psi");
	acL = getprop("/systems/electrical/bus/acL");
	acR = getprop("/systems/electrical/bus/acR");
	n2_1 = getprop("/engines/engine[0]/n2");
	n2_2 = getprop("/engines/engine[1]/n2");
	
	if ((a_eng1_pump_sw or a_eng2_pump_sw) and (n2_1 >= 47 or n2_2 >= 47)) {
		if (a_psi < 2900) {
			setprop("/systems/hydraulic/a-psi", a_psi + 100);
		} else {
			setprop("/systems/hydraulic/a-psi", 3000);
		}
	} else if (a_b_cross_pump_sw and b_psi >= 1500) {
		if (a_psi < 2400) {
			setprop("/systems/hydraulic/a-psi", a_psi + 100);
		} else {
			setprop("/systems/hydraulic/a-psi", 2500);
		}
	} else {
		if (a_psi > 1) {
			setprop("/systems/hydraulic/a-psi", a_psi - 50);
		} else {
			setprop("/systems/hydraulic/a-psi", 0);
		}
	}
	
	if ((b_elec1_pump_sw or b_elec2_pump_sw) and (acL >= 110 or acR >= 110)) {
		if (b_psi < 2900) {
			setprop("/systems/hydraulic/b-psi", b_psi + 100);
		} else {
			setprop("/systems/hydraulic/b-psi", 3000);
		}
	} else {
		if (b_psi > 1) {
			setprop("/systems/hydraulic/b-psi", b_psi - 50);
		} else {
			setprop("/systems/hydraulic/b-psi", 0);
		}
	}
	
	if (stby_pump_sw and (acL >= 110 or acR >= 110)) {
		if (stby_psi < 2400) {
			setprop("/systems/hydraulic/stby-psi", stby_psi + 100);
		} else {
			setprop("/systems/hydraulic/stby-psi", 2500);
		}
	} else {
		if (stby_psi > 1) {
			setprop("/systems/hydraulic/stby-psi", stby_psi - 50);
		} else {
			setprop("/systems/hydraulic/stby-psi", 0);
		}
	}
}

###################
# Update Function #
###################

var update_hydraulic = func {
	master_hyd();
}

var hyd_timer = maketimer(0.2, update_hydraulic);
