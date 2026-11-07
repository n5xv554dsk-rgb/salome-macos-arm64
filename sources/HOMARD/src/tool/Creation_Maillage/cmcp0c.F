      subroutine cmcp0c ( indtri, triint,
     >                    lesare,
     >                    areint, areqtr, niveau,
     >                    aretri, famtri, hettri,
     >                    filtri, pertri, nivtri,
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
c    Creation du Maillage - Conformite - decoupage des Pentaedres
c    -           -          -                          -
c                         - cas 0, phase C
c                               -        -
c    Construction des triangles internes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . triint .  s  .   3    . triangles internes au pentaedre            .
c .        .     .        .  1 = bordant la pyramide 1 uniquement      .
c .        .     .        .  2 = bordant la pyramide 2 uniquement      .
c .        .     .        .  3 = bordant les deux pyramides            .
c . lesare . e   .   3    . liste des aretes du pentaedre utiles       .
c .        .     .        .  1 = pyramide 1 et opposee a la face coupee.
c .        .     .        .  2 = pyramide 2 et opposee a la face coupee.
c .        .     .        .  3 = pyramide 1 et 2                       .
c . areint . e  .    1    . arete interne au pentaedre                 .
c . areqtr . e  .  (2,2) . aretes tri tracees sur les faces decoupees .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . famtri . es  . nouvtr . famille des triangles                      .
c . niveau . e   . 1      . niveau a attribuer aux triangles           .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : aucune arete ne correspond             .
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
      parameter ( nompro = 'CMCP0C' )
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
      integer indtri
      integer niveau
      integer triint(3)
      integer lesare(3)
      integer areint(1)
      integer areqtr(2,2)
      integer aretri(nouvtr,3), famtri(nouvtr)
      integer hettri(nouvtr), filtri(nouvtr), pertri(nouvtr)
      integer nivtri(nouvtr)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codetr
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
      codret = 0
c
      codetr = 1
c
c====
c 2. Les triangles s'appuient sur les 3 aretes non decoupees
c    triint(1) = dans la pyramide 1, l'arete non decoupee opposee
c                a la face triangulaire coupee
c    triint(2) = dans la pyramide 2, l'arete non decoupee opposee
c                a la face triangulaire coupee
c    triint(3) = triangle commun aux deux pyramides
c====
c
      indtri = indtri + 1
      triint(1) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_1', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areqtr(1,1), areint(1), lesare(1),
     >              codetr, niveau )
c
      indtri = indtri + 1
      triint(2) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_2', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areqtr(2,2), lesare(2), areint(1),
     >              codetr, niveau )
c
      indtri = indtri + 1
      triint(3) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_3', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areint(1), areqtr(1,2), lesare(3),
     >              codetr, niveau )
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
