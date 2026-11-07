.. _tui_create_boundary:

The boundary
############

.. index:: single: boundary
.. index:: single: cylinder
.. index:: single: sphere

The variables are described in :doc:`gui_create_boundary`.

Methods of the class homard
***************************
These methods returns an instance of the class boundary.

+----------------------------------------------------------------------------------------+
+----------------------------------------------------------------------------------------+
| .. module:: CreateBoundaryCAO                                                          |
|                                                                                        |
| **CreateBoundaryCAO(boundary_name, xao_file)**                                         |
|     Returns an instance of the class ``boundary``, type CAO after its creation         |
|                                                                                        |
|     - ``boundary_name``: the name of the CAO boundary                                  |
|     - ``xao_file``: the name of the file for this CAO, with format XAO                 |
+----------------------------------------------------------------------------------------+
| .. module:: CreateBoundaryDi                                                           |
|                                                                                        |
| **CreateBoundaryDi(boundary_name, mesh_name, mesh_file)**                              |
|     Returns an instance of the class ``boundary``, type discrete after its creation    |
|                                                                                        |
|     - ``boundary_name``: the name of the discrete boundary                             |
|     - ``mesh_name``: the name of the mesh of the boundary                              |
|     - ``mesh_file``: the name of the file for this mesh, with format MED               |
+----------------------------------------------------------------------------------------+
| .. module:: CreateBoundaryCylinder                                                     |
|                                                                                        |
| **CreateBoundaryCylinder(boundary_name, Xcen, Ycen, Zcen, Xaxe, Yaxe, Zaxe, R)**       |
|     Returns an instance of the class ``boundary`` analytical type cylindrical          |
|     after its creation                                                                 |
|                                                                                        |
|     - ``boundary_name``: the name of the analytical boundary based on a cylinder       |
|     - ``Xcen``, ``Ycen``, ``Zcen``: coordinates of a point on the axis of the cylinder |
|     - ``Xaxe``, ``Yaxe``, ``Zaxe``: vector of the axis                                 |
|     - ``R``: radius of the cylinder                                                    |
+----------------------------------------------------------------------------------------+
| .. module:: CreateBoundarySphere                                                       |
|                                                                                        |
| **CreateBoundarySphere(boundary_name, Xcen, Ycen, Zcen, R)**                           |
|     Returns an instance of the class ``boundary`` analytical type spherical            |
|     after its creation                                                                 |
|                                                                                        |
|     - ``boundary_name``: the name of the boundary analytique based on a sphere         |
|     - ``Xcen``, ``Ycen``, ``Zcen``: coordinates of the centre of the sphere            |
|     - ``R``: radius of the sphere                                                      |
+----------------------------------------------------------------------------------------+
| .. module:: CreateBoundaryConeA                                                        |
|                                                                                        |
| **CreateBoundaryConeA(boundary_name, Xaxe, Yaxe, Zaxe, Angle, Xcen, Ycen, Zcen)**      |
|     Returns an instance of the class ``boundary`` analytical type conical              |
|     after its creation                                                                 |
|                                                                                        |
|     - ``boundary_name``: the name of the boundary analytique based on a cone           |
|     - ``Xaxe``, ``Yaxe``, ``Zaxe``: vector of the axis                                 |
|     - ``Angle``: opening angle of the cone in degree (between 0 and 90)                |
|     - ``Xcen``, ``Ycen``, ``Zcen``: coordinates of the centre of the cone              |
+----------------------------------------------------------------------------------------+
| .. module:: CreateBoundaryConeR                                                        |
|                                                                                        |
| **CreateBoundaryConeR(boundary_name, Xc1, Yc1, Zc1, R1, Xc2, Yc2, Zc2, R2)**           |
|     Returns an instance of the class ``boundary`` analytical type conical              |
|     after its creation                                                                 |
|                                                                                        |
|     - ``boundary_name``: the name of the boundary analytique based on a cone           |
|     - ``Xc1``, ``Yc1``, ``Zc1``: coordinates of the first centre of the cone           |
|     - ``R1``: radius of the cone at the first centre of the cone                       |
|     - ``Xc2``, ``Yc2``, ``Zc2``: coordinates of the second centre of the cone          |
|     - ``R2``: radius of the cone at the second centre of the cone                      |
+----------------------------------------------------------------------------------------+
| .. module:: CreateBoundaryTorus                                                        |
|                                                                                        |
| **CreateBoundaryTorus(boundary_name, Xcen, Ycen, Zcen, Xaxe, Yaxe, Zaxe, RRev, RPri)** |
|     Returns an instance of the class ``boundary`` analytical type torus                |
|     after its creation                                                                 |
|                                                                                        |
|     - ``boundary_name``: the name of the analytical boundary based on a torus          |
|     - ``Xcen``, ``Ycen``, ``Zcen``: coordinates of the centre of the torus             |
|     - ``Xaxe``, ``Yaxe``, ``Zaxe``: vector of the axis                                 |
|     - ``RRev``: revolution radius of the torus                                         |
|     - ``RPri``: primary radius of the torus                                            |
+----------------------------------------------------------------------------------------+

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetBoundary                                       |
|                                                               |
| **GetBoundary(boundary_name)**                                |
|     Returns the instance of the class classe ``boundary``     |
|     known by its name                                         |
|                                                               |
|     - ``boundary_name``: the name of the boundary             |
+---------------------------------------------------------------+
| .. module:: GetAllBoundarysName                               |
|                                                               |
| **GetAllBoundarysName()**                                     |
|     Returns the list of the names of all the existing         |
|     boundaries                                                |
|                                                               |
+---------------------------------------------------------------+

