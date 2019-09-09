class MathExtensions {
  public static function sign(cl: Class<Math>, x: Float): Int {
    if (x == 0) return 0;
    return cast (x / Math.abs(x));
  }
}