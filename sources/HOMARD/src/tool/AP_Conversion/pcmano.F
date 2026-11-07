      subroutine pcmano ( coonoe, hetnoe,
     >                    famnoe, cfanoe,
     >                    nnosca, nnosho,
     >                    dimcst, coocst, sdimca, coonca,
     >                    noeord,
     >                    fameno,
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
c    aPres adaptation - Conversion - MAillage connectivite - NOeud
c     -                 -            --                      --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . hetnoe . e   . nbnoto . historique de l'etat des noeuds            .
c . famnoe . e   . nbnoto . famille des noeuds                         .
c . cfanoe . e   . nctfno*. codes des familles des noeuds              .
c .        .     . nbnoto .   1 : famille MED                          .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . nnosca .  s  . rsnoto . numero des noeuds du code de calcul        .
c . nnosho .  s  . rsnoac . numero des noeuds dans HOMARD              .
c . dimcst . e   .    1   . dimension de la coordonnee constante       .
c .        .     .        . eventuelle, 0 si toutes varient            .
c . coocst . e   .   11   . 1 : coordonnee constante eventuelle        .
c .        .     .        . 2, 3, 4 : xmin, ymin, zmin                 .
c .        .     .        . 5, 6, 7 : xmax, ymax, zmax                 .
c .        .     .        . 8, 9, 10 : -1 si constant, max-min sinon   .
c .        .     .        . 11 : max des (max-min)                     .
c . sdimca . e   .   1    . dimension de l'espace de calcul            .
c . coonca .   s . nbnoto . coordonnees des noeuds dans le calcul      .
c .        .     . *sdimca.                                            .
c . noeord . e   .   1    . vrai si les noeuds sont ordonnes           .
c .        .     .        . faux si sans importance                    .
c . fameno .   s . nbnoto . famille med des noeuds                     .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'PCMANO' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombsr.h"
#include "impr02.h"
c
#include "dicfen.h"
c
c 0.3. ==> arguments
c
      integer dimcst, sdimca
c
      double precision coocst(11)
      double precision coonoe(nbnoto,sdim), coonca(nbnoto,sdimca)
c
      integer hetnoe(nbnoto)
      integer cfanoe(nctfno,nbfnoe), famnoe(nbnoto)
      integer nnosca(rsnoto), nnosho(rsnoac)
      integer fameno(nbnoto)
c
      logical noeord
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer lenoeu, lenolo
      integer etat
      integer iaux, jaux, kaux, laux, maux
#ifdef _DEBUG_HOMARD_
      integer glop
#endif
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de noeuds '',a2,'' calcule :'',i10)'
      texte(1,5) = '(''Nombre de noeuds '',a2,'' estime  :'',i10)'
      texte(1,6) = '(''Coordonnee constante incorrecte :'',i7)'
      texte(1,10) = '(''Les deux doivent etre egaux ...'')'
c
      texte(2,4) = '(''Computed number of '',a2,'' nodes  :'',i10)'
      texte(2,5) = '(''Estimated number of '',a2,'' nodes :'',i10)'
      texte(2,6) = '(''Constant coordinate is wrong :'',i7)'
      texte(2,10) = '(''Both numbers oUGht to be equal ...'')'
c
#include "impr06.h"
c
      codret = 0
c
c====
c 2. noeuds
c====
c
c 2.1. ==> renumerotation eventuelle des noeuds pour placer les
c          noeuds dans l'ordre suivant :
c            . noeuds isoles
c            . noeuds d'elements ignores
c            . noeuds uniquement support de maille-point
c            . noeuds p1
c            . noeuds p2
c          sinon, pas de changement de renumerotation
cgn          write(6,*) 'noeord = ',noeord
cgn          write(6,*) 'nbnois, nbnoei, nbnomp, nbnop1, nbnoto = ',
cgn     >nbnois, nbnoei, nbnomp, nbnop1, nbnoto
c
      if ( noeord ) then
c
        iaux = 0
        jaux = nbnois
        kaux = jaux + nbnoei
        laux = kaux + nbnomp
        maux = laux + nbnop1
c
        do 211 , lenoeu = 1 , nbnoto
