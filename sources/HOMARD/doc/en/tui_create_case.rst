.. _tui_create_case:

The case
########
.. index:: single: cas
.. index:: single: type of conformity
.. index:: single: mesh;initial

The variables are described in :doc:`gui_create_case`.

Methods of the class homard
***************************

Creation of a case
==================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: CreateCase                                        |
|                                                               |
| **CreateCase(case_name, mesh_name, mesh_file)**               |
|     Returns an instance of the class ``cas`` after its        |
|     creation                                                  |
|                                                               |
|     - ``case_name``: the name of the case                     |
|     - ``mesh_name``: the name of the initial mesh             |
|     - ``mesh_file``: the name of the MED file of this mesh    |
|                                                               |
| Default:                                                      |
|                                                               |
|  * the directory for the results is ``/tmp``                  |
|  * the adaptation is conformal                                |
+---------------------------------------------------------------+
| .. module:: GetCase                                           |
|                                                               |
| **GetCase(case_name)**                                        |
|     Returns an instance of the class ``cas`` known by its name|
|                                                               |
|     - ``case_name``: the name of the case                     |
+---------------------------------------------------------------+
| .. module:: GetAllCasesName                                   |
|                                                               |
| **GetAllCasesName()**                                         |
|     Returns the liste of the name of all the existing cases   |
|                                                               |
+---------------------------------------------------------------+

Creation of a case by pursuit of a computed iteration
=====================================================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: CreateCaseFromIteration                           |
|                                                               |
| **CreateCaseFromIteration(case_name, dir_name)**              |
|     Returns an instance of the class ``cas`` after its        |
|     creation                                                  |
|                                                               |
|     - ``case_name``: the name of the case                     |
|     - ``dir_name``: the name of the directory that contains   |
|       the iteration                                           |
|                                                               |
+---------------------------------------------------------------+
| .. module:: CreateCaseFromCaseLastIteration                   |
|                                                               |
| **CreateCaseFromCaseLastIteration(case_name, dir_name)**      |
|     Returns an instance of the class ``cas`` after its        |
|     creation                                                  |
|                                                               |
|     - ``case_name``: the name of the case                     |
|     - ``dir_name``: the name of the directory that contains   |
|       the case                                                |
|                                                               |
+---------------------------------------------------------------+
| .. module:: CreateCaseFromCaseIteration                       |
|                                                               |
| **CreateCaseFromCaseIteration(case_name, dir_name, number)**  |
|     Returns an instance of the class ``cas`` after its        |
|     creation                                                  |
|                                                               |
|     - ``case_name``: the name of the case                     |
|     - ``dir_name``: the name of the directory that contains   |
|       the case                                                |
|     - ``number``: the number of the iteration of the case     |
|                                                               |
+---------------------------------------------------------------+



