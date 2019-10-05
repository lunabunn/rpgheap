import hxd.Key;

class Brain {
    public var moveDir: Int = -1;
    public var dash: Bool = false;
    public var owner: Entity;

    public function init(owner: Entity): Void {
        this.owner = owner;
    }

    public function new() {}
    public function update(dt: Float): Void {}
    public function onGridBegin(dt: Float): Void {}
    public function onGridEnd(dt: Float): Void {}
}

class PlayerBrain extends Brain {
    public var paralyzed = false;
    private var movementQueue = new Array<Int>();
    final keyMap = [40 => 0, 37 => 1, 39 => 2, 38 => 3];
    
    override public function update(dt: Float): Void {
        if (paralyzed) {
            movementQueue = [];
            moveDir = -1;
            dash = false;
            return;
        }
        if (Key.isPressed(Key.DOWN) && movementQueue.indexOf(keyMap[Key.DOWN]) == -1) movementQueue.unshift(keyMap[Key.DOWN]);
        if (Key.isPressed(Key.LEFT) && movementQueue.indexOf(keyMap[Key.LEFT]) == -1) movementQueue.unshift(keyMap[Key.LEFT]);
        if (Key.isPressed(Key.RIGHT) && movementQueue.indexOf(keyMap[Key.RIGHT]) == -1) movementQueue.unshift(keyMap[Key.RIGHT]);
        if (Key.isPressed(Key.UP) && movementQueue.indexOf(keyMap[Key.UP]) == -1) movementQueue.unshift(keyMap[Key.UP]);
        if (Key.isReleased(Key.DOWN)) movementQueue.remove(keyMap[Key.DOWN]);
        if (Key.isReleased(Key.LEFT)) movementQueue.remove(keyMap[Key.LEFT]);
        if (Key.isReleased(Key.RIGHT)) movementQueue.remove(keyMap[Key.RIGHT]);
        if (Key.isReleased(Key.UP)) movementQueue.remove(keyMap[Key.UP]);
        dash = Key.isDown(Key.LSHIFT);

        if (movementQueue.length > 0) moveDir = movementQueue[0];
        else moveDir = -1;
    }

    override public function onGridEnd(dt: Float) {
        if (paralyzed) return;
        if (Key.isPressed(Key.Z)) for (entity in RPGHeap.gameboard[owner.targetX][owner.targetY]) {
            if (entity == owner) continue;
            if (Std.is(entity, Entity.Interactable)) {
                cast (entity, Entity.Interactable).interact();
                break;
            }
        }
    }
}

class RandomBrain extends Brain {
    override public function onGridBegin(dt: Float): Void {
        moveDir = Math.floor(Math.random() * 4);
    }
}