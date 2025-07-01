# Copyright (C) 2025 Xavier Del Campo Romero
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

var input = func(num, v) {
	var p = sprintf("/instrumentation/cdu[%u]/input", num);

	setprop(p, getprop(p) ~ v);
}

var todmm = func(dec) {
	var ret = {};

	ret.deg = abs(int(dec));
	ret.min = (abs(dec) - ret.deg) * 60;
	return ret;
}

var lattodmm = func(dec) {
	if (typeof(dec) != "scalar") {
		return nil;
	}

	var dmm = todmm(dec);
	var sign = dec > 0 ? "N" : "S";

	return sprintf("%s%02u*%.1f", sign, dmm.deg, dmm.min);
}

var lontodmm = func(dec) {
	if (typeof(dec) != "scalar") {
		return nil;
	}

	var dmm = todmm(dec);
	var sign = dec > 0 ? "E" : "W";

	return sprintf("%s%03u*%.1f", sign, dmm.deg, dmm.min);
}

var parsescratchpadcoords = func(coords) {
	var fmt = "N0000.0E00000.0";

	if (size(coords) != size(fmt))
		return nil;

	var latsign = sprintf("%c", coords[0]);
	var latdeg = substr(coords, 1, 2);
	var latmin = substr(coords, 3, 4);
	var lonsign = sprintf("%c", coords[7]);
	var londeg = substr(coords, 8, 3);
	var lonmin = substr(coords, 11, 4);

	if ((latsign != "N" and latsign != "S")
		or (lonsign != "E" and lonsign != "W")
		or find(".", latdeg) > 0
		or find("-", latdeg) > 0
		or find(".", londeg) > 0
		or find("-", londeg) > 0
		or find(".", latmin) < 0
		or find(".", lonmin) < 0)
		return nil;

	var latdegnum = num(latdeg);
	var latminnum = num(latmin);
	var londegnum = num(londeg);
	var lonminnum = num(lonmin);

	if (latdegnum == nil
		or latminnum == nil
		or londegnum == nil
		or lonminnum == nil)
		return nil;

	var lat = (latsign == 'N' ? latdegnum : -latdegnum) + latminnum / 60;
	var lon = (lonsign == 'E' ? londegnum : -londegnum) + lonminnum / 60;

	return {lat: lat, lon: lon};
}

var coordtoscratchpad = func(lat, lon) {
	var dmmlat = todmm(lat);
	var dmmlon = todmm(lon);
	var latsign = lat > 0 ? "N" : "S";
	var lonsign = lon > 0 ? "E" : "W";

	return sprintf("%s%02u%04.1f%s%03u%04.1f", latsign, dmmlat.deg, dmmlat.min,
		lonsign, dmmlon.deg, dmmlon.min);
}

var setrefairport = func(icao) {
	info = airportinfo(icao);

	if (info != nil){
		setprop("/instrumentation/fmc/ref-airport", icao);
		refairport.lat = lattodmm(info.lat);
		refairport.lon = lontodmm(info.lon);
		return 1;
	}

	return 0;
}

var bar = func {
	return "-----------------------";
}

var parse_airport_xml = func(icao, fname, tag) {
	var parse = func(dir) {
		if (icao == nil or size(icao) != 4)
			return nil;

		var path = dir ~ "/Airports/"
			~ sprintf("%c", icao[0]) ~ "/"
			~ sprintf("%c", icao[1]) ~ "/"
			~ sprintf("%c", icao[2]) ~ "/"
			~ icao ~ "." ~ fname ~ ".xml";

		if (resolvepath(path) == "")
			return nil;

		parsexml(path, tag);
	}

	for (var i = 0; 1; i += 1) {
		var dir = getprop("/sim/fg-scenery[" ~ sprintf("%d", i) ~ "]");

		if (dir == nil)
			break;

		parse(dir);
	}
}

var getsids = func(icao, runway) {
	var ret = [];

	var tag = func(name, attr) {
		if (name == "Sid"
			and (runway == "" or runway == attr.Runways))
			append(ret, {name: attr.Name, runway: attr.Runways});
	}

	parse_airport_xml(icao, "procedures", tag);

	if (!size(ret))
		append(ret, {runway: runway, name: "DEFAULT"});

	return ret;
}

var togglesid = func(num) {
	var airport = getprop("/autopilot/route-manager/departure/airport");
	var rwyp = "/autopilot/route-manager/departure/runway";
	var runway = getprop(rwyp);
	var sids = getsids(airport, runway);

	if (size(sids) > num) {
		var p = "/autopilot/route-manager/departure/sid";
		var selsid = sids[num].name;
		var cursid = getprop(p);

		if (selsid != cursid) {
			setprop(p, selsid);
			setprop(rwyp, sids[num].runway);
		}
		else {
			setprop(p, "");
			setprop(rwyp, "");
		}
	}
}

var setdeprunway = func(num) {
	var airport = getprop("/autopilot/route-manager/departure/airport");
	var info = airportinfo(airport);

	if (info == nil)
		return 0;

	var p = "/autopilot/route-manager/departure/runway";

	setprop(p, keys(info.runways)[num]);
	return 1;
}

var getstars = func(icao, runway) {
	var ret = [];

	var tag = func(name, attr) {
		if (name == "Star"
			and (runway == ""
				or attr.Runways == runway
				or attr.Runways == "All"))
			append(ret, {name: attr.Name, runway: attr.Runways});
	}

	parse_airport_xml(icao, "procedures", tag);

	if (!size(ret))
		append(ret, {runway: runway, name: "DEFAULT"});

	return ret;
}

var togglestar = func(num) {
	var airport = getprop("/autopilot/route-manager/destination/airport");
	var rwyp = "/autopilot/route-manager/destination/runway";
	var runway = getprop(rwyp);
	var stars = getstars(airport, runway);

	if (size(stars) > num) {
		var p = "/autopilot/route-manager/destination/approach";
		var selstar = stars[num].name;
		var curstar = getprop(p);

		if (selstar != curstar) {
			setprop(p, selstar);
			setprop(rwyp, stars[num].runway);
		}
		else {
			setprop(p, "");
			setprop(rwyp, "");
		}
	}
}

var setarrrunway = func(num) {
	var airport = getprop("/autopilot/route-manager/destination/airport");
	var info = airportinfo(airport);

	if (info == nil)
		return 0;

	var p = "/autopilot/route-manager/destination/runway";

	setprop(p, keys(info.runways)[num]);
	return 1;
}

var getgate = func(icao, gate) {
	var ret = nil;
	var tag = func(name, attr) {
		if (name == "Parking" and attr.name == gate) {
			ret = {
				name: attr.name,
				lat: attr.lat,
				lon: attr.lon
			};
		}
	}

	parse_airport_xml(icao, "groundnet", tag);
	return ret;
}

var getlegspages = func {
	var nwp = getprop("/autopilot/route-manager/route/num");

	return pages = 1 + ((nwp + 1) / 5);
}

var getrtepages = func {
	var ret = getlegspages();

	return int(ret) > 1 ? ret : 2;
}

var depspages = func {
	var airport = getprop("/autopilot/route-manager/departure/airport");
	var info = airportinfo(airport);

	if (airport == "" or info == nil)
		return 1;

	var runway = getprop("/autopilot/route-manager/departure/runway");
	var sid = getprop("/autopilot/route-manager/departure/sid");

	if (runway != "" and sid != "")
		return 1;

	var rwypages = 1 + (size(keys(info.runways)) / 6);
	var sidpages = 1 + (size(getsids(airport, runway)) / 6);

	return rwypages > sidpages ? rwypages : sidpages;
}

var arrpages = func {
	var airport = getprop("/autopilot/route-manager/destination/airport");
	var info = airportinfo(airport);

	if (airport == "" or info == nil)
		return 1;

	var runway = getprop("/autopilot/route-manager/destination/runway");
	var star = getprop("/autopilot/route-manager/destination/approach");

	if (runway != "" and star != "")
		return 1;

	var rwypages = 1 + (size(keys(info.runways)) / 6);
	var starpages = 1 + (size(getstars(airport, runway)) / 6);

	return rwypages > starpages ? rwypages : starpages;
}

var getgcw = func {
	if (getprop("/sim/flight-model") == "jsb")
		return getprop("/fdm/jsbsim/inertia/weight-lbs");
	else if (getprop("/sim/flight-model") == "yasim")
		return getprop("/yasim/gross-weight-lbs");

	return nil;
}

