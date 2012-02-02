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
      PVector l = PVector.sub(light.getPosition(), data.hitPoint);
      l.normalize();
      PVector lcolor = light.getColor();
      PVector n = data.normalVector;
      n.normalize();
      float factor = max(0, l.dot(n));
      resultColor = PVector.add(resultColor,
                      PVector.mult(dotmult(kd, lcolor), factor));
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
  private final PVector mySpecularColor;
  /** The exponent controlling the sharpness of the specular reflection. */
  private final float myExponent;


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
public class Glazed extends Shader
{
  /**
   * Construct shader from data.
   */
  public Glazed (PVector diffuseColor)
  {
    super(diffuseColor);
  }

  /**
   * @see Shader#shade()
   */
  public PVector shade (IntersectionData data, Scene scene)
  {
    // TODO: Complete this function
    PVector d = data.cameraRay.getDirection();
    PVector n = data.normalVector;
    PVector r = PVector.sub(d, PVector.mult(n, PVector.dot(d, n) * 2));
    r.normalize();
    Ray rRay = new Ray(data.hitPoint, r).getOffset();
    PVector resultColor = dotmult(scene.rayColor(rRay), myDiffuseColor);

    PVector kd = myDiffuseColor.get();
    for (Light light : scene.getLights()) {
      PVector l = PVector.sub(light.getPosition(), data.hitPoint);
      l.normalize();
      PVector lcolor = light.getColor();
      n = data.normalVector;
      float factor = max(0, l.dot(n));
      resultColor = PVector.add(resultColor,
                      PVector.mult(dotmult(kd, lcolor), factor));
    }

    return resultColor;
  }


  /**
   * For debugging purposes.
   */
  public String toString ()
  {
    return "Glazed Shader = " +
           "\n      Diffuse Color = " + myDiffuseColor;
  }
}