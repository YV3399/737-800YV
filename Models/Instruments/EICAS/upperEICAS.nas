# ==============================================================================
# For 737-800 by Michael Soitanen
# ==============================================================================

var roundToNearest = func(n, m) {
	var x = int(n/m)*m;
	if((math.mod(n,m)) > (m/2) and n > 0)
			x = x + m;
	if((m - (math.mod(n,m))) > (m/2) and n < 0)
			x = x - m;
	return x;
}

var upperEICAS_canvas = nil;
var upperEICAS_display = nil;

var canvas_upperEICAS = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_upperEICAS] };
		var upperEICAS = canvas_group;
		var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(upperEICAS, "Aircraft/737-800/Models/Instruments/EICAS/upperEICAS.svg", {'font-mapper': font_mapper});
		
		var svg_keys = ["engine0N1","engine0N1Decimal","engine1N1","engine1N1Decimal",
		"needleN1_0","needleN1_1","tat"];
		foreach(var key; svg_keys) {
			m[key] = upperEICAS.getElementById(key);
		}

		return m;
	},
	update: func()
	{
		var n1_0 = getprop("/engines/engine[0]/n1");
		var n1_1 = getprop("/engines/engine[1]/n1");

		var tat = int(getprop("/fdm/jsbsim/propulsion/tat-c"));

		var n1_0_int = int(n1_0);
		var n1_0_dec = int(10*math.mod(n1_0,1));
		var n1_1_int = int(n1_1);
		var n1_1_dec = int(10*math.mod(n1_1,1));

		me["engine0N1"].setText(sprintf("%s", n1_0_int));
		me["engine0N1Decimal"].setText(sprintf("%s", n1_0_dec));
		me["engine1N1"].setText(sprintf("%s", n1_1_int));
		me["engine1N1Decimal"].setText(sprintf("%s", n1_1_dec));
		me["needleN1_0"].setRotation(n1_0*1.965*D2R);
		me["needleN1_1"].setRotation(n1_1*1.965*D2R);

		me["tat"].setText(sprintf("%s", tat));

		settimer(func me.update(), 0.04);
	},
};

setlistener("sim/signals/fdm-initialized", func() {
	upperEICAS_display = canvas.new({
		"name": "upperEICAS",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	upperEICAS_display.addPlacement({"node": "upperEICASScreen"});
	var group = upperEICAS_display.createGroup();
	upperEICAS_canvas = canvas_upperEICAS.new(group);
	upperEICAS_canvas.update();
});

setlistener("sim/signals/reinit", func upperEICAS_display.del());

var showupperEICAS = func() {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(upperEICAS_display);
}
