var door = aircraft.door.new("/services/deicing_truck/crane", 20);
var door3 = aircraft.door.new("/services/deicing_truck/deicing", 20);

var RAD2DEG = 57.3;

var ground_services = {
	init : func {
		me.UPDATE_INTERVAL = 0.1;
	me.loopid = 0;
	
	me.ice_time = 0;
	
	# Chokes and Parking Brakes
	
	# setprop("/services/chokes/nose", 1);
	# setprop("/services/chokes/left", 1);
	# setprop("/services/chokes/right", 1);
	
	# setprop("/controls/parking-brake", 1);
	
	# External Power
	
	setprop("/services/ext-pwr/enable", 0);
	
	# Catering Truck
	
	setprop("/services/catering/scissor-deg", 0);
	setprop("/sim/model/door-positions/cater_pos/position-norm", 0);

	# Fuel Truck
	
	setprop("/services/fuel-truck/enable", 0);
	setprop("/services/fuel-truck/connect", 0);
	setprop("/services/fuel-truck/transfer", 0);
	setprop("/services/fuel-truck/clean", 0);
	setprop("/services/fuel-truck/request-lbs", 0);
	
	# De-icing Truck
	
	setprop("/services/deicing_truck/enable", 0);
	setprop("/services/deicing_truck/de-ice", 0);
	
	# Set them all to 0 if the aircraft is not stationary
	
	if (getprop("/velocities/groundspeed-kt") > 10) {
		setprop("/services/chokes/nose", 0);
		setprop("/services/chokes/left", 0);
		setprop("/services/chokes/right", 0);
		setprop("/services/fuel-truck/enable", 0);
		setprop("/services/ext-pwr/enable", 0);
		setprop("/services/deicing_truck/enable", 0);
		setprop("/services/catering/enable", 0);
	}

	me.reset();
	},
	update : func {
	
		# Chokes and Parking Brakes Control
		
		# if ((getprop("/services/chokes/nose") == 1) or (getprop("/services/chokes/left") == 1) or (getprop("/services/chokes/right") == 1) or (getprop("/controls/parking-brake") == 1))
		#	setprop("/controls/gear/brake-parking", 1);
		# else
		#	setprop("/controls/gear/brake-parking", 0);
				
		# External Power Stuff
		
		if (getprop("/velocities/groundspeed-kt") > 10)
			setprop("/services/ext-pwr/enable", 0);
		
		if (getprop("/services/ext-pwr/enable") == 0)
			setprop("controls/electric/external-power", 0);
	
		# Catering Truck Controls
		
		var cater_pos = getprop("/sim/model/door-positions/cater_pos/position-norm");
		
		var scissor_deg = 3.325 * RAD2DEG * math.asin(cater_pos / (2 * 3.6512));
		
		setprop("/services/catering/scissor-deg", scissor_deg);
		
			
		# Fuel Truck Controls
		
#		if (getprop("/services/fuel-truck/enable") and getprop("/services/fuel-truck/connect")) {


		if ((getprop("services/fuel-truck/enable") == 1) and (getprop("services/fuel-truck/connect") == 1)) {
	
			if (getprop("/services/fuel-truck/transfer")) {
			
				if (getprop("consumables/fuel/total-fuel-lbs") < getprop("/services/fuel-truck/request-lbs")) {

					if (getprop("consumables/fuel/tank/level-lbs") < 9266) {

						setprop("/consumables/fuel/tank/level-lbs", getprop("/consumables/fuel/tank/level-lbs") + 30);
					}

					if (getprop("consumables/fuel/tank[1]/level-lbs") < 9266) {

						setprop("/consumables/fuel/tank[1]/level-lbs", getprop("/consumables/fuel/tank[1]/level-lbs") + 30);
					}

					if (getprop("consumables/fuel/tank[2]/level-lbs") < 20596) {

						setprop("/consumables/fuel/tank[2]/level-lbs", getprop("/consumables/fuel/tank[2]/level-lbs") + 30);

					}

									

				} else {
					setprop("/services/fuel-truck/transfer", 0);
					setprop("/consumables/fuel/tank/selected", 1);
					setprop("/consumables/fuel/tank[1]/selected", 1);
					setprop("/consumables/fuel/tank[2]/selected", 1);
					screen.log.write("All tanks ready... :)", 1, 1, 1);					
					screen.log.write("Re-fueling complete! Have a nice flight... :)", 1, 1, 1);
				}				


			}
			
			if (getprop("/services/fuel-truck/clean")) {
			
				if (getprop("consumables/fuel/total-fuel-lbs") > 90) {
				
					setprop("/consumables/fuel/tank/level-lbs", getprop("/consumables/fuel/tank/level-lbs") - 80);
					setprop("/consumables/fuel/tank[1]/level-lbs", getprop("/consumables/fuel/tank[1]/level-lbs") - 80);
					setprop("/consumables/fuel/tank[2]/level-lbs", getprop("/consumables/fuel/tank[2]/level-lbs") - 80);
				
				} else {
					setprop("/services/fuel-truck/clean", 0);
					screen.log.write("Finished draining the fuel tanks...", 1, 1, 1);
				}	
			
			}
		


			
		} else {	
			setprop("/services/fuel-truck/transfer", 0);
			setprop("/services/fuel-truck/clean", 0);


		}
		
		# De-icing Truck
		
		if (getprop("/services/deicing_truck/enable") and getprop("/services/deicing_truck/de-ice"))
		{
		
			if (me.ice_time == 2){
				door.move(1);
				print ("Lifting De-icing Crane...");
			}
			
			if (me.ice_time == 220){
				door3.move(1);
				print ("Starting De-icing Process...");
			}
			
			if (me.ice_time == 420){
				door3.move(0);
				print ("De-icing Process Completed...");
			}
				
			if (me.ice_time == 650){
				door.move(0);
				print ("Lowering De-icing Crane...");
			}
			
			if (me.ice_time == 900) {
				screen.log.write("De-icing Completed!", 1, 1, 1);
				setprop("/services/deicing_truck/de-ice", 0);
				setprop("/controls/ice/wing/temp", 30);
				setprop("/controls/ice/wing/eng1", 30);
				setprop("/controls/ice/wing/eng2", 30);
			}
		
		} else 
			me.ice_time = 0;
		
		
	me.ice_time += 1;
	
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

var toggle_parkingbrakes = func {

	if (getprop("/controls/parking-brake") == 1)
		setprop("/controls/parking-brake", 0);
	else	
		setprop("/controls/parking-brake", 1);	

}

setlistener("sim/signals/fdm-initialized", func {
	ground_services.init();
	print("Ground Services ... FINE!");
});
