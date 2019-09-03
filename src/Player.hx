import h2d.Anim;
import h2d.Tile;
import hxd.Key;

class Player extends GameObject {
    var anim: Anim;
    var speed: Float = .05;

    var frames = new Array<Array<Tile>>();
    var keys = new Array<Int>();
    var keysPrev = new Array<Int>();
    final keyAnim = [40 => 0, 37 => 1, 39 => 2, 38 => 3];

    public function new(charChip: Tile) {
        super();

        var cw = charChip.width / 4;
        var ch = charChip.height / 4;
        for (y in 0...4) {
            frames.push(new Array<Tile>());
            for (x in 0...4) {
                frames[y].push(charChip.sub(cw * x, ch * y, cw, ch));
            }
        }
        
        anim = new Anim(frames[0], speed * 80, sprite);
        anim.pause = true;
        anim.y = -22;
    }

    override public function update(dt: Float) {
        // region key checks
        if (Key.isPressed(Key.DOWN) && keys.indexOf(Key.DOWN) == -1) keys.unshift(Key.DOWN);
        if (Key.isPressed(Key.LEFT) && keys.indexOf(Key.LEFT) == -1) keys.unshift(Key.LEFT);
        if (Key.isPressed(Key.RIGHT) && keys.indexOf(Key.RIGHT) == -1) keys.unshift(Key.RIGHT);
        if (Key.isPressed(Key.UP) && keys.indexOf(Key.UP) == -1) keys.unshift(Key.UP);
        if (Key.isReleased(Key.DOWN)) keys.remove(Key.DOWN);
        if (Key.isReleased(Key.LEFT)) keys.remove(Key.LEFT);
        if (Key.isReleased(Key.RIGHT)) keys.remove(Key.RIGHT);
        if (Key.isReleased(Key.UP)) keys.remove(Key.UP);
        // end region
        
        if (keys.toString() != keysPrev.toString() && (remX < 0.01 || remX > 0.99) && (remY < 0.01 || remY > 0.99)) {
            remX = Math.round(remX);
            if (remX == 1) {remX = 0; gridX++;}
            remY = Math.round(remY);
            if (remY == 1) {remY = 0; gridY++;}
            
            if (keys.length > 0) {
                switch (keys[0]) {
                    case 40: deltaX = 0; deltaY = speed;
                    case 37: deltaX = -speed; deltaY = 0;
                    case 39: deltaX = speed; deltaY = 0;
                    case 38: deltaX = 0; deltaY = -speed;
                }
                
                if (anim.pause) anim.currentFrame++;
                if (anim.frames != frames[keyAnim[keys[0]]]) {
                    anim.play(frames[keyAnim[keys[0]]], anim.currentFrame);
                } else {
                    anim.pause = false;
                }
            } else {
                deltaX = 0;
                deltaY = 0;
                anim.currentFrame = 0;
                anim.pause = true;
            }

            keysPrev = keys.copy();
        }

        postUpdate(dt);
    }
}