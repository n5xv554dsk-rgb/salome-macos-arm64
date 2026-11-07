      subroutine eslsm2 ( nbcham, nocham, nbseal,
     >                    nbfonc, defonc, nofonc, option,
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
c  Entree-Sortie - Lecture d'une Solution au format MED - phase 2
c  -      -        -             -                  -           -
c  En sortie, on a des tableaux caracteristiques des champs contenus
c  dans le fichier
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbcham . e   .   1    . nombre de champs a lire                    .
c . nocham . e   . nbcham . nom des objets qui contiennent la          .
c .        .     .        . description de chaque champ                .
c . nbseal . e   .    1   . nombre de sequences a lire                 .
c .        .     .        . si -1, on lit tous les champs du fichier   .
c . nbfonc .  s  .   1    . nombre de fonctions                        .
c . defonc .  s  . nbinec*. description des fonctions en entier        .
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
c . nofonc .   s .3*nbfonc. description des fonctions en caracteres    .
c .        .     .        . 1. nom de l'objet profil, blanc sinon      .
c .        .     .        . 2. nom de l'objet fonction                 .
c .        .     .        . 3. nom de l'objet localisation des points  .
c .        .     .        . de Gauss, blanc sinon                      .
c . option . e   .   1    . 1 : on controle que l'on a les couples (aux.
c .        .     .        . noeuds par element/aux points de Gauss)    .
c .        .     .        . 0 : pas de controle                        .
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
      parameter ( nompro = 'ESLSM2' )
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
      integer nbcham, nbfonc, nbseal
      integer defonc(nbinec,*)
      integer option
c
      character*8 nofonc(3,*)
      character*8 nocham(nbcham)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
c
      integer iaux
      integer adcaen, adcaca, adnocp
      integer nrocha, nbcomp
      integer nbtvch, carsup
      integer nrfonc
c
      character*8 obcham
      character*64 nomcha
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
      texte(1,4) = '(''Nombre de fonctions crees :'',i8)'
c
      texte(2,4) = '(''Number of existing functions :'',i8)'
c
#include "impr03.h"
c
#include "esimpr.h"
c
      nbfonc = 0
c
c====
c 2. reperage des fonctions par champ
c====
c
      if ( codret.eq.0 ) then
c
      do 20 , nrocha = 1 , nbcham
c
c 2.1. ==> structure decrivant le champ
c
        obcham = nocham(nrocha)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) ' '
        write (ulsort,texte(langue,37)) nompro, nrocha
        write (ulsort,texte(langue,51)) obcham
        call gmprsx (nompro, obcham )
cgn        call gmprsx (nompro, obcham//'.Cham_Ent' )
cgn        call gmprsx (nompro, obcham//'.Cham_Car' )
        call gmprsx (nompro, obcham//'.Nom_Comp' )
#endif
c
c 2.2. ==> informations sur le champ
c
        if ( codret.eq.0 ) then
c
        call gmliat ( obcham, 1, nbcomp, codre1 )
        call gmliat ( obcham, 2, nbtvch, codre2 )
        call gmadoj ( obcham//'.Cham_Ent', adcaen, iaux, codre3 )
        call gmadoj ( obcham//'.Cham_Car', adcaca, iaux, codre4 )
        call gmadoj ( obcham//'.Nom_Comp', adnocp, iaux, codre5 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5 )
c
        endif
c
        if ( codret.eq.0 ) then
          iaux = 64
          call uts8ch ( smem(adnocp), iaux, nomcha,
     >                  ulsort, langue, codret )
        endif
c
c 2.3. ==> rangement des tableaux de valeurs dans des fonctions
c
        if ( codret.eq.0 ) then
c
        if ( nbtvch.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLCH3', nompro
#endif
          iaux = nrocha
          call eslch3 ( iaux, nomcha, nbcomp, nbtvch,
     >                  imem(adcaen), smem(adcaca),
     >                  nbfonc, defonc, nofonc,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,4)) nbfonc
      endif
#endif
c
   20 continue
c
      endif
c
c====
c 3. gestion des couples (aux noeuds par elements / aux points de Gauss)
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. gestion des couples ; codret', codret
#endif
c
      if ( option.eq.1 ) then
c
      if ( codret.eq.0 ) then
c
      do 30 , nrfonc = 1 , nbfonc
c
c 3.1. ==> est-elle attachee a un champ aux noeuds par elements / aux
c          points de Gauss ?
c
        carsup = defonc (6,nrfonc)
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,65+carsup))
#endif
c
c 3.2. ==> si oui, on recherche la fonction associee
c
        if ( carsup.ge.1 .and. carsup.le.2 ) then
c
c 3.2.1. ==> recherche des caracteristiques de son champ
c
          if ( codret.eq.0 ) then
c
            nrocha = defonc (10,nrfonc)
            obcham = nocham(nrocha)
            call gmadoj ( obcham//'.Cham_Ent', adcaen, iaux, codret )
c
          endif
c
c 3.2.2. ==> recherche de la fonction associee
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLCH7', nompro
#endif
            call eslch7 ( nbtvch, imem(adcaen), nbseal,
     >                    carsup, nbfonc, defonc, nrfonc,
     >                    ulsort, langue, codret )
c
          endif
c
        endif
c
   30 continue
c
      endif
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

