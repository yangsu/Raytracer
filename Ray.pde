/**
 * A ray is simply an origin and a direction.
 */
public class Ray
{
  /**
   * This quantity represents a "small amount" to handle comparisons in
   * floating point computations. It is often useful to have one global value
   * across the ray tracer that stands for a "small amount".
   */
  public static final float EPSILON = 0.001;

  /** The starting point of the ray. */
  private final PVector myStartPoint;
  /** The normalized direction in which the ray travels. */
  private final PVector myDirectionVector;

  /**
   * Construct ray from data.
   */
  public Ray (PVector startPoint, PVector directionVector)
  {
    myStartPoint = startPoint.get();
    myDirectionVector = directionVector.get();
  }

  /**
   * Returns a copy of this ray.
   */
  public Ray get ()
  {
    return new Ray(getOrigin(), getDirection());
  }

  /**
   * Returns a copy of this ray whose origin is slightly offset.
   */
  public Ray getOffset ()
  {
    return new Ray(getOffsetOrigin(), getDirection());
  }

  /**
   * Returns point in space which corresponds to a distance t
   * units along the ray.
   */
  public PVector evaluate (float t)
  {
    return new PVector(myStartPoint.x + myDirectionVector.x * t,
                       myStartPoint.y + myDirectionVector.y * t,
                       myStartPoint.z + myDirectionVector.z * t);
  }

  /**
   * Returns the origin.
   */
  public PVector getOrigin ()
  {
    return myStartPoint.get();
  }

  /**
   * Returns the origin offset by a small amount.
   */
  public PVector getOffsetOrigin ()
  {
    return PVector.add(myStartPoint, PVector.mult(myDirectionVector, Ray.EPSILON));
  }

  /**
   * Returns the direction.
   */
  public PVector getDirection ()
  {
    return myDirectionVector.get();
  }

  /**
   * For debugging purposes.
   */
  public String toString ()
  {
    return "[" + myStartPoint + ", " + myDirectionVector + "]";
  }
}

