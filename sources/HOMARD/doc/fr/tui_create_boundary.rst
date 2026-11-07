.. _tui_create_boundary:

La frontière
############

.. index:: single: boundary
.. index:: single: frontière
.. index:: single: cylindre
.. index:: single: sphere

Les variables sont décrites dans :doc:`gui_create_boundary`.

Méthodes de la classe homard
****************************
Ces méthodes retournent une instance de la classe boundary.

+----------------------------------------------------------------------------------------+
+----------------------------------------------------------------------------------------+
| .. module:: CreateBoundaryCAO                                                          |
|                                                                                        |
| **CreateBoundaryCAO(boundary_name, xao_file)**                                         |
|     Retourne une instance de la classe ``boundary`` de type CAO après sa création      |
|                                                                                        |
|     - ``boundary_name`` : le nom de la frontière CAO                                   |
|     - ``xao_file`` : le nom du fichier contenant cette CAO, au format XAO              |
+----------------------------------------------------------------------------------------+
| .. module:: CreateBoundaryDi                                                           |
|                                                                                        |
| **CreateBoundaryDi(boundary_name, mesh_name, mesh_file)**                              |
|     Retourne une instance de la classe ``boundary`` de type discret après sa création  |
|                                                                                        |
|     - ``boundary_name`` : le nom de la frontière discrète                              |
|     - ``mesh_name`` : le nom du maillage de la frontière                               |
|     - ``mesh_file`` : le nom du fichier contenant ce maillage, au format MED           |
+----------------------------------------------------------------------------------------+
| .. module:: CreateBoundaryCylinder                                                     |
|                                                                                        |
| **CreateBoundaryCylinder(boundary_name, Xcen, Ycen, Zcen, Xaxe, Yaxe, Zaxe, R)**       |
|     Retourne une instance de la classe ``boundary`` analytique de type cylindrique     |
|     après sa création                                                                  |
|                                                                                        |
|     - ``boundary_name`` : le nom de la frontière analytique basée sur un cylindre      |
|     - ``Xcen``, ``Ycen``, ``Zcen`` : coordonnées d'un point sur l'axe du cylindre      |
|     - ``Xaxe``, ``Yaxe``, ``Zaxe`` : vecteur de l'axe                                  |
|     - ``R`` : rayon du cylindre                                                        |
+----------------------------------------------------------------------------------------+
| .. module:: CreateBoundarySphere                                                       |
|                                                                                        |
| **CreateBoundarySphere(boundary_name, Xcen, Ycen, Zcen, R)**                           |
|     Retourne une instance de la classe ``boundary`` analytique de type sphérique       |
|     après sa création                                                                  |
|                                                                                        |
|     - ``boundary_name`` : le nom de la frontière analytique basée sur une sphere       |
|     - ``Xcen``, ``Ycen``, ``Zcen`` : coordonnées du centre de la sphère                |
|     - ``R`` : rayon de la sphère                                                       |
+----------------------------------------------------------------------------------------+
| .. module:: CreateBoundaryConeA                                                        |
|                                                                                        |
| **CreateBoundaryConeA(boundary_name, Xaxe, Yaxe, Zaxe, Angle, Xcen, Ycen, Zcen)**      |
|     Retourne une instance de la classe ``boundary`` analytique de type conique         |
|     après sa création                                                                  |
|                                                                                        |
|     - ``boundary_name`` : le nom de la frontière analytique basée sur un cône          |
|     - ``Xaxe``, ``Yaxe``, ``Zaxe`` : vecteur de l'axe (non nécessairement normé)       |
|     - ``Angle`` : angle d'ouverture du cône en degre (entre 0 et 90)                   |
|     - ``Xcen``, ``Ycen``, ``Zcen`` : coordonnées du centre du cône                     |
+----------------------------------------------------------------------------------------+
| .. module:: CreateBoundaryConeR                                                        |
|                                                                                        |
| **CreateBoundaryConeR(boundary_name, Xc1, Yc1, Zc1, R1, Xc2, Yc2, Zc2, R2)**           |
|     Retourne une instance de la classe ``boundary`` analytique de type conique         |
|     après sa création                                                                  |
|                                                                                        |
|     - ``boundary_name`` : le nom de la frontière analytique basée sur un cône          |
|     - ``Xc1``, ``Yc1``, ``Zc1`` : coordonnées du premier centre du cône                |
|     - ``R1`` : rayon du cône à la hauteur du premier centre                            |
|     - ``Xc2``, ``Yc2``, ``Zc2`` : coordonnées du second centre du cône                 |
|     - ``R2`` : rayon du cône à la hauteur du second centre                             |
+----------------------------------------------------------------------------------------+
| .. module:: CreateBoundaryTorus                                                        |
|                                                                                        |
| **CreateBoundaryTorus(boundary_name, Xcen, Ycen, Zcen, Xaxe, Yaxe, Zaxe, RRev, RPri)** |
|     Retourne une instance de la classe ``boundary`` analytique de type torique         |
|     après sa création                                                                  |
|                                                                                        |
|     - ``boundary_name`` : le nom de la frontière analytique basée sur un tore          |
|     - ``Xcen``, ``Ycen``, ``Zcen`` : coordonnées du centre du tore                     |
|     - ``Xaxe``, ``Yaxe``, ``Zaxe`` : vecteur de l'axe                                  |
|     - ``RRev`` : rayon de révolution du tore                                           |
|     - ``RPri`` : rayon primaire du tore                                                |
+----------------------------------------------------------------------------------------+

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetBoundary                                       |
|                                                               |
| **GetBoundary(boundary_name)**                                |
|     Retourne l'instance de la classe ``boundary`` connue par  |
|     son nom                                                   |
|                                                               |
|     - ``boundary_name`` : le nom de la frontière              |
+---------------------------------------------------------------+
| .. module:: GetAllBoundarysName                               |
|                                                               |
| **GetAllBoundarysName()**                                     |
|     Retourne la liste des noms de toutes les frontières       |
|     existantes                                                |
|                                                               |
+---------------------------------------------------------------+

