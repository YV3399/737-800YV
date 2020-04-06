# 737-800 JSB Engine System
# Joshua Davidson (it0uchpods)

#####################
# Initializing Vars #
#####################

var apu_max = 99.8;
var apu_egt_max = 513;
var spinup_time = 15;
var apu_consumption_lbs_sec = 240 / (60 * 60);
var apu_tank_level_prop = "/consumables/fuel/tank/level-lbs";

setprop("/systems/apu/rpm", 0);
setprop("/systems/apu/egt", 42);

#############
# Start APU #
#############

setlistener("/controls/APU/master", func {
	if ((getprop("/controls/APU/master") == 2) and (getprop("/controls/electric/battery-switch") == 1)) {
		interpolate("/systems/apu/rpm", apu_max, spinup_time);
		interpolate("/systems/apu/egt", apu_egt_max, spinup_time);
		apu_startt.start();
                apu_fuelt.start();
	} else if (getprop("/controls/APU/master") == 0) {
		apu_stop();
	}
}, 0, 0);

var apu_start = func {
	if (getprop("/systems/apu/rpm") >= 20) {
		setprop("/controls/APU/master", 1);
		apu_startt.stop();
	}
}

############
# Stop APU #
############

var apu_stop = func {
	interpolate("/systems/apu/rpm", 0, spinup_time);
	interpolate("/systems/apu/egt", 42, spinup_time);
        apu_fuelt.stop();
}

##############
# Fuel usage #
##############

var apu_fuel_loop = func {
    var lvl = getprop(apu_tank_level_prop) - apu_consumption_lbs_sec;
    if (lvl <= 0.0) {
        lvl = 0.0;
        apu_stop();
    }
    setprop(apu_tank_level_prop, lvl);
}


##########
# Timers #
##########
var apu_startt = maketimer(0.5, apu_start);
var apu_fuelt  = maketimer(1, apu_fuel_loop);
