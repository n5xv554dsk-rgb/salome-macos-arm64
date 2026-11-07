      subroutine gmshfr ( tab , adnew , adold , nbval )
c ______________________________________________________________________
c
c                             H O M A R D
c
c Outil de Maillage Adaptatif par Raffinement et Deraffinement d'EDF R&D
c
c Version originale enregistree le 18 juin 1996 sous le numero 96036
c aupres des huissiers de justice Simart et Lavoir a Clamart
c Version 11.2 enregistree le 13 fevrier 2015 sous le numero 2015/014
c aupres des huissiers de justice
c Lavoir, Silinski & Cherqui-Abrahmi a Clamart
c
c    HOMARD est une marque deposee d'Electricite de France
c
c Copyright EDF 1996
c Copyright EDF 1998
c Copyright EDF 2002
c Copyright EDF 2020
c ______________________________________________________________________
c
c    translate le contenu du tableau reel tab
c    de l'adresse adold a l'adresse adnew et cela pour nbval valeurs.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . tab    . es  .   *    . tableau dans lequel on decale              .
c .        .     .        . sa longueur est a priori inconnue          .
c . adnew  . e   .   1    . adresse a laquelle on placera les valeurs  .
c . adold  . e   .   1    . adresse a laquelle sont les valeurs        .
c . nbval  . e   .   1    . nombre de valeurs a transferer             .
c ______________________________________________________________________
c
c====
c 0. declarations et dimensionnement
c====
c
c 0.1. ==> generalites
c
      implicit none
      save
c
c 0.2. ==> communs
c
#include "gmimpr.h"
c
c 0.3. ==> arguments
c
      double precision tab(*)
c
      integer adnew , adold , nbval
c
c 0.4. ==> variables locales
c
      integer iaux, ifin, decal
c
c====
c 1. decalage des valeur au sein du tableau tab
c       a condition que adnew <= adold
c    remarque : cette programmation de la boucle est celle qui entraine
c               le moins de calculs sur machine scalaire.
c               sur CRAY, les options de compilation vectorisent
c               totalement le traitement.
c====
c
      decal = adold - adnew
      if ( decal.lt.0 ) then
c
        write(ulsort,1000) adnew, adold
 1000   format(//2x,' ======  spg gmshfr ========',/2x,
     >  ' le decalage d''indice ne peut s''effectuer car le nouvel',
     > /2x,' indice (',i6,') est superieur a l''ancien (',i6,') .')
        call ugstop('gmshfr',ulsort,0,1,1)
c
      endif

c
      ifin = adnew + nbval - 1
c
      do 10 , iaux = adnew , ifin
        tab(iaux) = tab(decal+iaux)
 10   continue
c
      end
