import hxd.Res;

class RPGHeap extends hxd.App{
    public static var current: RPGHeap;
    public static final GRID_WIDTH: Int = 32;
    public static final GRID_HEIGHT: Int = 32;

    public var player: Player;

    override function init() {
        hxd.Res.initEmbed();
        s2d.scaleMode = ScaleMode.LetterBox(544, 416);
        
        // Using Jael character sprite by Sithjester as placeholder, many thanks!
        player = new Player(Res.jael.toTile());
        player.x = 8;
        player.y = 6;
    }

    override function update(dt: Float) {
        player.update(dt);
    }

    static function main() {
        current = new RPGHeap();
    }
}