      subroutine pccapf ( nppafo, npfopa, nbcham, nocham,
     >                    nbpara, carenf, carchf,
     >                    option,
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
c    aPres adaptation - mise a jour des CAracteristiques
c     -                                 --
c                                   des Paquets de Fonctions
c                                       -          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nppafo . e   .    1   . nom du paquet de fonctions iteration p     .
c . npfopa . e   .   1    . nombre de fonctions a traiter              .
c . nbcham . e   .   1    . nombre de champs                           .
c . nocham . es  . nbcham . nom des objets qui contiennent la          .
c .        .     .        . description de chaque champ                .
c . nbpara . e   .   1    . nombre de parametres a enregistrer par fonc.
c . carenf .   s .nbpara* . caracteristiques entieres des fonctions :  .
c .        .     .  nnfopa.  1 : 0, pour une fonction ancienne isolee  .
c .        .     .        .      1, pour une ancienne associee a une   .
c .        .     .        .         autre fonction                     .
c .        .     .        .      -1, pour une nouvelle fonction        .
c .        .     .        .  2 : typcha                                .
c .        .     .        .  3 : typgeo                                .
c .        .     .        .  4 : typass                                .
c .        .     .        .  5 : ngauss                                .
c .        .     .        .  6 : nnenmx                                .
c .        .     .        .  7 : nnvapr                                .
c .        .     .        .  8 : carsup                                .
c .        .     .        .  9 : nbtafo                                .
c .        .     .        . 10 : anvale                                .
c .        .     .        . 11 : anvalr                                .
c .        .     .        . 12 : anobch                                .
c .        .     .        . 13 : adprpg                                .
c .        .     .        . 14 : anlipr                                .
c .        .     .        . 15 : npenmx                                .
c .        .     .        . 16 : npvapr                                .
c .        .     .        . 17 : apvale                                .
c .        .     .        . 18 : apvalr                                .
c .        .     .        . 19 : apobch                                .
c .        .     .        . 20 : apprpg                                .
c .        .     .        . 21 : apvatt                                .
c .        .     .        . 22 : apvane                                .
c .        .     .        . 23 : antyas                                .
c .        .     .        . 24 : aptyas                                .
c .        .     .        . 25 : numero de la 1ere fonction associee   .
c .        .     .        . 26 : numero de la 2nde fonction associee   .
c . carchf . es  .nbpara* . caracteristiques caracteres des fonctions :.
c .        .     .  nnfopa.  1 : nom de la fonction                    .
c .        .     .        .  2 : nom de la fonction n associee         .
c .        .     .        .  3 : nom de la fonction p associee         .
c .        .     .        .  4 : obpcan                                .
c .        .     .        .  5 : obpcap                                .
c .        .     .        .  6 : obprof                                .
c .        .     .        .  7 : oblopg                                .
c .        .     .        .  8 : si aux points de Gauss, nom de la     .
c .        .     .        .      fonction n ELNO correspondante        .
c .        .     .        .  9 : si aux points de Gauss, nom de la     .
c .        .     .        .      fonction p ELNO correspondante        .
c . option . e   .    1   . option du traitement                       .
c .        .     .        . -1 : Pas de changement dans le maillage    .
c .        .     .        .  0 : Adaptation complete                   .
c .        .     .        .  1 : Modification de degre                 .
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
      parameter ( nompro = 'PCCAPF' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbpara
      integer npfopa, nbcham
      integer carenf(nbpara,*)
      integer option
c
      character*8 nppafo
      character*8 nocham(nbcham)
      character*8 carchf(nbpara,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer nrfonc
      integer tbiaux(1)
      integer typgpf, ngauss, carsup, typint
      integer apobfo
c
      character*8 nnfonc
      character*8 npfonc, opprof, oplopg
      character*8 nnpafo
      character*8 tbsaux(1)
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(''Nom de la fonction '',a,'' numero'',i3,'' : '',a8)'
      texte(1,5) = '(''... Nom du profil = '',a8)'
      texte(1,6) = '(''... fonction nouvelle'')'
      texte(1,7) = '(''... fonction ancienne isolee'')'
      texte(1,8) = '(''... fonction ancienne associee a une autre'')'
      texte(1,9) = '(''Suppression de la fonction '',a)'
      texte(1,10) = '(''... '',a,'' : '',i6)'
      texte(1,11) =
     > '(''Remplacement du nom de la fonction dans le paquet :'')'
      texte(1,12) = '(3x,a,'' devient '',a)'
      texte(1,13) =
     > '(''Ajout du nom de la fonction '',a,'' dans le paquet'')'
      texte(1,20) = '(''Nombre de fonctions dans le paquet :'',i4)'
c
      texte(2,4) = '(''Name of the function '',a,'' #'',i3,'' : '',a8)'
      texte(2,5) = '(''... Name of the profile = '',a8)'
      texte(2,6) = '(''... new function'')'
      texte(2,7) = '(''... old lonesome function'')'
      texte(2,8) = '(''... old function connected to another one'')'
      texte(2,9) = '(''Deleting of the function '',a)'
      texte(2,10) = '(''... '',a,'' : '',i6)'
      texte(2,11) = '(''Change of function name in the pack'')'
      texte(2,12) = '(3x,a,'' becomes '',a)'
      texte(2,13) =
     > '(''Addition of function name '',a,'' to the pack'')'
      texte(2,20) = '(''Number of functions in the pack :'',i4)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,20)) npfopa
      write (ulsort,90002) 'option', option
#endif
c
c====
c 2. mise a jour des caracteristiques des fonctions
c====
c
      do 20 , nrfonc = 1 , npfopa
c
c 2.1. ==> mise a jour des caracteristiques des fonctions
c
        if ( codret.eq.0 ) then
c
cgn      write (ulsort,texte(langue,10)), 'nrfonc', nrfonc
cgn      write (ulsort,91010) (carenf(iaux,nrfonc),iaux=1,nbpara)
cgn      write (ulsort,93010) (carchf(iaux,nrfonc),iaux=1,nbpara)
c
        iaux = nrfonc
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCAFO', nompro
#endif
        call pccafo ( iaux, npfonc, opprof, oplopg,
     >                nbpara, carenf, carchf,
     >                option,
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) ' '
        write (ulsort,texte(langue,4)) 'p', nrfonc, npfonc
        write (ulsort,texte(langue,5)) opprof
        call gmprsx (nompro,npfonc)
        call gmprot (nompro,npfonc//'.ValeursR',1,20)
cgn        call gmprsx (nompro,npfonc//'.InfoPrPG')
#endif
c
c 2.2. ==> mise a jour des caracteristiques des champs
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2.2. mise a jour ; codret =', codret
#endif
c
        iaux = carenf(1,nrfonc)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7+iaux))
#endif
c
c 2.2.1. ==> remplacement quand la fonction existait deja
c
        if ( iaux.ge.0 ) then
c
          if ( codret.eq.0 ) then
c
          nnfonc = carchf( 2,nrfonc)
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,4)) 'n', nrfonc, nnfonc
          write (ulsort,texte(langue,11))
          write (ulsort,texte(langue,12)) nnfonc, npfonc
cgn        call gmprsx (nompro,nnfonc)
cgn        call gmprsx (nompro,nnfonc//'.InfoPrPG')
      write (ulsort,texte(langue,3)) 'PCCAC1', nompro
#endif
          call pccac1 ( nbcham, nocham,
     >                  nnfonc, npfonc, opprof, oplopg,
     >                  ulsort, langue, codret )
c
          endif
c
c 2.2.2. ==> ajout sinon
c
        else
c
          if ( codret.eq.0 ) then
c
          nnfonc = carchf( 3,nrfonc)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,4)) 'n', nrfonc, nnfonc
          write (ulsort,texte(langue,13)) npfonc
      write (ulsort,texte(langue,3)) 'PCCAC2', nompro
