.. _tui_create_iteration:

L'itération
###########

.. index:: single: itération
.. index:: single: hypothèse
.. index:: single: zone

Les variables sont décrites dans :doc:`gui_create_iteration`.

Méthodes de la classe homard
****************************

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: GetIteration                                      |
|                                                               |
| **GetIteration(iter_name)**                                   |
|     Retourne l'instance de la classe ``iteration`` connue par |
|     son nom                                                   |
|                                                               |
|     - ``iter_name`` : le nom de l'itération                   |
+---------------------------------------------------------------+
| .. module:: GetAllIterationsName                              |
|                                                               |
| **GetAllIterationsName()**                                    |
|     Retourne la liste des noms de toutes les itérations créées|
|                                                               |
+---------------------------------------------------------------+

Méthodes communes aux classes cas et iteration
**********************************************
Voir également dans :doc:`tui_create_case`.

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: NextIteration                                     |
|                                                               |
| **NextIteration(iter_name)**                                  |
|     Retourne une instance de la classe ``iteration`` après    |
|     sa création. Elle suit immédiatement :                    |
|                                                               |
|     - pour un cas : l'itération initiale, correspondant au    |
|       maillage définissant le cas                             |
|     - pour une itération : l'itération courante               |
|                                                               |
| Par défaut, le maillage produit a le même nom que l'itération |
|                                                               |
|     - ``iter_name`` : le nom à donner à la nouvelle itération |
+---------------------------------------------------------------+
| .. module:: LastIteration                                     |
|                                                               |
| **LastIteration()**                                           |
|     Retourne une instance de la classe ``iteration``. C'est   |
|     la dernière créée dans la descendance de :                |
|                                                               |
|     - pour un cas : l'itération initiale du cas               |
|     - pour une itération : l'itération courante               |
|                                                               |
|     C'est celle qui est sans fille. Il y a erreur s'il existe |
|     plus d'une branche dans la descendance.                   |
|                                                               |
+---------------------------------------------------------------+

Méthodes de la classe iteration
*******************************

Généralités
===========

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: Compute                                           |
|                                                               |
| **Compute(option1, option2)**                                 |
|     Calcule le maillage correspondant à l'itération           |
|                                                               |
|     - ``option1`` : un entier précisant ce qui se passe quand |
|       des fichiers de résultats existent déjà                 |
|                                                               |
|         * 0 : arrêt en erreur                                 |
|         * 1 : écrasement des anciens fichiers                 |
|                                                               |
|     - ``option2`` : un entier précisant ce qui est fait des   |
|       résultats                                               |
|                                                               |
|         * 1 : aucune action particulière                      |
|         * 2 : publication dans le module SMESH                |
|                                                               |
|     Retourne un entier :                                      |
|         * 0 : adaptation réussie                              |
|         * autre valeur : problème                             |
+---------------------------------------------------------------+
| .. module:: GetName                                           |
|                                                               |
| **GetName()**                                                 |
|     Retourne le nom de l'itération                            |
+---------------------------------------------------------------+
| .. module:: GetNumber                                         |
|                                                               |
| **GetNumber()**                                               |
|     Retourne le numéro de l'itération.                        |
|                                                               |
|     L'itération 0 est celle associée au maillage initial.     |
|     Ensuite, une itération de numéro N est issue de           |
|     l'adaptation d'une itération de numéro N-1.               |
+---------------------------------------------------------------+
| .. module:: GetIterParent                                     |
|                                                               |
| **GetIterParent()**                                           |
|     Retourne l'itération mère                                 |
+---------------------------------------------------------------+
| .. module:: AssociateHypo                                     |
|                                                               |
| **AssociateHypo(hypo_name)**                                  |
|     Associe une hypothèse à l'itération                       |
|                                                               |
|     - ``hypo_name`` : le nom de l'hypothèse à associer        |
+---------------------------------------------------------------+
| .. module:: GetHypoName                                       |
|                                                               |
| **GetHypoName()**                                             |
|     Retourne le nom de l'hypothèse associée                   |
+---------------------------------------------------------------+
| .. module:: GetCaseName                                       |
|                                                               |
| **GetCaseName()**                                             |
|     Retourne le nom du cas associé                            |
+---------------------------------------------------------------+
| .. module:: GetState                                          |
|                                                               |
| **GetState()**                                                |
|     Retourne l'état de l'itération                            |
|                                                               |
|     - ``2`` : itération calculée correctement                 |
|     - ``1`` : itération non calculée                          |
|     - ``<=0`` : itération initiale à ne pas calculer, de      |
|       numéro valant la valeur absolue de l'état               |
+---------------------------------------------------------------+
| .. module:: GetLogFile                                        |
|                                                               |
| **GetLogFile()**                                              |
|     Retourne le nom du fichier retraçant le déroulement de    |
|     l'exécution de HOMARD                                     |
+---------------------------------------------------------------+
| .. module:: GetFileInfo                                       |
|                                                               |
| **GetFileInfo()**                                             |
|     Retourne le nom du fichier contenant l'analyse du maillage|
+---------------------------------------------------------------+
| .. module:: GetDirName                                        |
|                                                               |
| **GetDirName()**                                              |
|     Retourne le nom du répertoire des résultats associé à     |
|     l'itération                                               |
+---------------------------------------------------------------+
| .. module:: Delete                                            |
|                                                               |
| **Delete(option)**                                            |
|     Detruit l'itération et toutes ses filles éventuelles.     |
|                                                               |
|     - ``option`` : un entier précisant ce qui est fait des    |
|       fichiers de maillage associés                           |
|                                                               |
|         * 0 : les fichiers sont conservés                     |
|         * 1 : les fichiers sont détruits                      |
|                                                               |
|     Retourne un entier :                                      |
|         * 0 : destruction réussie                             |
|         * autre valeur : problème                             |
+---------------------------------------------------------------+

