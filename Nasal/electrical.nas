# 737-800 Electrical System
# Derived from the A380-Omega Electrical System 
# Jonathan Redpath
# Todo: bustie system

# Initialize Empty Vectors
var suppliers = [];
var buses = [];
var subbuses = [];

## Electrical Bus
var bus = {
	name: "",
	type: "",
	suppliers: [],
	get_volts: func() {
		me.volts = 0;
		foreach(var bus_supplier; me.suppliers) {
			foreach(var supplier; suppliers) {
				if (bus_supplier == supplier.name) {
					if(supplier.supply() != 0) {
						if (supplier.volts > me.volts) {
							me.volts = supplier.volts;
						}
					}
				}
			}
		}
		return me.volts;
	},
	get_amps: func() {
		me.amps = 0;
		foreach(var bus_supplier; me.suppliers) {
			foreach(var supplier; suppliers) {
				if (bus_supplier == supplier.name) {
					ampsx = supplier.supply();
					if (ampsx > me.amps) {
						me.amps = supplier.supply();
					}
				}
			}
		}
		return me.amps;
	},
	new: func(name, type, suppliers) {
		var t = {parents:[bus]};
		t.name = name;
		t.type = type;
		t.suppliers = suppliers;
		t.volts = 0;
		t.amps = 0;
		return t;
	}
};

var subbus = {
	name: "",
	type: "",
	subbussuppliers: [],
	get_volts: func() {
		me.volts = 0;
		foreach(var subbus_supply; me.subbussuppliers) {
			foreach(var bus; buses) {
				if (subbus_supply == bus.name) {
					if (bus.volts != me.volts) {
						me.volts = bus.volts;
					}
				}
			}
		}
		return me.volts;
	},
	get_amps: func() {
		me.amps = 0;
		foreach(var subbus_supply; me.subbussuppliers) {
			foreach(var bus; buses) {
				if (subbus_supply == bus.name) {
					if (bus.amps != me.amps) {
						me.amps = bus.amps;
					}
				}
			}
		}
		return me.amps;
	},
	new: func(name, type, subbussuppliers) {
		var t = {parents:[subbus]};
		t.name = name;
		t.type = type;
		t.subbussuppliers = subbussuppliers;
		t.volts = 0;
		t.amps = 0;
		return t;
	}
};

# Electrical Power Supplier
var supplier = {
	name: "",
	type: "",
	volts: 0,
	amps: 0,
	dep: 0,
	dep_prop: "",
	dep_max: 0,
	dep_req: 0,
	sw_prop: "",
	supply: func() {
		var amps = 0;
		if (getprop(me.sw_prop) != 0) {
			if (me.dep == 1) {
				var dep_val = getprop(me.dep_prop);
				if (dep_val > me.dep_req) {
					amps = (dep_val / me.dep_max) * me.amps;
				} 
			} else {
				amps = me.amps;
			}
		}
		return amps;
	},
	new: func(name, type, volts, amps, dep, dep_prop, dep_max, dep_req, sw_prop) {
		var t = {parents:[supplier]};
		t.name = name;
		t.type = type;
		t.volts = volts;
		t.amps = amps;
		t.dep = dep;
		t.dep_prop = dep_prop;
		t.dep_max = dep_max;
		t.dep_req = dep_req;
		t.sw_prop = sw_prop;
		return t;
	}
};

var electrical = {
       init : func {
            me.UPDATE_INTERVAL = 1;
            me.loopid = 0;
            
			# Create Electrical Systems (using suppliers, buses and outputs)
			
			# Create Suppliers
			
			suppliers = [supplier.new("eng1-gen", "AC", 115, 50, 1, "/engines/engine/n2", 100, 5, "/controls/electric/contact/engine_1"),
						supplier.new("eng2-gen", "AC", 115, 50, 1, "/engines/engine[1]/n2", 100, 5, "/controls/electric/contact/engine_2"),
						supplier.new("bat-1", "DC", 24, 16, 0, "/controls/electric/battery-switch", 1, 1, "/controls/electric/battery-switch"),
						supplier.new("bat-2", "DC", 24, 16, 0, "/controls/electric/battery-switch", 1, 1, "/controls/electric/battery-switch"),
						supplier.new("ext-pwr", "AC", 115, 50, 0, "services/ext-pwr/enable", 1, 1, "/controls/electric/contact/external"),
						supplier.new("apu-gen", "AC", 115, 50, 1, "/systems/apu/rpm", 100, 5, "/controls/electric/contact/apu_gen")];
			
			# Suppliers in a bus must supply similar voltages
			buses = [bus.new("ac-trans-bus-1", "AC", ["eng1-gen", "ext-pwr", "apu-gen", "eng2-gen"]),
					bus.new("ac-trans-bus-2", "AC", ["eng2-gen", "ext-pwr", "apu-gen", "eng1-gen"])];
					
			subbuses = [subbus.new("ac-bus-1", "AC", ["ac-trans-bus-1"]),
					subbus.new("ac-bus-2", "AC", ["ac-trans-bus-2"]),
					subbus.new("galley-bus-1", "AC", ["ac-trans-bus-1"]),
					subbus.new("galley-bus-2", "AC", ["ac-trans-bus-1"]),
					subbus.new("galley-bus-3", "AC", ["ac-trans-bus-2"]),
					subbus.new("galley-bus-4", "AC", ["ac-trans-bus-2"]),
					subbus.new("ground-bus-1", "AC", ["ac-trans-bus-1"]),
					subbus.new("ground-bus-2", "AC", ["ac-trans-bus-2"]),
					subbus.new("AC-stby-bus", "AC", ["ac-trans-bus-1"])];
								
            setprop("/systems/electric/util-volts", 0);
            
            setprop("/controls/elec_panel/dc-btc", 0);
            
            setprop("/controls/elec_panel/ac-btc", 0);
            me.reset();
    },
    	update : func {
    	
    	# Tie Objects to Properties
    	
    	foreach(var supply; suppliers) {
    		var amps = supply.supply();
    		var volts = 0;
    		if (amps != 0) {
    			volts = supply.volts;
    		}
    		setprop("/systems/electric/suppliers/" ~ supply.name ~ "/volts", volts);
    		setprop("/systems/electric/suppliers/" ~ supply.name ~ "/amps", amps);
    	}

    	foreach(var bus; buses) {
    		setprop("/systems/electric/elec-buses/" ~ bus.name ~ "/volts", bus.get_volts());
    		setprop("/systems/electric/elec-buses/" ~ bus.name ~ "/amps", bus.get_amps());
    		setprop("/systems/electric/elec-buses/" ~ bus.name ~ "/watts", bus.get_amps()*bus.get_volts()); # P = V*i
    	}
		
		foreach(var subbus; subbuses) {
    		setprop("/systems/electric/elec-buses/" ~ subbus.name ~ "/volts", subbus.get_volts());
    		setprop("/systems/electric/elec-buses/" ~ subbus.name ~ "/amps", subbus.get_amps());
    		setprop("/systems/electric/elec-buses/" ~ subbus.name ~ "/watts", subbus.get_amps()*subbus.get_volts()); # P = V*i
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

setlistener("sim/signals/fdm-initialized", func {
	electrical.init();
	setprop("/controls/electric/contact/external", 0); # ensure electrical system is off on startup
	setprop("/controls/electric/contact/apu_gen", 0);
	setprop("/controls/electric/contact/engine_1", 0);
	setprop("/controls/electric/contact/engine_2", 0);
	print("737-800 Electrical System Initialized");
});