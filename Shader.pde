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
    PVector resultColor = myDiffuseColor.get();
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
    PVector resultColor = mySpecularColor.get();
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

