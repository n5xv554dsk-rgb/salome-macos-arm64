      subroutine utmoch ( nocham, option,
     >                    nomobj, npfonc,
     >                    nbcomp, nbtvch, typcha,
     >                    adnocp, adcaen, adcare, adcaca,
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
c    UTilitaire - MOdification d'un CHamp
c    --           --                --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocham . e   . char8  . nom de l'objet champ                       .
c . option . e   .    1   . option de la modification :                .
c .        .     .        . 1 : ajout de la fonction nomobj            .
c . nomobj . e   . char8  . nom de la fonction a ajouter               .
c . npfonc . e   . char8  . nom de la fonction associee                .
c . nbcomp .   s .   1    . nombre de composantes                      .
c . nbtvch .   s .   1    . nombre de tableaux du champ                .
c . typcha .   s .   1    . edin64/edfl64 selon entier/reel            .
c . adnocp .   s .   1    . adresse des noms des champ et composantes  .
c . adcaen .   s .   1    . adresse des caracteristiques entieres      .
c . adcare .   s .   1    . adresse des caracteristiques reelles       .
c . adcaca .   s .   1    . adresse des caracteristiques caracteres    .
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
      parameter ( nompro = 'UTMOCH' )
c
#include "nblang.h"
#include "esutil.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmstri.h"
#include "gmenti.h"
#include "gmreel.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbcomp, nbtvch, typcha
      integer adnocp, adcaen, adcare, adcaca
c
      character*8 nocham, nomobj, npfonc
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer codre1, codre2, codre3, codre4
      integer codre0
c
      integer nbtach
      integer typgeo, ngauss, nbenmx, nbvapr, nbtyas
      integer carsup, nbtafo, typint
      integer advale, advalr, adobch, adprpg, adtyas
c
      character*64 nomcha
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
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Champ avant modification :'')'
      texte(1,5) = '(''Champ apres modification :'')'
      texte(1,6) =
     > '(''Nombre initial de tableaux du champ         :'',i5)'
      texte(1,7) =
     > '(''Nombre de tableaux de la fonction a ajouter :'',i5)'
      texte(1,8) =
     > '(''Nombre final de tableaux du champ           :'',i5)'
