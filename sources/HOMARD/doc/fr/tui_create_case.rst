.. _tui_create_case:

Le cas
######
.. index:: single: cas
.. index:: single: type de conformité
.. index:: single: maillage;initial

Les variables sont décrites dans :doc:`gui_create_case`.

Méthodes de la classe homard
****************************

Création d'un cas
=================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: CreateCase                                        |
|                                                               |
| **CreateCase(case_name, mesh_name, mesh_file)**               |
|     Retourne une instance de la classe ``cas`` après sa       |
|     création                                                  |
|                                                               |
|     - ``case_name`` : le nom du cas                           |
|     - ``mesh_name`` : le nom du maillage initial              |
|     - ``mesh_file`` : le nom du fichier MED contenant ce      |
|       ce maillage                                             |
|                                                               |
| Par défaut :                                                  |
|                                                               |
|  * le répertoire des résultats est ``/tmp``                   |
|  * l'adaptation est conforme                                  |
+---------------------------------------------------------------+
| .. module:: GetCase                                           |
|                                                               |
| **GetCase(case_name)**                                        |
|     Retourne l'instance de la classe ``cas`` connue par       |
|     son nom                                                   |
|                                                               |
|     - ``case_name`` : le nom du cas                           |
+---------------------------------------------------------------+
| .. module:: GetAllCasesName                                   |
|                                                               |
| **GetAllCasesName()**                                         |
|     Retourne la liste des noms de tous les cas existant       |
|                                                               |
+---------------------------------------------------------------+

Création d'un cas par poursuite d'une itération calculée
========================================================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: CreateCaseFromIteration                           |
|                                                               |
| **CreateCaseFromIteration(case_name, dir_name)**              |
|     Retourne une instance de la classe ``cas`` après sa       |
|     création                                                  |
|                                                               |
|     - ``case_name`` : le nom du cas                           |
|     - ``dir_name``  : le nom du répertoire contenant          |
|       l'itération à poursuivre                                |
|                                                               |
+---------------------------------------------------------------+
| .. module:: CreateCaseFromCaseLastIteration                   |
|                                                               |
| **CreateCaseFromCaseLastIteration(case_name, dir_name)**      |
|     Retourne une instance de la classe ``cas`` après sa       |
|     création                                                  |
|                                                               |
|     - ``case_name`` : le nom du cas                           |
|     - ``dir_name``  : le nom du répertoire contenant          |
|       le cas à poursuivre                                     |
|                                                               |
+---------------------------------------------------------------+
| .. module:: CreateCaseFromCaseIteration                       |
|                                                               |
| **CreateCaseFromCaseIteration(case_name, dir_name, number)**  |
|     Retourne une instance de la classe ``cas`` après sa       |
|     création                                                  |
|                                                               |
|     - ``case_name`` : le nom du cas                           |
|     - ``dir_name``  : le nom du répertoire contenant          |
|       le cas à poursuivre                                     |
|     - ``number`` : le numéro de l'itération du cas            |
|                                                               |
+---------------------------------------------------------------+



