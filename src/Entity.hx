import h2d.Object;
import h2d.Bitmap;
import h2d.Tile;

using Utilities.MathExtensions;

class Entity {
    public var sprite: Object;
    public var collider: Array<Bool> = [true, true, true, true];
    public static var entities = new Array<Entity>();

    public var bitmap: Bitmap;
    public var speed: Int = 50;
    public var brain: Brain;

    var anims = new Array<Array<Tile>>();
    var animPaused = false;
    var currentAnim(default, set): Int = 0;
    var currentFrame(default, set): Int = 0;

    public var gridX(default, set): Int = 0;
    public var gridY(default, set): Int = 0;
    public var targetX: Int = 0;
    public var targetY: Int = 0;
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

    public function set_gridX(x: Int) {
        gridX = x;
        targetX = x;
        return x;
    }

    public function set_gridY(y: Int) {
        gridY = y;
        targetY = y;
        return y;
    }

    public function get_x() {
        return gridX + remX;
    }

    public function set_x(x) {
        RPGHeap.gameboard[gameboardX][gameboardY].remove(this);
        RPGHeap.gameboard[gameboardX = Math.round(x)][gameboardY].push(this);
        gridX = Math.floor(x);
        remX = Math.floor((x - gridX) * 1000);
        return x;
    }

    public function get_y() {
        return gridY + remY / 1000;
    }

    public function set_y(y) {
        RPGHeap.gameboard[gameboardX][gameboardY].remove(this);
        RPGHeap.gameboard[gameboardX][gameboardY = Math.round(y)].push(this);
        gridY = Math.floor(y);
        remY = Math.floor((y - gridY) * 1000);
        return y;
    }
    
    public function get_pixelX() {
        return (gridX + remX / 1000) * RPGHeap.GRID_WIDTH;
    }

    public function set_pixelX(x: Float) {
        var temp: Float = x / RPGHeap.GRID_WIDTH;
        RPGHeap.gameboard[gameboardX][gameboardY].remove(this);
        RPGHeap.gameboard[gameboardX = Math.round(temp)][gameboardY].push(this);
        gridX = Math.floor(temp);
        remX = Math.floor((temp - gridX) * 1000);
        return x;
    }

    public function get_pixelY() {
        return (gridY + remY / 1000) * RPGHeap.GRID_HEIGHT;
    }

    public function set_pixelY(y: Float) {
        var temp: Float = y / RPGHeap.GRID_HEIGHT;
        RPGHeap.gameboard[gameboardX][gameboardY].remove(this);
        RPGHeap.gameboard[gameboardX][gameboardY = Math.round(temp)].push(this);
        gridY = Math.floor(temp);
        remY = Math.floor((temp - gridY) * 1000);
        return y;
    }

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

    // end region

    public function new(charChip: Tile, brain: Brain) {
        sprite = new Object(RPGHeap.get().s2d);
        RPGHeap.gameboard[gameboardX][gameboardY].push(this);

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
        bitmap.y = -27;

        this.brain = brain;
        brain.init(this);
        entities.push(this);
    }

    public function update(dt: Float) {
        brain.update(dt);

        if (remX % 1000 == 0 && remY % 1000 == 0) {
            brain.onGridBegin(dt);

            if (brain.moveDir != -1) {
                switch (brain.moveDir) {
                    case 0: deltaX = 0; deltaY = speed;
                    case 1: deltaX = -speed; deltaY = 0;
                    case 2: deltaX = speed; deltaY = 0;
                    case 3: deltaX = 0; deltaY = -speed;
                }
                
                animPaused = false;
                if (currentAnim != brain.moveDir) {
                    currentAnim = brain.moveDir;
                }
            } else {
                deltaX = 0;
                deltaY = 0;
                currentFrame = 0;
                animPaused = true;
            }

            if (brain.moveDir != -1) {
                targetX = gridX + Math.sign(deltaX);
                targetY = gridY + Math.sign(deltaY);
                
                if (RPGHeap.getCollider(gridX, gridY, brain.moveDir, true) || RPGHeap.getCollider(targetX, targetY, 3 - brain.moveDir)) {
                    deltaX = 0;
                    deltaY = 0;
                    currentFrame = 0;
                    animPaused = true;
                } else {
                    RPGHeap.gameboard[gameboardX][gameboardY].remove(this);
                    RPGHeap.gameboard[gameboardX = targetX][gameboardY = targetY].push(this);
                }
            } else {
                targetX = gridX;
                targetY = gridY;
            }
        }

        if (!animPaused && remX % Math.closestMultiple(500, speed) == 0 && remY % Math.closestMultiple(500, speed) == 0) {
            currentFrame++;
        }

        brain.onGridEnd(dt);

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

// I know "interactable" isn't a real word, no need to enlighten me on that
class Interactable extends Entity {
    public var script: Array<Array<Script.Token>>;
    public var parser = new Script.Parser();

    public function new(charchip: Tile, brain: Brain) {
        super(charchip, brain);
        var scanner = new Script.Scanner();
        script = scanner.tokenize("message \"Hello, World!\"\nmessage \"Bye, World!\"");
    }

    public function interact() {
        if (!parser.running) parser.parse(script);
    }
}