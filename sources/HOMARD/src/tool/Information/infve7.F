      subroutine infve7 ( nubnvo,
     >                    nivtri, nivqua,
     >                    tritet, quahex,
     >                    facpyr, facpen,
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
c   INformation : Fichier VEctoriel - 7eme partie
c   --            -       --          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nubnvo .  s  .   *    . niveau des volumes                         .
c .        .     .        . Rangement :                                .
c .        .     .        . les tetraedres                             .
c .        .     .        . les hexaedres                              .
c .        .     .        . les pyramides                              .
c .        .     .        . les pentaedres                             .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'INFVE7' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nubnvo(*)
      integer nivtri(nbtrto)
      integer nivqua(nbquto)
      integer tritet(nbtecf,4)
      integer quahex(nbhecf,6)
      integer facpyr(nbpycf,5)
      integer facpen(nbpecf,5)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c_______________________________________________________________________
c
c====
c 1. prealables
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Niveaux des '',i10,1x,a)'
c
      texte(2,4) = '(''Levels for the '',i10,1x,a)'
c
c====
c 2. Niveaux des tetraedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbteto, mess14(langue,3,3)
#endif
      jaux = 0
c
      do 21 , iaux = 1 , nbteto
        nubnvo(jaux+iaux) = max( nivtri(tritet(iaux,1)),
     >                           nivtri(tritet(iaux,2)),
     >                           nivtri(tritet(iaux,3)),
     >                           nivtri(tritet(iaux,4)) )
   21 continue
c
c====
c 3. Niveaux des hexaedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbheto, mess14(langue,3,6)
#endif
      jaux = jaux + nbteto
c
      do 31 , iaux = 1 , nbheto
        nubnvo(jaux+iaux) = max( nivqua(quahex(iaux,1)),
     >                           nivqua(quahex(iaux,2)),
     >                           nivqua(quahex(iaux,3)),
     >                           nivqua(quahex(iaux,4)),
     >                           nivqua(quahex(iaux,5)),
     >                           nivqua(quahex(iaux,6)) )
   31 continue
c
c====
c 4. Niveaux des pyramides
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbpyto, mess14(langue,3,5)
#endif
      jaux = jaux + nbheto
c
      do 41 , iaux = 1 , nbpyto
        nubnvo(jaux+iaux) = max( nivtri(facpyr(iaux,1)),
     >                           nivtri(facpyr(iaux,2)),
     >                           nivtri(facpyr(iaux,3)),
     >                           nivtri(facpyr(iaux,4)),
     >                           nivqua(facpyr(iaux,5)) )
   41 continue
c
c====
c 5. Niveaux des pentaedres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbpeto, mess14(langue,3,7)
#endif
      jaux = jaux + nbpyto
c
      do 51 , iaux = 1 , nbpeto
        nubnvo(jaux+iaux) = max( nivtri(facpen(iaux,1)),
     >                           nivtri(facpen(iaux,2)),
     >                           nivqua(facpen(iaux,3)),
     >                           nivqua(facpen(iaux,4)),
     >                           nivqua(facpen(iaux,5)) )
   51 continue
c
c====
c 6. la fin
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
