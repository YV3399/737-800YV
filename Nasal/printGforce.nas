# print G force when touchdown.

var VERSION = "1.1";

props.globals.initNode("position/gear-agl-ft", 0);
var N = 100;
var count = N;
var maxG = 0.0;
var minVs = 0.0;
var touchGs = 0.0;
var kill = 0;
var pgf_started = 0;
var printGforce_start = func {
    if (pgf_started == 1) return;
    pgf_started = 1;
    printGforce();
}

var printGforce = func {
    var vs = getprop("velocities/vertical-speed-fps") * 60;
    var ias = getprop("velocities/airspeed-kt");
    var ggl = getprop("position/gear-agl-ft");
    var gr1_cmprs = getprop("gear/gear[1]/compression-norm");
    var gr2_cmprs = getprop("gear/gear[2]/compression-norm");
    var gdamped = getprop("accelerations/pilot-gdamped");
    var replay_state = getprop("sim/freeze/replay-state");
    
    if (count < N and (gr1_cmprs != 0 or gr2_cmprs != 0) and replay_state == 0) {
	
        if (gdamped > 0.0) {
            if (gdamped > maxG) {
                maxG = gdamped;
                
            }
            gs = getprop("velocities/groundspeed-kt");
            if (gs > touchGs) {
                touchGs = gs;
            }
            if (vs < minVs) {
                minVs = vs;
            }
        }
	if (count == N - 1){
	    print(">=======================================");
            print("> Touchdown G Force: ", maxG);
            print("> Touchdown VS: ", minVs);
            print("> Touchdown GS: ", touchGs);
            if (minVs > -60) {
                print("> Too soft landing (<60fpm)");
            } else if (minVs >= -180) {
                print("> Correct landing (60-180fpm)");
            } else if (minVs >= -240) {
                print("> A bit too firm landing (180-240fpm)");
            } else if (minVs > -600) {
                print("> Firm landing (240-600fpm)");
            } else {
                print("> Hard landing (>600fpm)");
            }
	    print(">=======================================");
	}

        count = count + 1;
    }
    
    var delay = 0.05;
    if (ggl > 30){
        count = 0;
        if (maxG > 0.0) {
            maxG = 0.0;
            minVs = 0.0;
            touchGs = 0.0;
        }
        if (ggl > 100) {
            delay = 0.2;
        }
    }
    if (kill == 0) {
        settimer(printGforce, delay);
    } else {
        print("> Stopped version ", VERSION);
    }
};

print("> Loaded printGforce version ", VERSION);
setlistener("/sim/signals/fdm-initialized", printGforce_start, 0, 0);