# Ideally, this should be extracted from the "data cycle" date in nav.dat.gz.
# However, this file is gzip-encoded, and currently there is no way to read
# gzip-compressed files from Nasal.
# Furthermore, writing a gzip library in Nasal might be very difficult
# or even impossible, as Nasal misses some required operators, such as
# bit-wise operators.
# Instead, a (1-element) lookup table is defined below.
var getnavdate = func {
	var version = getnavversion();

	if (version == "UNKOWN" or version != "FG226")
		return "UNKNOWN";

	return "OCT01/13";
}

var perf_armed = func {
	var armed = getprop("/instrumentation/fmc/perf-init/armed");
	var ci = getprop("/instrumentation/fmc/cost-index");
	var ta = getprop("/autopilot/settings/transition-altitude");
	var reserve = getprop("/instrumentation/fmc/reserve-fuel-lbs");

	return int(reserve) and int(ci) >= 0 and int(ta) > 0 and !armed;
}

var check_perf = func {
	# TODO
	return "";
}

var isprint = func(c) {
	var accepted = "!\"#$%&'()*+,-./0123456789:;<=>?@"
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		"\\]^_`"
		"abcdefghijklmnopqrstuvwxyz"
		"|~";

	return find(sprintf("%c", c), accepted) != -1;
}

var toupper = func(s) {
	var ret = "";

	for (var i = 0; i < size(s); i += 1) {
		var c = s[i];

		# HACK: Nasal does not treat characters in single quotes as integers.
		# Therefore, they cannot be compared as in C or C++.
		# However, this can be worked around by accessing their first
		# (and only) element.
		if (c >= 'a'[0] and c <= 'z'[0])
			ret = ret ~ sprintf("%c", c - 32);
		else if (isprint(c))
			ret = ret ~ sprintf("%c", c);
	}

	return ret;
}

var refairport = {};
var gate = nil;
var legspage = [1, 1];
var depspage = [1, 1];
var arrpage = [1, 1];
var rtepage = [1, 1];
var multinavaid = [nil, nil];
var fixinfo = nil;

var rteinsert = func(offset, navaid) {
	var ret = {input: "", display: "RTE1_RTE", wp: nil};
	var lat = getprop("/position/latitude-deg");
	var lon = getprop("/position/longitude-deg");
	# As of v2024.1.1, navinfo's "any" filter ranges from
	# FGPositioned::NDB to FGPositioned::GS (both included),
	# therefore not including FGPositioned::FIX.
	# Since the CDU does not know the navaid type in advance,
	# at most two searches must be performed to find a navaid.
	var wp = navinfo(lat, lon, "any", navaid);

	if (size(wp) or size(wp = navinfo(lat, lon, "fix", navaid))) {
		if (size(wp) == 1) {
			var viap = sprintf("/instrumentation/fmc/via[%u]", offset);
			var via = getprop(viap);
			var fp = flightplan();

			if (via != nil and via != "") {
				var wpvia = createViaTo(via, wp[0]);

				if (wpvia != nil) {
					print(sprintf(".id=%s, .type=%s, role=%s, lat=%.1f, lon=%.1f",
						wpvia.id, wpvia.wp_type, wpvia.wp_role, wpvia.lat, wpvia.lon));
					fp.insertWP(wpvia, offset);
				}
				else
					ret.input = "NOT IN DATABASE";
			}
			else
				fp.insertWP(wp[0].id, offset);
		}
		else {
			ret.wp = wp;
			ret.display = "RTE1_MULTI";
		}
	}
	else
		ret.input = "NOT IN DATABASE";

	return ret;
}

