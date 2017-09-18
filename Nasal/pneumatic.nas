# 737-800 Pneumatic System

# Initialize Empty Vectors
var buses = [];

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

var electrical = {
       init : func {
            me.UPDATE_INTERVAL = 1;
            me.loopid = 0;
            
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
            me.reset();
    },
    	update : func {

    	foreach(var bus; buses) {
    		setprop("/systems/electric/elec-buses/" ~ bus.name ~ "/volts", bus.get_volts());
    		setprop("/systems/electric/elec-buses/" ~ bus.name ~ "/amps", bus.get_amps());
    		setprop("/systems/electric/elec-buses/" ~ bus.name ~ "/watts", bus.get_amps()*bus.get_volts()); # P = V*i
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
	pneumatic.init();
	print("737-800 Pneumatic System Initialized");
});