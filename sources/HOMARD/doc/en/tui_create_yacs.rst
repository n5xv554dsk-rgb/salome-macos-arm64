.. _tui_create_yacs:

The schema YACS
###############

.. index:: single: YACS

The variables are described in :doc:`gui_create_yacs`.

Méthodes de la classe cas
*************************
See also in :doc:`tui_create_case`.

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: CreateYACSSchema                                  |
|                                                               |
| **CreateYACSSchema(yacs_name, ScriptFile, DirName, MeshFile)**|
|     Returns an instance of the class ``yacs``, after its      |
|     creation                                                  |
|                                                               |
|     - ``yacs_name`` : the name of the schema                  |
|     - ``ScriptFile`` : the file of the python script that     |
|       drives the computation, coupled with the mesh adaptation|
|     - ``DirName`` : the directory for the computation         |
|     - ``MeshFile`` : the MED file that contains the very first|
|       mesh for the computation                                |
+---------------------------------------------------------------+

Methodes of the class homard
****************************

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetYACS                                           |
|                                                               |
| **GetYACS(yacs_name)**                                        |
|     Returns the instance of the class classe ``yacs``         |
|     known by its name                                         |
|                                                               |
|     - ``yacs_name`` : the name of the schema                  |
+---------------------------------------------------------------+
| .. module:: GetAllYACSsName                                   |
|                                                               |
| **GetAllYACSsName()**                                         |
|     Returns the list of the names of all the existing         |
|     schemas                                                   |
+---------------------------------------------------------------+



Methodes of the class YACS
**************************

General methods
===============

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: Write                                             |
|                                                               |
| **Write()**                                                   |
|     Writes the schema into the file ``schema.xml``, in the    |
|     directory of the case                                     |
|     Writes the schema into the file of the schema             |
|     By default, it is the file ``schema.xml``, in the         |
|     directory of the case. If ``WriteOnFile`` was used before |
|     the writings are into this new file.                      |
|                                                               |
|     Returns an integer:                                       |
|         * 0: the writing is done                              |
|         * other value: problem                                |
+---------------------------------------------------------------+
| .. module:: WriteOnFile                                       |
|                                                               |
| **WriteOnFile(file_xml)**                                     |
|     Writes the schema into a specified file.                  |
|                                                               |
|     - ``file_xml`` : name of the xml file for the schema      |
|                                                               |
|     Returns an integer:                                       |
|         * 0: the writing is done                              |
|         * other value: problem                                |
+---------------------------------------------------------------+
| .. module:: Delete                                            |
|                                                               |
| **Delete(option)**                                            |
|     Deletes the schema                                        |
|                                                               |
|     - ``option``: an integer to define what to do with the    |
|       xml file of the schema                                  |
|                                                               |
|         * 0: the files is kept                                |
|         * 1: the files is removed                             |
|                                                               |
|     Returns an integer:                                       |
|         * 0: the destruction is done                          |
|         * other value: problem                                |
+---------------------------------------------------------------+


Informations about the schema
=============================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetName                                           |
|                                                               |
| **GetName()**                                                 |
|     Returns the name of the schema                            |
+---------------------------------------------------------------+
| .. module:: SetType                                           |
|                                                               |
| **SetType(Type)**                                             |
|     Defines the type of the schema.                           |
|                                                               |
|     - ``Type`` : the type of the schema                       |
|                                                               |
|         * 1 : constant                                        |
|         * 2 : variable                                        |
+---------------------------------------------------------------+
| .. module:: GetType                                           |
|                                                               |
| **GetType()**                                                 |
|     Returns the type of the schema                            |
+---------------------------------------------------------------+
| .. module:: SetScriptFile                                     |
|                                                               |
| **SetScriptFile(script_file)**                                |
|     Defines the file of the script python that launches the   |
|     computation                                               |
|                                                               |
|     - ``script_file`` : the name of the file that contains    |
|       the script python                                       |
+---------------------------------------------------------------+
| .. module:: GetScriptFile                                     |
|                                                               |
| **GetScriptFile()**                                           |
|     Returns the name of the file that contains the script     |
|     python                                                    |
+---------------------------------------------------------------+
| .. module:: SetDirName                                        |
|                                                               |
| **SetDirName(dir_name)**                                      |
|     Defines the name of the directory for the computation     |
|                                                               |
|     - ``dir_name`` : the name of the directory for the        |
|       computation                                             |
+---------------------------------------------------------------+
| .. module:: GetDirName                                        |
|                                                               |
| **GetDirName()**                                              |
|     Returns the name of the directory for the computation     |
+---------------------------------------------------------------+
| .. module:: SetMeshFile                                       |
|                                                               |
| **SetMeshFile(mesh_file)**                                    |
|     Defines the MED file of the very first mesh               |
|                                                               |
|     - ``mesh_file`` : the name of the MED file that contains  |
|       the very first mesh for the computation                 |
+---------------------------------------------------------------+
| .. module:: GetMeshFile                                       |
|                                                               |
| **GetMeshFile()**                                             |
|     Returns the name of the MED file of the very first mesh   |
|     for the computation                                       |
+---------------------------------------------------------------+
| .. module:: SetXMLFile                                        |
|                                                               |
| **SetXMLFile(xml_file)**                                      |
|     Defines the xml file                                      |
|                                                               |
|     - ``mesh_file`` : the name of the xml file                |
+---------------------------------------------------------------+
| .. module:: GetXMLFile                                        |
|                                                               |
| **GetXMLFile()**                                              |
|     Returns the name of the xml file                          |
+---------------------------------------------------------------+


