strobe_switch = props.globals.getNode("controls/switches/strobe", 1);
var beacon = aircraft.light.new( "/sim/model/lights/beacon", [0, 3], "/controls/lighting/beacon" );

beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
var strobe = aircraft.light.new( "/sim/model/lights/strobe", [0, 3,], "/controls/lighting/strobe" );
print("lighting OK");


