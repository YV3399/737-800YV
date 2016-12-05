# Electrical system for 737-800 by Joshua Davidson (it0uchpods/411).

var ELEC_UPDATE_PERIOD	= 1;					# A periodic update in secs
var STD_VOLTS_AC	= 115;						# Typical volts for a power source
var MIN_VOLTS_AC	= 115;						# Typical minimum voltage level for generic equipment
var STD_VOLTS_DC	= 28;						# Typical volts for a power source
var MIN_VOLTS_DC	= 25;						# Typical minimum voltage level for generic equipment
var STD_AMPS		= 0;						# Not used yet
var NUM_ENGINES		= 2;


									# Handy handles for DC source feed indices
var feed	= {	eng1	: 0,
			eng2	: 1,
			apu	: 2,
			batt	: 3,
			cart	: 4,
			rect1	: 5,
			rect2	: 6
		  };
var feed_status	= [0,0,0,0,0,0,0];					# For fast feed switch checking
var RECT_OFFSET = 5;							# Handy rectifier index offset

var elec_init = func {
	setprop("/controls/electric/battery-switch", 0);   # Set all the stuff I need
	setprop("/controls/electrical/ext/Lsw", 0);
	setprop("/controls/electrical/ext/Rsw", 0);
	setprop("/controls/electrical/emerpwr", 0);
	setprop("/controls/electrical/galley", 0);
	setprop("/controls/electrical/xtie/acxtie", 1);
	setprop("/controls/electrical/xtie/dcxtie", 0);
	setprop("/controls/electrical/xtie/xtieL", 0);
	setprop("/controls/electrical/xtie/xtieR", 0);
	setprop("/controls/electrical/apu/Lsw", 0);
	setprop("/controls/electrical/apu/Rsw", 0);
	setprop("/controls/electrical/eng/Lsw", 1);
	setprop("/controls/electrical/eng/Rsw", 1);
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
}

var master_elec = func {
	var battery_on = getprop("/controls/electric/battery-switch");   # Define all the stuff I need
	var extpwr_on = getprop("/services/ext-pwr/enable");
	var extL = getprop("/controls/electrical/ext/Lsw");
	var extR = getprop("/controls/electrical/ext/Rsw");
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
	var rpmL = getprop("/engines/engine[0]/n1");
	var rpmR = getprop("/engines/engine[1]/n1");
	var dcbusL = getprop("/systems/electrical/bus/dcL");
	var dcbusR = getprop("/systems/electrical/bus/dcR");
	var acbusL = getprop("/systems/electrical/bus/acL");
	var acbusR = getprop("/systems/electrical/bus/acR");
	var Lgen = getprop("/systems/electrical/bus/genL");
	var Rgen = getprop("/systems/electrical/bus/genR");
	var galley = getprop("/controls/electrical/galley");
	
	# Left cross tie yes?
	if (extpwr_on and extL) {
		setprop("/controls/electrical/xtie/xtieR", 1);
	} else if (rpmapu >= 99 and apuL) {
		setprop("/controls/electrical/xtie/xtieR", 1);
	} else if (rpmL >= 15 and engL) {
		setprop("/controls/electrical/xtie/xtieR", 1);
	} else {
		setprop("/controls/electrical/xtie/xtieR", 0);
	}
	
	# Right cross tie yes?
	if (extpwr_on and extR) {
		setprop("/controls/electrical/xtie/xtieL", 1);
	} else if (rpmapu >= 99 and apuR) {
		setprop("/controls/electrical/xtie/xtieL", 1);
	} else if (rpmR >= 15 and engR) {
		setprop("/controls/electrical/xtie/xtieL", 1);
	} else {
		setprop("/controls/electrical/xtie/xtieL", 0);
	}
	
	
	# Left DC bus yes?
	if (extpwr_on and extL) {
		setprop("/systems/electrical/bus/dcL", 28);
	} else if (emerpwr_on) {
		setprop("/systems/electrical/bus/dcL", 28);
	} else if (rpmapu >= 99 and apuL) {
		setprop("/systems/electrical/bus/dcL", 28);
	} else if (rpmL >= 15 and engL) {
		setprop("/systems/electrical/bus/dcL", 28);
	} else if (xtieL == 1 and dcxtie == 1) {
		setprop("/systems/electrical/bus/dcL", 28);
	} else {
		setprop("/systems/electrical/bus/dcL", 0);
	}
	
	# Right DC bus yes?
	if (extpwr_on and extR) {
		setprop("/systems/electrical/bus/dcR", 28);
	} else if (rpmapu >= 99 and apuR) {
		setprop("/systems/electrical/bus/dcR", 28);
	} else if (rpmR >= 15 and engR) {
		setprop("/systems/electrical/bus/dcR", 28);
	} else if (xtieR == 1 and dcxtie == 1) {
		setprop("/systems/electrical/bus/dcR", 28);
	} else {
		setprop("/systems/electrical/bus/dcR", 0);
	}
	
	# Left AC bus yes?
	if (extpwr_on and extL) {
		setprop("/systems/electrical/bus/acL", 115);
	} else if (emerpwr_on) {
		setprop("/systems/electrical/bus/acL", 115);
	} else if (rpmapu >= 99 and apuL) {
		setprop("/systems/electrical/bus/acL", 115);
	} else if (rpmL >= 15 and engL) {
		setprop("/systems/electrical/bus/acL", 115);
	} else if (xtieL == 1 and acxtie == 1) {
		setprop("/systems/electrical/bus/acL", 115);
	} else {
		setprop("/systems/electrical/bus/acL", 0);
	}
	
	# Right AC bus yes?
	if (extpwr_on and extR) {
		setprop("/systems/electrical/bus/acR", 115);
	} else if (rpmapu >= 99 and apuR) {
		setprop("/systems/electrical/bus/acR", 115);
	} else if (rpmR >= 15 and engR) {
		setprop("/systems/electrical/bus/acR", 115);
	} else if (xtieR == 1 and acxtie == 1) {
		setprop("/systems/electrical/bus/acR", 115);
	} else {
		setprop("/systems/electrical/bus/acR", 0);
	}
}

