import h2d.Object;

class GameObject {
    public var sprite: Object;

    public var gridX: Int = 0;
    public var gridY: Int = 0;
    // 1000 rem = 1 grid
    public var remX: Int = 0;
    public var remY: Int = 0;
    public var deltaX: Int = 0;
    public var deltaY: Int = 0;

    public var x(get, set): Float;
    public var y(get, set): Float;
    public var pixelX(get, set): Float;
    public var pixelY(get, set): Float;

    private var gameboardX: Int = 0;
    private var gameboardY: Int = 0;

    // region getters & setters

    public function get_x() {
        return gridX + remX;
    }

    public function set_x(x) {
        RPGHeap.current.gameboard[gameboardX][gameboardY].remove(this);
        RPGHeap.current.gameboard[gameboardX = Math.round(x)][gameboardY].push(this);
        gridX = Math.floor(x);
        remX = Math.floor((x - gridX) * 1000);
        return x;
    }

    public function get_y() {
        return gridY + remY / 1000;
    }

    public function set_y(y) {
        RPGHeap.current.gameboard[gameboardX][gameboardY].remove(this);
        RPGHeap.current.gameboard[gameboardX][gameboardY = Math.round(y)].push(this);
        gridY = Math.floor(y);
        remY = Math.floor((y - gridY) * 1000);
        return y;
    }
    
    public function get_pixelX() {
        return (gridX + remX / 1000) * RPGHeap.GRID_WIDTH;
    }

    public function set_pixelX(x: Float) {
        var temp: Float = x / RPGHeap.GRID_WIDTH;
        RPGHeap.current.gameboard[gameboardX][gameboardY].remove(this);
        RPGHeap.current.gameboard[gameboardX = Math.round(temp)][gameboardY].push(this);
        gridX = Math.floor(temp);
        remX = Math.floor((temp - gridX) * 1000);
        return x;
    }

    public function get_pixelY() {
        return (gridY + remY / 1000) * RPGHeap.GRID_HEIGHT;
    }

    public function set_pixelY(y: Float) {
        var temp: Float = y / RPGHeap.GRID_HEIGHT;
        RPGHeap.current.gameboard[gameboardX][gameboardY].remove(this);
        RPGHeap.current.gameboard[gameboardX][gameboardY = Math.round(temp)].push(this);
        gridY = Math.floor(temp);
        remY = Math.floor((temp - gridY) * 1000);
        return y;
    }

    // end region

    public function new() {
        sprite = new Object(RPGHeap.current.s2d);
        RPGHeap.current.gameboard[gameboardX][gameboardY].push(this);
    }

    public function update(dt: Float) {

    }
    
    private function updateGameboard(dt: Float) {
        RPGHeap.current.gameboard[gameboardX][gameboardY].remove(this);
        RPGHeap.current.gameboard[gameboardX = Math.round(gridX + (remX + deltaX) / 1000)][gameboardY = Math.round(gridY + (remY + deltaY) / 1000)].push(this);
    }
    
    private function postUpdate(dt: Float) {
        remX += deltaX;
        while (remX >= 1000) {remX -= 1000; gridX++;}
        while (remX < 0) {remX += 1000; gridX--;}
        remY += deltaY;
        while (remY >= 1000) {remY -= 1000; gridY++;}
        while (remY < 0) {remY += 1000; gridY--;}

        sprite.x = pixelX;
        sprite.y = pixelY;
    }
}