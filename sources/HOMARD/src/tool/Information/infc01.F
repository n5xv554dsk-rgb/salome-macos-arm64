      subroutine infc01 ( nbtvch,
     >                    adinch,
     >                    nrcham, nomcha, typcha,
     >                    nbcomp, nomcom, unicom,
     >                    obcham, adcaen, adcare, adcaca,
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
c  INformation - inFormations Complementaires - phase 01
c  --              -          -                       --
c ______________________________________________________________________
c  Allocation de la branche des champs
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbtvch . e   .   1    . nombre de tableaux de valeurs du champ     .
c . adinch . e   .   1    . adresse de l'information sur les champs    .
c . adinpf . e   .   1    . adresse de l'inf. sur paquets de fonctions .
c . nrcham . e   .   1    . numero du champ a traiter                  .
c . nomcha . e   . char64 . nom du champ a traiter                     .
c . typcha . e   .   1    . edin64/edfl64 selon entier/reel            .
c . nbcomp . e   .   1    . nombre de composantes                      .
c . nomcom . e   . char16 . nom des composantes                        .
c . unicom . e   . char16 . unite des composantes                      .
c . obcham .  s  .   1    . nom de l'objet InfoCham cree               .
c . adcaen .  s  .   1    . adresse des caract. entieres du champ      .
c . adcare .  s  .   1    . adresse des caract. reelles du champ       .
c . adcaca .  s  .   1    . adresse des caract. caracteres du champ    .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'INFC01' )
c
#include "nblang.h"
#include "consts.h"
#include "esutil.h"
c
c 0.2. ==> communs
c
#include "gmstri.h"
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbtvch
      integer adinch
      integer nrcham, typcha
      integer nbcomp
      integer adcaen, adcare, adcaca
c
      character*8 obcham
      character*16 nomcom(nbcomp), unicom(nbcomp)
      character*64 nomcha
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer adnocp
c
      integer codre1, codre2, codre3
      integer codre0
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
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
      texte(1,4) = '(''Creation de la branche du champ '', a8)'
c
      texte(2,4) = '(''Creation of the field '', a8)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nomcha
      write (ulsort,90002) 'nbtvch', nbtvch
      write (ulsort,90002) 'typcha', typcha
      write (ulsort,90002) 'nbcomp', nbcomp
#endif
c
      codret = 0
c
c====
c 2. Allocation de la structure decrivant le champ
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Allocation ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmalot ( obcham, 'InfoCham', 0, iaux, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      smem(adinch+nrcham-1) = obcham
c
      call gmecat ( obcham, 2, nbtvch, codre1 )
      call gmecat ( obcham, 3, typcha, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 3. Composantes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Composantes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmecat ( obcham, 1, nbcomp, codre1 )
      iaux = 8 + 4*nbcomp + 2
      call gmaloj ( obcham//'.Nom_Comp', ' ', iaux, adnocp, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      do 31 , iaux = 1, 8
        smem(adnocp+iaux-1) = nomcha(8*(iaux-1)+1:8*iaux)
   31 continue
c
      do 32 , iaux = 1, nbcomp
        smem(adnocp+7+2*iaux-1) = nomcom(iaux)(1: 8)
        smem(adnocp+7+2*iaux  ) = nomcom(iaux)(9:16)
        smem(adnocp+7+2*nbcomp+2*iaux-1) = unicom(iaux)(1: 8)
        smem(adnocp+7+2*nbcomp+2*iaux  ) = unicom(iaux)(9:16)
   32 continue
c
      smem(adnocp+8+4*nbcomp) = blan08
      smem(adnocp+9+4*nbcomp) = blan08
c
      endif
c
c====
c 4. Info
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Info ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = nbtvch*nbinec
      call gmaloj ( obcham//'.Cham_Ent', ' ', iaux, adcaen, codre1 )
      iaux = nbtvch
      call gmaloj ( obcham//'.Cham_Ree', ' ', iaux, adcare, codre2 )
      iaux = nbtvch*nbincc
      call gmaloj ( obcham//'.Cham_Car', ' ', iaux, adcaca, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      call gmprsx ( nompro, obcham )
      call gmprsx ( nompro, obcham//'.Nom_Comp' )
      endif
#endif
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
