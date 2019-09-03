import h2d.Object;

class GameObject {
    public var sprite: Object;

    public var gridX: Int = 0;
    public var gridY: Int = 0;
    public var remX: Float = 0;
    public var remY: Float = 0;
    public var deltaX: Float = 0;
    public var deltaY: Float = 0;

    public var x(get, set): Float;
    public var y(get, set): Float;
    public var pixelX(get, set): Float;
    public var pixelY(get, set): Float;

    // region getters & setters

    public function get_x() {
        return gridX + remX;
    }

    public function set_x(x) {
        gridX = Math.floor(x);
        remX = x - gridX;
        return x;
    }

    public function get_y() {
        return gridY + remY;
    }

    public function set_y(y) {
        gridY = Math.floor(y);
        remY = y - gridY;
        return y;
    }
    
    public function get_pixelX() {
        return (gridX + remX) * RPGHeap.GRID_WIDTH;
    }

    public function set_pixelX(x: Float) {
        var temp: Float = x / RPGHeap.GRID_WIDTH;
        gridX = Math.floor(temp);
        remX = temp - gridX;
        return x;
    }

    public function get_pixelY() {
        return (gridY + remY) * RPGHeap.GRID_HEIGHT;
    }

    public function set_pixelY(y: Float) {
        var temp: Float = y / RPGHeap.GRID_HEIGHT;
        gridY = Math.floor(temp);
        remY = temp - gridY;
        return y;
    }

    // end region

    public function new() {
        sprite = new Object(RPGHeap.current.s2d);
    }

    public function update(dt: Float) {}
    public function postUpdate(dt: Float) {
        remX += deltaX;
        while (remX >= 1) {remX--; gridX++;}
        while (remX < 0) {remX++; gridX--;}
        remY += deltaY;
        while (remY >= 1) {remY--; gridY++;}
        while (remY < 0) {remY++; gridY--;}

        sprite.x = pixelX;
        sprite.y = pixelY;
    }
}