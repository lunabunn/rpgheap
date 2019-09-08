import hxd.Res;

class RPGHeap extends hxd.App{
    public static var current: RPGHeap;
    public static final GRID_WIDTH: Int = 32;
    public static final GRID_HEIGHT: Int = 32;

    public var player: Character;
    public var map: Tilemap;
    public var gameboard: Array<Array<Array<GameObject>>>;

    override function init() {
        hxd.Res.initEmbed();
        s2d.scaleMode = ScaleMode.LetterBox(544, 416);

        map = new Tilemap(Res.chessboard_json, [[1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1]], 17, s2d);
        gameboard = createGameboard(map.width, map.height);

        // Using Jael character sprite by Sithjester as placeholder, many thanks!
        player = new Character(Res.jael.toTile(), new Character.PlayerBrain());
        player.x = 8;
        player.y = 6;
    }

    override function update(dt: Float) {
        player.update(dt);
    }

    public static function createGameboard(w: Int, h: Int): Array<Array<Array<GameObject>>> {
        trace(w, h);
        var out = new Array<Array<Array<GameObject>>>();
        for (x in 0...w) {
            var sub = new Array<Array<GameObject>>();
            for (y in 0...h) {
                sub.push([]);
            }
            out.push(sub);
        }
        return out;
    }

    static function main() {
        current = new RPGHeap();
    }
}