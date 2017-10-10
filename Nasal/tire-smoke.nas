
var run_tyresmoke0 = 0;
var run_tyresmoke1 = 0;
var run_tyresmoke2 = 0;

var tyresmoke_0 = aircraft.tyresmoke.new(0);
var tyresmoke_1 = aircraft.tyresmoke.new(1);
var tyresmoke_2 = aircraft.tyresmoke.new(2);





# =============================== listeners ===============================
#

#setlistener( "controls/lighting/nav-lights", func {
#	var nav_lights_node = props.globals.getNode("controls/lighting/nav-lights", 1);
#	var generic_node = props.globals.getNode("sim/multiplay/generic/int[0]", 1);
#	generic_node.setIntValue(nav_lights_node.getValue());
#	print("nav_lights ", nav_lights_node.getValue(), "generic_node ", generic_node.getValue());
#	},
#	1,
#	0); 

setlistener("gear/gear[0]/position-norm", func {
	var gear = getprop("gear/gear[0]/position-norm");
	
	if (gear == 1 ){
		run_tyresmoke0 = 1;
	}else{
		run_tyresmoke0 = 0;
	}

	},
	1,
	0);

setlistener("gear/gear[1]/position-norm", func {
	var gear = getprop("gear/gear[1]/position-norm");
	
	if (gear == 1 ){
		run_tyresmoke1 = 1;
	}else{
		run_tyresmoke1 = 0;
	}

	},
	1,
	0);

setlistener("gear/gear[2]/position-norm", func {
	var gear = getprop("gear/gear[2]/position-norm");
	
	if (gear == 1 ){
		run_tyresmoke2 = 1;
	}else{
		run_tyresmoke2 = 0;
	}

	},
	1,
	0);



#============================ Tyre Smoke ===================================

var update_tire_smoke = maketimer(0, func {

#print ("run_tyresmoke ",run_tyresmoke0);

	if (run_tyresmoke0)
		tyresmoke_0.update();

	if (run_tyresmoke1)
		tyresmoke_1.update();

	if (run_tyresmoke2)
		tyresmoke_2.update();
} );
 update_tire_smoke.start();
  		  	
  		  	
#============================ Rain ===================================
aircraft.rain.init();

var update_rain_smoke = maketimer(0, func {
aircraft.rain.update();
} );
# == fire it up ===
update_rain_smoke.start();
# end 
