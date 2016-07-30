# MD-88
#
# Engine support routines
#
# Gary Neely aka 'Buckaroo'
# Modified by Joshua Davidson (it0uchpods)
#
# Functionality notes not yet copied here. If interested in details, nag me.
#



var ENG_WM_UPDATE	= 5;						# Update interval in secs
var ENG_OFF_UPDATE	= 5;
var ENG_RUN_UPDATE	= 0;
var ENG_MONITOR_UPDATE	= 1;
var MAX_N1		= 99.2;
var MAX_N2		= 102.5;
#var MIN_PSI		# Defined in pneumatic system
#var pneu_psi		# Defined in pneumatic system
var N1_MOTORING		= 10;
var N2_MOTORING		= 20;
var N1_IDLE		= 19.7;
var N2_IDLE		= 50;
var MOTORING_TRANS	= 10;						# Not sure about this one
var IDLE_TRANS		= 20;						# Might be reasonable. Don't exceed 40
var SHUTDOWN_TRANS	= 40;						# Worst-case, actual time will be much less

									# Other property handles:
var engines		= props.globals.getNode("/engines").getChildren("engine");
var sw_start		= props.globals.getNode("/controls/switches").getChildren("eng-start");
var sw_ign		= props.globals.getNode("/controls/switches/eng-ign");
var cutoffs		= props.globals.getNode("/controls/engines").getChildren("engine");
var bleeds		= props.globals.getNode("/controls/pneumatic").getChildren("engine");
#var sw_ign		# Defined in fuel system
#var fuelpress		# Defined in fuel system
#var airspeed		# Defined in flightsurfaces system
									# For testing:
#var n1_wm		= props.globals.getNode("/systems/engines/n1-windmill");
#var n2_wm		= props.globals.getNode("/systems/engines/n2-windmill");


									# Windmilling: engine-off min n1/n2 based on airspeed:
									# N1 will block much of the airflow to N2, so will be higher.
									# Approximations based on info from other engines:
									#   150 kts n1=10, n2=0
									#   260 kts n1=18, n2=15
									# JT8D probably less than these given the relatively small
									# n1 area, but it doesn't matter much
									# Update casually, these aren't critical
var n1_windmill		= 0;
var n2_windmill		= 0;

var windmill_loop = func {
  var as = airspeed.getValue();
  if (as > 260) { as = 260; }						# Max windmilling
  n1_windmill = 18 * as/260;						# N1 windmilling
  if (as <= 150)	{ n2_windmill = 0; }				# N2 bottoms out at or under 150 kts
  else			{ n2_windmill = 15 * (as-150)/110; }
  #n1_wm.setValue(n1_windmill);						# For testing
  #n2_wm.setValue(n2_windmill);

  settimer(windmill_loop, ENG_WM_UPDATE);
}

settimer(windmill_loop, 2);						# Give a few seconds for vars to initialize



									# State 0 - Engine off
									# While in state 0, loop casually to update
									# n1, n2 to windmilling conditions
var eng0_off_loop = func {
  if (engines[0].getNode("state").getValue()>0) {			# Quit updating if no longer in this state
    return 0;
  }
  engines[0].getNode("n1-actual").setValue(n1_windmill);
  engines[0].getNode("n2-actual").setValue(n2_windmill);

  settimer(eng0_off_loop, ENG_OFF_UPDATE);
}
var eng1_off_loop = func {
  if (engines[1].getNode("state").getValue()>0) {
    return 0;
  }
  engines[1].getNode("n1-actual").setValue(n1_windmill);
  engines[1].getNode("n2-actual").setValue(n2_windmill);

  settimer(eng1_off_loop, ENG_OFF_UPDATE);
}


									# State 1 - Startup stage 1
									# Triggered by start switch set to 1
var eng_startup_1 = func(i) {
  if (!sw_start[i].getNode("position").getValue()) { return 0; }	# Startup not on
									# If oof & good PSI & bleed on:
  if (engines[i].getNode("out-of-fuel").getValue() and
      pneu_psi.getValue() >= MIN_PSI and
      bleeds[i].getNode("bleed").getValue()) {

    engines[i].getNode("state").setValue(1);				# Put engine in startup stage 1 state				
									# Interpolate n1, n2 to motoring speeds
    interpolate(engines[i].getNode("n1-actual"), N1_MOTORING, (N1_MOTORING - engines[i].getNode("n1-actual").getValue())/N1_MOTORING * MOTORING_TRANS);
    interpolate(engines[i].getNode("n2-actual"), N2_MOTORING, (N2_MOTORING - engines[i].getNode("n2-actual").getValue())/N2_MOTORING * MOTORING_TRANS);
  }
}


									# State 2 - Startup stage 2
									# Triggered by opened fuel cutoff valve
