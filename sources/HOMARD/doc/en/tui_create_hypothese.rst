.. _tui_create_hypothese:

The hypothesis
##############

.. index:: single: iteration
.. index:: single: hypothesis
.. index:: single: zone

The variables are described in :doc:`gui_create_hypothese`.

Methods of the class homard
***************************

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: CreateHypothesis                                  |
|                                                               |
| **CreateHypothesis(hypo_name)**                               |
|     Returns an instance of the class ``hypothese``            |
|                                                               |
|     - ``hypo_name``: the name of the hypothesis               |
+---------------------------------------------------------------+
| .. module:: GetHypothesis                                     |
|                                                               |
| **GetHypothesis(hypo_name)**                                  |
|     Returns an instance of the class ``hypothese``            |
|     known by its name                                         |
|                                                               |
|     - ``hypo_name``: the name of the hypothesis               |
+---------------------------------------------------------------+
| .. module:: GetAllHypothesesName                              |
|                                                               |
| **GetAllHypothesesName()**                                    |
|     Returns the liste of the name of all the existing         |
|     hypotheses                                                |
|                                                               |
+---------------------------------------------------------------+

Methods of the class hypothese
******************************

General methods
===============

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetName                                           |
|                                                               |
| **GetName()**                                                 |
|     Returns the name of the hypothesis                        |
+---------------------------------------------------------------+
| .. module:: GetAdapType                                       |
|                                                               |
| **GetAdapType()**                                             |
|     Returns the type of the adaptation                        |
|                                                               |
|         * -1: uniform                                         |
|         * 0: by zones                                         |
|         * 1: by a field                                       |
+---------------------------------------------------------------+
| .. module:: GetRefinType                                      |
|                                                               |
| **GetRefinType()**                                            |
|     Returns the type of the refinement                        |
|                                                               |
|         * 0: unactive                                         |
|         * 1: active                                           |
+---------------------------------------------------------------+
| .. module:: GetUnRefType                                      |
|                                                               |
| **GetUnRefType()**                                            |
|     Returns the type of the unrefinement                      |
|                                                               |
|         * 0: unactive                                         |
|         * 1: active                                           |
+---------------------------------------------------------------+
| .. module:: Delete                                            |
|                                                               |
| **Delete()**                                                  |
|     Deletes the hypothesis                                    |
|                                                               |
|     Returns an integer:                                       |
|         * 0: the destruction is done                          |
|         * other value: problem                                |
+---------------------------------------------------------------+

Uniform adaptation
==================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetUnifRefinUnRef                                 |
|                                                               |
| **SetUnifRefinUnRef(RefinUnRef)**                             |
|     Defines a type of adaptation for the whole mesh           |
|                                                               |
|     - ``RefinUnRef``: integer that defines the                |
|       type of adaptation                                      |
|                                                               |
|         * 1: refinement                                       |
|         * -1: unrefinement                                    |
+---------------------------------------------------------------+

Adaptation by a field
=====================

The driving field and the thresholds
------------------------------------

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetField                                          |
|                                                               |
| **SetField(FieldName)**                                       |
|     Gives the name of a driving field to the hypothesis       |
|                                                               |
|     - ``FieldName``: the name of the driving field            |
+---------------------------------------------------------------+
| .. module:: GetFieldName                                      |
|                                                               |
| **GetFieldName()**                                            |
|     Returns the name of the driving field                     |
+---------------------------------------------------------------+
| .. module:: SetUseField                                       |
|                                                               |
| **SetUseField(use_field)**                                    |
|     Gives the usage of the driving field                      |
|                                                               |
|     - ``use_field``: integer that defines how the driving     |
|       field is used                                           |
|                                                               |
|        * 0: value by element (default)                        |
|        * 1: jump between an element and its neighbours        |
+---------------------------------------------------------------+
| .. module:: SetRefinThr                                       |
|                                                               |
| **SetRefinThr(type_thres, threshold)**                        |
|     Defines the thresholds for the refinement                 |
|                                                               |
|     - ``type_thres``: integer that defines the type of the    |
|       threshold for the refinement                            |
|                                                               |
|        * 1: absolute value                                    |
|        * 2: relative value in %                               |
|        * 3: ratio of elements in %                            |
|        * 4: mean + n times the standard deviation             |
|                                                               |
|     - ``threshold``: numerical value that defines the         |
|       threshold                                               |
+---------------------------------------------------------------+
| .. module:: GetRefinThrType                                   |
|                                                               |
| **GetRefinThrType()**                                         |
|     Returns the type of the threshold for the refinement      |
+---------------------------------------------------------------+
| .. module:: SetUnRefThr                                       |
|                                                               |
| **SetUnRefThr(type_thres, threshold)**                        |
|     Defines the thresholds for the unrefinement               |
|                                                               |
|     - ``type_thres``: integer that defines the type of the    |
|       threshold for the unrefinement                          |
|                                                               |
|        * 1: absolute value                                    |
|        * 2: relative value in %                               |
|        * 3: ratio of elements in %                            |
|        * 4: mean - n times the standard deviation             |
|                                                               |
|     - ``threshold``: numerical value that defines the         |
|       threshold                                               |
+---------------------------------------------------------------+
| .. module:: GetUnRefThrType                                   |
|                                                               |
| **GetUnRefThrType()**                                         |
|     Returns the type of the threshold for the unrefinement    |
+---------------------------------------------------------------+


