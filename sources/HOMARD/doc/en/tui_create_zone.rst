.. _tui_create_zone:

The zone
########

.. index:: single: zone
.. index:: single: box
.. index:: single: sphere
.. index:: single: cylinder
.. index:: single: pipe
.. index:: single: disk
.. index:: single: disk with a hole
.. index:: single: 2D

The variables are described in :doc:`gui_create_zone`.

Methods of the class homard
***************************

These methods returns an instance of the class zone.

+----------------------------------------------------------------------------------+
+----------------------------------------------------------------------------------+
| .. module:: CreateZoneBox                                                        |
|                                                                                  |
| **CreateZoneBox(zone_name, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax)**                 |
|     Returns an instance of the class ``zone`` of type box                        |
|     after its creation                                                           |
|                                                                                  |
|     - ``zone_name``: the name of the zone based on a box                         |
|     - ``Xmin``, ``Xmax``: min/max coordinates extrêmes along X                   |
|     - ``Ymin``, ``Ymax``: min/max coordinates extrêmes along Y                   |
|     - ``Zmin``, ``Zmax``: min/max coordinates extrêmes along Z                   |
+----------------------------------------------------------------------------------+
| .. module:: CreateZoneCylinder                                                   |
|                                                                                  |
| **CreateZoneCylinder(zone_name, Xbase, Ybase, Zbase, Xaxe, Yaxe, Zaxe, R, H)**   |
|     Returns an instance of the class ``zone`` of type cylinder                   |
|     after its creation                                                           |
|                                                                                  |
|     - ``zone_name``: the name of the zone based on a cylinder                    |
|     - ``Xbase``, ``Ybase``, ``Zbase``: coordinates of a point on the axis        |
|     - ``Xaxe``, ``Yaxe``, ``Zaxe``: vector of the axis                           |
|     - ``R``: radius of the cylinder                                              |
|     - ``H``: height of the cylinder                                              |
+----------------------------------------------------------------------------------+
| .. module:: CreateZonePipe                                                       |
|                                                                                  |
| **CreateZonePipe(zone_name, Xbase, Ybase, Zbase, Xaxe, Yaxe, Zaxe, R, H, Rint)** |
|     Returns an instance of the class ``zone`` of type pipe                       |
|     after its creation                                                           |
|                                                                                  |
|     - ``zone_name``: the name of the zone based on a pipe                        |
|     - ``Xbase``, ``Ybase``, ``Zbase``: coordinates of a point on the axis        |
|     - ``Xaxe``, ``Yaxe``, ``Zaxe``: vector of the axis                           |
|     - ``R``: external radius of the pipe                                         |
|     - ``H``: height of the pipe                                                  |
|     - ``R``: internal radius of the pipe                                         |
+----------------------------------------------------------------------------------+
| .. module:: CreateZoneSphere                                                     |
|                                                                                  |
| **CreateZoneSphere(zone_name, Xcen, Ycen, Zcen, R)**                             |
|     Returns an instance of the class ``zone`` of type sphere                     |
|     after its creation                                                           |
|                                                                                  |
|     - ``zone_name``: the name of the zone based on a sphere                      |
|     - ``Xcen``, ``Ycen``, ``Zcen``: coordinates of the center of the sphere      |
|     - ``R``: radius of the sphere                                                |
+----------------------------------------------------------------------------------+
| .. module:: CreateZoneBox2D                                                      |
|                                                                                  |
| **CreateZoneBox2D(zone_name, Umin, Umax, Vmin, Vmax, Orient)**                   |
|     Returns an instance of the class ``zone`` of type rectangle                  |
|     after its creation                                                           |
|                                                                                  |
|     - ``zone_name``: the name of the zone based on a rectangle                   |
|     - ``Umin``, ``Umax``: min/max coordinates for the 1st dimension              |
|     - ``Vmin``, ``Vmax``: min/max coordinates for the 2nd dimension              |
|     - ``Orient``: integer that defines the convention for the plane              |
+----------------------------------------------------------------------------------+
| .. module:: CreateZoneDisk                                                       |
|                                                                                  |
| **CreateZoneDisk(zone_name, Ucen, Vcen, R, Orient)**                             |
|     Returns an instance of the class ``zone`` of type disk                       |
|     after its creation                                                           |
|                                                                                  |
|     - ``zone_name``: the name of the zone based on a full disk                   |
|     - ``Ucen``, ``Vcen``: coordinates of the center of the disk                  |
|     - ``R``: radius of the disk                                                  |
|     - ``Orient``: integer that defines the convention for the plane              |
+----------------------------------------------------------------------------------+
| .. module:: CreateZoneDiskWithHole                                               |
|                                                                                  |
| **CreateZoneDiskWithHole(zone_name, Ucen, Vcen, R, Rint, Orient)**               |
|     Returns an instance of the class ``zone`` of type disk with a hole           |
|     after its creation                                                           |
|                                                                                  |
|     - ``zone_name``: the name of the zone based on a disk with a hole            |
|     - ``Ucen``, ``Vcen``: coordinates of the center of the disk                  |
|     - ``R``: external radius of the disk                                         |
|     - ``Rint``: internal radius of the disk                                      |
|     - ``Orient``: integer that defines the convention for the plane              |
+----------------------------------------------------------------------------------+



