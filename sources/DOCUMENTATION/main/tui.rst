.. _tui:

.. figure:: /images/head.png
   :align: center

Developer's Documentation
=========================

This chapter contains different reference manuals and other documents which can be
helpful for the developers who wants to customize the **SALOME platform** or develop
new features, modules, plugins, etc.

Modules documentation
---------------------

* `KERNEL module <../tui/KERNEL/index.html>`__

*This is the developer reference manual for the SALOME KERNEL module. It provides a general
description of the main services implemented within the KERNEL module.*

* `GUI module <../tui/GUI/index.html>`__

*This is the developer reference manual for the SALOME GUI module. It provides a description
of the basic functionalities available in the GUI module.*

* `Shaper module <../tui/SHAPER/index.html>`__

*This section contains developer reference manual for the SALOME Shaper module. Shaper is a
CAD modeler which came as a replacement for the former Geometry module.*

* `Geometry module <../tui/GEOM/index.html>`__

This section contains developer reference manual for the SALOME Geometry module, the legacy
CAD modeler of the SALOME platform.*

* `Mesh module <../tui/SMESH/index.html>`__

*This is the developer reference manual for the SALOME Mesh module. This module can be used
for generating of the meshes from the CAD model prepared in Geometry or Shaper.*

* `YACS module  <../tui/YACS/index.html>`__

*This section contains developer reference manual for the SALOME YACS module.*

* `Fields module  <../dev/FIELDS/index.html>`__

*This section contains developer reference manual for the SALOME Fields module formely known
as Med module.*

* `ParaVis module  <../dev/PARAVIS/index.html>`__

*This section contains developer reference manual for the SALOME ParaVis module.*

Guides
------

.. |pdf| image:: /images/pdf.png
   :height: 16px
.. |warn| image:: /images/warn.png
   :height: 16px
.. |fr| image:: /images/fr.png
   :height: 16px

.. table::

   +--------+----------------------------+
   | Legend                              |
   +========+============================+
   | |warn| | Document is not up to date |
   +--------+----------------------------+
   | |fr|   | Document in French         |
   +--------+----------------------------+
   | |pdf|  | Document in PDF format     |
   +--------+----------------------------+

Architecture
~~~~~~~~~~~~

* |pdf| `SALOME GUI Architecture <../extra/SALOME_GUI_Architecture.pdf>`__ (PDF, 1 MB) |warn|

Module Development
~~~~~~~~~~~~~~~~~~

* The **SALOME Tutorial** provides an introduction to the development of new modules
  and integrating them to the SALOME platform, as well as new applications based on SALOME.
  The tutorial can be downloaded from `SALOME site <https://www.salome-platform.org/downloads>`__.

* |pdf| `Implement Dump Python <../extra/DumpPython_Extension.pdf>`__ (PDF, 67 KB)

Mesh
~~~~

* |pdf| `Use of SMDS API <../extra/SALOME_4.1.2_SMDS_reference_guide.pdf>`__ (PDF, 416 KB) |warn|
* |pdf| `Integration of new meshing algorithm as plug-in to SALOME Mesh module <../extra/SALOME_Mesh_Plugins.pdf>`__ (PDF, 91 KB)

Code Coupling
~~~~~~~~~~~~~

* |pdf| `Normalisation des maillages et des champs pour le couplage <../extra/Normalisation_pour_le_couplage_de_codes.pdf>`__ (PDF, 1 MB) |fr|
* |pdf| `Documentation of the Interface for Code Coupling / ICoCo <../extra/Interface_for_Code_Coupling.pdf>`__ (PDF, 1.6 MB) |fr|
* |pdf| `Le couplage de codes paralleles dans la plateforme SALOME <../extra/Couplage_de_codes_paralleles.pdf>`__ (PDF, 589 KB) |fr|
* |pdf| `Démonstrateur couplage fluide structure EDF <../extra/Demonstrateur_couplage_fluide_structure_EDF.pdf>`__ (PDF, 1.2 MB) |fr|

Installation procedure
~~~~~~~~~~~~~~~~~~~~~~

* `Build procedure <../dev/cmake/html/index.html>`__ (CMake)

Development
~~~~~~~~~~~

* `Contributing to the SALOME project with Git <../dev/git/html/Git_Simple_Write_Procedure.html>`__