var eng_startup_2= func(i) {
  if (cutoffs[i].getNode("cutoff").getValue()) { return 0; }		# Fuel cutoff not opened
  if (engines[i].getNode("state").getValue() != 1) { return 0; }	# Not in startup stage 1 state
									# Don't want !oof yet, as that would have the engine running
									# If oof & good PSI & start on & bleed on & good pressure &ignition on:
  if (engines[i].getNode("out-of-fuel").getValue() and
      pneu_psi.getValue() >= MIN_PSI and
      sw_start[i].getNode("position").getValue() and
      bleeds[i].getNode("bleed").getValue() and
      fuelpress[i] and
      sw_ign.getValue()) {

    engines[i].getNode("state").setValue(2);				# Go to stage 2
									# Interpolate n1, n2 to idle speeds
    interpolate(engines[i].getNode("n1-actual"), N1_IDLE, (N1_IDLE - engines[i].getNode("n1-actual").getValue())/N1_IDLE * IDLE_TRANS);
    interpolate(engines[i].getNode("n2-actual"), N2_IDLE, (N2_IDLE - engines[i].getNode("n2-actual").getValue())/N2_IDLE * IDLE_TRANS);

    									# Setup watch on engine to monitor n2;
    if (i == 0) { settimer(eng0_startup_monitor, ENG_MONITOR_UPDATE); }
    else	{ settimer(eng1_startup_monitor, ENG_MONITOR_UPDATE); }
  }
}


var eng0_startup_monitor = func {
  if (engines[0].getNode("n2-actual").getValue()>=N2_IDLE) {		# When n2 hits idle speed:
    engines[0].getNode("out-of-fuel").setBoolValue(0);			# Setting oof to false 'starts' FDM's engine
    engines[0].getNode("state").setValue(3);				# Put engine in running state				
    sw_start[0].getNode("position").setValue(0);			# Reset start switch
    settimer(eng0_run_loop,1);						# Begin run-state monitor
    return 0;								# Exit startup monitor
  }
  settimer(eng0_startup_monitor, ENG_MONITOR_UPDATE);
}
var eng1_startup_monitor = func {
  if (engines[1].getNode("n2-actual").getValue()>=N2_IDLE) {		# When n2 hits idle speed:
    engines[1].getNode("out-of-fuel").setBoolValue(0);			# Setting oof to false 'starts' FDM's engine
    engines[1].getNode("state").setValue(3);				# Put engine in running state				
    sw_start[1].getNode("position").setValue(0);			# Reset start switch
    settimer(eng1_run_loop,1);						# Begin run-state monitor
    return 0;								# Exit startup monitor
  }
  settimer(eng1_startup_monitor, ENG_MONITOR_UPDATE);
}



									# State 3 - Running
									# While in state 3, loop briskly to update n1, n2 from FDM
var eng0_run_loop = func {
  var e = engines[0];
  if (e.getNode("out-of-fuel").getValue()) {				# Quit updating if no longer in this state
    e.getNode("state").setValue(4);					# Put engine in shutdown state				
    settimer(eng0_shutdown,1);						# Begin shutdown sequence
    return 0;
  }
  e.getNode("n1-actual").setValue(e.getNode("n1").getValue());
  e.getNode("n2-actual").setValue(e.getNode("n2").getValue());

  settimer(eng0_run_loop, ENG_RUN_UPDATE);
}
var eng1_run_loop = func {
  var e = engines[1];
  if (e.getNode("out-of-fuel").getValue()) {				# Quit updating if no longer in this state
    e.getNode("state").setValue(4);					# Put engine in shutdown state				
    settimer(eng1_shutdown,1);						# Begin shutdown sequence
    return 0;
  }
  e.getNode("n1-actual").setValue(e.getNode("n1").getValue());
  e.getNode("n2-actual").setValue(e.getNode("n2").getValue());

  settimer(eng1_run_loop, ENG_RUN_UPDATE);
}




									# State 4 - Shutdown sequence
									# Use n2 to dictate spool-down time
									# as it will likely take longer
