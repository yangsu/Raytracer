/**
 * Abstract base class for all material properties.
 */
public abstract class Shader
{
  // These are read in from input file and do not change during rendering
  /** The color of the surface. */
  protected final PVector myDiffuseColor;

  /**
   * Construct shader from data.
   */
  public Shader (PVector diffuse)
  {
    myDiffuseColor = diffuse;
  }

  /**
   * Returns color for this material at the intersection described in data.
   * Scene is passed in to allow access to other lights and surfaces that might
   * be useful in computing color value (i.e., for shadows and reflections).
   */
  public abstract PVector shade (IntersectionData data, Scene scene);

  /**
   * Updates given color by adding given factor of the color to add.
   * Does not allocate new color for efficiency.
   */
  public void updateColor (PVector colorToUpdate, PVector colorToAdd, float scaleFactor)
  {
    colorToUpdate.add(PVector.mult(colorToAdd, scaleFactor));
  }

  /**
   * Calculate whether there's shadow or not
   */
  public boolean isShadow (IntersectionData data, Scene scene, Light lg) {
    PVector l = PVector.sub(lg.getPosition(), data.hitPoint);
    l.normalize();
    Ray sRay = new Ray(data.hitPoint, l).getOffset();
    return scene.isAnyIntersection(sRay);
  }
}

/**
 * A Lambertian material scatters light equally in all directions.
 */
public class Lambertian extends Shader
{
  /**
   * Construct shader from data.
   */
  public Lambertian (PVector diffuseColor)
  {
    super(diffuseColor);
  }

  /**
   * @see Shader#shade()
   */
  public PVector shade (IntersectionData data, Scene scene)
  {
    // TODO: Complete this function
    PVector resultColor = new PVector(0, 0, 0);
    PVector kd = myDiffuseColor.get();
    for (Light light : scene.getLights()) {
      if (!isShadow(data, scene, light)) {
        PVector l = PVector.sub(light.getPosition(), data.hitPoint);
        l.normalize();
        PVector lcolor = light.getColor();
        PVector n = data.normalVector;
        n.normalize();
        float factor = max(0, l.dot(n));
        resultColor = PVector.add(resultColor,
                        PVector.mult(dotmult(kd, lcolor), factor));
      }
    }

    return resultColor;
  }

  /**
   * For debugging purposes.
   */
  public String toString ()
  {
    return "Lambertian Shader = " +
           "\n      Diffuse Color = " + myDiffuseColor;
  }
}

/**
 * A Phong material uses the Modified Blinn-Phong model which is energy
 * preserving and reciprocal.
 */
public class Phong extends Shader
{
  // These are read in from input file and do not change during rendering
  /** The color of the specular reflection. */
  protected final PVector mySpecularColor;
  /** The exponent controlling the sharpness of the specular reflection. */
  protected final float myExponent;

  /**
   * Construct shader from data.
   */
  public Phong (PVector diffuseColor,
                PVector specularColor,
                float exponent)
  {
    super(diffuseColor);
    mySpecularColor = specularColor;
    myExponent = exponent;
  }

  /**
   * @see Shader#shade()
   */
  public PVector shade (IntersectionData data, Scene scene)
  {
    // TODO: Complete this function
    PVector resultColor = new PVector(0, 0, 0);
    PVector kd = myDiffuseColor.get();
    PVector ks = mySpecularColor.get();
    for (Light light : scene.getLights()) {
      if (!isShadow(data, scene, light)) {
        PVector l = PVector.sub(light.getPosition(), data.hitPoint);
        l.normalize();
        PVector h = PVector.add(PVector.mult(data.cameraRay.getDirection(), -1), l);
        h.normalize();
        PVector lcolor = light.getColor();
        float nlfactor = max(0, data.normalVector.dot(l));
        float nhfactor = pow(max(0, data.normalVector.dot(h)), myExponent);
        resultColor = PVector.add(resultColor, dotmult(
                        PVector.add(PVector.mult(ks, nhfactor),
                                  PVector.mult(kd, nlfactor)), lcolor));
      }
    }

    return resultColor;
  }

  /**
   * For debugging purposes.
   */
  public String toString ()
  {
    return "Phong Shader = " +
           "\n      Diffuse Color = " + myDiffuseColor +
           "\n      Specular Color = " + myDiffuseColor +
           "\n      exponent = " + myExponent;
  }
}


/**
 * A Glazed material addes a layer of reflection on top of the Lambertian
 * model.
 */
public class Glazed extends Lambertian
{
  private float myReflectivity;
  /**
   * Construct shader from data.
   */
  public Glazed (PVector diffuseColor, float reflectivity)
  {
    super(diffuseColor);
    myReflectivity = reflectivity;
  }

