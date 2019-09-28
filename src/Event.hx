import hxd.Key;
import h2d.Text;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;
using Utilities.MathExtensions;

class Event {
    public var callback: Void->Void;
    public static var activeEvents = new Array<Event>();

    public function new() {}
    public function update(dt: Float) {}
    public function run(callback: Void->Void, ?args: Array<Dynamic>) {
        activeEvents.push(this);
        this.callback = function() {
            activeEvents.remove(this);
            callback();
        };
    }
}

class MessageEvent extends Event {
    // Usage: message <text>
    // Displays a message box containing <text>
    override public function run(callback: Void->Void, ?args: Array<Dynamic>) {
        super.run(callback);
        text.text = "";
        string = args[0];
        reveal = 0;
        timer = 5;
        takeInput = false;
        container.visible = true;
    }

    override public function update(dt: Float) {
        if (--timer == 0) {
            reveal++;
            text.text = string.substr(0, reveal);
            if (reveal < string.length) {
                timer = 5;
            }
        }

        if (takeInput && Key.isPressed(Key.Z)) {
            if (reveal < string.length) {
                timer = -1;
                reveal = string.length;
                text.text = string.substr(0, reveal);
            } else {
                container.visible = false;
                callback();
            }
        }
        
        if (!takeInput) takeInput = true;
    }

    var container: Object;
    var box: Bitmap;
    var text: Text;
    var takeInput: Bool;
    var string: String;
    var timer: Int;
    var reveal: Int;

    public function new() {
        super();
        container = new Object(RPGHeap.get().s2d);
        container.visible = false;
        box = new Bitmap(Tile.fromColor(0x99999999), container);
        box.y = RPGHeap.HEIGHT / 2;
        box.scaleX = RPGHeap.WIDTH;
        box.scaleY = RPGHeap.HEIGHT / 2;
        box.alpha = .5;
        text = new Text(hxd.res.DefaultFont.get(), container);
        text.x = 20;
        text.y = RPGHeap.HEIGHT / 2 + 20;
    }
}

class MenuEvent extends Event {
    // Usage: menu
    // Displays a menu

    // MenuEvent is special, so... I know, very hacky.
    public function runCustom(callback: Int->Void, choices: Array<String>) {
        Event.activeEvents.push(this);
        callbackCustom = callback;
        text.text = "";
        this.choices = choices;
        var i = 1;
        for (choice in choices) {
            text.text += '${i % 10}: $choice\n';
            i++;
        }
        takeInput = false;
        container.visible = true;
    }

    override public function update(dt: Float) {
        if (takeInput) {
            if (Key.isPressed(Key.NUMBER_1) && choices.length > 0) {
                Event.activeEvents.remove(this);
                container.visible = false;
                callbackCustom(0);
            } else if (Key.isPressed(Key.NUMBER_2) && choices.length > 1) {
                Event.activeEvents.remove(this);
                container.visible = false;
                callbackCustom(1);
            } else if (Key.isPressed(Key.NUMBER_3) && choices.length > 2) {
                Event.activeEvents.remove(this);
                container.visible = false;
                callbackCustom(2);
            } else if (Key.isPressed(Key.NUMBER_4) && choices.length > 3) {
                Event.activeEvents.remove(this);
                container.visible = false;
                callbackCustom(3);
            } else if (Key.isPressed(Key.NUMBER_5) && choices.length > 4) {
                Event.activeEvents.remove(this);
                container.visible = false;
                callbackCustom(4);
            } else if (Key.isPressed(Key.NUMBER_6) && choices.length > 5) {
                Event.activeEvents.remove(this);
                container.visible = false;
                callbackCustom(5);
            } else if (Key.isPressed(Key.NUMBER_7) && choices.length > 6) {
                Event.activeEvents.remove(this);
                container.visible = false;
                callbackCustom(6);
            } else if (Key.isPressed(Key.NUMBER_8) && choices.length > 7) {
                Event.activeEvents.remove(this);
                container.visible = false;
                callbackCustom(7);
            } else if (Key.isPressed(Key.NUMBER_9) && choices.length > 8) {
                Event.activeEvents.remove(this);
                container.visible = false;
                callbackCustom(8);
            } else if (Key.isPressed(Key.NUMBER_0) && choices.length > 9) {
                Event.activeEvents.remove(this);
                container.visible = false;
                callbackCustom(9);
            }
        } else {
            takeInput = true;
        }
    }

