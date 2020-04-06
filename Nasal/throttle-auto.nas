
var throttleIdle = 0;
var throttleMax  = .94;
var throttleMovePerSecondSlow = 0.10;
var throttleMovePerSecondFast = 0.30;
var throttleUpdInterval = 0.05;

var setMaxPower = func{
    setPower(throttleMax, 1.0, 0);
}

var setIdlePower = func{
    setPower(throttleIdle, -1.0, 1);
}

var setPower = func(target, dir, fastInGround) {
    var e1p = "controls/engines/engine[0]/throttle";
    var onGround = getprop("gear/gear[0]/wow");
    var speed = onGround == fastInGround? throttleMovePerSecondFast : throttleMovePerSecondSlow;
    var curPower = getprop(e1p);
    if (dir*curPower < dir*target) {
        var timer = maketimer(throttleUpdInterval, func{
            if (getprop(e1p) != curPower) {
                return;
            }
            curPower += dir * speed * throttleUpdInterval;
            if (dir*curPower > dir*target) {
                curPower = target;
            }
            for (var i = 0; i < 2; i+=1) {
                setprop("controls/engines/engine["~i~"]/throttle", curPower);
            }
            if (dir*curPower < dir*target) {
               timer.restart(throttleUpdInterval);
            }
        });
        timer.singleShot = 1;
        timer.simulatedTime = 1;
        timer.start();
    }
}

