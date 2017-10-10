##
var nd_display = {};

var myCockpit_switches = {
	# symbolic alias : relative property (as used in bindings), initial value, type
	'toggle_range': 	{path: '/inputs/range-nm', value:40, type:'INT'},
	'toggle_weather': 	{path: '/inputs/wxr', value:0, type:'BOOL'},
	'toggle_airports': 	{path: '/inputs/arpt', value:1, type:'BOOL'},
	'toggle_stations': 	{path: '/inputs/sta', value:0, type:'BOOL'},
	'toggle_waypoints': 	{path: '/inputs/wpt', value:0, type:'BOOL'},
	'toggle_position': 	{path: '/inputs/pos', value:0, type:'BOOL'},
	'toggle_data': 		{path: '/inputs/data',value:0, type:'BOOL'},
	'toggle_terrain': 	{path: '/inputs/terr',value:0, type:'BOOL'},
	'toggle_traffic': 		{path: '/inputs/tfc',value:0, type:'BOOL'},
	'toggle_centered': 		{path: '/inputs/nd-centered',value:0, type:'BOOL'},
	'toggle_lh_vor_adf':	{path: '/inputs/lh-vor-adf',value:1, type:'INT'},
	'toggle_rh_vor_adf':	{path: '/inputs/rh-vor-adf',value:1, type:'INT'},
	'toggle_display_mode': 	{path: '/mfd/display-mode', value:'MAP', type:'STRING'},
	'toggle_display_type': 	{path: '/mfd/display-type', value:'LCD', type:'STRING'},
	'toggle_true_north': 	{path: '/mfd/true-north', value:0, type:'BOOL'},
	'toggle_rangearc':      {path: '/mfd/rangearc', value:0, type:'BOOL'},
	'toggle_track_heading': {path: '/trk-selected', value:1, type:'BOOL'},
	'toggle_hdg_bug_only': {path: '/mfd/hdg-bug-only', value:1, type:'BOOL'},
	# add new switches here
};

var _list = setlistener("sim/signals/fdm-initialized", func() {
	var ND = canvas.NavDisplay;

	# TODO: is this just an object decsribing a ND? Can we move this out of the listener?
	# Also applies below and to the 777.
	var NDCpt = ND.new("instrumentation/efis",myCockpit_switches);
	
	nd_display.cpt = canvas.new({
		"name": "ND",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});

	nd_display.cpt.addPlacement({"node": "ndScreenL"});
	var group = nd_display.cpt.createGroup();
	NDCpt.newMFD(group, nd_display.cpt);
	NDCpt.update();
	
	var NDFo = ND.new("instrumentation/efis[1]",myCockpit_switches);
	
	nd_display.fo = canvas.new({
		"name": "ND",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});

	nd_display.fo.addPlacement({"node": "ndScreenR"});
	var group = nd_display.fo.createGroup();
	NDFo.newMFD(group, nd_display.fo);
	NDFo.update();

	removelistener(_list); # run ONCE
});

var showNd = func(pilot='cpt') {
	var dlg = canvas.Window.new([512, 512], "dialog");
	dlg.setCanvas( nd_display[pilot] );
}