setlistener("/systems/electrical/bus/dcL", func {
	var dcL = getprop("/systems/electrical/bus/dcL");
	if (dcL >= 15) {
        setprop("systems/electrical/outputs/adf", 28);
        setprop("systems/electrical/outputs/audio-panel", 28);
        setprop("systems/electrical/outputs/audio-panel[1]", 28);
        setprop("systems/electrical/outputs/autopilot", 28);
        setprop("systems/electrical/outputs/avionics-fan", 28);
        setprop("systems/electrical/outputs/beacon", 28);
        setprop("systems/electrical/outputs/bus", 28);
        setprop("systems/electrical/outputs/cabin-lights", 28);
        setprop("systems/electrical/outputs/dme", 28);
        setprop("systems/electrical/outputs/efis", 28);
        setprop("systems/electrical/outputs/flaps", 28);
        setprop("systems/electrical/outputs/fuel-pump", 28);
        setprop("systems/electrical/outputs/fuel-pump[1]", 28);
        setprop("systems/electrical/outputs/gps", 28);
        setprop("systems/electrical/outputs/gps-mfd", 28);
        setprop("systems/electrical/outputs/hsi", 28);
        setprop("systems/electrical/outputs/instr-ignition-switch", 28);
        setprop("systems/electrical/outputs/instrument-lights", 28);
        setprop("systems/electrical/outputs/landing-lights", 28);
        setprop("systems/electrical/outputs/map-lights", 28);
        setprop("systems/electrical/outputs/mk-viii", 28);
        setprop("systems/electrical/outputs/nav", 28);
        setprop("systems/electrical/outputs/nav[1]", 28);
        setprop("systems/electrical/outputs/pitot-head", 28);
        setprop("systems/electrical/outputs/stobe-lights", 28);
        setprop("systems/electrical/outputs/tacan", 28);
        setprop("systems/electrical/outputs/taxi-lights", 28);
        setprop("systems/electrical/outputs/transponder", 28);
        setprop("systems/electrical/outputs/turn-coordinator", 28);
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
	var acR = getprop("/systems/electrical/bus/acR");
	var galley = getprop("/controls/electrical/galley");
	if (acR >= 100) {
		if (galley == 1) {
			setprop("systems/electrical/bus/galley", 115);
		} else if (galley == 0) {
			setprop("systems/electrical/bus/galley", 0);
		}
	} else {
		setprop("systems/electrical/bus/galley", 0);
	}
});


setlistener("/controls/electric/battery-switch", func {
	var batt = getprop("/controls/electric/battery-switch");
	if (batt == 0) {
        setprop("systems/electrical/on", 0);
		ai_spin.setValue(0.2);
		aispin.stop();
	} else if (batt == 1) {
        setprop("systems/electrical/on", 1);
		aispin.start();
	}
});

var ai_spin	= props.globals.getNode("/instrumentation/attitude-indicator/spin");

var aispinfunc = func {
  ai_spin.setValue(1);
}

var aispin = maketimer(5, aispinfunc);

  
var update_electrical = func {
  master_elec();

  
  settimer(update_electrical,ELEC_UPDATE_PERIOD);			# Schedule next run
}


settimer(update_electrical, 2);						# Give a few seconds for vars to initialize