import hxd.Key;
import h2d.Text;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;

class Event {
    public var callback: Void->Void;
    public static var events = new Array<Event>();

    public function new() {}
    public function update(dt: Float) {}
    public function run(callback: Void->Void, ?args: Array<Dynamic>) {
        events.push(this);
        this.callback = function() {
            events.remove(this);
            callback();
        };
    }
}

class MessageEvent extends Event {
    // Usage: message <text>
    // Displays a message box containing<text>
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