c
c=======================================================================
c nombres propres a la renumerotation des entites en entree
c-----------------------------------------------------------------------
c renois : nombre de noeuds isoles
c renoei : nombre de noeuds elements ignores uniquement
c renomp : nombre de noeuds support de maille-point uniquement
c renop1 : nombre de noeuds sommets
c renop2 : nombre de noeuds milieux d'aretes
c renoim : nombre de noeuds internes aux mailles
c renoac : nombre de noeuds actifs dans le calcul
c renoto : nombre total de noeuds
c          = renois+renoei+renomp+renop1+renop2+renoim
c reno1i : nombre de noeuds p1 et isoles (renois+renoei+renomp+renop1)
c rempac : nombre d'el. utiles au calcul et contenant des mailles-points
c rempto : nombre total de mailles-points
c rearac : nombre d'elements utiles au calcul et contenant des aretes
c rearto : nombre total d'aretes
c retrac : nombre d'elements utiles au calcul et contenant des triangles
c retrto : nombre total de triangles
c requac : nombre d'elements utiles au calcul et contenant des quads
c requto : nombre total de quadrangles
c reteac : nombre d'elements utiles au calcul et contenant des tetras
c reteto : nombre total de tetraedres
c reheac : nombre d'elements utiles au calcul et contenant des hexaas
c reheto : nombre total d'hexaedres
c repyac : nombre d'elements utiles au calcul et contenant des pyras
c repyto : nombre total de pyramides
c repeac : nombre d'elements utiles au calcul et contenant des pentas
c repeto : nombre total de pentaedres
c-----------------------------------------------------------------------
      integer         renois, renoei, renomp, renop1, renop2, renoim,
     >                renoac, renoto, reno1i,
     >                rempac, rempto,
     >                rearac, rearto,
     >                retrac, retrto,
     >                requac, requto,
     >                reteac, reteto,
     >                reheac, reheto,
     >                repyac, repyto,
     >                repeac, repeto
      common /nomber/ renois, renoei, renomp, renop1, renop2, renoim,
     >                renoac, renoto, reno1i,
     >                rempac, rempto,
     >                rearac, rearto,
     >                retrac, retrto,
     >                requac, requto,
     >                reteac, reteto,
     >                reheac, reheto,
     >                repyac, repyto,
     >                repeac, repeto