var eng0_shutdown = func {
  var shutdown_time = (engines[0].getNode("n2-actual").getValue() - n2_windmill)/MAX_N2 * SHUTDOWN_TRANS;
  interpolate(engines[0].getNode("n1-actual"), n1_windmill, shutdown_time);
  interpolate(engines[0].getNode("n2-actual"), n2_windmill, shutdown_time);

  settimer(eng0_shutdown_monitor, shutdown_time);			# Allow time to spool down, then state=off
}
var eng1_shutdown = func {
  var shutdown_time = (engines[1].getNode("n2-actual").getValue() - n2_windmill)/MAX_N2 * SHUTDOWN_TRANS;
  interpolate(engines[1].getNode("n1-actual"), n1_windmill, shutdown_time);
  interpolate(engines[1].getNode("n2-actual"), n2_windmill, shutdown_time);

  settimer(eng1_shutdown_monitor, shutdown_time);			# Allow time to spool down, then state=off

}


var eng0_shutdown_monitor = func {
  engines[0].getNode("state").setValue(0);				# Put engine in off state				
  settimer(eng0_off_loop, 1);						# Startup off state sequence
}
var eng1_shutdown_monitor = func {
  engines[1].getNode("state").setValue(0);				# Put engine in off state				
  settimer(eng1_off_loop, 1);						# Startup off state sequence
}


									# FDM throttle value is scaled higher than
									# control value to give proper idle setting.
									# On any control change, update FDM throttle.

var throttle0		= props.globals.getNode("controls/engines/engine[0]/throttle");
var throttle0_fdm	= props.globals.getNode("controls/engines/engine[0]/throttle-fdm");
var throttle1		= props.globals.getNode("controls/engines/engine[1]/throttle");
var throttle1_fdm	= props.globals.getNode("controls/engines/engine[1]/throttle-fdm");


setlistener("controls/engines/engine[0]/throttle", func {
  throttle0_fdm.setValue(throttle0.getValue()*0.93+0.07);
});
setlistener("controls/engines/engine[1]/throttle", func {
  throttle1_fdm.setValue(throttle1.getValue()*0.93+0.07);
});


var eng_magicstartup = func {
  setprop("/controls/switches/battery",1);
  sw_ign.setValue(1);
  setprop("/controls/switches/pumpLaft",1);
  setprop("/controls/switches/pumpLfwd",1);
  setprop("/controls/switches/pumpRaft",1);
  setprop("/controls/switches/pumpRfwd",1);
  setprop("/controls/switches/pumpCaft",1);
  setprop("/controls/switches/pumpCfwd",1);
  fuelpress[0] = 1;
  fuelpress[1] = 1;
  fuelpress[2] = 1;
  setprop("/engines/engine[0]/state",3);
  setprop("/engines/engine[1]/state",3);
  setprop("/engines/engine[0]/out-of-fuel",0);
  setprop("/engines/engine[1]/out-of-fuel",0);
  setprop("/controls/engines/engine[0]/cutoff",0);
  setprop("/controls/engines/engine[1]/cutoff",0);
  setprop("/controls/fuel/xfeed",0);
  settimer(eng0_run_loop, ENG_RUN_UPDATE);
  settimer(eng1_run_loop, ENG_RUN_UPDATE);
}

var eng_magicshutdown = func {
  setprop("/engines/engine[0]/state",4);
  setprop("/engines/engine[1]/state",4);
  setprop("/controls/engines/engine[0]/cutoff",1);
  setprop("/controls/engines/engine[1]/cutoff",1);
  setprop("/controls/switches/pumpLaft",0);
  setprop("/controls/switches/pumpLfwd",0);
  setprop("/controls/switches/pumpRaft",0);
  setprop("/controls/switches/pumpRfwd",0);
  setprop("/controls/switches/pumpCaft",0);
  setprop("/controls/switches/pumpCfwd",0);
  setprop("/engines/engine[0]/out-of-fuel",0);
  setprop("/engines/engine[1]/out-of-fuel",0);
  setprop("/controls/fuel/xfeed",0);
  sw_ign.setValue(0);
  setprop("/controls/switches/battery",0);
}

var eng_more0 = func {
  settimer(eng0_run_loop, ENG_RUN_UPDATE);
}

var eng_more1 = func {
  settimer(eng1_run_loop, ENG_RUN_UPDATE);
}


