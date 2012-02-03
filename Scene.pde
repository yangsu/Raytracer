/**
 * Represents a collection of objects, lights illuminating them, and a view point.
 */
public class Scene
{
  // These are read in from input file and do not change during rendering
  /** The camera for this scene. */
  private Camera myCamera;
  /** The list of lights for the scene. */
  private List<Light> myLights;
  /** The list of surfaces for the scene. */
  private List<Surface> mySurfaces;
  /** The list of materials in the scene . */
  private Map<String, Shader> myShaders;

  /**
   * Create an empty scene.
   */
  public Scene ()
  {
    myLights = new ArrayList<Light>();
    mySurfaces = new ArrayList<Surface>();
    myShaders = new HashMap<String, Shader>();
  }

  /**
   * Returns color along a single ray from camera through given x and y values.
   */
  public color renderPixel (float xRatio, float yRatio)
  {
    if (debug) println(myCamera);
    Ray ray = myCamera.getRay(xRatio, yRatio);
    if (debug) println("Camera to Pixel ray = " + ray);
    PVector resultColor = rayColor(ray, 0);
    if (debug) println("Resulting color = " + resultColor);
    return color(resultColor.x, resultColor.y, resultColor.z);
  }

  public PVector rayColor (Ray ray, int depth) {
    return rayColor(getClosestIntersection(ray, depth));
  }

  public PVector rayColor (IntersectionData data) {
    if (data != null)
    {
      if (debug) println(data);
      return data.surface.getColor(data, this);
    }
    else
    {
      if (debug) println("No surface hit by ray.");
      return BACKGROUND_COLOR_VECTOR;
    }
  }

  /**
   * Returns the first intersection of given ray with surfaces in this scene.
   */
  public IntersectionData getClosestIntersection (Ray ray, int depth)
  {
    if (depth > MAX_RECURSION_DEPTH) {
      // println("hit max MAX_RECURSION_DEPTH");
      return null;
    }

    float minDistance = Integer.MAX_VALUE;
    Surface hitSurface = null;
    for (Surface s : mySurfaces)
    {
      float t = s.intersects(ray);
      if (t > 0 && t < minDistance)
      {
        minDistance = t;
        hitSurface = s;
      }
    }
    if (hitSurface != null)
    {
      PVector hitPoint = ray.evaluate(minDistance);
      return new IntersectionData(ray, hitPoint,
                                  hitSurface.getNormal(hitPoint),
                                  hitSurface, minDistance, depth + 1);
    }
    else
    {
      return null;
    }
  }

  /**
   * Returns true if any intersection is found between given ray and surfaces in this scene.
   *
   * Shadow ray calculations can be considerably accelerated by not bothering to find the
   * first intersection.
   */
  public boolean isAnyIntersection (Ray ray)
  {
    for (Surface s : mySurfaces)
    {
      if (s.intersects(ray) > 0)
      {
        return true;
      }
    }
    return false;
  }

  /**
   * Returns the scene's lights.
   */
  public List<Light> getLights ()
  {
    return myLights;
  }

  /**
   * Returns the scene's surfaces.
   */
  public List<Surface> getSurfaces ()
  {
    return mySurfaces;
  }


  // BUGBUG: yuck --- ugly parsing code below
  //         Processing does not support reflection :(
  /**
   * Read scene description from given XML data.
   */
  public void read (XMLElement root)
  {
    for (XMLElement node : root.getChildren())
    {
      if (node.getName().equalsIgnoreCase("camera"))
      {
        setCamera(node.getChildren());
      }
      else if (node.getName().equalsIgnoreCase("light"))
      {
        addLight(node.getChildren());
      }
      else if (node.getName().equalsIgnoreCase("surface"))
      {
        addSurface(node.getString("type"), node.getChildren());
      }
      else if (node.getName().equalsIgnoreCase("shader"))
      {
        addShader(node.getString("name"), node.getString("type"), node.getChildren());
      }
    }
  }

  /** Set scene's camera. */
  private void setCamera (XMLElement[] properties)
  {
    Map<String, Object> values = parse(properties);
    myCamera = new Camera((PVector)values.get("position"),
                          (PVector)values.get("direction"),
                          (PVector)values.get("viewup"),
                          (PVector)values.get("imageplanenormal"),
                          (PVector)values.get("imageplane"));
  }

  /** Add a light to this scene. */
  private void addLight (XMLElement[] properties)
  {
    Map<String, Object> values = parse(properties);
    myLights.add(new Light((PVector)values.get("position"),
                           (PVector)values.get("color")));
  }

  /** Add a surface to scene. */
  private void addSurface (String type, XMLElement[] properties)
  {
    Map<String, Object> values = parse(properties);
    if (type.equalsIgnoreCase("sphere"))
    {
      mySurfaces.add(new Sphere((PVector)values.get("center"),
                                ((PVector)values.get("radius")).x,
                                myShaders.get(values.get("shader"))));
    }
    else if (type.equalsIgnoreCase("box"))
    {
      mySurfaces.add(new Box((PVector)values.get("minpoint"),
                             ((PVector)values.get("maxpoint")),
                             myShaders.get(values.get("shader"))));
    }
  }

  /** Add a shader to scene. */
  private void addShader (String name, String type, XMLElement[] properties)
  {
    Map<String, Object> values = parse(properties);

    PVector a = ((PVector)values.get("alpha"));
    float alpha = 1.0;
    if (a != null)
      alpha = a.x;

    if (type.equalsIgnoreCase("lambertian"))
    {
      myShaders.put(name,
                    new Lambertian((PVector)values.get("diffusecolor"),
                                   alpha));
    }
    else if (type.equalsIgnoreCase("phong"))
    {
      myShaders.put(name,
                    new Phong((PVector)values.get("diffusecolor"),
                              (PVector)values.get("specularcolor"),
                              ((PVector)values.get("exponent")).x,
                              alpha));
    }
    else if (type.equalsIgnoreCase("glazed"))
    {
      myShaders.put(name,
                    new Glazed((PVector)values.get("diffusecolor"),
                               ((PVector)values.get("reflectivity")).x,
                               alpha));
    }
    else if (type.equalsIgnoreCase("reflective"))
    {
      myShaders.put(name,
                    new Reflective((PVector)values.get("diffusecolor"),
                                   (PVector)values.get("specularcolor"),
                                   ((PVector)values.get("exponent")).x,
                                   ((PVector)values.get("reflectivity")).x,
                                   alpha));
    }
    else if (type.equalsIgnoreCase("refractive"))
    {
      myShaders.put(name,
                    new Refractive((PVector)values.get("diffusecolor"),
                                   (PVector)values.get("specularcolor"),
                                   ((PVector)values.get("exponent")).x,
                                   ((PVector)values.get("reflectivity")).x,
                                   ((PVector)values.get("refractionindex")).x,
                                   alpha));
    }
  }

  /** Convert an XML string to component values. */
  private Map<String, Object> parse (XMLElement[] properties)
  {
    Map<String, Object> values = new HashMap<String, Object>();
    for (XMLElement p : properties)
    {
      String key = p.getName().toLowerCase();
      if (p.getContent() != null)
      {
        float[] nums = float(split(p.getContent(), " "));
        values.put(key, new PVector(nums[0],
                                    nums.length > 1 ? nums[1] : 0,
                                    nums.length > 2 ? nums[2] : 0));
      }
      else
      {
        values.put(key, p.getString("ref").toLowerCase());
      }
    }
    return values;
  }
}