Méthodes de la classe cas
*************************
.. index:: single: YACS

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetName                                           |
|                                                               |
| **GetName()**                                                 |
|     Retourne le nom du cas                                    |
+---------------------------------------------------------------+
| .. module:: SetDirName                                        |
|                                                               |
| **SetDirName(dirname)**                                       |
|     Affecte le répertoire des résultats associé au cas. Cela  |
|     ne peut se faire qu'après la création du cas et avant le  |
|     premier calcul.                                           |
|                                                               |
|     - ``dirname`` : le nom du répertoire des résultats        |
+---------------------------------------------------------------+
| .. module:: GetDirName                                        |
|                                                               |
| **GetDirName()**                                              |
|     Retourne le nom du répertoire des résultats associé au cas|
+---------------------------------------------------------------+
| .. module:: SetConfType                                       |
|                                                               |
| **SetConfType(conf_type)**                                    |
|     Définit le mode de conformité associé au cas              |
|                                                               |
|     - ``conf_type`` : entier précisant le mode de conformité  |
|                                                               |
|         * 0 : conforme (défaut)                               |
|         * 1 : non conforme avec au minimum 2 aretes coupees   |
|         * 2 : non conforme avec 1 noeud par arete de maille   |
|         * 3 : non conforme quelconque                         |
|         * -1 : conforme avec des boites (pas d'escalier)      |
|         * -2 : non-conforme avec des boites (pas d'escalier)  |
+---------------------------------------------------------------+
| .. module:: GetConfType                                       |
|                                                               |
| **GetConfType()**                                             |
|     Retourne le type de conformité                            |
+---------------------------------------------------------------+
| .. module:: SetExtType                                        |
|                                                               |
| **SetExtType(ext_type)**                                      |
|     Définit le type externe associé au cas                    |
|                                                               |
|     - ``ext_type`` : entier précisant le type externe         |
|                                                               |
|         * 0 : MED standard (défaut)                           |
|         * 1 : Saturne MED                                     |
|         * 2 : Saturne 2D MED                                  |
+---------------------------------------------------------------+
| .. module:: GetExtType                                        |
|                                                               |
| **GetExtType()**                                              |
|     Retourne le type externe associé au cas                   |
+---------------------------------------------------------------+
| .. module:: GetIter0                                          |
|                                                               |
| **GetIter0()**                                                |
|     Retourne l'itération associée au maillage initial.        |
|     Cette itération est créée automatiquement par le module   |
|     HOMARD et est utilisée pour enchaîner les adaptations.    |
|     Elle correspond à un maillage initial ou à une itération  |
|     de poursuite d'un cas précédent.                          |
+---------------------------------------------------------------+
| .. module:: AddBoundary                                       |
|                                                               |
| **AddBoundary(boundary)**                                     |
|     Ajoute une frontière à la définition du cas               |
|                                                               |
|     - ``boundary`` : nom d'une frontière courbe à suivre      |
+---------------------------------------------------------------+
| .. module:: AddBoundaryGroup                                  |
|                                                               |
| **AddBoundaryGroup(boundary, group)**                         |
|     Ajoute une frontière à la définition du cas               |
|                                                               |
|     - ``boundary`` : nom d'une frontière courbe à suivre      |
|                                                               |
|     Pour une frontière discrète :                             |
|                                                               |
|     . si toutes les lignes courbes sont suivies, le second    |
|       argument est une chaîne vide.                           |
|     . si seulement certaines lignes courbes sont suivies,     |
|       ``group`` est le nom d'un groupe de segments à suivre.  |
|                                                               |
|     Pour une frontière analytique :                           |
|                                                               |
|     - ``group`` : nom d'un groupe de faces placées sur la     |
|       frontière                                               |
+---------------------------------------------------------------+
| .. module:: Delete                                            |
|                                                               |
| **Delete(option)**                                            |
|     Detruit le cas et toutes les itérations associées. Le     |
|     fichier du maillage initial associé est conservé.         |
|                                                               |
|     - ``option`` : un entier précisant ce qui est fait des    |
|       fichiers de maillage associés                           |
|                                                               |
|         * 0 : les fichiers sont conservés                     |
|         * 1 : les fichiers sont supprimés                     |
|                                                               |
|     Retourne un entier :                                      |
|         * 0 : destruction réussie                             |
|         * autre valeur : problème                             |
+---------------------------------------------------------------+
| .. module:: GetState                                          |
|                                                               |
| **GetState()**                                                |
|     Retourne l'état du cas :                                  |
|         * 0 : correspond à un maillage initial                |
|         * autre valeur : poursuite d'une itération de numéro n|
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

Les options avancées
====================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetPyram                                          |
|                                                               |
| **SetPyram(option)**                                          |
|     Définit le statut des pyramides pour le cas               |
|                                                               |
|     - ``option`` : entier précisant le statut des pyramides   |
|       éventuellement présentes dans le maillage initial       |
|                                                               |
|         * 0 : pyramides refusées (défaut)                     |
|         * 1 : pyramides autorisées                            |
+---------------------------------------------------------------+
| .. module:: GetPyram                                          |
|                                                               |
| **GetPyram()**                                                |
|     Retourne le statut accordé aux pyramides éventuellement   |
|     présentes dans le maillage initial                        |
+---------------------------------------------------------------+

Informations sur le maillage initial
====================================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: MeshInfo                                          |
|                                                               |
| **MeshInfo(Qual, Diam, Conn, Tail, Inte)**                    |
|     Donne des informations sur le maillage. Pour chaque       |
|     option, le choix 0 correspond à ne rien faire, alors que  |
|     le choix 1 active l'option.                               |
|                                                               |
|     - ``Qual`` : qualité des mailles                          |
|     - ``Diam`` : diamètre des mailles                         |
|     - ``Conn`` : connexité du domaine ; en un seul morceau,   |
|       combien de trous, etc.                                  |
|     - ``Tail`` : tailles des constituants du domaine, groupe  |
|       par groupe                                              |
|     - ``Inte`` : interpénétration des mailles, par dimension  |
+---------------------------------------------------------------+


Exemple
*******
La création de l'objet case_1 se fait ainsi : ::

    case_name = "CAS_1"
    mesh_name = "MAILL"
    mesh_file = "/home/A1789/Adapt/m0.med"
    case_1 = homard.CreateCase(case_name, mesh_name, mesh_file)
    dirname = "/home/A1789/Adapt/resu"
    case_1.SetDirName(dirname)
    case_1.SetConfType(1)
    case_1.SetExtType(0)
    case_1.AddBoundaryGroup( 'intersection', '' )
    case_1.AddBoundaryGroup( 'cyl_1', 'T1_EXT' )
    case_1.AddBoundaryGroup( 'cyl_1', 'T2_EXT' )
    case_1.AddBoundaryGroup( 'cyl_2', 'T_INT' )



Saisie graphique correspondante
*******************************
Consulter :doc:`gui_create_case`


