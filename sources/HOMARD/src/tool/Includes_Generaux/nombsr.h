c
c=======================================================================
c nombres propres a la renumerotation des entites en sortie
c-----------------------------------------------------------------------
c rsnois : nombre de noeuds isoles
c rsnoei : nombre de noeuds elements ignores uniquement
c rsnomp : nombre de noeuds support de maille-point uniquement
c rsnop1 : nombre de noeuds sommets
c rsnop2 : nombre de noeuds milieux d'aretes
c rsnoim : nombre de noeuds internes aux mailles
c rsnoac : nombre de noeuds actifs dans le calcul
c rsnoto : nombre total de noeuds
c          = rsnois+rsnoei+rsnomp+rsnop1+rsnop2+rsnoim
c rsmpac : nombre d'el. utiles au calcul et contenant des mailles-points
c rsmpto : nombre total de mailles-points
c rsarac : nombre d'elements utiles au calcul et contenant des aretes
c rsarto : nombre total d'aretes
c rstrac : nombre d'elements utiles au calcul et contenant des triangles
c rstrto : nombre total de triangles
c rsquac : nombre d'elements utiles au calcul et contenant des quads
c rsquto : nombre total de quadrangles
c rsteac : nombre d'elements utiles au calcul et contenant des tetras
c rsteto : nombre total de tetraedres
c rsheac : nombre d'elements utiles au calcul et contenant des hexas
c rsheto : nombre total d'hexaedres
c rspyac : nombre d'elements utiles au calcul et contenant des pyras
c rspyto : nombre total de pyramides
c rspeac : nombre d'elements utiles au calcul et contenant des pentas
c rspeto : nombre total de pentaedres
c rseutc : nombre total d'elements utiles au calcul
c rsevca : nombre d'elements volumiques dans le maillage de calcul
c rsevto : nombre total d'elements utiles au calcul
c-----------------------------------------------------------------------
      integer         rsnois, rsnoei, rsnomp, rsnop1, rsnop2, rsnoim,
     >                rsnoac, rsnoto,
     >                rsmpac, rsmpto,
     >                rsarac, rsarto,
     >                rstrac, rstrto,
     >                rsquac, rsquto,
     >                rsteac, rsteto,
     >                rsheac, rsheto,
     >                rspyac, rspyto,
     >                rspeac, rspeto,
     >                rseutc, rsevca, rsevto
      common /nombsr/ rsnois, rsnoei, rsnomp, rsnop1, rsnop2, rsnoim,
     >                rsnoac, rsnoto,
     >                rsmpac, rsmpto,
     >                rsarac, rsarto,
     >                rstrac, rstrto,
     >                rsquac, rsquto,
     >                rsteac, rsteto,
     >                rsheac, rsheto,
     >                rspyac, rspyto,
     >                rspeac, rspeto,
     >                rseutc, rsevca, rsevto
