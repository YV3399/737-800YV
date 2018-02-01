# 737-800 Electrical System
# Joshua Davidson (it0uchpods)

#############
# Init Vars #
#############

var ac_volt_std = 115;
var ac_volt_min = 110;
var dc_volt_std = 28;
var dc_volt_min = 25;

setlistener("/sim/signals/fdm-initialized", func {
	var battery_on = getprop("/controls/electric/battery-switch");
	var extpwr_on = getprop("/services/ext-pwr/enable");
	var ext = getprop("/controls/electrical/ext/sw");
	var emerpwr_on = getprop("/controls/electrical/emerpwr");
	var acxtie = getprop("/controls/electrical/xtie/acxtie");
	var dcxtie = getprop("/controls/electrical/xtie/dcxtie");
	var xtieL = getprop("/controls/electrical/xtie/xtieL");
	var xtieR = getprop("/controls/electrical/xtie/xtieR");
	var rpmapu = getprop("/systems/apu/rpm");
	var apuL = getprop("/controls/electrical/apu/Lsw");
	var apuR = getprop("/controls/electrical/apu/Rsw");
	var engL = getprop("/controls/electrical/eng/Lsw");
	var engR = getprop("/controls/electrical/eng/Rsw");
	var rpmL = getprop("/engines/engine[0]/n2");
	var rpmR = getprop("/engines/engine[1]/n2");
	var dcbusL = getprop("/systems/electrical/bus/dcL");
	var dcbusR = getprop("/systems/electrical/bus/dcR");
	var acbusL = getprop("/systems/electrical/bus/acL");
	var acbusR = getprop("/systems/electrical/bus/acR");
	var Lgen = getprop("/systems/electrical/bus/genL");
	var Rgen = getprop("/systems/electrical/bus/genR");
	var galley = getprop("/controls/electrical/galley");
});

var elec_init = func {
	setprop("/controls/electric/battery-switch", 0);   # Set all the stuff I need
	setprop("/controls/electrical/ext/sw", 0);
	setprop("/controls/electrical/emerpwr", 0);
	setprop("/controls/electrical/galley", 0);
	setprop("/controls/electrical/xtie/acxtie", 1);
	setprop("/controls/electrical/xtie/dcxtie", 0);
	setprop("/controls/electrical/xtie/xtieL", 0);
	setprop("/controls/electrical/xtie/xtieR", 0);
	setprop("/controls/electrical/apu/Lsw", 0);
	setprop("/controls/electrical/apu/Rsw", 0);
	setprop("/controls/electrical/eng/Lsw", 0);
	setprop("/controls/electrical/eng/Rsw", 0);
	setprop("/systems/electrical/bus/dcL", 0);
	setprop("/systems/electrical/bus/dcR", 0);
	setprop("/systems/electrical/bus/acL", 0);
	setprop("/systems/electrical/bus/acR", 0);
	setprop("/systems/electrical/bus/genL", 0);
	setprop("/systems/electrical/bus/genR", 0);
    setprop("systems/electrical/outputs/adf", 0);
    setprop("systems/electrical/outputs/audio-panel", 0);
    setprop("systems/electrical/outputs/audio-panel[1]", 0);
    setprop("systems/electrical/outputs/autopilot", 0);
    setprop("systems/electrical/outputs/avionics-fan", 0);
    setprop("systems/electrical/outputs/beacon", 0);
    setprop("systems/electrical/outputs/bus", 0);
    setprop("systems/electrical/outputs/cabin-lights", 0);
    setprop("systems/electrical/outputs/dme", 0);
    setprop("systems/electrical/outputs/efis", 0);
    setprop("systems/electrical/outputs/flaps", 0);
    setprop("systems/electrical/outputs/fuel-pump", 0);
    setprop("systems/electrical/outputs/fuel-pump[1]", 0);
    setprop("systems/electrical/outputs/gps", 0);
    setprop("systems/electrical/outputs/gps-mfd", 0);
    setprop("systems/electrical/outputs/hsi", 0);
    setprop("systems/electrical/outputs/instr-ignition-switch", 0);
    setprop("systems/electrical/outputs/instrument-lights", 0);
    setprop("systems/electrical/outputs/landing-lights", 0);
    setprop("systems/electrical/outputs/map-lights", 0);
    setprop("systems/electrical/outputs/mk-viii", 0);
    setprop("systems/electrical/outputs/nav", 0);
    setprop("systems/electrical/outputs/nav[1]", 0);
    setprop("systems/electrical/outputs/pitot-head", 0);
    setprop("systems/electrical/outputs/stobe-lights", 0);
    setprop("systems/electrical/outputs/tacan", 0);
    setprop("systems/electrical/outputs/taxi-lights", 0);
    setprop("systems/electrical/outputs/transponder", 0);
    setprop("systems/electrical/outputs/turn-coordinator", 0);
	elec_timer.start();
}

