.. _divers:

Divers
######

Références
**********
.. index:: single: référence

Pour une référence à HOMARD, utiliser :

G. Nicolas, T. Fouquet, S. Geniaut, S. Cuvilliez, Improved Adaptive Mesh Refinement for Conformal Hexahedral Meshes, "*Advances in Engineering Software*", Vol. 102, pp. 14-28, 2016, doi:10.1016/j.advengsoft.2016.07.014

`Accessible en cliquant ici <http://dx.doi.org/10.1016/j.advengsoft.2016.07.014>`_

G. Nicolas and T. Fouquet, Adaptive Mesh Refinement for Conformal Hexahedral Meshes, "*Finite Elements in Analysis and Design*", Vol. 67, pp. 1-12, 2013, doi:10.1016/j.finel.2012.11.008

`Accessible en cliquant ici <http://dx.doi.org/10.1016/j.finel.2012.11.008>`_

D'autres références sont disponibles sur le site de `HOMARD <http://www.code-aster.org/outils/homard/fr/divers.html>`_

Evolutions du module
********************
.. index:: single: évolution

On trouvera ici les principales évolutions de HOMARD à partir de la première version livrée dans SALOME 6.5.

SALOME VERSION 6.6 :
    - Interfaçage avec med 3.0.6
    - Valeurs par défaut des instants
    - Acceptation des mailles de type TRIA7 et QUAD9
    - Option de sortie dans le fichier MED du niveau de raffinement atteint dans chaque maille

SALOME VERSION 7.1 :
    - Correction d'une anomalie sur le filtrage du raffinement par les groupes
    - Pilotage de l'adaptation par un seuil basé sur la moyenne et l'écart-type (voir :doc:`tui_create_hypothese`)
    - En TUI, choix du dernier instant comme instant de pilotage par SetTimeStepRankLast (voir :doc:`tui_create_iteration`)
    - Possibilité de détruire les objets (GUI et TUI)
    - Modification des fonctions TUI pour qu'elles agissent sur les objets et non plus sur les noms :
      ``homard.AssociateIterHypo(iter_name,hypo_name)`` devient ``iter.AssociateHypo(hypo_name)``, ``homard.AssociateHypoZone(hypo_name,zone_name,type_use)`` devient ``hypo.AddZone(zone_name,type_use)``, ``homard.CreateIteration(iter_name,iter_parent_name)`` devient ``case.NextIteration(iter_name)`` ou ``iter.NextIteration(iter_name)``
    - Ajout de fonctions :
      ``cas.LastIteration()`` : retourne la dernière itération de la descendance du cas (voir :doc:`tui_create_iteration`)
    - Analyse de maillages (voir :doc:`gui_mesh_info`)

SALOME VERSION 7.2 :
    - Possibilité d'utiliser un cone comme support de frontiere 2D (voir :doc:`tui_create_boundary`)
    - Choix de publier ou non le résultat dans SMESH (voir :doc:`tui_create_iteration`)
      ``iter.Compute(option)`` devient ``iter.Compute(option1, option2)``
    - Possibilité de poursuivre une suite d'itérations archivées dans un répertoire (voir :doc:`gui_create_case`)

SALOME VERSION 7.3 :
    - Documentation en anglais
    - Options pour suivre le calcul de l'itération (voir :doc:`tui_create_iteration`) : ``iter.SetInfoCompute(MessInfo)``
    - Creation automatique de schéma YACS :
      ``case.WriteYACSSchema(ScriptFile, DirName, MeshFile)`` : écrit un schéma YACS correspondant au cas (voir :doc:`tui_create_case`)
    - Le maillage initial n'est pas publié dans SMESH.
    - Le raffinement de maillages 2D avec des quadrangles est amélioré pour prendre en compte des zones 'en escalier'.
    - Les champs constants par mailles peuvent être interpolés selon les deux modes : intensif ou extensif.
    - Possibilité de choix des pas de temps pour l'interpolation des champs :
      ``SetFieldInterpTimeStep(FieldInterp, TimeStep)`` : interpole le champ au pas de temps TimeStep (voir :doc:`tui_create_iteration`)
      ``SetFieldInterpTimeStepRank(FieldInterp, TimeStep, Rank)`` : interpole le champ au pas de temps TimeStep et au numéro d'ordre Rank (voir :doc:`tui_create_iteration`)
    - Arrêt en cas d'erreur dans les données des instructions python

SALOME VERSION 7.4 :
    - Grandes fenêtres avec ascenseur.
    - Publication des maillages à la demande.
    - Suivi de frontière analytique torique.
    - La fonction ``SetAdapRefinUnRef(TypeAdap, TypeRaff, TypeDera)`` est supprimée. Pour une adaptation selon un champ ou des zones, le mode raffinement/déraffinement est automatiquement déduit des autres paramètres de l'hypothèse. Pour un raffinement uniforme, on utilisera ``SetUnifRefinUnRef(TypeRaffDera)`` (voir :doc:`tui_create_hypothese`).
    - En cas d'erreur dans l'adaptation, le nom du fichier de messages est affiché.
    - Passage à la version 11.1 de l'exécutable HOMARD ; le raffinement conforme des maillages en hexaèdres est amélioré pour diminuer le nombre de mailles produites.

SALOME VERSION 7.5 :
    - Sorties supplémentaires optionnelles : diamètre et qualité ; on utilisera ``SetExtraOutput(option)`` (voir :doc:`tui_create_hypothese`).
    - Passage à la version 11.2 de l'exécutable HOMARD ; amélioration du suivi des frontières courbes 1D.

SALOME VERSION 7.6 :
    - Pilotage de l’interpolation de tous les champs présents dans le fichier d’entrée.

SALOME VERSION 8.1 :
    - Interfaçage avec med 3.2.0
    - Variantes dans les choix conforme / non conforme.
    - Diminution du nombre de mailles impactées dans le cas d’un raffinement non conforme d’un maillage en hexaèdres.
    - Correction d'une anomalie en raffinement / déraffinement d’un maillage en hexaèdres.

SALOME VERSION 8.3 :
    - Interfaçage avec med 3.2.1
    - Sortie des listes de mailles volumiques raccordées par non-conformité

SALOME VERSION 8.4 :
    - Interfaçage avec med 3.3.0
    - Correction pour le déraffinement conforme d’un ensemble d’hexaèdres.
    - Correction de l’interpolation d’un champ volumique sur les prismes découpés en tétraèdres et en pyramides.
    - Utilisation de champs MED entiers pour les recollements non conformes de niveaux différents.
