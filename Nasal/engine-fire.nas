# Engine Fire Originally By Gabriel Hernandez (YV3399)
# Edited for the 737-800 by Jonathan Redpath
# Copyright (c) 2018 Jonathan Redpath
# GNU GPL 2.0

fire_init = 0;

var fire_mgmt = {
    init : func {
        for (var i = 0; i < 3; i+= 1) {
            createFireHandleListener(i);
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
	engine0Update : func {
			if (getprop("/controls/fires/fire[0]/burn-time") < 25) {
				setprop("/controls/fires/fire[0]/burn-time", getprop("/controls/fires/fire[0]/burn-time") + 1);
				setprop("/controls/fires/fire[0]/phase", "fire");
			} else {
				setprop("/controls/fires/fire[0]/burn-time", getprop("/controls/fires/fire[0]/burn-time") + 1);
				setprop("/sim/sound/explode1", 1);
				setprop("/controls/fires/fire[0]/phase", "explode");
				setprop("/sim/failure-manager/engines/engine[0]/serviceable", 0);
				if (getprop("/controls/fires/fire[0]/burn-time") > 26) {
					setprop("/controls/fires/fire[0]/phase", "smoke");
				}
			}
    }, 
	engine1Update : func {
			if (getprop("/controls/fires/fire[1]/burn-time") < 25) {
				setprop("/controls/fires/fire[1]/burn-time", getprop("/controls/fires/fire[1]/burn-time") + 1);
				setprop("/controls/fires/fire[1]/phase", "fire");
			} else {
				setprop("/controls/fires/fire[1]/burn-time", getprop("/controls/fires/fire[1]/burn-time") + 1);
				setprop("/sim/sound/explode1", 1);
				setprop("/controls/fires/fire[1]/phase", "explode");
				setprop("/sim/failure-manager/engines/engine[1]/serviceable", 0);
				if (getprop("/controls/fires/fire[1]/burn-time") > 26) {
					setprop("/controls/fires/fire[1]/phase", "smoke");
				}
			}
    }, 
	engine2Update: func {
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
};

var createFireLampListener = func(i, symbol) {
    setlistener("/controls/fires/fire[" ~ i ~ "]/on-fire", func {
        setprop("/systems/weu/" ~ symbol ~ "-fire", 1);
    }, 0, 0);
}

var createFireHandleListener = func(n) {
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

setlistener("/controls/fires/fire[0]/on-fire", func {
	if (getprop("/controls/fires/fire[0]/on-fire") == 1) {
		engine0Timer.start();
	} else {
		engine0Timer.stop();
	}
}, 0, 0);

setlistener("/controls/fires/fire[1]/on-fire", func {
	if (getprop("/controls/fires/fire[1]/on-fire") == 1) {
		engine1Timer.start();
	} else {
		engine1Timer.stop();
	}
}, 0, 0);

setlistener("/controls/fires/fire[2]/on-fire", func {
	if (getprop("/controls/fires/fire[2]/on-fire") == 1) {
		engine2Timer.start();
	} else {
		engine2Timer.stop();
	}
}, 0, 0);
	
var engine0Timer = maketimer(0.25, func {
	fire_mgmt.engine0Update();
});

var engine1Timer = maketimer(0.25, func {
	fire_mgmt.engine1Update();
});

var engine2Timer = maketimer(0.25, func {
	fire_mgmt.engine2Update();
});
