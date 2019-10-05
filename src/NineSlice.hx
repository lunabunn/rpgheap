import h2d.Object;
import h2d.Graphics;
import h2d.Tile;

class NSSet {
    public var tile: Tile;
    public var leftWidth: Int;
    public var topWidth: Int;
    public var rightWidth: Int;
    public var bottomWidth: Int;
    public var horizGap: Int;
    public var vertGap: Int;

    public function new(tile: Tile, leftWidth: Int, topWidth: Int, rightWidth: Int, bottomWidth: Int) {
        this.tile = tile;
        this.leftWidth = leftWidth;
        this.topWidth = topWidth;
        this.rightWidth = rightWidth;
        this.bottomWidth = bottomWidth;
        horizGap = cast(tile.width, Int) - leftWidth - rightWidth;
        vertGap = cast(tile.height, Int) - topWidth - bottomWidth;
    }
}

class NSRect extends Object {
    var graphics: Graphics;
    public var nsSet: NSSet;
    public var width(default, set): Float;
    public var height(default, set): Float;

    function set_width(x: Float): Float {
        width = x;
        redraw();
        return x;
    }

    function set_height(x: Float): Float {
        height = x;
        redraw();
        return x;
    }

    public function new(nsSet: NSSet, ?parent: Object) {
        super(parent);
        graphics = new Graphics(this);
        this.nsSet = nsSet;
        width = 100;
        height = 100;
    }

    inline function redraw() {
        graphics.clear();

        var leftWidth = Math.min(width / 2, nsSet.leftWidth);
        var topWidth = Math.min(height / 2, nsSet.topWidth);
        var rightWidth = Math.min(width / 2, nsSet.rightWidth);
        var bottomWidth = Math.min(height / 2, nsSet.bottomWidth);

        graphics.beginTileFill(nsSet.tile);
        graphics.drawRect(0, 0, leftWidth, topWidth);
        graphics.endFill();

        graphics.beginTileFill(width - nsSet.tile.width, nsSet.tile);
        graphics.drawRect(width - rightWidth, 0, rightWidth, topWidth);
        graphics.endFill();

        graphics.beginTileFill(0, height - nsSet.tile.height, nsSet.tile);
        graphics.drawRect(0, height - bottomWidth, leftWidth, bottomWidth);
        graphics.endFill();

        graphics.beginTileFill(width - nsSet.tile.width, height - nsSet.tile.height, nsSet.tile);
        graphics.drawRect(width - rightWidth, height - bottomWidth, rightWidth, bottomWidth);
        graphics.endFill();

        var horizGap = width - leftWidth - rightWidth;
        var vertGap = height - topWidth - bottomWidth;

        if (horizGap > 0) {
            graphics.beginTileFill(leftWidth * (1 - horizGap / nsSet.horizGap), 0, horizGap / nsSet.horizGap, nsSet.tile);
            graphics.drawRect(leftWidth, 0, horizGap, topWidth);
            graphics.endFill();

            graphics.beginTileFill(leftWidth * (1 - horizGap / nsSet.horizGap), height - nsSet.tile.height, horizGap / nsSet.horizGap, nsSet.tile);
            graphics.drawRect(leftWidth, height - bottomWidth, horizGap, bottomWidth);
            graphics.endFill();
        }

        if (vertGap > 0) {
            graphics.beginTileFill(0, topWidth * (1 - vertGap / nsSet.vertGap), 1, vertGap / nsSet.vertGap, nsSet.tile);
            graphics.drawRect(0, topWidth, leftWidth, vertGap);
            graphics.endFill();

            graphics.beginTileFill(width - nsSet.tile.width, topWidth * (1 - vertGap / nsSet.vertGap), 1, vertGap / nsSet.vertGap, nsSet.tile);
            graphics.drawRect(width - rightWidth, topWidth, rightWidth, vertGap);
            graphics.endFill();
        }

        if (horizGap > 0 && vertGap > 0) {
            graphics.beginTileFill(leftWidth * (1 - horizGap / nsSet.horizGap), topWidth * (1 - vertGap / nsSet.vertGap), horizGap / nsSet.horizGap, vertGap / nsSet.vertGap, nsSet.tile);
            graphics.drawRect(leftWidth, topWidth, horizGap, vertGap);
            graphics.endFill();
        }
    }
}