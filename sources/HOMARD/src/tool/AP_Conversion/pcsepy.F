      subroutine pcsepy ( nfpent, nfpyra, nftetr, ficalc,
     >                    lepent, etat,
     >                    filpen, fppyte,
     >                    npecca, ntecca, npycca,
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
c    aPres adaptation - Conversion de Solution Elements de volume -
c     -                 -             -        -
c                       Pentaedres - reperages des fils
c                       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nfpent .   s .    1   . nombre de fils pentaedres                  .
c . nfpyra .   s .    1   . nombre de fils pyramides                   .
c . nftetr .   s .    1   . nombre de fils tetraedres                  .
c . ficalc .   s .  3,11  . numeros des fils en numerotation du calcul .
c .        .     .        . 1 : pentaedres                             .
c .        .     .        . 2 : pyramides                              .
c .        .     .        . 3 : tetraedres                             .
c . lepent . e   .    1   . hexaedre courant                           .
c . etat   . e   .    1   . etat du pentaedre                          .
c . filpen . e   .   *    . premier fils des pentaedres                .
c . fppyte . e   .2*nbpeco. fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) =-j .
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
c . npecca . e   .   *    . numero des pentaedres dans le calcul e/s   .
c . ntecca . e   .   *    . numero des tetraedres dans le calcul e/s   .
c . npycca . e   .   *    . pyramides en sortie dans le calcul e/s     .
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
      parameter ( nompro = 'PCSEPY' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer nfpent, nfpyra, nftetr
      integer ficalc(3,11)
      integer lepent, etat
c
      integer filpen(*), fppyte(2,*)
      integer npecca(*)
      integer ntecca(*)
      integer npycca(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "pcimp2.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) lepent, etat
#endif
c
c====
c 2. denombrement des fils pour les differents cas de figure
c====
c 2.0. ==> a priori, aucun
c
      nfpent = 0
      nfpyra = 0
      nftetr = 0
c
c 2.1. ==> etat = 1, ..., 6 :
c          decoupage en 1 tetraedre et 2 pyramides
c
      if ( etat.ge.1 .and. etat.le.6 ) then
c
        nfpyra = 2
        nftetr = 1
c
c 2.2. ==> etat = 17, ..., 19 :
c          decoupage en 2 tetraedres et 1 pyramide.
c
      elseif ( etat.ge.17 .and. etat.le.19 ) then
c
        nfpyra = 1
        nftetr = 2
c
c 2.3. ==> etat = 21, ..., 26 :
c          decoupage en 6 tetraedres
c
      elseif ( etat.ge.21 .and. etat.le.26 ) then
c
        nftetr = 6
c
c 2.4. ==> etat = 31, ..., 36 :
c          decoupage en 10 tetraedres et 1 pyramide.
c
      elseif ( etat.ge.31 .and. etat.le.36 ) then
c
        nfpyra = 1
        nftetr = 10
c
c 2.5. ==> etat = 43, ..., 45 :
c          decoupage en 2 tetraedres et 4 pyramides
c
      elseif ( etat.ge.43 .and. etat.le.45 ) then
c
        nfpyra = 4
        nftetr = 2
c
c 2.6. ==> etat = 51, 52 :
c          decoupage en 11 tetraedres
c
      elseif ( etat.ge.51 .and. etat.le.52 ) then
c
        nftetr = 11
c
c 2.7. ==> etat = 80 :
c          decoupage en 8 pentaedres.
c
      elseif ( etat.eq.80 .or. etat.eq.99 ) then
c
        nfpent = 8
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nfpent', nfpent
      write (ulsort,90002) 'nfpyra', nfpyra
      write (ulsort,90002) 'nftetr', nftetr
#endif
c
c====
c 3. Calcul
c====
c 3.1. ==> Reperage des pentaedres fils du pentaedre
c
      if ( nfpent.gt.0 ) then
c
        jaux = filpen(lepent) - 1
        do 31 , iaux = 1 , nfpent
          ficalc(1,iaux) = npecca(jaux+iaux)
   31   continue
cgn        write(ulsort,90002) 'nfpent', nfpent
cgn        write(ulsort,91020) (ficalc(1,iaux) , iaux = 1 , nfpent)
c
      endif
c
c 3.2. ==> Reperage des pyramides filles du pentaedre
c
      if ( nfpyra.gt.0 ) then
c
        jaux = fppyte(1,-filpen(lepent)) - 1
        do 32 , iaux = 1 , nfpyra
          ficalc(2,iaux) = npycca(jaux+iaux)
   32   continue
cgn        write(ulsort,90002) 'nfpyra', nfpyra
cgn        write(ulsort,91020) (ficalc(2,iaux) , iaux = 1 , nfpyra)
c
      endif
c
c 3.3. ==> Reperage des tetraedres fils du pentaedre
c
      if ( nftetr.gt.0 ) then
c
        jaux = fppyte(2,-filpen(lepent)) - 1
        do 33 , iaux = 1 , nftetr
          ficalc(3,iaux) = ntecca(jaux+iaux)
   33   continue
cgn        write(ulsort,90002) 'nftetr', nftetr
cgn        write(ulsort,91020) (ficalc(3,iaux) , iaux = 1 , nftetr)
c
      endif
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
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
