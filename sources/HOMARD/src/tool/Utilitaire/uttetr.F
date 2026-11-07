      subroutine uttetr ( decisi,
     >                    nbtrto, nbteto, nbtecf,
     >                    tritet, hettet, filtet, voltri,
     >                    ulsort, langue, codret )
c
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
c    UTilitaire - TEtraedres - TRiangles
c    --           --           --
c ______________________________________________________________________
c
c but : etablit le tableau voltri a partir de son reciproque, tritet
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . decisi . e   .   1    . pilotage des voisins des triangles :       .
c .        .     .        . 1 : on construit la table.                 .
c .        .     .        . 2 : on construit la table et on controle   .
c .        .     .        . a. qu'il n'y a pas de tetraedre doubles    .
c .        .     .        . b. qu'un triangle n'appartient pas a plus  .
c .        .     .        .    de 2 tetraedres                         .
c . nbtrto . e   .   1    . nombre de triangles total                  .
c . nbteto . e   .   1    . nombre de tetraedres total                 .
c . nbtecf . e   .   1    . nombre de tetraedres decrits par faces     .
c . tritet . e   .nbtecf*4. numeros des triangles des tetraedres       .
c . hettet . e   . nbtecf . historique des etats des tetraedres        .
c . filtet . e   . nbtecf . fils des tetraedres                        .
c . voltri .  s  .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme dans le controle              .
c .        .     .        . 3 : probleme de tetraedres doubles         .
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
      parameter ( nompro = 'UTTETR' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer decisi
      integer nbtrto, nbteto, nbtecf
      integer filtet(nbteto), hettet(nbteto), tritet(nbtecf,4)
      integer voltri(2,nbtrto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer codre1, codre2
      integer etat
      integer fils1, fils2
      integer letetr
      integer letria, tria(4), tribis(4), triacl(4), tribcl(4)
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
      texte(1,10) =
     > '(/,''Le triangle'',i10,'' a plus de deux voisins ?'')'
      texte(1,4) = '(''Volumes :'',3i10,/)'
      texte(1,5) =
     > '(/,''Les deux tetraedres suivants sont identiques.'')'
      texte(1,6) =
     > '(''Triangles du tetraedre numero :'',i10,'' : '',4i10)'
c
      texte(2,10) =
     > '(/,''Triangle'',i10,'' has more than 2 neighbours ?'')'
      texte(2,4) = '(''Volumes :'',3i10,/)'
      texte(2,5) = '(/,''The following two tetraedra are the same.'')'
      texte(2,6) = '(''Triangles of tetrahedron # :'',i10,'' : '',4i10)'
c
#include "impr03.h"
c
      iaux = 4
c
      codret = 0
c
c====
c 2. liste des tetraedres s'appuyant sur chaque triangle
c    attention : a priori, un triangle borde 0, 1 ou 2 tetraedres
c====
c
c 2. ==> on regarde tous les tetraedres decrits par leurs faces
c
      do 20 , letetr = 1 , nbtecf
c
c 2.1. ==> les triangles du tetraedre en cours d'examen
c
        tria(1) = tritet(letetr,1)
        tria(2) = tritet(letetr,2)
        tria(3) = tritet(letetr,3)
        tria(4) = tritet(letetr,4)
cgn             write(ulsort,90015) 'tetr', letetr,' : ', tria
c
c 2.2. ==> quand un tetraedre est decoupe en 2 pour la mise en
c          conformite, deux de ses triangles sont des bords du
c          tetraedre et de son fils.
c          La convention HOMARD veut que l'on ne memorise que le fils
c          dans les voisins du triangle.
c          on va alors annuler le numero du triangle pour ne rien
c          archiver maintenant.
c
        etat = mod ( hettet(letetr), 100 )
cgn          write(ulsort,1000) letetr,etat
        if ( etat.ge.21 .and. etat.le.26 ) then
c
          fils1 = filtet(letetr)
c
          if ( fils1.gt.0 ) then
c
            fils2 = fils1 + 1
            do 22 , letria = 1 , 4
              if ( tria(letria).eq.tritet(fils1,1) .or.
     >             tria(letria).eq.tritet(fils1,2) .or.
     >             tria(letria).eq.tritet(fils1,3) .or.
     >             tria(letria).eq.tritet(fils1,4) .or.
     >             tria(letria).eq.tritet(fils2,1) .or.
     >             tria(letria).eq.tritet(fils2,2) .or.
     >             tria(letria).eq.tritet(fils2,3) .or.
     >             tria(letria).eq.tritet(fils2,4) ) then
                   tria(letria) = 0
              endif
   22       continue
c
          endif
c
        endif
c
c 2.3. ==> pour chacun des 4 triangles encore a traiter
c
        do 23 , letria = 1 , 4
c
          if ( tria(letria).ne.0 ) then
c
c 2.3.1. ==> aucun voisin n'existe : on met le tetraedre courant
c            comme premier voisin
c
          if ( voltri(1,tria(letria)).eq.0 ) then
            voltri(1,tria(letria)) = letetr
c
          else
c
c 2.3.2. ==> il existe un premier voisin
c
c 2.3.2.1. ==> en cas de controle :
c
            if ( decisi.eq.2 ) then
c
c 2.3.2.1.1. ==> on verifie que le second tetraedre n'est pas identique
c                au premier. Pour cela, on trie les tableaux des
c                triangles par numero de triangles croissant et
c                on compare.
c
              if ( voltri(2,tria(letria)).eq.0 ) then
c
                if ( voltri(1,tria(letria)).gt.0 ) then
c
                  tribis(1) = tritet(voltri(1,tria(letria)),1)
                  tribis(2) = tritet(voltri(1,tria(letria)),2)
                  tribis(3) = tritet(voltri(1,tria(letria)),3)
                  tribis(4) = tritet(voltri(1,tria(letria)),4)
c
                  call uttrii ( triacl, jaux, kaux,
     >                          iaux, tria,
     >                          ulsort, langue, codre1 )
c
                  call uttrii ( tribcl, jaux, kaux,
     >                          iaux, tribis,
     >                          ulsort, langue, codre2 )
c
                  if ( codre1.eq.0 .and. codre2.eq.0 ) then
                    if ( tria(triacl(1)).eq.tribis(tribcl(1)) .and.
     >                   tria(triacl(2)).eq.tribis(tribcl(2)) .and.
     >                   tria(triacl(3)).eq.tribis(tribcl(3)) .and.
     >                   tria(triacl(4)).eq.tribis(tribcl(4)) ) then
                      write(ulsort,texte(langue,5))
                      write(ulsort,texte(langue,6)) letetr, tria
                      write(ulsort,texte(langue,6))
     >                                  voltri(1,tria(letria)), tribis
                      codret = 3
                    endif
                  else
                    codret = 1
                  endif
c
                endif
c
c 2.3.2.1.2. ==> il y a deja un second volume comme voisin de ce
c                triangle !
c
              else
c
                write(ulsort,texte(langue,10)) tria(letria)
                write(ulsort,texte(langue,4)) voltri(1,tria(letria)),
     >                                        voltri(2,tria(letria)),
     >                                        letetr
                codret = 3
c
              endif
c
            endif
c
c 2.3.2.2. ==> il existe un premier voisin : on met le tetraedre
c              courant comme second voisin
c
            voltri(2,tria(letria)) = letetr
c
          endif
c
          endif
c
   23   continue
c
   20 continue
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