Informations sur les maillages
==============================

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetMeshName                                       |
|                                                               |
| **SetMeshName(mesh_name)**                                    |
|     Définit le nom du maillage produit                        |
|                                                               |
|     - ``mesh_name`` : le nom du maillage produit              |
+---------------------------------------------------------------+
| .. module:: GetMeshName                                       |
|                                                               |
| **GetMeshName()**                                             |
|     Retourne le nom du maillage produit                       |
+---------------------------------------------------------------+
| .. module:: SetMeshFile                                       |
|                                                               |
| **SetMeshFile(mesh_file)**                                    |
|     Définit le fichier MED du maillage produit                |
|                                                               |
|     - ``mesh_file`` : le nom du fichier MED qui contiendra    |
|       le maillage produit                                     |
+---------------------------------------------------------------+
| .. module:: GetMeshFile                                       |
|                                                               |
| **GetMeshFile()**                                             |
|     Retourne le nom du fichier MED du maillage produit        |
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

Informations sur les champs
===========================

Le fichier des champs
---------------------

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetFieldFile                                      |
|                                                               |
| **SetFieldFile(field_file)**                                  |
|     Définit le fichier MED des champs utiles                  |
|                                                               |
|     - ``field_file`` : le nom du fichier MED contenant les    |
|       champs : champ de pilotage de l'adaptation ou champs    |
|       à interpoler                                            |
+---------------------------------------------------------------+
| .. module:: GetFieldFileName                                  |
|                                                               |
| **GetFieldFileName()**                                        |
|     Retourne le nom du fichier MED des champs                 |
+---------------------------------------------------------------+

Les instants pour le champ de pilotage
--------------------------------------
Si une seule occurence du champ de pilotage de l'adaptation est présente dans le fichier des champs, il est inutile de préciser le pas de temps. Sinon, il faut préciser quel pas de temps est retenu.

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetTimeStep                                       |
|                                                               |
| **SetTimeStep(TimeStep)**                                     |
|     Définit l'instant pour le champ de pilotage. Le numéro    |
|     d'ordre sera ignoré.                                      |
|                                                               |
|     - ``TimeStep`` : l'instant où est pris le champ           |
+---------------------------------------------------------------+
| .. module:: SetTimeStepRank                                   |
|                                                               |
| **SetTimeStepRank(TimeStep, Rank)**                           |
|     Définit l'instant et le numéro d'ordre pour le champ de   |
|     pilotage                                                  |
|                                                               |
|     - ``TimeStep`` : l'instant où est pris le champ           |
|     - ``Rank`` : le numéro d'ordre où est pris le champ       |
+---------------------------------------------------------------+
| .. module:: SetTimeStepRankLast                               |
|                                                               |
| **SetTimeStepRankLast()**                                     |
|     Précise que le dernier instant enregistré pour le champ   |
|     de pilotage est utilisé                                   |
+---------------------------------------------------------------+
| .. module:: GetTimeStep                                       |
|                                                               |
| **GetTimeStep()**                                             |
|     Retourne l'instant où est pris le champ de pilotage       |
+---------------------------------------------------------------+
| .. module:: GetRank                                           |
|                                                               |
| **GetRank()**                                                 |
|     Retourne le numéro d'ordre où est pris le champ de        |
|     pilotage                                                  |
+---------------------------------------------------------------+