c
      texte(2,4) = '(''Field before modification :'')'
      texte(2,5) = '(''Field after modification :'')'
      texte(2,6) =
     > '(''Initial number of arrays in the field        :'',i5)'
      texte(2,7) =
     > '(''Number of arrays in the function to be added :'',i5)'
      texte(2,8) =
     > '(''Final number of arrays in the field          :'',i5)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      call gmprsx (nompro, nocham )
      call gmprsx (nompro, nocham//'.Nom_Comp' )
      call gmprsx (nompro, nocham//'.Cham_Ent' )
cgn      call gmprsx (nompro, nocham//'.Cham_Ree' )
cgn      call gmprsx (nompro, nocham//'.Cham_Car' )
#endif
c
c====
c 2. caracteristiques de l'objet contenant le champ
c====
c
c 2.1. ==> nombre de tableaux de valeurs pour ce champ
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCACH', nompro
#endif
      call utcach ( nocham,
     >              nomcha,
     >              nbcomp, nbtvch, typcha,
     >              adnocp, adcaen, adcare, adcaca,
     >              ulsort, langue, codret )
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) nbtvch
#endif
c
c 2.2. ==> nombre de tableaux de valeurs pour ce champ et cette fonction
c
      if ( codret.eq.0 ) then
c
cgn      write(ulsort,*) 'au depart'
      nbtach = 0
c
      do 21 , iaux = 1 , nbtvch
c
        jaux = adcaca + nbincc*(iaux-1)
c
        if ( smem(jaux).eq.npfonc ) then
c
          nbtach = nbtach + 1
c
        endif
cgn      call gmprot (nompro, nocham//'.Cham_Ent',
cgn     >             nbinec*(iaux-1)+1, nbinec*iaux )
c
   21 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) nbtach
#endif
      endif
c
c====
c 3. ajout d'une fonction
c====
c
      if ( option.eq.1 ) then
c
c 3.1. ==> caracteristiques de la fonction
c
      if ( codret.eq.0 ) then
c
cgn      call gmprsx (nompro, nomobj )
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAFO', nompro
#endif
      call utcafo ( nomobj,
     >              typcha,
     >              typgeo, ngauss, nbenmx, nbvapr, nbtyas,
     >              carsup, nbtafo, typint,
     >              advale, advalr, adobch, adprpg, adtyas,
     >              ulsort, langue, codret )
c
      endif
c
c 3.2. ==> allongement de la structure pour accueillir les nbtafo
c          tableaux de la fonction
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nocham, 2, nbtvch+nbtach, codre1 )
      iaux = nbinec*(nbtvch+nbtach)
      call gmmod ( nocham//'.Cham_Ent',
     >             adcaen, nbinec*nbtvch, iaux, 1, 1, codre2 )
      iaux = nbtvch+nbtach
      call gmmod ( nocham//'.Cham_Ree',
     >             adcare, nbtvch, iaux, 1, 1, codre3 )
      iaux = nbincc*(nbtvch+nbtach)
      call gmmod ( nocham//'.Cham_Car',
     >             adcaca, nbincc*nbtvch, iaux, 1, 1, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
cgn      write(ulsort,*) 'apres 32'
cgn      call gmprot (nompro, nocham//'.Cham_Ent',  1, nbinec )
cgn      call gmprot (nompro, nocham//'.Cham_Ent', nbinec+1, 2*nbinec )
cgn      call gmprsx (nompro, nocham//'.Cham_Ent' )
cgn      call gmprsx (nompro, nocham//'.Cham_Car' )
c
c 3.3. ==> transfert des caracteristiques de la fonction
c          Rappel :
c       1. type de support au sens MED
c       2. numero du pas de temps
c       3. numero d'ordre
c       4. nombre de points de Gauss
c       5. nombre d'entites support
c       6. nombre de valeurs du profil eventuel
c       7. supports associes
c       8. noeuds par elements/points de Gauss/autre
c       9. numero du 1er tableau dans la fonction
c       10. -1 ou champ elga/champ elno
c       11. type interpolation
c       21-nbinec. type des supports associes
c
      if ( codret.eq.0 ) then
c
      do 33 , iaux = 1 , nbtach
c
        jaux = adcaen + nbinec*(nbtvch+iaux-1)
        imem(jaux)   = typgeo
        imem(jaux+3) = ngauss
        imem(jaux+4) = nbenmx
        imem(jaux+5) = nbvapr
        imem(jaux+6) = nbtyas
        imem(jaux+7) = carsup
        if ( carsup.ne.2 ) then
          imem(jaux+9) = 0
        endif
        imem(jaux+10) = typint
        if ( nbtyas.gt.0 ) then
          do 331 , kaux = 1 , nbtyas
            imem(jaux+19+kaux) = imem(adtyas+kaux-1)
  331     continue
        endif
c
        jaux = adcaca + nbincc*(nbtvch+iaux-1)
        smem(jaux  ) = nomobj
        smem(jaux+1) = smem(adprpg)
        smem(jaux+2) = smem(adprpg+1)
c
   33 continue
c
      endif
cgn      write(ulsort,*) 'apres 33'
cgn      call gmprot (nompro, nocham//'.Cham_Ent',  1, nbinec )
cgn      call gmprot (nompro, nocham//'.Cham_Ent', nbinec+1, 2*nbinec )
cgn      call gmprsx (nompro, nocham//'.Cham_Ent' )
cgn      call gmprsx (nompro, nocham//'.Cham_Car' )
c
c 3.4. ==> transfert des caracteristiques temporelles du champ
c          on doit recopier celles de la fonction associee
c
      if ( codret.eq.0 ) then
c
cgn      write(ulsort,*) 'apres 34'
      kaux = 0
c
      do 34 , iaux = 1 , nbtvch
c
        jaux = adcaca + nbincc*(iaux-1)
c
        if ( smem(jaux).eq.npfonc ) then
c
c         2. numero du pas de temps
          imem(adcaen+nbinec*(nbtvch+kaux)+1) =
     >    imem(adcaen+nbinec*(iaux-1)+1)
c         3. numero d'ordre
          imem(adcaen+nbinec*(nbtvch+kaux)+2) =
     >    imem(adcaen+nbinec*(iaux-1)+2)
c         9. numero du 1er tableau dans la fonction
          imem(adcaen+nbinec*(nbtvch+kaux)+8) =
     >    imem(adcaen+nbinec*(iaux-1)+8)
c
          rmem(adcare+(nbtvch+kaux))     = rmem(adcare+iaux-1)
c
          kaux = kaux + 1
cgn      call gmprot (nompro, nocham//'.Cham_Ent',
cgn     >             nbinec*(nbtvch+kaux-1)+1, nbinec*(nbtvch+kaux) )
c
        endif
c
   34 continue
c
      endif
cgn      call gmprot (nompro, nocham//'.Cham_Ent',  1, nbinec )
cgn      call gmprot (nompro, nocham//'.Cham_Ent', nbinec+1, 2*nbinec )
cgn      call gmprsx (nompro, nocham//'.Cham_Ent' )
cgn      call gmprsx (nompro, nocham//'.Cham_Car' )
c
c 3.5. ==> cumul du nombre total de tableaux pour le champ
c
      nbtvch = nbtvch + kaux
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) nbtvch
#endif
c
      endif
c
c====
c 4. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5))
      call gmprsx (nompro, nocham )
      call gmprsx (nompro, nocham//'.Nom_Comp' )
      call gmprsx (nompro, nocham//'.Cham_Ent' )
      call gmprsx (nompro, nocham//'.Cham_Ree' )
      call gmprsx (nompro, nocham//'.Cham_Car' )
#endif
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
