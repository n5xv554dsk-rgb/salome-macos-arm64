      subroutine pcsehy ( nfhexa, nfpyra, nftetr, ficalc,
     >                    lehexa, etat,
     >                    filhex, fhpyte,
     >                    nhecca, ntecca, npycca,
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
c                       Hexaedres - reperages des fils
c                       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nfhexa .   s .    1   . nombre de fils hexaedres                   .
c . nfpyra .   s .    1   . nombre de fils pyramides                   .
c . nftetr .   s .    1   . nombre de fils tetraedres                  .
c . ficalc .   s .  3,18  . numeros des fils en numerotation du calcul .
c .        .     .        . 1 : hexaedres                              .
c .        .     .        . 2 : pyramides                              .
c .        .     .        . 3 : tetraedres                             .
c . lehexa . e   .    1   . hexaedre courant                           .
c . etat   . e   .    1   . etat de l'hexaedre                         .
c . filhex . e   .   *    . premier fils des hexaedres                 .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . nhecca . e   .   *    . numero des hexaedres dans le calcul e/s    .
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
      parameter ( nompro = 'PCSEHY' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "hexcf0.h"
c
c 0.3. ==> arguments
c
      integer nfhexa, nfpyra, nftetr
      integer ficalc(3,18)
      integer lehexa, etat
c
      integer filhex(*), fhpyte(2,*)
      integer nhecca(*)
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
      write (ulsort,texte(langue,4)) lehexa, etat
#endif
c
c====
c 2. denombrement des fils pour les differents cas de figure
c====
c
      jaux = chbiet(etat)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'etat', etat, ' ==> code binaire', jaux
#endif
c
      nfhexa = chnhe(jaux)
      nfpyra = chnpy(jaux)
      nftetr = chnte(jaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nfhexa', nfhexa
      write (ulsort,90002) 'nfpyra', nfpyra
      write (ulsort,90002) 'nftetr', nftetr
#endif
c
c====
c 3. Calcul
c====
c 3.1. ==> Reperage des hexaedres fils de l'hexaedre
c
      if ( nfhexa.gt.0 ) then
c
        jaux = filhex(lehexa) - 1
        do 31 , iaux = 1 , nfhexa
cgn        write(ulsort,90002) 'fils', iaux,jaux+iaux
          ficalc(1,iaux) = nhecca(jaux+iaux)
   31   continue
cgn        write(ulsort,90002) 'nfhexa', nfhexa
cgn        write(ulsort,91020) (ficalc(1,iaux) , iaux = 1 , nfhexa)
c
      endif
c
c 3.2. ==> Reperage des pyramides filles de l'hexaedre
c
      if ( nfpyra.gt.0 ) then
c
        jaux = fhpyte(1,-filhex(lehexa)) - 1
        do 32 , iaux = 1 , nfpyra
          ficalc(2,iaux) = npycca(jaux+iaux)
   32   continue
cgn        write(ulsort,90002) 'nfpyra', nfpyra
cgn        write(ulsort,91020) (ficalc(2,iaux) , iaux = 1 , nfpyra)
c
      endif
c
c 3.3. ==> Reperage des tetraedres fils de l'hexaedre
c
      if ( nftetr.gt.0 ) then
c
        jaux = fhpyte(2,-filhex(lehexa)) - 1
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
