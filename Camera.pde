/**
 * Represents a simple camera.
 */
public class Camera
{
  // These are read in from input file and do not change during rendering
  /** Position of the camera */
  private final PVector myViewPoint;
  /** Direction camera is facing */
  private final PVector myViewDirection;
  /** Up direction of the camera */
  private final PVector myViewUp;
  /** Normal of the projection plane */
  private final PVector myPlaneNormal;
  /** Width, Height, and Distance of the projection plane */
  private final PVector myPlaneSize;
  // computed values of the axes of the camera's view
  private PVector myXaxis;
  private PVector myYaxis;
  private PVector myZaxis;

  /**
   * Construct camera from data.
   */
  public Camera (PVector viewPoint,
                 PVector viewDirection,
                 PVector viewUp,
                 PVector planeNormal,
                 PVector planeSize)
  {
    myViewPoint = viewPoint;
    myViewDirection = viewDirection;
    myViewUp = viewUp;
    myPlaneNormal = planeNormal;
    myPlaneSize = planeSize;
    // all camera vectors should be normalized
    myViewDirection.normalize();
    myViewUp.normalize();
    myPlaneNormal.normalize();
    init();
  }

  /**
   * Returns ray that starts at camera and travels through given pixel,
   * the pixel is expressed as a percentage of its distance along the
   * total width or height of the view plane.
   */
  public Ray getRay (float xRatio, float yRatio)
  {
    PVector result = PVector.mult(myZaxis, -myPlaneSize.z);
    float u = -myPlaneSize.x/2 + myPlaneSize.x * xRatio; // need 0.5 offset?
    float v = -myPlaneSize.y/2 + myPlaneSize.y * yRatio; // need 0.5 offset?
    result.add(PVector.mult(myXaxis, u));
    result.add(PVector.mult(myYaxis, v));
    result.normalize();
    return new Ray(myViewPoint, result);
  }

  /**
   * Computes the axes of the view space in relation to the image plane.
   * The camera's view is determined by the position and a view window.
   * The window's center is positioned along the view direction at a
   * distance from the position. It is oriented in space so that it is
   * perpendicular to the image plane normal and its top and bottom edges
   * are perpendicular to the up vector.
   */
  private void init ()
  {
    myZaxis = myPlaneNormal;
    myXaxis = myViewUp.cross(myZaxis);
    myXaxis.normalize();
    myYaxis = myXaxis.cross(myZaxis);
    myYaxis.normalize();
  }

  /**
   * For debugging purposes.
   */
  public String toString ()
  {
    return "Camera = " +
           "\n File Data" +
           "\n  Position = " + myViewPoint +
           "\n  Direction = " + myViewDirection +
           "\n  Up Vector = " + myViewUp +
           "\n  Plane Normal = " + myPlaneNormal +
           "\n  Plane Data = " + myPlaneSize +
           "\n Computed Data" +
           "\n  X-axis = " + myXaxis +
           "\n  Y-axis = " + myYaxis +
           "\n  Z-axis = " + myZaxis;
  }
}

