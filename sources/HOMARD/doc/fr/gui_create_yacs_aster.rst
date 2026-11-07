.. _gui_create_yacs_aster:

Un schéma YACS pour Code_Aster
##############################
.. index:: single: YACS
.. index:: single: Code_Aster

Dans le cas où le schéma implique un couplage entre *Code_Aster* et HOMARD, une façon de faire est décrite ici. Les seules contraintes sont des conventions pour que le script de pilotage de *Code_Aster* fonctionne correctement au sein du schéma.

Préparations
************
Le répertoire de calcul
=======================
La première phase consiste à créer un répertoire qui abritera les fichiers du calcul et les fichiers des maillages successifs.

Les commandes
=============
Les commandes du calcul sont à définir comme pour n'importe quel calcul. On particularisera uniquement la récupération de la valeur de test pour la convergence.

La valeur de test
-----------------
Pour récupérer la valeur de test ``V_TEST``, le script va chercher dans le fichier ``resu``, la ligne de type :
::

    V_TEST    0.02071983

Pour cela, la meilleure façon consiste à placer la valeur à tester dans une table intitulée ``V_TEST``, par exemple après une extraction depuis un résultat :

.. literalinclude:: ../files/yacs_aster_01.comm
   :language: python
   :lines: 53-59

puis à imprimer cette table en se limitant aux deux paramètres ``INTITULE`` et composante retenue :

.. literalinclude:: ../files/yacs_aster_01.comm
   :language: python
   :lines: 63-64

Le pilotage de l'adaptation
---------------------------
Si on souhaite piloter l'adaptation par un champ, il faudra écrire ce champ dans le fichier MED de sortie. Ce peut être un indicateur d'erreur (commande CALC_ERREUR) ou un autre champ.

Par exemple :

.. literalinclude:: ../files/yacs_aster_01.comm
   :language: python
   :lines: 68-78

Le script
=========
Le script de pilotage de *Code_Aster* à fournir au schéma YACS est à télécharger ici : :download:`ScriptAster<../files/yacs_script.py>`. Ce fichier peut être placé n'importe où.

Comment procéder ?
******************
Un premier calcul
=================
Une fois les commandes au point, il faut lancer un premier calcul. Cela permet de choisir le paramétrage du calcul : version de *Code_Aster*, serveur de calcul, interactif/batch, etc. Ce sont ces paramètres qui seront utilisés pour les calculs successifs dans le schéma. Le lancement de *Code_Aster* rassemble ces informations dans un fichier de type ``export``. Il faut copier ce fichier sous le nom ``calcul.ref.export`` dans le répertoire de calcul.

Création du schéma
==================
Quand le calcul est terminé, il faut enchaîner les étapes suivante :

- vérifier que le fichier de résultats au format MED a été créé et que le fichier de résultats de type ``resu`` contient la ligne donnant la valeur à tester ;
- activer le module HOMARD de SALOME ;
- créer un cas à partir du maillage initial ;
- créer une itération en se basant sur le champ que l'on a retenu ;
- éventuellement calculer cette itération pour contrôler les choix, mais ce n'est pas obligatoire ;
- créer le schéma basé sur ce cas.

Lancer le schéma
================
Le schéma est écrit dans le fichier ``schema.xml`` dans le répertoire lié au cas qui en est le support. Ce fichier peut être déplacé sans problème. On peut modifier les paramètres de contrôle par défaut de la boucle de l'alternance (calcul/adaptation).

On active alors le module YACS, on importe le schéma et on l'exécute.






