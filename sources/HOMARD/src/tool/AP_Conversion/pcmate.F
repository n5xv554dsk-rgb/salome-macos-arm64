      subroutine pcmate ( elemen, nbele0,
     >                    somare, np2are,
     >                    aretri,
     >                    tritet, cotrte, aretet,
     >                    hettet, famtet, cfatet,
     >                    nnosca, ntesca, ntesho,
     >                    famele, noeele, typele,
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
c    aPres adaptation - Conversion - MAillage connectivite - TEtraedres
c     -                 -            --                      --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . elemen . es  .   1    . numero du dernier element cree             .
c . nbele0 . e   .   1    . estimation du nombre d'elements            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero du noeud p2 milieu d'arete          .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . famtet . e   . nbteto . famille des tetraedres                     .
c . cfatet .     . nctfte. codes des familles des tetraedres          .
c .        .     . nbftet .   1 : famille MED                          .
c .        .     .        .   2 : type de tetraedres                   .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . nnosca . e   . rsnoto . numero des noeuds du code de calcul        .
c . ntesca .  s  . rsteto . numero des tetraedres du calcul            .
c . ntesho .  s  . nbele0 . numero des tetraedres dans HOMARD          .
c . famele . es  . nbele0 . famille med des elements                   .
c . noeele . es  . nbele0 . noeuds des elements                        .
c .        .     . *nbmane.                                            .
c . typele . es  . nbele0 . type des elements                          .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'PCMATE' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
#include "envca1.h"
c
#include "nbfami.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombte.h"
c
#include "nombsr.h"
c
#include "dicfen.h"
c
c 0.3. ==> arguments
c
      integer elemen
      integer nbele0
c
      integer somare(2,nbarto), np2are(nbarto)
      integer aretri(nbtrto,3)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hettet(nbteto)
c
      integer cfatet(nctfte,nbftet), famtet(nbteto)
c
      integer nnosca(rsnoto)
      integer ntesca(rsteto), ntesho(nbele0)
c
      integer famele(nbele0), noeele(nbele0,nbmane)
      integer typele(nbele0)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer letetr, letet0
      integer etat
      integer iaux
      integer listar(6), listso(4)
c
      integer nbmess
      parameter ( nbmess = 20 )
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbtecf, nbteca =', nbtecf, nbteca
#endif
c
#include "impr06.h"
c
c====
c 2. initialisations des renumerotations
c====
c
      do 21 , iaux = 1 , rsteto
        ntesca(iaux) = 0
   21 continue
c
      do 22 , iaux = 1 , nbele0
        ntesho(iaux) = 0
   22 continue
c
c====
c 3. Conversion en lineaire
c====
c
      if ( degre.eq.1 ) then
c
c                                    la face fi est opposee au sommet ni
c                     n1
c                     *
c                    .  ..
c                   .     . . a3
c                  .        .  .
c                 .           .   .
c             a1 .          a2  .    .  n4
c               .                 .    *
c              .                  . .   .
c             .        a4    .        .  . a6
c            .          .               . .
c           .      .                      ..
c          .  .                             .
c         *..................................*
c       n2               a5                  n3
c
        do 31 , letet0 = 1 , nbteto
c
          letetr = letet0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,3), letetr
#endif
c
          etat = mod( hettet(letetr) , 100 )
c
          if ( etat.eq.0 .or. hierar.ne.0 ) then
c
            elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,14)) elemen
            write (ulsort,*) 'triangles',(tritet(letetr,iaux),iaux=1,4)
#endif
            ntesho(elemen) = letetr
            ntesca(letetr) = elemen
c
            call utaste ( letetr,
     >                    nbtrto, nbtecf, nbteca,
     >                    somare, aretri,
     >                    tritet, cotrte, aretet,
     >                    listar, listso )
#ifdef _DEBUG_HOMARD_
            write (ulsort,90002) "sommets", listso
#endif
c
            noeele(elemen,1) = nnosca(listso(1))
            noeele(elemen,2) = nnosca(listso(2))
            noeele(elemen,3) = nnosca(listso(3))
            noeele(elemen,4) = nnosca(listso(4))
            famele(elemen) = cfatet(cofamd,famtet(letetr))
            typele(elemen) = cfatet(cotyel,famtet(letetr))
c
          endif
c
   31   continue
c
c====
c 4. Conversion en quadratique
c====
c
      else
c
c                                    la face fi est opposee au sommet ni
c                     n1
c                     *
c                    .  ..
c                   .     . . a3
c                  .        .  *n8
c                 .           .   .
c             a1 .          a2  *    .  n4
c             n5*               n7.    *
c              .                  . .   .
c             .        a5    .        .  . a6
c            .          *n9             . *n10
c           .      .                      ..
c          .  .                             .
c         *................*.................*
c       n2              a4 n6                n3
c
c
        do 41 , letet0 = 1 , nbteto
c
          letetr = letet0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,11)) mess14(langue,2,3), letetr
#endif
c
          etat = mod( hettet(letetr) , 100 )
c
          if ( etat.eq.0 .or. hierar.ne.0 ) then
c
            elemen = elemen + 1
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,14)) elemen
            write (ulsort,*) 'triangles',(tritet(letetr,iaux),iaux=1,3)
#endif
            ntesho(elemen) = letetr
            ntesca(letetr) = elemen
c
            call utaste ( letetr,
     >                    nbtrto, nbtecf, nbteca,
     >                    somare, aretri,
     >                    tritet, cotrte, aretet,
     >                    listar, listso )
#ifdef _DEBUG_HOMARD_
            write (ulsort,90002) "sommets", listso
#endif
c
            noeele(elemen,1)  = nnosca(listso(1))
            noeele(elemen,2)  = nnosca(listso(2))
            noeele(elemen,3)  = nnosca(listso(3))
            noeele(elemen,4)  = nnosca(listso(4))
            noeele(elemen,5)  = nnosca(np2are(listar(1)))
            noeele(elemen,6)  = nnosca(np2are(listar(4)))
            noeele(elemen,7)  = nnosca(np2are(listar(2)))
            noeele(elemen,8)  = nnosca(np2are(listar(3)))
            noeele(elemen,9)  = nnosca(np2are(listar(5)))
            noeele(elemen,10) = nnosca(np2are(listar(6)))
cgn            write (ulsort,*) (noeele(elemen,iaux),iaux=5,10)
            famele(elemen) = cfatet(cofamd,famtet(letetr))
            typele(elemen) = cfatet(cotyel,famtet(letetr))
c
          endif
c
   41   continue
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
