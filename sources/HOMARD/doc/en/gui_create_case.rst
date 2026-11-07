.. _gui_create_case:

The creation of a case
######################
.. index:: single: case

The definition of a case is done with the following data:

  - A name
  - A directory
  - The file of the initial mesh
  - The type of conformity for the serie of adaptations
  - Some curved boundaries

.. image:: images/intro_32.png
   :align: center


Name of the case
****************
A name is automatically suggested for the case: Case_1, Case_2, etc. This name can be modified. It must be a new name.

The directory
*************
The directory will countain all the files producted by the successive adaptations. By default, nothing is suggested. The choice is made either by giving a name into the text zone or by a selection through the search window. In this directory, the MED files for the adapted mesh will be stored, with name ``maill.xx.med``, where ``xx`` is a rank number automatically created. These files can be seen into the object browser.

.. image:: images/create_case_2.png
   :align: center

.. index:: single: mesh;initial
.. index:: single: MED

The initial mesh
****************
The initial mesh must be stored into a MED file. Usually, it is produced by the software that solves the physical problem. But it also can be created by the module SMESH and exported with the MED format. The name of the file is choosen either by giving a name into the text zone or by a selection through the search window.


.. image:: images/create_case_3.png
   :align: center

.. note::
  Only one mesh into the file.

.. warning::
  The initial mesh must not be itself the product of an adaptation by HOMARD. If it is, the coherence between the different levels of refinement will be lost.


.. index:: single: conformity

Type of conformity
******************
The future iterations for this case must respect the the same behaviour regarding the type of conformity.

The default option, 'conformal', implies that the meshes produced by HOMARD will be conformal, as expected in the finite element method. This is a classical choice for most of the simulation software with the finite element method.

The treatment of non conformal meshes is possible.

.. image:: images/create_case_4.png
   :align: center

Some extra options can be given by the advanced options.

.. index:: single: boundary

The boundaries
**************
If the limit of the domain is curved, HOMARD can put the new nodes onto these curved limits to avoid some artificial singularities. This technique is effective for external limits as well for internal limits.

Two situations:

- CAO: the CAO of the domain is available. The computtion will rely on it to project the nodes.
- No CAO: if no CAO is available, an approximative approach is possible:

  * 1D curve: this curve may be defined into a plane, for example for a 2D calculation. It can also be defined into the 3D space, for example to describe the intersection of two surfaces. Such a line is defined with a discrete desription.
  * a surface: such a surface is defined with an analytical description.

Check the button:

.. image:: images/create_boundary_1.png
   :align: center

The definition of the boundaries is described in :doc:`gui_create_boundary`.

.. index:: single: pyramid

Advanced options
****************
Default: no advanced option. Nevertheless, some advanced options can be defined :

The pyramids
============

The first option is about the pyramids.

.. image:: images/create_case_7.png
   :align: center

HOMARD is able to work with 2D or 3D meshes as well, including the following elements:
   - nodal element
   - segment
   - triangle
   - quadrangle
   - tetrahedron
   - hexahedron
   - prism

If pyramids are present into the initial mesh, HOMARD stops with an error. However, if no refinement will be in contact with any edge of those pyramids, the "Authorized pyramids" whould be checked. The adaptation will go on and the pyramids will be back as they are into the initial mesh.
Nevertheless, if the computation is available with non conformal meshes, 3 possibilities are available:

Which conformity?
=================

With a conformal refinement, the choice is given between the standard conformal refinement, default option, and a refinement into boxes, e.g. without any staircases.

.. image:: images/create_case_8.png
   :align: center

Which non conformity?
=====================

With a non conformal refinement, 4 choices are available:

* standard non conformal refinement, default option
* refinement into boxes, e.g. without any staircases
* 1 node per edge: every single edge of an element ban be split once while its neighbour is not.
* free: no limit for the number of hanging node.

.. image:: images/create_case_9.png
   :align: center

The external format
===================
.. index:: single: MED
.. index:: single: Saturne

By default, the external format is MED. When coupled with Saturne 2D, it is necessary to precise it to correctly deal with the pseudo 2D situation.

.. image:: ../images/create_case_1.png
   :align: center

The pursuit of a case
*********************
.. index:: single: pursuit
.. index:: single: YACS

The pursuit of a case is interesting in the following situation. A list of adaptations was done for a case and, at the end, SALOME is closed. The directories for these iterations are kept. Then, the user wants to go on these iterations from the final point of the previous list. This function is useful with a schema YACS if a long list of adaptations is cut into small parts.

The compulsatory condition to pursue an iteration is to keep two files into the same directory:
   - the configuration file that was a data for the binary module of HOMARD; this file looks like ``HOMARD.Configuration.(n).vers.(n+1)``
   - the MED file that saves the history of th eprevious adaptations; this file looks like ``maill.(n).hom.med``

Either an iteration known by its directory or an iteration identified into the directory of a case can be selected.

To pursuit of an iteration known by its directory, the definition of the case is made by the following data:

  - A name
  - A directory
  - The directory of the data base

.. image:: images/pursue_case_1.png
   :align: center

The pursuit of an iteration into a previous case can be operated; the default starting iteration is the last iteration of the case.

.. image:: images/pursue_case_2.png
   :align: center

If the starting iteration is not the last one, its number must be given:

.. image:: images/pursue_case_3.png
   :align: center

.. note::
  The governing parameters of the created case are the same as the ones of the strating iteration: same mode for the conformity, for instance.


Object browser
**************
At the end of the creation, the case is included into the object browser. The initial iteration, known by the name of the associated mesh, is shown.

.. image:: images/create_case_6.png
   :align: center



Corresponding python functions
******************************
Look :doc:`tui_create_case`

