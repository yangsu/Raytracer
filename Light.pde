/**
 * Represents a basic point light source.
 *
 * It is infinitely small and emits at constant power in all directions.
 * This is a useful idealization of a small light emitter.
 */
public class Light
{
  // These are read in from input file and do not change during rendering
  /** Where the light is located in space. */
  private final PVector myPosition;
  /** Color of the light. */
  private final PVector myColor;


  /**
   * Construct camera from data.
   */
  public Light (PVector position,
                PVector colr)
  {
    myPosition = position;
    myColor = colr;
  }


  /**
   * Returns light's position in space.
   */
  public PVector getPosition ()
  {
    return myPosition.get();
  }


  /**
   * Returns light's color triple.
   */
  public PVector getColor ()
  {
    return myColor.get();
  }


  /**
   * Create a ray from intersection point to the light,
   *  - with a normalized direction for dotting later
   *  - and a slightly offect origin so no inadverant intersections
   */
  public Ray getRayToLight (PVector startPoint)
  {
    PVector directionVector = PVector.sub(getPosition(), startPoint);
    directionVector.normalize();
    return new Ray(startPoint, directionVector).getOffset();
  }


  /**
   * For debugging purposes.
   */
  public String toString ()
  {
    return "Light = " +
           "\n File Data" +
           "\n  Position = " + myPosition +
           "\n  Color = " + myColor;
  }
}

