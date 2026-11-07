      subroutine cmchfc ( indtri, trigpy,
     >                    hettri, aretri, nivtri,
     >                    filtri, pertri, famtri,
     >                    areint, arext1, arext2, arext3, arext4,
     >                    niveau,
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
c    Creation du Maillage - Conformite - decoupage des Hexaedres
c    -           -          -                          -
c                         - par 1 Face - utilitaire C
c                                 -                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . trigpy .  s  .   4    . triangles bordant la grande pyramide       .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . famtri . es  . nouvtr . famille des triangles                      .
c . areint . e   .    4   . numeros des aretes internes a l'hexaedre   .
c . arextk . e   .   1    . numeros des aretes externes a l'hexaedre   .
c . niveau . e   . 1      . niveau a attribuer au triangle             .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : aucune face ne correspond              .
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
      parameter ( nompro = 'CMCHFC' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer indtri, trigpy(4)
      integer hettri(nouvtr), aretri(nouvtr,3), nivtri(nouvtr)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer areint(4)
      integer arext1, arext2, arext3, arext4
      integer niveau
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
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
      codret = 0
c
c====
c 2. triangles s'appuyant sur la face non decoupee
c====
c
      iaux = 1
c
      trigpy(1) = indtri + 1
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              trigpy(1), arext1, areint(2), areint(1),
     >              iaux, niveau )
c
      trigpy(2) = indtri + 2
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              trigpy(2), arext2, areint(3), areint(2),
     >              iaux, niveau )
c
      trigpy(3) = indtri + 3
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              trigpy(3), arext3, areint(4), areint(3),
     >              iaux, niveau )
c
      trigpy(4) = indtri + 4
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              trigpy(4), arext4, areint(1), areint(4),
     >              iaux, niveau )
c
      indtri = trigpy(4)
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
