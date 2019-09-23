import h2d.Object;
using Utilities.MathExtensions;

class Viewport extends Object {
    public function new(parent) {
        super(parent);
    }

    public function center(entity: Entity) {
        // TODO: Refactor this trash
        if (RPGHeap.map.width * RPGHeap.GRID_WIDTH > RPGHeap.WIDTH) {
            x = Math.clamp(RPGHeap.WIDTH / 2 - RPGHeap.player.pixelX - 16, RPGHeap.WIDTH - RPGHeap.map.width * RPGHeap.GRID_WIDTH, 0);
        } else if (RPGHeap.map.width * RPGHeap.GRID_WIDTH == RPGHeap.WIDTH) {
            x = 0;
        } else {
            x = (RPGHeap.WIDTH - RPGHeap.map.width * RPGHeap.GRID_WIDTH) / 2;
        }
        if (RPGHeap.map.height * RPGHeap.GRID_HEIGHT > RPGHeap.HEIGHT) {
            y = Math.clamp(RPGHeap.HEIGHT / 2 - RPGHeap.player.pixelY - 16, RPGHeap.HEIGHT - RPGHeap.map.height * RPGHeap.GRID_HEIGHT, 0);
        } else if (RPGHeap.map.height * RPGHeap.GRID_HEIGHT == RPGHeap.HEIGHT) {
            y = 0;
        } else {
            y = (RPGHeap.HEIGHT - RPGHeap.map.height * RPGHeap.GRID_HEIGHT) / 2;
        }
    }
}