#endif
          call pccac2 ( npfonc, nnfonc,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
   20 continue
c
c====
c 3. suppression des anciennes fonctions
c    attention a ne le faire qu'a ce moment, car le nom connu peut
c    etre le meme pour plusieurs fonctions p dans le cas de conformite.
c    Si on le faisait dans la boucle 20, on perdrait tout !
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. suppression ; codret =', codret
#endif
c
      do 30 , nrfonc = 1 , npfopa
c
        if ( codret.eq.0 ) then
c
        iaux = carenf(1,nrfonc)
c
        if ( iaux.eq.0 ) then
c
          nnfonc = carchf( 2,nrfonc)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,9)) nnfonc
#endif
c
          call gmobal ( nnfonc, jaux )
c
          if ( jaux.eq.1 ) then
            call gmsgoj ( nnfonc , codret )
          elseif ( jaux.ne.0 ) then
            codret = 3
          endif
c
        endif
c
        endif
c
   30 continue
c
c====
c 4. degre du type geometrique
c====
c
      if ( option.eq.1 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTMOPF', nompro
#endif
      iaux = 6
      call utmopf ( nppafo, iaux,
     >              jaux, tbsaux, tbiaux,
     >              nnpafo,
     >              npfopa, typgpf, ngauss, carsup, typint,
     >              apobfo,
     >              ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 5. la fin
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
