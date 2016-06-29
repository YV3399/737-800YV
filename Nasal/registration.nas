#############################################################################
# This file is part of FlightGear, the free flight simulator
# http://www.flightgear.org/
#
# Copyright (C) 2009 Torsten Dreyer, Torsten (at) t3r _dot_ de
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#############################################################################

# ===========================
# Immatriculation by Zakharov
# Tuned by Torsten Dreyer
# ===========================
var registrationDialog = gui.Dialog.new("/sim/gui/dialogs/b707/status/dialog",
				  "Aircraft/737-800/Systems/registration.xml");

var l = setlistener("/sim/signals/fdm-initialized", func {
  var callsign = props.globals.getNode("/sim/multiplay/callsign",1).getValue();
  if( callsign == nil or callsign == "callsign" )
    callsign = "N123AB";
  props.globals.initNode( "/sim/multiplay/generic/string[0]", callsign, "STRING" );
  removelistener(l);
});