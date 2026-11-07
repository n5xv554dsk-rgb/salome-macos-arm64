      subroutine cmchfb ( indtri, triint,
     >                    hettri, aretri, nivtri,
     >                    filtri, pertri, famtri,
     >                    areint, arefad, areqtr, niveau,
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
c                         - par 1 Face - utilitaire B
c                                 -                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . triint .  s  . (4,2)  . triangles appuyes sur la face coupee       .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . famtri . es  . nouvtr . famille des triangles                      .
c . niveau . e   . 1      . niveau a attribuer au triangle             .
c . areint . e   .    4   . numeros des aretes internes a l'hexaedre   .
c . arefad . e   .    4   . aretes internes a la face oupee en 4       .
c . areqtr . e   . (4,2)  . aretes internes au quadrangles coupes en 3 .
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
      parameter ( nompro = 'CMCHFB' )
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
      integer indtri, triint(4,2)
      integer hettri(nouvtr), aretri(nouvtr,3), nivtri(nouvtr)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer areint(4), arefad(4), areqtr(4,2)
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
c 2. triangles interieurs s'appuyant sur les aretes interieures
c    a la face coupee
c====
c
      iaux = 1
c
      triint(1,1) = indtri + 1
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              triint(1,1), arefad(1), areqtr(1,1), areint(1),
     >              iaux, niveau )
c
      triint(1,2) = indtri + 2
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              triint(1,2), arefad(1), areint(2), areqtr(1,2),
     >              iaux, niveau )
c
      triint(2,1) = indtri + 3
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              triint(2,1), arefad(2), areqtr(2,1), areint(2),
     >              iaux, niveau )
c
      triint(2,2) = indtri + 4
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              triint(2,2), arefad(2), areint(3), areqtr(2,2),
     >              iaux, niveau )
c
      triint(3,1) = indtri + 5
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              triint(3,1), arefad(3), areqtr(3,1), areint(3),
     >              iaux, niveau )
c
      triint(3,2) = indtri + 6
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              triint(3,2), arefad(3), areint(4), areqtr(3,2),
     >              iaux, niveau )
c
      triint(4,1) = indtri + 7
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              triint(4,1), arefad(4), areqtr(4,1), areint(4),
     >              iaux, niveau )
c
      triint(4,2) = indtri + 8
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              triint(4,2), arefad(4), areint(1), areqtr(4,2),
     >              iaux, niveau )
c
      indtri = triint(4,2)
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
