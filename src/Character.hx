import h2d.Bitmap;
import h2d.Tile;
import hxd.Key;

class Character extends GameObject {
    var bitmap: Bitmap;
    var speed: Int = 50;
    var brain: Brain;

    var anims = new Array<Array<Tile>>();
    var animPaused = false;
    var currentAnim(default, set): Int = 0;
    var currentFrame(default, set): Int = 0;
    var movementQueuePrev = new Array<Int>();

    public function set_currentAnim(anim: Int) {
        currentAnim = anim;
        bitmap.tile = anims[currentAnim][currentFrame];
        return anim;
    }

    public function set_currentFrame(frame: Int) {
        currentFrame = frame % anims[currentAnim].length;
        bitmap.tile = anims[currentAnim][currentFrame];
        return frame;
    }

    public function new(charChip: Tile, brain: Brain) {
        super();

        var cw = charChip.width / 4;
        var ch = charChip.height / 4;
        for (y in 0...4) {
            anims.push(new Array<Tile>());
            for (x in 0...4) {
                anims[y].push(charChip.sub(cw * x, ch * y, cw, ch));
            }
        }
        
        bitmap = new Bitmap(anims[0][0], sprite);
        animPaused = true;
        bitmap.y = -22;

        this.brain = brain;
        brain.init(this);
    }

    override public function update(dt: Float) {
        brain.update(dt);

        if (!animPaused && remX % 500 == 0 && remY % 500 == 0) {
            currentFrame++;
        }

        if (remX % 1000 == 0 && remY % 1000 == 0) {
            brain.onGrid(dt);
            if (brain.movementQueue.toString() != movementQueuePrev.toString()) {
                if (brain.movementQueue.length > 0) {
                    switch (brain.movementQueue[0]) {
                        case 0: deltaX = 0; deltaY = speed;
                        case 1: deltaX = -speed; deltaY = 0;
                        case 2: deltaX = speed; deltaY = 0;
                        case 3: deltaX = 0; deltaY = -speed;
                    }
                    
                    if (animPaused) currentFrame++;
                    if (currentAnim != brain.movementQueue[0]) {
                        currentAnim = brain.movementQueue[0];
                    }
                    animPaused = false;
                } else {
                    deltaX = 0;
                    deltaY = 0;
                    currentFrame = 0;
                    animPaused = true;
                }

                movementQueuePrev = brain.movementQueue.copy();
            }
        }

        postUpdate(dt);
    }
}

class Brain {
    public var movementQueue = new Array<Int>();
    public var character: Character;

    public function init(character: Character): Void {
        this.character = character;
    }

    public function new() {}
    public function update(dt: Float): Void {}
    public function onGrid(dt: Float): Void {}
}

class PlayerBrain extends Brain {
    final keyMap = [40 => 0, 37 => 1, 39 => 2, 38 => 3];
    
    override public function update(dt: Float): Void {
        if (Key.isPressed(Key.Z)) trace(RPGHeap.current.gameboard);

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