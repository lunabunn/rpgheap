import h2d.Object;
using Utilities.MathExtensions;

class Viewport extends Object {
    public function new(parent) {
        super(parent);
    }

    public function center(entity: Entity) {
        if (RPGHeap.map.pixelWidth > RPGHeap.WIDTH) {
            x = Math.clamp(RPGHeap.WIDTH / 2 - RPGHeap.player.pixelX - 16, RPGHeap.WIDTH - RPGHeap.map.pixelWidth, 0);
        } else if (RPGHeap.map.pixelWidth == RPGHeap.WIDTH) {
            x = 0;
        } else {
            x = (RPGHeap.WIDTH - RPGHeap.map.pixelWidth) / 2;
        }
        if (RPGHeap.map.pixelHeight > RPGHeap.HEIGHT) {
            y = Math.clamp(RPGHeap.HEIGHT / 2 - RPGHeap.player.pixelY - 16, RPGHeap.HEIGHT - RPGHeap.map.pixelHeight, 0);
        } else if (RPGHeap.map.pixelHeight == RPGHeap.HEIGHT) {
            y = 0;
        } else {
            y = (RPGHeap.HEIGHT - RPGHeap.map.pixelHeight) / 2;
        }
    }
}