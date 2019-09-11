class MathExtensions {
    public static function sign(cl: Class<Math>, x: Float): Int {
        if (x == 0) return 0;
        return cast (x / Math.abs(x));
    }

    public static function closestMultiple(cl: Class<Math>, result: Float, factor: Float) {
        return factor * Math.round(result / factor);    
    }
}