Methods of the class cas
************************
See also in :doc:`tui_create_case`.

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: AddBoundary                                       |
|                                                               |
| **AddBoundary(boundary)**                                     |
|     Add a boundary to the definition of a case                |
|                                                               |
|     - ``boundary``: name of the curved boundary               |
+---------------------------------------------------------------+
| .. module:: AddBoundaryGroup                                  |
|                                                               |
| **AddBoundaryGroup(boundary, group)**                         |
|     Add a boundary to the definition of a case with a         |
|     filtering by groups                                       |
|                                                               |
|     - ``boundary``: name of the curved boundary               |
|                                                               |
|     Discrete or CAO boundary:                                 |
|                                                               |
|     - ``group``: the name of a group of meshes                |
|                                                               |
|     Analytical boundary:                                      |
|                                                               |
|     - ``group``: name of the groups of faces located on the   |
|       boundary                                                |
+---------------------------------------------------------------+

Methods of the class boundary
*****************************

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetName                                           |
|                                                               |
| **GetName()**                                                 |
|     Returns the name of the boundary                          |
+---------------------------------------------------------------+
| .. module:: GetType                                           |
|                                                               |
| **GetType()**                                                 |
|     Returns the type of the boundary:                         |
|                                                               |
|         * -1: CAO                                             |
|         * 0: discrete                                         |
|         * 1: cylinder                                         |
|         * 2: sphere                                           |
|         * 3: cone defined by an axis and an angle             |
|         * 4: cone defined by 2 radius                         |
|         * 5: torus                                            |
+---------------------------------------------------------------+
| .. module:: GetCoords                                         |
|                                                               |
| **GetCoords()**                                               |
|     Returns the array of the coordinates of the boundary      |
|     with the same order as in its definition with             |
|     CreateBoundaryXXXX                                        |
+---------------------------------------------------------------+
| .. module:: Delete                                            |
|                                                               |
| **Delete()**                                                  |
|     Deletes the boundary.                                     |
|     If the boundary is discrete, the file of the mesh is kept.|
|     If the boundary is CAO, the xao file of the geometry is   |
|     kept.                                                     |
|                                                               |
|     Returns an integer:                                       |
|         * 0: the destruction is done                          |
|         * other value: problem                                |
+---------------------------------------------------------------+


Example
*******
Creation of a CAO boundary: ::

    la_cao = homard.CreateBoundaryCAO("BLOC", dircase+'/tutorial_6.xao')

Creation of a discrete boundary, a spherical boundary, and a cylindrical boundary:
::

    inter = homard.CreateBoundaryDi("INTERSECTION", 'PIQUAGE', dircase+'/tutorial_4.fr.med')
    fron_1 = homard.CreateBoundarySphere("FRON_1", 12.3, 3.4, .56, 6.5)
    fron_2 = homard.CreateBoundaryCylinder('CYL_1', 0.0, 25., -25., 25., 50., 75., 100.)


Similar graphical input
***********************
Look at :doc:`gui_create_boundary`