Méthodes de la classe cas
*************************
Voir également dans :doc:`tui_create_case`.

+---------------------------------------------------------------+
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
|     Ajoute une frontière à la définition du cas en précisant  |
|     les groupes associés                                      |
|                                                               |
|     - ``boundary`` : nom d'une frontière courbe à suivre      |
|                                                               |
|     Pour une frontière discrète ou CAO :                      |
|                                                               |
|     - ``group`` : nom d'un groupe de mailles à suivre         |
|                                                               |
|     Pour une frontière analytique :                           |
|                                                               |
|     - ``group`` : nom d'un groupe de faces placées sur la     |
|       frontière                                               |
+---------------------------------------------------------------+

Méthodes de la classe boundary
******************************

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetName                                           |
|                                                               |
| **GetName()**                                                 |
|     Retourne le nom de la frontière                           |
+---------------------------------------------------------------+
| .. module:: GetType                                           |
|                                                               |
| **GetType()**                                                 |
|     Retourne le type de la frontière :                        |
|                                                               |
|         * -1 : CAO                                            |
|         * 0 : discrète                                        |
|         * 1 : cylindre                                        |
|         * 2 : sphère                                          |
|         * 3 : cône défini par un axe et un angle              |
|         * 4 : cône défini par deux rayons                     |
|         * 5 : tore                                            |
+---------------------------------------------------------------+
| .. module:: GetCoords                                         |
|                                                               |
| **GetCoords()**                                               |
|     Retourne un tableau contenant les coordonnées de la       |
|     frontière dans l'ordre d'entrée dans le CreateBoundaryXXXX|
|     associé                                                   |
+---------------------------------------------------------------+
| .. module:: Delete                                            |
|                                                               |
| **Delete()**                                                  |
|     Détruit la frontière.                                     |
|     Pour une frontière discrète, le fichier du maillage       |
|     associé est conservé.                                     |
|     Pour une frontière CAO, le fichier de la géométrie        |
|     associée est conservé.                                    |
|                                                               |
|     Retourne un entier :                                      |
|         * 0 : destruction réussie                             |
|         * autre valeur : problème                             |
+---------------------------------------------------------------+


Exemple
*******
Création d'une frontière CAO : ::

    la_cao = homard.CreateBoundaryCAO("BLOC", dircase+'/tutorial_6.xao')

Création d'une frontière discrète, d'une frontière sphérique, puis d'une frontière cylindrique : ::

    inter = homard.CreateBoundaryDi("INTERSECTION", 'PIQUAGE', dircase+'/tutorial_4.fr.med')
    fron_1 = homard.CreateBoundarySphere("FRON_1", 12.3, 3.4, .56, 6.5)
    fron_2 = homard.CreateBoundaryCylinder('CYL_1', 0.0, 25., -25., 25., 50., 75., 100.)


Saisie graphique correspondante
*******************************
Consulter :doc:`gui_create_boundary`
