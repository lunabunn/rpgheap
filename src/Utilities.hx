class MathExtensions {
    /**
     * Returns the signum value of `x`.
     */
    public static function sign(cl: Class<Math>, x: Float): Int {
        if (x == 0) return 0;
        return cast (x / Math.abs(x));
    }

    /**
     * Clamps the value of `x` to be between `a` and `b`, inclusive, then returns it.
     */
    public static function clamp(cl: Class<Math>, x: Float, a: Float, b: Float): Float {
        if (x < a) return a;
        if (x > b) return b;
        return x;
    }

    /**
     * Returns the multiple of `factor` that is closest to `result` .
     */
    public static function closestMultiple(cl: Class<Math>, result: Float, factor: Float) {
        return factor * Math.round(result / factor);    
    }

    /**
     * Returns a pseudo-random number which is greater than or equal to `a`, and less than `b`.
     */
    public static function randomRange(cl: Class<Math>, a: Float, b: Float): Float {
        return a + (b - a) * Math.random();
    }

    /**
     * Returns a pseudo-random integer between `a` and `b`, inclusive.
     */
    public static function irandom(cl: Class<Math>, a: Int, b: Int): Int {
        return a + Math.floor((b - a + 1) * Math.random());
    }

    /**
     * Returns either `a` or `b`, pseudo-randomly.
     */
    public static function choose<T>(cl: Class<Math>, a: T, b: T): T {
        if (Math.floor(Math.random() * 2) == 0) return a;
        return b;
    }
}