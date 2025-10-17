print("LOADING weapons.nas pew pew! fox 3 fox3!.");
################################################################################
#
#                        F-22 WEAPONS SETTINGS
#							Thanks to the m2005-5's developpers
#                          and Special thanks to Developer0607! (Ghost)
################################################################################

var dt = 0;
var isFiring = 0;
var splashdt = 0;
var MPMessaging = props.globals.getNode("/payload/armament/msg", 1);
# Trigger
fire_MG = func() {  # b would be in the ()

    var time = getprop("/sim/time/elapsed-sec");
    if(getprop("/sim/failure-manager/systems/wcs/failure-level"))return;
    if (getprop("controls/armament/trigger") == 0){return;} #hmmm
    if(getprop("/controls/armament/stick-selector") == 1)
    {
        if (getprop("controls/armament/master-arm") == 1) {
        isFiring = 1;
        
        setprop("/controls/armament/gun-trigger", 1);
        screen.log.write("Trigger!");
        settimer(autostopFiring, 0.47); # Fast burst
        } else {
            screen.log.write("Master arm is not armed");
        }

        #
    }
    if(getprop("/controls/armament/stick-selector") == 2)
    {
     #   if(b == 1)
     #   {
            if (getprop("controls/armament/master-arm") == 1) {
            # var time = getprop("/sim/time/elapsed-sec");
            if(time - dt > 0) # Adjust this 0 for limit on how many missiles you can shoot at once speed limit
            {
                    var missile = getprop("controls/missile");
    setprop("controls/missile", !missile);
                dt = time;
                m2000_load. SelectNextPylon();
                #(0,0); # Open the bay doors of the currently selected weapon
                var pylon = getprop("/controls/armament/missile/current-pylon");
                m2000_load.dropLoad(pylon);
                screen.log.write("Trigger!");
                print("Should fire Missile");
                setprop("/controls/armament/missile-trigger", 1);



            }
        } else {
            screen.log.write("Master arm is not armed");
        }
    }
}
# Pickle
fire_MG_pic = func() {  # b would be in the ()

    var time = getprop("/sim/time/elapsed-sec");
    if(getprop("/sim/failure-manager/systems/wcs/failure-level"))return;
    if (getprop("controls/armament/pickle") == 0){return;} #hmmm
        if (getprop("controls/armament/master-arm") == 1) {
        # var time = getprop("/sim/time/elapsed-sec");
        if(time - dt > 1) # Adjust this 0 for limit on how many missiles you can shoot at once speed limit
            {
            var missile = getprop("controls/missile");
            setprop("controls/missile", !missile);
            dt = time;
            m2000_load.SelectNextPylon();
            screen.log.write("Pickle!");
            #f22.fire(0,0); # Open the bay doors of the currently selected weapon
            var pylon = getprop("/controls/armament/missile/current-pylon");
            m2000_load.dropLoad(pylon);
            print("Should fire Missile");
            setprop("/controls/armament/missile-trigger", 1);
            }
    } else {
        screen.log.write("Master arm is not armed");
    }
}



var autostopFiring = func() {
    setprop("/controls/armament/missile-trigger", 0);
    setprop("/controls/armament/gun-trigger", 0);
    isFiring = 0;
}


var stopFiring = func() {
    if (getprop("controls/armament/trigger") == 0) {

        setprop("/controls/armament/missile-trigger", 0);
    setprop("/controls/armament/gun-trigger", 0);
    isFiring = 0;
    }
}

gun_timer = maketimer(0.01, stopFiring);
gun_timer.start();

reload = func() {
    setprop("/ai/submodels/submodel/count",    480);
    setprop("/ai/submodels/submodel[1]/count", 480);
    setprop("/ai/submodels/submodel[2]/count", 480);
    setprop("/ai/submodels/submodel[3]/count", 480);
    setprop("/ai/submodels/submodel[4]/count", 480);
    setprop("/ai/submodels/submodel[5]/count", 480);
    setprop("/ai/submodels/submodel[6]/count", 480);
    setprop("/ai/submodels/submodel[7]/count", 480);
    setprop("/f22/flare",200);
    setprop("/f22/chaff",200);
    screen.log.write("Reloaded guns and countermessures! Repaired damage aswell.");
}


input = {
  elapsed:          "/sim/time/elapsed-sec",
  impact:           "/ai/models/model-impact",
};

foreach(var name; keys(input)) {
      input[name] = props.globals.getNode(input[name], 1);
}

var last_impact = 0;

var hit_count = 0;

#gun hits

var hits_count = 0;
var hit_timer  = nil;
var hit_callsign = "";

var Mp = props.globals.getNode("ai/models");
var valid_mp_types = {
    multiplayer: 1, tanker: 1, aircraft: 1, ship: 1, groundvehicle: 1,
};

