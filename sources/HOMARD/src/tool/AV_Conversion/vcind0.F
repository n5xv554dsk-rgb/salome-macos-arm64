      subroutine vcind0 ( nocind,
     >                    nocham, nbcomp, nbtvch, adnocp, adcaca,
     >                    ulsort, langue, codret)
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
c    aVant adaptation - Conversion d'INDicateur - phase 0
c     -                 -            ---                -
c recuperation des caracteristiques du champ contenant l'indicateur
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nrpass . e   .   1    . numero du passage                          .
c . nocind . e   . char*8 . nom de la structure contenant l'indicateur .
c . nocham .   s . char*8 . nom de la structure du champ               .
c . nbcomp .   s .   1    . nombre de composantes                      .
c . nbtvch .   s .   1    . nombre de tableaux du champ                .
c . adnocp .   s .   1    . adresse des noms des champ et composantes  .
c . adcaca .   s .   1    . adresse des caracteristiques caracteres    .
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
      parameter ( nompro = 'VCIND0' )
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
      integer nbcomp, nbtvch
      integer adnocp, adcaca
c
      character*8 nocind
      character*8 nocham
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nbcham, nbpafo, nbprof, nblopg
      integer adinch, adinpf, adinpr, adinlg
      integer typcha
      integer adcaen, adcare
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
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''On a '',i5,'' champs dans l''''indicateur'')'
      texte(1,5) = '(''Il en faut au moins 1 !'')'
      texte(1,6) = '(''1 suffirait !'')'
      texte(1,7) = '(/,''Objet du champ : '',a)'
      texte(1,8) = '(''Nombre de composantes :'',i8)'
      texte(1,9) = '(''Nombre de tableaux    :'',i8,//)'
c
      texte(2,4) = '(i5,'' fields are included in indicator.'')'
      texte(2,5) = '(''At least 1 is required !'')'
      texte(2,6) = '(''One would be enoUGh !'')'
      texte(2,7) = '(/,''Field object : '',a)'
      texte(2,8) = '(''Number of components :'',i8)'
      texte(2,9) = '(''Number of arrays     :'',i8,//)'
c
c====
c 2. analyse de la structure 'Solution' qui contient l'indicateur
c====
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nocind )
      call gmprsx (nompro, nocind//'.InfoCham' )
      call gmprsx (nompro, nocind//'.InfoPaFo' )
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCASO', nompro
#endif
      call utcaso ( nocind,
     >              nbcham, nbpafo, nbprof, nblopg,
     >              adinch, adinpf, adinpr, adinlg,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nbcham.ne.1 ) then
        write (ulsort,texte(langue,4)) nbcham
        if ( nbcham.eq.0 ) then
          write (ulsort,texte(langue,5))
        else
          write (ulsort,texte(langue,6))
        endif
        codret = 2
      endif
c
      endif
c
c====
c 3. caracteristiques du champ associe
c====
c
      if ( codret.eq.0 ) then
c
      nocham = smem(adinch)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) nocham
      call gmprsx (nompro, nocham )
      call gmprsx (nompro, nocham//'.Nom_Comp' )
      call gmprsx (nompro, nocham//'.Cham_Ent' )
      call gmprsx (nompro, nocham//'.Cham_Ree')
      call gmprsx (nompro, nocham//'.Cham_Car')
#endif
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
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,8)) nbcomp
      write (ulsort,texte(langue,9)) nbtvch
c
      endif
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
