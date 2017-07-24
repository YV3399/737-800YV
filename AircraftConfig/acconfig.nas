# Aircraft Config Center
# Joshua Davidson (it0uchpods)

var spinning = maketimer(0.05, func {
	var spinning = getprop("/systems/acconfig/spinning");
	if (spinning == 0) {
		setprop("/systems/acconfig/spin", "\\");
		setprop("/systems/acconfig/spinning", 1);
	} else if (spinning == 1) {
		setprop("/systems/acconfig/spin", "|");
		setprop("/systems/acconfig/spinning", 2);
	} else if (spinning == 2) {
		setprop("/systems/acconfig/spin", "/");
		setprop("/systems/acconfig/spinning", 3);
	} else if (spinning == 3) {
		setprop("/systems/acconfig/spin", "-");
		setprop("/systems/acconfig/spinning", 0);
	}
});

setprop("/systems/acconfig/autoconfig-running", 0);
setprop("/systems/acconfig/spinning", 0);
setprop("/systems/acconfig/spin", "-");
var main_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/main/dialog", "Aircraft/737-800YV/AircraftConfig/main.xml");
var welcome_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/welcome/dialog", "Aircraft/737-800YV/AircraftConfig/welcome.xml");
var ps_load_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/psload/dialog", "Aircraft/737-800YV/AircraftConfig/psload.xml");
var ps_loaded_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/psloaded/dialog", "Aircraft/737-800YV/AircraftConfig/psloaded.xml");
var init_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/init/dialog", "Aircraft/737-800YV/AircraftConfig/ac_init.xml");
var help_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/help/dialog", "Aircraft/737-800YV/AircraftConfig/help.xml");
var fctl_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/fctl/dialog", "Aircraft/737-800YV/AircraftConfig/fctl.xml");
var announcements_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/announcements/dialog", "Aircraft/737-800YV/AircraftConfig/announcements.xml");
var lights_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/lights/dialog", "Aircraft/737-800YV/AircraftConfig/lights.xml");
var fuel_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/fuel/dialog", "Aircraft/737-800YV/AircraftConfig/fuel.xml");
var fail_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/fail/dialog", "Aircraft/737-800YV/AircraftConfig/fail.xml");
spinning.start();
init_dlg.open();

setlistener("/sim/signals/fdm-initialized", func {
	init_dlg.close();
	welcome_dlg.open();
	spinning.stop();
});

var saveSettings = func {
	aircraft.data.add("/sim/yokes-visible", "/controls/switches/increase-fps");
	aircraft.data.save();
}

saveSettings();

var systemsReset = func { # Not used yet, for panel states when implemented
	systems.elec_init();
	systems.hyd_init();
  	itaf.ap_init();
  	setprop("/it-autoflight/input/spd-kts", 100);
	setprop("/it-autoflight/input/bank-limit-sw", 6);
}
