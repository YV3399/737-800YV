# 737-800 Pneumatic System

# Initialize Empty Vectors
var airsources = [];
var packs = [];

## Electrical Bus
var packs = {
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
            
			buses = [bus.new("ac-trans-bus-1", "AC", ["eng1-gen", "ext-pwr", "apu-gen", "eng2-gen"]),
					bus.new("ac-trans-bus-2", "AC", ["eng2-gen", "ext-pwr", "apu-gen", "eng1-gen"])];
					
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