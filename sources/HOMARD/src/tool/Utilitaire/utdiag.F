      subroutine utdiag ( lepere,
     >                    filtet, tritet, aretri,
     >                    arenoe, somare, cotrte,
     >                    ardiag, decoup, codret )
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
c    UTilitaire - Recherche de l'arete DIAGonale d'un tetraedre decoupe
c    --                                ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepere . e   .   1    . tetraedre pere dont on veut la diagonale   .
c . filtet . e   . nouvte . premier fils des tetraedres                .
c . tritet . e   .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . aretri . e   .nouvtr*3. numeros des 3 aretes des triangles         .
c . arenoe . e   . nouvno . arete liee a un nouveau noeud              .
c . somare . e   .2*nouvar. numeros des extremites d'arete             .
c . cotrte . e   .nouvtf*4. code des 4 triangles des tetraedres        .
c . ardiag .   s .   1    . numero de l'arete diagonale de decoupe     .
c . decoup .   s .   1    . type de decoupe du tetraedre (85, 86 ou 87).
c . codret .   s .   1    . code de retour, 0 si ok, (no tetra) si pb  .
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
c
c 0.2. ==> communs
c
#include "nouvnb.h"
#include "i1i2i3.h"
#include "indefi.h"
c
c 0.3. ==> arguments
c
      integer lepere, ardiag, decoup
      integer filtet(nouvte), tritet(nouvtf,4), aretri(nouvtr,3)
      integer arenoe(nouvno), somare(2,nouvar), cotrte(nouvtf,4)
      integer codret
c
c 0.4. ==> variables locales
c
      integer lefils, letria, numfac, iaux
      integer larete, numare, nbarte, aretet
      integer a1, a2, a3, a4, a5, a6
      integer listar(6)
c
c 0.5. ==> initialisations
c
      codret = 0
c ______________________________________________________________________
c
c remarque importante : le tetraedre teste est suppose vraiment decoupe,
c --------------------- donc le test de cet etat doit etre fait avant
c                       l'entree dans cette routine !
c
c====
c 1. recherche de la diagonale de decoupe du tetraedre
c    (recherche de l'arete commune des fils no 5 et 7 du bloc interne)
c====
c
c     pour cela, on etablit la liste des aretes du tetraedre no 5 dans
c     "listar" en parcourant les 3 premieres faces (la quatrieme
c     contient obligatoirement des aretes deja decrites), puis on
c     parcours de la meme maniere les 3 premieres faces du tetraedre
c     no 7 en regardant si chaque arete n'existe pas dans la liste.
c     celle qui existe est l'arete diagonale. Les boucles "do" sont
c     court-circuitees pour une recherche d'efficacite mais cet
c     avantage reste a verifier
c
      do 320 , iaux = 1 , 6
        listar(iaux) = 0
  320 continue
c
c 1.1 recherche de la liste des aretes du fils no 5
c
      lefils = filtet(lepere) + 4
c
      nbarte = 0
      do 340 , numfac = 1 , 3
c
        letria = tritet(lefils,numfac)
c
        do 342 , numare = 1 , 3
c
          larete = aretri(letria,numare)
c
          do 344 , iaux = 1 , nbarte
c
c           si l'arete existe deja dans la liste, on passe a la
c           suivante
c
            if ( larete.eq.listar(iaux) ) then
              goto 342
            endif
  344     continue
c
c         sinon on la stocke
c
          nbarte = nbarte + 1
          listar(nbarte) = larete
c
  342   continue
c
  340 continue
c
c 1.2 recherche d'une arete commune dans le fils no 7
c
      ardiag = iindef
      lefils = filtet(lepere) + 6
c
      do 350 , numfac = 1 , 3
c
        letria = tritet(lefils,numfac)
c
        do 352 , numare = 1 , 3
c
          larete = aretri(letria,numare)
c
          do 354 , iaux = 1 , nbarte
c
c           si l'arete existe deja dans la liste, elle est donc
c           commune et c'est l'arete diagonale. on arrete
c
            if ( larete.eq.listar(iaux) ) then
              ardiag = larete
              goto 360
            endif
c
  354     continue
c
  352   continue
c
  350 continue
c
  360 continue
c
c====
c 2.  recherche du type de decoupe du tetraedre (85, 86 ou 87)
c====
c
c 2.1 determination de l'arete du tetraedre "lepere" supportant le
c     premier noeud de l'arete "ardiag". on a alors une arete de type
c     a1, a2, a3, a4, a5 ou a6.
c
      aretet = arenoe(somare(1,ardiag))
c
c 2.2 on utilise les codes de faces du tetraedre "lepere" pour obtenir
c     le rang de chaque arete (de numero local a1 a a6) dans le
c     rangement "aretri". on a alors le numero global de chaque arete,
c     a comparer avec le numero global "aretet" de l'arete du tetraedre
c     supportant le premier noeud de l'arete de decoupe diagonale.
c
      decoup = 0
c
c 2.2.1 numero global de l'arete a1 (face f3, premiere arete i1)
c                  ou de l'arete a6 (face f1, troisieme arete i3)
c
      a1 = aretri(tritet(lepere,3),i1(cotrte(lepere,3)))
      a6 = aretri(tritet(lepere,1),i3(cotrte(lepere,1)))
c
      if (( a1.eq.aretet ).or.( a6.eq.aretet )) then
        decoup = 85
      endif
c
c 2.2.2 numero global de l'arete a2 (face f2, premiere arete i1)
c                  ou de l'arete a5 (face f1, seconde arete i2)
c
      a2 = aretri(tritet(lepere,2),i1(cotrte(lepere,2)))
      a5 = aretri(tritet(lepere,1),i2(cotrte(lepere,1)))
c
      if (( a2.eq.aretet ).or.( a5.eq.aretet )) then
        decoup = 86
      endif
c
c 2.2.3 numero global de l'arete a3 (face f2, seconde arete i2)
c                  ou de l'arete a4 (face f1, premiere arete i1)
c
      a3 = aretri(tritet(lepere,2),i2(cotrte(lepere,2)))
      a4 = aretri(tritet(lepere,1),i1(cotrte(lepere,1)))
c
      if (( a3.eq.aretet ).or.( a4.eq.aretet )) then
        decoup = 87
      endif
c
c 2.3 verification que la decoupe a ete trouvee
c
      if ( decoup.eq.0 ) then
        codret = lepere
      endif
c
      end
