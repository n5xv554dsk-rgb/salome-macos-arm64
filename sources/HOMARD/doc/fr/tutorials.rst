Exemples
########
.. index:: single: exemple
.. index:: single: python

On trouvera ici les instructions python pour quelques configurations caractéristiques. Les fichiers de données associés sont téléchargeables. Il faut penser à adapter la valeur de la variable ``data_dir`` : c'est le répertoire dans lequel les fichiers med auront été enregistrés.
C'est dans le répertoire ``dircase`` que seront écrits les fichiers résultant des adaptations successives. Ce répertoire est créé par défaut dans ``/tmp``.

Chargement du module HOMARD
***************************
.. index:: single: YACS

Le chargement du module HOMARD se fait de manière analogue aux autres modules.

 ::

  import HOMARD
  homard = salome.lcc.FindOrLoadComponent('FactoryServer','HOMARD')
  homard.UpdateStudy()

Pour utiliser le module HOMARD au sein d'un schéma YACS distribué, le chargement se fait ainsi :

 ::

  import HOMARD
  my_container.load_component_Library('HOMARD')
  homard = my_container.create_component_instance('HOMARD',0)
  homard.UpdateStudy()

Raffinement uniforme
********************
.. index:: single: raffinement;uniforme

On fera ici trois raffinements uniformes successifs du maillage contenu dans le fichier ``tutorial_1.00.med``. Quelques remarques :
  * la même hypothèse est utilisée à chaque itération
  * le maillage produit porte toujours le même nom. Cela ne pose pas de problème car il est stocké dans des fichiers différents.

.. literalinclude:: ../files/tutorial_1.py
   :language: python
   :start-after: Début des commandes
   :end-before: Fin des commandes

.. note::
  Téléchargement des fichiers

  * :download:`maillage initial<../files/tutorial_1.00.med>`
  * :download:`commandes python<../files/tutorial_1.py>`
  * :download:`commandes python de l'utilitaire de création du répertoire de test<../files/tutorial_util.py>`


Raffinement par des zones
*************************
.. index:: single: zone

On procède ici au raffinement selon des zones. Pour passer du maillage initial au maillage 'M_1', on utilise une boîte encadrant le plan z=1 et une sphère centrée sur l'origine de rayon 1.05. Puis pour passer du maillage 'M_1' au maillage 'M_2', on remplace la sphère par une boîte encadrant le cube de côté 0.5, pointant sur l'origine et on déraffine les mailles contenues dans la toute première zone.

.. literalinclude:: ../files/tutorial_2.py
   :language: python
   :start-after: Début des commandes
   :end-before: Fin des commandes

.. note::
  Téléchargement des fichiers

  * :download:`maillage initial<../files/tutorial_2.00.med>`
  * :download:`commandes python<../files/tutorial_2.py>`
  * :download:`commandes python de l'utilitaire de création du répertoire de test<../files/tutorial_util.py>`


Raffinement selon un champ
**************************
.. index:: single: champ

On procède ici au raffinement selon un champ. Les hypothèses servent à définir le nom du champ et les seuils de raffinement/déraffinement. La donnée du fichier et des instants est faite dans l'itération. Des champs sur les noeuds ou sur les mailles sont interpolés.
Pour adapter le maillage H_1 issu de l'itération Iter_1, deux variantes sont appliquées. Dans la première, Iter_2, le champ est un champ scalaire d'indicateurs d'erreur et on découpe les 1.5% de mailles où l'erreur est la plus grande. Dans la seconde variante, Iter_2_bis, on se base sur un champ vectoriel et on examine le saut de ce vecteur entre une maille et ses voisines : on découpera là où la norme infinie de ce saut est supérieure au seuil absolu de 0.0001.

.. literalinclude:: ../files/tutorial_3.py
   :language: python
   :start-after: Début des commandes
   :end-before: Fin des commandes

.. note::
  Téléchargement des fichiers

  * :download:`maillage et champ étape 0<../files/tutorial_3.00.med>`
  * :download:`maillage et champ étape 1<../files/tutorial_3.01.med>`
  * :download:`commandes python<../files/tutorial_3.py>`
  * :download:`commandes python de l'utilitaire de création du répertoire de test<../files/tutorial_util.py>`


Suivi de frontières courbes
***************************
.. index:: single: frontière
.. index:: single: CAO
.. index:: single: YACS

On teste ici le suivi des frontières courbes en fournissant la géométrie représentée par la CAO de la pièce. Cette CAO est fournie dans un fichier au format XAO.
Le pilotage du raffinement est le suivant : raffinement uniforme de toutes les mailles contenues dans des groupes désignés. On commence par raffiner les faces internes aux tuyaux ; ensuite, on raffine deux fois de suite les faces externes aux tuyaux.
Le schéma YACS réalisant cette adaptation est téléchargeable.

.. literalinclude:: ../files/tutorial_4.py
   :language: python
   :start-after: Début des commandes
   :end-before: Fin des commandes

.. note::
  Téléchargement des fichiers

  * :download:`maillage initial<../files/tutorial_4.00.med>`
  * :download:`la frontière en CAO<../files/tutorial_4.xao>`
  * :download:`commandes python<../files/tutorial_4.py>`
  * :download:`commandes python de l'utilitaire de création du répertoire de test<../files/tutorial_util.py>`
  * :download:`schéma YACS<../files/tutorial_4.xml>`

Si la géométrie sous forme de CAO n'est pas disponible, on peut l'approcher ainsi :
des frontières analytiques pour décrire les différentes surfaces des tuyaux et une frontière discrète pour décrire les lignes d'intersection des deux tuyaux. Il suffit de remplacer la définition des frontières.

.. literalinclude:: ../files/tutorial_6.py
   :language: python
   :start-after: Début des commandes
   :end-before: Fin des commandes

.. note::
  Téléchargement des fichiers

  * :download:`maillage initial<../files/tutorial_4.00.med>`
  * :download:`maillage de la frontière discrète<../files/tutorial_6.fr.med>`
  * :download:`commandes python<../files/tutorial_6.py>`
  * :download:`commandes python de l'utilitaire de création du répertoire de test<../files/tutorial_util.py>`
  * :download:`schéma YACS<../files/tutorial_6.xml>`


Instructions spécifiques au 2D
******************************
.. index:: single: 2D

Les instructions pour adapter un maillage 2D sont exactement identiques à celles nécessaires à l'adaptation d'un maillage 3D. La seule exception concerne le raffinement selon des zones géométriques : des fonctions différentes sont utilisées pour pouvoir définir des zones 2D. On donne alors les coordonnées 2D des zones, en précisant l'orientation du plan du maillage.
Dans le cas présenté ici, on raffine une première fois toutes les mailles contenues dans un disque percé, puis dans une seconde itération, toutes les mailles contenues dans un rectangle. On notera l'utilisation du suivi des frontières circulaires du domaine.

.. literalinclude:: ../files/tutorial_5.py
   :language: python
   :start-after: Début des commandes
   :end-before: Fin des commandes

.. note::
  Téléchargement des fichiers

  * :download:`maillage initial<../files/tutorial_5.00.med>`
  * :download:`maillage de la frontière discrète<../files/tutorial_5.fr.med>`
  * :download:`commandes python<../files/tutorial_5.py>`
  * :download:`commandes python de l'utilitaire de création du répertoire de test<../files/tutorial_util.py>`


.. toctree::
   :maxdepth: 2