    var callbackCustom: Int->Void;
    var container: Object;
    var box: Bitmap;
    var text: Text;
    var choices: Array<String>;
    var takeInput: Bool;
    var string: String;

    public function new() {
        super();
        container = new Object(RPGHeap.get().s2d);
        container.visible = false;
        box = new Bitmap(Tile.fromColor(0x99999999), container);
        box.y = RPGHeap.HEIGHT / 2;
        box.scaleX = RPGHeap.WIDTH;
        box.scaleY = RPGHeap.HEIGHT / 2;
        box.alpha = .5;
        text = new Text(hxd.res.DefaultFont.get(), container);
        text.x = 20;
        text.y = RPGHeap.HEIGHT / 2 + 20;
    }
}

class DelayEvent extends Event {
    // Usage: delay <duaration> [lagCompensation=false]
    // Delays the execution of any events following by <duration> frames
    // If lagCompensation is true, will take the delta time of each frame into account
    override public function run(callback: Void->Void, ?args: Array<Dynamic>) {
        super.run(callback);
        timer = 0;
        duration = args[0];
        if (args.length > 1) lagCompensation = args[1];
        else lagCompensation = false;
    }

    override public function update(dt: Float) {
        if (timer >= duration) {
            callback();
            return;
        }
        if (lagCompensation) timer += dt * 60;
        else timer++;
    }

    var timer: Float;
    var duration: Int;
    var lagCompensation: Bool;
}

class CameraModeEvent extends Event {
    // Usage: cameramode <auto>
    // Sets the camera mode; <auto> determines whether or not the camera will automatically follow the player
    override public function run(callback: Void->Void, ?args: Array<Dynamic>) {
        super.run(callback);
        RPGHeap.isCameraAuto = args[0];
        this.callback();
    }
}

class CameraWalkEvent extends Event {
    // Usage: camerawalk <x> <y> <duration> [lagCompensation=false]
    // Moves the camera <x> pixels to the right and <y> pixels down over <duration> frames
    // If lagCompensation is true, will take the delta time of each frame into account
    override public function run(callback: Void->Void, ?args: Array<Dynamic>) {
        super.run(callback);
        bx = RPGHeap.viewport.x;
        by = RPGHeap.viewport.y;
        dx = args[0];
        dy = args[1];
        timer = 0;
        duration = args[2];
        if (args.length > 3) lagCompensation = args[3];
        else lagCompensation = false;
    }

    override public function update(dt: Float) {
        if (timer >= duration) {
            RPGHeap.viewport.x = bx - dx;
            RPGHeap.viewport.y = by - dy;
            callback();
        } else {
            RPGHeap.viewport.x = bx - dx * (timer / duration);
            RPGHeap.viewport.y = by - dy * (timer / duration);
            if (lagCompensation) timer += dt * 60;
            else timer++;
        }
    }

    public var bx: Float;
    public var by: Float;
    public var dx: Float;
    public var dy: Float;
    public var timer: Float;
    public var duration: Int;
    public var lagCompensation: Bool;
}

class ShakeEvent extends Event {
    // Usage: shake <strength> <duration> [async=false] [lagCompensation=false]
    // Shakes the screen with strength <strength> for <duration> frames
    // If [async] is true, event(s) following this one will be executed right after screenshake begins
    override public function run(callback: Void->Void, ?args: Array<Dynamic>) {
        Event.activeEvents.push(this);
        strength = args[0];
        timer = 0;
        duration = args[1];
        if (args.length > 2) async = args[2];
        else async = false;
        if (args.length > 3) lagCompensation = args[3];
        else lagCompensation = false;
        if (async) callback();
    }

    override public function update(dt: Float) {
        if (timer >= duration) {
            Event.activeEvents.remove(this);
            RPGHeap.viewport.container.x = 0;
            RPGHeap.viewport.container.y = 0;
            if (!async) callback();
            return;
        }
        RPGHeap.viewport.container.x = Math.randomRange(-strength, strength);
        RPGHeap.viewport.container.y = Math.randomRange(-strength, strength);
        if (lagCompensation) timer += dt * 60;
        else timer++;
    }

    public var strength: Float;
    public var timer: Float;
    public var duration: Int;
    public var async: Bool;
    public var lagCompensation: Bool;
}