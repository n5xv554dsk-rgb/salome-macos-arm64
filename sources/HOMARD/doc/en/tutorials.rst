Examples
########
.. index:: single: example
.. index:: single: python

One will find here the instructions python for some characteristic configurations. The associated data files are downloadable. It is necessary to think of adapting the value of the variable ``data_dir``: it is the directory in which the files med will have been recorded.
It is in the directory ``dircase`` that the files will be written resulting from the successive adaptations. This directory is created by default in ``/tmp``.

Loading of the module HOMARD
****************************
.. index:: single: YACS

The loading of the module HOMARD is done in a way similar to the other modules.

 ::

  import HOMARD
  homard = salome.lcc.FindOrLoadComponent('FactoryServer','HOMARD')
  homard.UpdateStudy()

To use the module HOMARD within a distributed scheme YACS, the loading is made as follows:

 ::

  import HOMARD
  my_container.load_component_Library('HOMARD')
  homard = my_container.create_component_instance('HOMARD',0)
  homard.UpdateStudy()

Uniform refinement
******************
.. index:: single: refinement;uniform

One will make here three successive uniform refinements of the mesh contained in the file ``tutorial_1.00.med``. Some notes:
  * the same hypothesis is used with each iteration
  * the produced mesh always bears the same name. That does not pose a problem because it is stored in different files.


.. literalinclude:: ../files/tutorial_1.py
   :language: python
   :start-after: Début des commandes
   :end-before: Fin des commandes

.. note::
  Download the files

  * :download:`initial mesh<../files/tutorial_1.00.med>`
  * :download:`python script<../files/tutorial_1.py>`
  * :download:`python script for the creation of the test directory<../files/tutorial_util.py>`



Refinement by zones
*******************
.. index:: single: zone

One proceeds here to refinement according to zones. To pass from the initial mesh to the mesh 'M_1', one uses a box framing the z=1 plane and a sphere centered on the origin with radius 1.05. Then to pass from the mesh 'M_1' to the mesh 'M_2', one replaces the sphere by a box framing the cube on side 0.5, pointing on the origin and the meshes in the very first zone are unrefined.

.. literalinclude:: ../files/tutorial_2.py
   :language: python
   :start-after: Début des commandes
   :end-before: Fin des commandes

.. note::
  Download the files

  * :download:`initial mesh<../files/tutorial_2.00.med>`
  * :download:`python script<../files/tutorial_2.py>`
  * :download:`python script for the creation of the test directory<../files/tutorial_util.py>`


Refinement driven by a field
****************************
.. index:: single: field

One proceeds here to refinement according to a field. The hypotheses are used to define the name of the field and the thresholds of refinement/unrefinement. The input of the file and the instants is made in the iteration. Fields on the nodes or the elements are interpolated.
To adapt the H_1 mesh resulting from the Iter_1 iteration, two alternatives are applied. In the first, Iter_2, the field is a scalar field of indicators of error and one cuts out the 1.5% of elements where the error is largest. In the second alternative, Iter_2_bis, one is based on a vector field and one examines the jump of this vector between an element and its neighbors: one will cut out where the infinite standard of this jump is higher than the absolute threshold of 0.0001.

.. literalinclude:: ../files/tutorial_3.py
   :language: python
   :start-after: Début des commandes
   :end-before: Fin des commandes

.. note::
  Download the files

  * :download:`mesh and field stage 0<../files/tutorial_3.00.med>`
  * :download:`mesh and field stage 1<../files/tutorial_3.01.med>`
  * :download:`python script<../files/tutorial_3.py>`
  * :download:`python script for the creation of the test directory<../files/tutorial_util.py>`


Non plane boundaries
********************
.. index:: single: boundary
.. index:: single: CAO
.. index:: single: YACS

One tests the follow-up of the curved borders here, giving the representation of the domain by its CAO. That CAO is given in a XAO format file.
The driving of refinement is the following: uniform refinement of all the elements contained in indicated groups. One starts by refining the inner faces with the pipes; then, one refines continuation twice the external faces with the pipes.
Scheme YACS carrying out this adaptation is downloadable.

.. literalinclude:: ../files/tutorial_4.py
   :language: python
   :start-after: Début des commandes
   :end-before: Fin des commandes

.. note::
  Téléchargement des fichiers

  * :download:`initial mesh<../files/tutorial_4.00.med>`
  * :download:`CAO<../files/tutorial_4.xao>`
  * :download:`python scrip<../files/tutorial_4.py>`
  * :download:`python script for the creation of the test directory<../files/tutorial_util.py>`
  * :download:`YACS scheme<../files/tutorial_4.xml>`

If the CAO is not available, the boundaries can be approximated: analytical borders to describe various surfaces of the pipes and a discrete border to describe the intersecting lines of the two pipes. Only the definition of the boundaries has to be modified.

.. literalinclude:: ../files/tutorial_6.py
   :start-after: Début des commandes
   :end-before: Fin des commandes

.. note::
  Download the files

  * :download:`initial mesh<../files/tutorial_4.00.med>`
  * :download:`mesh of the discrete boundary<../files/tutorial_6.fr.med>`
  * :download:`python script<../files/tutorial_6.py>`
  * :download:`python script for the creation of the test directory<../files/tutorial_util.py>`
  * :download:`YACS scheme<../files/tutorial_6.xml>`


Specific instructions for a 2D mesh
***********************************
.. index:: single: 2D

The instructions to adapt a 2D mesh are exactly identical to those necessary to the adaptation of a 3D mesh. The only exception relates to refinement according to geometrical zones: different functions are used to be able to define 2D zones. One gives the 2D coordinates zones, by specifying the orientation of the plane of the mesh.
In the case presented here, one for the first time refines all the elements contained in a bored disk, then in one second iteration, all the elements contained in a rectangle. One will note the use of the follow-up of the circular borders of the field.

.. literalinclude:: ../files/tutorial_5.py
   :language: python
   :start-after: Début des commandes
   :end-before: Fin des commandes

.. note::
  Download the files

  * :download:`initial mesh<../files/tutorial_5.00.med>`
  * :download:`mesh of the discrete boundary<../files/tutorial_5.fr.med>`
  * :download:`python script<../files/tutorial_5.py>`
  * :download:`python script for the creation of the test directory<../files/tutorial_util.py>`


.. toctree::
   :maxdepth: 2

