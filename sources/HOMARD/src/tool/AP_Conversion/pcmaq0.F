      subroutine pcmaq0 ( rsquto,
     >                    hetqua,
     >                    famqua, cfaqua,
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
c    aPres adaptation - Conversion - MAillage connectivite -
c     -                 -            --
c                       QUadrangles - phase 0
c                       -                   -
c ______________________________________________________________________
c
c remarque : pcmaqu et pcmaq0 sont des clones
c remarque : pcmaa0, pcmat0 et pcmaq0 sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . rsquto . es  .   1    . nombre de quadrangles actifs et du calcul  .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
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
      parameter ( nompro = 'PCMAQ0' )
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
#include "nombqu.h"
c
#include "dicfen.h"
c
c 0.3. ==> arguments
c
      integer rsquto
c
      integer hetqua(nbquto)
c
      integer cfaqua(nctfqu,nbfqua), famqua(nbquto)
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
c 2. Decompte des quadrangles actifs et du calcul
c====
c
      rsquto = 0
c
      do 21 , iaux = 1 , nbquto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,4), iaux
      write (ulsort,texte(langue,12))
     >                     cotyel, cfaqua(cotyel,famqua(iaux))
#endif
c
        if ( cfaqua(cotyel,famqua(iaux)).ne.0 ) then
c
          etat = mod( hetqua(iaux) , 100 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,13)) hetqua(iaux), etat
#endif
c
          if ( etat.eq.0 .or. hierar.ne.0 ) then
c
            rsquto = nbquto
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
      write (ulsort,texte(langue,18)) mess14(langue,3,4), rsquto
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
