import hxd.Res;
import h2d.Text;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;
import hxd.Key;

using Utilities.MathExtensions;

class Event {
    public static var updates = new Array<Float->Void>();

    public static function cameraMode(callback: Void->Void, isCameraAuto: Bool) {
        RPGHeap.isCameraAuto = isCameraAuto;
        callback();
    }
}

class MessageBox {
    var messageContainer: Object;
    var box: NineSlice.NSRect;
    var text: Text;
    var menuContainer: Object;
    var menuBox: NineSlice.NSRect;
    var choiceBox: NineSlice.NSRect;
    var choiceContainer: Object;
    var takeInput: Bool;
    var string: String;
    var timer: Int;
    var reveal: Int;
    var choice: Int;
    var isMenu = false;
    var stayOn = false;

    var messageCallback: Void->Void;
    var menuCallback: Int->Void;

    public function new() {
        messageContainer = new Object(RPGHeap.get().s2d);
        messageContainer.visible = false;

        var nsSet = new NineSlice.NSSet(Res.gui.window.toTile(), 2, 2, 2, 2);

        box = new NineSlice.NSRect(nsSet, messageContainer);
        box.width = RPGHeap.WIDTH;
        box.height = RPGHeap.HEIGHT / 3;
        box.y = RPGHeap.HEIGHT - box.height;

        text = new Text(hxd.res.DefaultFont.get(), messageContainer);
        text.textColor = 0x222034;
        text.x = 20;
        text.y = box.y + 20;

        menuContainer = new Object(RPGHeap.get().s2d);
        menuContainer.visible = false;
        
        menuBox = new NineSlice.NSRect(nsSet, menuContainer);
        choiceBox = new NineSlice.NSRect(nsSet, menuContainer);
        menuBox.width = (choiceBox.width = RPGHeap.WIDTH / 3) + 20;
        choiceBox.height = 36;
        menuBox.x = RPGHeap.WIDTH - menuBox.width;
        choiceBox.x = menuBox.x + 10;

        choiceContainer = new Object(menuContainer);
        choiceContainer.x = choiceBox.x + 10;
    }

    public function message(callback: Void->Void, stayOn: Bool, string: String) {
        text.text = "";
        this.stayOn = stayOn;
        this.string = string;
        reveal = 0;
        timer = 2;
        takeInput = false;
        messageContainer.visible = true;
        messageCallback = callback;
        isMenu = false; // A message is being displayed, not a menu
        Event.updates.push(update);
    }

    public function menu(callback: Int->Void, stayOn: Bool, choices: Array<String>) {
        this.stayOn = stayOn;
        choiceContainer.removeChildren();
        menuBox.height = 20 + 36 * choices.length;
        menuBox.y = box.y - menuBox.height;
        choiceBox.y = menuBox.y + 10;
        choiceContainer.y = choiceBox.y + 10;
        var y = 0;
        for (choice in choices) {
            var choiceText = new Text(hxd.res.DefaultFont.get(), choiceContainer);
            choiceText.text = choice;
            choiceText.textColor = 0x222034;
            choiceText.x = 0;
            choiceText.y = y;
            y += 36;
        }
        choice = 0;
        takeInput = false;
        menuContainer.visible = true;
        menuCallback = callback;
        isMenu = true; // A menu is being displayed
        Event.updates.push(update);
    }

    public function update(dt: Float) {
        if (--timer == 0) {
            reveal++;
            text.text = string.substr(0, reveal);
            if (reveal < string.length) {
                timer = 2;
            }
        }

        if (takeInput) {
            if (isMenu) {
                if (Key.isPressed(Key.DOWN)) {
                    choice = (choice + 1) % choiceContainer.numChildren;
                    choiceBox.y = menuBox.y + choiceContainer.getChildAt(choice).y + 10;
                }
                if (Key.isPressed(Key.UP)) {
                    choice--;
                    if (choice < 0) choice += choiceContainer.numChildren;
                    choiceBox.y = menuBox.y + choiceContainer.getChildAt(choice).y + 10;
                }
                if (Key.isPressed(Key.Z)) {
                    messageContainer.visible = stayOn;
                    menuContainer.visible = false;
                    Event.updates.remove(update);
                    menuCallback(choice);
                }
            } else if (Key.isPressed(Key.Z)) {
                if (reveal < string.length) {
                    timer = -1;
                    reveal = string.length;
                    text.text = string.substr(0, reveal);
                } else {
                    messageContainer.visible = stayOn;
                    Event.updates.remove(update);
                    messageCallback();
                }
            }
        }
        
        if (!takeInput) takeInput = true;
    }
}

class Delay {
    var timer: Float;
    var duration: Int;
    var lagCompensation: Bool;
    var callback: Void->Void;

    public function new() {}

    public function delay(callback: Void->Void, duration: Int, lagCompensation: Bool) {
        timer = 0;
        this.duration = duration;
        this.lagCompensation = lagCompensation;
        this.callback = callback;
        Event.updates.push(update);
    }

    public function update(dt: Float) {
        if (timer >= duration) {
            Event.updates.remove(update);
            callback();
            return;
        }
        if (lagCompensation) timer += dt * 60;
        else timer++;
    }
}

class CameraWalk {
    var bx: Float;
    var by: Float;
    var dx: Float;
    var dy: Float;
    var timer: Float;
    var duration: Int;
    var lagCompensation: Bool;
    var callback: Void->Void;

    public function new() {}

    public function cameraWalk(callback: Void->Void, dx: Float, dy: Float, duration: Int, lagCompensation: Bool) {
        bx = RPGHeap.viewport.x;
        by = RPGHeap.viewport.y;
        this.dx = dx;
        this.dy = dy;
        timer = 0;
        this.duration = duration;
        this.lagCompensation = lagCompensation;
        this.callback = callback;
        Event.updates.push(update);
    }

    public function update(dt: Float) {
        if (timer >= duration) {
            RPGHeap.viewport.x = bx - dx;
            RPGHeap.viewport.y = by - dy;
            Event.updates.remove(update);
            callback();
        } else {
            RPGHeap.viewport.x = bx - dx * (timer / duration);
            RPGHeap.viewport.y = by - dy * (timer / duration);
            if (lagCompensation) timer += dt * 60;
            else timer++;
        }
    }
}

class ScreenShake {
    var strength: Float;
    var timer: Float;
    var duration: Int;
    var async: Bool;
    var lagCompensation: Bool;
    var callback: Void->Void;

    public function new() {}

    public function screenShake(callback: Void->Void, strength: Float, duration: Int, async: Bool, lagCompensation: Bool) {
        this.strength = strength;
        timer = 0;
        this.duration = duration;
        this.async = async;
        this.lagCompensation = lagCompensation;
        if (async) callback();
        this.callback = callback;
        Event.updates.push(update);
    }

    public function update(dt: Float) {
        if (timer >= duration) {
            RPGHeap.viewport.container.x = 0;
            RPGHeap.viewport.container.y = 0;
            Event.updates.remove(update);
            if (!async) callback();
            return;
        }
        RPGHeap.viewport.container.x = Math.randomRange(-strength, strength);
        if (lagCompensation) timer += dt * 60;
        else timer++;
    }
}