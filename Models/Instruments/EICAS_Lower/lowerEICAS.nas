################################
# Lower EICAS                  #
# Josh Davidson (Octal450) #
################################

var lowerEICAS_canvas = nil;
var lowerEICAS_display = nil;

var canvas_lowerEICAS = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_lowerEICAS] };
		var lowerEICAS = canvas_group;
		var font_mapper = func(family, weight)
		{
			if( family == "'Liberation Sans'" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(lowerEICAS, "Aircraft/737-800YV/Models/Instruments/EICAS_Lower/lowerEICAS.svg", {'font-mapper': font_mapper});
		
		var svg_keys = ["engine0N1","engine0N1Decimal","engine1N1","engine1N1Decimal","needleN1_0","needleN1_1","ff_0","ff_1"];
		foreach(var key; svg_keys) {
			m[key] = lowerEICAS.getElementById(key);
		}

		return m;
	},
	update: func()
	{
		var n1_0 = getprop("/engines/engine[0]/n2") + 0.05;
		var n1_1 = getprop("/engines/engine[1]/n2") + 0.05;
		var fuel_flow_0 = getprop("/engines/engine[0]/fuel-flow_pph")*0.4536/1000;
		var fuel_flow_1 = getprop("/engines/engine[1]/fuel-flow_pph")*0.4536/1000;

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
		
		me["ff_0"].setText(sprintf("%01.2f",fuel_flow_0));
		me["ff_1"].setText(sprintf("%01.2f",fuel_flow_1));

		settimer(func me.update(), 0.2);
	},
};

setlistener("sim/signals/fdm-initialized", func() {
	lowerEICAS_display = canvas.new({
		"name": "lowerEICAS",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	lowerEICAS_display.addPlacement({"node": "lowerEICASScreen"});
	var group = lowerEICAS_display.createGroup();
	lowerEICAS_canvas = canvas_lowerEICAS.new(group);
	lowerEICAS_canvas.update();
}, 0, 0);

var showlowerEICAS = func() {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(lowerEICAS_display);
}