c
#ifdef _DEBUG_HOMARD_
        if ( lenoeu.eq.-12 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
      write (ulsort,texte(langue,11)) mess14(langue,2,-1), lenoeu
        endif
#endif
          if ( hetnoe(lenoeu).eq.0) then
            iaux = iaux + 1
            nnosho(iaux) = lenoeu
            nnosca(lenoeu) = iaux
          else
            etat = mod ( hetnoe(lenoeu), 10 )
            if ( etat.eq.7 ) then
              jaux = jaux + 1
              nnosho(jaux) = lenoeu
              nnosca(lenoeu) = jaux
            elseif ( etat.eq.3 ) then
              kaux = kaux + 1
              nnosho(kaux) = lenoeu
              nnosca(lenoeu) = kaux
            elseif ( etat.eq.1 ) then
              laux = laux + 1
              nnosho(laux) = lenoeu
              nnosca(lenoeu) = laux
            elseif ( etat.eq.2 ) then
              maux = maux + 1
              nnosho(maux) = lenoeu
              nnosca(lenoeu) = maux
            else
              codret = codret + 1
            endif
          endif
  211   continue
c
        if ( iaux.ne.nbnois ) then
          write(ulsort,texte(langue,4)) 'is', iaux
          write(ulsort,texte(langue,5)) 'is', nbnois
          write(ulsort,texte(langue,10))
          codret = 1
        endif
c
        if ( kaux-nbnois.ne.nbnoei ) then
          write(ulsort,texte(langue,4)) 'IG', jaux-nbnois
          write(ulsort,texte(langue,5)) 'IG', nbnoei
          write(ulsort,texte(langue,10))
          codret = 1
        endif
c
        if ( kaux-nbnois-nbnoei.ne.nbnomp ) then
          write(ulsort,texte(langue,4)) 'MP', jaux-nbnois-nbnoei
          write(ulsort,texte(langue,5)) 'MP', nbnomp
          write(ulsort,texte(langue,10))
          codret = 1
        endif
c
        if ( laux-nbnois-nbnoei-nbnomp.ne.nbnop1 ) then
          write(ulsort,texte(langue,4)) 'P1', kaux-nbnois-nbnoei-nbnomp
          write(ulsort,texte(langue,5)) 'P1', nbnop1
          write(ulsort,texte(langue,10))
          codret = 1
        endif
c
        if ( maux-nbnois-nbnoei-nbnomp-nbnop1.ne.nbnop2 ) then
          write(ulsort,texte(langue,4)) 'P2',
     >                                  laux-nbnois-nbnoei-nbnomp-nbnop1
          write(ulsort,texte(langue,5)) 'P2', nbnop2
          write(ulsort,texte(langue,10))
          codret = 1
        endif
c
      else
c
        do 212 , lenoeu = 1 , nbnoto
#ifdef _DEBUG_HOMARD_
        if ( lenoeu.eq.-12 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
      write (ulsort,texte(langue,11)) mess14(langue,2,-1), lenoeu
        endif
#endif
          nnosho(lenoeu) = lenoeu
          nnosca(lenoeu) = lenoeu
  212   continue
CGN          nnosho(28) = 30
CGN          nnosca(28) = 30
CGN          nnosho(30) = 28
CGN          nnosca(30) = 28
CGN          nnosho(29) = 31
CGN          nnosca(29) = 31
CGN          nnosho(31) = 29
CGN          nnosca(31) = 29
CGN          nnosho(40) = 46
CGN          nnosca(40) = 46
CGN          nnosho(46) = 40
CGN          nnosca(46) = 40
CGN          nnosho(41) = 47
CGN          nnosca(41) = 47
CGN          nnosho(47) = 41
CGN          nnosca(47) = 41
CGN          nnosho(42) = 48
CGN          nnosca(42) = 48
CGN          nnosho(48) = 42
CGN          nnosca(48) = 42
c
      endif
c
CGN        do 219 , lenoeu = 1 , nbnoto
CGN          write(6,5555) lenoeu, nnosho(lenoeu), nnosca(lenoeu)
CGN  219   continue
CGN 5555 format(3i4)
c
c 2.2. ==> les coordonnees
c
      if ( sdim.eq.1 ) then
c
        do 221 , lenoeu = 1 , nbnoto
          lenolo = nnosho(lenoeu)
          coonca(lenoeu,1) = coonoe(lenolo,1)
  221   continue
        if(dimcst.eq.2) then
          do 2223 , lenoeu = 1 , nbnoto
            coonca(lenoeu,2) = 0.d0
 2223     continue
        endif
c
      elseif ( sdim.eq.2 ) then
c
        if ( dimcst.eq.0 .or. dimcst.eq.3 ) then
          iaux = 1
          jaux = 2
        elseif ( dimcst.eq.1 ) then
          iaux = 2
          jaux = 3
        elseif ( dimcst.eq.2 ) then
          iaux = 1
          jaux = 3
        else
          write (ulsort,texte(langue,6)) dimcst
          codret = 1
        endif
c
        if ( codret.eq.0 ) then
c
        do 222 , lenoeu = 1 , nbnoto
          lenolo = nnosho(lenoeu)
          coonca(lenoeu,iaux) = coonoe(lenolo,1)
          coonca(lenoeu,jaux) = coonoe(lenolo,2)
  222   continue
c
        if ( dimcst.ne.0 ) then
          do 2221 , lenoeu = 1 , nbnoto
            coonca(lenoeu,dimcst) = coocst(1)
 2221     continue
        endif
c
        endif
c
      else
c
        do 223 , lenoeu = 1 , nbnoto
#ifdef _DEBUG_HOMARD_
        if ( lenoeu.eq.-12 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
      write (ulsort,texte(langue,11)) mess14(langue,2,-1), lenoeu
        endif
#endif
          lenolo = nnosho(lenoeu)
          coonca(lenoeu,1) = coonoe(lenolo,1)
          coonca(lenoeu,2) = coonoe(lenolo,2)
          coonca(lenoeu,3) = coonoe(lenolo,3)
  223   continue
c
      endif
c
c====
c 3. la famille des noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. la famille des noeuds ; codret = ', codret
#endif
c
      do 31, lenoeu = 1, rsnoto
#ifdef _DEBUG_HOMARD_
        if ( lenoeu.eq.-12 ) then
          glop = 1
        else
          glop = 0
        endif
#endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
      write (ulsort,texte(langue,11)) mess14(langue,2,-1), lenoeu
      write (ulsort,*) 'nnosho(lenoeu) =', nnosho(lenoeu)
      write (ulsort,*) 'famnoe =', famnoe(nnosho(lenoeu))
c      write (ulsort,texte(langue,16)) cofamd
        endif
#endif
        fameno(lenoeu) = cfanoe(cofamd,famnoe(nnosho(lenoeu)))
   31 continue
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