The components of the driving field
-----------------------------------

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: AddComp                                           |
|                                                               |
| **AddComp(comp_name)**                                        |
|     Add a component of the field                              |
|                                                               |
|     - ``comp_name``: name of a component to take into account |
|                                                               |
|     Note: if this method is not used, every component         |
|     of the field is taken into account.                       |
+---------------------------------------------------------------+
| .. module:: SetUseComp                                        |
|                                                               |
| **SetUseComp(use_comp)**                                      |
|     Defines hom to use the components                         |
|                                                               |
|     - ``use_comp``: integer that defines how to use the       |
|       components                                              |
|                                                               |
|        * 0: L2 norm (default)                                 |
|        * 1: infinite norm                                     |
|        * 2: relative value, if only one component             |
+---------------------------------------------------------------+
| .. module:: GetComps                                          |
|                                                               |
| **GetComps()**                                                |
|     Returns the list of the used components                   |
+---------------------------------------------------------------+
| .. module:: SupprComp                                         |
|                                                               |
| **SupprComp(comp_name)**                                      |
|     Eliminates a component of the field                       |
|                                                               |
|     - ``comp_name``: name of a component to eliminate         |
+---------------------------------------------------------------+
| .. module:: SupprComps                                        |
|                                                               |
| **SupprComps()**                                              |
|     Eliminates all the components of the field                |
+---------------------------------------------------------------+


Adaptation by zones
===================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: AddZone                                           |
|                                                               |
| **AddZone(zone_name, type_use)**                              |
|                                                               |
|     - ``zone_name``: the name of the zone to add              |
|     - ``type_use``: integer that defines how to use the zone  |
|                                                               |
|         * 1: refinement                                       |
|         * -1: unrefinement                                    |
+---------------------------------------------------------------+
| .. module:: GetZones                                          |
|                                                               |
| **GetZones()**                                                |
|     Returns the list of the used zones with their uses        |
|                                                               |
|     Warning: the use is stored as a string in the list and    |
|     not as an integer.                                        |
|                                                               |
|     Example: ['Zone_A', '1', 'Zone_B', '1', 'Zone_C', '1']    |
+---------------------------------------------------------------+
| .. module:: SupprZone                                         |
|                                                               |
| **SupprZone(zone_name)**                                      |
|     Eliminates a zone from the hypothesis                     |
|                                                               |
|     - ``zone_name``: name of a zone to eliminate              |
+---------------------------------------------------------------+
| .. module:: SupprZones                                        |
|                                                               |
| **SupprZones()**                                              |
|     Eliminates all the zones from the hypothesis              |
+---------------------------------------------------------------+


The filtering by the groups
===========================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: AddGroup                                          |
|                                                               |
| **AddGroup(group_name)**                                      |
|     Add a group to the filtering                              |
|                                                               |
|     - ``group_name``: name of the group to take into account  |
+---------------------------------------------------------------+
| .. module:: GetGroups                                         |
|                                                               |
| **GetGroups()**                                               |
|     Returns the mist of the groups that are used in the       |
|     filtering                                                 |
+---------------------------------------------------------------+

