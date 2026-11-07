      subroutine utcvne ( nretap, nrsset, textet, lgtext, codret )
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
c   UTilitaire - ConVertit le Numero d'Etape
c   --           -  -         -        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nretap . e   .    1   . numero d'etape en entier                   .
c . nrsset . e   .    1   . numero de sous-etape en entier             .
c . textet .   s .char*(*). textet : nretap.nrsset.                    .
c . lgtext .   s .    1   . longueur du textet                         .
c . codret .   s .    1   . 0 : pas de probleme                        .
c .        .     .        . 1 : conversion impossible                  .
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
      character*6 nompro
      parameter ( nompro = 'UTCVNE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nretap, nrsset, lgtext
      integer codret
c
      character*(*) textet
c
c 0.4. ==> variables locales
c
      integer iaux, lgtx00
      integer ulsort, langue
c
      character*3 c3aux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
#include "impr01.h"
c
c====
c 1. decodage
c====
c
      call gusost ( ulsort )
      langue = 1
c
c 1.1. ==> filtrage initial
c          s'il est negatif, c'est une erreur
c
      if ( nretap.le.0 ) then
        codret = 1
      endif
c
      lgtext = 0
      lgtx00 = len(textet)
c
c 1.2. ==> conversion en entier
c
      if ( codret.eq.0 ) then
c
      call utench ( nretap, 'g', iaux, c3aux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
        lgtext = iaux+1
        textet (1:lgtext) = c3aux(1:iaux)//'.'
c
      endif
c
c 1.3. ==> numero de sous-etape
c          s'il est negatif, on ne mentionne rien
c
      if ( nrsset.ge.0 ) then
c
        if ( codret.eq.0 ) then
c
        call utench ( nrsset, 'g', iaux, c3aux,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
          textet (lgtext+1:lgtext+iaux+1) = c3aux(1:iaux)//'.'
          lgtext = lgtext+iaux+1
c
        endif
c
      endif
c
c====
c 2. bilan
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
        textet = ' '
        lgtext = 1
c
      endif
c
      do 21 , iaux = lgtext+1 , lgtx00
        textet(iaux:iaux) = ' '
   21 continue
c
      end
