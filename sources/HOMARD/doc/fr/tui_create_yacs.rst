.. _tui_create_yacs:

Le schéma YACS
##############

.. index:: single: YACS

Les variables sont décrites dans :doc:`gui_create_yacs`.

Méthodes de la classe cas
*************************
Voir également dans :doc:`tui_create_case`.

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: CreateYACSSchema                                  |
|                                                               |
| **CreateYACSSchema(yacs_name, ScriptFile, DirName, MeshFile)**|
|     Retourne une instance de la classe ``yacs`` après sa      |
|     création                                                  |
|                                                               |
|     - ``yacs_name`` : le nom du schéma                        |
|     - ``ScriptFile`` : le fichier du script python qui permet |
|       de lancer le calcul à coupler avec l'adaptation de      |
|       maillage                                                |
|     - ``DirName`` : le répertoire où a lieu le calcul         |
|     - ``MeshFile`` : le fichier MED contenant le tout premier |
|       maillage de calcul                                      |
+---------------------------------------------------------------+

Méthodes de la classe homard
****************************

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetYACS                                           |
|                                                               |
| **GetYACS(yacs_name)**                                        |
|     Retourne l'instance de la classe ``yacs`` connue par      |
|     son nom                                                   |
|                                                               |
|     - ``yacs_name`` : le nom du schéma                        |
+---------------------------------------------------------------+
| .. module:: GetAllYACSsName                                   |
|                                                               |
| **GetAllYACSsName()**                                         |
|     Retourne la liste des noms de tous les schémas existant   |
+---------------------------------------------------------------+



Méthodes de la classe YACS
**************************

Généralités
===========

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: Write                                             |
|                                                               |
| **Write()**                                                   |
|     Ecrit le schéma dans le fichier lié au schéma             |
|     Par défaut, c'est le fichier ``schema.xml``, dans le      |
|     répertoire du cas. Si ``WriteOnFile`` a été utilisé       |
|     auparavant, l'écriture a lieu dans le nouveau fichier.    |
|                                                               |
|     Retourne un entier :                                      |
|         * 0 : écriture réussie                                |
|         * autre valeur : problème                             |
+---------------------------------------------------------------+
| .. module:: WriteOnFile                                       |
|                                                               |
| **WriteOnFile(file_xml)**                                     |
|     Ecrit le schéma dans un fichier désigné.                  |
|                                                               |
|     - ``file_xml`` : nom du fichier xml du schéma             |
|                                                               |
|     Retourne un entier :                                      |
|         * 0 : écriture réussie                                |
|         * autre valeur : problème                             |
+---------------------------------------------------------------+
| .. module:: Delete                                            |
|                                                               |
| **Delete(option)**                                            |
|     Detruit le schéma.                                        |
|                                                               |
|     - ``option`` : un entier précisant ce qui est fait du     |
|       fichier xml du schéma                                   |
|                                                               |
|         * 0 : le fichier est conservé                         |
|         * 1 : le fichier est détruit                          |
|                                                               |
|     Retourne un entier :                                      |
|         * 0 : destruction réussie                             |
|         * autre valeur : problème                             |
+---------------------------------------------------------------+


Informations sur le schéma
==========================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetName                                           |
|                                                               |
| **GetName()**                                                 |
|     Retourne le nom du schéma.                                |
+---------------------------------------------------------------+
| .. module:: SetType                                           |
|                                                               |
| **SetType(Type)**                                             |
|     Définit le type de schéma.                                |
|                                                               |
|     - ``Type`` : le type de schéma                            |
|                                                               |
|         * 1 : constant                                        |
|         * 2 : variable                                        |
+---------------------------------------------------------------+
| .. module:: GetType                                           |
|                                                               |
| **GetType()**                                                 |
|     Retourne le type du schéma.                               |
+---------------------------------------------------------------+
| .. module:: SetScriptFile                                     |
|                                                               |
| **SetScriptFile(script_file)**                                |
|     Définit le fichier du script python de lancement du       |
|     calcul.                                                   |
|                                                               |
|     - ``script_file`` : le nom du fichier qui contient le     |
|       le script python                                        |
+---------------------------------------------------------------+
| .. module:: GetScriptFile                                     |
|                                                               |
| **GetScriptFile()**                                           |
|     Retourne le nom du fichier MED qui contient le script     |
|     python.                                                   |
+---------------------------------------------------------------+
| .. module:: SetDirName                                        |
|                                                               |
| **SetDirName(dir_name)**                                      |
|     Définit le nom du répertoire de calcul.                   |
|                                                               |
|     - ``dir_name`` : le nom du répertoire de calcul           |
+---------------------------------------------------------------+
| .. module:: GetDirName                                        |
|                                                               |
| **GetDirName()**                                              |
|     Retourne le nom du répertoire de calcul.                  |
+---------------------------------------------------------------+
| .. module:: SetMeshFile                                       |
|                                                               |
| **SetMeshFile(mesh_file)**                                    |
|     Définit le fichier MED du tout premier maillage.          |
|                                                               |
|     - ``mesh_file`` : le nom du fichier MED contenant le tout |
|       premier maillage de calcul                              |
+---------------------------------------------------------------+
| .. module:: GetMeshFile                                       |
|                                                               |
| **GetMeshFile()**                                             |
|     Retourne le nom du fichier MED du tout premier maillage   |
|     de calcul.                                                |
+---------------------------------------------------------------+
| .. module:: SetXMLFile                                        |
|                                                               |
| **SetXMLFile(xml_file)**                                      |
|     Définit le fichier xml pour l'écriture.                   |
|                                                               |
|     - ``xml_file`` : le nom du fichier xml                    |
+---------------------------------------------------------------+
| .. module:: GetXMLFile                                        |
|                                                               |
| **GetXMLFile()**                                              |
|     Retourne le nom du fichier xml.                           |
+---------------------------------------------------------------+