# Find a MP aircraft close to a given point (code from the Mirage 2000)
var findmultiplayer = func(targetCoord, dist) {
    if(targetCoord == nil) return nil;

    var raw_list = Mp.getChildren();
    var SelectedMP = nil;
    foreach(var c ; raw_list)
    {
        var is_valid = c.getNode("valid");
        if(is_valid == nil or !is_valid.getBoolValue()) continue;

        var type = c.getName();

        var position = c.getNode("position");
        var name = c.getValue("callsign");
        if(name == nil or name == "") {
            # fallback, for some AI objects
            var name = c.getValue("name");
        }
        if(position == nil or name == nil or name == "" or !contains(valid_mp_types, type)) continue;

        var lat = position.getValue("latitude-deg");
        var lon = position.getValue("longitude-deg");
        var elev = position.getValue("altitude-ft") * FT2M;

        if(lat == nil or lon == nil or elev == nil) continue;

        MpCoord = geo.Coord.new().set_latlon(lat, lon, elev);
        var tempoDist = MpCoord.direct_distance_to(targetCoord);
        if(dist > tempoDist) {
            dist = tempoDist;
            SelectedMP = name;
        }
    }
    return SelectedMP;
}

var impact_listener = func {
    var ballistic_name = props.globals.getNode("/ai/models/model-impact").getValue();
    var ballistic = props.globals.getNode(ballistic_name, 0);
    if (ballistic != nil and ballistic.getName() != "munition") {
        var typeNode = ballistic.getNode("impact/type");
        if (typeNode != nil and typeNode.getValue() != "terrain") {
            var lat = ballistic.getNode("impact/latitude-deg").getValue();
            var lon = ballistic.getNode("impact/longitude-deg").getValue();
            var elev = ballistic.getNode("impact/elevation-m").getValue();
            var impactPos = geo.Coord.new().set_latlon(lat, lon, elev);
            var target = findmultiplayer(impactPos, 80);

            if (target != nil) {
                var typeOrd = ballistic.getNode("name").getValue();
                if(target == hit_callsign) {
                    # Previous impacts on same target
                    hits_count += 1;
                }
                else {
                    if (hit_timer != nil) {
                        # Previous impacts on different target, flush them first
                        hit_timer.stop();
                        hitmessage(typeOrd);
                    }
                    hits_count = 1;
                    hit_callsign = target;
                    hit_timer = maketimer(1, func {hitmessage(typeOrd,hit_callsign,hits_count);});
                    hit_timer.singleShot = 1;
                    hit_timer.start();
                }
            }
        }
    }
}

var hitmessage = func(typeOrd,callsign,hits) {
    #print("inside hitmessage");
    var phrase = "M61A1 shell" ~ " hit: " ~ callsign ~ ": " ~ hits ~ " hits";
    if (getprop("payload/armament/msg") == 1) {
      #setprop("/sim/multiplay/chat", phrase);   Old damage system
        #armament.defeatSpamFilter(phrase);
    print("Guns hit target");
        var msg = notifications.ArmamentNotification.new("mhit", 4, -1*(damage.shells["M61A1 shell"][0]+1));
        msg.RelativeAltitude = 0;
        msg.Bearing = 0;
        msg.Distance = hits;
        msg.RemoteCallsign = callsign;
        notifications.hitBridgedTransmitter.NotifyAll(msg);
        screen.log.write("Guns Hit!");
        damage.damageLog.push("You hit "~callsign~" with "~"M61A1 shells"~", "~hits~" times.");
    } else {
        setprop("/sim/messages/atc", phrase);
    }
    hit_callsign = "";
    hit_timer = nil;
    hits_count = 0;
}

# setup impact listener
setlistener("/ai/models/model-impact", impact_listener, 0, 0);
setprop("/controls/armament/target-selected",0);
setprop("/controls/armament/weapon-selected",0);
var pickle = func() {
    if (getprop("controls/armament/pickle") == 1) {
        print("pickle on");
    } else {
        print("pickle off");
    }
}



setlistener("/controls/armament/trigger",fire_MG);
setlistener("/controls/armament/pickle",fire_MG_pic);





var switch_target = func(){
    if(getprop("/controls/armament/target-selected") == 1) {
        radar.next_Target_Index();
        setprop("/controls/armament/target-selected", 0);   
    }
    if(getprop("/controls/armament/target-selected") == -1) {
        radar.previous_Target_Index();
        setprop("/controls/armament/target-selected", 0);   
    }
}

# Target switch
setlistener("/controls/armament/target-selected",switch_target);


