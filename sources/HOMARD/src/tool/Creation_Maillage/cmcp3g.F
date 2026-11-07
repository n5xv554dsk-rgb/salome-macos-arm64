      subroutine cmcp3g ( indtri, triint,
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
c                         - cas 3, phase G
c                               -        -
c    Construction des triangles internes
c    Remarque : cmcp3c et cmcp3g sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . triint .  s  .  17    . triangles internes au pentaedre            .
c .        .     .        .  1-4 = bordant la pyramide                 .
c .        .     .        .  5 = bordant la face f1                    .
c .        .     .        .  6 = bordant la face f2                    .
c .        .     .        .  7 = s'appuyant sur la derniere non coupee .
c .        .     .        .  8-11 = appuyes sur les filles des aretes  .
c .        .     .        .   coupees                                  .
c .        .     .        .  12-17 = appuyes sur une arete interne a   .
c .        .     .        .   une face coupee                          .
c . lesare . e   .   7    . liste des aretes du pentaedre utiles       .
c .        .     .        .  1-4 = les aretes de la pyramide           .
c .        .     .        .  5 = autre arete non decoupee face 1       .
c .        .     .        .  6 = autre arete non decoupee face 2       .
c .        .     .        .  7 = derniere arete non decoupee           .
c . areint . e  .    8    . aretes internes au pentaedre               .
c . areqtr . e   .(4,0:2) . aretes tri tracees sur les faces decoupees .
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
      parameter ( nompro = 'CMCP3G' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nouvnb.h"
#include "ope1a4.h"
c
c 0.3. ==> arguments
c
      integer indtri
      integer niveau
      integer triint(17)
      integer lesare(7)
      integer areint(8)
      integer areqtr(4,0:2)
      integer aretri(nouvtr,3), famtri(nouvtr)
      integer hettri(nouvtr), filtri(nouvtr), pertri(nouvtr)
      integer nivtri(nouvtr)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
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
c 2. Les triangles de la pyramide
c    triint(i) = triangle bordant la pyramide selon l'arete areint(i)
c====
c
      do 21 , iaux = 1 , 4
c
        jaux = per1a4(1,iaux)
c
        indtri = indtri + 1
        triint(iaux) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_1234', nompro
#endif
        call cmctri ( aretri, famtri, hettri,
     >                filtri, pertri, nivtri,
     >                indtri, areint(jaux), lesare(iaux), areint(iaux),
     >                codetr, niveau )
c
   21 continue
c
c====
c 3. Les triangles s'appuyant sur les 3 aretes non decoupees
c    triint(5) = triangle s'appuyant sur l'arete non decoupee, situee
c                sur la face f1
c    triint(6) = triangle s'appuyant sur l'arete non decoupee, situee
c                sur la face f2
c    triint(7) = triangle s'appuyant sur la derniere arete non decoupee
c====
c
      indtri = indtri + 1
      triint(5) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_5', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areint(5), lesare(5), areint(1),
     >              codetr, niveau )
c
      indtri = indtri + 1
      triint(6) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_6', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areint(6), lesare(6), areint(3),
     >              codetr, niveau )
c
      indtri = indtri + 1
      triint(7) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_7', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri,  areint(6),lesare(7),areint(5),
     >              codetr, niveau )
c
c====
c 4. Les triangles s'appuyant sur les filles des aretes coupees
c     triint(8) : 1/2 arete de la face F1, du cote pyramide
c     triint(9) : 1/2 arete de la face F1, de l'autre cote
c     triint(10) : 1/2 arete de la face F2, du cote pyramide
c     triint(11) : 1/2 arete de la face F2, de l'autre cote
c====
c
      indtri = indtri + 1
      triint(8) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_8', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areint(2), areqtr(3,0), areint(7),
     >              codetr, niveau )
c
      indtri = indtri + 1
      triint(9) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_9', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areint(7), areqtr(3,1), areint(5),
     >              codetr, niveau )

c
      indtri = indtri + 1
      triint(10) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_10', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areint(4), areqtr(4,0), areint(8),
     >              codetr, niveau )
c
      indtri = indtri + 1
      triint(11) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_11', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areint(8), areqtr(4,1), areint(6),
     >              codetr, niveau )
c
c====
c 5. Les triangles s'appuyant sur une arete interne a une face coupee
c     triint(12) : arete de la 1ere face quad , du cote pyramide
c     triint(13) : arete de la 1ere face quad , de l'autre cote
c     triint(14) : arete de la 2eme face quad , du cote pyramide
c     triint(15) : arete de la 2eme face quad , de l'autre cote
c     triint(16) : arete de la face F1
c     triint(17) : arete de la face F2
c====
c
      indtri = indtri + 1
      triint(12) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_12', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areint(7), areqtr(1,1), areint(3),
     >              codetr, niveau )
c
      indtri = indtri + 1
      triint(13) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_13', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areint(6), areqtr(1,2), areint(7),
     >              codetr, niveau )
c
      indtri = indtri + 1
      triint(14) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_14', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areint(8), areqtr(2,1), areint(1),
     >              codetr, niveau )
c
      indtri = indtri + 1
      triint(15) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_15', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areint(5), areqtr(2,2), areint(8),
     >              codetr, niveau )
c
      indtri = indtri + 1
      triint(16) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_16', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areint(7), areqtr(3,2), areint(1),
     >              codetr, niveau )
c
      indtri = indtri + 1
      triint(17) = indtri
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCTRI_17', nompro
#endif
      call cmctri ( aretri, famtri, hettri,
     >              filtri, pertri, nivtri,
     >              indtri, areint(8), areqtr(4,2), areint(3),
     >              codetr, niveau )
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
