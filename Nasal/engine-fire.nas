var fire_mgmt = {
	init : func { 
        me.UPDATE_INTERVAL = 1; 
        me.loopid = 0; 
		setprop("/controls/fires/fire/burn-time", 0);
		setprop("/controls/fires/fire[1]/burn-time", 0);
		setprop("/controls/fires/fire/phase", "no-fire");
		setprop("/controls/fires/fire[1]/phase", "no-fire");
		setprop("/sim/sound/explode0", 0);
		setprop("/sim/sound/explode1", 0);
        me.reset(); 
	}, 
	update : func {
	
		for (var n = 0; n < 2; n += 1) {

			# PHASES: NO FIRE, FIRE, EXPLODE, SMOKE
		
			## If there's a fire, it lasts for about 15 seconds. The crew can discharge it and shut it down (not that it needs to be discharged and shut down) and the fire moves back to the no fire phase. That is, they'll have to restart the engines to get them running again. Now, if they don't extinguish the fire in time, it makes an explosion and ends up in smoke throughout the flight. It can't be restarted either.
		
			if (getprop("/controls/fires/fire[" ~ n ~ "]/on-fire") == 1) {
			
				if (getprop("/controls/fires/fire[" ~ n ~ "]/burn-time") < 25) {
					
					setprop("/controls/fires/fire[" ~ n ~ "]/burn-time", getprop("/controls/fires/fire[" ~ n ~ "]/burn-time") + 1);
					
					setprop("/controls/fires/fire[" ~ n ~ "]/phase", "fire");
					
					if ((getprop("/controls/engines/engine[" ~ n ~ "]/cutoff") == 1) and (getprop("/controls/fires/fire[" ~ n ~ "]/extinguish") == 1)) {
						
						setprop("/controls/fires/fire[" ~ n ~ "]/burn-time", 0);
						setprop("/sim/sound/explode" ~ n, 0);
						setprop("/controls/fires/fire[" ~ n ~ "]/on-fire", 0);
						setprop("/controls/fires/fire[" ~ n ~ "]/phase", "no-fire");
						
					}
					
				} else {
				
					setprop("/controls/fires/fire[" ~ n ~ "]/burn-time", getprop("/controls/fires/fire[" ~ n ~ "]/burn-time") + 1);
				
					setprop("/sim/sound/explode" ~ n, 1);
					setprop("/controls/fires/fire[" ~ n ~ "]/phase", "explode");
					setprop("/sim/failure-manager/engines/engine[" ~ n ~ "]/serviceable", 0);
					
					if (getprop("/controls/fires/fire[" ~ n ~ "]/burn-time") > 26) {
					
						setprop("/controls/fires/fire[" ~ n ~ "]/phase", "smoke");
						setprop("/sim/failure-manager/engines/engine[" ~ n ~ "]/serviceable", 0);
					
					}
				
				}
			
			}
		
		}

	},
    reset : func { 
        me.loopid += 1;
        me._loop_(me.loopid);
    },
    _loop_ : func(id) {
        id == me.loopid or return;
        me.update();
        settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
    }

};

setlistener("sim/signals/fdm-initialized", func
 {
 fire_mgmt.init();
 if (getprop("/controls/fires/fire/on-fire") != 1)
 	sysinfo.log_msg("[ENG] Engine 1 Check ..... OK", 0);
 if (getprop("/controls/fires/fire[1]/on-fire") != 1)
 sysinfo.log_msg("[ENG] Engine 2 Check ..... OK", 0);
 });