var key = func(cdunum, x) {
	var cduprop = sprintf("/instrumentation/cdu[%u]", cdunum);
	var cduDisplay = getprop(cduprop ~ "/display");
	var origcduDisplay = cduDisplay;
	var serviceable = getprop(cduprop ~ "/serviceable");
	# TODO: eicas[cdunum]?
	var eicasDisplay = getprop("/instrumentation/eicas/display");
	var cduInput = getprop(cduprop ~ "/input");
	var depsoffset = 5 * (depspage[cdunum] - 1);
	var arroffset = 5 * (arrpage[cdunum] - 1);

	if (serviceable != 1)
		return;
	else if (x == "exec"){
		if ((cduDisplay == "RTE1_RTE" or cduDisplay == "RTE1_LEGS")
			and getprop("/autopilot/route-manager/armed")) {
			setprop("/autopilot/route-manager/input","@ACTIVATE");
			setprop("/autopilot/route-manager/armed", 0);
		}
		else if (cduDisplay == "PERF_INIT" and perf_armed()) {
			if ((cduInput = checkperf()) == "")
				setprop("/autopilot/fmc/perf-init/armed", 1);
		}
	}
	else if (x == "rte"){
		var ref = getprop("/instrumentation/fmc/ref-airport");
		var origin = getprop("/autopilot/route-manager/departure/airport");

		if (origin == "" and ref != "")
			cduInput = ref;

		cduDisplay = "RTE1_RTE";
	}
	else if (x == "prog")
		cduDisplay = "PROG";
	else if (x == "init_ref")
		cduDisplay = "INIT_REF";
	else if (x == "dep_arr")
		cduDisplay = "DEP_ARR_INDEX";
	else if (x == "fix")
		cduDisplay = "FIX_INFO";
	else if (x == "legs")
		cduDisplay = "RTE1_LEGS";
	else if (x == "menu")
		cduDisplay = "MENU";
	else if (x == "n1limit")
		cduDisplay = "N1_LIMIT";
	else if (x == "next"){
		if (cduDisplay == "POS_INIT"){
			cduDisplay = "POS_REF";
		}
		else if (cduDisplay == "POS_REF") {
			cduDisplay = "POS_SHIFT";
		}
		else if (cduDisplay == "RTE1_RTE"){
			var page = rtepage[cdunum] + 1;

			if (page <= getrtepages())
				rtepage[cdunum] = page;
		}
		else if (cduDisplay == "RTE1_LEGS"){
			var page = legspage[cdunum] + 1;

			if (page <= getlegspages())
				legspage[cdunum] = page;
		}
		else if (cduDisplay == "RTE1_DEP"){
			var page = depspage[cdunum] + 1;

			if (page <= depspages())
				depspage[cdunum] = page;
		}
		else if (cduDisplay == "RTE1_ARR"){
			var page = arrpage[cdunum] + 1;

			if (page <= arrpages())
				arrpage[cdunum] = page;
		}
	}
	else if (x == "prev"){
		if (cduDisplay == "POS_REF"){
			cduDisplay = "POS_INIT";
		}
		else if (cduDisplay == "POS_SHIFT") {
			cduDisplay = "POS_REF";
		}
		else if (cduDisplay == "RTE1_RTE" and rtepage[cdunum] > 1){
			rtepage[cdunum] -= 1;
		}
		else if (cduDisplay == "RTE1_LEGS" and legspage[cdunum] > 1){
			legspage[cdunum] -= 1;
		}
		else if (cduDisplay == "RTE1_DEP" and depspage[cdunum] > 1){
			depspage[cdunum] -= 1;
		}
		else if (cduDisplay == "RTE1_ARR" and arrpage[cdunum] > 1){
			arrpage[cdunum] -= 1;
		}
	}
	else if (x == "LSK1L"){
		if (cduDisplay == "DEP_ARR_INDEX"){
			cduDisplay = "RTE1_DEP";
		}
		else if (cduDisplay == "EICAS_MODES"){
			eicasDisplay = "ENG";
		}
		else if (cduDisplay == "EICAS_SYN"){
			eicasDisplay = "ELEC";
		}
		else if (cduDisplay == "INIT_REF"){
			cduDisplay = "IDENT";
		}
		else if (cduDisplay == "RTE1_RTE" and rtepage[cdunum] == 1){
			if (cduInput == "DELETE"){
				setprop("/autopilot/route-manager/departure/airport", "");
				refairport = {};
				cduInput = "";
			}
			else if (setrefairport(cduInput)) {
				setprop("/autopilot/route-manager/departure/airport", cduInput);
				cduInput = "";
			}
			else
				cduInput = "NOT IN DATABASE";
		}
		else if (cduDisplay == "RTE1_RTE" and rtepage[cdunum] > 1) {
			var rteoffset = 1 + 5 * (rtepage[cdunum] - 2);
			var prop = sprintf("/instrumentation/fmc/via[%u]", rteoffset);

			if (cduInput == "DELETE") {
				setprop(prop, "");
				cduInput = "";
			}
			else if (airway(cduInput) != nil) {
				setprop(prop, cduInput);
				cduInput = "";
			}
			else
				cduInput = "NOT IN DATABASE";
		}
		else if (cduDisplay == "RTE1_LEGS"){
			if (cduInput == "DELETE"){
				setprop("/autopilot/route-manager/input","@DELETE0");
			}
			else{
				setprop("/autopilot/route-manager/input","@INSERT1:"~cduInput);
			}

			cduInput = "";
		}
		else if (cduDisplay == "TO_REF"){
			if (cduInput == "DELETE") {
				setprop("/instrumentation/fmc/to-flap", 0);
				cduInput = "";
			}
			else {
				var flaps = int(cduInput);

				if (flaps == nil
					or (flaps != 1
						and flaps != 2
						and flaps != 5
						and flaps != 10
						and flaps != 15
						and flaps != 25
						and flaps != 30
						and flaps != 40))
					cduInput = "INVALID ENTRY";
				else {
					setprop("/instrumentation/fmc/to-flap", cduInput);
					cduInput = "";
				}
			}
		}
		else if (cduDisplay == "FIX_INFO") {
			if (cduInput == "DELETE") {
				fixinfo = nil;
				cduInput = "";
			}
			else {
				var wp = navinfo(cduInput);
				var lat = getprop("/position/latitude-deg");
				var lon = getprop("/position/longitude-deg");

				if (size(wp) or size(wp = navinfo(lat, lon, "fix", cduInput))) {
					if (size(wp) == 1) {
						fixinfo = wp[0];
						cduInput = "";
					}
					else
						cduInput = "TODO";
				}
				else
					cduInput = "NOT IN DATABASE";
			}
		}
		else if (cduDisplay == "RTE1_DEP")
			togglesid(0 + depsoffset);
		else if (cduDisplay == "RTE1_ARR")
			togglestar(0 + arroffset);
	}
	else if (x == "LSK1R"){
		if (cduDisplay == "EICAS_MODES"){
			eicasDisplay = "FUEL";
		}
		else if (cduDisplay == "EICAS_SYN"){
			eicasDisplay = "HYD";
		}
		else if (cduDisplay == "NAV RAD"){
			setprop("/instrumentation/nav[1]/frequencies/selected-mhz",cduInput);
			cduInput = "";
		}
		else if (cduDisplay == "RTE1_RTE"  and rtepage[cdunum] == 1){
			if (cduInput == "DELETE") {
				setprop("/autopilot/route-manager/destination/airport", "");
				cduInput = "";
			}
			else if (airportinfo(cduInput) != nil) {
				setprop("/autopilot/route-manager/destination/airport", cduInput);
				cduInput = "";
			}
			else
				cduInput = "NOT IN DATABASE";
		}
		else if (cduDisplay == "RTE1_RTE" and rtepage[cdunum] > 1) {
			var fp = flightplan();
			var offset = 1 + 5 * (rtepage[cdunum] - 2);

			if (cduInput == "DELETE") {
				fp.deleteWP(offset);
				cduInput = "";
			}
			else {
				var r = rteinsert(offset, cduInput);

				cduDisplay = r.display;
				cduInput = r.input;
			}
		}
		else if (cduDisplay == "RTE1_LEGS"){
			setprop("/autopilot/route-manager/route/wp[1]/altitude-ft",cduInput);

			if (substr(cduInput,0,2) == "FL"){
				setprop("/autopilot/route-manager/route/wp[1]/altitude-ft",substr(cduInput,2)*100);
			}
			cduInput = "";
		}
		else if (cduDisplay == "PERF_INIT") {
			if (cduInput == "DELETE") {
				setprop("/autopilot/route-manager/cruise/flight-level", 0);
				setprop("/autopilot/route-manager/cruise/altitude-ft", 0);
			}
			else if (substr(cduInput, 0, 2) == "FL")
				cduInput = substr(cduInput, 2);

			var altitude = int(cduInput);

			if (altitude == nil or altitude < 0
				or size(cduInput) > 3
				or altitude > 41000)
				cduInput = "INVALID ENTRY";
			else {
				var ft = altitude * 100;

				setprop("/autopilot/route-manager/cruise/flight-level", altitude);
				setprop("/autopilot/route-manager/cruise/altitude-ft", ft);
				cduInput = "";
			}
		}
		else if (cduDisplay == "RTE1_DEP") {
			setdeprunway(0 + depsoffset);
			setprop("/autopilot/route-manager/departure/sid", "");
		}
		else if (cduDisplay == "RTE1_ARR") {
			setarrrunway(0 + arroffset);
			setprop("/autopilot/route-manager/destination/approach", "");
		}
	}
	else if (x == "LSK2L"){
		if (cduDisplay == "EICAS_MODES"){
			eicasDisplay = "STAT";
		}
		else if (cduDisplay == "EICAS_SYN"){
			eicasDisplay = "ECS";
		}
		else if (cduDisplay == "POS_INIT"){
			if (setrefairport(cduInput))
				cduInput = "";
			else
				cduInput = "NOT IN DATABASE";
		}
		else if (cduDisplay == "INIT_REF"){
			cduDisplay = "POS_INIT";
		}
		else if (cduDisplay == "RTE1_RTE" and rtepage[cdunum] == 1){
			if (cduInput == "DELETE") {
				var fp = flightplan();

				fp.cleanPlan();
				setprop("/autopilot/route-manager/departure/airport", "");
				setprop("/autopilot/route-manager/destination/airport", "");
				setprop("/instrumentation/fmc/co-route", "");
				cduInput = "";
			}
			else {
				var path = getprop("/sim/fg-home/") ~ "/Export/" ~ cduInput ~ ".fgfp";

				if (fgcommand("load-flightplan", props.Node.new({"path": path}))) {
					setprop("/instrumentation/fmc/co-route", cduInput);
					setrefairport(getprop("/autopilot/route-manager/departure/airport"));
					cduInput = "";
				} else
					cduInput = "NOT IN DATABASE";
			}
		}
		else if (cduDisplay == "RTE1_LEGS"){
			if (cduInput == "DELETE"){
				setprop("/autopilot/route-manager/input","@DELETE1");
			}
			else{
				setprop("/autopilot/route-manager/input","@INSERT2:"~cduInput);
			}

			cduInput = "";
		}
		else if (cduDisplay == "RTE1_DEP")
			togglesid(1 + depsoffset);
		else if (cduDisplay == "RTE1_ARR")
			togglestar(1 + arroffset);
	}
	else if (x == "LSK2R"){
		if (cduDisplay == "DEP_ARR_INDEX"){
			cduDisplay = "RTE1_ARR";
		}
		else if (cduDisplay == "EICAS_MODES"){
			eicasDisplay = "GEAR";
		}
		else if (cduDisplay == "EICAS_SYN"){
			eicasDisplay = "DRS";
		}
		else if (cduDisplay == "MENU"){
			eicasDisplay = "EICAS_MODES";
		}
		else if (cduDisplay == "RTE1_LEGS"){
			setprop("/autopilot/route-manager/route/wp[2]/altitude-ft",cduInput);
			if (substr(cduInput,0,2) == "FL"){
				setprop("/autopilot/route-manager/route/wp[2]/altitude-ft",substr(cduInput,2)*100);
			}
			cduInput = "";
		}
		else if (cduDisplay == "RTE1_DEP") {
			setdeprunway(1 + depsoffset);
			setprop("/autopilot/route-manager/departure/sid", "");
		}
		else if (cduDisplay == "RTE1_ARR") {
			setarrrunway(1 + arroffset);
			setprop("/autopilot/route-manager/destination/approach", "");
		}
	}
	else if (x == "LSK3L"){
		if (cduDisplay == "INIT_REF"){
			cduDisplay = "PERF_INIT";
		}
		else if (cduDisplay == "RTE1_LEGS"){
			if (cduInput == "DELETE"){
				setprop("/autopilot/route-manager/input","@DELETE2");
			}
			else{
				setprop("/autopilot/route-manager/input","@INSERT3:"~cduInput);
			}

			cduInput = "";
		}
		else if (cduDisplay == "RTE1_RTE"){
			var airport = getprop("/autopilot/route-manager/departure/airport");

			if (airport != "") {
				var sidp = "/autopilot/route-manager/departure/sid";
				var rwyp = "/autopilot/route-manager/departure/runway";
				var info = airportinfo(airport);

				if (info != nil and info.runways[cduInput] != nil) {
					if (cduInput == "DELETE") {
						setprop(rwyp, "");
						setprop(sidp, "");
					}
					else {
						if (getprop(rwyp) != cduInput)
							setprop(sidp, "");

						setprop(rwyp, cduInput);
					}

					cduInput = "";
				}
				else
					cduInput = "NOT IN DATABASE";
			}
			else {
				cduInput = "NO ORIGIN AIRPORT";
			}
		}
		else if (cduDisplay == "POS_INIT"){
			var g = getgate(getprop("/instrumentation/fmc/ref-airport"), cduInput);

			if (g != nil) {
				gate = g;
				cduInput = "";
			}
			else
				cduInput = "NOT IN DATABASE";
		}
		else if (cduDisplay == "RTE1_DEP")
			togglesid(2 + depsoffset);
		else if (cduDisplay == "RTE1_ARR")
			togglestar(2 + arroffset);
	}
	else if (x == "LSK3R"){
		if (cduDisplay == "RTE1_LEGS"){
			setprop("/autopilot/route-manager/route/wp[3]/altitude-ft",cduInput);
			if (substr(cduInput,0,2) == "FL"){
				setprop("/autopilot/route-manager/route/wp[3]/altitude-ft",substr(cduInput,2)*100);
			}
			cduInput = "";
		}
		else if (cduDisplay == "RTE1_DEP") {
			setdeprunway(2 + depsoffset);
			setprop("/autopilot/route-manager/departure/sid", "");
		}
		else if (cduDisplay == "RTE1_ARR") {
			setarrrunway(2 + arroffset);
			setprop("/autopilot/route-manager/destination/approach", "");
		}
	}
	else if (x == "LSK4L"){
		if (cduDisplay == "INIT_REF"){
			cduDisplay = "TO_REF";
		}
		else if (cduDisplay == "RTE1_LEGS"){
			if (cduInput == "DELETE"){
				setprop("/autopilot/route-manager/input","@DELETE3");
			}
			else{
				setprop("/autopilot/route-manager/input","@INSERT4:"~cduInput);
			}

			cduInput = "";
		}
		else if (cduDisplay == "RTE1_DEP")
			togglesid(3 + depsoffset);
		else if (cduDisplay == "RTE1_ARR")
			togglestar(3 + arroffset);
		else if (cduDisplay == "POS_REF"){
			var lat = getprop("/position/latitude-deg");
			var lon = getprop("/position/longitude-deg");

			cduInput = coordtoscratchpad(lat, lon);
		}
		else if (cduDisplay == "PERF_INIT"){
			var p = "/instrumentation/fmc/reserve-fuel-lbs";

			if (cduInput == "DELETE") {
				setprop(p, "");
				cduInput = "";
			}
			else {
				# Values extracted from ground-services.nas.
				var maxfuel = 8.621 * 2 + 20.596;
				var lbs = num(cduInput);

				if (lbs == nil or int(lbs) <= 0 or lbs > maxfuel)
					cduInput = "INVALID ENTRY";
				else {
					setprop(p, lbs * 1000);
					cduInput = "";
				}
			}
		}
	}
	else if (x == "LSK4R"){
		if (cduDisplay == "RTE1_LEGS"){
			setprop("/autopilot/route-manager/route/wp[4]/altitude-ft",cduInput);
			if (substr(cduInput,0,2) == "FL"){
				setprop("/autopilot/route-manager/route/wp[4]/altitude-ft",substr(cduInput,2)*100);
			}
			cduInput = "";
		}
		else if (cduDisplay == "POS_INIT"){
			if (cduInput == "DELETE") {
				setprop("/instrumentation/fmc/irs-latitude", "");
				setprop("/instrumentation/fmc/irs-longitude", "");
				cduInput = "";
			}
			else {
				var coords = parsescratchpadcoords(cduInput);

				if (coords != nil) {
					setprop("/instrumentation/fmc/irs-latitude", coords.lat);
					setprop("/instrumentation/fmc/irs-longitude", coords.lon);
					setprop("/instrumentation/fmc/last-pos-latitude", coords.lat);
					setprop("/instrumentation/fmc/last-pos-longitude", coords.lon);
					cduInput = "";
				} else
					cduInput = "INVALID ENTRY";
			}
		}
		else if (cduDisplay == "RTE1_DEP") {
			setdeprunway(3 + depsoffset);
			setprop("/autopilot/route-manager/departure/sid", "");
		}
		else if (cduDisplay == "RTE1_ARR") {
			setarrrunway(3 + arroffset);
			setprop("/autopilot/route-manager/destination/approach", "");
		}
	}
	else if (x == "LSK5L"){
		if (cduDisplay == "RTE1_LEGS"){
			if (cduInput == "DELETE"){
				setprop("/autopilot/route-manager/input","@DELETE4");
			}
			else{
				setprop("/autopilot/route-manager/input","@INSERT5:"~cduInput);
			}

			cduInput = "";
		}
		else if (cduDisplay == "RTE1_DEP")
			togglesid(4 + depsoffset);
		else if (cduDisplay == "RTE1_ARR")
			togglestar(4 + arroffset);
		else if (cduDisplay == "POS_REF"){
			var lat = getprop("/position/latitude-deg");
			var lon = getprop("/position/longitude-deg");

			cduInput = coordtoscratchpad(lat, lon);
		}
		else if (cduDisplay == "PERF_INIT") {
			if (cduInput == "DELETE") {
				setprop("/instrumentation/fmc/cost-index", -1);
				cduInput = "";
			} else {
				var ci = int(cduInput);

				if (ci == nil or ci < 0 or ci > 500)
					cduInput = "INVALID ENTRY";
				else {
					setprop("/instrumentation/fmc/cost-index", cduInput);
					cduInput = "";
				}
			}
		}
	}
	else if (x == "LSK5R"){
		if (cduDisplay == "RTE1_LEGS"){
			setprop("/autopilot/route-manager/route/wp[5]/altitude-ft",cduInput);
			if (substr(cduInput,0,2) == "FL"){
				setprop("/autopilot/route-manager/route/wp[5]/altitude-ft",substr(cduInput,2)*100);
			}
			cduInput = "";
		}
		else if (cduDisplay == "PERF_INIT") {
			var alt = int(cduInput);

			if (alt == nil or alt < 0)
				cduInput = "INVALID ENTRY";
			else {
				line5r = setprop("/autopilot/settings/transition-altitude", alt);
				cduInput = "";
			}
		}
		else if (cduDisplay == "RTE1_DEP") {
			setdeprunway(4 + depsoffset);
			setprop("/autopilot/route-manager/departure/sid", "");
		}
		else if (cduDisplay == "RTE1_ARR") {
			setarrrunway(4 + arroffset);
			setprop("/autopilot/route-manager/destination/approach", "");
		}
	}
	else if (x == "LSK6L"){
		if (cduDisplay == "INIT_REF")
			cduDisplay = "APP_REF";
		else if (cduDisplay == "APP_REF")
			cduDisplay = "INIT_REF";
		else if (cduDisplay == "IDENT"
			or cduDisplay == "MAINT"
			or cduDisplay == "PERF_INIT"
			or cduDisplay == "POS_INIT"
			or cduDisplay == "TO_REF"
			or cduDisplay == "RTE1_DEP"
			or cduDisplay == "RTE1_ARR")
			cduDisplay = "INIT_REF";
		else if (cduDisplay == "N1_LIMIT")
			cduDisplay = "PERF_INIT";
	}
	else if (x == "LSK6R"){
		if (cduDisplay == "N1_LIMIT")
			cduDisplay = "TO_REF";
		else if (cduDisplay == "PERF_INIT" or cduDisplay == "APP_REF")
			cduDisplay = "N1_LIMIT";
		else if (cduDisplay == "RTE1_RTE" or cduDisplay == "RTE1_LEGS"){
			if (getprop("/autopilot/route-manager/active")
				or getprop("/autopilot/route-manager/armed"))
				cduDisplay = "PERF_INIT";
			else
				setprop("/autopilot/route-manager/armed", 1)
		}
		else if (cduDisplay == "POS_INIT"
			or cduDisplay == "DEP"
			or cduDisplay == "RTE1_ARR"
			or cduDisplay == "RTE1_DEP") {
			var ref = getprop("/instrumentation/fmc/ref-airport");
			var origin = getprop("/autopilot/route-manager/departure/airport");

			if (origin == "" and ref != "")
				cduInput = ref;

			cduDisplay = "RTE1_RTE";
		}
		else if (cduDisplay == "IDENT" or cduDisplay == "TO_REF"){
			cduDisplay = "POS_INIT";
		}
		else if (cduDisplay == "EICAS_SYN"){
			cduDisplay = "EICAS_MODES";
		}
		else if (cduDisplay == "EICAS_MODES"){
			cduDisplay = "EICAS_SYN";
		}
		else if (cduDisplay == "INIT_REF"){
			cduDisplay = "MAINT";
		}
	}

	if (cduDisplay != "RTE1_DEP")
		depspage[cdunum] = 1;

	if (cduDisplay != "RTE1_ARR")
		arrpage[cdunum] = 1;

	if (cduDisplay != "RTE1_LEGS")
		legspage[cdunum] = 1;
	else if (origcduDisplay != "RTE1_LEGS") {
		var cwp = getprop("/autopilot/route-manager/current-wp");

		if (cwp > 0)
			legspage[cdunum] = 1 + int(cwp / 5);
	}

	if (cduDisplay != "RTE1_RTE")
		rtepage[cdunum] = 1;

	setprop(cduprop ~ "/display", cduDisplay);
	if (eicasDisplay != nil){
		setprop("/instrumentation/eicas/display", eicasDisplay);
	}
	setprop(cduprop ~ "/input", cduInput);
}

