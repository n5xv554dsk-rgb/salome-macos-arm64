      subroutine pcspt0 ( etan, etanp1, tehn, tehnp1,
     >                    prfcan, prfcap,
     >                    filtet,
     >                    nteeca, ntesca,
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
c                       Tetraedres d'etat anterieur 0
c                       -                           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . etan   . e   .    1   . ETAt du tetraedre a l'iteration N          .
c . etanp1 . e   .    1   . ETAt du tetraedre a l'iteration N+1        .
c . tehn   . e   .    1   . TEtraedre courant en numerotation Homard   .
c .        .     .        . a l'iteration N                            .
c . tehnp1 . e   .    1   . TEtraedre courant en numerotation Homard   .
c .        .     .        . a l'iteration N+1                          .
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . nteeca . e   . reteto . numero des tetraedres dans le calcul entree.
c . ntesca . e   . rsteto . numero des tetraedres dans le calcul sortie.
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
      parameter ( nompro = 'PCSPT0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "nombte.h"
#include "nombsr.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer etan, etanp1, tehn, tehnp1
      integer nbfonc, ngauss
      integer prfcan(*), prfcap(*)
      integer filtet(nbteto)
      integer nteeca(reteto), ntesca(rsteto)
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
c     tecn   = TEtraedre courant en numerotation du Calcul a l'it. N
c     tecnp1 = TEtraedre courant en numerotation du Calcul a l'it. N+1
c
      integer tecn, tecnp1
c
c     f1hp = Fils 1er du tetraedre en numerotation Homard a l'it. N+1
c     f1cp = Fils 1er du tetraedre en numerota. du Calcul a l'it. N+1
c     f2cp = Fils 2eme du tetraedre en numerota. du Calcul a l'it. N+1
c     f3cp = Fils 3eme du tetraedre en numerota. du Calcul a l'it. N+1
c     f4cp = Fils 4eme du tetraedre en numerota. du Calcul a l'it. N+1
c     f5cp = Fils 5eme du tetraedre en numerota. du Calcul a l'it. N+1
c     f6cp = Fils 6eme du tetraedre en numerota. du Calcul a l'it. N+1
c     f7cp = Fils 7eme du tetraedre en numerota. du Calcul a l'it. N+1
c     f8cp = Fils 8eme du tetraedre en numerota. du Calcul a l'it. N+1
c
      integer f1hp
      integer f1cp, f2cp, f3cp, f4cp, f5cp, f6cp, f7cp, f8cp
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
     >'(/,''Tetr. en cours : numero a l''''iteration '',a3,'' : '',i10)'
      texte(1,5) =
     >'(  ''                  etat a l''''iteration '',a3,''   : '',i4)'
c
      texte(2,4) =
     >'(/,''Current tetrahedron : # at iteration '',a3,''     : '',i10)'
      texte(2,5) =
     > '(  ''                     status at iteration '',a3,'' : '',i4)'
c
#include "impr03.h"
c
      coderr = 0
c
c 1.2. ==> on repere son ancien numero dans le calcul
c
      tecn = nteeca(tehn)
cgn        write (ulsort,texte(langue,4)) 'nca', tecn
cgn        write (ulsort,*) 'prfcan(tecn)', prfcan(tecn)
cgncc      if ( prfcan(tecn).eq.0 ) then
cgn        write (ulsort,texte(langue,4)) 'n  ', tehn
cgn        write (ulsort,texte(langue,5)) 'n  ', etan
cgncc      endif
c
c====
c 2. etan = 0 : le tetraedre etait actif
c    On explore tous les etats du tetraedre a l'iteration n+1
c====
c
      if ( prfcan(tecn).gt.0 ) then
c
c ===> etanp1 = 0 : le tetraedre etait actif et l'est encore ;
c               il est inchange
c             c'est le cas le plus simple : on prend la valeur de la
c             fonction associee a l'ancien numero du tetraedre.
c
      if ( etanp1.eq.0 ) then
c
        tecnp1 = ntesca(tehnp1)
        prfcap(tecnp1) = 1
c
cgn      write (ulsort,90002) 'tecnp1',tecnp1
        do 21 , nrofon = 1, nbfonc
          do 211 , nugaus = 1 , ngauss
cgn        write (ulsort,92010) vafoen(nrofon,nugaus,prfcan(tecn))
            vafott(nrofon,nugaus,tecnp1) =
     >                                vafoen(nrofon,nugaus,prfcan(tecn))
  211     continue
   21  continue
cgn        write(ulsort,91010) tecn,-1,tecnp1
c
c ==> etanp1 = 21, ..., 26 : le tetraedre etait actif et
c                  est decoupe en 2.
c            les deux fils prennent la valeur de la fonction sur le pere
c
      elseif ( etanp1.ge.21 .and. etanp1.le.26 ) then
c
        f1hp = filtet(tehnp1)
        f1cp = ntesca(f1hp)
        f2cp = ntesca(f1hp+1)
        prfcap(f1cp) = 1
        prfcap(f2cp) = 1
        daux1 = 1.d0/dble(ngauss)
        do 22 , nrofon = 1, nbfonc
          daux = vafoen(nrofon,1,prfcan(tecn))
cgn        write (ulsort,*) 'daux', daux
          do 221 , nugaus = 2, ngauss
            daux = daux + vafoen(nrofon,nugaus,prfcan(tecn))
  221     continue
          daux = daux*daux1
          do 222 , nugaus = 1 , ngauss
            vafott(nrofon,nugaus,f1cp) = daux
            vafott(nrofon,nugaus,f2cp) = daux
  222   continue
   22   continue
cgn        write(12,91010) f1cp,f2cp
cgn        write(ulsort,91010) tecn,-1,
cgn     >                     f1cp,f2cp
c
c ==> etanp1 = 41, ... 47 : le tetraedre etait actif et est
c                  decoupe en 4.
c            les quatre fils prennent la valeur de la fonction sur le
c            pere
c
      elseif ( etanp1.ge.41 .and. etanp1.le.47 ) then
c
        f1hp = filtet(tehnp1)
        f1cp = ntesca(f1hp)
        f2cp = ntesca(f1hp+1)
        f3cp = ntesca(f1hp+2)
        f4cp = ntesca(f1hp+3)
        prfcap(f1cp) = 1
        prfcap(f2cp) = 1
        prfcap(f3cp) = 1
        prfcap(f4cp) = 1
        daux1 = 1.d0/dble(ngauss)
        do 23 , nrofon = 1, nbfonc
          daux = vafoen(nrofon,1,prfcan(tecn))
          do 231 , nugaus = 2, ngauss
            daux = daux + vafoen(nrofon,nugaus,prfcan(tecn))
  231     continue
          daux = daux*daux1
          do 232 , nugaus = 1 , ngauss
            vafott(nrofon,nugaus,f1cp) = daux
            vafott(nrofon,nugaus,f2cp) = daux
            vafott(nrofon,nugaus,f3cp) = daux
            vafott(nrofon,nugaus,f4cp) = daux
  232   continue
   23   continue
cgn        write(13,91010) f1cp,f2cp,f3cp,f4cp
cgn        write(ulsort,91010) tecn,-1,
cgn     >                     f1cp,f2cp,f3cp,f4cp
c
c ==> etanp1 = 81, 86, 87 : le tetraedre etait actif et est
c                  decoupe en 8.
c            les huit fils prennent la valeur de la fonction sur le
c            pere
c
      elseif ( etanp1.ge.85 .and. etanp1.le.87 ) then
c
        f1hp = filtet(tehnp1)
        f1cp = ntesca(f1hp)
        f2cp = ntesca(f1hp+1)
        f3cp = ntesca(f1hp+2)
        f4cp = ntesca(f1hp+3)
        f5cp = ntesca(f1hp+4)
        f6cp = ntesca(f1hp+5)
        f7cp = ntesca(f1hp+6)
        f8cp = ntesca(f1hp+7)
        prfcap(f1cp) = 1
        prfcap(f2cp) = 1
        prfcap(f3cp) = 1
        prfcap(f4cp) = 1
        prfcap(f5cp) = 1
        prfcap(f6cp) = 1
        prfcap(f7cp) = 1
        prfcap(f8cp) = 1
        daux1 = 1.d0/dble(ngauss)
        do 24 , nrofon = 1, nbfonc
          daux = vafoen(nrofon,1,prfcan(tecn))
          do 241 , nugaus = 2, ngauss
            daux = daux + vafoen(nrofon,nugaus,prfcan(tecn))
  241     continue
          daux = daux*daux1
          do 242 , nugaus = 1 , ngauss
            vafott(nrofon,nugaus,f1cp) = daux
            vafott(nrofon,nugaus,f2cp) = daux
            vafott(nrofon,nugaus,f3cp) = daux
            vafott(nrofon,nugaus,f4cp) = daux
            vafott(nrofon,nugaus,f5cp) = daux
            vafott(nrofon,nugaus,f6cp) = daux
            vafott(nrofon,nugaus,f7cp) = daux
            vafott(nrofon,nugaus,f8cp) = daux
  242     continue
   24   continue
cgn        write(14,91010) f1cp,f2cp,f3cp,f4cp,f5cp,f6cp,f7cp,f8cp
cgn        write(ulsort,91010) tecn,-1,
cgn     >                     f1cp,f2cp,f3cp,f4cp,f5cp,f6cp,f7cp,f8cp
c
c ==> aucun autre etat sur le tetraedre courant n'est possible
c
      else
c
        coderr = 1
        write (ulsort,texte(langue,4)) 'n  ', tehn
        write (ulsort,texte(langue,5)) 'n  ', etan
        write (ulsort,texte(langue,4)) 'n+1', tehnp1
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
