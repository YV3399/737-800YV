# AUTOPUSH
# Visual entry of pushback route.
#
# Copyright (c) 2018 Autopush authors:
#  Michael Danilov <mike.d.ft402 -eh- gmail.com>
#  Joshua Davidson http://github.com/it0uchpods
#  Merspieler http://github.com/merspieler
# Distribute under the terms of GPLv2.


var _listener = nil;
var _view_listener = nil;
var _user_points = dynarr.dynarr.new(4);
var _route = [];
var _view_index = nil;
var _user_point_models = [];
var _waypoint_models = [];
var _N = 0;
var _show = 0;
var _view_changed_or_external = 0;
var _start_immediately = nil;
var _D_min = nil;

# TODO find a proper value or add a calculated value so we can get ridge
setprop("/demo/prec/", 10);


var _add = func(pos) {
	if (_N) {
		var (A, S) = courseAndDistance(_user_points.arr[_N - 1], pos);
		if (S * NM2M < 3 * _D_min) {
			gui.popupTip("Too close to the previous point,\ntry again");
			return;
		}
	}
	_user_points.add(geo.Coord.new(pos));
	setsize(_user_point_models, _N + 1);
	_user_point_models[_N] = geo.put_model("Models/Autopush/cursor.xml", pos, 0.0);
	_N += 1;
	if (_N == 1) {
		gui.popupTip("Click waypoints, press \"Done\" to finish");
	} else {
		_calculate_bezier();
		_place_waypoint_models();
	}
}

var _stop = func(fail = 0) {
	if (_listener != nil) {
		removelistener(_listener);
		_listener = nil;
		if (!fail) {
			settimer(func() {
				_reset_view();
				if (_start_immediately) {
					autopush_driver.start();
				} else {
					gui.popupTip("Done");
				}
			}, 1.0);
		} else {
			_reset_view();
		}
	}
}

var _place_user_point_models = func() {
	_clear_user_point_models();
	setsize(_user_point_models, _N);
	var user_points = _user_points.get_sliced();
	for (var ii = 1; ii < _N; ii += 1) {
		_user_point_models[ii] = geo.put_model("Models/Autopush/cursor.xml", user_points[ii], 0.0);
	}
}

var _clear_user_point_models = func() {
	for (var ii = 0; ii < size(_user_point_models); ii += 1) {
		if (_user_point_models[ii] != nil) {
			_user_point_models[ii].remove();
			_user_point_models[ii] = nil;
		}
	}
	setsize(_user_point_models, 0);
}

var _place_waypoint_models = func() {
	_clear_waypoint_models();
	setsize(_waypoint_models, size(_route));
	for (var ii = 0; ii < size(_route); ii += 1) {
		_waypoint_models[ii] = geo.put_model("Models/Autopush/waypoint.xml", _route[ii], 0.0);
	}
}

var _clear_waypoint_models = func() {
	for (var ii = 0; ii < size(_waypoint_models); ii += 1) {
		if (_waypoint_models[ii] != nil) {
			_waypoint_models[ii].remove();
			_waypoint_models[ii] = nil;
		}
	}
	setsize(_waypoint_models, 0);
}

var _set_view = func() {
	if(!getprop("/sim/current-view/internal")){
		_view_changed_or_external = 1;
		return;
	}
	_view_index = getprop("/sim/current-view/view-number");
	setprop("/sim/current-view/view-number", view.indexof("Model View"));
	_view_changed_or_external = 0;
	_view_listener = setlistener("/sim/current-view/name", func {
		_view_changed_or_external = 1;
	});
}

var _reset_view = func() {
	if (!_view_changed_or_external) {
		setprop("/sim/current-view/view-number", _view_index);
	}
	if (_view_listener != nil) {
		removelistener(_view_listener);
		_view_listener = nil;
	}
	if (!_show) {
		_clear_user_point_models();
		_clear_waypoint_models();
	}
}

var _calculate_bezier = func() {
	# add the first point cause it will be fix at this pos
	_route = [];
	user_points = _user_points.get_sliced();
	var route = dynarr.dynarr.new();
	route.add(geo.Coord.new(user_points[0]));

	PNumber = size(user_points);

	if (PNumber > 2) {
		var pointList = [];
		setsize(pointList, PNumber);
		for (var i = 0; i < PNumber; i += 1) {
			pointList[i] = [];
			setsize(pointList[i], PNumber);
		}

		pointList[0] = user_points;

		prec = getprop("/demo/prec");
		step = prec / 100;

		for (var i = step; i < 1; i+= step) {
			# start iterating from 1 cause we don't need to iterate over Pn
			for (var j = 1; j < PNumber; j += 1) {
				for (var k = 0; k < PNumber - j; k += 1) {
					pointList[j][k] = geo.Coord.new(pointList[j - 1][k]);
					var dist = pointList[j - 1][k].distance_to(pointList[j - 1][k + 1]);
					var course = pointList[j - 1][k].course_to(pointList[j - 1][k + 1]);
					pointList[j][k].apply_course_distance(course, dist * i);
				}
			}
			if (i + step < 1) {
				route.add(geo.Coord.new(pointList[PNumber - 1][0]));
			}
		}
	}

	if (PNumber > 1) {
		# append last user point to route
		route.add(geo.Coord.new(user_points[-1]));
	}

	_route = route.get_sliced();
}

setlistener("/sim/model/pushback/route/show", func(p) {
	var show = p.getValue();
	if (_listener == nil) {
		if (show > _show) {
			_place_user_point_models();
			_place_waypoint_models();
		} else if (show < _show) {
			_clear_user_point_models();
			_clear_waypoint_models();
		}
	}
	_show = show;
});


var enter = func(start_immediately = 0) {
	clear();
	_set_view();
	_D_min = getprop("/sim/model/pushback/driver/D_min-m");
	var wp = geo.aircraft_position();
	var H = geo.elevation(wp.lat(), wp.lon());
	if (H != nil) {
		wp.set_alt(H);
	}
	_add(wp);
	_listener = setlistener("/sim/signals/click", func {
		_add(geo.click_position());
	});
	_start_immediately = start_immediately;
}

var done = func() {
	_stop(0);
}

var clear = func() {
	_stop(1);
	_clear_user_point_models();
	_clear_waypoint_models();
	_N = 0;
	_user_points = dynarr.dynarr.new(4);
}

var route = func() {
	if (_N < 2) {
		return nil;
	}
	_calculate_bezier();
	return _route;
}
