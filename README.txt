CompSci 124 : Ray Tracer Code

All the functions or parts of the functions you need to complete are marked with TODO in the source code. The following explanations are to give you a rough overview of the tasks. Most instructions, however, are provided in the comments in the source code or algorithms described in the text book or slides.


Camera. 
This class represents the camera in the scene. You need to complete two functions which will initialize the camera’s axis vectors and return a ray corresponding to a given pixel position in the rendered image.

Sphere/Box
These classes are subclasses of Surface (and written below it in the same file). You need to complete two functions for each surface, defined as abstract in Surface, which determines if the given ray intersects this surface and determines the surface normal at the given point.

Lambertian/Phong
These classes are subclasses of Shader (and written below it in the same file). 
You need to complete the one function for each shader, defined as abstract in Shader, which will determine the material's color using the information from the  IntersectionData and the scene's light sources.



The rest of the classes are intended simply as helper classes. One thing to note is that, in an effort to reduce the overall code in the framework, all collections of 3 numbers (e.g., colors, vectors, and points) are represented simply using the Processing data type PVector, which provides basic utilities for combining triples. Every effort has made to note the PVector's purpose in the code through its variable name to avoid confusion when using them.

If you decide to work on any of the extra credit, you may find yourself changing the helper classes, especially Scene (to add new parsing options) and IntersectionData (to keep track of new data that pertains to new materials or processing).  

In general, you are welcome to change any of the code you want outside the specific areas marked as TODO, however, keep in mind that the project's point is not to improve the parsing or structure, etc. so do not get caught up in the trap of simply refactoring the given code.
