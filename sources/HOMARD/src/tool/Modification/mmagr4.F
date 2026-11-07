      subroutine mmagr4 ( nbte06, tbaux5, tbaux6,
     >                    aretri,
     >                    tritet, cotrte,
     >                    famtet, cfatet,
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
c    Modification de Maillage - AGRegat - phase 4
c    -               -          ---             -
c    On marque chaque triangle et chaque arete avec la famille MED
c    du tetraedre voisin. Quand une arete ou un triangle est voisin
c    de deux familles differentes, la derniere valeur est gardee
c    mais peu importe car ces aretes/triangles sont ailleurs
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbte06 . e   .   1    . nombre de tetr. des j. ponctuels d'ordre 6 .
c . tbaux5 .  s  . nbarto . numero MED du volume de l'arete            .
c . tbaux6 .  s  . nbtrto . numero MED du volume du triangle           .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . famtet . e   . nbteto . famille des tetraedres                     .
c . cfatet . e   . nctfte. codes des familles des tetraedres           .
c .        .     . nbftet .   1 : famille MED                          .
c .        .     .        .   2 : type de tetraedres                   .
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
      parameter ( nompro = 'MMAGR4' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "coftex.h"
#include "nbfami.h"
#include "dicfen.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombte.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbte06
      integer tbaux5(nbarto), tbaux6(nbtrto)
      integer aretri(nbtrto,3)
      integer tritet(nbtecf,4), cotrte(nbtecf,4)
      integer famtet(nbteto), cfatet(nctfte,nbftet)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
c
      integer letetr
      integer listar(6)
      integer fammed
c
      integer nbmess
      parameter ( nbmess = 30 )
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
#include "mmag01.h"
c
c 1.2. ==> rien au depart
c
      do 121 , iaux = 1 , nbarto
        tbaux5(iaux) = 0
  121 continue
      do 122 , iaux = 1 , nbtrto
        tbaux6(iaux) = 0
  122 continue
c
      codret = 0
c
c====
c 2. Parcours des tetraedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,3,3)
#endif
c
      kaux = nbteto - nbte06
c
      do 21 , iaux = 1 , kaux
c
        letetr = iaux
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,3), letetr
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTARTE', nompro
#endif
        call utarte ( letetr,
     >                nbtrto, nbtecf,
     >                aretri, tritet, cotrte,
     >                listar )
c
        fammed = cfatet(cofamd,famtet(letetr))
cgn        write(ulsort,*) fammed
        do 211 , jaux = 1 , 6
          tbaux5(listar(jaux)) = fammed
  211   continue
        do 212 , jaux = 1 , 4
          tbaux6(tritet(letetr,jaux)) = fammed
  212   continue
c
   21 continue
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
