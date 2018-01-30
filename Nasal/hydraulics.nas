# 737-800 Hydraulic System
# Joshua Davidson (it0uchpods)

#############
# Init Vars #
#############

setlistener("/sim/signals/fdm-initialized", func {
	var a_eng1_pump_sw = getprop("/controls/hydraulic/a-eng1-pump");
	var a_elec2_pump_sw = getprop("/controls/hydraulic/a-elec2-pump");
	var b_elec1_pump_sw = getprop("/controls/hydraulic/b-elec1-pump");
	var b_eng2_pump_sw = getprop("/controls/hydraulic/b-eng2-pump");
	var a_b_cross_pump_sw = getprop("/controls/hydraulic/a-b-cross-pump");
	var stby_pump_sw = getprop("/controls/hydraulic/stby-pump");
	var fctl_a_sw = getprop("/controls/hydraulic/fctl-a");
	var fctl_b_sw = getprop("/controls/hydraulic/fctl-b");
	var spoiler_a_sw = getprop("/controls/hydraulic/spoiler-a");
	var spoiler_b_sw = getprop("/controls/hydraulic/spoiler-b");
	var a_psi = getprop("/systems/hydraulic/a-psi");
	var b_psi = getprop("/systems/hydraulic/b-psi");
	var stby_psi = getprop("/systems/hydraulic/stby-psi");
	var acL = getprop("/systems/electrical/bus/acL");
	var acR = getprop("/systems/electrical/bus/acR");
	var n2_1 = getprop("/engines/engine[0]/n2");
	var n2_2 = getprop("/engines/engine[1]/n2");
	
	var gearlvr = getprop("/b737/controls/gear/lever");
});

var hyd_init = func {
	setprop("/b737/controls/gear/lever", 0);
	setprop("/controls/hydraulic/a-eng1-pump", 1);
	setprop("/controls/hydraulic/a-elec2-pump", 1);
	setprop("/controls/hydraulic/b-elec1-pump", 1);
	setprop("/controls/hydraulic/b-eng2-pump", 1);
	setprop("/controls/hydraulic/a-b-cross-pump", 0);
	setprop("/controls/hydraulic/stby-pump", 0);
	setprop("/controls/hydraulic/fctl-a", 1);
	setprop("/controls/hydraulic/fctl-b", 1);
	setprop("/controls/hydraulic/spoiler-a", 1);
	setprop("/controls/hydraulic/spoiler-b", 1);
	setprop("/controls/hydraulic/fctl-a-cover", 0);
	setprop("/controls/hydraulic/fctl-b-cover", 0);
	setprop("/controls/hydraulic/spoiler-a-cover", 0);
	setprop("/controls/hydraulic/spoiler-b-cover", 0);
	setprop("/systems/hydraulic/a-psi", 0);
	setprop("/systems/hydraulic/b-psi", 0);
	setprop("/systems/hydraulic/stby-psi", 0);
	setprop("/systems/hydraulic/ail-active", 0);
	setprop("/systems/hydraulic/elev-active", 0);
	setprop("/systems/hydraulic/rudder-active", 0);
	setprop("/systems/hydraulic/spoiler-a-active", 0);
	setprop("/systems/hydraulic/spoiler-b-active", 0);
	setprop("/controls/gear/brake-parking", 0);
	hyd_timer.start();
}

#######################
# Main Hydraulic Loop #
#######################

var master_hyd = func {
	a_eng1_pump_sw = getprop("/controls/hydraulic/a-eng1-pump");
	a_elec2_pump_sw = getprop("/controls/hydraulic/a-elec2-pump");
	b_elec1_pump_sw = getprop("/controls/hydraulic/b-elec1-pump");
	b_eng2_pump_sw = getprop("/controls/hydraulic/b-eng2-pump");
	a_b_cross_pump_sw = getprop("/controls/hydraulic/a-b-cross-pump");
	stby_pump_sw = getprop("/controls/hydraulic/stby-pump");
	a_psi = getprop("/systems/hydraulic/a-psi");
	b_psi = getprop("/systems/hydraulic/b-psi");
	stby_psi = getprop("/systems/hydraulic/stby-psi");
	acL = getprop("/systems/electrical/bus/acL");
	acR = getprop("/systems/electrical/bus/acR");
	n2_1 = getprop("/engines/engine[0]/n2");
	n2_2 = getprop("/engines/engine[1]/n2");
	
	if ((a_eng1_pump_sw or a_elec2_pump_sw) and (n2_1 >= 47 or n2_2 >= 47)) {
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
	
	if ((b_elec1_pump_sw or b_eng2_pump_sw) and (acL >= 110 or acR >= 110)) {
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
	
	a_psi = getprop("/systems/hydraulic/a-psi");
	b_psi = getprop("/systems/hydraulic/b-psi");
	stby_psi = getprop("/systems/hydraulic/stby-psi");
	fctl_a_sw = getprop("/controls/hydraulic/fctl-a");
	fctl_b_sw = getprop("/controls/hydraulic/fctl-b");
	spoiler_a_sw = getprop("/controls/hydraulic/spoiler-a");
	spoiler_b_sw = getprop("/controls/hydraulic/spoiler-b");
	
	if (a_psi >= 1500 and fctl_a_sw) {
		setprop("/systems/hydraulic/ail-active", 1);
		setprop("/systems/hydraulic/elev-active", 1);
	} else if (b_psi >= 1500 and fctl_b_sw) {
		setprop("/systems/hydraulic/ail-active", 1);
		setprop("/systems/hydraulic/elev-active", 1);
	} else {
		setprop("/systems/hydraulic/ail-active", 0);
		setprop("/systems/hydraulic/elev-active", 0);
	}
	
	if (a_psi >= 1500 and spoiler_a_sw) {
		setprop("/systems/hydraulic/spoiler-a-active", 1);
	} else {
		setprop("/systems/hydraulic/spoiler-a-active", 0);
	}
	
	if (b_psi >= 1500 and spoiler_b_sw) {
		setprop("/systems/hydraulic/spoiler-b-active", 1);
	} else {
		setprop("/systems/hydraulic/spoiler-b-active", 0);
	}
	
	if ((a_psi >= 1500 and fctl_a_sw) or (b_psi >= 1500 and fctl_b_sw)) {
		setprop("/systems/hydraulic/rudder-active", 1);
	} else if (stby_psi >= 1500 or !fctl_a_sw) {
		setprop("/systems/hydraulic/rudder-active", 1);
	} else {
		setprop("/systems/hydraulic/rudder-active", 0);
	}
	
	# landing gear
	# Add override trigger later. Remember that only the nose gear will retract on the ground due to the mlg needing to rotate past vertical to extend
}

setlistener("/b737/controls/gear/lever", func {
	gearlvr = getprop("/b737/controls/gear/lever");
	wow = getprop("/gear/gear[1]/wow");
	if (gearlvr == 0 and !wow) {  # in air, put gear down
		setprop("/controls/gear/gear-down", 1);
	} else if (gearlvr == 1 and !wow) { # in air put gear up
		setprop("/controls/gear/gear-down", 0);
	} else if (gearlvr == 1 or gearlvr == 2 and wow) { # on ground inhibit lever movement. 
		setprop("/controls/gear/gear-down", 1);
		setprop("/b737/controls/gear/lever", 0);
	} 
});
###################
# Update Function #
###################

var update_hydraulic = func {
	master_hyd();
}

var hyd_timer = maketimer(0.2, update_hydraulic);
