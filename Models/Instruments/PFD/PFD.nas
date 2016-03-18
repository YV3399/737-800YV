# ==============================================================================
# Original Boeing 747-400 pfd by Gijs de Rooy
# Modified for 737-800 by Michael Soitanen
# ==============================================================================

var roundToNearest = func(n, m) {
	var x = int(n/m)*m;
	if((math.mod(n,m)) > (m/2) and n > 0)
			x = x + m;
	if((m - (math.mod(n,m))) > (m/2) and n < 0)
			x = x - m;
	return x;
}

var normten = func(x) {
	while (x < 0)
		x += 10;
	while (x >= 10)
		x -= 10;
	return x;
}

var pfd_canvas = nil;
var pfd_display = nil;

var canvas_PFD = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_PFD] };
		var pfd = canvas_group;
		var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(pfd, "Aircraft/737-800/Models/Instruments/PFD/PFD.svg", {'font-mapper': font_mapper});
		
		var svg_keys = ["afdsMode","afdsModeBox","altTape","altText1","altText2","atMode",
		"altTapeScale","altTextHigh1","altTextHigh2","altTextHigh3","altTextHigh4","altTextHigh5",
		"altTextLow1","altTextLow2","altTextLow3","altTextLow4",
		"altTextHighSmall2","altTextHighSmall3","altTextHighSmall4","altTextHighSmall5",
		"altTextLowSmall1","altTextLowSmall2","altTextLowSmall3","altTextLowSmall4",
		"altMinus",
		"bankPointer","slipSkid","baroSet","baroUnit","baroStd","baroPreSet","baroPreSetUnit",
		"cmdSpd","trkLine","compassBack",
		"selHdg",
		"curAltDig1","curAltDig1Low","curAltDig1High",
		"curAltDig2","curAltDig2Low","curAltDig2High",
		"curAltDig3","curAltDig3Low","curAltDig3High",
		"curAltDig45","curAltDig45High1","curAltDig45High2","curAltDig45Low1","curAltDig45Low2",
		"curAltBox","curAltMtrTxt","curSpdDig1","curSpdDig2","curSpdDig3",
		"dhText","dmeDist","fdX","fdY",
		"compassLMark1","compassLMark2","compassLMark3","compassLMark4","compassLMark5","compassLMark6","compassLMark7","compassLMark8",
		"compassSMark1","compassSMark2","compassSMark3","compassSMark4","compassSMark5","compassSMark6","compassSMark7","compassSMark8",
		"compassLNmbr1","compassLNmbr2","compassLNmbr3",
		"compassSNmbr1","compassSNmbr2","compassSNmbr3","compassSNmbr4","compassSNmbr5","compassSNmbr6",
		"fpv",
		"flaps-mark-1","flaps-mark-1-txt","flaps-mark-2","flaps-mark-2-txt","flaps-mark-3","flaps-mark-3-txt","flaps-mark-4","flaps-mark-4-txt","flaps-mark-5","flaps-mark-5-txt",
		"gpwsAlert","gsPtr","gsScale","gsText","horizon","ilsId","locPtr","locScale","locScaleExp","scaleCenter","machText",
		"ladderLimiter",
		"markerBeacon","markerBeaconText","maxSpdInd","mcpAltMtr","minimums","minSpdInd","metric",
		"pitchMode","pitchArmMode","radioAltInd","risingRwy","risingRwyPtr","rollMode","rollArmMode",
		"selAltBox","selAltPtr","selHdgText","spdTape","spdTrend","speedText","spdTapeWhiteBug",
		"singleCh","singleChBox",
		"tenThousand","touchdown",
		"v1","v2","vertSpdUp","vertSpdDn","vr","vref",
		"vsiNeedle","vsPointer","spdModeChange","rollModeChange","pitchModeChange", "bankPointerTriangle"];
		foreach(var key; svg_keys) {
			m[key] = pfd.getElementById(key);
		}
		debug.dump(m["horizon"].getCenter());
		m.h_trans = m["horizon"].createTransform();
		m.h_rot = m["horizon"].createTransform();
		
		var c1 = m["spdTrend"].getCenter();
		m["spdTrend"].createTransform().setTranslation(-c1[0], -c1[1]);
		m["spdTrend_scale"] = m["spdTrend"].createTransform();
		m["spdTrend"].createTransform().setTranslation(c1[0], c1[1]);
		var c2 = m["risingRwyPtr"].getCenter();
		m["risingRwyPtr"].createTransform().setTranslation(-c2[0], -c2[1]);
		m["risingRwyPtr_scale"] = m["risingRwyPtr"].createTransform();
		m["risingRwyPtr"].createTransform().setTranslation(c2[0], c2[1]);
		var c3 = m["compassBack"].getCenter();
		m["selHdg"].setCenter(c3[0], c3[1]);
		m["trkLine"].setCenter(c3[0], c3[1]);
		m["compassLMark1"].setCenter(c3[0], c3[1]);
		m["compassLMark2"].setCenter(c3[0], c3[1]);
		m["compassLMark3"].setCenter(c3[0], c3[1]);
		m["compassLMark4"].setCenter(c3[0], c3[1]);
		m["compassLMark5"].setCenter(c3[0], c3[1]);
		m["compassLMark6"].setCenter(c3[0], c3[1]);
		m["compassLMark7"].setCenter(c3[0], c3[1]);
		m["compassLMark8"].setCenter(c3[0], c3[1]);
		m["compassSMark1"].setCenter(c3[0], c3[1]);
		m["compassSMark2"].setCenter(c3[0], c3[1]);
		m["compassSMark3"].setCenter(c3[0], c3[1]);
		m["compassSMark4"].setCenter(c3[0], c3[1]);
		m["compassSMark5"].setCenter(c3[0], c3[1]);
		m["compassSMark6"].setCenter(c3[0], c3[1]);
		m["compassSMark7"].setCenter(c3[0], c3[1]);
		m["compassSMark8"].setCenter(c3[0], c3[1]);
		m["compassLNmbr1"].setCenter(c3[0], c3[1]);
		m["compassLNmbr2"].setCenter(c3[0], c3[1]);
		m["compassLNmbr3"].setCenter(c3[0], c3[1]);
		m["compassSNmbr1"].setCenter(c3[0], c3[1]);
		m["compassSNmbr2"].setCenter(c3[0], c3[1]);
		m["compassSNmbr3"].setCenter(c3[0], c3[1]);
		m["compassSNmbr4"].setCenter(c3[0], c3[1]);
		m["compassSNmbr5"].setCenter(c3[0], c3[1]);
		m["compassSNmbr6"].setCenter(c3[0], c3[1]);
		var c4 = m["horizon"].getCenter();
		m["ladderLimiter"].setCenter(c4[0], c4[1]);

		
		m["horizon"].set("clip", "rect(220.816, 693.673, 750.887, 192.606)");
		m["ladderLimiter"].set("clip", "rect(220.816, 693.673, 750.887, 192.606)");
		m["fpv"].set("clip", "rect(220.816, 693.673, 750.887, 192.606)");
		m["minSpdInd"].set("clip", "rect(126.5, 1024, 863.76, 0)");
		m["maxSpdInd"].set("clip", "rect(126.5, 1024, 863.76, 0)");
		m["spdTape"].set("clip", "rect(126.5, 1024, 863.76, 0)");
		m["spdTrend"].set("clip", "rect(126.5, 1024, 863.76, 0)");
		m["cmdSpd"].set("clip", "rect(126.5, 1024, 863.76, 0)");
		m["spdTapeWhiteBug"].set("clip", "rect(126.5, 1024, 863.76, 0)");
		m["altTapeScale"].set("clip", "rect(126.5, 1024, 863.76, 0)");
		m["altTape"].set("clip", "rect(126.5, 1024, 863.76, 0)");
		m["selAltPtr"].set("clip", "rect(126.5, 1024, 863.76, 0)");
		m["vsiNeedle"].set("clip", "rect(287, 1024, 739, 965)");
		m["curAltDig45"].set("clip", "rect(456, 1024, 539, 0)");
		m["curAltDig3"].set("clip", "rect(456, 1024, 539, 0)");
		m["curAltDig2"].set("clip", "rect(456, 1024, 539, 0)");
		m["curAltDig1"].set("clip", "rect(456, 1024, 539, 0)");
		m["tenThousand"].set("clip", "rect(456, 1024, 539, 0)");
		m["altMinus"].set("clip", "rect(456, 1024, 539, 0)");
		m["curSpdDig3"].set("clip", "rect(456, 1024, 539, 0)");
		m["curSpdDig1"].set("clip", "rect(456, 1024, 539, 0)");
		m["curSpdDig2"].set("clip", "rect(456, 1024, 539, 0)");
		m["risingRwy"].set("clip", "rect(0, 693.673, 1024, 192.606)");

		m.update_ap_modes();

		return m;
	},
	update: func()
	{
		var radioAlt = getprop("instrumentation/radar-altimeter/radar-altitude-ft") or 0;
		var alt = getprop("instrumentation/altimeter/indicated-altitude-ft");
		var ias = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
		if (ias < 45)
			ias = 45;
		var gs = getprop("velocities/groundspeed-kt");
		var mach = getprop("instrumentation/airspeed-indicator/indicated-mach");
		var pitch = getprop("orientation/pitch-deg");
		var path = getprop("orientation/path-deg");
		var roll =  getprop("orientation/roll-deg");
		var slipSkid = getprop("instrumentation/slip-skid-ball/indicated-slip-skid");
		var hdg =  getprop("orientation/heading-magnetic-deg");
		var track = getprop("/orientation/track-magnetic-deg");
		var vSpd = getprop("/velocities/vertical-speed-fps");
		var air_ground = getprop("/b737/sensors/air-ground");
		if ( air_ground == "ground") var wow = 1;
		else var wow = 0;
		var apAlt = getprop("autopilot/settings/target-altitude-mcp-ft");
		var apSpd = getprop("autopilot/settings/target-speed-kt");
		var apHdg = getprop("autopilot/settings/heading-bug-deg");
		var metricMode = getprop("instrumentation/efis[0]/inputs/alt-meters");
		var baroStdSet = getprop("instrumentation/efis[0]/inputs/setting-std");
		var baroPreSetShow = getprop("instrumentation/efis[0]/inputs/baro-previous-show");
		var fpv = getprop("instrumentation/efis[0]/inputs/fpv");

		if (metricMode) {
			me["metric"].show();
		} else {
			me["metric"].hide();
		}

		if (baroStdSet) {
			me["baroStd"].show();
			me["baroSet"].hide();
			me["baroUnit"].hide();
		} else {
			me["baroStd"].hide();
			me["baroSet"].show();
			me["baroUnit"].show();
			me["baroPreSet"].hide();
			me["baroPreSetUnit"].hide();
		}

		if (baroStdSet and baroPreSetShow) {
			me["baroPreSet"].show();
			me["baroPreSetUnit"].show();
			var pressureUnit = getprop("instrumentation/efis[0]/inputs/kpa-mode");
			if ( pressureUnit == 0 ) {
				me["baroPreSet"].setText(sprintf("%2.2f",getprop("instrumentation/efis[0]/inputs/baro-previous")));
				me["baroPreSetUnit"].setText("IN");
			} else {
				me["baroPreSet"].setText(sprintf("%4.0f",getprop("instrumentation/efis[0]/inputs/baro-previous")));
				me["baroPreSetUnit"].setText("HPA");
			}
		}


		
		me.h_trans.setTranslation(0,pitch*11.4625);
		me.h_rot.setRotation(-roll*D2R,me["horizon"].getCenter());
		
		me["slipSkid"].setTranslation(slipSkid*-8,0);
		me["bankPointer"].setRotation(-roll*D2R);
		me["ladderLimiter"].setRotation(-roll*D2R);

		if (math.abs(roll) < 35) {
			me["bankPointerTriangle"].setColor(1,1,1);
			me["bankPointerTriangle"].setColorFill(0,0.477,0.725,1);
			me["slipSkid"].setColor(1,1,1);
		} else {
			me["bankPointerTriangle"].setColor(1,0.749,0);
			me["bankPointerTriangle"].setColorFill(1,0.749,0,1);
			me["slipSkid"].setColor(1,0.749,0);
		}
		
		var hdgDiff = geo.normdeg180(hdg - apHdg);
		if ( hdgDiff < -35 ) hdgDiff = -35;
		if ( hdgDiff > 35 ) hdgDiff = 35;
		me["selHdg"].setRotation(-hdgDiff*1.58*D2R); # 1.58 - coefficient for compass
		var trkDiff = geo.normdeg180(hdg - track);
		if (gs < 5) trkDiff = 0;
		me["trkLine"].setRotation(-trkDiff*1.58*D2R);
		me["compassLMark1"].setRotation((hdg-(roundToNearest(hdg, 10)-40))*-1*1.58*D2R);
		me["compassLMark2"].setRotation((hdg-(roundToNearest(hdg, 10)-30))*-1*1.58*D2R);
		me["compassLMark3"].setRotation((hdg-(roundToNearest(hdg, 10)-20))*-1*1.58*D2R);
		me["compassLMark4"].setRotation((hdg-(roundToNearest(hdg, 10)-10))*-1*1.58*D2R);
		me["compassLMark5"].setRotation((hdg-(roundToNearest(hdg, 10)-0))*-1*1.58*D2R);
		me["compassLMark6"].setRotation((hdg-(roundToNearest(hdg, 10)+10))*-1*1.58*D2R);
		me["compassLMark7"].setRotation((hdg-(roundToNearest(hdg, 10)+20))*-1*1.58*D2R);
		me["compassLMark8"].setRotation((hdg-(roundToNearest(hdg, 10)+30))*-1*1.58*D2R);
		me["compassSMark1"].setRotation((hdg-(roundToNearest(hdg, 10)-35))*-1*1.58*D2R);
		me["compassSMark2"].setRotation((hdg-(roundToNearest(hdg, 10)-25))*-1*1.58*D2R);
		me["compassSMark3"].setRotation((hdg-(roundToNearest(hdg, 10)-15))*-1*1.58*D2R);
		me["compassSMark4"].setRotation((hdg-(roundToNearest(hdg, 10)-5))*-1*1.58*D2R);
		me["compassSMark5"].setRotation((hdg-(roundToNearest(hdg, 10)+5))*-1*1.58*D2R);
		me["compassSMark6"].setRotation((hdg-(roundToNearest(hdg, 10)+15))*-1*1.58*D2R);
		me["compassSMark7"].setRotation((hdg-(roundToNearest(hdg, 10)+25))*-1*1.58*D2R);
		me["compassSMark8"].setRotation((hdg-(roundToNearest(hdg, 10)+35))*-1*1.58*D2R);
		me["compassLNmbr1"].setRotation((hdg-(roundToNearest(hdg, 30)-30))*-1*1.58*D2R);
		me["compassLNmbr2"].setRotation((hdg-(roundToNearest(hdg, 30)-00))*-1*1.58*D2R);
		me["compassLNmbr3"].setRotation((hdg-(roundToNearest(hdg, 30)+30))*-1*1.58*D2R);
		me["compassSNmbr1"].setRotation((hdg-(roundToNearest(hdg, 30)-40))*-1*1.58*D2R);
		me["compassSNmbr2"].setRotation((hdg-(roundToNearest(hdg, 30)-20))*-1*1.58*D2R);
		me["compassSNmbr3"].setRotation((hdg-(roundToNearest(hdg, 30)-10))*-1*1.58*D2R);
		me["compassSNmbr4"].setRotation((hdg-(roundToNearest(hdg, 30)+10))*-1*1.58*D2R);
		me["compassSNmbr5"].setRotation((hdg-(roundToNearest(hdg, 30)+20))*-1*1.58*D2R);
		me["compassSNmbr6"].setRotation((hdg-(roundToNearest(hdg, 30)+40))*-1*1.58*D2R);
		var LNmbr1 = (roundToNearest(hdg, 30)-30)/10;
		var LNmbr2 = roundToNearest(hdg, 30)/10;
		var LNmbr3 = (roundToNearest(hdg, 30)+30)/10;
		if (LNmbr1 == 36) LNmbr1 = 0;
		if (LNmbr2 == 36) LNmbr2 = 0;
		if (LNmbr3 == 36) LNmbr3 = 0;
		var SNmbr1 = geo.normdeg((roundToNearest(hdg, 30)-40))/10;
		var SNmbr2 = geo.normdeg((roundToNearest(hdg, 30)-20))/10;
		var SNmbr3 = geo.normdeg((roundToNearest(hdg, 30)-10))/10;
		var SNmbr4 = geo.normdeg((roundToNearest(hdg, 30)+10))/10;
		var SNmbr5 = geo.normdeg((roundToNearest(hdg, 30)+20))/10;
		var SNmbr6 = geo.normdeg((roundToNearest(hdg, 30)+40))/10;
		me["compassLNmbr1"].setText(sprintf("%0.0f", LNmbr1));
		me["compassLNmbr2"].setText(sprintf("%0.0f", LNmbr2));
		me["compassLNmbr3"].setText(sprintf("%0.0f", LNmbr3));
		me["compassSNmbr1"].setText(sprintf("%0.0f", SNmbr1));
		me["compassSNmbr2"].setText(sprintf("%0.0f", SNmbr2));
		me["compassSNmbr3"].setText(sprintf("%0.0f", SNmbr3));
		me["compassSNmbr4"].setText(sprintf("%0.0f", SNmbr4));
		me["compassSNmbr5"].setText(sprintf("%0.0f", SNmbr5));
		me["compassSNmbr6"].setText(sprintf("%0.0f", SNmbr6));
			
		# Flight director
		if (getprop("/instrumentation/flightdirector/fd-left-on") == 1) {
			if (getprop("/instrumentation/flightdirector/fd-left-bank") != nil) {
				var fdRoll = (roll-getprop("/instrumentation/flightdirector/fd-left-bank"))*3;
				if (fdRoll > 200)
					fdRoll = 200;
				elsif (fdRoll < -200)
					fdRoll = -200;
				me["fdX"].setTranslation(-fdRoll,0);
			}
			if (getprop("/instrumentation/flightdirector/fd-left-pitch") != nil) {
				var fdPitch = (pitch-getprop("/instrumentation/flightdirector/fd-left-pitch"))*11.4625;
				if (fdPitch > 200)
					fdPitch = 200;
				elsif (fdPitch < -200)
					fdPitch = -200;
				me["fdY"].setTranslation(0,fdPitch);
			}
			me["fdX"].show();
			me["fdY"].show();
		} else {
			me["fdX"].hide();
			me["fdY"].hide();
		}
		
		var speedDiff = apSpd-ias;
		if ( speedDiff < -60 ) speedDiff = -60;
		if ( speedDiff > 60 ) speedDiff = 60;
		me["cmdSpd"].setTranslation(0,-(speedDiff)*6.145425);

		if (mach > 0.4) setprop("instrumentation/pfd/display-mach", 1);
		if (mach < 0.38) setprop("instrumentation/pfd/display-mach", 0);
		var displayMach = getprop("instrumentation/pfd/display-mach");
		if ( displayMach ) {
			me["gsText"].hide();
			me["machText"].setText(sprintf(".%3.0f",mach*1000));
			me["machText"].setTranslation(0,0);
		} else {
			me["gsText"].show();
			me["machText"].setText(sprintf("%.0f",gs));
			me["machText"].setTranslation(15,0);
		}
		me["altText1"].setText(sprintf("%2.0f",math.floor(apAlt/1000)));
		me["altText2"].setText(sprintf("%03.0f",math.mod(apAlt,1000)));
		me["mcpAltMtr"].setText(sprintf("%5.0f",apAlt*FT2M));

		if (alt >= 10000 ) {
			var altTenThousand = 20;
		} elsif (alt > 9980 and alt < 10000) {
			var altTenThousand = math.mod(alt,20);
		} elsif (alt > 0 and alt <= 9980) {
			var altTenThousand = 0;
		} elsif (alt < -20) {
			var altTenThousand = -20;
		} else {
			var altTenThousand = math.mod(alt,20)-20;
		}
		me["tenThousand"].setTranslation(0,altTenThousand*66/20);

		if (alt < -20) {
			var altMinus = 0;
		} elsif (alt > 0) {
			var altMinus = 20
		} else {
			var altMinus = math.mod(alt,20);
		}
		me["altMinus"].setTranslation(0,altMinus*66/20);

		if (alt > 0) {
			var altDig1High = sprintf("%1.0f",math.fmod(math.floor(alt/10000)+1,10));
			var altDig1Low = sprintf("%1.0f",math.fmod(math.floor(alt/10000),10));
		} else {
			var altDig1High = sprintf("%1.0f",normten(math.abs(math.fmod(math.floor((alt-20)/10000),10))-2));
			var altDig1Low = sprintf("%1.0f",normten(math.abs(math.fmod(math.floor((alt-20)/10000),10))-1));
		}
		if (altDig1High == 0) altDig1High = "";
		if (altDig1Low == 0) altDig1Low = "";
		me["curAltDig1High"].setText(altDig1High);
		me["curAltDig1Low"].setText(altDig1Low);
		if (math.abs(alt) < 50) {
			var curAltDig1Add = 0;
		} elsif (math.abs(math.fmod(alt,10000)) > 9980 and math.abs(math.fmod(alt,10000)) < 10000) {
			var curAltDig1Add = math.mod(alt,20);
		} else {
			var curAltDig1Add = 0;
		}
		me["curAltDig1"].setTranslation(0,curAltDig1Add*64/20);
		
		if (alt > 0) {
			me["curAltDig2High"].setText(sprintf("%1.0f",math.fmod(math.floor(alt/1000)+1,10)));
			me["curAltDig2Low"].setText(sprintf("%1.0f",math.fmod(math.floor(alt/1000),10)));
		} else {
			me["curAltDig2High"].setText(sprintf("%1.0f",normten(math.abs(math.fmod(math.floor((alt-20)/1000),10))-2)));
			me["curAltDig2Low"].setText(sprintf("%1.0f",normten(math.abs(math.fmod(math.floor((alt-20)/1000),10))-1)));
		}
		if (math.abs(alt) < 50) {
			var curAltDig2Add = 0;
		} elsif (math.abs(math.fmod(alt,1000)) > 980 and math.abs(math.fmod(alt,1000)) < 1000) {
			var curAltDig2Add = math.mod(alt,20);
		} else {
			var curAltDig2Add = 0;
		}
		me["curAltDig2"].setTranslation(0,curAltDig2Add*64/20);

		if (alt > 0) {
			me["curAltDig3High"].setText(sprintf("%1.0f",math.fmod(math.floor(alt/100)+1,10)));
			me["curAltDig3Low"].setText(sprintf("%1.0f",math.fmod(math.floor(alt/100),10)));
		} else {
			me["curAltDig3High"].setText(sprintf("%1.0f",normten(math.abs(math.fmod(math.floor((alt-20)/100),10))-2)));
			me["curAltDig3Low"].setText(sprintf("%1.0f",normten(math.abs(math.fmod(math.floor((alt-20)/100),10))-1)));
		}
		if (math.abs(alt) < 50) {
			var curAltDig3Add = 0;
		} elsif (math.abs(math.fmod(alt,100)) > 80 and math.abs(math.fmod(alt,100)) < 100) {
			var curAltDig3Add = math.mod(alt,20);
		} else {
			var curAltDig3Add = 0;
		}
		me["curAltDig3"].setTranslation(0,curAltDig3Add*59/20);

		var altR20 = roundToNearest(alt, 20);
		me["curAltDig45High2"].setText(sprintf("%02d",math.mod(math.abs(altR20+20),100)));
		me["curAltDig45High1"].setText(sprintf("%02d",math.mod(math.abs(altR20),100)));
		me["curAltDig45Low1"].setText(sprintf("%02d",math.mod(math.abs(altR20-20),100)));
		me["curAltDig45Low2"].setText(sprintf("%02d",math.mod(math.abs(altR20-40),100)));
		me["curAltDig45"].setTranslation(0,((alt - altR20)/20*36.31));

		me["curAltMtrTxt"].setText(sprintf("%4.0f",alt*FT2M));
		
		var altAlert = getprop("/b737/warnings/altitude-alert");
		var altAlertMode = getprop("/b737/warnings/altitude-alert-mode");
		if (altAlert) {
			me["curAltBox"].setStrokeLineWidth(5);
			if (altAlertMode == 1) {
				var time = getprop("/sim/time/elapsed-sec");
				if (math.mod(time, 0.7) < 0.35) {
					me["curAltBox"].setColor(1,0.749,0);
				} else {
					me["curAltBox"].setColor(1,1,1);
				}
				me["selAltBox"].hide();
			} else {
				me["curAltBox"].setColor(1,1,1);
				me["selAltBox"].show();
			}
		} else {
			me["curAltBox"].setStrokeLineWidth(3);
			me["curAltBox"].setColor(1,1,1);
			me["selAltBox"].hide();
		}

		var curAltDiff = alt-apAlt;
		if (curAltDiff > 400)
			curAltDiff = 400;
		elsif (curAltDiff < -400)
			curAltDiff = -400;
		me["selAltPtr"].setTranslation(0,curAltDiff*0.9132);

		me["curSpdDig3"].setTranslation(0,math.mod(ias,10)*41.084538462);
		if (math.mod(ias,10) > 9 and math.mod(ias,10) < 10) {
			var spdDig2Add = math.mod(ias,1);
		} else {
			var spdDig2Add = 0;
		}
		me["curSpdDig2"].setTranslation(0,(math.floor(math.mod(ias,100)/10) + spdDig2Add)*71.7);
		if (math.mod(ias,100) > 99 and math.mod(ias,100) < 100) {
			var spdDig1Add = math.mod(ias,1);
		} else {
			var spdDig1Add = 0;
		}
		me["curSpdDig1"].setTranslation(0,(math.floor(math.mod(ias,1000)/100) + spdDig1Add)*71.7);
		
		if (getprop("instrumentation/marker-beacon/outer")) {
			me["markerBeacon"].show();
			me["markerBeaconText"].setText("OM");
		} elsif (getprop("instrumentation/marker-beacon/middle")) {
			me["markerBeacon"].show();
			me["markerBeaconText"].setText("MM");
		} elsif (getprop("instrumentation/marker-beacon/inner")) {
			me["markerBeacon"].show();
			me["markerBeaconText"].setText("IM");
		} else {
			me["markerBeacon"].hide();
		}
		
		var navSignalQuality = getprop("instrumentation/nav[0]/signal-quality-norm") or 0;
		var navIsLocalizer = getprop("instrumentation/nav[0]/nav-loc") or 0;
		if (navSignalQuality > 0.95 and navIsLocalizer) {
			var deflection = getprop("instrumentation/nav[0]/heading-needle-deflection-norm"); # 1 dot = 1 degree, full needle deflection is 10 deg
			var expanded = getprop("/autopilot/display/localizer_expanded");
				
			me["locPtr"].show();
			
			if(abs(deflection) < 0.95) {
				me["locPtr"].setColorFill(1,0,1,1);
			}
			else {
				me["locPtr"].setColorFill(0,0,0,1);
			}
			
			if (radioAlt < 2500) {
				me["risingRwy"].show();
				me["risingRwyPtr"].show();
				if (radioAlt< 200) {
					if(expanded) {
						if (deflection > 0.3) deflection = 0.3;
						if (deflection < -0.3) deflection = -0.3;
						me["risingRwy"].setTranslation(deflection*600,-(200-radioAlt)*0.682);
					} else {
						me["risingRwy"].setTranslation(deflection*180,-(200-radioAlt)*0.682);
					}
					me["risingRwyPtr_scale"].setScale(1, ((200-radioAlt)*0.682)/11);
				} else {
					if(expanded) {
						if (deflection > 0.3) deflection = 0.3;
						if (deflection < -0.3) deflection = -0.3;
						me["risingRwy"].setTranslation(deflection*600,0);
					} else {
						me["risingRwy"].setTranslation(deflection*180,0);
					}
					me["risingRwyPtr_scale"].setScale(1, 1);
				}
			} else {
				me["risingRwy"].hide();
				me["risingRwyPtr"].hide();
			}
			if(expanded) {
				if (deflection > 0.3) deflection = 0.3;
				if (deflection < -0.3) deflection = -0.3;
				me["locPtr"].setTranslation(deflection*600,0);
				me["risingRwyPtr"].setTranslation(deflection*600,0);
				me["scaleCenter"].show();
				me["locScaleExp"].show();
				me["locScale"].hide();
			} else {
				me["locPtr"].setTranslation(deflection*180,0);
				me["risingRwyPtr"].setTranslation(deflection*180,0);
				me["scaleCenter"].show();
				me["locScaleExp"].hide();
				me["locScale"].show();
			}
		} else {
			me["locPtr"].hide();
			me["scaleCenter"].hide();
			me["locScaleExp"].hide();
			me["locScale"].hide();
			me["risingRwy"].hide();
			me["risingRwyPtr"].hide();
		}
		
		if(getprop("instrumentation/nav/gs-in-range")) {
			
			var mcp_course = getprop("/instrumentation/nav[0]/radials/selected-deg");
			var trk_crs_diff = math.abs(geo.normdeg180(track - mcp_course));
			if (trk_crs_diff < 90) {
				me["gsPtr"].show();
			} else {
				me["gsPtr"].hide();
			}
			me["gsScale"].show();
			var gs_deflection=getprop("instrumentation/nav/gs-needle-deflection-norm");
			me["gsPtr"].setTranslation(0,-gs_deflection*180);
			if(abs(gs_deflection) < 0.95) {
				me["gsPtr"].setColorFill(1,0,1,1);
			}
			else {
				me["gsPtr"].setColorFill(0,0,0,1);
			}
		} else {
			me["gsPtr"].hide();
			me["gsScale"].hide();
		}

		if (fpv) {
			me["fpv"].show();
			me["fpv"].setTranslation((track-hdg)*11,(pitch-path)*11.4625)
		} else {
			me["fpv"].hide();
		}
		
		if (alt < 10000)
			me["tenThousand"].show();
		else 
			me["tenThousand"].hide();
		if (vSpd != nil) {
			var vertSpd = vSpd*60;
			var vertSpdTxt = roundToNearest(abs(vertSpd),50);
			if (vertSpdTxt > 9999) vertSpdTxt = 9999;
			if (vertSpd > 0 ) {
				if (abs(vertSpd) > 400) {
					me["vertSpdUp"].setText(sprintf("%4.0f",vertSpdTxt));
					me["vertSpdUp"].show();
				} else {
					me["vertSpdUp"].hide();
				}
			} else {
				if (abs(vertSpd) > 400) {
					me["vertSpdDn"].setText(sprintf("%4.0f",vertSpdTxt));
					me["vertSpdDn"].show();
				} else {
					me["vertSpdDn"].hide();
				}
			}
			if (getprop("instrumentation/pfd/target-vs") != nil and getprop("autopilot/internal/VNAV-VS")) {
				me["vsPointer"].show();
				me["vsPointer"].setTranslation(0,-getprop("instrumentation/pfd/target-vs"));
			} else {
				me["vsPointer"].hide();
			}
		}
		radioAlt = radioAlt - 7.5;
		if (radioAlt < 2500) {
			if (radioAlt > 500)
				me["radioAltInd"].setText(sprintf("%4.0f",roundToNearest(radioAlt,20)));
			elsif (radioAlt > 100)
				me["radioAltInd"].setText(sprintf("%4.0f",roundToNearest(radioAlt,10)));
			else
				me["radioAltInd"].setText(sprintf("%4.0f",roundToNearest(radioAlt,2)));
			me["radioAltInd"].show();
		} else {
			me["radioAltInd"].hide();
		}

		me["dmeDist"].setText(sprintf("DME %s",getprop("instrumentation/dme[0]/KDI572-574/nm")));

		var lookaheadSpd = getprop("instrumentation/pfd/speed-lookahead");
		if (lookaheadSpd != nil) {
			if (ias == 45 and lookaheadSpd < 45) {
				me["spdTrend_scale"].setScale(1, 0);
			} else {
				me["spdTrend_scale"].setScale(1, (lookaheadSpd-ias)/20);
			}
			
		}
		
		me["spdTape"].setTranslation(0,ias*6.145425);
		me["altTape"].setTranslation(0,alt*0.9132);

		me["altTapeScale"].setTranslation(0,(alt - roundToNearest(alt, 1000))*0.9132);
		
		if (roundToNearest(alt, 1000) == 0) {
			me["altTextLowSmall1"].setText(sprintf("%0.0f",200));
			me["altTextLowSmall2"].setText(sprintf("%0.0f",400));
			me["altTextLowSmall3"].setText(sprintf("%0.0f",600));
			me["altTextLowSmall4"].setText(sprintf("%0.0f",800));
			me["altTextHighSmall2"].setText(sprintf("%0.0f",200));
			me["altTextHighSmall3"].setText(sprintf("%0.0f",400));
			me["altTextHighSmall4"].setText(sprintf("%0.0f",600));
			me["altTextHighSmall5"].setText(sprintf("%0.0f",800));
			var altNumLow = "-";
			var altNumHigh = "";
			var altNumCenter = altNumHigh;
		} elsif (roundToNearest(alt, 1000) > 0) {
			me["altTextLowSmall1"].setText(sprintf("%0.0f",800));
			me["altTextLowSmall2"].setText(sprintf("%0.0f",600));
			me["altTextLowSmall3"].setText(sprintf("%0.0f",400));
			me["altTextLowSmall4"].setText(sprintf("%0.0f",200));
			me["altTextHighSmall2"].setText(sprintf("%0.0f",200));
			me["altTextHighSmall3"].setText(sprintf("%0.0f",400));
			me["altTextHighSmall4"].setText(sprintf("%0.0f",600));
			me["altTextHighSmall5"].setText(sprintf("%0.0f",800));
			var altNumLow = roundToNearest(alt, 1000)/1000 - 1;
			var altNumHigh = roundToNearest(alt, 1000)/1000;
			var altNumCenter = altNumHigh;
		} elsif (roundToNearest(alt, 1000) < 0) {
			me["altTextLowSmall1"].setText(sprintf("%0.0f",200));
			me["altTextLowSmall2"].setText(sprintf("%0.0f",400));
			me["altTextLowSmall3"].setText(sprintf("%0.0f",600));
			me["altTextLowSmall4"].setText(sprintf("%0.0f",800));
			me["altTextHighSmall2"].setText(sprintf("%0.0f",800));
			me["altTextHighSmall3"].setText(sprintf("%0.0f",600));
			me["altTextHighSmall4"].setText(sprintf("%0.0f",400));
			me["altTextHighSmall5"].setText(sprintf("%0.0f",200));
			var altNumLow = roundToNearest(alt, 1000)/1000;
			var altNumHigh = roundToNearest(alt, 1000)/1000 + 1;
			var altNumCenter = altNumLow;
		}
		if ( altNumLow == 0 ) {
			altNumLow = "";
		}
		if ( altNumHigh == 0 and alt < 0) {
			altNumHigh = "-";
		}
		me["altTextLow1"].setText(sprintf("%s", altNumLow));
		me["altTextLow2"].setText(sprintf("%s", altNumLow));
		me["altTextLow3"].setText(sprintf("%s", altNumLow));
		me["altTextLow4"].setText(sprintf("%s", altNumLow));
		me["altTextHigh1"].setText(sprintf("%s", altNumCenter));
		me["altTextHigh2"].setText(sprintf("%s", altNumHigh));
		me["altTextHigh3"].setText(sprintf("%s", altNumHigh));
		me["altTextHigh4"].setText(sprintf("%s", altNumHigh));
		me["altTextHigh5"].setText(sprintf("%s", altNumHigh));
	
		
		var vsiDeg = getprop("instrumentation/pfd/vsi-needle-deg");
		if( vsiDeg != nil) {
			me["vsiNeedle"].setRotation(vsiDeg*D2R);
		}
		
		settimer(func me.update(), 0.04);
	},
	update_ap_modes: func()
	{
		# Modes
		var afds = getprop("/autopilot/display/afds-mode[0]");
		if (afds == "SINGLE CH") {
			me["afdsMode"].hide();
			me["afdsModeBox"].hide();
			me["singleCh"].show();
			if ( getprop("/autopilot/display/afds-mode-rectangle[0]") == 1 ) {
				me["singleChBox"].show();
			} else {
				me["singleChBox"].hide();
			}
		} else {
			me["singleCh"].hide();
			me["singleChBox"].hide();
			me["afdsMode"].show();
			me["afdsMode"].setText(afds);
			if ( getprop("/autopilot/display/afds-mode-rectangle[0]") == 1 ) {
				me["afdsModeBox"].show();
			} else {
				me["afdsModeBox"].hide();
			}
		}
		
		
		var apSpd = getprop("/autopilot/display/throttle-mode");
		if (apSpd == "ARM") {
			me["atMode"].setColor(1,1,1);
		} else {
			me["atMode"].setColor(0,1,0);
		}
		me["atMode"].setText(apSpd);

		var apRoll = getprop("/autopilot/display/roll-mode");
		me["rollMode"].setText(apRoll);

		var apPitch = getprop("/autopilot/display/pitch-mode");
		me["pitchMode"].setText(apPitch);

		var apRollArm = getprop("/autopilot/display/roll-mode-armed");
		me["rollArmMode"].setText(apRollArm);

		var apPitchArm = getprop("/autopilot/display/pitch-mode-armed");
		me["pitchArmMode"].setText(apPitchArm);

		var spdChange = getprop("/autopilot/display/throttle-mode-rectangle");
		if ( spdChange == 1 ) {
			me["spdModeChange"].show();
		} else {
			me["spdModeChange"].hide();
		}

		var rollChange = getprop("/autopilot/display/roll-mode-rectangle");
		if ( rollChange == 1 ) {
			me["rollModeChange"].show();
		} else {
			me["rollModeChange"].hide();
		}

		var pitchChange = getprop("/autopilot/display/pitch-mode-rectangle");
		if ( pitchChange == 1 ) {
			me["pitchModeChange"].show();
		} else {
			me["pitchModeChange"].hide();
		}

		settimer(func me.update_ap_modes(), 0.5);
	},
	update_slow: func()
	{
		var air_ground = getprop("/b737/sensors/air-ground");
		if ( air_ground == "ground") var wow = 1;
		else var wow = 0;
		var flaps = getprop("/controls/flight/flaps");
		var alt = getprop("instrumentation/altimeter/indicated-altitude-ft");
		var apSpd = getprop("autopilot/settings/target-speed-kt");
		var dh = getprop("instrumentation/mk-viii/inputs/arinc429/decision-height");
		
		var v1 = getprop("instrumentation/fmc/speeds/v1-kt") or 0;
		if (v1 > 0) {
			if (wow) {
				me["v1"].show();
				me["v1"].setTranslation(0,-getprop("instrumentation/fmc/speeds/v1-kt")*6.145425);
				me["vr"].show();
				me["vr"].setTranslation(0,-getprop("instrumentation/fmc/speeds/vr-kt")*6.145425);
			} else {
				me["v1"].hide();
				me["vr"].hide();
			}
		} else {
			me["v1"].hide();
			me["vr"].hide();
		}

		me["v2"].hide(); #i have never seen V2 bug on 737-800 PFD

		me["spdTapeWhiteBug"].hide(); #will implement in future

			
		if (getprop("instrumentation/fmc/phase-name") == "APPROACH") {
			if (flaps == 1)
				var vref = getprop("instrumentation/pfd/flaps-30-kt");
			else
				var vref = getprop("instrumentation/pfd/flaps-25-kt");
			me["vref"].show();
			me["vref"].setTranslation(0,-vref*6.145425);
		} else {
			me["vref"].hide();
		}
		
		var vref40 = getprop("instrumentation/fmc/v-ref-40") or 0;
		vref40 = roundToNearest(vref40,1);
		setprop("instrumentation/fmc/v-ref-40-rounded", vref40);
		
		me["flaps-mark-1"].hide();
		me["flaps-mark-2"].hide();
		me["flaps-mark-3"].hide();
		me["flaps-mark-4"].hide();
		me["flaps-mark-5"].hide();
		if (alt < 20000) {
			if (flaps == 0) {
				me["flaps-mark-1"].show();
				me["flaps-mark-1-txt"].setText("UP");
				me["flaps-mark-1"].setTranslation(0,-(vref40+70)*6.145425);
			} elsif (flaps == 0.125) {
				me["flaps-mark-1"].show();
				me["flaps-mark-1-txt"].setText("UP");
				me["flaps-mark-1"].setTranslation(0,-(vref40+70)*6.145425);
				me["flaps-mark-2"].show();
				me["flaps-mark-2-txt"].setText("1");
				me["flaps-mark-2"].setTranslation(0,-(vref40+50)*6.145425);
			} elsif (flaps == 0.250) {
				me["flaps-mark-1"].show();
				me["flaps-mark-1-txt"].setText("UP");
				me["flaps-mark-1"].setTranslation(0,-(vref40+70)*6.145425);
				me["flaps-mark-2"].show();
				me["flaps-mark-2-txt"].setText("1");
				me["flaps-mark-2"].setTranslation(0,-(vref40+50)*6.145425);
				me["flaps-mark-3"].show();
				me["flaps-mark-3-txt"].setText("2");
				me["flaps-mark-3"].setTranslation(0,-(vref40+40)*6.145425);
			} elsif (flaps == 0.375) {
				me["flaps-mark-1"].show();
				me["flaps-mark-1-txt"].setText("UP");
				me["flaps-mark-1"].setTranslation(0,-(vref40+70)*6.145425);
				me["flaps-mark-2"].show();
				me["flaps-mark-2-txt"].setText("1");
				me["flaps-mark-2"].setTranslation(0,-(vref40+50)*6.145425);
				me["flaps-mark-3"].show();
				me["flaps-mark-3-txt"].setText("5");
				me["flaps-mark-3"].setTranslation(0,-(vref40+30)*6.145425);
			} elsif (flaps == 0.500) {
				me["flaps-mark-1"].show();
				me["flaps-mark-1-txt"].setText("UP");
				me["flaps-mark-1"].setTranslation(0,-(vref40+70)*6.145425);
				me["flaps-mark-2"].show();
				me["flaps-mark-2-txt"].setText("1");
				me["flaps-mark-2"].setTranslation(0,-(vref40+50)*6.145425);
				me["flaps-mark-3"].show();
				me["flaps-mark-3-txt"].setText("10");
				me["flaps-mark-3"].setTranslation(0,-(vref40+30)*6.145425);
			} elsif (flaps == 0.625) {
				me["flaps-mark-1"].show();
				me["flaps-mark-1-txt"].setText("UP");
				me["flaps-mark-1"].setTranslation(0,-(vref40+70)*6.145425);
				me["flaps-mark-2"].show();
				me["flaps-mark-2-txt"].setText("1");
				me["flaps-mark-2"].setTranslation(0,-(vref40+50)*6.145425);
				me["flaps-mark-3"].show();
				me["flaps-mark-3-txt"].setText("5");
				me["flaps-mark-3"].setTranslation(0,-(vref40+30)*6.145425);
				me["flaps-mark-4"].show();
				me["flaps-mark-4-txt"].setText("15");
				me["flaps-mark-4"].setTranslation(0,-(vref40+20)*6.145425);
			} elsif (flaps == 0.750) {
				me["flaps-mark-1"].show();
				me["flaps-mark-1-txt"].setText("UP");
				me["flaps-mark-1"].setTranslation(0,-(vref40+70)*6.145425);
				me["flaps-mark-2"].show();
				me["flaps-mark-2-txt"].setText("1");
				me["flaps-mark-2"].setTranslation(0,-(vref40+50)*6.145425);
				me["flaps-mark-3"].show();
				me["flaps-mark-3-txt"].setText("5");
				me["flaps-mark-3"].setTranslation(0,-(vref40+30)*6.145425);
				me["flaps-mark-4"].show();
				me["flaps-mark-4-txt"].setText("15");
				me["flaps-mark-4"].setTranslation(0,-(vref40+20)*6.145425);
				me["flaps-mark-5"].show();
				me["flaps-mark-5-txt"].setText("25");
				me["flaps-mark-5"].setTranslation(0,-(vref40+10)*6.145425);
			} elsif (flaps == 0.875) {
				me["flaps-mark-1"].show();
				me["flaps-mark-1-txt"].setText("UP");
				me["flaps-mark-1"].setTranslation(0,-(vref40+70)*6.145425);
			} elsif (flaps == 1.000) {
				me["flaps-mark-1"].show();
				me["flaps-mark-1-txt"].setText("UP");
				me["flaps-mark-1"].setTranslation(0,-(vref40+70)*6.145425);
			}
		}
		if (getprop("instrumentation/weu/state/stall-speed") != nil)
			me["minSpdInd"].setTranslation(0,-getprop("instrumentation/weu/state/stall-speed")*6.145425);

		var mmoKt = getprop("instrumentation/pfd/mmo-kt") or 500;
		var maxIAS = 340;
		if ( mmoKt < 340 ) {
			var maxIAS = mmoKt;
		}
		if (flaps == 0.125) {
			maxIAS = getprop("limits/max-flap-extension-speed[0]/speed");
		} elsif (flaps == 0.250) {
			maxIAS = getprop("limits/max-flap-extension-speed[1]/speed");
		} elsif (flaps == 0.375) {
			maxIAS = getprop("limits/max-flap-extension-speed[2]/speed");
		} elsif (flaps == 0.500) {
			maxIAS = getprop("limits/max-flap-extension-speed[3]/speed");
		} elsif (flaps == 0.625) {
			maxIAS = getprop("limits/max-flap-extension-speed[4]/speed");
		} elsif (flaps == 0.750) {
			maxIAS = getprop("limits/max-flap-extension-speed[5]/speed");
		} elsif (flaps == 0.875) {
			maxIAS = getprop("limits/max-flap-extension-speed[6]/speed");
		} elsif (flaps == 1.000) {
			maxIAS = getprop("limits/max-flap-extension-speed[7]/speed");
		}
		me["maxSpdInd"].setTranslation(0,maxIAS*-6.145425);
		if (dh != nil)
			me["minimums"].setTranslation(0,-dh*0.9132);
		if (getprop("autopilot/route-manager/destination/field-elevation-ft") != nil) {
			me["touchdown"].setTranslation(0,-getprop("autopilot/route-manager/destination/field-elevation-ft")*0.9132);
			me["touchdown"].show();
		} else
			me["touchdown"].hide();
		
		if(wow) {
			me["minSpdInd"].hide();
			me["maxSpdInd"].hide();
		} else {
			me["minSpdInd"].show();
			me["maxSpdInd"].show();
		}
		var pressureUnit = getprop("instrumentation/efis/inputs/kpa-mode");
		if ( pressureUnit == 0 ) {
			me["baroSet"].setText(sprintf("%2.2f",getprop("instrumentation/altimeter[0]/setting-inhg")));
			me["baroUnit"].setText("IN");
		} else {
			me["baroSet"].setText(sprintf("%4.0f",getprop("instrumentation/altimeter[0]/setting-hpa")));
			me["baroUnit"].setText("HPA");
		}
		var navId = getprop("instrumentation/nav[0]/nav-id");
		var navFrq = getprop("instrumentation/nav[0]/frequencies/selected-mhz-fmt") or 0;
		if (navId == "" or navId == nil) {
			me["ilsId"].setText(sprintf("%s /%03d°",navFrq,getprop("instrumentation/nav/radials/selected-deg")));
		} else {
			me["ilsId"].setText(sprintf("%s /%03d°",navId,getprop("instrumentation/nav/radials/selected-deg")));
		}
		me["dhText"].setText(sprintf("%4.0f",dh));
		me["selHdgText"].setText(sprintf("%03d",getprop("autopilot/settings/heading-bug-deg")));
		if (getprop("/autopilot/internal/SPD-MACH")) {
			me["speedText"].setText(sprintf(".%2.0f",getprop("/autopilot/settings/target-speed-mach")*100));
		} else {
			me["speedText"].setText(sprintf("%3.0f",apSpd));
		}
		
		
		settimer(func me.update_slow(), 0.1);
	},
};

setlistener("sim/signals/fdm-initialized", func() {
	pfd_display = canvas.new({
		"name": "PFD",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	pfd_display.addPlacement({"node": "pfdScreen"});
	var group = pfd_display.createGroup();
	pfd_canvas = canvas_PFD.new(group);
	pfd_canvas.update();
	pfd_canvas.update_slow();
});

#setlistener("sim/signals/reinit", func pfd_display.del());

var showPfd = func() {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(pfd_display);
}
