# AUTOPUSH
# Pushback driver class.
#
# Command the pushback to tow/push the aircraft.
#
# Copyright (c) 2018 Autopush authors:
#  Michael Danilov <mike.d.ft402 -eh- gmail.com>
#  Joshua Davidson http://github.com/it0uchpods
#  Merspieler http://gitlab.com/merspieler
# Distribute under the terms of GPLv2.


var _K_V = nil;
var _F_V = nil;
var _D_min = nil;
var _K_psi = nil;
var _debug = nil;

var _route = nil;
var _push = nil;
var _sign = nil;
var _psi_park = nil;

var _to_wp = nil;


var _loop = func() {
	if (!getprop("/sim/model/pushback/connected")) {
		stop();
		return;
	}
	var psi = getprop("/orientation/heading-deg") + _push * 180.0;
	var (A, D) = courseAndDistance(_route[_to_wp]);
	D *= NM2M;
	# FIXME Use _K_V and total remaining distance.
	var V = _F_V;
	if ((D < _D_min) or (abs(geo.normdeg180(A - psi) > 90.0))) {
		_to_wp += 1;
		if (_to_wp == size(_route)) {
			_done();
			autopush_route.clear();
			return;
		}
		if (_debug) {
			print("pushback_driver wp " ~ _to_wp);
		}
	}
	if (_debug > 1) {
		print("pushback_driver psi_target " ~ geo.normdeg(A) ~ ", deltapsi " ~ _sign * geo.normdeg180(A - psi));
	}
	setprop("/sim/model/pushback/target-speed-km_h", _sign * V);
	steering = math.min(math.max(_sign * _K_psi * geo.normdeg180(A - psi), -1.0), 1.0);
	setprop("/sim/model/pushback/steer-cmd-norm", steering);
}

var _timer = maketimer(0.051, func{_loop()});

var _done = func() {
	stop();
	screen.log.write("(pushback): Pushback complete, please set parking brake.");
}

var start = func() {
	if (_timer.isRunning) {
		stop();
	}
	if (!getprop("/sim/model/pushback/connected")) {
		gui.popupTip("Pushback must be connected");
		return;
	}
	_route = autopush_route.route();
	if ((_route == nil) or size(_route) < 2) {
		autopush_route.enter(1);
		return;
	}else{
		autopush_route.done();
	}
	_K_V = getprop("/sim/model/pushback/driver/K_V");
	_F_V = getprop("/sim/model/pushback/driver/F_V");
	_D_min = getprop("/sim/model/pushback/driver/D_min-m");
	_K_psi = getprop("/sim/model/pushback/driver/K_psi");
	_debug = getprop("/sim/model/pushback/debug") or 0;
	var (psi_park, D_park) = courseAndDistance(_route[0], _route[1]);
	var (psi_twy, D_twy) = courseAndDistance(_route[size(_route) - 2], _route[size(_route) - 1]);
	_psi_park = psi_park;
	_push = (abs(geo.normdeg180(getprop("/orientation/heading-deg") - psi_park)) > 90.0);
	_sign = 1.0 - 2.0 * _push;
	_to_wp = 0;
	_timer.start();
	if (_sign < 0.0) {
		screen.log.write("(pushback): Push back facing " ~ int(geo.normdeg(psi_twy + 180.0 - magvar())) ~ ".");
	} else {
		screen.log.write("(pushback): Tow facing " ~ int(geo.normdeg(psi_twy - magvar())) ~ ".");
	}
}

var stop = func() {
	_timer.stop();
	setprop("/sim/model/pushback/target-speed-km_h", 0.0);
	autopush_route.clear();
}
