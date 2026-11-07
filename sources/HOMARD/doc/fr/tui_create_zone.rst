.. _tui_create_zone:

La zone
#######

.. index:: single: zone
.. index:: single: boite
.. index:: single: sphere
.. index:: single: cylindre
.. index:: single: tuyau
.. index:: single: disque
.. index:: single: disque avec trou
.. index:: single: 2D

Les variables sont décrites dans :doc:`gui_create_zone`.

Méthodes de la classe homard
****************************

Ces méthodes retournent une instance de la classe zone.

+----------------------------------------------------------------------------------+
+----------------------------------------------------------------------------------+
| .. module:: CreateZoneBox                                                        |
|                                                                                  |
| **CreateZoneBox(zone_name, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax)**                 |
|     Retourne une instance de la classe ``zone`` de type parallélépipèdique       |
|     après sa création                                                            |
|                                                                                  |
|     - ``zone_name`` : le nom de la zone basée sur un parallélépipède             |
|     - ``Xmin``, ``Xmax`` : coordonnées extrêmes selon X                          |
|     - ``Ymin``, ``Ymax`` : coordonnées extrêmes selon Y                          |
|     - ``Zmin``, ``Zmax`` : coordonnées extrêmes selon Z                          |
+----------------------------------------------------------------------------------+
| .. module:: CreateZoneCylinder                                                   |
|                                                                                  |
| **CreateZoneCylinder(zone_name, Xbase, Ybase, Zbase, Xaxe, Yaxe, Zaxe, R, H)**   |
|     Retourne une instance de la classe ``zone`` de type cylindrique              |
|     après sa création                                                            |
|                                                                                  |
|     - ``zone_name`` : le nom de la zone basée sur un cylindre                    |
|     - ``Xbase``, ``Ybase``, ``Zbase`` : coordonnées d'un point de base           |
|       positionné sur l'axe                                                       |
|     - ``Xaxe``, ``Yaxe``, ``Zaxe`` : vecteur de l'axe                            |
|     - ``R`` : rayon du cylindre                                                  |
|     - ``H`` : hauteur du cylindre                                                |
+----------------------------------------------------------------------------------+
| .. module:: CreateZonePipe                                                       |
|                                                                                  |
| **CreateZonePipe(zone_name, Xbase, Ybase, Zbase, Xaxe, Yaxe, Zaxe, R, H, Rint)** |
|     Retourne une instance de la classe ``zone`` de type tuyau                    |
|     après sa création                                                            |
|                                                                                  |
|     - ``zone_name`` : le nom de la zone basée sur un tuyau                       |
|     - ``Xbase``, ``Ybase``, ``Zbase`` : coordonnées d'un point de base           |
|       positionné sur l'axe                                                       |
|     - ``Xaxe``, ``Yaxe``, ``Zaxe`` : vecteur de l'axe                            |
|     - ``R`` : rayon externe du tuyau                                             |
|     - ``H`` : hauteur du tuyau                                                   |
|     - ``R`` : rayon interne du tuyau                                             |
+----------------------------------------------------------------------------------+
| .. module:: CreateZoneSphere                                                     |
|                                                                                  |
| **CreateZoneSphere(zone_name, Xcen, Ycen, Zcen, R)**                             |
|     Retourne une instance de la classe ``zone`` de type sphérique                |
|     après sa création                                                            |
|                                                                                  |
|     - ``zone_name`` : le nom de la zone basée sur une sphère                     |
|     - ``Xcen``, ``Ycen``, ``Zcen`` : coordonnées du centre de la sphère          |
|     - ``R`` : rayon de la sphère                                                 |
+----------------------------------------------------------------------------------+
| .. module:: CreateZoneBox2D                                                      |
|                                                                                  |
| **CreateZoneBox2D(zone_name, Umin, Umax, Vmin, Vmax, Orient)**                   |
|     Retourne une instance de la classe ``zone`` de type rectangulaire            |
|     après sa création                                                            |
|                                                                                  |
|     - ``zone_name`` : le nom de la zone basée sur un rectangle                   |
|     - ``Umin``, ``Umax`` : coordonnées extrêmes pour la 1ère dimension           |
|     - ``Vmin``, ``Vmax`` : coordonnées extrêmes pour la 2nde dimension           |
|     - ``Orient`` : entier précisant la convention d'orientation du plan          |
+----------------------------------------------------------------------------------+
| .. module:: CreateZoneDisk                                                       |
|                                                                                  |
| **CreateZoneDisk(zone_name, Ucen, Vcen, R, Orient)**                             |
|     Retourne une instance de la classe ``zone`` de type disque                   |
|     après sa création                                                            |
|                                                                                  |
|     - ``zone_name`` : le nom de la zone basée sur un disque plein                |
|     - ``Ucen``, ``Vcen`` : coordonnées du centre du disque                       |
|     - ``R`` : rayon du disque                                                    |
|     - ``Orient`` : entier précisant la convention d'orientation du plan          |
+----------------------------------------------------------------------------------+
| .. module:: CreateZoneDiskWithHole                                               |
|                                                                                  |
| **CreateZoneDiskWithHole(zone_name, Ucen, Vcen, R, Rint, Orient)**               |
|     Retourne une instance de la classe ``zone`` de type disque troué             |
|     après sa création                                                            |
|                                                                                  |
|     - ``zone_name`` : le nom de la zone basée sur un disque troué                |
|     - ``Ucen``, ``Vcen`` : coordonnées du centre du disque                       |
|     - ``R`` : rayon externe du disque                                            |
|     - ``Rint`` : rayon interne du disque                                         |
|     - ``Orient`` : entier précisant la convention d'orientation du plan          |
+----------------------------------------------------------------------------------+



