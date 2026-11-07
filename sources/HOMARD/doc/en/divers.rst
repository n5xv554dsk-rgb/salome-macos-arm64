.. _divers:

Miscellaneous
#############

References
**********
.. index:: single: reference

For a reference to HOMARD, use:

G. Nicolas, T. Fouquet, S. Geniaut, S. Cuvilliez, Improved Adaptive Mesh Refinement for Conformal Hexahedral Meshes, "*Advances in Engineering Software*", Vol. 102, pp. 14-28, 2016, doi:10.1016/j.advengsoft.2016.07.014

`Available here <http://dx.doi.org/10.1016/j.advengsoft.2016.07.014>`_

G. Nicolas and T. Fouquet, Adaptive Mesh Refinement for Conformal Hexahedral Meshes, "*Finite Elements in Analysis and Design*", Vol. 67, pp. 1-12, 2013, doi:10.1016/j.finel.2012.11.008

`Available here <http://dx.doi.org/10.1016/j.finel.2012.11.008>`_

Other references are available on the site for `HOMARD <http://www.code-aster.org/outils/homard/en/divers.html>`_

Evolutions of the module
************************
.. index:: single: evolution

Here are the main evolutions de HOMARD from the first release in SALOME 6.5.

SALOME RELEASE 6.6:
    - Interface with med 3.0.6
    - Default values for the time steps
    - New element types: TRIA7 and QUAD9
    - Optional output into the MED file of the level of refinement of every element

SALOME RELEASE 7.1:
    - Correction of a bug in the filtering of the refinement by groups
    - Driving of the adaptation by a threshold that is based upon the mean and the standard deviation (see :doc:`tui_create_hypothese`)
    - TUI: the last time step for the driving instant can be selected by SetTimeStepRankLast (see :doc:`tui_create_iteration`)
    - The destruction of the objects is available (GUI and TUI)
    - The TUI functions are modified: they act onto the objects and no more by the names:
      ``homard.AssociateIterHypo(iter_name,hypo_name)`` becomes ``iter.AssociateHypo(hypo_name)``, ``homard.AssociateHypoZone(hypo_name,zone_name,type_use)`` becomes ``hypo.AddZone(zone_name,type_use)``, ``homard.CreateIteration(iter_name,iter_parent_name)`` becomes ``case.NextIteration(iter_name)`` or ``iter.NextIteration(iter_name)``
    - Addition of a function:
      ``cas.LastIteration()`` : returns the last iteration of the case (see :doc:`tui_create_iteration`)
    - Mesh analysis (see :doc:`gui_mesh_info`)

SALOME RELEASE 7.2:
    - A cone can be used as a support for a 2D boundary (see :doc:`tui_create_boundary`)
    - The result can be published or not published in SMESH (see :doc:`tui_create_iteration`)
      ``iter.Compute(option)`` becomes ``iter.Compute(option1, option2)``
    - A serie of iterations that is stored in a directory can be followed (see :doc:`gui_create_case`)

SALOME RELEASE 7.3:
    - English documentation
    - Options to track the computation (see :doc:`tui_create_iteration`): ``iter.SetInfoCompute(MessInfo)``
    - Automatic creation of YACS schema:
      ``case.WriteYACSSchema(ScriptFile, DirName, MeshFile)``: writes a schema YACS relative to the case (see :doc:`tui_create_case`)
    - The initial mesh is not published in SMESH.
    - The refinement of 2D meshes with quadrangles is improved to take into account 'staircases'.
    - The fields overs elements can be interpolated with two ways: intensive or extensive.
    - The time steps for the interpolation of the files can be choosen:
      ``SetFieldInterpTimeStep(FieldInterp, TimeStep)``: defines the time step for the interpolation of the field (see :doc:`tui_create_iteration`)
      ``SetFieldInterpTimeStepRank(FieldInterp, TimeStep, Rank)``: defines the time step and the rank for the interpolation of the field (see :doc:`tui_create_iteration`)
    - If error occurs into the python instructions, the program stops.

SALOME RELEASE 7.4:
    - Scroll bar for the large windows.
    - The meshes are published only if requested.
    - The torus is a new possibility for the analytical boundary.
    - The function ``SetAdapRefinUnRef(TypeAdap, TypeRaff, TypeDera)`` is suppressed. For an adaptation by a field or by zones, the mode refinement/unrefinement is automatically set from the other parameters of the hypothesis. For a uniform refinement, the function ``SetUnifRefinUnRef(TypeRaffDera)`` is now used (see :doc:`tui_create_hypothese`).
    - If an error occurs, the name of the message file is displayed.
    - Release 11.1 for the HOMARD binary. The conformal refinement of the meshes with hexaedra is improved: less meshes are produced.

SALOME RELEASE 7.5:
    - Additional extra output: diameters and qualities; the function ``SetExtraOutput(option)`` is now used (see :doc:`tui_create_hypothese`).
    - Release 11.2 for the HOMARD binary ; improvement for the 1D curve boundaries.

SALOME RELEASE 7.6:
    - Interpolation of all the fields into the input file.

SALOME RELEASE 8.1:
    - Interface with med 3.2.0
    - New options within the choice conformal/non-conformal.
    - Less meshes are involved in the case of a non conformal refinement of a mesh made of hexahedra.
    - Correction of an error when refinement and unrefinement are coupled for a mesh made of hexahedra.

SALOME RELEASE 8.3:
    - Interface with med 3.2.1
    - Output of the list of the meshes that are connected with a non conformal link.

SALOME RELEASE 8.4:
    - Interface with med 3.3.0
    - Correction for the conformal coarsening of a set of hexaedra
    - Correction of the interpolation od a volumic field over prisms which are splitted into tetrahedra and pyramids
    - Integer MED fields to glue the elements with different levels when non conformal refinement is used