var delete_func = func(num) {
		var p = sprintf("/instrumentation/cdu[%u]/input", num);
		var sz = size(getprop(p));

		if (!sz)
			setprop(p, "DELETE");
		else {
			var length = sz - 1;
			setprop(p, substr(getprop(p), 0, length));
		}
	}

var plusminus = func(num) {
	var cduprop = sprintf("/instrumentation/cdu[%u]", num);
	var end = size(getprop(cduprop ~ "/input"));
	var start = end - 1;
	var lastchar = substr(getprop(cduprop ~ "/input"),start,end);
	if (lastchar == "+"){
		me.delete_func();
		me.input('-');
		}
	if (lastchar == "-"){
		me.delete_func();
		me.input('+');
		}
	if ((lastchar != "-") and (lastchar != "+")){
		me.input('+');
		}
	}

var getversion = func {
	var path = string.normpath(getprop("/sim/fg-root") ~ "/flightgear-version");

	return io.readfile(path);
}

var getnavversion = func {
	var unknown = "UNKNOWN";
	var d = directory(getprop("/sim/fg-root") ~ "/Navaids/");

	if (d == nil)
		return unknown;

	foreach (var entry; d) {
		var s = split('.', entry);

		# Expected filename: ReadMe.FGXYZ.txt
		# X: major version, YZ: minor version
		if (size(s) == 3) {
			var name = s[0];
			var version = s[1];

			if (name == "ReadMe")
				return version;
		}
	}

	return unknown;
}

