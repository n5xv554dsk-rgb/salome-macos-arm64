      subroutine eslch3 ( nrocha, nomcha, nbcomp, nbtvch,
     >                    caraen, caraca,
     >                    nbfonc, defonc, nofonc,
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
c  Entree-Sortie - Lecture d'un CHamp au format MED - phase 3
c  -      -        -            --                          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nrocha . e   .    1   . numero du champ dans le rangement HOMARD   .
c . nomcha . e   . char64 . nom du champ                               .
c . nbcomp . e   .   1    . nombre de composantes                      .
c . nbtvch . e   .   1    . nombre de tableaux associes a ce champ     .
c . caraen . e   . nbinec*. caracteristiques entieres des tableaux du  .
c .        .     . nbtvch . champ en cours d'examen                    .
c .        .     .        . 1. type de support au sens MED             .
c .        .     .        .  -1, si on prend tous les supports         .
c .        .     .        . 2. numero du pas de temps                  .
c .        .     .        . 3. numero d'ordre                          .
c .        .     .        . 4. nombre de points de Gauss               .
c .        .     .        . 5. nombre d'entites support                .
c .        .     .        . 6. nombre de valeurs du profil eventuel    .
c .        .     .        . 7. nombre de supports associes             .
c .        .     .        . 8. 1, si aux noeuds par elements           .
c .        .     .        .    2, si aux points de Gauss, associe avec .
c .        .     .        .       un champ aux noeuds par elements     .
c .        .     .        .    3, si aux points de Gauss autonome      .
c .        .     .        .    0, sinon                                .
c .        .     .        . 9. numero du 1er tableau dans la fonction  .
c .        .     .        . 10. si champ elga, numero du champ elno    .
c .        .     .        .     si champ elno, numero du champ elga si .
c .        .     .        .     il existe, sinon -1                    .
c .        .     .        . 11. type interpolation                     .
c .        .     .        .       0, si automatique                    .
c .        .     .        .       1 si degre 1, 2 si degre 2,          .
c .        .     .        .       3 si iso-P2                          .
c .        .     .        . 12. type de champ edfl64/edin64            .
c .        .     .        . 21-nbinec. type des supports associes      .
c . caraca . e   . nbincc*. caracteristiques caracteres des tableaux   .
c .        .     . nbtvch . du champ en cours d'examen                 .
c .        .     .        . 1. nom de l'objet fonction                 .
c .        .     .        . 2. nom de l'objet profil, blanc sinon      .
c .        .     .        . 3. nom de l'objet localisation des points  .
c .        .     .        . de Gauss, blanc sinon                      .
c . nbfonc . es  .   1    . nombre de fonctions classees               .
c . defonc . es  . nbinec*. description des fonctions en entier        .
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
c .        .     .        . 21-20+(7). type des supports associes      .
c . nofonc .   s .3*nbfonc. description des fonctions en caracteres    .
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
      parameter ( nompro = 'ESLCH3' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "esutil.h"
#include "envex1.h"
#include "meddc0.h"
c
c 0.3. ==> arguments
c
      integer nrocha
      integer nbcomp, nbtvch
      integer nbfonc
      integer caraen(nbinec,nbtvch)
      integer defonc(nbinec,*)
c
      character*8 caraca(nbincc,nbtvch)
      character*8 nofonc(3,*)
      character*64 nomcha
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer typgeo
      integer nrotv, nrfonc
      integer ngauss, nbensu, nbvapr, nbtyas, carsup, typint, typcha
c
      logical trouve
c
      character*8 obprof, oblopg
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
      texte(1,4) = '(/,''Nom du champ : '',a)'
      texte(1,5) = '(''Numero du champ   :'',i5)'
      texte(1,6) = '(''Numero du tableau :'',i5)'
c
      texte(2,4) = '(/,''Field Name : '',a)'
      texte(2,5) = '(''Field #'',i5)'
      texte(2,6) = '(''Array #'',i5)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nomcha
      write (ulsort,texte(langue,5)) nrocha
      write (ulsort,90002) 'nbtvch', nbtvch
      write (ulsort,90002) 'nbcomp', nbcomp
#endif
c
c====
c 2. on parcourt tous les tableaux de ce champ
c====
c
      codret = 0
c
      do 21 , nrotv = 1 , nbtvch
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) nrotv
#endif
cgn      write (ulsort,*)(caraen(nrfonc,nrotv), nrfonc = 1 , nbinec)
c
c 2.1. ==> caracteristiques du tableau courant
c
        typgeo = caraen(1,nrotv)
        ngauss = caraen(4,nrotv)
        nbensu = caraen(5,nrotv)
        nbvapr = caraen(6,nrotv)
        nbtyas = caraen(7,nrotv)
        carsup = caraen(8,nrotv)
        typint = caraen(11,nrotv)
        typcha = caraen(12,nrotv)
        obprof = caraca(2,nrotv)
        oblopg = caraca(3,nrotv)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'typgeo', typgeo
      write (ulsort,90002) 'ngauss', ngauss
      write (ulsort,90002) 'nbensu', nbensu
      write (ulsort,90002) 'nbvapr', nbvapr
      write (ulsort,90002) 'nbtyas', nbtyas
      write (ulsort,90002) 'carsup', carsup
      write (ulsort,90002) 'typint', typint
      write (ulsort,90002) 'typcha', typcha
#endif
c
c 2.2. ==> on cherche quelle fonction deja enregistree a ces
c          caracteristiques
c          quand on l'a, on ajoute le nombre de composantes
c          si on ne la trouve pas, on en cree une
c
        trouve = .false.
c
        do 22 , nrfonc = 1 , nbfonc
c
          if ( defonc( 1,nrfonc).eq.typgeo .and.
     >         defonc( 2,nrfonc).eq.ngauss .and.
     >         defonc( 3,nrfonc).eq.nbensu .and.
     >         defonc( 4,nrfonc).eq.nbvapr .and.
     >         defonc( 5,nrfonc).eq.nbtyas .and.
     >         defonc( 6,nrfonc).eq.carsup .and.
     >         defonc(11,nrfonc).eq.typint .and.
     >         defonc(12,nrfonc).eq.typcha .and.
     >         nofonc(1,nrfonc).eq.obprof .and.
     >         nofonc(3,nrfonc).eq.oblopg ) then
c
            trouve = .true.
c
            if ( carsup.ne.0 ) then
              if ( defonc(10,nrfonc).ne.nrocha ) then
                trouve = .false.
              endif
            endif
c
            do 221 , iaux = 1, nbtyas
              if ( defonc(20+iaux,nrfonc) .ne.
     >             caraen(20+iaux,nrotv) ) then
                trouve = .false.
              endif
  221       continue
c
            if ( trouve ) then
#ifdef _DEBUG_HOMARD_
           write (ulsort,90002) 'Ajout de la composante numero ', nbcomp
           write (ulsort,90002) 'a la fonction numero ', nrfonc
#endif
              defonc(7,nrfonc) = defonc(7,nrfonc) + nbcomp
              goto 21
            endif
c
          endif
c
   22   continue
c
        nbfonc = nbfonc + 1
        defonc( 1,nrfonc) = typgeo
        defonc( 2,nrfonc) = ngauss
        defonc( 3,nrfonc) = nbensu
        defonc( 4,nrfonc) = nbvapr
        defonc( 5,nrfonc) = nbtyas
        defonc( 6,nrfonc) = carsup
        defonc( 7,nrfonc) = nbcomp
        defonc( 8,nrfonc) = 1
        defonc( 9,nrfonc) = 0
        defonc(10,nrfonc) = nrocha
        defonc(11,nrfonc) = typint
        defonc(12,nrfonc) = typcha
        do 220 , iaux = 1, nbtyas
          defonc(20+iaux,nrfonc) = caraen(20+iaux,nrotv)
  220   continue
        nofonc( 1,nrfonc) = obprof
        nofonc( 3,nrfonc) = oblopg
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) '============================================='
        write (ulsort,*) 'Creation d''une nouvelle fonction'
        write (ulsort,texte(langue,36)) nompro, nbfonc
        write (ulsort,texte(langue,64)) defonc(1,nrfonc)
        write (ulsort,texte(langue,57)) defonc(2,nrfonc)
        write (ulsort,texte(langue,58)) defonc(3,nrfonc)
        write (ulsort,texte(langue,62)) defonc(4,nrfonc)
        do 229 , iaux = 1, defonc(5,nrfonc)
          write (ulsort,texte(langue,60)) defonc(20+iaux,nrfonc)
  229   continue
        write (ulsort,texte(langue,111)) defonc(7,nrfonc)
        if ( nbvapr.gt.0 ) then
          write (ulsort,texte(langue,84)) nofonc(1,nrfonc)
        endif
        write (ulsort,texte(langue,65+carsup))
        if ( oblopg.ne.blan08 ) then
          write (ulsort,texte(langue,83)) nofonc(3,nrfonc)
        endif
        write (ulsort,*) '============================================='
#endif
c
   21 continue
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,4)) nomcha
      write (ulsort,texte(langue,65+carsup))
      write (ulsort,texte(langue,5)) nrocha
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
