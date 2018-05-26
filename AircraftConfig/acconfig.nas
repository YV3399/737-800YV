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
setprop("/systems/acconfig/options/welcome-skip", 0);
setprop("/systems/acconfig/options/yokes-visible", 0);
setprop("/systems/acconfig/options/increase-fps", 0);
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
	readSettings();
	if (getprop("/systems/acconfig/options/welcome-skip") != 1) {
		welcome_dlg.open();
	}
	writeSettings();
	spinning.stop();
});

var readSettings = func {
	io.read_properties(getprop("/sim/fg-home") ~ "/Export/737-800YV-config.xml", "/systems/acconfig/options");
	setprop("/sim/yokes-visible", getprop("/systems/acconfig/options/yokes-visible"));
	setprop("/controls/switches/increase-fps", getprop("/systems/acconfig/options/increase-fps"));
}

var writeSettings = func {
	setprop("/systems/acconfig/options/yokes-visible", getprop("/sim/yokes-visible"));
	setprop("/systems/acconfig/options/increase-fps", getprop("/controls/switches/increase-fps"));
	io.write_properties(getprop("/sim/fg-home") ~ "/Export/737-800YV-config.xml", "/systems/acconfig/options");
}

var systemsReset = func { # Not used yet, for panel states when implemented
}
