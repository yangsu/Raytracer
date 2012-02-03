/**
 * Abstract base class for all material properties.
 */
public abstract class Shader
{
  // These are read in from input file and do not change during rendering
  /** The color of the surface. */
  protected final PVector myDiffuseColor;

  protected float myAlpha;
  /**
   * Construct shader from data.
   */
  public Shader (PVector diffuse, float alpha)
  {
    myDiffuseColor = diffuse;
    myAlpha = alpha;
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
  public boolean isShadow (IntersectionData data, Scene scene, Light l) {
    return scene.isAnyIntersection(l.getRayToLight(data.hitPoint));
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
  public Lambertian (PVector diffuseColor, float alpha)
  {
    super(diffuseColor, alpha);
  }

  /**
   * @see Shader#shade()
   */
  public PVector shade (IntersectionData data, Scene scene)
  {
    PVector resultColor = BACKGROUND_COLOR_VECTOR;
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
                float exponent,
                float alpha)
  {
    super(diffuseColor, alpha);
    mySpecularColor = specularColor;
    myExponent = exponent;
  }

  protected PVector phong (IntersectionData data, Scene scene)
  {
    PVector resultColor = BACKGROUND_COLOR_VECTOR;
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
   * @see Shader#shade()
   */
  public PVector shade (IntersectionData data, Scene scene)
  {
    return phong(data, scene);
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
  public Glazed (PVector diffuseColor, float reflectivity, float alpha)
  {
    super(diffuseColor, alpha);
    myReflectivity = reflectivity;
  }

  /**
   * @see Shader#shade()
   */
  public PVector shade (IntersectionData data, Scene scene)
  {
    PVector d = data.cameraRay.getDirection();
    PVector n = data.normalVector;
    PVector r = PVector.sub(d, PVector.mult(n, PVector.dot(d, n) * 2));
    r.normalize();
    Ray rRay = new Ray(data.hitPoint, r).getOffset();
    PVector resultColor = PVector.mult(scene.rayColor(rRay, data.depth),
                                       myReflectivity*pow(0.5, data.depth));
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
                     float reflectivity,
                     float alpha)
  {
    super(diffuseColor, specularColor, exponent, alpha);
    myReflectivity = reflectivity;
  }

  protected PVector reflect (IntersectionData data, Scene scene)
  {
    if (myReflectivity > 0) {
      PVector d = data.cameraRay.getDirection();
      PVector n = data.normalVector;
      PVector r = PVector.sub(d, PVector.mult(n, PVector.dot(d, n)*2));
      r.normalize();
      Ray rRay = new Ray(data.hitPoint, r).getOffset();

      return dotmult(scene.rayColor(rRay, data.depth),
                     PVector.mult(mySpecularColor,
                                  myReflectivity*pow(0.5,data.depth)));
    }
    return BACKGROUND_COLOR_VECTOR;
  }
  /**
   * @see Shader#shade()
   */
  public PVector shade (IntersectionData data, Scene scene)
  {
    PVector resultColor = phong(data, scene);
    return PVector.add(resultColor, reflect(data, scene));
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
                     float ior,
                     float alpha)
  {
    super(diffuseColor, specularColor, exponent, reflectivity, alpha);
    myIOR = ior;
  }

  private PVector refractRay(float n1, float n2, PVector n, PVector s1) {
    float c1 = -n.dot(s1);
    float nn = n1 / n2;
    float c2 = sqrt(1-sq(nn)*(1 - sq(c1)));
    PVector s2 = PVector.add(PVector.mult(s1, nn), PVector.mult(n, nn*c1-c2));
    s2.normalize();
    return s2;
  }

  private PVector refract (IntersectionData data, Scene scene) {
    PVector resultColor = BACKGROUND_COLOR_VECTOR;
    if (myAlpha < 1.0){
      if (debug) println("in:refracting ray "+data.cameraRay.getDirection());
      PVector s2 = refractRay(GLOBAL_IOR, myIOR, data.normalVector,
                           data.cameraRay.getDirection());
      if (debug) println("refracted ray " + s2);
      Ray inRay = new Ray(data.hitPoint, s2).getOffset();
      IntersectionData data2 = scene.getClosestIntersection(inRay, data.depth);
      if (data2 != null &&
          data.surface == data2.surface)
      {
        if (debug) println("out:refracting ray "+s2);
        s2 = refractRay(myIOR, GLOBAL_IOR, PVector.mult(data2.normalVector, -1),
                     s2);
        if (debug) println("refracted ray " +s2);
        Ray outRay = new Ray(data2.hitPoint, s2).getOffset();
        resultColor = scene.rayColor(outRay, data.depth);
      }
    }
    return resultColor;
  }
  /**
   * @see Shader#shade()
   */
  public PVector shade (IntersectionData data, Scene scene)
  {
    PVector resultColor =
      PVector.add(PVector.mult(refract(data, scene), 1-myAlpha),
                  PVector.mult(phong(data, scene), myAlpha));

    return PVector.add(resultColor, reflect(data, scene));
  }
  /**
   * For debugging purposes.
   */
  public String toString ()
  {
    return "Refractive Shader = " +
           "\n      Diffuse Color = " + myDiffuseColor +
           "\n      Specular Color = " + myDiffuseColor +
           "\n      exponent = " + myExponent +
           "\n      Reflectivity = " + myReflectivity;
  }
}