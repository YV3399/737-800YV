# A3XX Icing System
# Jonathan Redpath (legoboyvdlp)

#######################################
# Copyright (c) A3XX Development Team #
#######################################

var icingInit = func {
	setprop("/systems/icing/severity", "0"); # maximum severity: we will make it random
	setprop("/systems/icing/factor", 0.0); # the factor is how many inches we add per second
	setprop("/systems/icing/max-spread-degc", 0.0);
	setprop("/systems/icing/melt-w-heat-factor", -0.00005000);
	setprop("/systems/icing/icingcond", 0);
	setprop("/controls/switches/windowprobeheat", 0);
	setprop("/controls/switches/wing", 0);
	setprop("/controls/switches/wingfault", 0);
	setprop("/controls/switches/leng", 0);
	setprop("/controls/switches/lengfault", 0);
	setprop("/controls/switches/reng", 0);
	setprop("/controls/switches/rengfault", 0);
	setprop("/controls/deice/wing", 0);
	setprop("/controls/deice/lengine", 0);
	setprop("/controls/deice/rengine", 0);
	setprop("/controls/deice/windowprobeheat", 0);
	setprop("/systems/pitot/icing", 0.0);
	setprop("/systems/pitot/failed", 1);
	setprop("/controls/deice/WingHasBeenTurnedOff", 0);
	setprop("/controls/deice/GroundModeFinished", 0);
	icing_timer.start();
}

