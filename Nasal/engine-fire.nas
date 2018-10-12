# Engine Fire Originally By Gabriel Hernandez (YV3399)
# Edited for the 737-800 by Jonathan Redpath
# Copyright (c) 2018 Jonathan Redpath
# GNU GPL 2.0

fire_init = 0;

var fire_mgmt = {
    init : func { 
        me.UPDATE_INTERVAL = 1; 
        me.loopid = 0;
        me.reset(); 
        
        for (var i = 0; i < 3; i+= 1) {
            createFireListener(i);
            setprop("/controls/fires/fire[" ~ i ~ "]/extinguish-handle-armed", 0);
            setprop("/controls/fires/fire[" ~ i ~ "]/extinguish-handle-pos", 0);
            setprop("/controls/fires/fire[" ~ i ~ "]/burn-time", 0);
            setprop("/controls/fires/fire[" ~ i ~ "]/phase", "no-fire");
            setprop("/sim/sound/explode"~i, 0);
        }
        
        createFireLampListener(0, "engine1");
        createFireLampListener(1, "engine2");
        createFireLampListener(2, "apu");
    }, 
    update : func {
    
        for (var n = 0; n < 2; n += 1) {

            # PHASES: NO FIRE, FIRE, EXPLODE, SMOKE
        
            ## If there's a fire, it lasts for about 15 seconds. The crew can discharge it and shut it down (not that it needs to be discharged and shut down) and the fire moves back to the no fire phase. That is, they'll have to restart the engines to get them running again. Now, if they don't extinguish the fire in time, it makes an explosion and ends up in smoke throughout the flight. It can't be restarted either.
        
            if (getprop("/controls/fires/fire[" ~ n ~ "]/on-fire") == 1) {
                if (getprop("/controls/fires/fire[" ~ n ~ "]/burn-time") < 25) {
                    setprop("/controls/fires/fire[" ~ n ~ "]/burn-time", getprop("/controls/fires/fire[" ~ n ~ "]/burn-time") + 1);
                    setprop("/controls/fires/fire[" ~ n ~ "]/phase", "fire");
                } else {
                    setprop("/controls/fires/fire[" ~ n ~ "]/burn-time", getprop("/controls/fires/fire[" ~ n ~ "]/burn-time") + 1);
                    setprop("/sim/sound/explode" ~ n, 1);
                    setprop("/controls/fires/fire[" ~ n ~ "]/phase", "explode");
                    setprop("/sim/failure-manager/engines/engine[" ~ n ~ "]/serviceable", 0);
                    if (getprop("/controls/fires/fire[" ~ n ~ "]/burn-time") > 26) {
                        setprop("/controls/fires/fire[" ~ n ~ "]/phase", "smoke");
                    }
                }
            }
        }
        
        # apu: simpler system
        
        if (getprop("/controls/fires/fire[2]/on-fire") == 1) {
            if (getprop("/controls/fires/fire[2]/burn-time") < 25) {
                setprop("/controls/fires/fire[2]/burn-time", getprop("/controls/fires/fire[2]/burn-time") + 1);
                setprop("/controls/fires/fire[2]/phase", "fire");
            } else {
                setprop("/controls/fires/fire[2]/burn-time", getprop("/controls/fires/fire[2]/burn-time") + 1);
                setprop("/sim/sound/explode2", 1);
                setprop("/controls/fires/fire[2]/phase", "explode");
                if (getprop("/controls/fires/fire[2]/burn-time") > 26) {
                    setprop("/controls/fires/fire[2]/phase", "smoke");
				}
            }
        }
    
    },
    extinguish : func(n) {
        setprop("/controls/fires/fire[" ~ n ~"]/burn-time", 0);
        setprop("/controls/fires/fire[" ~ n ~"]/on-fire", 0);
        setprop("/controls/fires/fire[" ~ n ~"]/phase", "no-fire");
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

var createFireLampListener = func(i, symbol) {
    setlistener("/controls/fires/fire[" ~ i ~ "]/on-fire", func {
        setprop("/systems/weu/" ~ symbol ~ "-fire", 1);
    }, 0, 0);
}

var createFireListener = func(n) {
    setlistener("/controls/fires/fire[" ~ n ~ "]/extinguish-handle-pos", func {
        if (getprop("/controls/fires/fire[" ~ n ~ "]/extinguish-handle-pos") == -1) {
            var willItGoOut = rand();
            if (willItGoOut <= 0.6) {
                settimer(func {
                    fire_mgmt.extinguish(n);
                }, rand() * 5);
            }
        } elsif (getprop("/controls/fires/fire[" ~ n ~ "]/extinguish-handle-pos") == 1) {
            var willItGoOut = rand();
            if (willItGoOut <= 0.99) {
                settimer(func {
                    fire_mgmt.extinguish(n);
                }, rand() * 5);
            }
        }                   
    }, 0, 0);
}


setlistener("sim/signals/fdm-initialized", func {
    if (!fire_init){
        fire_mgmt.init();
        fire_init = 1;
    }
 });


