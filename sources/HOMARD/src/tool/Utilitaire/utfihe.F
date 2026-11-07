      subroutine utfihe ( lehexa,
     >                    hethex, filhex, fhpyte,
     >                    nbfite, filste,
     >                    nbfihe, filshe,
     >                    nbfipy, filspy )
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
c     UTilitaire : les FIls d'un HExaedre coupe
c     --               --        --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   .  1     . numero de l'hexaedre a examiner            .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . nbfite .  s  .  1     . nombre de fils de type tetraedre           .
c . filste .  s  .  1     . fils aine tetraedre s'il existe, 0 sinon   .
c . nbfihe .  s  .  1     . nombre de fils de type hexaedre            .
c . filshe .  s  .  1     . fils aine hexaedre s'il existe, 0 sinon    .
c . nbfipy .  s  .  1     . nombre de fils de type pyramide            .
c . filspy .  s  .  1     . fils aine pyramide s'il existe, 0 sinon    .
c .____________________________________________________________________.
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
#include "hexcf0.h"
c
c 0.3. ==> arguments
c
      integer lehexa
      integer hethex(*), filhex(*), fhpyte(2,*)
      integer nbfite, filste
      integer nbfihe, filshe
      integer nbfipy, filspy
c
c 0.4. ==> variables locales
c
      integer iaux
      integer bindec
c
#include "impr03.h"
c
c====
c 1. Nombre de fils
c====
c
      iaux = mod(hethex(lehexa),1000)
      bindec = chbiet(iaux)
#ifdef _DEBUG_HOMARD_
      write (*,90015) 'etat', iaux, ' ==> code binaire', bindec
#endif
c
      nbfite = chnte(bindec)
      nbfihe = chnhe(bindec)
      nbfipy = chnpy(bindec)
c
c====
c 2. Les fils
c====
c
      iaux = filhex(lehexa)
c
      if ( nbfite.gt.0 ) then
        filste = fhpyte(2,-iaux)
      else
        filste = 0
      endif
c
      if ( nbfihe.gt.0 ) then
        filshe = iaux
      else
        filshe = 0
      endif
c
      if ( nbfipy.gt.0 ) then
        filspy = fhpyte(1,-iaux)
      else
        filspy = 0
      endif
c
#ifdef _DEBUG_HOMARD_
      write (*,90002) 'hexaedre', lehexa
      write (*,90006) 'fils hexaedres  - nombre', nbfihe, '-', filshe
      write (*,90006) 'fils pyramides  - nombre', nbfipy, '-', filspy
      write (*,90006) 'fils tetraedres - nombre', nbfite, '-', filste
#endif
c
      end