var switch_weapon = func(){
    if(getprop("/controls/armament/weapon-selected") == 1) {
        # AA
        if (getprop("/controls/armament/selected-weapon") == "none"){
            setprop("/controls/armament/selected-weapon","Aim-120");
            setprop("/controls/armament/selected-weapon-digit",2);
            screen.log.write("Joystick: A/A Selected: "~getprop("/controls/armament/selected-weapon")~"");
            setprop("/controls/armament/weapon-selected", 0);   
            return 0;
            
        }
        if (getprop("/controls/armament/selected-weapon") == "GBU-39"){
            setprop("/controls/armament/selected-weapon","Aim-120");
            setprop("/controls/armament/selected-weapon-digit",2);
            screen.log.write("Joystick: A/A Selected: "~getprop("/controls/armament/selected-weapon")~"");
            setprop("/controls/armament/weapon-selected", 0);   
            return 0;
            
        }
        if (getprop("/controls/armament/selected-weapon") == "JDAM"){
            setprop("/controls/armament/selected-weapon","Aim-120");
            setprop("/controls/armament/selected-weapon-digit",2);
            screen.log.write("Joystick: A/A Selected: "~getprop("/controls/armament/selected-weapon")~"");
            setprop("/controls/armament/weapon-selected", 0);   
            return 0;
        }
        if (getprop("/controls/armament/selected-weapon") == "Aim-9x"){
            setprop("/controls/armament/selected-weapon","Aim-120");
            setprop("/controls/armament/selected-weapon-digit",2);
            screen.log.write("Joystick: A/A Selected: "~getprop("/controls/armament/selected-weapon")~"");
            setprop("/controls/armament/weapon-selected", 0);   
            return 0;
        }
        if (getprop("/controls/armament/selected-weapon") == "Aim-120"){
            setprop("/controls/armament/selected-weapon","Aim-260");
            setprop("/controls/armament/selected-weapon-digit",4);
            screen.log.write("Joystick: A/A Selected: "~getprop("/controls/armament/selected-weapon")~"");
            setprop("/controls/armament/weapon-selected", 0);   
            return 0;
        }
        if (getprop("/controls/armament/selected-weapon") == "Aim-260"){
            setprop("/controls/armament/selected-weapon","Aim-9x");
            setprop("/controls/armament/selected-weapon-digit",1);
            screen.log.write("Joystick: A/A Selected: "~getprop("/controls/armament/selected-weapon")~"");
            setprop("/controls/armament/weapon-selected", 0);   
            return 0;
        }

        setprop("/controls/armament/weapon-selected", 0);   
    }
    if(getprop("/controls/armament/weapon-selected") == -1) {
        # AG
        if (getprop("/controls/armament/selected-weapon") == "none" or getprop("/controls/armament/selected-weapon") == "Aim-120" or getprop("/controls/armament/selected-weapon") == "Aim-260" or getprop("/controls/armament/selected-weapon") == "Aim-9x"){
            setprop("/controls/armament/selected-weapon","GBU-39");
            setprop("/controls/armament/selected-weapon-digit",3);
            screen.log.write("Joystick: A/G Selected: "~getprop("/controls/armament/selected-weapon")~"");
            setprop("/controls/armament/weapon-selected", 0);   
            return 0;
        }
        if (getprop("/controls/armament/selected-weapon") == "GBU-39"){
            setprop("/controls/armament/selected-weapon","JDAM");
            setprop("/controls/armament/selected-weapon-digit",4);
            screen.log.write("Joystick: A/G Selected: "~getprop("/controls/armament/selected-weapon")~"");
            setprop("/controls/armament/weapon-selected", 0);   
            return 0;
        }
        if (getprop("/controls/armament/selected-weapon") == "JDAM"){
            setprop("/controls/armament/selected-weapon","GBU-39");
            setprop("/controls/armament/selected-weapon-digit",1);
            screen.log.write("Joystick: A/G Selected: "~getprop("/controls/armament/selected-weapon")~"");
            setprop("/controls/armament/weapon-selected", 0);   
            return 0;
        }
        setprop("/controls/armament/weapon-selected", 0);   
    }
}

#switch_weapon();
#print("ae");

var missile_reject = func(){
    print("Reject pressed");
    if (getprop("/controls/armament/missile-reject") == 1) {
        #screen.log.write("Reject!");
        #CMS.updatecms();
        #CMS.trigger();
        print("No CMS Detected!");
        setprop("/controls/armament/missile-reject",0);
    }
}


setlistener("/controls/armament/missile-reject",missile_reject);


var stickreporter = func(){
    if(getprop("/controls/armament/stick-selector") == 1)screen.log.write("Selected M61A1 Vulcon.",1,0.4,0.4);
    else{screen.log.write("Selected missiles.",1,0.4,0.4);}
}
setlistener("/controls/armament/stick-selector",stickreporter);

switch_weapon_timer = maketimer(0,switch_weapon);
switch_weapon_timer.start();

