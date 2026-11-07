      subroutine mmag91 ( larete, ordre, nujois,
     >                    nbduno, tbau30,
     >                    somare,
     >                    aredup,
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
c    Modification de Maillage - AGRegat - phase 9.1
c    -               -          --              - -
c    Reperage des aretes liees aux joints simples formant
c    le joint multiple
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . larete . e   .   1    . arete support du joint multiple            .
c . ordre  . e   .   1    . ordre du joint a explorer                  .
c . nujois . e   . ordre  . numeros des joints simples associes        .
c . nbduno . e   .   1    . nombre de duplication de noeuds            .
c . tbau30 . e   .8*nbduno. Pour la i-eme duplication de noeud :       .
c .        .     .        . (1,i) : noeud a dupliquer                  .
c .        .     .        . (2,i) : arete construite sur le noeud      .
c .        .     .        . (3,i) : noeud cree cote min(fammed)        .
c .        .     .        . (4,i) : noeud cree cote max(fammed)        .
c .        .     .        . (5,i) : numero du joint simple cree        .
c .        .     .        . (6,i) : arete entrant dans le cote 1       .
c .        .     .        . (7,i) : arete entrant dans le cote 2       .
c .        .     .        . (8,i) : ordre de multiplicite              .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aredup .  s  .2*nbduno. aretes issues de la duplication            .
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
      parameter ( nompro = 'MMAG91' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer larete
      integer ordre, nujois(ordre)
      integer nbduno, tbau30(8,nbduno)
      integer somare(2,nbarto)
      integer aredup(2*ordre)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nbarlo
c
      integer nbmess
      parameter ( nbmess = 40 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
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
#include "impr03.h"
#include "mmag01.h"
#include "mmag02.h"
c
      codret = 0
c
c====
c 2. On explore tous les noeuds qui ont ete dupliques
c    On est bon quand :
c    . le noeud duplique est un des sommets de l'arete triple
c    . la duplication a lieu pour un des joints simples associes
c
c    On stocke les aretes qui partent de chacun des noeuds.
c====
c
      nbarlo = 0
c
      do 21 , iaux = 1 , nbduno
c
        do 211 , jaux = 1 , 2
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) '. ', mess14(langue,1,-1),
     >     somare(jaux,larete)
#endif
c
          if ( tbau30(1,iaux).eq.somare(jaux,larete) ) then
c
            do 2111 , kaux = 1 , ordre
c
c      write (ulsort,*) 'nujois(kaux) =', nujois(kaux)
c
              if ( tbau30(5,iaux).eq.nujois(kaux) ) then
                aredup(ordre*(jaux-1)+kaux) = tbau30(2,iaux)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,40)) mess14(langue,1,-1),
     >          tbau30(1,iaux),mess14(langue,1,1),tbau30(2,iaux)
#endif
                nbarlo = nbarlo + 1
                if ( nbarlo.eq.2*ordre ) then
                  goto 210
                endif
                goto 2110
              endif
 2111       continue
c
 2110       continue
c
          endif
c
  211   continue
c
   21 continue
c
c     Si on arrive ici, c'est que les aretes n'ont pas ete trouvees
c
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
      write (ulsort,texte(langue,38)) mess14(langue,3,-1)
      codret = 21
c
  210 continue
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
