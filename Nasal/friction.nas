######################################################################
#
# Terrain reactions for JSBSim (friction, bumpiness, water sinking).
#
# Configuration:
#
# Add the following to ...-set.xml:
#
#   <nasal>
#     ...
#     <friction>
#       <file>path/to/friction.nas</file>
#     </friction>
#   </nasal>
#
#   <gear>
#     <gear n="N">
#       ...
#       <zsink-in type="double">INCHES</zsink-in>
#     </gear>
#   </gear>
#
# where N is the index of the point of contact (<zsink-in> should be
# specified for every point of contact, not just the gears) and INCHES
# is how deep that point should sink in the water.
#
# Information about surface properties will appear in
#
#   /fdm/jsbsim/gear/unit[*]/friction/
#   /fdm/jsbsim/contact/unit[*]/friction/
#

var rain_factor = 0.3;
var snow_factor = 0.45;
var meters_in_degree = 1852 * 60;
var degrees_in_inch = 0.0254 / meters_in_degree;
var radians_in_degree = math.pi / 180;

var points_of_contact = getprop("fdm/jsbsim/gear/num-units");
var point_info = [];
for (var i = 0; i < points_of_contact; i += 1) {
    var x = getprop("gear/gear["~i~"]/xoffset-in") * degrees_in_inch;
    var y = getprop("gear/gear["~i~"]/yoffset-in") * degrees_in_inch;
    var z = getprop("gear/gear["~i~"]/zoffset-in");
    var zs = getprop("gear/gear["~i~"]/zsink-in");
    if (zs == nil)
        zs = z;

    var g = 0;
    var r = 0;
    var prop = "";
    if (props.globals.getNode("fdm/jsbsim/gear/unit["~i~"]") != nil) {
        prop = "fdm/jsbsim/gear/unit["~i~"]";
        g = 1;
        r = getprop(prop~"/rolling_friction_coeff");
    } else {
        prop = "fdm/jsbsim/contact/unit["~i~"]";
    }
    var s = getprop(prop~"/static_friction_coeff");
    var d = getprop(prop~"/dynamic_friction_coeff");

    append(point_info, { g: g, x: x, y: y, z: z, zs: zs, s: s, d: d, r: r });
}


var update_reactions = func {
    settimer(update_reactions, 0.1);

    if (getprop("fdm/jsbsim/position/h-agl-ft") > 100)
        return;

    var lat = getprop("fdm/jsbsim/position/lat-geod-deg");
    var lon = getprop("fdm/jsbsim/position/long-gc-deg");
    var rot = -getprop("fdm/jsbsim/attitude/heading-true-rad");
    var h_cos = math.cos(rot);
    var h_sin = math.sin(rot);
    var cg = -getprop("fdm/jsbsim/inertia/cg-x-in") * degrees_in_inch;

    var rain_coeff = (getprop("environment/rain-norm")
                      or getprop("environment/metar/rain-norm")
                      or 0) * rain_factor;
    var snow_coeff = (getprop("environment/snow-norm")
                      or getprop("environment/metar/snow-norm")
                      or 0) * snow_factor;
    var wave_amp = ((getprop("environment/wave/amp") or 1) - 1) * 40;
    var wave_freq = (getprop("environment/wave/freq") or 0) * 60;

    for (var i = 0; i < points_of_contact; i += 1) {
        if (!getprop("gear/gear["~i~"]/wow"))
            continue;

        var north = (point_info[i].x - cg) * h_cos + point_info[i].y * h_sin;
        var east = (point_info[i].x - cg) * -h_sin + point_info[i].y * h_cos;
        var lat_corr = math.cos(lat * radians_in_degree) or 0.0000000001;
        east /= lat_corr;
        var p_lat = lat + north;
        var p_lon = lon + east;

        var info = geodinfo(p_lat, p_lon);
        var rolling_friction = point_info[i].r;
        var dynamic_friction = point_info[i].d;
        var friction_factor = 1;
        var bumpiness = 0;
        var solid = 1;
        if (info != nil and info[1] != nil) {
            friction_factor = info[1].friction_factor;
            rolling_friction = info[1].rolling_friction;
            bumpiness = info[1].bumpiness;
            solid = info[1].solid;
        }

        var z = 0;
        if (solid) {
            z = -point_info[i].z;
            # Bumpiness has a period of about 16m and an amplitude
            # of about 1m (40 inches) for bumpiness == 1.
            if (bumpiness) {
                var l = p_lon / lat_corr;
                var dist_m = math.sqrt(p_lat*p_lat + l*l) * meters_in_degree;
                z += 20 * bumpiness * math.sin(math.pi * dist_m * 0.125);
            }

            var static_friction = point_info[i].s - rain_coeff - snow_coeff;
            static_friction *= friction_factor;
            if (static_friction < rolling_friction)
                static_friction = rolling_friction;
            if (static_friction < 0.1)
                static_friction = 0.1;
        } else {
            if (point_info[i].g)
                rolling_friction = 1;

            z = point_info[i].zs;
            z += wave_amp * math.sin(wave_freq * systime() + i);
            static_friction = rolling_friction; # Make brakes ineffective.
        }

        if (dynamic_friction > static_friction)
            dynamic_friction = static_friction;

        var prop = (point_info[i].g
                    ? "fdm/jsbsim/gear/unit["~i~"]"
                    : "fdm/jsbsim/contact/unit["~i~"]");

        setprop(prop~"/static_friction_coeff", static_friction);
        setprop(prop~"/dynamic_friction_coeff", dynamic_friction);
        if (point_info[i].g)
            setprop(prop~"/rolling_friction_coeff", rolling_friction);
        setprop(prop~"/z-position", z);

        setprop(prop~"/friction/friction_factor", friction_factor);
        setprop(prop~"/friction/rolling_friction", rolling_friction);
        setprop(prop~"/friction/bumpiness", bumpiness);
        setprop(prop~"/friction/solid", solid);
        setprop(prop~"/friction/lat", p_lat);
        setprop(prop~"/friction/lon", p_lon);
    }
}

setprop("sim/fdm/surface/override-level", 1);
update_reactions();
