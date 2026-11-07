c
c=======================================================================
c front1 : taille des tableaux de la geometrie de la frontiere
c-----------------------------------------------------------------------
c sfsdim : dimension de l'espace
c sfmdim : dimension du maillage
c sfnbso : nombre de sommets decrivant la frontiere
c sfnbli : nombre de lignes decrivant la frontiere
c sfnbse : taille du tableau contenant la suite des sommets des lignes
c-----------------------------------------------------------------------
      integer         sfsdim, sfmdim, sfnbso, sfnbli, sfnbse
      common /front1/ sfsdim, sfmdim, sfnbso, sfnbli, sfnbse
