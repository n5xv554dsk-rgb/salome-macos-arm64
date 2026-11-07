      subroutine pcset8 ( etanp1, tehn, tehnp1, typint,
     >                    prfcan, prfcap,
     >                    filtet, nbante, anfite,
     >                    nteeca, ntesca,
     >                    nbfonc, vafoen, vafott,
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
c    aPres adaptation - Conversion de Solution Elements de Volume -
c     -                 -             -        -           -
c                       Tetraedres d'etat anterieur 8
c                       -                           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . etanp1 . e   .    1   . ETAt du tetraedre a l'iteration N+1        .
c . tehn   . e   .    1   . TEtraedre courant en numerotation Homard   .
c .        .     .        . a l'iteration N                            .
c . tehnp1 . e   .    1   . TEtraedre courant en numerotation Homard   .
c .        .     .        . a l'iteration N+1                          .
c . typint . e   .   1    . type d'interpolation                       .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  elements : 0 si intensif, sans orientation.
c .        .     .        .             1 si extensif, sans orientation.
c .        .     .        .             2 si intensif, avec orientation.
c .        .     .        .             3 si extensif, avec orientation.
c .        .     .        .  noeuds : 1 si degre 1                     .
c .        .     .        .           2 si degre 2                     .
c .        .     .        .           3 si iso-P2                      .
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . nbante . e   .   1    . nombre de tetraedres decoupes par   .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfite . e   . nbante . tableau filtet du maillage de l'iteration n
c . nteeca . e   . reteto . numero des tetraedres dans le calcul entree.
c . ntesca . e   . rsteto . numero des tetraedres dans le calcul sortie.
c . nbfonc . e   .    1   . nombre de fonctions elements de volume     .
c . vafoen . e   . nbfonc*. variables en entree de l'adaptation        .
c .        .     . nbeven .                                            .
c . vafott . es  . nbfonc*. variables en sortie de l'adaptation        .
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
      parameter ( nompro = 'PCSET8' )
c
#include "nblang.h"
#include "fracta.h"
#include "fractc.h"
#include "fractf.h"
c
c 0.2. ==> communs
c
#include "nombte.h"
#include "nombsr.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer etanp1, tehn, tehnp1
      integer typint
      integer nbfonc
      integer prfcan(*), prfcap(*)
      integer filtet(nbteto)
      integer nbante
      integer anfite(nbante)
      integer nteeca(reteto), ntesca(rsteto)
c
      double precision vafoen(nbfonc,*)
      double precision vafott(nbfonc,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#ifdef _DEBUG_HOMARD_
      integer iaux
#endif
c
c     tecnp1 = TEtraedre courant en numerotation du Calcul a l'it. N+1
c
      integer tecnp1
c
c     f1hp = Fils 1er du tetraedre en numerotation Homard a l'it. N+1
c     f1cp = Fils 1er du tetraedre en numerota. du Calcul a l'it. N+1
c     f2cp = Fils 2eme du tetraedre en numerota. du Calcul a l'it. N+1
c     f3cp = Fils 3eme du tetraedre en numerota. du Calcul a l'it. N+1
c     f4cp = Fils 4eme du tetraedre en numerota. du Calcul a l'it. N+1

      integer f1hp
      integer f1cp, f2cp, f3cp, f4cp
c
c     f1hn = Fils 1er du tetraedre en numerotation Homard a l'it. N
c     f1cn = Fils 1er du tetraedre en numerotation du Calcul a l'it. N
c     f2cn = Fils 2eme du tetraedre en numerotation du Calcul a l'it. N
c     f3cn = Fils 3eme du tetraedre en numerotation du Calcul a l'it. N
c     f4cn = Fils 4eme du tetraedre en numerotation du Calcul a l'it. N
c     f5cn = Fils 5eme du tetraedre en numerotation du Calcul a l'it. N
c     f6cn = Fils 6eme du tetraedre en numerotation du Calcul a l'it. N
c     f7cn = Fils 7eme du tetraedre en numerotation du Calcul a l'it. N
c     f8cn = Fils 8eme du tetraedre en numerotation du Calcul a l'it. N
c
      integer f1hn
      integer f1cn, f2cn, f3cn, f4cn, f5cn, f6cn, f7cn, f8cn
c
      integer nrofon
      integer coderr
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
      coderr = 0
c
c 1.2. ==> on repere les numeros dans le calcul pour ses huit fils
c         a l'iteration n
c
      f1hn = anfite(tehn)
      f1cn = nteeca(f1hn)
      f2cn = nteeca(f1hn+1)
      f3cn = nteeca(f1hn+2)
      f4cn = nteeca(f1hn+3)
      f5cn = nteeca(f1hn+4)
      f6cn = nteeca(f1hn+5)
      f7cn = nteeca(f1hn+6)
      f8cn = nteeca(f1hn+7)
c
      if ( prfcan(f1cn).gt.0 .and. prfcan(f2cn).gt.0 .and.
     >     prfcan(f3cn).gt.0 .and. prfcan(f4cn).gt.0 .and.
     >     prfcan(f5cn).gt.0 .and. prfcan(f6cn).gt.0 .and.
     >     prfcan(f7cn).gt.0 .and. prfcan(f8cn).gt.0 ) then
c
c====
c 2. etan = 85, 86, 87 : le tetraedre etait coupe en 8
c====
c
c 2.1. ==> etanp1 = 0 : le tetraedre est reactive.
c             remarque : cela arrive seulement avec du deraffinement.
c
      if ( etanp1.eq.0 ) then
c
        tecnp1 = ntesca(tehnp1)
        prfcap(tecnp1) = 1
c
        if ( typint.eq.0 ) then
          do 210 , nrofon = 1, nbfonc
            daux = unshu * ( vafoen(nrofon,prfcan(f1cn))
     >                     + vafoen(nrofon,prfcan(f2cn))
     >                     + vafoen(nrofon,prfcan(f3cn))
     >                     + vafoen(nrofon,prfcan(f4cn))
     >                     + vafoen(nrofon,prfcan(f5cn))
     >                     + vafoen(nrofon,prfcan(f6cn))
     >                     + vafoen(nrofon,prfcan(f7cn))
     >                     + vafoen(nrofon,prfcan(f8cn)) )
            vafott(nrofon,tecnp1) = daux
 210     continue
        else
          do 211 , nrofon = 1, nbfonc
            daux = vafoen(nrofon,prfcan(f1cn))
     >           + vafoen(nrofon,prfcan(f2cn))
     >           + vafoen(nrofon,prfcan(f3cn))
     >           + vafoen(nrofon,prfcan(f4cn))
     >           + vafoen(nrofon,prfcan(f5cn))
     >           + vafoen(nrofon,prfcan(f6cn))
     >           + vafoen(nrofon,prfcan(f7cn))
     >           + vafoen(nrofon,prfcan(f8cn))
            vafott(nrofon,tecnp1) = daux
 211     continue
        endif
cgn        write(ulsort,7777) f1cn,f2cn,f3cn,f4cn,f
cgn        write(ulsort,7777) f1cn,f2cn,f3cn,f4cn,f5cn,f6cn,f7cn,f8cn,-1,
cgn     >                 tecnp1
cgn        write(81,7777) tecnp1
c
c 2.2. ==> etanp1 = 21, ...,26 : le tetraedre est decoupe en deux
c             c'est ce qui se passe quand un decoupage de conformite
c             est cree apres du deraffinement.
c             on donne la valeur moyenne de la fonction sur les huit
c             anciens fils a chaque nouveau fils.
c             remarque : on pourrait certainement faire mieux, avec des
c                        moyennes ponderees en fonction du recouvrement
c                        des anciennes et nouvelles filles. c'est trop
c                        complique pour que cela vaille le coup.
c             remarque : cela arrive seulement avec du deraffinement.
c
      elseif ( etanp1.ge.21 .and. etanp1.le.26 ) then
c
        f1hp = filtet(tehnp1)
        f1cp = ntesca(f1hp)
        f2cp = ntesca(f1hp+1)
        prfcap(f1cp) = 1
        prfcap(f2cp) = 1
        if ( typint.eq.0 ) then
          daux1 = unshu
        else
          daux1 = unsde
        endif
        do 22 , nrofon = 1, nbfonc
          daux = daux1 * ( vafoen(nrofon,prfcan(f1cn))
     >                   + vafoen(nrofon,prfcan(f2cn))
     >                   + vafoen(nrofon,prfcan(f3cn))
     >                   + vafoen(nrofon,prfcan(f4cn))
     >                   + vafoen(nrofon,prfcan(f5cn))
     >                   + vafoen(nrofon,prfcan(f6cn))
     >                   + vafoen(nrofon,prfcan(f7cn))
     >                   + vafoen(nrofon,prfcan(f8cn)) )
          vafott(nrofon,f1cp) = daux
          vafott(nrofon,f2cp) = daux
   22   continue
cgn        write(ulsort,7777) f1cn,f2cn,f3cn,f4cn,f5cn,f6cn,f7cn,f8cn,-1,
cgn     >                 f1cp,f2cp
cgn        write(82,7777) f1cp,f2cp
c
c 2.3. ==> etanp1 = 41, ..., 44 : le tetraedre est
c                      decoupe en quatre par une face.
c                       etanp1 = 45, 46, 47 : le tetraedre est decoupe
c                       en 4 par une diagonale
c             c'est ce qui se passe quand un decoupage de conformite
c             est cree apres du deraffinement.
c             on donne la valeur moyenne de la fonction sur les huit
c             anciens fils a chaque nouveau fils.
c             remarque : on pourrait certainement faire mieux, avec des
c                        moyennes ponderees en fonction du recouvrement
c                        des anciens et nouveaux fils. c'est trop
c                        complique pour que cela vaille le coup.
c             remarque : cela arrive seulement avec du deraffinement.
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
        if ( typint.eq.0 ) then
          daux1 = unshu
        else
          daux1 = unsqu
        endif
        do 23 , nrofon = 1, nbfonc
          daux = daux1 * ( vafoen(nrofon,prfcan(f1cn))
     >                   + vafoen(nrofon,prfcan(f2cn))
     >                   + vafoen(nrofon,prfcan(f3cn))
     >                   + vafoen(nrofon,prfcan(f4cn))
     >                   + vafoen(nrofon,prfcan(f5cn))
     >                   + vafoen(nrofon,prfcan(f6cn))
     >                   + vafoen(nrofon,prfcan(f7cn))
     >                   + vafoen(nrofon,prfcan(f8cn)) )
          vafott(nrofon,f1cp) = daux
          vafott(nrofon,f2cp) = daux
          vafott(nrofon,f3cp) = daux
          vafott(nrofon,f4cp) = daux
  23    continue
cgn        write(ulsort,7777) f1cn,f2cn,f3cn,f4cn,f5cn,f6cn,f7cn,f8cn,-1,
cgn     >                 f1cp,f2cp,f3cp,f4cp
cgn        write(83,7777) f1cp,f2cp,f3cp,f4cp
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
