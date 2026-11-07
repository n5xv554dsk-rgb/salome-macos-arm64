      subroutine utcoq3 ( hetare, somare, filare, a1, a2, a3, a4,
     >                    numdec, ai, aj, ak, al, afij, afil,
     >                    saiaj, sajak, sakal, salai, ni,
     >                    ulsort, langue, codret )
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
c    UTilitaire - decoupage de COnformite d'un Quadrangle
c    --                        --              -
c                           en 3 triangles
c                              -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hetare . e   . nbaret . historique de l'etat des aretes            .
c . somare . e   .2*nbaret. numeros des extremites d'arete             .
c . filare . e   . nbaret . premiere fille des aretes                  .
c .a1,..,a4. e   . 1      . les numeros d'arete du quadrangle          .
c . numdec .  s  . 1      . numero local de l'arete decoupee           .
c .   ai   .  s  . 1      . l'arete du quadrangle qui est decoupee     .
c .aj,ak,al.  s  . 1      . les 3 autres aretes dans l'ordre oriente   .
c .  afij  .  s  . 1      . fille de ai allant vers saiaj              .
c .  afil  .  s  . 1      . fille de ai allant vers salai              .
c . saiaj  .  s  . 1      . sommet commun aux aretes i et j            .
c . sajak  .  s  . 1      . sommet commun aux aretes j et k            .
c . sakal  .  s  . 1      . sommet commun aux aretes k et l            .
c . salai  .  s  . 1      . sommet commun aux aretes l et i            .
c .   ni   .  s  . 1      . milieu de l'arete ai                       .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c ______________________________________________________________________
c
c       saiaj         afij       ai/ni       afil         salai
c           ._____________________________________________.
c           .                      .                      .
c           .                     . .                     .
c           .                    .   .                    .
c           .                   .     .                   .
c           .                  .       .                  .
c           .                 .         .                 .
c           .       nf2      .           .       nf3      .
c           .               .             .               .
c           .              .               .              .
c           .             .                 .             .
c        aj .            .                   .            . al
c           .           .anijk           anikl.           .
c           .          .                       .          .
c           .         .                         .         .
c           .        .                           .        .
c           .       .                             .       .
c           .      .               nf1             .      .
c           .     .                                 .     .
c           .    .                                   .    .
c           .   .                                     .   .
c           .  .                                       .  .
c           . .                                         . .
c           ._____________________________________________.
c       sajak                       ak                    sakal
c
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
      parameter ( nompro = 'UTCOQ3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "ope1a4.h"
c
c 0.3. ==> arguments
c
      integer hetare(*), somare(2,*), filare(*)
      integer numdec
      integer a1, a2, a3, a4
      integer ai, aj, ak, al
      integer afij, afil
      integer saiaj, sajak, sakal, salai
      integer ni
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer arete(4)
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,10) ='(''Impossible de trouver l''''arete coupee.''))'
c
      texte(2,10) ='(''Cut edge cannot be found.'')'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. recherche du numero local de l'arete coupee
c====
c
      arete(1) = a1
      arete(2) = a2
      arete(3) = a3
      arete(4) = a4
c
      do 20 , iaux = 1 , 4
        if ( mod(hetare(arete(iaux)),10).eq.2 ) then
          numdec = iaux
          goto 21
        endif
  20  continue
c
      write (ulsort,texte(langue,10))
      codret = 1
c
  21  continue
cgn      write (ulsort,90002) 'numdec', numdec
c
c====
c 3. les numeros globaux des noeuds et des aretes
c====
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> l'arete coupee
c
      ai = arete(numdec)
c
c 3.2. ==> les autres aretes sont dans le meme ordre de rotation
c
      iaux = per1a4(1,numdec)
      aj = arete(iaux)
c
      iaux = per1a4(1,iaux)
      ak = arete(iaux)
c
      iaux = per1a4(1,iaux)
      al = arete(iaux)
c
c 3.3. ==> les sommets du quadrangle
c
      call utsoqu ( somare, ai, aj, ak, al,
     >              saiaj, sajak, sakal, salai )
c
c 3.4. ==> le decoupage de l'arete ai
c
      iaux = filare(ai)
      if ( somare(1,iaux).eq.saiaj ) then
        afij = iaux
        afil = iaux + 1
      else
        afij = iaux + 1
        afil = iaux
      endif
c
      ni = somare(2,afij)
c
      endif
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
