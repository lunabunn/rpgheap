import hxd.Res;
import haxe.Json;
import h2d.Object;
import haxe.ds.ObjectMap;
import h2d.Tile;
import hxd.res.Resource;
import h2d.TileGroup;

class Tilemap extends Object {
    public var width: Int;
    public var height: Int;

    public var colliders = new Array<Array<Array<Bool>>>();

    public function new(tileset: Resource, data: Array<Array<Int>>, width: Int, ?parent: Object) {
        super(parent);
        var tileset = Tileset.get(tileset);
        var tx: Int, ty: Int;
        var tilegroup: TileGroup;
        this.width = width;
        for (i in 0...width) {
            colliders.push(new Array<Array<Bool>>());
        }
        for (layer in data) {
            tx = 0;
            ty = 0;
            tilegroup = new TileGroup(tileset.tile, this);
            for (tile in layer) {
                tilegroup.add(tx * RPGHeap.GRID_WIDTH, ty * RPGHeap.GRID_HEIGHT, tileset.tiles[tile]);
                colliders[tx][ty] = tileset.colliders[tile];
                if (tx + 1 < width) tx++;
                else {tx = 0; ty++;}
            }
        }
        this.height = colliders[0].length;
    }
}

class Tileset {
    public var tile: Tile;
    public var tiles: Array<Tile>;
    public var colliders: Array<Array<Bool>>;

    public function new(tile: Tile, tiles: Array<Tile>, colliders: Array<Array<Bool>>) {
        this.tile = tile;
        this.tiles = tiles;
        this.colliders = colliders;
    }

    private static var _tilesets = new ObjectMap<Resource, Tileset>();

    public static function get(tilesetFile: Resource): Tileset {
        if (_tilesets.exists(tilesetFile)) {
            return _tilesets.get(tilesetFile);
        } else {
            var tilesetData = Json.parse(tilesetFile.entry.getText());
            var collidersData: Null<haxe.DynamicAccess<Array<Bool>>> = tilesetData.colliders;
            var tile = Res.load(tilesetData.source).toTile();
            var tiles = tile.gridFlatten(RPGHeap.GRID_WIDTH);
            var colliders = new Array<Array<Bool>>();
            for (i in 0...tiles.length) {
                if (collidersData != null && collidersData.get('$i') != null) {
                    colliders[i] = tilesetData.colliders.get('$i');
                } else {
                    colliders[i] = [false, false, false, false];
                }
            }
            var tileset = new Tileset(tile, tiles, colliders);
            _tilesets.set(tilesetFile, tileset);
            trace(tileset);
            return tileset;
        }
    }
}