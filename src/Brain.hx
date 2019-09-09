import hxd.Key;

class Brain {
    public var movementQueue = new Array<Int>();
    public var owner: Entity;

    public function init(owner: Entity): Void {
        this.owner = owner;
    }

    public function new() {}
    public function update(dt: Float): Void {}
    public function onGrid(dt: Float): Void {}
}

class PlayerBrain extends Brain {
    final keyMap = [40 => 0, 37 => 1, 39 => 2, 38 => 3];
    
    override public function update(dt: Float): Void {
        if (Key.isPressed(Key.DOWN) && movementQueue.indexOf(keyMap[Key.DOWN]) == -1) movementQueue.unshift(keyMap[Key.DOWN]);
        if (Key.isPressed(Key.LEFT) && movementQueue.indexOf(keyMap[Key.LEFT]) == -1) movementQueue.unshift(keyMap[Key.LEFT]);
        if (Key.isPressed(Key.RIGHT) && movementQueue.indexOf(keyMap[Key.RIGHT]) == -1) movementQueue.unshift(keyMap[Key.RIGHT]);
        if (Key.isPressed(Key.UP) && movementQueue.indexOf(keyMap[Key.UP]) == -1) movementQueue.unshift(keyMap[Key.UP]);
        if (Key.isReleased(Key.DOWN)) movementQueue.remove(keyMap[Key.DOWN]);
        if (Key.isReleased(Key.LEFT)) movementQueue.remove(keyMap[Key.LEFT]);
        if (Key.isReleased(Key.RIGHT)) movementQueue.remove(keyMap[Key.RIGHT]);
        if (Key.isReleased(Key.UP)) movementQueue.remove(keyMap[Key.UP]);
    }
}