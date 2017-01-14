# 737-800 
#By Gabriel Hernandez(YV3399) and Legoboyvdlp


setlistener("/sim/signals/fdm-initialized", func {
print("Lighting System: Initializing, please wait");


var beacon = aircraft.light.new( "/sim/model/lights/beacon", [0,2, ], "/controls/lighting/beacon" );
var strobe = aircraft.light.new( "/sim/model/lights/strobe", [0,2, ], "/controls/lighting/strobe" );

strobe_switch = props.globals.getNode("controls/switches/strobe", 1);
beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);

setprop("/controls/lighting/strobe",0);
setprop("/controls/lighting/beacon",0);
setprop("/controls/lighting/landing-lights",0);
setprop("/controls/lighting/logo-lights",0);
setprop("/controls/lighting/nav-lights",0);

print("lighting OK");

});

if (getprop("controls/lighting/landing-lights")) {
setprop("sim/rendering/als-secondary-lights/use-landing-light",1);
setprop("sim/rendering/als-secondary-lights/use-alt-landing-light",1);
} else {
setprop("sim/rendering/als-secondary-lights/use-landing-light",0);
setprop("sim/rendering/als-secondary-lights/use-alt-landing-light",0);
}

