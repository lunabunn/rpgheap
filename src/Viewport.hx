import h2d.Object;
using Utilities.MathExtensions;

class Viewport extends Object {
    public var container: Object;
    public var zoom(default, set) = 1.;

    function set_zoom(x: Float): Float {
        return scaleX = scaleY = zoom = x;
    }

    public function new(parent: Object) {
        super(parent);
        container = new Object(this);
    }

    public function center(entity: Entity) {
        if (RPGHeap.map.pixelWidth * zoom > RPGHeap.WIDTH) {
            x = Math.clamp(-((entity.pixelX + 16) * zoom - RPGHeap.WIDTH / 2), RPGHeap.WIDTH - RPGHeap.map.pixelWidth * zoom, 0);
        } else if (RPGHeap.map.pixelWidth * zoom == RPGHeap.WIDTH) {
            x = 0;
        } else {
            x = (RPGHeap.WIDTH - RPGHeap.map.pixelWidth * zoom) / 2;
        }
        if (RPGHeap.map.pixelHeight * zoom > RPGHeap.HEIGHT) {
            y = Math.clamp(-((entity.pixelY + 16) * zoom - RPGHeap.HEIGHT / 2), RPGHeap.HEIGHT - RPGHeap.map.pixelHeight * zoom, 0);
        } else if (RPGHeap.map.pixelHeight * zoom == RPGHeap.HEIGHT) {
            y = 0;
        } else {
            y = (RPGHeap.HEIGHT - RPGHeap.map.pixelHeight * zoom) / 2;
        }
    }
}