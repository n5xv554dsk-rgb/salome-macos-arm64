      subroutine pcmaa0 ( rsarto,
     >                    hetare,
     >                    famare, cfaare,
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
c    aPres adaptation - Conversion - MAillage connectivite - Aretes
c     -                 -            --                      -
c    - phase 0
c            -
c ______________________________________________________________________
c
c remarque : pcmaar et pcmaa0 sont des clones
c remarque : pcmaa0, pcmat0 et pcmaq0 sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . rsarto .  s  .   1    . nombre d'aretes actives et du calcul       .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . famare . e   . nbarto . famille des aretes                         .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
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
      parameter ( nompro = 'PCMAA0' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "envca1.h"
c
#include "nbfami.h"
#include "nombar.h"
c
#include "dicfen.h"
c
c 0.3. ==> arguments
c
      integer rsarto
c
      integer hetare(nbarto)
c
      integer cfaare(nctfar,nbfare), famare(nbarto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer etat
      integer iaux
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
#include "impr06.h"
c
c====
c 2. Decompte des aretes actives et du calcul
c====
c
      rsarto = 0
c
      do 21 , iaux = 1 , nbarto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,1), iaux
      write (ulsort,texte(langue,12))
     >                     cotyel, cfaare(cotyel,famare(iaux))
#endif
c
        if ( cfaare(cotyel,famare(iaux)).ne.0 ) then
c
          etat = mod( hetare(iaux) , 10 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,13)) hetare(iaux), etat
#endif
c
          if ( etat.eq.0 .or. hierar.ne.0 ) then
c
            rsarto = nbarto
            goto 22
c
          endif
c
        endif
c
   21 continue
c
   22 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,18)) mess14(langue,3,1), rsarto
#endif
c
c====
c 3. la fin
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