Les options du schéma
=====================
Les valeurs par défaut sont définies dans les préférences du module HOMARD.

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetMaxIter                                        |
|                                                               |
| **SetMaxIter(MaxIter)**                                       |
|     Définit le nombre maximal d'itérations pour le schéma.    |
|                                                               |
|     - ``MaxIter`` : le nombre maximal d'itérations du schéma  |
+---------------------------------------------------------------+
| .. module:: GetMaxIter                                        |
|                                                               |
| **GetMaxIter()**                                              |
|     Retourne le nombre maximal d'itérations du schéma.        |
+---------------------------------------------------------------+
| .. module:: SetMaxNode                                        |
|                                                               |
| **SetMaxNode(MaxNode)**                                       |
|     Définit le nombre maximal de noeuds pour l'adaptation.    |
|                                                               |
|     - ``MaxNode`` : le nombre maximal de noeuds pour          |
|       l'adaptation. Si MaxNode est nul, aucune limite n'est   |
|       imposée.                                                |
+---------------------------------------------------------------+
| .. module:: GetMaxNode                                        |
|                                                               |
| **GetMaxNode()**                                              |
|     Retourne le nombre maximal de noeuds pour l'adaptation.   |
+---------------------------------------------------------------+
| .. module:: SetMaxElem                                        |
|                                                               |
| **SetMaxElem(MaxElem)**                                       |
|     Définit le nombre maximal de mailles pour l'adaptation.   |
|                                                               |
|     - ``MaxElem`` : le nombre maximal de mailles pour         |
|       l'adaptation. Si MaxElem est nul, aucune limite n'est   |
|       imposée.                                                |
+---------------------------------------------------------------+
| .. module:: GetMaxElem                                        |
|                                                               |
| **GetMaxElem()**                                              |
|     Retourne le nombre maximal de mailles pour l'adaptation.  |
+---------------------------------------------------------------+
| .. module:: SetTestConvergence                                |
|                                                               |
| **SetTestConvergence(Type, VRef)**                            |
|     Précise un test de convergence pour le schéma.            |
|                                                               |
|     - ``Type`` : le type de convergence du schéma.            |
|                                                               |
|         * 0 : aucun test                                      |
|         * 1 : quand la valeur de test est supérieure à VRef   |
|         * 2 : quand la valeur de test est inférieure à VRef   |
|                                                               |
|     - ``VRef`` : la valeur de référence du test               |
+---------------------------------------------------------------+
| .. module:: GetTestConvergenceType                            |
|                                                               |
| **GetTestConvergenceType()**                                  |
|     Retourne le type de convergence du schéma.                |
+---------------------------------------------------------------+
| .. module:: GetTestConvergenceVRef                            |
|                                                               |
| **GetTestConvergenceVRef()**                                  |
|     Retourne la valeur de référence utilisée pour le test de  |
|     convergence du schéma.                                    |
+---------------------------------------------------------------+


Exemple
*******
La création d'un schéma se fait ainsi :
::

    ScriptFile = "/scratch/D68518/Salome/HOMARD_SALOME/HOMARD_SRC/doc/files/ScriptAster.py"
    DirName = "/scratch/D68518/calcul"
    MeshFile = "/scratch/D68518/calcul/maill.00.med"
    YACS_0 = Case.CreateYACSSchema("YACS_0", ScriptFile, DirName, MeshFile)
    YACS_0.SetMaxIter(4)

On peut ensuite l'écrire dans un fichier :
::

    YACSFile = "/scratch/D68518/calcul/yacs.xml"
    codret = YACS_0.WriteOnFile(YACSFile)

Saisie graphique correspondante
*******************************
Consulter :doc:`gui_create_yacs`