  /**
   * @see Shader#shade()
   */
  public PVector shade (IntersectionData data, Scene scene)
  {
    // TODO: Add in resursion limits!
    PVector d = data.cameraRay.getDirection();
    PVector n = data.normalVector;
    PVector r = PVector.sub(d, PVector.mult(n, PVector.dot(d, n) * 2));
    r.normalize();
    Ray rRay = new Ray(data.hitPoint, r).getOffset();
    PVector resultColor = dotmult(scene.rayColor(rRay),
                            PVector.mult(myDiffuseColor, myReflectivity));
    return PVector.add(resultColor, super.shade(data, scene));
  }

  /**
   * For debugging purposes.
   */
  public String toString ()
  {
    return "Glazed Shader = " +
           "\n      Diffuse Color = " + myDiffuseColor +
           "\n      Reflectivity = " + myReflectivity;
  }
}

/**
 * A Reflective material addes a layer of reflection on top of the Phong
 * model.
 */
public class Reflective extends Phong
{
  protected float myReflectivity;
  /**
   * Construct shader from data.
   */
  public Reflective (PVector diffuseColor,
                     PVector specularColor,
                     float exponent,
                     float reflectivity)
  {
    super(diffuseColor, specularColor, exponent);
    myReflectivity = reflectivity;
  }

  /**
   * @see Shader#shade()
   */
  public PVector shade (IntersectionData data, Scene scene)
  {
    // TODO: Add in resursion limits!
    PVector d = data.cameraRay.getDirection();
    PVector n = data.normalVector;
    PVector r = PVector.sub(d, PVector.mult(n, PVector.dot(d, n) * 2));
    r.normalize();
    Ray rRay = new Ray(data.hitPoint, r).getOffset();
    PVector resultColor = dotmult(scene.rayColor(rRay),
                            PVector.mult(mySpecularColor, myReflectivity));
    return PVector.add(resultColor, super.shade(data, scene));
    // return resultColor;
  }

  /**
   * For debugging purposes.
   */
  public String toString ()
  {
    return "Reflective Shader = " +
           "\n      Diffuse Color = " + myDiffuseColor +
           "\n      Specular Color = " + myDiffuseColor +
           "\n      exponent = " + myExponent +
           "\n      Reflectivity = " + myReflectivity;
  }
}


/**
 * A Refractive material addes a layer of reflection on top of the Reflective
 * model.
 */
public class Refractive extends Reflective
{
  private float myIOR;

  public Refractive (PVector diffuseColor,
                     PVector specularColor,
                     float exponent,
                     float reflectivity,
                     float ior)
  {
    super(diffuseColor, specularColor, exponent, 0);
    myIOR = ior;
    PVector a = refract(1, 1.0, new PVector(0, 1, 0),
                      new PVector(-1, 1, 0)
                        );
    println("-----------------------------------");
    println(a);
    println("-----------------------------------");
  }

  private PVector refract(float n1, float n2, PVector n, PVector s1) {
    float c1 = -n.dot(s1);
    float nn = n1 / n2;
    float c2 = sqrt(1-sq(nn)*(1 - sq(c1)));
    PVector s2 = PVector.add(PVector.mult(s1, nn), PVector.mult(n, nn*c1-c2));
    s2.normalize();
    return s2;
  }
  /**
   * @see Shader#shade()
   */
  public PVector shade (IntersectionData data, Scene scene)
  {
    // TODO: Add in resursion limits!
    PVector s2 = refract(GLOBAL_IOR, myIOR, data.normalVector,
                         data.cameraRay.getDirection());
    Ray inRay = new Ray(data.hitPoint, s2).getOffset();
    IntersectionData data2 = scene.getClosestIntersection(inRay);
    PVector resultColor = new PVector(0, 0, 0);
    if (data2 != null)
    {
      s2 = refract(GLOBAL_IOR, myIOR, data2.normalVector,
                   data2.cameraRay.getDirection());
      Ray outRay = new Ray(data.hitPoint, s2).getOffset();
      IntersectionData data3 = scene.getClosestIntersection(outRay);
      if (data3 != null)
      {
         resultColor = scene.rayColor(data3);
      }
      else
      {
      // resultColor = scene.rayColor(data2);

      }
      // resultColor = scene.rayColor(outRay);
    }
    else {
      // println("surfaces is not closed");
      // resultColor = scene.rayColor(data2);
    }
    // return resultColor;
    return PVector.add(resultColor, PVector.mult(super.shade(data, scene),0.5));
  }
  /**
   * For debugging purposes.
   */
  public String toString ()
  {
    return "Reflective Shader = " +
           "\n      Diffuse Color = " + myDiffuseColor +
           "\n      Specular Color = " + myDiffuseColor +
           "\n      exponent = " + myExponent +
           "\n      Reflectivity = " + myReflectivity;
  }
}