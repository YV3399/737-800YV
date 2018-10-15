# Simulation of the Boeing 737-800 Warning System
# Copyright (c) 2018 Jonathan Redpath
# GNU GPL 2.0

###############################################################################
# Declare variables
###############################################################################

var storedWarnings = std.Vector.new();
var activeWarnings = std.Vector.new();
var fireWarnings = std.Vector.new();

var masterCaution = props.globals.initNode("/instrumentation/weu/outputs/master-caution-lamp", 0, "BOOL");
var fireWarning = props.globals.initNode("/instrumentation/weu/outputs/fire-warn-lamp", 0, "BOOL");

var fltContLamp = props.globals.initNode("/instrumentation/weu/outputs/flt-cont-lamp", 0, "BOOL");
var irsLamp = props.globals.initNode("/instrumentation/weu/outputs/irs-lamp", 0, "BOOL");
var fuelLamp = props.globals.initNode("/instrumentation/weu/outputs/fuel-lamp", 0, "BOOL");
var elecLamp = props.globals.initNode("/instrumentation/weu/outputs/elec-lamp", 0, "BOOL");
var apuLamp = props.globals.initNode("/instrumentation/weu/outputs/apu-lamp", 0, "BOOL");
var ovhtLamp = props.globals.initNode("/instrumentation/weu/outputs/ovht-lamp", 0, "BOOL");

var antiIceLamp = props.globals.initNode("/instrumentation/weu/outputs/anti-ice-lamp", 0, "BOOL");
var hydLamp = props.globals.initNode("/instrumentation/weu/outputs/hyd-lamp", 0, "BOOL");
var doorLamp = props.globals.initNode("/instrumentation/weu/outputs/door-lamp", 0, "BOOL");
var engLamp = props.globals.initNode("/instrumentation/weu/outputs/eng-lamp", 0, "BOOL");
var ovhdLamp = props.globals.initNode("/instrumentation/weu/outputs/ovhd-lamp", 0, "BOOL");
var airConLamp = props.globals.initNode("/instrumentation/weu/outputs/air-cond-lamp", 0, "BOOL");

var fltContCond = props.globals.initNode("/systems/weu/flt-cont-failed", 0, "BOOL");
var irsCond = props.globals.initNode("/systems/weu/irs-failed", 0, "BOOL");
var fuelCond = props.globals.getNode("/systems/weu/fuel-failed", 1); # init in jsb
var elecCond = props.globals.initNode("/systems/weu/elec-failed", 0, "BOOL");
var apuCond = props.globals.initNode("/systems/weu/apu-failed", 0, "BOOL");
var ovhtCond = props.globals.initNode("/systems/weu/ovht-failed", 0, "BOOL");

var antiIceCond = props.globals.initNode("/systems/weu/anti-ice-failed", 0, "BOOL");
var hydCond = props.globals.initNode("/systems/weu/hyd-failed", 0, "BOOL");
var doorCond = props.globals.initNode("/systems/weu/door-failed", 0, "BOOL");
var engCond = props.globals.initNode("/systems/weu/eng-failed", 0, "BOOL");
var ovhdCond = props.globals.initNode("/systems/weu/ovhd-failed", 0, "BOOL");
var airConCond = props.globals.initNode("/systems/weu/air-cond-failed", 0, "BOOL");

var engine1Fire = props.globals.initNode("/systems/weu/engine1-fire", 0, "BOOL");
var engine2Fire = props.globals.initNode("/systems/weu/engine2-fire", 0, "BOOL");
var apuFire = props.globals.initNode("/systems/weu/apu-fire", 0, "BOOL");
var gearFire = props.globals.initNode("/systems/weu/gear-fire", 0, "BOOL");
var cargoFire = props.globals.initNode("/systems/weu/cargo-fire", 0, "BOOL");

###############################################################################
# main warnings class
###############################################################################

