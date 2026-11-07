      subroutine utcoq5 ( hetare, somare, filare, a1, a2, a3, a4,
     >                    numdec, ai, aj, ak, al,
     >                    aifj, aifl, ni,
     >                    ajfi, ajfk, nj,
     >                    saiaj, sajak, sakal, salai,
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
c                           en 3 quadrangles
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
c .  aifj  .  s  . 1      . fille de ai allant vers saiaj              .
c .  aifl  .  s  . 1      . fille de ai allant vers salai              .
c .   ni   .  s  . 1      . milieu de l'arete ai                       .
c .  ajfi  .  s  . 1      . fille de aj allant vers saiaj              .
c .  ajfk  .  s  . 1      . fille de aj allant vers sajak              .
c .   nj   .  s  . 1      . milieu de l'arete aj                       .
c . saiaj  .  s  . 1      . sommet commun aux aretes i et j            .
c . sajak  .  s  . 1      . sommet commun aux aretes j et k            .
c . sakal  .  s  . 1      . sommet commun aux aretes k et l            .
c . salai  .  s  . 1      . sommet commun aux aretes l et i            .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c ______________________________________________________________________
c
c       saiaj         aifj       ai/ni       aifl         salai
c           ._____________________________________________.
c           .                      .                      .
c           .                      .                      .
c           .                      .                      .
c           .                      .anin0                 .
c      ajfi .         nq1          .                      .
c           .                      .                      .
c           .                      .                      .
c           .                      .                      .
c           .        anjn0         .                      .
c     aj/nj .----------------------.n0         nq3        . al
c           .                        .                    .
c           .                          .                  .
c           .                            .                .
c           .                              .              .
c      ajfk .           nq2                  .            .
c           .                           ankln0 .          .
c           .                                    .        .
c           .                                      .      .
c           .                                        .    .
c           ._____________________________________________.
c       sajak                     ak                      sakal
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
      parameter ( nompro = 'UTCOQ5' )
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
      integer aifj, aifl, ni
      integer ajfi, ajfk, nj
      integer saiaj, sajak, sakal, salai
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer arete(4)
      integer iaux, jaux, kaux
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
      codret = 0
c
c====
c 2. recherche du numero local de la premiere arete coupee
c====
c
      arete(1) = a1
      arete(2) = a2
      arete(3) = a3
      arete(4) = a4
cgn      write(ulsort,*) a1,hetare(a1)
cgn      write(ulsort,*) a2,hetare(a2)
cgn      write(ulsort,*) a3,hetare(a3)
cgn      write(ulsort,*) a4,hetare(a4)
c
      jaux = 0
      kaux = 0
      do 20 , iaux = 1 , 4
        if ( mod(hetare(arete(iaux)),10).eq.2 ) then
          if ( jaux.eq.0 ) then
            jaux = iaux
          else
            kaux = iaux
          endif
        endif
  20  continue
c
cgn      write (ulsort,*) jaux, kaux
      if ( kaux.eq.0 ) then
        write (ulsort,texte(langue,10))
        codret = 1
      elseif ( jaux.eq.1 .and. kaux.eq.4 ) then
        numdec = 4
      else
        numdec = jaux
      endif
c
c====
c 3. les numeros globaux des noeuds et des aretes
c====
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> la premiere arete coupee
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
        aifj = iaux
        aifl = iaux + 1
      else
        aifj = iaux + 1
        aifl = iaux
      endif
c
      ni = somare(2,aifj)
c
c 3.5. ==> le decoupage de l'arete aj
c
      iaux = filare(aj)
      if ( somare(1,iaux).eq.saiaj ) then
        ajfi = iaux
        ajfk = iaux + 1
      else
        ajfi = iaux + 1
        ajfk = iaux
      endif
c
      nj = somare(2,ajfi)
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
