#Initialise
var engine1 = engines.Jet.new(0, 0, 0.01, 5.21, 3, 4, 2, 4);
var engine2 = engines.Jet.new(1, 0, 0.01, 5.21, 3, 4, 2, 4);
var engine3 = engines.Jet.new(2, 0, 0.01, 5.21, 3, 4, 2, 4);
var engine4 = engines.Jet.new(3, 0, 0.01, 5.21, 3, 4, 2, 4);
var engine5 = engines.Jet.new(4, 0, 0.01, 5.21, 3, 4, 2, 4);
var engine6 = engines.Jet.new(5, 0, 0.01, 5.21, 3, 4, 2, 4);

engine1.init();
engine2.init();
engine3.init();
engine4.init();
engine5.init();
engine6.init();

props.globals.initNode("/sim/autostart/started", 0, "BOOL");

var eng1fuelon = func { setprop("/controls/engines/engine[0]/cutoff", 0); }
var eng2fuelon = func { setprop("/controls/engines/engine[1]/cutoff", 0); }
var eng3fuelon = func { setprop("/controls/engines/engine[2]/cutoff", 0); }
var eng4fuelon = func { setprop("/controls/engines/engine[3]/cutoff", 0); }
var eng5fuelon = func { setprop("/controls/engines/engine[4]/cutoff", 0); }
var eng6fuelon = func { setprop("/controls/engines/engine[5]/cutoff", 0); }

var eng1fueloff = func { setprop("/controls/engines/engine[0]/cutoff", 1); }
var eng2fueloff = func { setprop("/controls/engines/engine[1]/cutoff", 1); }
var eng3fueloff = func { setprop("/controls/engines/engine[2]/cutoff", 1); }
var eng4fueloff = func { setprop("/controls/engines/engine[3]/cutoff", 1); }
var eng5fueloff = func { setprop("/controls/engines/engine[4]/cutoff", 1); }
var eng6fueloff = func { setprop("/controls/engines/engine[5]/cutoff", 1); }

var eng1starter = func { setprop("/controls/engines/engine[0]/starter", 1); }
var eng2starter = func { setprop("/controls/engines/engine[1]/starter", 1); }
var eng3starter = func { setprop("/controls/engines/engine[2]/starter", 1); }
var eng4starter = func { setprop("/controls/engines/engine[3]/starter", 1); }
var eng5starter = func { setprop("/controls/engines/engine[4]/starter", 1); }
var eng6starter = func { setprop("/controls/engines/engine[5]/starter", 1); }

var eng1start = func {
  gui.popupTip("*** Engine start 1 left ***");
  eng1fueloff();
  eng1starter();
  settimer(eng1fuelon, 2);
  setprop("/controls/engines/engine[0]/condition", 1);
}

var eng2start = func {
  gui.popupTip("*** Engine start 2 left ***");
  eng2fueloff();
  eng2starter();
  settimer(eng2fuelon, 2);
  setprop("/controls/engines/engine[1]/condition", 1);
}

var eng3start = func {
  gui.popupTip("*** Engine start 3 left ***");
  eng3fueloff();
  eng3starter();
  settimer(eng3fuelon, 2);
  setprop("/controls/engines/engine[2]/condition", 1);
}

var eng4start = func {
  gui.popupTip("*** Engine start 4 right ***");
  eng4fueloff();
  eng4starter();
  settimer(eng4fuelon, 2);
  setprop("/controls/engines/engine[3]/condition", 1);
}

var eng5start = func {
  gui.popupTip("*** Engine start 5 right ***");
  eng5fueloff();
  eng5starter();
  settimer(eng5fuelon, 2);
  setprop("/controls/engines/engine[4]/condition", 1);
}

var eng6start = func {
  gui.popupTip("*** Engine start 6 right ***");
  eng6fueloff();
  eng6starter();
  settimer(eng6fuelon, 2);
  setprop("/controls/engines/engine[6]/condition", 1);
}

var engstart = func {
  settimer(eng1start, 2);
  settimer(eng6start, 4);
  settimer(eng2start, 6);
  settimer(eng5start, 8);
  settimer(eng3start, 10);
  settimer(eng4start, 12);
}

var engstop = func {
  eng1fueloff();
  setprop("/controls/engines/engine[0]/throttle", 0);
  setprop("/controls/engines/engine[0]/condition", 0);
  eng2fueloff();
  setprop("/controls/engines/engine[1]/throttle", 0);
  setprop("/controls/engines/engine[1]/condition", 0);
  eng3fueloff();
  setprop("/controls/engines/engine[2]/throttle", 0);
  setprop("/controls/engines/engine[2]/condition", 0);
  eng4fueloff();
  setprop("/controls/engines/engine[3]/throttle", 0);
  setprop("/controls/engines/engine[3]/condition", 0);
  eng5fueloff();
  setprop("/controls/engines/engine[4]/throttle", 0);
  setprop("/controls/engines/engine[4]/condition", 0);
  eng6fueloff();
  setprop("/controls/engines/engine[5]/throttle", 0);
  setprop("/controls/engines/engine[5]/condition", 0);
}

var autostart = func {
  var startstatus = getprop("/sim/autostart/started");
  if ( startstatus == 0 ) {
    gui.popupTip("Autostarting...");
    setprop("/sim/model/autostart", 1);
    setprop("/sim/autostart/started", 1);
    setprop("/controls/electric/battery-switch", 1);
    settimer(engstart, 0.4);
    gui.popupTip("Starting Engines");
  }
  if ( startstatus == 1 ) {
    gui.popupTip("Shutting Down...");
    setprop("/sim/model/autostart", 0);
    setprop("/sim/autostart/started", 0);
    engstop();
  }
}
