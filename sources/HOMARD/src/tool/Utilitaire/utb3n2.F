      subroutine utb3n2 ( coonoe,
     >                    nbintx, nbbomx,
     >                    lglibo, ptnubo, listbo,
     >                    nbboit, boimin, boimax,
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
c    UTilitaire - Bilan - option 3 - phase N2
c    --           -              -         --
c ______________________________________________________________________
c
c Classe les noeuds par boite
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . nbintx . e   .    1   . nombre maximal d'intervalle                .
c . nbbomx . e   .    1   . nombre total de boites                     .
c . lglibo . e   .   1    . longueur de listbo                         .
c . ptnubo . es  .0:nbbomx. pointeur dans listbo                       .
c . listbo .  s  . lglibo . numero des noeuds dans chaque boite        .
c . nbboit .  s  .  sdim  . nombre de boite dans chaque direction      .
c . boimin . e   .0:nbintx. limite minimale de chaque boite            .
c . boimax . e   .0:nbintx. limite maximale de chaque boite            .
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
      parameter ( nompro = 'UTB3N2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      integer nbintx, nbbomx
      integer lglibo
      integer ptnubo(0:nbbomx), listbo(lglibo)
      integer nbboit(3)
c
      double precision coonoe(nbnoto,sdim)
      double precision boimin(3,0:nbintx), boimax(3,0:nbintx)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lgboin, boinoe(8)
      integer lenoeu, noedeb
      integer nbinte(3)
c
      double precision coord(3)
c
      integer nbmess
      parameter (nbmess = 10 )
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
      texte(1,2) = '(''Nombre maximal de boites : '',i10)'
c
      texte(2,2) = '(''Maximum number of boxes : '',i10)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,2)) nbbomx
#endif
c
      codret = 0
c
c 1.2. ==> Nombre d'intervalles
c
      do 12 , iaux = 1 , sdim
        nbinte(iaux) = nbboit(iaux) - 1
   12 continue
c
c====
c 2. Creation des listes
c====
c    au depart :
c    ptnubo(i) = position du dernier noeud de la boite i-1
c              = nombre cumule de noeuds pour les (i-1) premieres boites
c    a l'arrivee :
c    ptnubo(i) = position du dernier noeud de la boite i
c              = nombre cumule de noeuds pour les i premieres boites
c
c 2.0. ==> On controle tous les noeuds, sauf dans un cas : si le code
c          de calcul associe est Saturne_2D ou Neptune_2D, le maillage
c          est une couche 2D du maillage 3D. Dans ce cas, un noeud
c          supplementaire a ete cree pour memoriser les cotes mini
c          et maxi du maillage. Ce noeud etant isole se trouve en
c          premiere position. Il doit etre retire du controle car il
c          n'a pas de sens du point de vue du maillage.
c
      if ( typcca.eq.26 .or.
     >     typcca.eq.46 ) then
        noedeb = 2
      else
        noedeb = 1
      endif
c
cgn 3000 format(i10,3g12.5)
c
c 2.1. ==> en dimension 1
c
      if ( sdim.eq.1 ) then
c
        do 21 , lenoeu = noedeb , nbnoto
c
          coord(1) = coonoe(lenoeu,1)
cgn          write (ulsort,3000) lenoeu,coord(1)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3N5', nompro
#endif
          call utb3n5 ( lgboin, boinoe,
     >                  coord,
     >                  nbboit, nbinte,
     >                  boimin, boimax )
c
cgn          write(ulsort,*) 'lgboin =', lgboin
          do 211 , iaux = 1 , lgboin
cgn            write(ulsort,*) 'boinoe(',iaux,') =', boinoe(iaux)
            ptnubo(boinoe(iaux)) = ptnubo(boinoe(iaux)) + 1
            listbo(ptnubo(boinoe(iaux))) = lenoeu
  211     continue
c
   21   continue
cgn        write(ulsort,*) ptnubo
cgn        write(ulsort,*) listbo
c
c 2.2. ==> en dimension 2
c
      elseif ( sdim.eq.2 ) then
c
        do 22 , lenoeu = noedeb , nbnoto
c
          coord(1) = coonoe(lenoeu,1)
          coord(2) = coonoe(lenoeu,2)
cgn          write (ulsort,3000) lenoeu,coord(1), coord(2)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3N4', nompro
#endif
          call utb3n4 ( lgboin, boinoe,
     >                  coord,
     >                  nbboit, nbinte,
     >                  boimin, boimax )
c
cgn          write(ulsort,*) 'lgboin =', lgboin
          do 221 , iaux = 1 , lgboin
cgn            write(ulsort,*) 'boinoe(',iaux,') =', boinoe(iaux)
            ptnubo(boinoe(iaux)) = ptnubo(boinoe(iaux)) + 1
            listbo(ptnubo(boinoe(iaux))) = lenoeu
  221     continue
c
   22   continue
cgn        write(ulsort,*) ptnubo
cgn        write(ulsort,*) listbo
c
c 2.3. ==> en dimension 3
c
      else
c
        do 23 , lenoeu = noedeb , nbnoto
cgn      write (ulsort,*) lenoeu,(coonoe(lenoeu,iaux) , iaux = 1 , sdim)
c
          coord(1) = coonoe(lenoeu,1)
          coord(2) = coonoe(lenoeu,2)
          coord(3) = coonoe(lenoeu,3)
cgn          write (ulsort,3000) lenoeu,coord
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB3N3', nompro
#endif
          call utb3n3 ( lgboin, boinoe,
     >                  coord,
     >                  nbboit, nbinte,
     >                  boimin, boimax )
c
          do 231 , iaux = 1 , lgboin
            ptnubo(boinoe(iaux)) = ptnubo(boinoe(iaux)) + 1
            listbo(ptnubo(boinoe(iaux))) = lenoeu
  231     continue
c
   23   continue
c
      endif
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
#endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
