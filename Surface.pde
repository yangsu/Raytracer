/**
 * Abstract base class for all surfaces.
 */
public abstract class Surface
{
  // These are read in from input file and do not change during rendering
  /** Shader to be used to shade this surface. */
  protected Shader myShader;


  /**
   * Construct surface from data.
   */
  public Surface (Shader material)
  {
    myShader = material;
  }


  /**
   * Returns t closest value for which ray intersects this surface, or
   * -Integer.MAX_VALUE if no intersection occurs.
   */
  public abstract float intersects (Ray ray);


  /**
   * Returns the normal vector to this surface at given point
   */
  public abstract PVector getNormal (PVector surfacePoint);


  /**
   * Returns this surface's color at the intersection described in data.
   * Note, includes global Ambient light since that hits all surfaces equally.
   */
  public PVector getColor (IntersectionData data, Scene scene)
  {
    PVector resultColor = myShader.shade(data, scene);
    myShader.updateColor(resultColor, AMBIENT_LIGHT_COLOR, AMBIENT_LIGHT);
    return resultColor;
  }
}


/**
 * Represents a sphere as a center and a radius.
 */
public class Sphere extends Surface
{
  // These are read in from input file and do not change during rendering
  /** The center of the sphere. */
  protected PVector myCenter;
  /** The radius of the sphere. */
  protected float myRadius;


  /**
   * Construct surface from data.
   */
  public Sphere (PVector center,
                 float radius,
                 Shader material)
  {
    super(material);
    myCenter = center;
    myRadius = radius;
  }


  /**
   * @see Surface#intersects()
   */
  public float intersects (Ray ray)
  {
    // TODO: Complete this function
    PVector d = ray.getDirection();
    PVector e = ray.getOrigin();
    float dd = d.dot(d);
    PVector ec = PVector.sub(e, myCenter);
    float dec = d.dot(ec);
    float det = sq(dec)-dd*(ec.dot(ec)-sq(myRadius));
    if (det > 0) {
      float sqrtdet = sqrt(det);
      // inters[0] = PVector.add(e, PVector.mult(d, (-dec-sqrtdet)/dd));
      // norms[0] = PVector.div(PVector.mult(inters[0], myCenter), myRadius);
      // inters[1] = PVector.add(e, PVector.mult(d, (-dec+sqrtdet)/dd));
      // norms[1] = PVector.div(PVector.mult(inters[1], myCenter), myRadius);
      return (-dec-sqrtdet)/dd;
    }
    else if (det == 0) {
      // inters[0] = PVector.add(e, PVector.mult(d, -dec/dd));
      // norms[0] = PVector.div(PVector.mult(inters[0], myCenter), myRadius);
      return -dec/dd;
    }
    else
      return -Integer.MAX_VALUE;
  }


  /**
   * @see Surface#getNormal()
   */
  public PVector getNormal (PVector surfacePoint)
  {
    // TODO: Complete this function
    PVector result = new PVector();
    result.normalize();
    return result;
  }


  /**
   * For debugging purposes.
   */
  public String toString ()
  {
    return "Sphere Surface = " +
           "\n    " + myShader +
           "\n    Center = " + myCenter +
           "\n    Radius = " + myRadius;
  }
}


public class Box extends Surface
{
  // These are read in from input file and do not change during rendering
  /* The corner of the box with the smallest x, y, and z components. */
  private final PVector myMinPoint;
  /* The corner of the box with the largest x, y, and z components. */
  private final PVector myMaxPoint;


  /**
   * Construct surface from data.
   */
  public Box (PVector minPoint,
              PVector maxPoint,
              Shader material)
  {
    super(material);
    myMinPoint = minPoint;
    myMaxPoint = maxPoint;
  }


  /**
   * @see Surface#intersects()
   */
  public float intersects (Ray ray)
  {
    // TODO: Complete this function
    return -Integer.MAX_VALUE;
  }


  /**
   * @see Surface#getNormal()
   */
  public PVector getNormal (PVector surfacePoint)
  {
    // TODO: Complete this function
    PVector result = new PVector();
    result.normalize();
    return result;
  }


  /**
   * For debugging purposes.
   */
  public String toString ()
  {
    return "Box Surface = " +
           "\n    " + myShader +
           "\n    Min Point = " + myMinPoint +
           "\n    Max Point = " + myMaxPoint;
  }
}