var irspos = func {
	var irslat = getprop("/instrumentation/fmc/irs-latitude");
	var irslon = getprop("/instrumentation/fmc/irs-longitude");
	var empty = "___*__._";
	# IRS alignment is not implemented yet. Therefore,
	# always assume the IRS as aligned.
	var latstr = irslat != "" ? "" : empty;
	var lonstr = irslon != "" ? "" : empty;

	sprintf("%s %s", latstr, lonstr);
}

var cdu = func(num) {
	var cduprop = sprintf("/instrumentation/cdu[%u]", num);
	var display = getprop(cduprop ~ "/display");
	var serviceable = getprop(cduprop ~ "/serviceable");

	title = "";		page = "";
	line1l = "";	line2l = "";	line3l = "";	line4l = "";	line5l = "";	line6l = "";
	line1lt = "";	line2lt = "";	line3lt = "";	line4lt = "";	line5lt = "";	line6lt = "";
	line1c = "";	line2c = "";	line3c = "";	line4c = "";	line5c = "";	line6c = "";
	line1ct = "";	line2ct = "";	line3ct = "";	line4ct = "";	line5ct = "";	line6ct = "";
	line1r = "";	line2r = "";	line3r = "";	line4r = "";	line5r = "";	line6r = "";
	line1rt = "";	line2rt = "";	line3rt = "";	line4rt = "";	line5rt = "";	line6rt = "";
	line6bar = "";

	if (display == "MENU") {
		title = "MENU";
		line1l = "<FMC";
		line1rt = "EFIS CP";
		line1r = "SELECT>";
		line2l = "<ACARS";
		line2rt = "EICAS CP";
		line2r = "SELECT>";
		line6l = "<ACMS";
		line6r = "CMC>";
	}
	else if (display == "APP_REF") {
		title = "APPROACH REF";
		line1lt = "GROSS WT";
		line1rt = "FLAPS    VREF";
		if (getprop("/instrumentation/fmc/vspeeds/Vref") != nil){
			line1l = getprop("/instrumentation/fmc/vspeeds/Vref");
		}
		if (getprop("/autopilot/route-manager/destination/airport") != ""){
			line4lt = getprop("/autopilot/route-manager/destination/airport");
		}
		line6l = "<INDEX";
		line6r = "N1 LIMIT>";
	}
	else if (display == "DEP_ARR_INDEX") {
		title = "DEP/ARR INDEX";
		page = "1/1";
		line1l = "<DEP";
		if (getprop("/autopilot/route-manager/departure/airport") != ""){
			line1c = getprop("/autopilot/route-manager/departure/airport");
		}
		# FlightGear does not support STARs for the departure airport.
		# line1r = "ARR>";
		if (getprop("/autopilot/route-manager/destination/airport") != ""){
			line2c = getprop("/autopilot/route-manager/destination/airport");
		}
		line2r = "ARR>";
		line6lt ="DEP";
		line6l = "<----";
		line6c = "OTHER";
		line6rt ="ARR";
		line6r = "---->";
	}
	else if (display == "EICAS_MODES") {
		title = "EICAS MODES";
		line1l = "<ENG";
		line1r = "FUEL>";
		line2l = "<STAT";
		line2r = "GEAR>";
		line5l = "<CANC";
		line5r = "RCL>";
		line6r = "SYNOPTICS>";
	}
	else if (display == "EICAS_SYN") {
		title = "EICAS SYNOPTICS";
		line1l = "<ELEC";
		line1r = "HYD>";
		line2l = "<ECS";
		line2r = "DOORS>";
		line5l = "<CANC";
		line5r = "RCL>";
		line6r = "MODES>";
	}
	else if (display == "FIX_INFO") {
		title = "FIX INFO";
		# Support only one page for now.
		page = "1/1";
		line1lt = "FIX";
		line1ct = "RAD/DIS    FR";
		line2lt = "RAD/DIS";
		line2ct = "ETA    DTG";
		line2rt = "ALT";
		line2l = "---";
		line3l = "---";
		line4l = "---";
		line5l = "<ABM";

		if (fixinfo != nil) {
			var from = {
				lat: getprop("/position/latitude-deg"),
				lon: getprop("/position/longitude-deg")
			};

			var (course, dist) = courseAndDistance(from, fixinfo);

			line1l = fixinfo.id;
			line1c = sprintf("%3.0f/%.1f", course, dist);
		}
	}
	else if (display == "IDENT") {
		title = "IDENT";
		line1lt = "MODEL";
		if (getprop(cduprop ~ "/ident/model") != nil){
			line1l = getprop(cduprop ~ "/ident/model");
		}
		line1rt = "ENG RATING";
		line1r = "26K";
		line2lt = "NAV DATA";
		line2l = getnavversion();
		line2rt = "ACTIVE";
		line2r = getnavdate();
		line4lt = "OP PROGRAM";
		line4l = getversion();
		line5rt = "SUPP DATA";
		line6l = "<INDEX";
		line6r = "POS INIT>";
	}
	else if (display == "INIT_REF") {
		title = "INIT/REF INDEX";
		page = "1/1";
		line1l = "<IDENT";
		line1r = "NAV DATA>";
		line2l = "<POS";
		line3l = "<PERF";
		line4l = "<TAKEOFF";
		line5l = "<APPROACH";
		if (getprop("/b737/sensors/air-ground") == 0) {
			line6r = "NAV STATUS>";
			line6l = "<OFFSET";
		} else {
			line6r = "MAINT>";
		}
	}
	else if (display == "MAINT") {
		title = "MAINTENANCE INDEX";
		line1l = "<CROS LOAD";
		line1r = "BITE>";
		line2l = "<PERF FACTORS";
		line3l = "<IRS MONITOR";
		line6l = "<INDEX";
	}
	else if (display == "PERF_INIT") {
		var cruiseft = getprop("/autopilot/route-manager/cruise/altitude-ft");
		var cruisefl = "_____";
		var ta = int(getprop("/autopilot/settings/transition-altitude"));
		var ci = getprop("/instrumentation/fmc/cost-index");
		var reserve = getprop("/instrumentation/fmc/reserve-fuel-lbs");
		var winddeg = int(getprop("/instrumentation/fmc/cruise-wind-deg"));
		var windkt = int(getprop("/instrumentation/fmc/cruise-wind-kt"));
		var degstr = (winddeg >= 0 ? sprintf("%3u", winddeg) : "---") ~ "*";
		var ktstr = windkt >= 0 ? sprintf("%3u", windkt) : "---";

		if (int(cruiseft))
			cruisefl = int(cruiseft) > ta ?
				sprintf("FL%u", int(cruiseft / 100))
				: sprintf("%5.0f", cruiseft);

		title = "PERF INIT";
		page = "1/2";
		line1lt = "GW/CRZ CG";
		line1rt = "TRIP/CRZ ALT";
		# TODO: calculate TRIP altitude
		line1r = "/" ~ cruisefl;
		line2lt = "PLAN/FUEL";
		line2rt = "CRZ WIND";
		line2r = sprintf("%s/%s", degstr, ktstr);
		line3lt = "ZFW";
		# TODO: calculate fuel usage
		line4lt = "RESERVES";
		line4l = int(reserve) > 0 ? sprintf("%3.1f", reserve / 1000) : "__._";
		line5lt = "COST INDEX";
		line5l = int(ci) >= 0 ? sprintf("%u", ci) : "___";
		line5rt = "TRANS ALT";
		line5r = sprintf("%u", ta);
		line6bar = bar();
		line6l = "<INDEX";
		line6r = "N1 LIMIT>";

		var cg = getprop("/instrumentation/fmc/cg");
		var gcw = getgcw();
		var fuel = 0;
		var zfw = 0;

		if (getprop("/sim/flight-model") == "jsb") {
			fuel = getprop("/fdm/jsbsim/propulsion/total-fuel-lbs");
			zfw = getprop("/fdm/jsbsim/inertia/empty-weight-lbs");
		}
		else if (getprop("/sim/flight-model") == "yasim") {
			fuel = getprop("/consumables/fuel/total-fuel-lbs");
			zfw = getprop("/yasim/gross-weight-lbs");
			zfw -= getprop("/consumables/fuel/total-fuel-lbs");
			yasim_weights = props.globals.getNode("/sim").getChildren("weight");

			for (var i = 0; i < size(yasim_weights); i += 1) {
				yasim_emptyweight -= yasim_weights[i].getChild("weight-lb").getValue();
			}
		}

		line1l = sprintf("%3.1f/%2.1f%%", gcw / 1000, cg);
		line2l = sprintf("    /%2.1f", fuel / 1000);
		line3l = sprintf("%3.1f", zfw / 1000);
	}
	else if (display == "POS_INIT") {
		var lat = getprop("/instrumentation/fmc/last-pos-latitude");
		var lon = getprop("/instrumentation/fmc/last-pos-longitude");
		var hour = getprop("/sim/time/utc/hour");
		var min = getprop("/sim/time/utc/minute");
		var sec = getprop("/sim/time/utc/second") / 6;
		var month = getprop("/sim/time/utc/month");
		var day = getprop("/sim/time/utc/day");

		if (lat != "" and lon != "")
			line1r = lattodmm(lat) ~ " " ~ lontodmm(lon);
		else
			line1r = "---*--.- ---*--.-";

		title = "POS INIT";
		page = "1/3";
		line1rt = "LAST POS";
		line2lt = "REF AIRPORT";
		if (getprop("/instrumentation/fmc/ref-airport") != ""){
			line2l = getprop("/instrumentation/fmc/ref-airport");
			line2r = refairport.lat ~ " " ~ refairport.lon;
		} else{
			line2l = "----";
		}
		line3lt = "GATE";
		line3l = gate != nil ? gate.name : "-----";
		line4rt = "SET IRS POS";
		line4r = irspos();
		line5lt = "GMT-MON/DY";
		line5l = sprintf("%02u%02u.%uz %02u/%02u", hour, min, sec, month, day);
		line6bar = bar();
		line6l = "<INDEX";
		line6r = "ROUTE>";
	}
	else if (display == "POS_REF") {
		var lat = lattodmm(getprop("/position/latitude-deg"));
		var lon = lontodmm(getprop("/position/longitude-deg"));
		var pos = lat ~ " " ~ lon;
		var gs = int(getprop("/velocities/groundspeed-kt"));

		title = "POS REF";
		page = "2/3";
		line1lt = "FMC POS";
		line1rt = "GS";
		line1r = gs ? sprintf("%uKT", gs) : "";
		line2lt = "IRS L";
		line3lt = "IRS R";
		line4lt = "GPS L";
		line4l = pos;
		line5lt = "GPS R";
		line5l = pos;
		line6lt = "RADIO";
	}
	else if (display == "POS_SHIFT") {
		title = "POS SHIFT";
		page = "3/3";
		line2lt = "GPS-L";
		line2ct = "GPS(L)";
		line2rt = "GPS-R";
		line3lt = "IRS-L";
		line3ct = "IRS(L)";
		line3rt = "IRS-R";
		line4lt = "RNP/ACTUAL";
		line4l = "2.00/0.01NM";
		line4rt = "RADIO";
		line5r = "NAV STATUS>";
		line6l = "<INDEX";
	}
	else if (display == "RTE1_RTE") {
		var active = getprop("/autopilot/route-manager/active");
		var armed = getprop("/autopilot/route-manager/armed");

		page = sprintf("%u/%u", rtepage[num], getrtepages());
		title = active ? "ACT RTE" : "RTE";

		if (active or armed)
			line6r = "PERF INIT>";
		else if (getprop("/autopilot/route-manager/route/num"))
			line6r = "ACTIVATE>";

		if (rtepage[num] == 1) {
			var runway = getprop("/autopilot/route-manager/departure/runway");
			var co_route = getprop("/instrumentation/fmc/co-route");
			var origin = getprop("/autopilot/route-manager/departure/airport");
			var dest = getprop("/autopilot/route-manager/destination/airport");

			line1lt = "ORIGIN";
			line1l = origin != "" ? origin : "-----";
			line1rt = "DEST";
			line1r = dest != "" ? dest : "_____";
			line2lt = "CO ROUTE";
			line2l = co_route != "" ? co_route : "------";
			line3lt = "RUNWAY";

			if (runway != "")
				line3l = runway;

			line4c = bar();
		} else {
			line1lt = "VIA";
			line1rt = "TO";
			line6bar = bar();

			for (var i = 0; i < 6; i += 1) {
				# wp[0] is not shown here.
				var offset = 5 * (rtepage[num] - 2) + 1 + i;
				var wp = sprintf("/autopilot/route-manager/route/wp[%u]/id", offset);
				var id = getprop(wp);
				var viap = sprintf("/instrumentation/fmc/via[%u]", offset);
				var via = getprop(viap);

				if (id != nil) {
					if (via == nil or via == "")
						via = "DIRECT";

					if (i == 0) {
						line1l = via;
						line1r = id;
					}
					else if (i == 1) {
						line2l = via;
						line2r = id;
					}
					else if (i == 2) {
						line3l = via;
						line3r = id;
					}
					else if (i == 3) {
						line4l = via;
						line4r = id;
					}
					else if (i == 4) {
						line5l = via;
						line5r = id;
					}
				}
				else {
					var n = getprop("/autopilot/route-manager/route/num");

					if (via == nil or via == "")
						via = "-----";

					if (!n) {
						line1l = via;
						line1r = "-----";
					}
					else if (offset == n) {
						if (i == 0) {
							line1l = via;
							line1r = "-----";
						}
						else if (i == 1) {
							line2l = via;
							line2r = "-----";
						}
						else if (i == 2) {
							line3l = via;
							line3r = "-----";
						}
						else if (i == 3) {
							line4l = via;
							line4r = "-----";
						}
						else if (i == 4) {
							line5l = via;
							line5r = "-----";
						}
					}
				}
			}
		}
	}
	else if (display == "RTE1_ARR") {
		var airport = getprop("/autopilot/route-manager/destination/airport");
		var star = getprop("/autopilot/route-manager/destination/approach");
		var runway = getprop("/autopilot/route-manager/destination/runway");
		var npages = arrpages();

		if (arrpage[num] > npages)
			arrpage[num] = npages;

		title = "ARRIVALS";

		if (airport != "")
			title = airport ~ " " ~ title;

		line1lt = "STARS";
		page = sprintf("%u/%u", arrpage[num], npages);
		line6bar = bar();

		if (star != "") {
			line1l = star ~ "<SEL>";
			line2lt = "TRANS";
			line2l = "-NONE-";
		}
		else {
			var arroffset = 5 * (arrpage[num] - 1);
			var i = 0;

			foreach (var star; getstars(airport, runway)) {
				if (i == arroffset)
					line1l = star.name;
				else if (i == arroffset + 1)
					line2l = star.name;
				else if (i == arroffset + 2)
					line3l = star.name;
				else if (i == arroffset + 3)
					line4l = star.name;
				else if (i == arroffset + 4)
					line5l = star.name;

				i = i + 1;
			}

			if (i == 0 or i == 1) {
				line2lt = "TRANS";
				line2l = "-NONE-";
			}
			else if (i == 2) {
				line3lt = "TRANS";
				line3l = "-NONE-";
			}
			else if (i == 3) {
				line4lt = "TRANS";
				line4l = "-NONE-";
			}
			else if (i == 4) {
				line5lt = "TRANS";
				line5l = "-NONE-";
			}
		}

		line1rt = "RUNWAYS";

		if (airport != "") {
			var info = airportinfo(airport);

			if (info != nil) {
				var arroffset = 5 * (arrpage[num] - 1);
				var i = 0;

				foreach (var r; keys(info.runways)) {
					# On a real 737-800, only the selected runway is shown,
					# if it exists. However, FlightGear does not allow to
					# unselect the destination runway, so a compromise the
					# CDU will always list all runways.
					if (runway != "" and r == runway)
						r = "<SEL>" ~ r;

					if (i == arroffset)
						line1r = r;
					else if (i == arroffset +1)
						line2r = r;
					else if (i == arroffset + 2)
						line3r = r;
					else if (i == arroffset + 3)
						line4r = r;
					else if (i == arroffset + 4)
						line5r = r;

					i = i + 1;
				}
			}
		}

		line6l = "<INDEX";
		line6r = "ROUTE>";
	}
	else if (display == "RTE1_DEP") {
		var airport = getprop("/autopilot/route-manager/departure/airport");
		var sid = getprop("/autopilot/route-manager/departure/sid");
		var runway = getprop("/autopilot/route-manager/departure/runway");
		var npages = depspages();

		if (depspage[num] > npages)
			depspage[num] = npages;

		title = "DEPARTURES";

		if (airport != "")
			title = airport ~ " " ~ title;

		line1lt = "SIDS";
		page = sprintf("%u/%u", depspage[num], npages);
		line6bar = bar();

		if (sid != "") {
			line1l = sid ~ "<SEL>";
			line2lt = "TRANS";
			line2l = "-NONE-";
		}
		else {
			var depsoffset = 5 * (depspage[num] - 1);
			var i = 0;

			foreach (var sid; getsids(airport, runway)) {
				if (i == depsoffset)
					line1l = sid.name;
				else if (i == depsoffset + 1)
					line2l = sid.name;
				else if (i == depsoffset + 2)
					line3l = sid.name;
				else if (i == depsoffset + 3)
					line4l = sid.name;
				else if (i == depsoffset + 4)
					line5l = sid.name;

				i = i + 1;
			}

			if (i == 0 or i == 1) {
				line2lt = "TRANS";
				line2l = "-NONE-";
			}
			else if (i == 2) {
				line3lt = "TRANS";
				line3l = "-NONE-";
			}
			else if (i == 3) {
				line4lt = "TRANS";
				line4l = "-NONE-";
			}
			else if (i == 4) {
				line5lt = "TRANS";
				line5l = "-NONE-";
			}
		}

		line1rt = "RUNWAYS";

		if (airport != "") {
			var info = airportinfo(airport);

			if (info != nil) {
				var depsoffset = 5 * (depspage[num] - 1);
				var i = 0;

				foreach (var r; keys(info.runways)) {
					# On a real 737-800, only the selected runway is shown,
					# if it exists. However, FlightGear does not allow to
					# unselect the departure runway, so a compromise the
					# CDU will always list all runways.
					if (runway != "" and r == runway)
						r = "<SEL>" ~ r;

					if (i == depsoffset)
						line1r = r;
					else if (i == depsoffset +1)
						line2r = r;
					else if (i == depsoffset + 2)
						line3r = r;
					else if (i == depsoffset + 3)
						line4r = r;
					else if (i == depsoffset + 4)
						line5r = r;

					i = i + 1;
				}
			}
		}
		line6l = "<INDEX";
		line6r = "ROUTE>";
	}
	else if (display == "RTE1_LEGS") {
		title = "RTE 1 LEGS";

		if (getprop("/autopilot/route-manager/active"))
			title = "ACT " ~ title;

		var setwp = func(num, line) {
			var path = sprintf("/autopilot/route-manager/route/wp[%u]/", num);
			var id = getprop(path ~ "id");

			if (id == nil)
				return;

			var altitude = getprop(path ~ "altitude-ft");
			var altstr = "-----";
			var kts = getprop(path ~ "speed-kts");
			var ktsstr = "";
			var transalt = getprop("/autopilot/settings/transition-altitude");

			if (altitude > transalt)
				altstr = sprintf("FL%3.0f", altitude / 100);
			else if (altitude > 0)
				altstr = sprintf("%5.0f", altitude);

			if (kts != nil)
				ktsstr = sprintf("%.0f", kts);
			else if (altitude < 0)
				ktsstr = "----";

			var altkts = ktsstr ~ "/" ~ altstr;
			var deg = sprintf("%3.0f*", getprop(path ~ "leg-bearing-true-deg"));
			var nm = sprintf("%3.0fNM", getprop(path ~ "leg-distance-nm"));

			if (line == 1) {
				line1lt = deg;
				line1l = id;
				line1r = altkts;

				if (num)
					line1ct = nm;
			} else if (line == 2) {
				line2lt = deg;
				line2l = id;
				line2ct = nm;
				line2r = altkts;
			} else if (line == 3) {
				line3lt = deg;
				line3l = id;
				line3ct = nm;
				line3r = altkts;
			} else if (line == 4) {
				line4lt = deg;
				line4l = id;
				line4ct = nm;
				line4r = altkts;
			} else if (line == 5) {
				line5lt = deg;
				line5l = id;
				line5ct = nm;
				line5r = altkts;
			}
		}

		page = sprintf("%u/%u", legspage[num], getlegspages());

		for (var i = 0; i < 5; i += 1)
			setwp(i + ((legspage[num] - 1) * 5), i + 1);

		line6lt = "RNP/ACTUAL";
		line6bar = "       ----------------";
		line6l = "2.00/0.1NM";

		if (getprop("/autopilot/route-manager/active")
			or getprop("/autopilot/route-manager/armed"))
			line6r = "RTE DATA>";
		else if (getprop("/autopilot/route-manager/route/num"))
			line6r = "ACTIVATE>";
	}
	else if (display == "N1_LIMIT") {
		var n1_26k = getprop("/autopilot/settings/to-n1-26k");
		var degc = getprop("/environment/temperature-degc");

		title = "N1 LIMIT";
		page = "1/1";
		line1lt = "SEL/OAT";
		line1l = sprintf("----/%+3.0f*C", degc);
		line1rt = "26K N1";
		line1r = sprintf("%4.1f/%4.1f", n1_26k, n1_26k);
		line2lt = "26K";
		line2l = "<TO";
		line2r = "CLB>";
		line3lt = "24K DERATE";
		line3l = "<TO-1";
		line3c = "<SEL> <ARM>";
		line4lt = "22K DERATE";
		line3r = "CLB-1>";
		line4lt = "TO 2";
		line4l = "<TO-2";
		line4r = "CLB-2>";
		line5lt = "27K BUMP";
		line5l = "<TO-B";
		line6bar = bar();
		line6l = "<PERF INIT";
		line6r = "TAKEOFF>";
	}
	else if (display == "TO_REF") {
		var to_flap = getprop("/instrumentation/fmc/to-flap");
		var V1 = getprop("/instrumentation/fmc/vspeeds/V1");
		var VR = getprop("/instrumentation/fmc/vspeeds/VR");
		var V2 = getprop("/instrumentation/fmc/vspeeds/V2");
		var rwy = getprop("/autopilot/route-manager/departure/runway");
		var cg = getprop("/instrumentation/fmc/cg");

		title = "TAKEOFF REF";
		line1lt = "FLAPS";
		line1l = int(to_flap) ? sprintf("%u*", to_flap) : "__*";
		line1rt = "V1";
		line1r = V1 ? sprintf("%3.0f", V1) : "---";
		# TODO: determine 26K?
		line2lt = "26K N1";
		line2rt = "VR";
		line2r = VR ? sprintf("%3.0f", VR) : "---";
		# TODO: CG?
		line3lt = "CG";
		line3l = (int(cg) ? sprintf("%3.1f", cg) : "--.-") ~ "%";
		line3rt = "V2";
		line3r = V2 ? sprintf("%3.0f", V2) : "---";
		line4rt = "GW   / TOW";
		line4r = sprintf("%3.1f", getgcw() / 1000) ~ "/     ";
		line5lt = "RUNWAY";
		line5l = rwy != "" ? "RW" ~ rwy : "-----";
		line6bar = "-------------------";
		line6rt = "SELECT";
		line6l = "<INDEX";
		line6r = "QRH OFF>";
	}
	else if (display == "PROG") {
		# Real-life airliners would report the flight number.
		# However, flight numbers cannot be defined in FlightGear,
		# so the callsign is used as a compromise.
		var callsign = getprop("/sim/multiplay/callsign");
		var winddeg = getprop("/environment/wind-from-heading-deg");
		var windkt = getprop("/environment/wind-speed-kt");

		title = "PROGRESS";

		if (callsign != nil and callsign != "") {
			var trunc = toupper(substr(callsign, 0, 6));

			title = trunc ~ " " ~ title;
		}

		# TODO: support 1 page for now
		page = "1/1";
		line1lt = "FROM";
		line1ct = "ALT    ATA";
		line1rt = "FUEL";
		# TODO: deg
		line2lt = "";
		line2ct = "DTG    ETA";
		line2rt = "FUEL";
		# TODO: TO T/C? Determine flight stage.
		line5lt = "TO T/D";
		line5rt = "FUEL QTY";
		line6lt = "WIND";
		line6l = sprintf("%3.0f*/%3.0fKT", winddeg, windkt);
		line6r = "NAV STATUS>";
	}

	if (serviceable != 1){
		title = "";		page = "";
		line1l = "";	line2l = "";	line3l = "";	line4l = "";	line5l = "";	line6l = "";
		line1lt = "";	line2lt = "";	line3lt = "";	line4lt = "";	line5lt = "";	line6lt = "";
		line1c = "";	line2c = "";	line3c = "";	line4c = "";	line5c = "";	line6c = "";
		line1ct = "";	line2ct = "";	line3ct = "";	line4ct = "";	line5ct = "";	line6ct = "";
		line1r = "";	line2r = "";	line3r = "";	line4r = "";	line5r = "";	line6r = "";
		line1rt = "";	line2rt = "";	line3rt = "";	line4rt = "";	line5rt = "";	line6rt = "";
		line6bar = "";
	}

	setprop(cduprop ~ "/output/title", title);
	setprop(cduprop ~ "/output/page", page);
	setprop(cduprop ~ "/output/line1/left", line1l);
	setprop(cduprop ~ "/output/line2/left", line2l);
	setprop(cduprop ~ "/output/line3/left", line3l);
	setprop(cduprop ~ "/output/line4/left", line4l);
	setprop(cduprop ~ "/output/line5/left", line5l);
	setprop(cduprop ~ "/output/line6/left", line6l);
	setprop(cduprop ~ "/output/line1/left-title", line1lt);
	setprop(cduprop ~ "/output/line2/left-title", line2lt);
	setprop(cduprop ~ "/output/line3/left-title", line3lt);
	setprop(cduprop ~ "/output/line4/left-title", line4lt);
	setprop(cduprop ~ "/output/line5/left-title", line5lt);
	setprop(cduprop ~ "/output/line6/left-title", line6lt);
	setprop(cduprop ~ "/output/line1/center", line1c);
	setprop(cduprop ~ "/output/line2/center", line2c);
	setprop(cduprop ~ "/output/line3/center", line3c);
	setprop(cduprop ~ "/output/line4/center", line4c);
	setprop(cduprop ~ "/output/line5/center", line5c);
	setprop(cduprop ~ "/output/line6/center", line6c);
	setprop(cduprop ~ "/output/line1/center-title", line1ct);
	setprop(cduprop ~ "/output/line2/center-title", line2ct);
	setprop(cduprop ~ "/output/line3/center-title", line3ct);
	setprop(cduprop ~ "/output/line4/center-title", line4ct);
	setprop(cduprop ~ "/output/line5/center-title", line5ct);
	setprop(cduprop ~ "/output/line6/center-title", line6ct);
	setprop(cduprop ~ "/output/line1/right", line1r);
	setprop(cduprop ~ "/output/line2/right", line2r);
	setprop(cduprop ~ "/output/line3/right", line3r);
	setprop(cduprop ~ "/output/line4/right", line4r);
	setprop(cduprop ~ "/output/line5/right", line5r);
	setprop(cduprop ~ "/output/line6/right", line6r);
	setprop(cduprop ~ "/output/line1/right-title", line1rt);
	setprop(cduprop ~ "/output/line2/right-title", line2rt);
	setprop(cduprop ~ "/output/line3/right-title", line3rt);
	setprop(cduprop ~ "/output/line4/right-title", line4rt);
	setprop(cduprop ~ "/output/line5/right-title", line5rt);
	setprop(cduprop ~ "/output/line6/right-title", line6rt);
	setprop(cduprop ~ "/output/line6/bar", line6bar);
}

