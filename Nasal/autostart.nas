## 737-300 Start - Shutdown


# Autostart #

var autostart = func {

	setprop("/sim/input/selected/engine[0]",1);
	setprop("/sim/input/selected/engine[1]",1);
  
	setprop("/controls/electric/battery-switch",1);
	setprop("/controls/electric/apugen1",1);
	setprop("/controls/electric/apugen2",1);

	setprop("/systems/electrical/outputs/efis",28); #for central eicas function
	
	setprop("/controls/fuel/tank[0]/pump-aft",1);
	setprop("/controls/fuel/tank[0]/pump-fwd",1);
	setprop("/controls/fuel/tank[1]/pump-aft",1);
	setprop("/controls/fuel/tank[1]/pump-fwd",1);
	setprop("/controls/fuel/tank[2]/pump-left",1);
	setprop("/controls/fuel/tank[2]/pump-right",1);

  setprop("/controls/engines/engine[0]/starter",1);
	setprop("/controls/engines/engine[1]/starter",1);
	setprop("/controls/engines/engine[0]/cutoff",1);
	setprop("/controls/engines/engine[1]/cutoff",1);

	if (getprop("/engines/engine[0]/n2") > 25) {
		setprop("/controls/engines/engine[0]/cutoff",0);
		setprop("/controls/engines/engine[1]/cutoff",0);
		setprop("/controls/engines/autostart",0);
	}
	if (getprop("/engines/engine[0]/n2") < 25) settimer(autostart,0);
}

# Shutdown #

var shutdown = func {

  	setprop("/controls/engines/engine[0]/cutoff",1);
	  setprop("/controls/engines/engine[1]/cutoff",1);
	  setprop("/controls/electric/battery-switch",0);
	  setprop("/controls/electric/apugen1",0);
	  setprop("/controls/electric/apugen2",0);
    setprop("/controls/engines/engine[0]/starter",0);
	  setprop("/controls/engines/engine[1]/starter",0);

  	setprop("/controls/fuel/tank[0]/pump-aft",0);
	  setprop("/controls/fuel/tank[0]/pump-fwd",0);
	  setprop("/controls/fuel/tank[1]/pump-aft",0);
	  setprop("/controls/fuel/tank[1]/pump-fwd",0);
	  setprop("/controls/fuel/tank[2]/pump-left",0);
	  setprop("/controls/fuel/tank[2]/pump-right",0);


#	  setprop("/controls/engines/autostart",1);
}

var inAirStart = func {
    if (getprop("position/altitude-agl-ft")>400) {
    	setprop("controls/gear/brake-parking",0);
    	setprop("/b737/sensors/was-in-air", "true");
    	setprop("/b737/sensors/landing", 0);
		autostart();
		if(var vbaro = getprop("environment/metar/pressure-inhg")) {
            setprop("instrumentation/altimeter[0]/setting-inhg", vbaro);
            setprop("instrumentation/altimeter[1]/setting-inhg", vbaro);
            setprop("instrumentation/altimeter[2]/setting-inhg", vbaro);
        }
        setprop("instrumentation/flightdirector/fd-left-on", 1);
        setprop("instrumentation/flightdirector/fd-right-on", 1);
        setprop("autopilot/settings/target-speed-kt", boeing737.roundToNearest(getprop("sim/presets/airspeed-kt"), 1));
        setprop("autopilot/settings/heading-bug-deg", boeing737.roundToNearest(getprop("orientation/heading-magnetic-deg"), 1));
        setprop("autopilot/settings/target-altitude-mcp-ft", boeing737.roundToNearest(getprop("sim/presets/altitude-ft"), 100));
        setprop("autopilot/internal/SPD", 1);
        autopilot737.hdg_mode_engage();
        settimer(func {autopilot737.lvlchg_button_press();}, 1);
        settimer(func {autopilot737.cmda_button_press();}, 1.2);

        # set ILS frequency
        var cur_runway = getprop("sim/presets/runway");
        var runways = airportinfo(getprop("sim/presets/airport-id")).runways;
        var r =runways[cur_runway];
        if (r != nil and r.ils != nil)
        {
            setprop("instrumentation/nav[0]/frequencies/selected-mhz", (r.ils.frequency / 100));
            setprop("instrumentation/nav[1]/frequencies/selected-mhz", (r.ils.frequency / 100));
            settimer(func {
            	var magvar = getprop("environment/magnetic-variation-deg");
	            var crs = boeing737.roundToNearest(geo.normdeg(getprop("instrumentation/nav[0]/radials/target-radial-deg") - magvar), 1);
	            setprop("instrumentation/nav[0]/radials/selected-deg", crs);
	            setprop("instrumentation/nav[1]/radials/selected-deg", crs);
	        }, 2);
        }
    }
}

setlistener("sim/signals/fdm-initialized", inAirStart);
setlistener("sim/signals/reinit", inAirStart);

