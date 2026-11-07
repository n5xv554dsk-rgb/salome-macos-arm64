      subroutine eslsch ( nochso,
     >                    nbseal, adcact, adcaet, adcart,
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
c  Entree-Sortie - Lecture d'une Solution - les CHamps a lire
c  -      -        -             -              --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nochso . e   . char8  . nom de l'objet decrivant les chmps a lire  .
c .        .     .        . si blanc, on lit tous les champs du fichier.
c . nbseal .   s .    1   . nombre de sequences a lire                 .
c .        .     .        . si = -1, on lit tous les champs du fichier .
c . adcact .   s .    1   . adresse du champ CarCaChp de nochso        .
c . adcaet .   s .    1   . adresse du champ CarEnChp de nochso        .
c .        .     .        . 1. type de support au sens MED             .
c .        .     .        .  -1, si on prend tous les supports         .
c .        .     .        . 2. 1, si numero du pas de temps, 0 sinon   .
c .        .     .        . 3. numero du pas de temps                  .
c .        .     .        . 4. 1, si numero d'ordre, 0 sinon           .
c .        .     .        . 5. numero d'ordre                          .
c .        .     .        . 6. 1, si instant, 0 sinon                  .
c .        .     .        . 7. 1, si aux noeuds par elements, 0 sinon, .
c .        .     .        .   -1, si non precise                       .
c .        .     .        . 8. numero du champ noeuds/element associe  .
c .        .     .        . 9. numero du champ associe dans HOMARD     .
c .        .     .        . 10. type d'interpolation                   .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  1 si degre 1, 2 si degre 2, 3 si iso-P2   .
c .        .     .        . 11. 1, s'il fait partie du champ en cours  .
c .        .     .        .    d'examen, 0, sinon                      .
c .        .     .        . 12. type de champ edfl64/edin64            .
c . adcart .   s .    1   . adresse du champ CarReChp de nochso        .
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
      parameter ( nompro = 'ESLSCH' )
c
#include "nblang.h"
#include "consts.h"
c
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer nbseal, adcact, adcaet, adcart
c
      character*8 nochso
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer codre1, codre2, codre3, codre4
      integer codre0
c
      character*64 saux64
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
      texte(1,4) = '(/,''Lecture de tous les champs du fichier'')'
c
      texte(2,4) = '(/,''Readings of all fields from the file.'')'
c
#include "impr03.h"
c
c====
c 2. tous les champs sont a lire
c====
c
      if ( nochso.eq.blan08 ) then
c
        nbseal = -1
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4))
#endif
c
c====
c 3. on lit les champs enregistres
c====
c
      else
c
c 3.1. ==> reperage des informations stockees
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, nochso )
        call gmprsx (nompro, nochso//'.CarCaChp' )
        call gmprsx (nompro, nochso//'.CarEnChp' )
        call gmprsx (nompro, nochso//'.CarReChp' )
#endif
c
        call gmliat ( nochso, 1, nbseal, codre1 )
        call gmadoj ( nochso//'.CarCaChp', adcact, iaux, codre2 )
        call gmadoj ( nochso//'.CarEnChp', adcaet, iaux, codre3 )
        call gmadoj ( nochso//'.CarReChp', adcart, iaux, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
c 3.2. ==> impression
c
cgn      print *,nbseal
        if ( codret.eq.0 ) then
c
        do 32 , iaux = 1 , nbseal
c
          if ( codret.eq.0 ) then
c
          jaux = len(saux64)
          call uts8ch ( smem(adcact+8*(iaux-1)), jaux, saux64,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          call utlgut ( jaux, saux64, ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          write (ulsort,texte(langue,32)) saux64(1:jaux)
          if ( imem(adcaet+12*iaux-11).gt.0 ) then
            write (ulsort,texte(langue,113)) imem(adcaet+12*iaux-10)
          endif
          if ( imem(adcaet+12*iaux-9).gt.0 ) then
            write (ulsort,texte(langue,114)) imem(adcaet+12*iaux-8)
          endif
          if ( imem(adcaet+12*iaux-7).gt.0 ) then
            write (ulsort,texte(langue,115)) rmem(adcart+iaux-1)
          endif
          write (ulsort,*) ' '
c
          endif
c
   32   continue
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