Methods of the class cas
************************
.. index:: single: YACS

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetName                                           |
|                                                               |
| **GetName()**                                                 |
|     Returns the name of the case                              |
+---------------------------------------------------------------+
| .. module:: SetDirName                                        |
|                                                               |
| **SetDirName(dirname)**                                       |
|     Gives a directory for the results of the case. It can be  |
|     done only after the creation of the case and before the   |
|     first computation.                                        |
|                                                               |
|     - ``dirname``: the name of the directory of the results   |
+---------------------------------------------------------------+
| .. module:: GetDirName                                        |
|                                                               |
| **GetDirName()**                                              |
|     Returns the name of the directory of the results of the   |
|     case                                                      |
+---------------------------------------------------------------+
| .. module:: SetConfType                                       |
|                                                               |
| **SetConfType(conf_type)**                                    |
|     Defines the type of conformity for the case               |
|                                                               |
|     - ``conf_type``: integer as follows:                      |
|                                                               |
|         * 0: conformal (default)                              |
|         * 1: non conformal with at max 2 cut edges per element|
|         * 2: non conformal with one hanging node per edge of  |
|           element                                             |
|         * 3: non conformal without any constraint             |
|         * -1: conformal with boxes (no staircases)            |
|         * -2: non-conformal with boxes (no staircases)        |
+---------------------------------------------------------------+
| .. module:: GetConfType                                       |
|                                                               |
| **GetConfType()**                                             |
|     Returns the type of conformity                            |
+---------------------------------------------------------------+
| .. module:: SetExtType                                        |
|                                                               |
| **SetExtType(ext_type)**                                      |
|     Defines the external type for the case                    |
|                                                               |
|     - ``ext_type`` : integer as follows:                      |
|                                                               |
|         * 0 : Standard MED (default)                          |
|         * 1 : Saturne MED                                     |
|         * 2 : Saturne 2D MED                                  |
+---------------------------------------------------------------+
| .. module:: GetExtType                                        |
|                                                               |
| **GetExtType()**                                              |
|     Returns the external type for the case                    |
+---------------------------------------------------------------+
| .. module:: GetIter0                                          |
|                                                               |
| **GetIter0()**                                                |
|     Returns the iteration linked to the initial mesh.         |
|     This iteration is automatically created by the module     |
|     HOMARD. It is used to connect the iterations. It is       |
|     connected to an initial mesh or to the iteration of a     |
|     previous case.                                            |
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
|     Add a boundary to the definition of a case                |
|                                                               |
|     - ``boundary``: name of the curved boundary               |
|                                                               |
|     Discrete boundary:                                        |
|                                                               |
|     . if all the curved lines are involved, the second        |
|     argument is an empty string.                              |
|     . if only some curved lines are involved, ``group`` is    |
|     the name of the group of segments                         |
|                                                               |
|     Analytical boundary:                                      |
|                                                               |
|     - ``group``: name of the group of faces located on the    |
|       boundary                                                |
+---------------------------------------------------------------+
| .. module:: Delete                                            |
|                                                               |
| **Delete(option)**                                            |
|     Deletes the case and all the connected iterations. The MED|
|     file of the first mesh is kept.                           |
|                                                               |
|     - ``option``: an integer to define what to do with the    |
|       MED file of the associated meshes                       |
|                                                               |
|         * 0: the files are kept                               |
|         * 1: the files are removed                            |
|                                                               |
|     Returns an integer:                                       |
|         * 0: the destruction is done                          |
|         * other value: problem                                |
+---------------------------------------------------------------+
| .. module:: GetState                                          |
|                                                               |
| **GetState()**                                                |
|     Returns the state of the case:                            |
|         * 0: corresponds to an initial mesh                   |
|         * other value: pursuit of an iteration with number n  |
+---------------------------------------------------------------+
| .. module:: WriteYACSSchema                                   |
|                                                               |
| **WriteYACSSchema(ScriptFile, DirName, MeshFile)**            |
|     Writes a schema YACS relative to the case.                |
|                                                               |
|     - ``ScriptFile`` : name of the file that contains the     |
|       script to launch the computation                        |
|     - ``DirName`` : the directory for the computation         |
|     - ``MeshFile`` : name of the file that contains the mesh  |
|       for the very first computation                          |
+---------------------------------------------------------------+

Advanced options
****************

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetPyram                                          |
|                                                               |
| **SetPyram(option)**                                          |
|     Defines the status of the pyramids in this case           |
|                                                               |
|     - ``option``: integer that defines the status of the      |
|       pyramids that could belongs to the initial mesh         |
|                                                               |
|         * 0: rejected pyramids (default)                      |
|         * 1: authorized pyramids                              |
+---------------------------------------------------------------+
| .. module:: GetPyram                                          |
|                                                               |
| **GetPyram()**                                                |
|     Returns the status of the pyramids in this case           |
+---------------------------------------------------------------+

Informations for the initial mesh
*********************************

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: MeshInfo                                          |
|                                                               |
| **MeshInfo(Qual, Diam, Conn, Tail, Inte)**                    |
|     Gives information about the current mesh. For every       |
|     option, the choice #0 corresponds to 'no action', while   |
|     the choice #1 launches the option.                        |
|                                                               |
|     - ``Qual``: quality of the elements                       |
|     - ``Diam``: diametre of the elements                      |
|     - ``Conn``: connexity of the domain; a single block, how  |
|       many holes, etc.                                        |
|     - ``Tail``: size of the parts of the domain, group by     |
|       group                                                   |
|     - ``Inte``: staggered elements, by dimension              |
+---------------------------------------------------------------+


Example
*******
The creation of the object case_1 is done as follows:

::

    case_name = "CAS_1"
    mesh_name = "MAILL"
    mesh_file = "/scratch/Salome/Adapt/m0.med"
    case_1 = homard.CreateCase(case_name, mesh_name, mesh_file)
    dirname = "/scratch/Salome/Adapt/resu"
    case_1.SetDirName(dirname)
    case_1.SetConfType(1)
    case_1.AddBoundaryGroup( 'intersection', '' )
    case_1.AddBoundaryGroup( 'cyl_1', 'T1_EXT' )
    case_1.AddBoundaryGroup( 'cyl_1', 'T2_EXT' )
    case_1.AddBoundaryGroup( 'cyl_2', 'T_INT' )



Similar graphical input
***********************
Look at :doc:`gui_create_case`