var warnings = {
    init: func() {
        warningsLoop.start();
    },

    update: func() {
        if (activeWarnings.size() != 0) { 
            foreach(var k; activeWarnings.vector) {
                setprop("/instrumentation/weu/outputs/" ~ k ~ "-lamp", 1);
            }
            masterCaution.setBoolValue(1);
        }
        
        if (fireWarnings.size() != 0) {
            fireWarning.setBoolValue(1);
        }
    },
    
    toggleLamps: func(n) {
        if (n < 0 or int(n) == nil) {return;} else {n = int(n);} # sanity check for n

        fltContLamp.setBoolValue(n);
        irsLamp.setBoolValue(n);
        fuelLamp.setBoolValue(n);
        elecLamp.setBoolValue(n);
        apuLamp.setBoolValue(n);
        ovhtLamp.setBoolValue(n);

        antiIceLamp.setBoolValue(n);
        hydLamp.setBoolValue(n);
        doorLamp.setBoolValue(n);
        engLamp.setBoolValue(n);
        ovhdLamp.setBoolValue(n);
        airConLamp.setBoolValue(n);
    },
    
    cautionBtn: func() {
        foreach(var i; activeWarnings.vector) {
            storedWarnings.append(i);
            activeWarnings.remove(i);
            setprop("/instrumentation/weu/outputs/" ~ i ~ "-lamp", 0);
        }

        masterCaution.setBoolValue(0);
    },

    fireBtn: func() {
        if (fireWarnings.size() > 0) {
            foreach(var j; fireWarnings.vector) {
                fireWarnings.remove(j);
            }
        }
        
        fireWarning.setBoolValue(0);
    },

    recallBtn: func() {
        if (storedWarnings.size() == 0 and activeWarnings.size() == 0) {
            warnings.toggleLamps(1);
        } elsif (storedWarnings.size() > 0) {
            foreach(var k; storedWarnings.vector) {
                activeWarnings.append(k);
                setprop("/instrumentation/weu/outputs/" ~ k ~ "-lamp", 1);
                storedWarnings.remove(k);
            }
        }
    },

    recallOff: func() {
        if (storedWarnings.size() == 0 and activeWarnings.size() == 0) {
            warnings.toggleLamps(0);
        }
    }

};

###############################################################################
# helper functions for listeners
###############################################################################
var createFailedListener = func(system) {
    setlistener("/systems/weu/" ~ system ~ "-failed", func {
        if (getprop("/systems/weu/" ~ system ~ "-failed") == 1) {
            activeWarnings.append(system);
        } elsif (storedWarnings.contains(system) == 1 and getprop("/systems/weu/" ~ system ~ "-failed") == 0) {
            storedWarnings.remove(system);
        }
    }, 0, 0);
}

var createFireListener = func(object) {
    setlistener("/systems/weu/" ~ object ~ "-fire", func {
        if (getprop("/systems/weu/" ~ object ~ "-fire") == 1) {
            fireWarnings.append(object);
        }
    }, 0, 0);
}

###############################################################################
# listeners to enable warnings
###############################################################################
createFailedListener("flt-cont");
createFailedListener("irs");
createFailedListener("elec");
createFailedListener("fuel");
createFailedListener("apu");
createFailedListener("ovht");
createFailedListener("anti-ice");
createFailedListener("hyd");
createFailedListener("door");
createFailedListener("eng");
createFailedListener("ovhd");
createFailedListener("air-cond");

createFireListener("engine1");
createFireListener("engine2");
createFireListener("apu");
createFireListener("cargo");
createFireListener("gear");

###############################################################################
# Init and start loop
###############################################################################

var warningsLoop = maketimer(0.25, warnings.update);

warnings.init();

###############################################################################
# Custom fg-commands for hardware
###############################################################################

addcommand("weu-caution-button", warnings.cautionBtn);
addcommand("weu-fire-button", warnings.fireBtn);
addcommand("weu-recall-button", warnings.recallBtn);
addcommand("weu-recall-button-off", warnings.recallOff);