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
    if (det > 0)
      return (-dec-sqrt(det))/dd;
    else if (det == 0)
      return -dec/dd;
    else
      return -Integer.MAX_VALUE;
  }


  /**
   * @see Surface#getNormal()
   */
  public PVector getNormal (PVector surfacePoint)
  {
    // TODO: Complete this function
    PVector result = new PVector(surfacePoint.x - myCenter.x,
                                 surfacePoint.y - myCenter.y,
                                 surfacePoint.z - myCenter.z);
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

  private final PVector myA,myB,myC,myD,myE,myF,myG,myH;
  private final PVector myX,myY,myZ;
  private PVector myN;
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
    PVector diff = PVector.sub(myMaxPoint, myMinPoint);
    myX = new PVector(diff.x, 0, 0);
    myY = new PVector(0, diff.y, 0);
    myZ = new PVector(0, 0, diff.z);
    myA = PVector.add(myMinPoint, myZ);
    myB = PVector.sub(myMaxPoint, myX);
    myC = myMaxPoint;
    myD = PVector.sub(myMaxPoint, myY);
    myE = myMinPoint;
    myF = PVector.add(myMinPoint, myY);
    myG = PVector.sub(myMaxPoint, myZ);
    myH = PVector.add(myMinPoint, myX);
  }

  private PVector triangleNormal(PVector a, PVector b, PVector c) {
    PVector n = PVector.sub(b, a).cross(PVector.sub(c, a));
    n.normalize();
    return n;
  }
  private boolean triangleIntersect(Ray r, PVector a, PVector b, PVector c, PVector tval) {
    PVector e = r.getOrigin();
    PVector d = r.getDirection();
    PVector n = PVector.sub(b, a).cross(PVector.sub(c, a));
    n.normalize();
    float t = PVector.sub(a, e).dot(n)/d.dot(n);
    tval.set(t, 0, 0);
    PVector inter = r.evaluate(t);
    return (PVector.sub(b, a).cross(PVector.sub(inter, a)).dot(n) > 0 &&
            PVector.sub(c, b).cross(PVector.sub(inter, b)).dot(n) > 0 &&
            PVector.sub(a, c).cross(PVector.sub(inter, c)).dot(n) > 0);
  }
  /**
   * a, b, c, d are coplanar points on a rectangle in order of bottom left(a),
   * top left(b), top right(c), bottom right(d)
   */
  private boolean rectIntersect(Ray r, PVector a, PVector b, PVector c, PVector d, PVector tval) {
    PVector n = rectNormal(a, b, c, d);
    float t = PVector.sub(a, r.getOrigin()).dot(n)/r.getDirection().dot(n);
    tval.set(t, 0, 0);
    PVector inter = r.evaluate(t);

    return (PVector.sub(d, a).cross(PVector.sub(inter, a)).dot(n) > 0 &&
        PVector.sub(a, b).cross(PVector.sub(inter, b)).dot(n) > 0 &&
        PVector.sub(b, c).cross(PVector.sub(inter, c)).dot(n) > 0 &&
        PVector.sub(c, d).cross(PVector.sub(inter, d)).dot(n) > 0 &&
        r.getDirection().dot(n) <= 0);
  }
  private PVector rectNormal(PVector a, PVector b, PVector c, PVector d) {
    PVector n = PVector.sub(c, a).cross(PVector.sub(b, d));
    n.normalize();
    return n;
  }
  /**
   * @see Surface#intersects()
   */
  public float intersects (Ray ray)
  {
    PVector t = new PVector(0, 0, 0);

    if (rectIntersect(ray, myA, myB, myC, myD, t) ||
        rectIntersect(ray, myH, myG, myF, myE, t) ||
        rectIntersect(ray, myE, myF, myB, myA, t) ||
        rectIntersect(ray, myD, myC, myG, myH, t) ||
        rectIntersect(ray, myB, myF, myG, myC, t) ||
        rectIntersect(ray, myE, myA, myD, myH, t))
      return t.x;
    else
      return -Integer.MAX_VALUE;
  }
  /**
   * @see Surface#getNormal()
   */
  public PVector getNormal (PVector surfacePoint)
  {
    if (abs(surfacePoint.x - myMinPoint.x) < 0.001)
      return new PVector(-1, 0, 0);
    else if (abs(surfacePoint.x - myMaxPoint.x) < 0.001)
      return new PVector(1, 0, 0);
    else if (abs(surfacePoint.y - myMinPoint.y) < 0.001)
      return new PVector(0, -1, 0);
    else if (abs(surfacePoint.y - myMaxPoint.y) < 0.001)
      return new PVector(0, 1, 0);
    else if (abs(surfacePoint.z - myMinPoint.z) < 0.001)
      return new PVector(0, 0, -1);
    else if (abs(surfacePoint.z - myMaxPoint.z) < 0.001)
      return new PVector(0, 0, 1);
    else
    {
      println("error!");
      return new PVector(0, 0, 0);
    }
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

