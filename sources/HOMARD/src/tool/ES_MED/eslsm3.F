      subroutine eslsm3 ( nbfonc, defonc,
     >                    nofonc,
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
c  Entree-Sortie - Lecture d'une Solution au format MED - phase 3
c  -      -        -             -                  -           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfonc . e   .   1    . nombre de fonctions                        .
c . defonc . e   . nbinec*. description des fonctions en entier        .
c .        .     . nbfonc . 1. type de support au sens MED             .
c .        .     .        . 2. nombre de points de Gauss               .
c .        .     .        . 3. nombre de valeurs                       .
c .        .     .        . 4. nombre de valeurs du profil eventuel    .
c .        .     .        . 5. nombre de supports associes             .
c .        .     .        . 6. 1, si aux noeuds par elements           .
c .        .     .        .    2, si aux points de Gauss, associe avec .
c .        .     .        .       un champ aux noeuds par elements     .
c .        .     .        .    3, si aux points de Gauss autonome      .
c .        .     .        .    0, sinon                                .
c .        .     .        . 7. nombre de tableaux de ce type           .
c .        .     .        . 8. numero du tableau dans la fonction      .
c .        .     .        . 9. numero de la fonction associee si champ .
c .        .     .        .    aux noeuds par element ou points de Gaus.
c .        .     .        . 10. numero HOMARD du champ associe         .
c .        .     .        . 11. type interpolation                     .
c .        .     .        .       0, si automatique                    .
c .        .     .        .       1 si degre 1, 2 si degre 2,          .
c .        .     .        .       3 si iso-P2                          .
c .        .     .        . 12. type de champ edfl64/edin64            .
c .        .     .        . 21-nbinec. type des supports associes      .
c . nofonc . es  .3*nbfonc. description des fonctions en caracteres    .
c .        .     .        . 1. nom de l'objet profil, blanc sinon      .
c .        .     .        . 2. nom de l'objet fonction                 .
c .        .     .        . 3. nom de l'objet localisation des points  .
c .        .     .        . de Gauss, blanc sinon                      .
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
      parameter ( nompro = 'ESLSM3' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "esutil.h"
#include "gmenti.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer defonc(nbinec,*)
c
      character*8 nofonc(3,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nrfonc
      integer typcha
      integer typgeo, ngauss, nbenmx, nbvapr, nbtyas
      integer carsup, nbtafo, typint
      integer advale, advalr, adobch, adprpg, adtyas
c
      character*8 obfonc
c
      integer nbmess
      parameter ( nbmess = 150 )
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
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "esimpr.h"
c
c====
c 2. creations des fonctions
c====
c
      do 20 , nrfonc = 1 , nbfonc
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '============================================='
        write (ulsort,texte(langue,36)) nompro, nrfonc
        write (ulsort,texte(langue,64)) defonc(1,nrfonc)
        write (ulsort,texte(langue,69)) defonc(12,nrfonc)
        write (ulsort,texte(langue,64)) defonc(1,nrfonc)
        write (ulsort,texte(langue,57)) defonc(2,nrfonc)
        write (ulsort,texte(langue,58)) defonc(3,nrfonc)
        write (ulsort,texte(langue,62)) defonc(4,nrfonc)
        do 229 , iaux = 1, defonc(5,nrfonc)
          write (ulsort,texte(langue,60)) defonc(20+iaux,nrfonc)
  229   continue
        write (ulsort,texte(langue,65+defonc(6,nrfonc)))
        write (ulsort,texte(langue,111)) defonc(7,nrfonc)
        if ( defonc(11,nrfonc).ge.0 .and. defonc(11,nrfonc).le.3 ) then
          write (ulsort,texte(langue,100+defonc(11,nrfonc)))
        else
          write (ulsort,texte(langue,104))
        endif
        write (ulsort,texte(langue,61)) nofonc(1,nrfonc)
        write (ulsort,*) 'numero tableau : ',defonc(9,nrfonc)
        if ( defonc(2,nrfonc).eq.ednopg ) then
          write (ulsort,*) 'Allocation a ',
     >    defonc(3,nrfonc)*defonc(7,nrfonc), ' = ',
     >    defonc(3,nrfonc), '*', defonc(7,nrfonc)
        else
          write (ulsort,*) 'Allocation a ',
     >    defonc(3,nrfonc)*defonc(7,nrfonc)*defonc(2,nrfonc), ' = ',
     >    defonc(3,nrfonc), '*', defonc(7,nrfonc), '*', defonc(2,nrfonc)
        endif
#endif
c
        typcha = defonc(12,nrfonc)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALFO', nompro
#endif
        call utalfo ( obfonc, typcha,
     >                defonc(1,nrfonc), defonc(2,nrfonc),
     >                defonc(3,nrfonc), defonc(4,nrfonc),
     >                defonc(5,nrfonc), defonc(6,nrfonc),
     >                defonc(7,nrfonc), defonc(11,nrfonc),
     >                advale, advalr, adobch, adprpg, adtyas,
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, obfonc )
#endif
c
        if ( codret.eq.0 ) then
c
        do 21 , iaux = 1, defonc(5,nrfonc)
          imem(adtyas+iaux-1) = defonc(20+iaux,nrfonc)
   21   continue
        nofonc(2,nrfonc) = obfonc
c
        endif
c
   20 continue
c
c====
c 3. memorisation des fonctions associees
c====
c
      do 30 , nrfonc = 1 , nbfonc
c
        iaux = defonc(9,nrfonc)
c
        if ( iaux.ne.0 ) then
c
c 3.1. ==> caracteristiques de la fonction courante
c
          if ( codret.eq.0 ) then
c
          obfonc = nofonc(2,nrfonc)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAFO', nompro
#endif
          call utcafo ( obfonc,
     >                  typcha,
     >                  typgeo, ngauss, nbenmx, nbvapr, nbtyas,
     >                  carsup, nbtafo, typint,
     >                  advale, advalr, adobch, adprpg, adtyas,
     >                  ulsort, langue, codret )
          endif
c
c 3.2. ==> memorisation du nom de la fonction associee
c
          if ( codret.eq.0 ) then
c
          smem(adprpg+2) = nofonc(2,iaux)
c
          endif
c
        endif
c
   30 continue
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

