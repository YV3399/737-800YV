# AUTOPUSH
# Basic pushback logic class.
#
# Copyright (c) 2018 Autopush authors:
#  Michael Danilov <mike.d.ft402 -eh- gmail.com>
#  Joshua Davidson http://github.com/it0uchpods
#  Merspieler http://gitlab.com/merspieler
# Distribute under the terms of GPLv2.


var _enabled = 0;
var _K_p = nil;
var _F_p = nil;
var _K_i = nil;
var _F_i = nil;
var _K_d = nil;
var _F_d = nil;
var _F = nil;
var _int = nil;
var _deltaV = nil;
var _T_f = nil;
var _K_yaw = nil;
var _yasim = 0;
var _time = nil;
# (ft / s^2) / ((km / h) / s)
var _unitconv = M2FT / 3.6;
var _debug = nil;

var _loop = func() {
	if (!getprop("/sim/model/pushback/available")) {
		_stop();
		return;
	}
	var force = 0.0;
	var x = 0.0;
	var y = 0.0;
	# Rollspeed is only adequate if the wheel is touching the ground.
	if (getprop("/gear/gear[0]/wow")) {
		var deltaV = getprop("/sim/model/pushback/target-speed-km_h");
		deltaV -= getprop("/gear/gear[0]/rollspeed-ms") * 3.6;
		var dV = deltaV - _deltaV;
		var time = getprop("/sim/time/elapsed-sec");
		var prop = math.min(math.max(_K_p * deltaV, -_F_p), _F_p);
		var speedup = getprop("/sim/speed-up");
		dt = time - _time;
		# XXX Sanitising dt. Smaller chance of freakout on lag spike.
		if(dt > 0.0) {
			if(dt < 0.05) {
				_int = math.min(math.max(_int + _K_i * dV * dt, -_F_i), _F_i);
			}
			if(dt > 0.002) {
				var deriv = math.min(math.max(_K_d * dV / dt, -_F_d), _F_d);
			}
		}
		var accel = prop + _int + deriv;
		if (_debug > 2) {
			print("pushback prop " ~ prop ~ ", _int " ~ _int ~ ", deriv " ~ deriv);
		}
		_deltaV = deltaV;
		_time = time;
		if (!_yasim) {
			force = accel * getprop("/fdm/jsbsim/inertia/weight-lbs") * _unitconv;
		} else {
			force = accel * getprop("/fdm/yasim/gross-weight-lbs") * _unitconv;
		}
		var yaw = getprop("/sim/model/pushback/yaw") * _K_yaw;
		x = math.cos(yaw);
		y = math.sin(yaw);
		setprop("/sim/model/pushback/force-x", x);
		setprop("/sim/model/pushback/force-y", y);
	}
	setprop("/sim/model/pushback/force-lbf", force);
	if (_yasim) {
		# The force is divided by YASim thrust="100000.0" setting.
		setprop("/sim/model/pushback/force-x-yasim", x * force * 0.00001);
		# YASim's y is to the left.
		setprop("/sim/model/pushback/force-y-yasim", -y * force * 0.00001);
	}
}

var _timer = maketimer(0.0167, func{_loop()});

var _start = func() {
	# Else overwritten by dialog.
	settimer(func() {
		setprop("/sim/model/pushback/target-speed-km_h", 0.0)
	}, 0.1);
	_K_p = getprop("/sim/model/pushback/K_p");
	_F_p = getprop("/sim/model/pushback/F_p");
	_K_i = getprop("/sim/model/pushback/K_i");
	_F_i = getprop("/sim/model/pushback/F_i");
	_K_d = getprop("/sim/model/pushback/K_d");
	_F_d = getprop("/sim/model/pushback/F_d");
	_F = getprop("/sim/model/pushback/F");
	_T_f = getprop("/sim/model/pushback/T_f");
	_K_yaw = getprop("/sim/model/pushback/yaw-mult") * D2R;
	_yasim = (getprop("/sim/flight-model") == "yasim");
	_debug = getprop("/sim/model/pushback/debug") or 0;
	_int = 0.0;
	_deltaV = 0.0;
	_time = getprop("/sim/time/elapsed-sec");
	setprop("/sim/model/pushback/connected", 1);
	if (!_timer.isRunning) {
		if (getprop("/sim/model/pushback/chocks")) {
			setprop("/sim/model/pushback/chocks", 0);
			screen.log.write("(pushback): Pushback connected, chocks removed. Please release brakes.");
		} else {
			screen.log.write("(pushback): Pushback connected, please release brakes.");
		}
	}
	_timer.start();
}

var _stop = func() {
	if (_timer.isRunning) {
		screen.log.write("(pushback): Pushback and bypass pin removed.");
	}
	_timer.stop();
	setprop("/sim/model/pushback/force-lbf", 0.0);
	if (_yasim) {
		setprop("/sim/model/pushback/force-x-yasim", 0.0);
		setprop("/sim/model/pushback/force-y-yasim", 0.0);
	}
	setprop("/sim/model/pushback/connected", 0);
	setprop("/sim/model/pushback/enabled", 0);
}

setlistener("/sim/model/pushback/enabled", func(p) {
	var enabled = p.getValue();
	if ((enabled > _enabled) and getprop("/sim/model/pushback/available")) {
		_start();
	} else if (enabled < _enabled) {
		_stop();
	}
	_enabled = enabled;
});
