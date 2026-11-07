      subroutine pcsptd ( etan, etanp1, trhn, trhnp1,
     >                    prfcan, prfcap,
     >                    hettri, filtri, nbantr, anfitr,
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
c                       Triangles d'etat anterieur Deux
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
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . nbantr . e   .   1    . nombre de triangles decoupes par           .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfitr . e   . nbantr . tableau filtri du maillage de l'iteration n.
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
      parameter ( nompro = 'PCSPTD' )
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
      integer hettri(nbtrto), filtri(nbtrto)
      integer nbantr
      integer anfitr(nbantr)
      integer ntreca(retrto), ntrsca(rstrto)
c
      double precision vafoen(nbfonc,ngauss,*)
      double precision vafott(nbfonc,ngauss,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
c     trcnp1 = TRiangle courant en numerotation Calcul a l'iteration N+1
c
      integer trcnp1
c
c     f1hp = Fils 1er du triangle en numerotation Homard a l'it. N+1
c     f1cp = Fils 1er du triangle en numerota. du Calcul a l'it. N+1
c     f2cp = Fils 2eme du triangle en numerota. du Calcul a l'it. N+1
c
      integer f1hp, fihp
      integer f1cp, f2cp
c
c     f1hn = Fils 1er du triangle en numerotation Homard a l'it. N
c     f1cn = Fils 1er du triangle en numerotation du Calcul a l'it. N
c     f2cn = Fils 2eme du triangle en numerotation du Calcul a l'it. N
c
      integer f1hn
      integer f1cn, f2cn
c
      integer iaux
      integer lglist, nrlist
      integer list(30)
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
c 1.2. ==> on repere les numeros dans le calcul pour ses deux fils
c          a l'iteration n
c
      f1hn = anfitr(trhn)
      f1cn = ntreca(f1hn)
      f2cn = ntreca(f1hn+1)
c
c====
c 2. etan = 1, 2, 3 : le triangle etait actif
c    On explore tous les etats du triangle a l'iteration n+1
c====
cgn      write (ulsort,90002) 'etanp1', etanp1
c
      if ( prfcan(f1cn).gt.0 .and. prfcan(f2cn).gt.0 ) then
c
c ===> etanp1 = 0 : le triangle est actif
c             Cela veut dire qu'il est reactive.
c             on lui attribue la valeur moyenne sur les deux anciens
c             fils.
c             remarque : cela arrive seulement avec du deraffinement.
c
      if ( etanp1.eq.0 ) then
c
        trcnp1 = ntrsca(trhnp1)
        prfcap(trcnp1) = 1
c
        daux1 = 1.d0/dble(2*ngauss)
        do 21 , nrofon = 1 , nbfonc
          daux = 0.d0
          do 211 , nugaus = 1, ngauss
            daux = daux + vafoen(nrofon,nugaus,prfcan(f1cn))
     >                  + vafoen(nrofon,nugaus,prfcan(f2cn))
  211     continue
          daux = daux*daux1
          do 212 , nugaus = 1 , ngauss
            vafott(nrofon,nugaus,trcnp1) = daux
  212     continue
   21   continue
c
c       etanp1 = etan : le triangle est decoupe en deux
c                       selon le meme decoupage.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation,
c             puis reproduit a la creation du maillage car les faces
c             autour n'ont pas change entre les deux iterations.
c             le fils prend la valeur de la fonction sur l'ancien
c             fils qui etait au meme endroit. comme la procedure de
c             numerotation est la meme (voir cmcdtr), le premier fils
c             est toujours le meme, le second egalement. on prendra
c             alors la valeur sur le fils de rang identique a
c             l'iteration n.
c
      elseif ( etanp1.eq.etan ) then
c
        f1hp = filtri(trhnp1)
        f1cp = ntrsca(f1hp)
        f2cp = ntrsca(f1hp+1)
        prfcap(f1cp) = 1
        prfcap(f2cp) = 1
        do 22 , nrofon = 1, nbfonc
          do 221 , nugaus = 1 , ngauss
            vafott(nrofon,nugaus,f1cp) =
     >                               vafoen(nrofon,nugaus,prfcan(f1cn))
            vafott(nrofon,nugaus,f2cp) =
     >                               vafoen(nrofon,nugaus,prfcan(f2cn))
  221     continue
   22   continue
c
c    etanp1 = 1, 2, 3 et different de etan : le triangle est decoupe
c             en deux mais par un autre decoupage.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation. il y
c             a du deraffinement dans la zone qui induisait le decoupage
c             de conformite et raffinement sur une autre zone.
c             on donne la valeur moyenne de la fonction sur les deux
c             anciens fils a chaque nouveau fils.
c             remarque : cela arrive seulement avec du deraffinement.
c
      elseif ( etanp1.ge.1 .and. etanp1.le.3 ) then
c
        f1hp = filtri(trhnp1)
        f1cp = ntrsca(f1hp)
        f2cp = ntrsca(f1hp+1)
        prfcap(f1cp) = 1
        prfcap(f2cp) = 1
        daux1 = 1.d0/dble(2*ngauss)
        do 23 , nrofon = 1 , nbfonc
          daux = 0.d0
          do 231 , nugaus = 1, ngauss
            daux = daux + vafoen(nrofon,nugaus,prfcan(f1cn))
     >                  + vafoen(nrofon,nugaus,prfcan(f2cn))
  231     continue
          daux = daux*daux1
          do 232 , nugaus = 1 , ngauss
            vafott(nrofon,nugaus,trcnp1) = daux
  232     continue
   23   continue
c
c    etanp1 = 4, 6, 7, 8 : le triangle est decoupe en 4
c             on donne la valeur moyenne de la fonction sur les deux
c             anciens fils a chaque nouveau fils.
c
      elseif ( etanp1.eq.4 .or.
     >         ( etanp1.ge.6 .and. etanp1.le.8 ) ) then
c
        f1hp = filtri(trhnp1)
        lglist = 0
        do 241 , nrlist = 1 , 4
          fihp = f1hp+nrlist-1
          iaux = mod(hettri(fihp),10)
          if ( iaux.eq.0 ) then
            lglist = lglist + 1
            list(lglist) = ntrsca(fihp)
          elseif ( iaux.ge.1 .and. iaux.le.3 ) then
            lglist = lglist + 1
            list(lglist) = ntrsca(filtri(fihp))
            lglist = lglist + 1
            list(lglist) = ntrsca(filtri(fihp)+1)
          else
            coderr = 1
          endif
  241   continue
c
        do 242 , nrlist = 1 , lglist
          prfcap(list(nrlist)) = 1
  242   continue
c
        daux1 = 1.d0/dble(2*ngauss)
        do 24 , nrofon = 1 , nbfonc
          daux = 0.d0
          do 243 , nugaus = 1, ngauss
            daux = daux + vafoen(nrofon,nugaus,prfcan(f1cn))
     >                  + vafoen(nrofon,nugaus,prfcan(f2cn))
  243     continue
          daux = daux*daux1
          do 244 , nugaus = 1, ngauss
            do 245 , nrlist = 1 , lglist
              vafott(nrofon,nugaus,list(nrlist)) = daux
  245       continue
  244     continue
   24   continue
c
c
c doc.0.erreur. ==> aucun autre etat sur le  courant elgnairt
c                   n'est possible
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