The options of the schema
=========================
The default values are defined by the preferences of the module HOMARD.

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetMaxIter                                        |
|                                                               |
| **SetMaxIter(MaxIter)**                                       |
|     Defines the maximal number of iterations for the schema.  |
|                                                               |
|     - ``MaxIter`` : the maximal number of iterations of the   |
|       schema                                                  |
+---------------------------------------------------------------+
| .. module:: GetMaxIter                                        |
|                                                               |
| **GetMaxIter()**                                              |
|     Returns the maximal number of iterations of the schema    |
+---------------------------------------------------------------+
| .. module:: SetMaxNode                                        |
|                                                               |
| **SetMaxNode(MaxNode)**                                       |
|     Defines the maximal number of nodes for the adaptation.   |
|                                                               |
|     - ``MaxNode`` : the maximal number of nodes for the       |
|       adaptation. If MaxNode equals 0, no limit.              |
+---------------------------------------------------------------+
| .. module:: GetMaxNode                                        |
|                                                               |
| **GetMaxNode()**                                              |
|     Returns the maximal number of nodes for the adaptation    |
+---------------------------------------------------------------+
| .. module:: SetMaxElem                                        |
|                                                               |
| **SetMaxElem(MaxElem)**                                       |
|     Defines the maximal number of meshes for the adaptation.  |
|                                                               |
|     - ``MaxElem`` : the maximal number of meshes for the      |
|       adaptation. If MaxElem equals 0, no limit.              |
+---------------------------------------------------------------+
| .. module:: GetMaxElem                                        |
|                                                               |
| **GetMaxElem()**                                              |
|     Returns the maximal number of meshes for the adaptation   |
+---------------------------------------------------------------+
| .. module:: SetTestConvergence                                |
|                                                               |
| **SetTestConvergence(Type, VRef)**                            |
|     Defines a convergence test for the schema.                |
|                                                               |
|     - ``Type`` : the type of convergence of the schema.       |
|                                                               |
|         * 0 : no test                                         |
|         * 1 : if the test value is greater than VRef          |
|         * 2 : if the test value is lower than VRef            |
|                                                               |
|     - ``VRef`` : the reference value for the test             |
+---------------------------------------------------------------+
| .. module:: GetTestConvergenceType                            |
|                                                               |
| **GetTestConvergenceType()**                                  |
|     Returns the type of convergence of the schema.            |
+---------------------------------------------------------------+
| .. module:: GetTestConvergenceVRef                            |
|                                                               |
| **GetTestConvergenceVRef()**                                  |
|     Returns the reference value for the test.                 |
+---------------------------------------------------------------+


Example
*******
The creation of a schema is done as follows:
::

    ScriptFile = "/scratch/D68518/Salome/HOMARD_SALOME/HOMARD_SRC/doc/files/ScriptAster.py"
    DirName = "/scratch/D68518/computation"
    MeshFile = "/scratch/D68518/computation/maill.00.med"
    YACS_0 = Case.CreateYACSSchema("YACS_0", ScriptFile, DirName, MeshFile)
    YACS_0.SetMaxIter(4)

It can be writen down in a file :
::

    YACSFile = "/scratch/D68518/computation/yacs.xml"
    codret = YACS_0.WriteOnFile(YACSFile)

Similar graphical input
***********************
Look at :doc:`gui_create_yacs`