var cdustatus = func {
	var dcl = getprop("/systems/electrical/bus/dcL");
	var dcr = getprop("/systems/electrical/bus/dcR");

	# There is a possible race condition on startup, where one of
	# the values has not been defined yet.
	if (dcl != nil and dcr != nil) {
		var value = dcl >= 15 or dcr >= 15;

		setprop("/instrumentation/cdu[0]/serviceable", value);
		setprop("/instrumentation/cdu[1]/serviceable", value);
	}
	else {
		setprop("/instrumentation/cdu[0]/serviceable", 0);
		setprop("/instrumentation/cdu[1]/serviceable", 0);
	}
}

var CAPTAIN = 0;
var FIRST_OFFICER = 1;

var captcdu = func {
	cdu(CAPTAIN);
	settimer(captcdu, 0.2);
}

var focdu = func {
	cdu(FIRST_OFFICER);
	settimer(focdu, 0.2);
}

var init = func(num) {
	var cduprop = sprintf("/instrumentation/cdu[%u]", num);

	setprop(cduprop ~ "/serviceable", 0);
	setprop(cduprop ~ "/display", "IDENT");
	setprop(cduprop ~ "/input", "");
	setprop(cduprop ~ "/ident/model", "737-800YV");
}

var wpchanged = func(num) {
	var cduprop = sprintf("/instrumentation/cdu[%u]", num);
	var display = getprop(cduprop ~ "/display");
	var cwp = getprop("/autopilot/route-manager/current-wp");

	if (display != "RTE1_LEGS" or cwp == nil or cwp < 0)
		return;

	legspage[num] = 1 + cwp / 5;
}

