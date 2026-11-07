      subroutine utcach ( nocham,
     >                    nomcha,
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
c    UTilitaire - CAracteristiques d'un CHamp
c    --           --                    --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocham . e   . char8  . nom de l'objet champ                       .
c . nomcha .   s . char64 . nom du champ                               .
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
      parameter ( nompro = 'UTCACH' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      character*8 nocham
      character*64 nomcha
c
      integer nbcomp, nbtvch, typcha
      integer adnocp, adcaen, adcare, adcaca
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7
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
      texte(1,4) = '(''Nom du champ : '',a32)'
      texte(1,5) =
     >'(''. Composante '',i2,'' : '',a16,''(unite : '',a16,'')'')'
c
      texte(2,4) = '(''Name of the field : '',a32)'
      texte(2,5) =
     >'(''. Component '',i2,'' : '',a8,''(unit : '',a8,'')'')'
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nocham )
      call gmprsx (nompro, nocham//'.Nom_Comp' )
      call gmprsx (nompro, nocham//'.Cham_Ent' )
      call gmprsx (nompro, nocham//'.Cham_Ree' )
      call gmprsx (nompro, nocham//'.Cham_Car' )
#endif
c
c====
c 2. caracteristiques de l'objet contenant le champ
c====
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nocham, 1, nbcomp, codre1 )
      call gmliat ( nocham, 2, nbtvch, codre2 )
      call gmliat ( nocham, 3, typcha, codre3 )
      call gmadoj ( nocham//'.Nom_Comp', adnocp, iaux, codre4 )
      call gmadoj ( nocham//'.Cham_Ent', adcaen, iaux, codre5 )
      call gmadoj ( nocham//'.Cham_Ree', adcare, iaux, codre6 )
      call gmadoj ( nocham//'.Cham_Car', adcaca, iaux, codre7 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
c
      endif
c
c====
c 3. le nom du champ
c====
c
      if ( codret.eq.0 ) then
c
      iaux = 64
      call uts8ch ( smem(adnocp), iaux, nomcha,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nomcha
      do 31 , iaux = 1 , nbcomp
        write (ulsort,texte(langue,5)) iaux,
     >        smem(adnocp+3+iaux)//smem(adnocp+4+iaux),
     >        smem(adnocp+2*nbcomp+3+iaux)//smem(adnocp+2*nbcomp+4+iaux)
   31 continue
#endif
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
