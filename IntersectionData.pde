/**
 * This class is just a simple data object,
 * holding information about a particular intersection.
 */
public class IntersectionData
{
  /** The location where the intersection occurred. */
  public final Ray cameraRay;
  /** The location where the intersection occurred. */
  public final PVector hitPoint;
  /** The normal of the surface at the intersection location. */
  public final PVector normalVector;
  /** A reference to the actual surface. */
  public Surface surface;
  /** The t value along the ray at which the intersection occurred. */
  public float t;


  /**
   * Construct intersection data from pieces.
   */
  public IntersectionData (Ray cameraRay,
                           PVector hitPoint,
                           PVector normalVector,
                           Surface surface,
                           float t)
  {
    this.cameraRay = cameraRay;
    this.hitPoint = hitPoint;
    this.normalVector = normalVector;
    this.surface = surface;
    this.t = t;
  }


  /**
   * For debugging purposes.
   */
  public String toString ()
  {
    return "Intersection Data = " +
           "\n  " + surface +
           "\n  t = " + t +
           "\n  Hit Point = " + hitPoint +
           "\n  Normal Vector = " + normalVector;
  }
}

