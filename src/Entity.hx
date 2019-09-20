import h2d.Object;
import h2d.Bitmap;
import h2d.Tile;

using Utilities.MathExtensions;

class Entity {
    public var sprite: Object;
    public var collider: Array<Bool> = [true, true, true, true];
    public static var entities = new Array<Entity>();

    public var bitmap: Bitmap;
    public var speed: Float = 2;
    public var brain: Brain;

    var anims = new Array<Array<Tile>>();
    var animPaused = false;
    var currentAnim(default, set): Int = 0;
    var currentFrame(default, set): Int = 0;

    public var gridX(default, set): Int = 0;
    public var gridY(default, set): Int = 0;
    public var targetX: Int = 0;
    public var targetY: Int = 0;
    public var remX: Float = 0;
    public var remY: Float = 0;
    public var deltaX: Float = 0;
    public var deltaY: Float = 0;

    public var x(get, set): Float;
    public var y(get, set): Float;
    public var pixelX(get, set): Float;
    public var pixelY(get, set): Float;

    public var gameboardX: Int = 0;
    public var gameboardY: Int = 0;

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
        remX = Math.floor((x - gridX) * RPGHeap.GRID_WIDTH);
        return x;
    }

    public function get_y() {
        return gridY + remY / RPGHeap.GRID_HEIGHT;
    }

    public function set_y(y) {
        RPGHeap.gameboard[gameboardX][gameboardY].remove(this);
        RPGHeap.gameboard[gameboardX][gameboardY = Math.round(y)].push(this);
        gridY = Math.floor(y);
        remY = Math.floor((y - gridY) * RPGHeap.GRID_HEIGHT);
        return y;
    }
    
    public function get_pixelX() {
        return gridX * RPGHeap.GRID_WIDTH + remX;
    }

    public function set_pixelX(x: Float) {
        var temp: Float = x / RPGHeap.GRID_WIDTH;
        RPGHeap.gameboard[gameboardX][gameboardY].remove(this);
        RPGHeap.gameboard[gameboardX = Math.round(temp)][gameboardY].push(this);
        gridX = Math.floor(temp);
        remX = Math.floor(x - gridX * RPGHeap.GRID_WIDTH);
        return x;
    }

    public function get_pixelY() {
        return gridY * RPGHeap.GRID_HEIGHT + remY;
    }

    public function set_pixelY(y: Float) {
        var temp: Float = y / RPGHeap.GRID_HEIGHT;
        RPGHeap.gameboard[gameboardX][gameboardY].remove(this);
        RPGHeap.gameboard[gameboardX][gameboardY = Math.round(temp)].push(this);
        gridY = Math.floor(temp);
        remY = Math.floor(y - gridY * RPGHeap.GRID_HEIGHT);
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

        if ((remX < speed || RPGHeap.GRID_WIDTH - remX < speed)
            && (remY < speed || RPGHeap.GRID_HEIGHT - remY < speed)) {
            brain.onGridBegin(dt);
            
            if (brain.moveDir != -1) {
                if (remX < speed) remX = 0;
                if (remY < speed) remY = 0;
                if (RPGHeap.GRID_WIDTH - remX < speed) {
                    gridX++;
                    remX = 0;
                }
                if (RPGHeap.GRID_HEIGHT - remY < speed) {
                    gridY++;
                    remY = 0;
                }

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
                if (RPGHeap.GRID_WIDTH - remX < speed) {
                    gridX++;
                }
                if (RPGHeap.GRID_HEIGHT - remY < speed) {
                    gridY++;
                }
                remX = 0;
                remY = 0;
                currentFrame = 0;
                animPaused = true;
            }

            if (brain.moveDir != -1) {
                targetX = gridX + ((RPGHeap.GRID_WIDTH - remX < speed)? 1:0) + Math.sign(deltaX);
                targetY = gridY + ((RPGHeap.GRID_HEIGHT - remY < speed)? 1:0) + Math.sign(deltaY);
                
                if (RPGHeap.getCollider(gridX, gridY, brain.moveDir, true) || RPGHeap.getCollider(targetX, targetY, 3 - brain.moveDir, this)) {
                    deltaX = 0;
                    deltaY = 0;
                    if (RPGHeap.GRID_WIDTH - remX < speed) {
                        gridX++;
                    }
                    if (RPGHeap.GRID_HEIGHT - remY < speed) {
                        gridY++;
                    }
                    remX = 0;
                    remY = 0;
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

        if (!animPaused && remX % (RPGHeap.GRID_WIDTH / 2) < speed && remY % (RPGHeap.GRID_HEIGHT / 2) < speed) {
            currentFrame++;
        }

        brain.onGridEnd(dt);

        remX += deltaX;
        while (remX >= RPGHeap.GRID_WIDTH) {remX -= RPGHeap.GRID_WIDTH; gridX++;}
        while (remX < 0) {remX += RPGHeap.GRID_WIDTH; gridX--;}
        remY += deltaY;
        while (remY >= RPGHeap.GRID_HEIGHT) {remY -= RPGHeap.GRID_HEIGHT; gridY++;}
        while (remY < 0) {remY += RPGHeap.GRID_HEIGHT; gridY--;}

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