var icingModel = func {
	var dewpoint = getprop("/environment/dewpoint-degc");
	var temperature = getprop("/environment/temperature-degc");
	var speed = getprop("/velocities/airspeed-kt");
	var visibility = getprop("/environment/effective-visibility-m");
	var visibLclWx = getprop("/environment/visibility-m");
	var severity = getprop("/systems/icing/severity");
	var factor = getprop("/systems/icing/factor");
	var maxSpread = getprop("/systems/icing/max-spread-degc");
	var icingCond = getprop("/systems/icing/icingcond");
	var pause = getprop("/sim/freeze/master");
	var melt = getprop("/systems/icing/melt-w-heat-factor");
	var windowprobe = getprop("/controls/deice/windowprobeheat");
	var wingBtn = getprop("/controls/switches/wing");
	var wingFault = getprop("/controls/switches/wingfault");
	var wingAnti = getprop("/controls/deice/wing");
	var PSI = getprop("/systems/pneumatic/total-psi");
	var wowl = getprop("/gear/gear[1]/wow");
	var wowr = getprop("/gear/gear[2]/wow");
	var PitotIcing = getprop("/systems/pitot/icing");
	var PitotFailed = getprop("/systems/pitot/failed");
	var lengBtn = getprop("/controls/switches/leng");
	var lengFault = getprop("/controls/switches/lengfault");
	var rengBtn = getprop("/controls/switches/reng");
	var rengFault = getprop("/controls/switches/rengfault");
	var lengAnti = getprop("/controls/deice/lengine");
	var rengAnti = getprop("/controls/deice/rengine");
	var WingHasBeenTurnedOff = getprop("/controls/deice/WingHasBeenTurnedOff");
	var GroundModeFinished = getprop("/controls/deice/GroundModeFinished");
	
	if (temperature >= 0 or !icingCond) {
		setprop("/systems/icing/severity", "0");
	} else if (temperature < 0 and temperature >= -2 and icingCond) {
		setprop("/systems/icing/severity", "1");
	} else if (temperature < -2 and temperature >= -12 and icingCond) {
		setprop("/systems/icing/severity", "3");
	} else if (temperature < -12 and temperature >= -30 and icingCond) {
		setprop("/systems/icing/severity", "5");
	} else if (temperature < -30 and temperature >= -40 and icingCond) {
		setprop("/systems/icing/severity", "3");
	} else if (temperature < -40 and temperature >= -99 and icingCond) {
		setprop("/systems/icing/severity", "1");
	}
	
	var icing1 = getprop("/sim/model/icing/iceable[0]/ice-inches");
	var sensitive1 = getprop("/sim/model/icing/iceable[0]/sensitivity");
	var v = icing1 + (factor * sensitive1);
	var a = icing1 + melt;
	if (icing1 < 0.0 and !pause) {
		setprop("/sim/model/icing/iceable[0]/ice-inches", 0.0);
	} else if (wingAnti) {
		setprop("/sim/model/icing/iceable[0]/ice-inches", a);
	} else if (!pause and !wingAnti) {
		setprop("/sim/model/icing/iceable[0]/ice-inches", v);
	}
	
	var icing2 = getprop("/sim/model/icing/iceable[1]/ice-inches");
	var sensitive2 = getprop("/sim/model/icing/iceable[1]/sensitivity");
	var u = icing2 + (factor * sensitive2);
	var b = icing2 + melt;
	if (icing2 < 0.0 and !pause) {
		setprop("/sim/model/icing/iceable[1]/ice-inches", 0.0);
	} else if (lengAnti) {
		setprop("/sim/model/icing/iceable[1]/ice-inches", b);
	} else if (!pause and !lengAnti) {
		setprop("/sim/model/icing/iceable[1]/ice-inches", u);
	}
	
	var icing3 = getprop("/sim/model/icing/iceable[2]/ice-inches");
	var sensitive3 = getprop("/sim/model/icing/iceable[2]/sensitivity");
	var t = icing3 + (factor * sensitive3);
	var c = icing3 + melt;
	if (icing3 < 0.0 and !pause) {
		setprop("/sim/model/icing/iceable[2]/ice-inches", 0.0);
	} else if (rengAnti) {
		setprop("/sim/model/icing/iceable[2]/ice-inches", c);
	} else if (!pause and !rengAnti) {
		setprop("/sim/model/icing/iceable[2]/ice-inches", t);
	}
	
	var icing4 = getprop("/sim/model/icing/iceable[3]/ice-inches");
	var sensitive4 = getprop("/sim/model/icing/iceable[3]/sensitivity");
	var s = icing4 + (factor * sensitive4);
	var d = icing4 + melt;
	if (icing4 < 0.0 and !pause) {
		setprop("/sim/model/icing/iceable[3]/ice-inches", 0.0);
	} else if (windowprobe) {
		setprop("/sim/model/icing/iceable[3]/ice-inches", d);
	} else if (!pause and !windowprobe) {
		setprop("/sim/model/icing/iceable[3]/ice-inches", s);
	}
	
	var icing5 = getprop("/sim/model/icing/iceable[4]/ice-inches");
	var sensitive5 = getprop("/sim/model/icing/iceable[4]/sensitivity");
	var r = icing5 + (factor * sensitive5);
	if (icing5 < 0.0 and !pause) {
		setprop("/sim/model/icing/iceable[4]/ice-inches", 0.0);
	} else if (!pause) {
		setprop("/sim/model/icing/iceable[4]/ice-inches", r);
	}
	
	var icing6 = getprop("/sim/model/icing/iceable[5]/ice-inches");
	var sensitive6 = getprop("/sim/model/icing/iceable[5]/sensitivity");
	var q = icing6 + (factor * sensitive6);
	var e = icing6 + melt;
	if (icing6 < 0.0 and !pause) {
		setprop("/sim/model/icing/iceable[5]/ice-inches", 0.0);
	} else if (windowprobe) {
		setprop("/sim/model/icing/iceable[5]/ice-inches", e);
	} else if (!pause and !windowprobe) {
		setprop("/sim/model/icing/iceable[5]/ice-inches", q);
	}
	
	# Do we create ice?
	var spread = temperature - dewpoint;
	# freezing fog or low temp and below dp or in advanced wx cloud
	if ((spread < maxSpread and temperature < 0) or (temperature < 0 and visibility < 1000) or (visibLclWx < 5000 and temperature < 0)) { 
		setprop("/systems/icing/icingcond", 1);
	} else {
		setprop("/systems/icing/icingcond", 0);
	}
	
	#################
	# Wing Anti-Ice #
	#################

	# Switching on the wing anti-ice
	setlistener("/controls/switches/wing", func {
		# On the ground
		if (wowl and wowr and wingBtn) {
			setprop("/controls/switches/wingfault", 1);
			settimer(func() {
				setprop("/controls/switches/wingfault", 0);
				setprop("/controls/deice/wing", 1);
			}, 0.5);
			settimer(func() {
				setprop("/controls/deice/WingHasBeenTurnedOff", 1);
				setprop("/controls/deice/wing", 0);
			}, 30.5);
			settimer(func() {
				setprop("/controls/deice/GroundModeFinished", 1);
			}, 31);
		} else if (wingBtn and !wowl and !wowr) { # In the air
			setprop("/controls/switches/wingfault", 1);
			settimer(func() {
				setprop("/controls/switches/wingfault", 0);
				setprop("/controls/deice/wing", 1);
			}, 0.5);
		} else if (!wingBtn) {
			setprop("/controls/switches/wingfault", 1);
			settimer(func() {
				setprop("/controls/switches/wingfault", 0);
				setprop("/controls/deice/wing", 0);
			}, 0.5);
		}
	});
	
	if (WingHasBeenTurnedOff and !wowl and !wowr and GroundModeFinished) {
		setprop("/controls/deice/wing", 1);
		setprop("/controls/switches/WingHasBeenTurnedOff", 0);
	}
		
	
	# If we have low pressure we have a fault
	if (PSI < 10) {
		setprop("/controls/switches/wingfault", 1);
		setprop("/controls/deice/wing", 0);
	} 
	
	if (PSI > 10 and wingFault) {
		setprop("/controls/switches/wingfault", 0);
		if (wingBtn) { 
			setprop("/controls/deice/wing", 1);
		}
	}
	
	#################
	# LEng Anti-Ice #
	#################

	setlistener("/controls/switches/leng", func {
		if (lengBtn) {
			setprop("/controls/switches/lengfault", 1);
			settimer(func() {
				setprop("/controls/switches/lengfault", 0);
				setprop("/controls/deice/lengine", 1);
			}, 0.5);
		} else if (!lengBtn) {
			setprop("/controls/switches/lengfault", 1);
			settimer(func() {
				setprop("/controls/switches/lengfault", 0);
				setprop("/controls/deice/lengine", 0);
			}, 0.5);
		}
	});
	
	#################
	# REng Anti-Ice #
	#################

	setlistener("/controls/switches/reng", func {
		if (rengBtn) {
			setprop("/controls/switches/rengfault", 1);
			settimer(func() {
				setprop("/controls/switches/rengfault", 0);
				setprop("/controls/deice/rengine", 1);
			}, 0.5);
		} else if (!rengBtn) {
			setprop("/controls/switches/rengfault", 1);
			settimer(func() {
				setprop("/controls/switches/rengfault", 0);
				setprop("/controls/deice/rengine", 0);
			}, 0.5);
		}
	});
	
	##################
	# Probe Anti-Ice #
	##################
	
	if (PitotIcing > 0.03) {
		if (!PitotFailed) {
			setprop("/systems/pitot/failed", 1);
		}
	} else if (PitotIcing < 0.03) {
		if (PitotFailed) {
			setprop("/systems/pitot/failed", 0);
		}
	}
	
	setlistener("/controls/switches/windowprobeheat", func {
		var windowprb = getprop("/controls/switches/windowprobeheat");
		if (windowprb == 0.5) { # if in auto 
			var wowl = getprop("/gear/gear[1]/wow");
			var wowr = getprop("/gear/gear[2]/wow");
			var stateL = getprop("/engines/engine[0]/state");
			var stateR = getprop("/engines/engine[1]/state");
			if (!wowl or !wowr) {
				setprop("/controls/deice/windowprobeheat", 1);
			} else if (stateL == 3 or stateR == 3) {
				setprop("/controls/deice/windowprobeheat", 1);
			}
		} else if (windowprb == 1) { # if in ON
			setprop("/controls/deice/windowprobeheat", 1);
		} else {
			setprop("/controls/deice/windowprobeheat", 0);
		}
	});	
}

###################
# Update Function #
###################

var update_Icing = func {
	icingModel();
}

var icing_timer = maketimer(0.2, update_Icing);