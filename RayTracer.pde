// change to test different scenes
final String SCENE_FILE = "four_spheres.xml";
// change to distinguish background from shadows
final color BACKGROUND_COLOR = color(1, 0, 1);
// change the color of the overall ambient light
final PVector AMBIENT_LIGHT_COLOR = new PVector(1, 1, 1);
// change the intensity of the ambient light
final float AMBIENT_LIGHT = 0.16;

// change to print out debugging information while processing
boolean debug = false;
// needs to be global to be used by all methods in this file
Scene scene = new Scene();


void setup ()
{
  // smaller is faster, bigger for more detailed pictures
  size(600, 600);
  // computed color values range from [0 .. 1]
  colorMode(RGB, 1.0);
  // generate picture only, no animation
  noLoop();
  // read XML configuration file
  scene.read(new XMLElement(this, SCENE_FILE));
}


void draw ()
{
  println("Starting ray tracing ...");
  // for each pixel, compute ray through it and return corresponding color
  for (int y = 0; y < height; y++)
  {
    float yRatio = float(y) / height;
    for (int x = 0; x < width; x++)
    {
      float xRatio = float(x) / width;
      set(x, y, scene.renderPixel(xRatio, yRatio));
    }
  }
  println("Done.");
}


// for debugging purposes, test shooting a single ray through the mouse location
void mouseClicked ()
{
  debug = true;
  println("Shooting ray at: [" + mouseX + ", " + mouseY + "]");
  scene.renderPixel(float(mouseX) / width, float(mouseY) / height);
  println("Done.");
  debug = false;
}
