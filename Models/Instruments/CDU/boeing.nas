var input = func(v) {
		setprop("/instrumentation/cdu/input",getprop("/instrumentation/cdu/input")~v);
	}
	
var key = func(x) {
		var cduDisplay = getprop("/instrumentation/cdu/display");
		var serviceable = getprop("/instrumentation/cdu/serviceable");
		var eicasDisplay = getprop("/instrumentation/eicas/display");
		var cduInput = getprop("/instrumentation/cdu/input");
		
		if (serviceable == 1){
			if (x == "next"){
				if (cduDisplay == "POS_INIT"){
					cduDisplay = "POS_REF";
				}
				if (cduDisplay == "RTE1_1"){
					cduDisplay = "RTE1_2";
				}
			}
			if (x == "prev"){
				if (cduDisplay == "POS_REF"){
					cduDisplay = "POS_INIT";
				}
				if (cduDisplay == "RTE1_2"){
					cduDisplay = "RTE1_1";
				}
			}
			if (x == "LSK1L"){
				if (cduDisplay == "DEP_ARR_INDEX"){
					cduDisplay = "RTE1_DEP";
				}
				if (cduDisplay == "EICAS_MODES"){
					eicasDisplay = "ENG";
				}
				if (cduDisplay == "EICAS_SYN"){
					eicasDisplay = "ELEC";
				}
				if (cduDisplay == "INIT_REF"){
					cduDisplay = "IDENT";
				}
				if (cduDisplay == "NAV_RAD"){
					setprop("/instrumentation/nav[0]/frequencies/selected-mhz",cduInput);
					cduInput = "";
				}
				if (cduDisplay == "RTE1_1"){
					setprop("/autopilot/route-manager/departure/airport",cduInput);
					cduInput = "";
				}
				if (cduDisplay == "RTE1_LEGS"){
					if (cduInput == "DELETE"){
						setprop("/autopilot/route-manager/input","@DELETE1");
						cduInput = "";
					}
					else{
						setprop("/autopilot/route-manager/input","@INSERT2:"~cduInput);
					}
				}
				if (cduDisplay == "TO_REF"){
					setprop("/instrumentation/fmc/to-flap",cduInput);
					cduInput = "";
				}
			}
			if (x == "LSK1R"){
				if (cduDisplay == "EICAS_MODES"){
					eicasDisplay = "FUEL";
				}
				if (cduDisplay == "EICAS_SYN"){
					eicasDisplay = "HYD";
				}
				if (cduDisplay == "NAV RAD"){
					setprop("/instrumentation/nav[1]/frequencies/selected-mhz",cduInput);
					cduInput = "";
				}
				if (cduDisplay == "RTE1_1"){
					setprop("/autopilot/route-manager/destination/airport",cduInput);
					cduInput = "";
				}
				if (cduDisplay == "RTE1_LEGS"){
					setprop("/autopilot/route-manager/route/wp[1]/altitude-ft",cduInput);
					if (substr(cduInput,0,2) == "FL"){
						setprop("/autopilot/route-manager/route/wp[1]/altitude-ft",substr(cduInput,2)*100);
					}
					cduInput = "";
				}
			}
			if (x == "LSK2L"){
				if (cduDisplay == "EICAS_MODES"){
					eicasDisplay = "STAT";
				}
				if (cduDisplay == "EICAS_SYN"){
					eicasDisplay = "ECS";
				}
				if (cduDisplay == "POS_INIT"){
					setprop("/instrumentation/fmc/ref-airport",cduInput);
					cduInput = "";;
				}
				if (cduDisplay == "INIT_REF"){
					cduDisplay = "POS_INIT";
				}
				if (cduDisplay == "RTE1_1"){
					setprop("/autopilot/route-manager/departure/runway",cduInput);
					cduInput = "";;
				}
				if (cduDisplay == "RTE1_LEGS"){
					if (cduInput == "DELETE"){
						setprop("/autopilot/route-manager/input","@DELETE2");
						cduInput = "";
					}
					else{
						setprop("/autopilot/route-manager/input","@INSERT3:"~cduInput);
					}
				}
			}
			if (x == "LSK2R"){
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
			}
			if (x == "LSK3L"){
				if (cduDisplay == "INIT_REF"){
					cduDisplay = "PERF_INIT";
				}
				if (cduDisplay == "RTE1_LEGS"){
					if (cduInput == "DELETE"){
						setprop("/autopilot/route-manager/input","@DELETE3");
						cduInput = "";
					}
					else{
						setprop("/autopilot/route-manager/input","@INSERT4:"~cduInput);
					}
				}
			}
			if (x == "LSK3R"){
				if (cduDisplay == "RTE1_LEGS"){
					setprop("/autopilot/route-manager/route/wp[3]/altitude-ft",cduInput);
					if (substr(cduInput,0,2) == "FL"){
						setprop("/autopilot/route-manager/route/wp[3]/altitude-ft",substr(cduInput,2)*100);
					}
					cduInput = "";
				}
			}
			if (x == "LSK4L"){
				if (cduDisplay == "INIT_REF"){
					cduDisplay = "TO_REF";
				}
				if (cduDisplay == "RTE1_LEGS"){
					if (cduInput == "DELETE"){
						setprop("/autopilot/route-manager/input","@DELETE4");
						cduInput = "";
					}
					else{
						setprop("/autopilot/route-manager/input","@INSERT5:"~cduInput);
					}
				}
			}
			if (x == "LSK4R"){
				if (cduDisplay == "RTE1_LEGS"){
					setprop("/autopilot/route-manager/route/wp[4]/altitude-ft",cduInput);
					if (substr(cduInput,0,2) == "FL"){
						setprop("/autopilot/route-manager/route/wp[4]/altitude-ft",substr(cduInput,2)*100);
					}
					cduInput = "";
				}
			}
			if (x == "LSK5L"){
				if (cduDisplay == "RTE1_LEGS"){
					if (cduInput == "DELETE"){
						setprop("/autopilot/route-manager/input","@DELETE5");
						cduInput = "";
					}
					else{
						setprop("/autopilot/route-manager/input","@INSERT6:"~cduInput);
					}
				}
			}
			if (x == "LSK5R"){
				if (cduDisplay == "RTE1_LEGS"){
					setprop("/autopilot/route-manager/route/wp[5]/altitude-ft",cduInput);
					if (substr(cduInput,0,2) == "FL"){
						setprop("/autopilot/route-manager/route/wp[5]/altitude-ft",substr(cduInput,2)*100);
					}
					cduInput = "";
				}
			}
			if (x == "LSK6L"){
				if (cduDisplay == "INIT_REF"){
					cduDisplay = "APP_REF";
				}
				if (cduDisplay == "APP_REF"){
					cduDisplay = "INIT_REF";
				}
				if ((cduDisplay == "IDENT") or (cduDisplay = "MAINT") or (cduDisplay = "PERF_INIT") or (cduDisplay = "POS_INIT") or (cduDisplay = "POS_REF") or (cduDisplay = "THR_LIM") or (cduDisplay = "TO_REF")){
					cduDisplay = "INIT_REF";
				}
			}
			if (x == "LSK6R"){
				if (cduDisplay == "THR_LIM"){
					cduDisplay = "TO_REF";
				}
				else if (cduDisplay == "APP_REF"){
					cduDisplay = "THR_LIM";
				}
				else if ((cduDisplay == "RTE1_1") or (cduDisplay == "RTE1_LEGS")){
					setprop("/autopilot/route-manager/input","@ACTIVATE");
				}
				else if ((cduDisplay == "POS_INIT") or (cduDisplay == "DEP") or (cduDisplay == "RTE1_ARR") or (cduDisplay == "RTE1_DEP")){
					cduDisplay = "RTE1_1";
				}
				else if ((cduDisplay == "IDENT") or (cduDisplay == "TO_REF")){
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
			
			setprop("/instrumentation/cdu/display", cduDisplay);
			if (eicasDisplay != nil){
				setprop("/instrumentation/eicas/display", eicasDisplay);
			}
			setprop("/instrumentation/cdu/input", cduInput);
		}
	}
	
var delete_func = func {
		var length = size(getprop("/instrumentation/cdu/input")) - 1;
		setprop("/instrumentation/cdu/input",substr(getprop("/instrumentation/cdu/input"),0,length));
	}
	
var i = 0;

var plusminus = func {	
	var end = size(getprop("/instrumentation/cdu/input"));
	var start = end - 1;
	var lastchar = substr(getprop("/instrumentation/cdu/input"),start,end);
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

var cdu = func {
		var display = getprop("/instrumentation/cdu/display");
		var serviceable = getprop("/instrumentation/cdu/serviceable");
		title = "";		page = "";
		line1l = "";	line2l = "";	line3l = "";	line4l = "";	line5l = "";	line6l = "";
		line1lt = "";	line2lt = "";	line3lt = "";	line4lt = "";	line5lt = "";	line6lt = "";
		line1c = "";	line2c = "";	line3c = "";	line4c = "";	line5c = "";	line6c = "";
		line1ct = "";	line2ct = "";	line3ct = "";	line4ct = "";	line5ct = "";	line6ct = "";
		line1r = "";	line2r = "";	line3r = "";	line4r = "";	line5r = "";	line6r = "";
		line1rt = "";	line2rt = "";	line3rt = "";	line4rt = "";	line5rt = "";	line6rt = "";
		
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
		if (display == "ALTN_NAV_RAD") {
			title = "ALTN NAV RADIO";
		}
		if (display == "APP_REF") {
			title = "APPROACH REF";
			line1lt = "GROSS WT";
			line1rt = "FLAPS    VREF";
			if (getprop("/instrumentation/fmc/vspeeds/Vref") != nil){
				line1l = getprop("/instrumentation/fmc/vspeeds/Vref");
			}
			if (getprop("/autopilot/route-manager/destination/airport") != nil){
				line4lt = getprop("/autopilot/route-manager/destination/airport");
			}
			line6l = "<INDEX";
			line6r = "THRUST LIM>";
		}
		if (display == "DEP_ARR_INDEX") {
			title = "DEP/ARR INDEX";
			line1l = "<DEP";
			line1ct = "RTE 1";
			if (getprop("/autopilot/route-manager/departure/airport") != nil){
				line1c = getprop("/autopilot/route-manager/departure/airport");
			}
			line1r = "ARR>";
			if (getprop("/autopilot/route-manager/destination/airport") != nil){
				line2c = getprop("/autopilot/route-manager/destination/airport");
			}
			line2r = "ARR>";
			line3l = "<DEP";
			line3r = "ARR>";
			line4r = "ARR>";
			line6lt ="DEP";
			line6l = "<----";
			line6c = "OTHER";
			line6rt ="ARR";
			line6r = "---->";
		}
		if (display == "EICAS_MODES") {
			title = "EICAS MODES";
			line1l = "<ENG";
			line1r = "FUEL>";
			line2l = "<STAT";
			line2r = "GEAR>";
			line5l = "<CANC";
			line5r = "RCL>";
			line6r = "SYNOPTICS>";
		}
		if (display == "EICAS_SYN") {
			title = "EICAS SYNOPTICS";
			line1l = "<ELEC";
			line1r = "HYD>";
			line2l = "<ECS";
			line2r = "DOORS>";
			line5l = "<CANC";
			line5r = "RCL>";
			line6r = "MODES>";
		}
		if (display == "FIX_INFO") {
			title = "FIX INFO";
			line1l = sprintf("%3.2f", getprop("/instrumentation/nav[0]/frequencies/selected-mhz-fmt"));
			line1r = sprintf("%3.2f", getprop("/instrumentation/nav[1]/frequencies/selected-mhz-fmt"));
			line2l = sprintf("%3.2f", getprop("/instrumentation/nav[0]/radials/selected-deg"));
			line2r = sprintf("%3.2f", getprop("/instrumentation/nav[1]/radials/selected-deg"));
			line6l = "<ERASE FIX";
		}
		if (display == "IDENT") {
			title = "IDENT";
			line1lt = "MODEL";
			if (getprop("/instrumentation/cdu/ident/model") != nil){
				line1l = getprop("/instrumentation/cdu/ident/model");
			}
			line1rt = "ENGINES";
			line2lt = "NAV DATA";
			if (getprop("/instrumentation/cdu/ident/engines") != nil){
				line1r = getprop("/instrumentation/cdu/ident/engines");
			}
			line6l = "<INDEX";
			line6r = "POS INIT>";
		}
		if (display == "INIT_REF") {
			title = "INIT/REF INDEX";
			page = "1/1";
			line1l = "<IDENT";
			line1r = "NAV DATA>";
			line2l = "<POS";
			line2r = "MSG RECALL>";
			line3l = "<PERF";
			line3r = "ALTN DEST>";
			line4l = "<TAKEOFF";
			line5l = "<APPROACH";
			line5r = "SEL CONFIG>";
			line6l = "<OFFSET";
			if (getprop("/b737/sensors/air-ground") == 0) {
				line6r = "NAV STATUS>";
			} else {
				line6r = "MAINT>";
			}
		}
		if (display == "MAINT") {
			title = "MAINTENANCE INDEX";
			line1l = "<CROS LOAD";
			line1r = "BITE>";
			line2l = "<PERF FACTORS";
			line3l = "<IRS MONITOR";
			line6l = "<INDEX";
		}
		if (display == "NAV_RAD") {
			title = "NAV RADIO";
			line1lt = "VOR L";
			line1l = sprintf("%3.2f", getprop("/instrumentation/nav[0]/frequencies/selected-mhz-fmt"));
			line1rt = "VOR R";
			line1r = sprintf("%3.2f", getprop("/instrumentation/nav[1]/frequencies/selected-mhz-fmt"));
			line2lt = "CRS";
			line2ct = "RADIAL";
			line2c = sprintf("%3.2f", getprop("/instrumentation/nav[0]/radials/selected-deg"))~"   "~sprintf("%3.2f", getprop("/instrumentation/nav[1]/radials/selected-deg"));
			line2rt = "CRS";
			line3lt = "ADF L";
			line3l = sprintf("%3.2f", getprop("/instrumentation/adf[0]/frequencies/selected-khz"));
			line3rt = "ADF R";
		}
		if (display == "PERF_INIT") {
			title = "PERF INIT";
			page = "1/2";
			line1lt = "GR WT";
			line1rt = "CRZ ALT";
			line1r = getprop("/autopilot/route-manager/cruise/altitude-ft");
			line2lt = "FUEL";
			line3lt = "ZFW";
			line4lt = "RESERVES";
			line4rt = "CRZ CG";
			line5lt = "COST INDEX";
			line5rt = "STEP SIZE";
			line6l = "<INDEX";
			line6r = "THRUST LIM>";	
			if (getprop("/sim/flight-model") == "jsb") {
				line1l = sprintf("%3.1f", (getprop("/fdm/jsbsim/inertia/weight-lbs")/1000));
				line2l = sprintf("%3.1f", (getprop("/fdm/jsbsim/propulsion/total-fuel-lbs")/1000));
				line3l = sprintf("%3.1f", (getprop("/fdm/jsbsim/inertia/empty-weight-lbs")/1000));
			}
			elsif (getprop("/sim/flight-model") == "yasim") {
				line1l = sprintf("%3.1f", (getprop("/yasim/gross-weight-lbs")/1000));
				line2l = sprintf("%3.1f", (getprop("/consumables/fuel/total-fuel-lbs")/1000));

				yasim_emptyweight = getprop("/yasim/gross-weight-lbs");
				yasim_emptyweight -= getprop("/consumables/fuel/total-fuel-lbs");
				yasim_weights = props.globals.getNode("/sim").getChildren("weight");
				for (i = 0; i < size(yasim_weights); i += 1) {
					yasim_emptyweight -= yasim_weights[i].getChild("weight-lb").getValue();
				}

				line3l = sprintf("%3.1f", yasim_emptyweight/1000);
			}
		}
		if (display == "POS_INIT") {
			title = "POS INIT";
			page = "1/4";
			line1rt = "LAST POS";
			line2lt = "REF AIRPORT";
			line3lt = "GATE";
			line4rt = "SET IRS POS";
			line5lt = "GMT-MON/DY";
			line5l = sprintf("%s", getprop("/sim/time/utc/hour") ~ getprop("/sim/time/utc/minute") ~ "." ~ getprop("/sim/time/utc/second") ~ "Z " ~ getprop("/sim/time/utc/month") ~ "/" ~ getprop("/sim/time/utc/day"));
			line6l = "<INDEX";
			line6r = "ROUTE>";
		}
		if (display == "POS_REF") {
			title = "POS REF";
			page = "2/4";
			line1lt = "FMC POST";
			line1l = getprop("/position/latitude-string")~" "~getprop("/position/longitude-string");
			line1rt = "GS";
			line1r = sprintf("%3.0f", getprop("/velocities/groundspeed-kt"));
			line5l = "<PURGE";
			line5r = "INHIBIT>";
			line6l = "<INDEX";
			line6r = "BRG/DIST>";
		}
		if (display == "RTE1_1") {
			title = "ACT RTE";
			page = "1/3";
			line1lt = "ORIGIN";
			if (getprop("/autopilot/route-manager/departure/airport") != nil){
				line1l = getprop("/autopilot/route-manager/departure/airport");
			}
			line1rt = "DEST";
			if (getprop("/autopilot/route-manager/destination/airport") != nil){
				line1r = getprop("/autopilot/route-manager/destination/airport");
			}
			line2lt = "CO ROUTE";
			line2rt = "FLT NO.";
			line3lt = "RUNWAY";
			if (getprop("/autopilot/route-manager/departure/runway") != nil){
				line3l = getprop("/autopilot/route-manager/departure/runway");
			}
			line5l = "<RTE COPY";
			line6l = "<RTE 2";
			if (getprop("/autopilot/route-manager/active") == 1){
				line6r = "PERF INIT>";
				}
			else {
				line6r = "ACTIVATE>";
				}
		}
		if (display == "RTE1_2") {
			title = "ACT RTE";
			page = "2/3";
			line1lt = "VIA";
			line1rt = "TO";
			if (getprop("/autopilot/route-manager/route/wp[1]/id") != nil){
				line1r = getprop("/autopilot/route-manager/route/wp[1]/id");
				}
			if (getprop("/autopilot/route-manager/route/wp[2]/id") != nil){
				line2r = getprop("/autopilot/route-manager/route/wp[2]/id");
				}
			if (getprop("/autopilot/route-manager/route/wp[3]/id") != nil){
				line3r = getprop("/autopilot/route-manager/route/wp[3]/id");
				}
			if (getprop("/autopilot/route-manager/route/wp[4]/id") != nil){
				line4r = getprop("/autopilot/route-manager/route/wp[4]/id");
				}
			if (getprop("/autopilot/route-manager/route/wp[5]/id") != nil){
				line5r = getprop("/autopilot/route-manager/route/wp[5]/id");
				}
			line6l = "<RTE 2";
			line6r = "ACTIVATE>";
		}
		if (display == "RTE1_ARR") {
			if (getprop("/autopilot/route-manager/destination/airport") != nil){
				title = getprop("/autopilot/route-manager/destination/airport")~" ARRIVALS";
			}
			else{
				title = "ARRIVALS";
			}
			line1lt = "STARS";
			line1rt = "APPROACHES";
			if (getprop("/autopilot/route-manager/destination/runway") != nil){
				line1r = getprop("/autopilot/route-manager/destination/runway");
			}
			line2lt = "TRANS";
			line3rt = "RUNWAYS";
			line6l = "<INDEX";
			line6r = "ROUTE>";
		}
		if (display == "RTE1_DEP") {
			if (getprop("/autopilot/route-manager/departure/airport") != nil){
				title = getprop("/autopilot/route-manager/departure/airport")~" DEPARTURES";
			}
			else{
				title = "DEPARTURES";
			}
			line1lt = "SIDS";
			line1rt = "RUNWAYS";
			if (getprop("/autopilot/route-manager/departure/runway") != nil){
				line1r = getprop("/autopilot/route-manager/departure/runway");
			}
			line2lt = "TRANS";
			line6l = "<ERASE";
			line6r = "ROUTE>";
		}
		if (display == "RTE1_LEGS") {
			if (getprop("/autopilot/route-manager/active") == 1){
				title = "ACT RTE 1 LEGS";
				}
			else {
				title = "RTE 1 LEGS";
				}
			if (getprop("/autopilot/route-manager/route/wp[1]/id") != nil){
				line1lt = sprintf("%3.0f", getprop("/autopilot/route-manager/route/wp[1]/leg-bearing-true-deg"));
				line1l = getprop("/autopilot/route-manager/route/wp[1]/id");
				line2ct = sprintf("%3.0f", getprop("/autopilot/route-manager/route/wp[1]/leg-distance-nm"))~" NM";
				line1r = sprintf("%5.0f", getprop("/autopilot/route-manager/route/wp[1]/altitude-ft"));
				if (getprop("/autopilot/route-manager/route/wp[1]/speed-kts") != nil){
					line4r = getprop("/autopilot/route-manager/route/wp[1]/speed-kts")~"/"~sprintf("%5.0f", getprop("/autopilot/route-manager/route/wp[1]/altitude-ft"));
					}
				}
			if (getprop("/autopilot/route-manager/route/wp[2]/id") != nil){
				if (getprop("/autopilot/route-manager/route/wp[2]/leg-bearing-true-deg") != nil){
					line2lt = sprintf("%3.0f", getprop("/autopilot/route-manager/route/wp[2]/leg-bearing-true-deg"));
				}
				line2l = getprop("/autopilot/route-manager/route/wp[2]/id");
				if (getprop("/autopilot/route-manager/route/wp[2]/leg-distance-nm") != nil){
					line3ct = sprintf("%3.0f", getprop("/autopilot/route-manager/route/wp[2]/leg-distance-nm"))~" NM";
				}
				line2r = sprintf("%5.0f", getprop("/autopilot/route-manager/route/wp[2]/altitude-ft"));
				if (getprop("/autopilot/route-manager/route/wp[2]/speed-kts") != nil){
					line4r = getprop("/autopilot/route-manager/route/wp[2]/speed-kts")~"/"~sprintf("%5.0f", getprop("/autopilot/route-manager/route/wp[2]/altitude-ft"));
					}
				}
			if (getprop("/autopilot/route-manager/route/wp[3]/id") != nil){
				if (getprop("/autopilot/route-manager/route/wp[3]/leg-bearing-true-deg") != nil){
					line3lt = sprintf("%3.0f", getprop("/autopilot/route-manager/route/wp[3]/leg-bearing-true-deg"));
				}
				line3l = getprop("/autopilot/route-manager/route/wp[3]/id");
				if (getprop("/autopilot/route-manager/route/wp[3]/leg-distance-nm") != nil){
					line4ct = sprintf("%3.0f", getprop("/autopilot/route-manager/route/wp[3]/leg-distance-nm"))~" NM";
				}
				line3r = sprintf("%5.0f", getprop("/autopilot/route-manager/route/wp[3]/altitude-ft"));
				if (getprop("/autopilot/route-manager/route/wp[3]/speed-kts") != nil){
					line3r = getprop("/autopilot/route-manager/route/wp[3]/speed-kts")~"/"~sprintf("%5.0f", getprop("/autopilot/route-manager/route/wp[3]/altitude-ft"));;
					}
				}
			if (getprop("/autopilot/route-manager/route/wp[4]/id") != nil){
				if (getprop("/autopilot/route-manager/route/wp[4]/leg-bearing-true-deg") != nil){
					line4lt = sprintf("%3.0f", getprop("/autopilot/route-manager/route/wp[4]/leg-bearing-true-deg"));
				}
				line4l = getprop("/autopilot/route-manager/route/wp[4]/id");
				if (getprop("/autopilot/route-manager/route/wp[4]/leg-distance-nm") != nil){
					line5ct = sprintf("%3.0f", getprop("/autopilot/route-manager/route/wp[4]/leg-distance-nm"))~" NM";
				}
				line4r = sprintf("%5.0f", getprop("/autopilot/route-manager/route/wp[4]/altitude-ft"));
				if (getprop("/autopilot/route-manager/route/wp[4]/speed-kts") != nil){
					line4r = getprop("/autopilot/route-manager/route/wp[4]/speed-kts")~"/"~sprintf("%5.0f", getprop("/autopilot/route-manager/route/wp[4]/altitude-ft"));
					}
				}
			if (getprop("/autopilot/route-manager/route/wp[5]/id") != nil){
				if (getprop("/autopilot/route-manager/route/wp[5]/leg-bearing-true-deg") != nil){
					line5lt = sprintf("%3.0f", getprop("/autopilot/route-manager/route/wp[5]/leg-bearing-true-deg"));
				}
				line5l = getprop("/autopilot/route-manager/route/wp[5]/id");
				line5r = sprintf("%5.0f", getprop("/autopilot/route-manager/route/wp[5]/altitude-ft"));
				if (getprop("/autopilot/route-manager/route/wp[5]/speed-kts") != nil){
					line4r = getprop("/autopilot/route-manager/route/wp[5]/speed-kts")~"/"~sprintf("%5.0f", getprop("/autopilot/route-manager/route/wp[5]/altitude-ft"));
					}
				}
			line6l = "<RTE 2 LEGS";
			if (getprop("/autopilot/route-manager/active") == 1){
				line6r = "RTE DATA>";
				}
			else{
				line6r = "ACTIVATE>";
				}
		}
		if (display == "THR_LIM") {
			title = "THRUST LIM";
			line1lt = "SEL";
			line1ct = "OAT";
			line1c = sprintf("%2.0f", getprop("/environment/temperature-degc"))~" °C";
			line1rt = "TO 1 N1";
			line2l = "<TO";
			line2r = "CLB>";
			line3lt = "TO 1";
			line3c = "<SEL> <ARM>";
			line3r = "CLB 1>";
			line4lt = "TO 2";
			line4r = "CLB 2>";
			line6l = "<INDEX";
			line6r = "TAKEOFF>";
		}
		if (display == "TO_REF") {
			title = "TAKEOFF REF";
			line1lt = "FLAP/ACCEL HT";
			line1l = getprop("/instrumentation/fmc/to-flap");
			line1rt = "REF V1";
			if (getprop("/instrumentation/fmc/vspeeds/V1") != nil){
				line1r = sprintf("%3.0f", getprop("/instrumentation/fmc/vspeeds/V1"));
			}
			line2lt = "E/O ACCEL HT";
			line2rt = "REF VR";
			if (getprop("/instrumentation/fmc/vspeeds/VR") != nil){
				line2r = sprintf("%3.0f", getprop("/instrumentation/fmc/vspeeds/VR"));
			}
			line3lt = "THR REDUCTION";
			line3rt = "REF V2";
			if (getprop("/instrumentation/fmc/vspeeds/V2") != nil){
				line3r = sprintf("%3.0f", getprop("/instrumentation/fmc/vspeeds/V2"));
			}
			line4lt = "WIND/SLOPE";
			line4rt = "TRIM   CG%";
			if (getprop("/instrumentation/fmc/cg") != nil and getprop("/instrumentation/fmc/stab-trim-units")){
				line4r = sprintf("%1.1f", getprop("/instrumentation/fmc/stab-trim-units"))~"  "~sprintf("%2.1f", getprop("/instrumentation/fmc/cg"))~"%";
			}
			line5rt = "POS SHIFT";
			line6l = "<INDEX";
			line6r = "POS INIT>";
		}
		
		if (serviceable != 1){
			title = "";		page = "";
			line1l = "";	line2l = "";	line3l = "";	line4l = "";	line5l = "";	line6l = "";
			line1lt = "";	line2lt = "";	line3lt = "";	line4lt = "";	line5lt = "";	line6lt = "";
			line1c = "";	line2c = "";	line3c = "";	line4c = "";	line5c = "";	line6c = "";
			line1ct = "";	line2ct = "";	line3ct = "";	line4ct = "";	line5ct = "";	line6ct = "";
			line1r = "";	line2r = "";	line3r = "";	line4r = "";	line5r = "";	line6r = "";
			line1rt = "";	line2rt = "";	line3rt = "";	line4rt = "";	line5rt = "";	line6rt = "";
		}
		
		setprop("/instrumentation/cdu/output/title",title);
		setprop("/instrumentation/cdu/output/page",page);
		setprop("/instrumentation/cdu/output/line1/left",line1l);
		setprop("/instrumentation/cdu/output/line2/left",line2l);
		setprop("/instrumentation/cdu/output/line3/left",line3l);
		setprop("/instrumentation/cdu/output/line4/left",line4l);
		setprop("/instrumentation/cdu/output/line5/left",line5l);
		setprop("/instrumentation/cdu/output/line6/left",line6l);
		setprop("/instrumentation/cdu/output/line1/left-title",line1lt);
		setprop("/instrumentation/cdu/output/line2/left-title",line2lt);
		setprop("/instrumentation/cdu/output/line3/left-title",line3lt);
		setprop("/instrumentation/cdu/output/line4/left-title",line4lt);
		setprop("/instrumentation/cdu/output/line5/left-title",line5lt);
		setprop("/instrumentation/cdu/output/line6/left-title",line6lt);
		setprop("/instrumentation/cdu/output/line1/center",line1c);
		setprop("/instrumentation/cdu/output/line2/center",line2c);
		setprop("/instrumentation/cdu/output/line3/center",line3c);
		setprop("/instrumentation/cdu/output/line4/center",line4c);
		setprop("/instrumentation/cdu/output/line5/center",line5c);
		setprop("/instrumentation/cdu/output/line6/center",line6c);
		setprop("/instrumentation/cdu/output/line1/center-title",line1ct);
		setprop("/instrumentation/cdu/output/line2/center-title",line2ct);
		setprop("/instrumentation/cdu/output/line3/center-title",line3ct);
		setprop("/instrumentation/cdu/output/line4/center-title",line4ct);
		setprop("/instrumentation/cdu/output/line5/center-title",line5ct);
		setprop("/instrumentation/cdu/output/line6/center-title",line6ct);
		setprop("/instrumentation/cdu/output/line1/right",line1r);
		setprop("/instrumentation/cdu/output/line2/right",line2r);
		setprop("/instrumentation/cdu/output/line3/right",line3r);
		setprop("/instrumentation/cdu/output/line4/right",line4r);
		setprop("/instrumentation/cdu/output/line5/right",line5r);
		setprop("/instrumentation/cdu/output/line6/right",line6r);
		setprop("/instrumentation/cdu/output/line1/right-title",line1rt);
		setprop("/instrumentation/cdu/output/line2/right-title",line2rt);
		setprop("/instrumentation/cdu/output/line3/right-title",line3rt);
		setprop("/instrumentation/cdu/output/line4/right-title",line4rt);
		setprop("/instrumentation/cdu/output/line5/right-title",line5rt);
		setprop("/instrumentation/cdu/output/line6/right-title",line6rt);
		settimer(cdu,0.2);
    }
_setlistener("/sim/signals/fdm-initialized", cdu); 