+---------------------------------------------------------------+
+---------------------------------------------------------------+
|   The convention of the orientation of the plane is the same  |
|   as the one that is applied in the other modules of SALOME,  |
|   in particular GEOM:                                         |
|                                                               |
|     1. plane XY ; U <==> X and V <==> Y                       |
|     2. plane YZ ; U <==> Y and V <==> Z                       |
|     3. plane ZX ; U <==> Z and V <==> X                       |
+---------------------------------------------------------------+


.. note::
  The functions that define 2D zones should be used only of the whole mesh is 2D into a plane of coordinates.




+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetZone                                           |
|                                                               |
| **GetZone(zone_name)**                                        |
|     Returns an instance of the class ``zone``                 |
|     known by its name                                         |
|                                                               |
|     - ``zone_name``: the name of the zone                     |
+---------------------------------------------------------------+
| .. module:: GetAllZonesName                                   |
|                                                               |
| **GetAllZonesName()**                                         |
|     Returns the liste of the name of all the existing zones   |
|                                                               |
+---------------------------------------------------------------+


Methods of the class zone
*************************

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetName                                           |
|                                                               |
| **GetName()**                                                 |
|     Returns the name of the zone                              |
+---------------------------------------------------------------+
| .. module:: GetType                                           |
|                                                               |
| **GetType()**                                                 |
|     Returns the type of the zone                              |
|                                                               |
|         * 2: box                                              |
|         * 3: sphere                                           |
|         * 5: cylinder                                         |
|         * 7: pipe                                             |
|         * 11, 12, 13: rectangle and orientation 1, 2 ou 3     |
|         * 31, 32, 33: disk and orientation 1, 2 ou 3          |
|         * 61, 62, 63: disk with a hole and orientation 1, 2   |
|           ou 3                                                |
+---------------------------------------------------------------+
| .. module:: GetCoords                                         |
|                                                               |
| **GetCoords()**                                               |
|     Returns the array of the coordinates of the zone          |
|     with the same order as in its definition with             |
|     CreateZoneXXXX                                            |
+---------------------------------------------------------------+
| .. module:: Delete                                            |
|                                                               |
| **Delete()**                                                  |
|     Deletes the zone                                          |
|                                                               |
|     Returns an integer:                                       |
|         * 0: the destruction is done                          |
|         * other value: problem                                |
+---------------------------------------------------------------+


Example
*******
The creation of a 3D box is done as follows:
::

    zone_1 = homard.CreateZoneBox ("BLOC", -1., 1., -30., 40., 10.5, 20.8)


The creation of a disk in the plane XY is done as follows:
::

    zone_2 = homard.CreateZoneDisk ("disk", 1., 3., 43.25, 1)


Similar graphical input
***********************
Look at :doc:`gui_create_zone`

.. warning::
  With the graphical input mode, if a zone is edited and if one of the dimensions is modified, all the iterations that were computed with this zone are unvalidated. In python mode, that is not true: the iterations stay as they are.