+---------------------------------------------------------------+
+---------------------------------------------------------------+
|   La convention d'orientation du plan est la même que celle   |
|   appliquée dans les autres modules de SALOME, en particulier |
|   GEOM :                                                      |
|                                                               |
|     1. plan XY ; U <==> X et V <==> Y                         |
|     2. plan YZ ; U <==> Y et V <==> Z                         |
|     3. plan ZX ; U <==> Z et V <==> X                         |
+---------------------------------------------------------------+


.. note::
  Les fonctions définissant des zones 2D ne doivent être utilisées que si l'intégralité du
  maillage est 2D, dans un des plans de coordonnées.


+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetZone                                           |
|                                                               |
| **GetZone(zone_name)**                                        |
|     Retourne l'instance de la classe ``zone`` connue par      |
|     son nom                                                   |
|                                                               |
|     - ``zone_name`` : le nom de la zone                       |
+---------------------------------------------------------------+
| .. module:: GetAllZonesName                                   |
|                                                               |
| **GetAllZonesName()**                                         |
|     Retourne la liste des noms de toutes les zones créées     |
|                                                               |
+---------------------------------------------------------------+


Méthodes de la classe zone
**************************

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetName                                           |
|                                                               |
| **GetName()**                                                 |
|     Retourne le nom de la zone                                |
+---------------------------------------------------------------+
| .. module:: GetType                                           |
|                                                               |
| **GetType()**                                                 |
|     Retourne le type de la zone                               |
|                                                               |
|         * 2 : parallélépipède                                 |
|         * 3 : sphère                                          |
|         * 5 : cylindre                                        |
|         * 7 : tuyau                                           |
|         * 11, 12, 13 : rectangle et orientation 1, 2 ou 3     |
|         * 31, 32, 33 : disque et orientation 1, 2 ou 3        |
|         * 61, 62, 63 : disque percé et orientation 1, 2 ou 3  |
+---------------------------------------------------------------+
| .. module:: GetCoords                                         |
|                                                               |
| **GetCoords()**                                               |
|     Retourne un tableau contenant les coordonnées de la zone  |
|     dans l'ordre d'entrée dans le CreateZoneXXXX associé      |
+---------------------------------------------------------------+
| .. module:: Delete                                            |
|                                                               |
| **Delete()**                                                  |
|     Detruit la zone                                           |
|                                                               |
|     Retourne un entier :                                      |
|         * 0 : destruction réussie                             |
|         * autre valeur : problème                             |
+---------------------------------------------------------------+


Exemple
*******
La création d'une boîte 3D se fait ainsi :
::

    zone_1 = homard.CreateZoneBox ("BLOC", -1., 1., -30., 40., 10.5, 20.8)


La création d'un disque dans le plan XY se fait ainsi :
::

    zone_2 = homard.CreateZoneDisk ("disque", 1., 3., 43.25, 1)


Saisie graphique correspondante
*******************************
Consulter :doc:`gui_create_zone`

.. warning::
  En mode graphique, si on édite une zone et que l'on modifie une des dimensions, toutes les itérations qui ont été calculées précédemment avec cette zone sont invalidées. En mode python, cela n'est plus vrai : les itérations restent telles quelles.



