      subroutine utbotr ( nbtrto, nbteto, numead,
     >                    nivtri, filtri, pertri,
     >                    hettet, hetpyr,
     >                    voltri, pypetr,
     >                    bortri,
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
c    UTilitaire - BOrd - Triangles
c    --           --     --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbtrto . e   .   1    . nombre de triangles total                  .
c . nbteto . e   .   1    . nombre de tetraedres total                 .
c . numead . e   .   1    . numero de la mere adoptive                 .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . filtri . e   . nbtrto . fils des triangles                         .
c . pertri . e   . nbtrto . pere des triangles                         .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . e   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . bortri .  s  . nbtrto . reperage des triangles de bord             .
c .        .     .        . -1 : triangle non classe                   .
c .        .     .        .  0 : triangle bidimensionnel               .
c .        .     .        .  1 : triangle au bord d'un seul tetraedre  .
c .        .     .        .  2 : triangle entre 2 tetraedres           .
c .        .     .        .  3 : triangle de non conformite            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . sinon : probleme                           .
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
      parameter ( nompro = 'UTBOTR' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbtrto, nbteto, numead
      integer nivtri(nbtrto)
      integer filtri(nbtrto), pertri(nbtrto)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer bortri(nbtrto)
      integer hettet(*), hetpyr(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nbtr2d, nbtrbo, nbtrv2, nbtrv3, nbtrv4, nbtrnc
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) =
     > '(''Nombre de '',a,'' de regions bidimensionnelles :'',i10)'
      texte(1,5) =
     > '(''Nombre de '',a,'' de bord                      :'',i10)'
      texte(1,6) =
     > '(''Nombre de '',a,'' internes aux volumes         :'',i10)'
      texte(1,7) =
     > '(''Nombre de '',a,'' de non conformite            :'',i10)'
      texte(1,8) =
     > '(''Nombre de '',a,'' non classes                  :'',i10)'
c
      texte(2,4) =
     > '(''Number of '',a,'' in 2D regions     :'',i10)'
      texte(2,5) =
     > '(''Number of boundary '',a,''          :'',i10)'
      texte(2,6) =
     > '(''Number of '',a,'' inside of volume  :'',i10)'
      texte(2,7) =
     > '(''Number of non conformal '',a,''     :'',i10)'
      texte(2,8) =
     > '(''Number of '',a,'' without any place :'',i10)'
c
      codret = 0
c
c====
c 2. appel du programme generique
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTBOFA', nompro
#endif
      iaux = 2
      call utbofa ( iaux, numead,
     >              nbtrto, nbteto,
     >              nivtri, filtri, pertri,
     >              hettet, hetpyr,
     >              voltri, pypetr,
     >              bortri, nbtr2d, nbtrbo,
     >              nbtrv2, nbtrv3, nbtrv4, nbtrnc,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      iaux = 2
      write(ulsort,texte(langue,4)) mess14(langue,3,iaux), nbtr2d
      write(ulsort,texte(langue,5)) mess14(langue,3,iaux), nbtrbo
      write(ulsort,texte(langue,6)) mess14(langue,3,iaux), nbtrv2
      write(ulsort,texte(langue,7)) mess14(langue,3,iaux), nbtrnc
      write(ulsort,texte(langue,8)) mess14(langue,3,iaux),
     >                        nbtrto - nbtr2d - nbtrbo - nbtrv2 - nbtrnc
      endif
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
