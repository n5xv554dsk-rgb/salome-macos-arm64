.. _glossaire:

Glossaire
#########

.. glossary::
   :sorted:

   raffinement
      Le raffinement est une opération consistant à découper les mailles sélectionnées.

   niveau
      Le niveau d'une maille est le nombre de découpages qu'il a fallu pour l'obtenir. Les mailles du maillage initial sont du niveau 0 par convention.

   déraffinement
      Le déraffinement est une opération consistant à supprimer des mailles. Il s'agit en fait d'annuler un précédent découpage : on ne reviendra jamais 'plus haut' que le maillage initial.

   zone
      Une zone est une région qui définit un mode de pilotage de l'adaptation : toutes les mailles dont au moins une arête est dans une zone seront raffinées ou déraffinées selon le choix retenu.

   cas
      Un cas est défini par un maillage initial et une succession d'adaptations.

   indicateur d'erreur
      L'indicateur d'erreur est un champ exprimé sur les mailles du calcul. Il représente l'écart entre la solution réelle et la solution calculée.

   itération
      Une itération est le processus qui permet de passer d'un maillage à un autre au sein d'un cas. Une itération met en oeuvre du raffinement et/ou du déraffinement selon l'hypothèse qui lui est attachée.

   hypothèse
      Une hypothèse décrit les conditions de passage d'un maillage à un autre : raffinement et/ou déraffinement, mode de pilotage, etc. Une hypothèse est référencée par une ou plusieurs itérations.

   champ
      Un champ est exprimé sur un maillage, par noeud ou par maille, avec une ou plusieurs composantes. La valeur de ce champ pilote l'adaptation.


   MED
      C'est le format d'échange des maillages et des champs pour SALOME.