Interpolation of fields
=======================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetTypeFieldInterp                                |
|                                                               |
| **SetTypeFieldInterp(typefieldinterp)**                       |
|                                                               |
|     - ``typefieldinterp``: integer that defines if some fields|
|       are interpolated or not                                 |
|                                                               |
|         * 0: no field (default)                               |
|         * 1: every field is interpolated                      |
|         * 2: some fields are interpolated; automatically set  |
|           after using AddFieldInterp or AddFieldInterpType    |
+---------------------------------------------------------------+
| .. module:: GetTypeFieldInterp                                |
|                                                               |
| **GetTypeFieldInterp()**                                      |
|     Returns the integer that defines if some fields are       |
|     interpolated or not                                       |
+---------------------------------------------------------------+
| .. module:: AddFieldInterp                                    |
|                                                               |
| **AddFieldInterp(FieldName)**                                 |
|                                                               |
|     - ``FieldName``: the name of the field to interpolate     |
|                                                               |
|     The interpolation type is automatically deduced by        |
|     HOMARD; it corresponds to the type 0 of AddFieldInterpType|
+---------------------------------------------------------------+
| .. module:: AddFieldInterpType                                |
|                                                               |
| **AddFieldInterpType(FieldName, type_interp)**                |
|                                                               |
|     - ``FieldName``: the name of the field to interpolate     |
|     - ``type_interp``: integer that defines the type of       |
|       interpolation                                           |
|                                                               |
|     For a field over the nodes:                               |
|                                                               |
|         * 0: the field will be interpolated in degree 1 or 2  |
|           depending on its baseframe.                         |
|         * 1: interpolation en degree 1                        |
|         * 2: interpolation en degree 2                        |
|         * 3: interpolation iso-P2                             |
|                                                               |
|     For a field over the elements:                            |
|                                                               |
|         * 0: the field will be interpolated as an intensive   |
|           variable                                            |
|         * 1: the field will be interpolated as an extensive   |
|           variable                                            |
+---------------------------------------------------------------+
| .. module:: GetFieldInterps                                   |
|                                                               |
| **GetFieldInterps()**                                         |
|     Returns the list of the interpolated fields with their use|
|                                                               |
|     Warning: the use is stored as a string in the list and    |
|     not as an integer.                                        |
|                                                               |
|     Example: ['DEPL', '0', 'Mass', '1', 'Density', '0']       |
+---------------------------------------------------------------+
| .. module:: SupprFieldInterp                                  |
|                                                               |
| **SupprFieldInterp(FieldName)**                               |
|     Eliminates a field from the hypothesis                    |
|                                                               |
|     - ``FieldName``: name of a field to eliminate             |
+---------------------------------------------------------------+
| .. module:: SupprFieldInterps                                 |
|                                                               |
| **SupprFieldInterps()**                                       |
|     Eliminates all the fields from the hypothesis             |
+---------------------------------------------------------------+

.. note::
  The file and the time steps for the fiels are defined with the iteration; see :doc:`tui_create_iteration`.

Advanced options
================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetNivMax                                         |
|                                                               |
| **SetNivMax(nivmax)**                                         |
|     Defines the maximum level for the refinement              |
|                                                               |
|     - ``nivmax``: level of refinement that must not be        |
|       exceeded                                                |
+---------------------------------------------------------------+
| .. module:: GetNivMax                                         |
|                                                               |
| **GetNivMax()**                                               |
|     Returns the maximum level for the refinement              |
+---------------------------------------------------------------+
| .. module:: SetDiamMin                                        |
|                                                               |
| **SetDiamMin(diammin)**                                       |
|     Defines the minimum diameter of the future elements       |
|                                                               |
|     - ``diammin``: minimum diameter for an element            |
+---------------------------------------------------------------+
| .. module:: GetDiamMin                                        |
|                                                               |
| **GetDiamMin()**                                              |
|     Returns the minimum diameter of the future elements       |
+---------------------------------------------------------------+
| .. module:: SetAdapInit                                       |
|                                                               |
| **SetAdapInit(option)**                                       |
|     Defines the treatment of the elements where the field that|
|     governs the adaptation is not defined                     |
|                                                               |
|     - ``option``: integer as follows:                         |
|                                                               |
|         *  0: no effect (default)                             |
|         *  1: the elements without field are refined          |
|         * -1: the elements without field are unrefined        |
+---------------------------------------------------------------+
| .. module:: GetAdapInit                                       |
|                                                               |
| **GetAdapInit()**                                             |
|     Returns the treatment of the elements where the field that|
|     governs the adaptation is not defined                     |
+---------------------------------------------------------------+
| .. module:: SetExtraOutput                                    |
|                                                               |
| **SetExtraOutput(option)**                                    |
|     Acts if some extra information are required into the      |
|     output MED file. The option is a product of               |
|     2, 3, 5, 7, 11.                                           |
|                                                               |
|     - ``option``: integer as follows:                         |
|                                                               |
|         *  1 : no effect (default)                            |
|         *  2x : the refinement level of every mesh is produced|
|         *  3x : the quality of every mesh                     |
|         *  5x : the diameter of every mesh                    |
|         *  7x : common parent of every mesh                   |
|         * 11x : neighbours of glued cells                     |
+---------------------------------------------------------------+
| .. module:: GetExtraOutput                                    |
|                                                               |
| **GetExtraOutput()**                                          |
|     Returns the choice for the output of extra information    |
+---------------------------------------------------------------+


Example
*******
The creation of the object hypo_1 is done as follows:
::

    hypo_1 = homard.CreateHypothesis("HypoField")
    hypo_1.SetField("INDICATEUR")
    hypo_1.AddComp("INDX")
    hypo_1.AddComp("INDZ")
    hypo_1.SetRefinThr(1, 80.)
    hypo_1.AddFieldInterp("DEPL")
    hypo_1.AddFieldInterpType("MASS", 1)


Similar graphical input
***********************
Look at :doc:`gui_create_hypothese`

.. warning::
  With the graphical input mode, if a hypothesis is edited and if one of the characteristic is modified, the value of the threshold for the refinement for example, all the iterations that were computed with this hypothesis are unvalidated. In python mode, that is not true: the iterations stay as they are.
