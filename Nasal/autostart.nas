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

