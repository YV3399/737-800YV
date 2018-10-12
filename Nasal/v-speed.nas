# Simulation of the Boeing 737-800 V-Speed System
# Copyright (c) 2018 Jonathan Redpath
# GNU GPL 2.0

###############################################################################
# Declare variables
###############################################################################

var vSpeedBug = props.globals.initNode("/controls/fmc/v-speed-bug", 100, "DOUBLE");
var vSpeedSelectorMode = props.globals.initNode("/controls/fmc/v-speed-mode", 0, "DOUBLE");
var vSpeedSelectorModeText = props.globals.initNode("/controls/fmc/v-speed-mode-text", "AUTO", "STRING");
var vSpeedSelectorPFDText = props.globals.initNode("/controls/fmc/v-speed-pfd-text", "AUTO", "STRING");

var v1Speed = props.globals.initNode("/instrumentation/fmc/speeds/v1-kt", 0, "DOUBLE");
var vrSpeed = props.globals.initNode("/instrumentation/fmc/speeds/vr-kt", 0, "DOUBLE");
var vrefSpeed = props.globals.initNode("/instrumentation/fmc/speeds/vref-kt", 0, "DOUBLE");
var whiteBugSpeed = props.globals.initNode("/instrumentation/fmc/speeds/white-bug-kt", 0, "DOUBLE");
var gWeight = props.globals.initNode("/instrumentation/fmc/weights/gw", 0, "DOUBLE");

var airground = props.globals.getNode("/b737/sensors/air-ground", 1);
var setFlag = props.globals.initNode("/instrumentation/fmc/speeds/vspeeds-man-set", 0);

###############################################################################
# main v speed class
###############################################################################

var vspeed = {
    init: func() {
		me.v1 = 0;
		me.vr = 0;
		me.wt = 0;
		me.vref = 0;
    },

    modeKnob: func() {
		mode = vSpeedSelectorMode.getValue();
		airgnd = airground.getValue();
		bug = vSpeedBug.getValue();
		
		if (mode == 0) {
			setFlag.setBoolValue(0);
			vSpeedSelectorModeText.setValue("AUTO"); # when setting in cdu is simulated, remove the below setValue()s
			v1Speed.setValue(0);
			vrSpeed.setValue(0);
			vrefSpeed.setValue(0);
			gWeight.setValue(0);
			whiteBugSpeed.setValue(0);
			return;
		} 
		
		if (mode == 1) {
			if (airgnd == 1) {
				vSpeedSelectorModeText.setValue("V1");
				vSpeedSelectorPFDText.setValue(bug);
			} else {
				vSpeedSelectorModeText.setValue("INVALID ENTRY");
				vSpeedSelectorPFDText.setValue(999);
			}
		} elsif (mode == 2) {
			if (airgnd == 1) {
				vSpeedSelectorModeText.setValue("VR");
				vSpeedSelectorPFDText.setValue(bug);
			} else {
				vSpeedSelectorModeText.setValue("INVALID ENTRY");
				vSpeedSelectorPFDText.setValue(999);
			}
		} elsif (mode == 3) {
			vSpeedSelectorModeText.setValue("WT");
				vSpeedSelectorPFDText.setValue(bug*500);
		} elsif (mode == 4) {
			if (airgnd == 0) {
				vSpeedSelectorModeText.setValue("VREF");
				vSpeedSelectorPFDText.setValue(bug);
			} else {
				vSpeedSelectorModeText.setValue("INVALID ENTRY");
				vSpeedSelectorPFDText.setValue(999);
			}
		} elsif (mode == 5) {
			vSpeedSelectorModeText.setValue(""); # no display of speed, just the bug moves as far as I know
			vSpeedSelectorPFDText.setValue("");
			# whiteBug = vSpeedBug.getValue(); # temporarily disabled until I can fix the PFD display of the white bug
			# whiteBugSpeed.setValue(whiteBug);
		} elsif (mode == 6) {
			vSpeedSelectorModeText.setValue("SET");
			if (me.v1 != nil) {
				v1Speed.setValue(me.v1);
			}
			if (me.vr != nil) {
				vrSpeed.setValue(me.vr);
			}
			if (me.vref != nil) {
				vrefSpeed.setValue(me.vref);
			}
			gWeight.setValue(me.wt);
			setFlag.setBoolValue(1);
		}
    },
	
	speedKnob: func() {
		mode = vSpeedSelectorMode.getValue();
		airgnd = airground.getValue();
		bug = vSpeedBug.getValue();
		if (mode == 0 or mode == 6) {return;}
		
		if (mode == 1 and airgnd == 1) {
			me.v1 = bug;
			vSpeedSelectorPFDText.setValue(me.v1);
		} elsif (mode == 2 and airgnd == 1) {
			me.vr = bug;
			vSpeedSelectorPFDText.setValue(me.vr);
		} elsif (mode == 3) {
			wtRaw = bug;
			me.wt = wtRaw * 500;
			vSpeedSelectorPFDText.setValue(me.wt);
		} elsif (mode == 4 and airgnd == 0) {
			me.vref = bug;
			vSpeedSelectorPFDText.setValue(me.vref);
		}
	},
};

###############################################################################
# Listeners
###############################################################################
setlistener("/controls/fmc/v-speed-mode", func {
	vspeed.modeKnob();
}, 0, 0);

setlistener("/controls/fmc/v-speed-bug", func {
	vspeed.speedKnob();
}, 0, 0);

###############################################################################
# Init
###############################################################################
vspeed.init();