var wpchangedcapt = func {
	wpchanged(CAPTAIN);
}

var wpchangedfo = func {
	wpchanged(FIRST_OFFICER);
}

init(CAPTAIN);
init(FIRST_OFFICER);
setprop("/instrumentation/fmc/irs-latitude", "");
setprop("/instrumentation/fmc/irs-longitude", "");
setprop("/instrumentation/fmc/last-pos-latitude", "");
setprop("/instrumentation/fmc/last-pos-longitude", "");
setprop("/instrumentation/fmc/ref-airport", "");
setprop("/instrumentation/fmc/co-route", "");
getprop("/instrumentation/fmc/to-flap", 0);
setprop("/instrumentation/fmc/cost-index", -1);
setprop("/instrumentation/fmc/reserve-fuel-lbs", 0);
setprop("/instrumentation/fmc/cruise-wind-deg", -1);
setprop("/instrumentation/fmc/cruise-wind-kt", -1);
setprop("/instrumentation/fmc/perf-init/armed", 0);
setprop("/autopilot/route-manager/armed", 0);
setprop("/autopilot/settings/transition-altitude", 18000);
setlistener("/systems/electrical/bus/dcL", cdustatus);
setlistener("/systems/electrical/bus/dcR", cdustatus);
setlistener("/sim/signals/fdm-initialized", captcdu);
setlistener("/sim/signals/fdm-initialized", focdu);
setlistener("/autopilot/route-manager/current-wp", wpchangedcapt);
setlistener("/autopilot/route-manager/current-wp", wpchangedfo);