######################
# Main Electric Loop #
######################

var master_elec = func {
	battery_on = getprop("/controls/electric/battery-switch");
	extpwr_on = getprop("/services/ext-pwr/enable");
	ext = getprop("/controls/electrical/ext/sw");
	emerpwr_on = getprop("/controls/electrical/emerpwr");
	acxtie = getprop("/controls/electrical/xtie/acxtie");
	dcxtie = getprop("/controls/electrical/xtie/dcxtie");
	xtieL = getprop("/controls/electrical/xtie/xtieL");
	xtieR = getprop("/controls/electrical/xtie/xtieR");
	rpmapu = getprop("/systems/apu/rpm");
	apuL = getprop("/controls/electrical/apu/Lsw");
	apuR = getprop("/controls/electrical/apu/Rsw");
	engL = getprop("/controls/electrical/eng/Lsw");
	engR = getprop("/controls/electrical/eng/Rsw");
	rpmL = getprop("/engines/engine[0]/n2");
	rpmR = getprop("/engines/engine[1]/n2");
	dcbusL = getprop("/systems/electrical/bus/dcL");
	dcbusR = getprop("/systems/electrical/bus/dcR");
	acbusL = getprop("/systems/electrical/bus/acL");
	acbusR = getprop("/systems/electrical/bus/acR");
	Lgen = getprop("/systems/electrical/bus/genL");
	Rgen = getprop("/systems/electrical/bus/genR");
	galley = getprop("/controls/electrical/galley");
	
	# Left cross tie yes?
	if (extpwr_on and ext) {
		setprop("/controls/electrical/xtie/xtieR", 1);
	} else if (rpmapu >= 94.9 and apuL) {
		setprop("/controls/electrical/xtie/xtieR", 1);
	} else if (rpmL >= 54 and engL) {
		setprop("/controls/electrical/xtie/xtieR", 1);
	} else {
		setprop("/controls/electrical/xtie/xtieR", 0);
	}
	
	# Right cross tie yes?
	if (extpwr_on and ext) {
		setprop("/controls/electrical/xtie/xtieL", 1);
	} else if (rpmapu >= 94.9 and apuR) {
		setprop("/controls/electrical/xtie/xtieL", 1);
	} else if (rpmR >= 54 and engR) {
		setprop("/controls/electrical/xtie/xtieL", 1);
	} else {
		setprop("/controls/electrical/xtie/xtieL", 0);
	}
	
	
	# Left DC bus yes?
	if (extpwr_on and ext) {
		setprop("/systems/electrical/bus/dcL", dc_volt_std);
	} else if (rpmapu >= 94.9 and apuL) {
		setprop("/systems/electrical/bus/dcL", dc_volt_std);
	} else if (rpmL >= 54 and engL) {
		setprop("/systems/electrical/bus/dcL", dc_volt_std);
	} else if (xtieL == 1 and dcxtie == 1) {
		setprop("/systems/electrical/bus/dcL", dc_volt_std);
	} else {
		setprop("/systems/electrical/bus/dcL", 0);
	}
	
	# Right DC bus yes?
	if (extpwr_on and ext) {
		setprop("/systems/electrical/bus/dcR", dc_volt_std);
	} else if (rpmapu >= 94.9 and apuR) {
		setprop("/systems/electrical/bus/dcR", dc_volt_std);
	} else if (rpmR >= 54 and engR) {
		setprop("/systems/electrical/bus/dcR", dc_volt_std);
	} else if (xtieR == 1 and dcxtie == 1) {
		setprop("/systems/electrical/bus/dcR", dc_volt_std);
	} else {
		setprop("/systems/electrical/bus/dcR", 0);
	}
	
	# Left AC bus yes?
	if (extpwr_on and ext) {
		setprop("/systems/electrical/bus/acL", ac_volt_std);
	} else if (rpmapu >= 94.9 and apuL) {
		setprop("/systems/electrical/bus/acL", ac_volt_std);
	} else if (rpmL >= 54 and engL) {
		setprop("/systems/electrical/bus/acL", ac_volt_std);
	} else if (xtieL == 1 and acxtie == 1) {
		setprop("/systems/electrical/bus/acL", ac_volt_std);
	} else {
		setprop("/systems/electrical/bus/acL", 0);
	}
	
	# Right AC bus yes?
	if (extpwr_on and ext) {
		setprop("/systems/electrical/bus/acR", ac_volt_std);
	} else if (rpmapu >= 94.9 and apuR) {
		setprop("/systems/electrical/bus/acR", ac_volt_std);
	} else if (rpmR >= 54 and engR) {
		setprop("/systems/electrical/bus/acR", ac_volt_std);
	} else if (xtieR == 1 and acxtie == 1) {
		setprop("/systems/electrical/bus/acR", ac_volt_std);
	} else {
		setprop("/systems/electrical/bus/acR", 0);
	}
	
	setprop("/instrumentation/attitude-indicator/spin", 1);
}

