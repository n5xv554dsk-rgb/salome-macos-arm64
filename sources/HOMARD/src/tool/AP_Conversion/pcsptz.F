      subroutine pcsptz ( etan, etanp1, trhn, trhnp1,
     >                    prfcan, prfcap,
     >                    filtri,
     >                    ntreca, ntrsca,
     >                    nbfonc, ngauss, vafoen, vafott,
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
c    aPres adaptation - Conversion de Solution Points de Gauss -
c     -                 -             -        -
c                       Triangles d'etat anterieur Zero
c                       -                          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . etan   . e   .    1   . ETAt du triangle a l'iteration N           .
c . etanp1 . e   .    1   . ETAt du triangle a l'iteration N+1         .
c . trhn   . e   .    1   . TRiangle courant en numerotation Homard    .
c .        .     .        . a l'iteration N                            .
c . trhnp1 . e   .    1   . TRiangle courant en numerotation Homard    .
c .        .     .        . a l'iteration N+1                          .
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . ntreca . e   . retrto . numero des triangles dans le calcul entree .
c . ntrsca . e   . rstrto . numero des triangles du calcul en sortie   .
c . nbfonc . e   .    1   . nombre de fonctions elements de volume     .
c . ngauss . e   .   1    . nbre de points de Gauss des fonctions pg   .
c . vafoen . e   . nbfonc*. variables en entree de l'adaptation        .
c .        .     . ngauss*.                                            .
c .        .     . nbeven .                                            .
c . vafott . es  . nbfonc*. tableau temporaire de la solution          .
c .        .     . ngauss*.                                            .
c .        .     . nbevso .                                            .
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
      parameter ( nompro = 'PCSPTZ' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "nombtr.h"
#include "nombsr.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer etan, etanp1, trhn, trhnp1
      integer nbfonc, ngauss
      integer prfcan(*), prfcap(*)
      integer filtri(nbtrto)
      integer ntreca(retrto), ntrsca(rstrto)
c
      double precision vafoen(nbfonc,ngauss,*)
      double precision vafott(nbfonc,ngauss,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#ifdef _DEBUG_HOMARD_
      integer iaux
#endif
c
c     trcn   = TRiangle courant en numerotation Calcul a l'iteration N
c     trcnp1 = TRiangle courant en numerotation Calcul a l'iteration N+1
c
      integer trcn, trcnp1
c
c     f1hp = Fils 1er du triangle en numerotation Homard a l'it. N+1
c     f1cp = Fils 1er du triangle en numerota. du Calcul a l'it. N+1
c     f2cp = Fils 2eme du triangle en numerota. du Calcul a l'it. N+1
c     f3cp = Fils 3eme du triangle en numerota. du Calcul a l'it. N+1
c     f4cp = Fils 4eme du triangle en numerota. du Calcul a l'it. N+1
c
      integer f1hp
      integer f1cp, f2cp, f3cp, f4cp
c
      integer coderr
      integer nrofon, nugaus
c
      double precision daux
      double precision daux1
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     >'(/,''Triangle en cours : nro a l''''iteration '',a3,'' : '',i10)'
      texte(1,5) =
     > '(  ''                etat a l''''iteration '',a3,''   : '',i4)'
c
      texte(2,4) =
     >'(/,''Current triangle : # at iteration '',a3,''     : '',i10)'
      texte(2,5) =
     > '(  ''              status at iteration '',a3,'' : '',i4)'
c
#include "impr03.h"
c
      coderr = 0
c
c 1.2. ==> on repere son ancien numero dans le calcul
c
      trcn = ntreca(trhn)
c
c====
c 2. etan = 0 : le triangle etait actif
c    On explore tous les etats du triangle a l'iteration n+1
c====
c
      if ( prfcan(trcn).gt.0 ) then
c
c  ===> etanp1 = 0 : le triangle etait actif et l'est encore ;
c               il est inchange
c             c'est le cas le plus simple : on prend la valeur de la
c             fonction associee a l'ancien numero du triangle.
c                   .                         .
c                  . .                       . .
c                 .   .                     .   .
c                .     .                   .     .
c               .       .      ===>       .       .
c              .         .               .         .
c             .           .             .           .
c            .             .           .             .
c           .................         .................
c
      if ( etanp1.eq.0 ) then
c
        trcnp1 = ntrsca(trhnp1)
        prfcap(trcnp1) = 1
c
        do 21 , nrofon = 1 , nbfonc
cgn      write(ulsort,90014) nrofon,
cgn     >         (vafoen(nrofon,nugaus,trcn),nugaus=1,ngauss)
          do 211 , nugaus = 1 , ngauss
            vafott(nrofon,nugaus,trcnp1) =
     >                         vafoen(nrofon,nugaus,prfcan(trcn))
  211     continue
   21   continue
cgn        write(21,91010) trcnp1
cgn        write(ulsort,91010) trcn,-1,trcnp1
c
c ==> etanp1 = 1, 2, 3 : le triangle etait actif et est decoupe en 2.
c
      elseif ( etanp1.ge.1 .and. etanp1.le.3 ) then
c
        f1hp = filtri(trhnp1)
        f1cp = ntrsca(f1hp)
        f2cp = ntrsca(f1hp+1)
        prfcap(f1cp) = 1
        prfcap(f2cp) = 1
        daux1 = 1.d0/dble(ngauss)
        do 22 , nrofon = 1, nbfonc
          daux = vafoen(nrofon,1,prfcan(trcn))
          do 221 , nugaus = 2, ngauss
            daux = daux + vafoen(nrofon,nugaus,prfcan(trcn))
  221     continue
          daux = daux*daux1
          do 222 , nugaus = 1 , ngauss
            vafott(nrofon,nugaus,f1cp) = daux
            vafott(nrofon,nugaus,f2cp) = daux
  222     continue
   22   continue
c
c ==> etanp1 = 4,6,7,8 : le triangle etait actif et est decoupe en 4.
c
      elseif ( etanp1.eq.4 .or.
     >         ( etanp1.ge.6 .and. etanp1.le.8 ) ) then
c
        f1hp = filtri(trhnp1)
        f1cp = ntrsca(f1hp)
        f2cp = ntrsca(f1hp+1)
        f3cp = ntrsca(f1hp+2)
        f4cp = ntrsca(f1hp+3)
        prfcap(f1cp) = 1
        prfcap(f2cp) = 1
        prfcap(f3cp) = 1
        prfcap(f4cp) = 1
        daux1 = 1.d0/dble(ngauss)
        do 23 , nrofon = 1, nbfonc
          daux = vafoen(nrofon,1,prfcan(trcn))
          do 231 , nugaus = 2, ngauss
            daux = daux + vafoen(nrofon,nugaus,prfcan(trcn))
  231     continue
          daux = daux*daux1
          do 232 , nugaus = 1 , ngauss
            vafott(nrofon,nugaus,f1cp) = daux
            vafott(nrofon,nugaus,f2cp) = daux
            vafott(nrofon,nugaus,f3cp) = daux
            vafott(nrofon,nugaus,f4cp) = daux
  232     continue
   23   continue
c
c ==> aucun autre etat sur le triangle courant n'est possible
c
      else
c
        coderr = 1
        write (ulsort,texte(langue,4)) 'n  ', trhn
        write (ulsort,texte(langue,5)) 'n  ', etan
        write (ulsort,texte(langue,4)) 'n+1', trhnp1
        write (ulsort,texte(langue,5)) 'n+1', etanp1
c
      endif
c
      endif
c
c====
c 3. la fin
c====
c
      if ( coderr.ne.0 ) then
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) coderr
      codret = codret + 1
c
      endif
c
      end
