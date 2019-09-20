import h2d.Graphics;
import hxd.Res;

class RPGHeap extends hxd.App {
    static var current: RPGHeap;
    public static final WIDTH: Int = 544;
    public static final HEIGHT: Int = 416;
    public static final GRID_WIDTH: Int = 32;
    public static final GRID_HEIGHT: Int = 32;

    public static var map: Tilemap;
    public static var gameboard: Array<Array<Array<Entity>>>;
    public static var debugGraphics: DebugGraphics;

    public static function get(): RPGHeap {
        return current;
    }
    
    override function init() {
        hxd.Res.initEmbed();
        s2d.scaleMode = ScaleMode.LetterBox(WIDTH, HEIGHT);

        map = new Tilemap(Res.chessboard_json, [[1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,2,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,2,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,2,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,2,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,2,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,2,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,2,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,2,0,1,0,1,0,1,0,1,0,1,0,1]], 17, s2d);
        gameboard = createGameboard(map.width, map.height);

        // Using Jael character sprite by Sithjester as placeholder, many thanks!
        var player = new Entity(Res.jael.toTile(), new Brain.PlayerBrain());
        player.x = 8;
        player.y = 6;
        player.speed = 1.5;

        var dummy = new Entity.Interactable(Res.jael.toTile(), new Brain());
        dummy.x = 4;
        dummy.y = 6;
        dummy.speed = 1;

        debugGraphics = new DebugGraphics(s2d);
        // debugGraphics.visible = false;
        debugGraphics.update(0);
    }

    override function update(dt: Float) {
        for (entity in Entity.entities) {
            entity.update(dt);
        }
        for (event in Event.events) {
            event.update(dt);
        }
        debugGraphics.update(dt);
    }

    public static function getCollider(x: Int, y: Int, dir: Int, ?excludeEntity:Entity, mapOnly=false) {
        if (x < 0 || y < 0 || x >= map.width || y >= map.height) return true;
        var out = map.colliders[x][y][dir];
        if (mapOnly) return out;
        for (entity in gameboard[x][y]) {
            if (entity == excludeEntity) continue;
            out = out || entity.collider[dir];
        }
        return out;
    }

    static function createGameboard(w: Int, h: Int): Array<Array<Array<Entity>>> {
        trace(w, h);
        var out = new Array<Array<Array<Entity>>>();
        for (x in 0...w) {
            var sub = new Array<Array<Entity>>();
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

class DebugGraphics extends Graphics {
    public function update(dt: Float) {
        this.clear();
        this.beginFill(0x0000FF, .5);
        for (x in 0...RPGHeap.map.width) {
            for (y in 0...RPGHeap.map.height) {
                if (RPGHeap.map.colliders[x][y][0]) this.drawRect(x * RPGHeap.GRID_WIDTH, (y + 1) * RPGHeap.GRID_HEIGHT - 5, RPGHeap.GRID_WIDTH, 5);
                if (RPGHeap.map.colliders[x][y][1]) this.drawRect(x * RPGHeap.GRID_WIDTH, y * RPGHeap.GRID_HEIGHT, 5, RPGHeap.GRID_HEIGHT);
                if (RPGHeap.map.colliders[x][y][2]) this.drawRect((x + 1) * RPGHeap.GRID_WIDTH - 5, y * RPGHeap.GRID_HEIGHT, 5, RPGHeap.GRID_HEIGHT);
                if (RPGHeap.map.colliders[x][y][3]) this.drawRect(x * RPGHeap.GRID_WIDTH, y * RPGHeap.GRID_HEIGHT, RPGHeap.GRID_WIDTH, 5);
            }
        }
        this.endFill();

        this.beginFill(0xFF0000, .5);
        for (x in 0...RPGHeap.map.width) {
            for (y in 0...RPGHeap.map.height) {
                var down = false, left = false;
                var right = false, up = false;
                for (Entity in RPGHeap.gameboard[x][y]) {
                    down = down || Entity.collider[0];
                    left = left || Entity.collider[0];
                    right = right || Entity.collider[0];
                    up = up || Entity.collider[0];
                }
                if (down) this.drawRect(x * RPGHeap.GRID_WIDTH, (y + 1) * RPGHeap.GRID_HEIGHT - 5, RPGHeap.GRID_WIDTH, 5);
                if (left) this.drawRect(x * RPGHeap.GRID_WIDTH, y * RPGHeap.GRID_HEIGHT, 5, RPGHeap.GRID_HEIGHT);
                if (right) this.drawRect((x + 1) * RPGHeap.GRID_WIDTH - 5, y * RPGHeap.GRID_HEIGHT, 5, RPGHeap.GRID_HEIGHT);
                if (up) this.drawRect(x * RPGHeap.GRID_WIDTH, y * RPGHeap.GRID_HEIGHT, RPGHeap.GRID_WIDTH, 5);
            }
        }
        this.endFill();

        this.beginFill(0x00FF00, .5);
        var cx = (Entity.entities[0].targetX + 0.5) * RPGHeap.GRID_WIDTH;
        var cy = (Entity.entities[0].targetY + 0.5) * RPGHeap.GRID_HEIGHT;
        this.drawRect(cx - 4, cy - 4, 8, 8);
        this.endFill();
    }
}