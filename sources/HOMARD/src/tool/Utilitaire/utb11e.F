      subroutine utb11e ( option, nubloc, nublen,
     >                    somare,
     >                    aretri, arequa,
     >                    tritet, quahex, facpyr, facpen,
     >                    maxtet, maxhex, maxpyr, maxpen,
     >                    tabau3, tabau4,
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
c    UTilitaire - Bilan sur le maillage - option 11 - phase e
c    --           -                              --         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . 3 : les faces des volumes                  .
c .        .     .        . 2 : les aretes des faces                   .
c .        .     .        . 1 : les noeuds des aretes                  .
c . nubloc . e   .   1    . numero du bloc a traiter                   .
c . nublen . e   .   *    . numero de blocs des entites                .
c .        .     .        . Pour les volumes, ils sont ranges ainsi :  .
c .        .     .        . les tetraedres                             .
c .        .     .        . les hexaedres                              .
c .        .     .        . les pyramides                              .
c .        .     .        . les pentaedres                             .
c .        .     .        . Pour les faces, ils sont ranges ainsi :    .
c .        .     .        . les quadrangles                            .
c .        .     .        . les triangles                              .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . tabau3 .  s  . nbarto . Nombre d'occurences de l'arete dans le     .
c .        .     .        .  bloc de volumes                           .
c .        .     ./ nbnoto. Nombre d'occurences du noeud dans le       .
c .        .     .        .  bloc de volumes                           .
c . tabau4 .  s  .-nbquto . Nombre d'occurences de la face dans le     .
c .        .     . :nbtrto.  bloc de volumes                           .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB11E' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer option, nubloc, nublen(*)
      integer somare(2,nbarto)
      integer aretri(nbtrto,3), arequa(nbquto,4)
      integer tritet(nbtecf,4), quahex(nbhecf,6)
      integer facpyr(nbpycf,5), facpen(nbpecf,5)
      integer maxtet, maxhex, maxpyr, maxpen
      integer tabau3(*)
      integer tabau4(-nbquto:nbtrto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nument
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(''Bloc numero '',i8)'
      texte(1,5) = '(''Bloc de '',a)'
      texte(1,6) = '(''Traitement du '',a,i8)'
c
      texte(2,4) = '(Block # '',i8)'
      texte(2,5) = '(Block of '',i8)'
      texte(2,6) = '(''Treatment of '',a,i8)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nubloc
#endif
c
      codret = 0
c
c====
c 2. Recherche des faces du bloc volumique courant
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. bloc de volume ; codret =', codret
#endif
c
      if ( option.eq.3 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,9)
#endif
c
c 2.1. ==> Rien a priori
c
        do 21 , iaux = -nbquto , nbtrto
          tabau4(iaux) = 0
   21   continue
c
c 2.2. ==> On explore tous les volumes du bloc. On cumule les faces
c
        do 22 , nument = 1, maxpen
c
          if ( nublen(nument).eq.nubloc ) then
c
c 2.2.1. ==> Tetraedre
c
            if ( nument.le.maxtet ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,3), nument
#endif
c
              if ( nument.le.nbtecf ) then
c
              do 221 , iaux = 1 , 4
                tabau4(tritet(nument,iaux)) =
     >          tabau4(tritet(nument,iaux)) + 1
  221         continue
c
              endif
c
c 2.2.2. ==> Hexaedre
c
            elseif ( nument.le.maxhex ) then
c
              jaux = nument - maxtet
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,6), jaux
#endif
c
              if ( jaux.le.nbhecf ) then
c
              do 222 , iaux = 1 , 6
                tabau4(-quahex(jaux,iaux)) =
     >          tabau4(-quahex(jaux,iaux)) + 1
  222         continue
c
              endif
c
c 2.2.3. ==> Pyramide
c
            elseif ( nument.le.maxpyr ) then
c
              jaux = nument - maxhex
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,5), jaux
#endif
c
              if ( jaux.le.nbpycf ) then
c
              do 223 , iaux = 1 , 4
                tabau4(facpyr(jaux,iaux)) =
     >          tabau4(facpyr(jaux,iaux)) + 1
  223         continue
              tabau4(-facpyr(jaux,5)) =
     >        tabau4(-facpyr(jaux,5)) + 1
c
              endif
c
c 2.2.4. ==> Pentaedre
c
            else
c
              jaux = nument - maxpyr
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,7), jaux
#endif
c
              if ( jaux.le.nbpecf ) then
c
              do 2241 , iaux = 1 , 2
                tabau4(facpen(jaux,iaux)) =
     >          tabau4(facpen(jaux,iaux)) + 1
 2241         continue
              do 2242 , iaux = 3 , 5
                tabau4(-facpen(jaux,iaux)) =
     >          tabau4(-facpen(jaux,iaux)) + 1
 2242         continue
c
              endif
c
            endif
c
          endif
c
   22   continue
c
c====
c 3. Recherche des aretes du bloc surfacique courant
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. bloc de faces ; codret =', codret
#endif
c
      elseif ( option.eq.2 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,8)
#endif
c
c 3.1. ==> Rien a priori
c
        do 31 , iaux = 1 , nbarto
          tabau3(iaux) = 0
   31   continue
c
c 3.2. ==> On explore toutes les faces du bloc. On cumule les aretes
c
        do 32 , nument = -nbquto, nbtrto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,4), nument
cgn      write (ulsort,*) nublen(nbquto+1+nument)
#endif
c
          if ( nublen(nbquto+1+nument).eq.nubloc ) then
c
c 3.2.1. ==> Quadrangle
c
            if ( nument.lt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,4), nument
#endif
              do 321 , iaux = 1 , 4
                tabau3(arequa(-nument,iaux)) =
     >          tabau3(arequa(-nument,iaux)) + 1
  321         continue
c
c 3.2.2. ==> Triangle
c
            elseif ( nument.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,2), nument
#endif
              do 322 , iaux = 1 , 3
                tabau3(aretri(nument,iaux)) =
     >          tabau3(aretri(nument,iaux)) + 1
  322         continue
c
            endif
c
          endif
c
   32   continue
c
c====
c 4. Recherche des noeuds du bloc lineique courant
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. bloc d''aretes ; codret =', codret
#endif
c
      elseif ( option.eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,1)
#endif
c
c 4.1. ==> Rien a priori
c
        do 41 , iaux = 1 , nbnoto
          tabau3(iaux) = 0
   41   continue
c
c 4.2. ==> On explore toutes les aretes du bloc. On cumule les noeuds
c
        do 42 , nument = 1, nbarto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,1), nument
cgn      write (ulsort,*) nublen(nbquto+1+nument)
#endif
c
          if ( nublen(nument).eq.nubloc ) then
c
            do 421 , iaux = 1 , 2
              tabau3(somare(iaux,nument)) =
     >        tabau3(somare(iaux,nument)) + 1
  421       continue
c
          endif
c
   42   continue
c
      endif
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