setlistener("/systems/electrical/bus/dcL", func {
	if (getprop("/systems/electrical/bus/dcL") >= 15) {
        setprop("systems/electrical/outputs/adf", dc_volt_std);
        setprop("systems/electrical/outputs/audio-panel", dc_volt_std);
        setprop("systems/electrical/outputs/audio-panel[1]", dc_volt_std);
        setprop("systems/electrical/outputs/autopilot", dc_volt_std);
        setprop("systems/electrical/outputs/avionics-fan", dc_volt_std);
        setprop("systems/electrical/outputs/beacon", dc_volt_std);
        setprop("systems/electrical/outputs/bus", dc_volt_std);
        setprop("systems/electrical/outputs/cabin-lights", dc_volt_std);
        setprop("systems/electrical/outputs/dme", dc_volt_std);
        setprop("systems/electrical/outputs/efis", dc_volt_std);
        setprop("systems/electrical/outputs/flaps", dc_volt_std);
        setprop("systems/electrical/outputs/fuel-pump", dc_volt_std);
        setprop("systems/electrical/outputs/fuel-pump[1]", dc_volt_std);
        setprop("systems/electrical/outputs/gps", dc_volt_std);
        setprop("systems/electrical/outputs/gps-mfd", dc_volt_std);
        setprop("systems/electrical/outputs/hsi", dc_volt_std);
        setprop("systems/electrical/outputs/instr-ignition-switch", dc_volt_std);
        setprop("systems/electrical/outputs/instrument-lights", dc_volt_std);
        setprop("systems/electrical/outputs/landing-lights", dc_volt_std);
        setprop("systems/electrical/outputs/map-lights", dc_volt_std);
        setprop("systems/electrical/outputs/mk-viii", dc_volt_std);
        setprop("systems/electrical/outputs/nav", dc_volt_std);
        setprop("systems/electrical/outputs/nav[1]", dc_volt_std);
        setprop("systems/electrical/outputs/pitot-head", dc_volt_std);
        setprop("systems/electrical/outputs/stobe-lights", dc_volt_std);
        setprop("systems/electrical/outputs/tacan", dc_volt_std);
        setprop("systems/electrical/outputs/taxi-lights", dc_volt_std);
        setprop("systems/electrical/outputs/transponder", dc_volt_std);
        setprop("systems/electrical/outputs/turn-coordinator", dc_volt_std);
	} else {
        setprop("systems/electrical/outputs/adf", 0);
        setprop("systems/electrical/outputs/audio-panel", 0);
        setprop("systems/electrical/outputs/audio-panel[1]", 0);
        setprop("systems/electrical/outputs/autopilot", 0);
        setprop("systems/electrical/outputs/avionics-fan", 0);
        setprop("systems/electrical/outputs/beacon", 0);
        setprop("systems/electrical/outputs/bus", 0);
        setprop("systems/electrical/outputs/cabin-lights", 0);
        setprop("systems/electrical/outputs/dme", 0);
        setprop("systems/electrical/outputs/efis", 0);
        setprop("systems/electrical/outputs/flaps", 0);
        setprop("systems/electrical/outputs/fuel-pump", 0);
        setprop("systems/electrical/outputs/fuel-pump[1]", 0);
        setprop("systems/electrical/outputs/gps", 0);
        setprop("systems/electrical/outputs/gps-mfd", 0);
        setprop("systems/electrical/outputs/hsi", 0);
        setprop("systems/electrical/outputs/instr-ignition-switch", 0);
        setprop("systems/electrical/outputs/instrument-lights", 0);
        setprop("systems/electrical/outputs/landing-lights", 0);
        setprop("systems/electrical/outputs/map-lights", 0);
        setprop("systems/electrical/outputs/mk-viii", 0);
        setprop("systems/electrical/outputs/nav", 0);
        setprop("systems/electrical/outputs/nav[1]", 0);
        setprop("systems/electrical/outputs/pitot-head", 0);
        setprop("systems/electrical/outputs/stobe-lights", 0);
        setprop("systems/electrical/outputs/tacan", 0);
        setprop("systems/electrical/outputs/taxi-lights", 0);
        setprop("systems/electrical/outputs/transponder", 0);
        setprop("systems/electrical/outputs/turn-coordinator", 0);
	}
});

setlistener("/systems/electrical/bus/acR", func {
	if (getprop("/systems/electrical/bus/acR") >= 100) {
		if (getprop("/controls/electrical/galley") == 1) {
			setprop("systems/electrical/bus/galley", ac_volt_std);
		} else if (getprop("/controls/electrical/galley") == 0) {
			setprop("systems/electrical/bus/galley", 0);
		}
	} else {
		setprop("systems/electrical/bus/galley", 0);
	}
});

###################
# Update Function #
###################

var update_electrical = func {
	master_elec();
}

var elec_timer = maketimer(0.2, update_electrical);