Les instants pour les champs à interpoler
-----------------------------------------

Les champs à interpoler sont définis dans l'hypothèse (voir :doc:`tui_create_hypothese`).
Pour un champ donné, si aucune mention de pas de temps n'est précisé, tous les pas de temps seront pris en compte.
Si on souhaite limiter l'interpolation à un ou plusieurs pas de temps, il faut le préciser ici.

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetFieldInterpTimeStep                            |
|                                                               |
| **SetFieldInterpTimeStep(FieldName, TimeStep)**               |
|     Définit un instant pour le champ à interpoler. Le numéro  |
|     d'ordre sera ignoré.                                      |
|                                                               |
|     - ``FieldName`` : le nom du champ à interpoler            |
|     - ``TimeStep`` : l'instant où est pris le champ           |
+---------------------------------------------------------------+
| .. module:: SetFieldInterpTimeStepRank                        |
|                                                               |
| **SetFieldInterpTimeStepRank(FieldName, TimeStep)**           |
|     Définit l'instant et le numéro d'ordre pour le champ à    |
|     interpoler.                                               |
|                                                               |
|     - ``FieldName`` : le nom du champ à interpoler            |
|     - ``TimeStep`` : l'instant où est pris le champ           |
|     - ``Rank`` : le numéro d'ordre où est pris le champ       |
+---------------------------------------------------------------+
| .. module:: GetFieldInterpsTimeStepRank                       |
|                                                               |
| **GetFieldInterpsTimeStepRank()**                             |
|     Retourne l'ensemble des triplets (nom du champ, pas de    |
|     temps, numéro d'ordre)                                    |
|                                                               |
|     Attention : l'usage est stocké sous forme de chaîne de    |
|     caractères et non pas d'entier dans la liste.             |
|                                                               |
|     Exemple : ['DEPL', '1', '1', 'DEPL', '2', '1', 'Masse',   |
|     '2', '0', 'Masse', '3', '0']                              |
+---------------------------------------------------------------+

Divers
======

+---------------------------------------------------------------+
+---------------------------------------------------------------+
| .. module:: SetInfoCompute                                    |
|                                                               |
| **SetInfoCompute(MessInfo)**                                  |
|     Précise des options d'informations sur le déroulement du  |
|     calcul de l'itération                                     |
|                                                               |
|     - ``MessInfo`` : entier pilotant des écritures, sous la   |
|       forme d'un entier multiple de 2, 3 et 5                 |
|                                                               |
|         * 1 : aucune écriture (défaut)                        |
|         * 2x : temps de calcul                                |
|         * 3x : fichiers MED                                   |
|         * 5x : mémoire                                        |
+---------------------------------------------------------------+
| .. module:: GetInfoCompute                                    |
|                                                               |
| **GetInfoCompute()**                                          |
|     Retourne les options d'informations sur le déroulement du |
|     calcul de l'itération                                     |
+---------------------------------------------------------------+


Exemple
*******
.. index:: single: maillage;initial

Pour la création de la première itération, on part de celle qui correspond au maillage initial. C'est celle contenue dans le cas.
::

    iter_name = "Iteration_1"
    iter_1 = case_1.NextIteration(iter_name)
    iter_1.SetField(field_file)
    iter_1.SetTimeStepRank( 0, 0)
    iter_1.SetMeshName("maill_01")
    iter_1.SetMeshFile("/local00/M.01.med")
    iter_1.AssociateHypo("HypoField")
    codret = iter_1.Compute(1, 2)

Ensuite, on crée une itération suivante à l'itération parent de laquelle on part.
::

    iter_name = "Iteration_2"
    iter_2 = iter_1.NextIteration(iter_name)
    iter_2.SetField(field_file)
    iter_2.SetTimeStepRank( 1, 1)
    iter_2.SetMeshName("maill_02")
    iter_2.SetMeshFile("/local00/M.02.med")
    iter_2.AssociateHypo("HypoField")
    codret = iter_2.Compute(1, 2)


Saisie graphique correspondante
*******************************
Consulter :doc:`gui_create_iteration`
