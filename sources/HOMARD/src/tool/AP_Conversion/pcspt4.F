      subroutine pcspt4 ( etan, etanp1, tehn, tehnp1,
     >                    prfcan, prfcap,
     >                    hettet, filtet, nbante, anfite,
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
c    aPres adaptation - Conversion de Solution Points de Gauss-
c     -                 -             -        -
c                       Tetraedres d'etat anterieur 4
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
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . nbante . e   .   1    . nombre de tetraedres decoupes par   .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfite . e   . nbante . tableau filtet du maillage de l'iteration n
c . nteeca . e   . reteto . numero des tetraedres dans le calcul entree.
c . ntesca . e   . rsteto . numero des tetraedres dans le calcul sortie.
c . nbfonc . e   .    1   . nombre de fonctions elements de volume     .
c . ngauss . e   .   1    . nbre de points de Gauss des fonctions pg   .
c . vafoen . e   . nbfonc*. variables en entree de l'adaptation        .
c .        .     . ngauss* .                                            .
c .        .     . nbeven .                                            .
c . vafott . es  . nbfonc*. variables en sortie de l'adaptation        .
c .        .     . ngauss* .                                            .
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
      parameter ( nompro = 'PCSPT4' )
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
      integer hettet(nbteto), filtet(nbteto)
      integer nbante
      integer anfite(nbante)
      integer nteeca(reteto), ntesca(rsteto)
c
      double precision vafoen(nbfonc,ngauss,*)
      double precision vafott(nbfonc,ngauss,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
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
c
      integer f1hp, fihp
      integer f1cp, f2cp, f3cp, f4cp
c
c     f1hn = Fils 1er du tetraedre en numerotation Homard a l'it. N
c     f1cn = Fils 1er du tetraedre en numerotation du Calcul a l'it. N
c     f2cn = Fils 2eme du tetraedre en numerotation du Calcul a l'it. N
c     f3cn = Fils 3eme du tetraedre en numerotation du Calcul a l'it. N
c     f4cn = Fils 4eme du tetraedre en numerotation du Calcul a l'it. N
c
      integer f1hn
      integer f1cn, f2cn, f3cn, f4cn
c
      integer nrofon, nugaus
      integer coderr
c
      integer iaux
      integer lglist, nrlist
      integer list(30)
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
      coderr = 0
c ______________________________________________________________________
c
c 1.2. ==> on repere les numeros dans le calcul pour ses quatre fils
c          a l'iteration n
c
      f1hn = anfite(tehn)
      f1cn = nteeca(f1hn)
      f2cn = nteeca(f1hn+1)
      f3cn = nteeca(f1hn+2)
      f4cn = nteeca(f1hn+3)
c
      if ( prfcan(f1cn).gt.0 .and. prfcan(f2cn).gt.0 .and.
     >     prfcan(f3cn).gt.0 .and. prfcan(f4cn).gt.0 ) then
c
c====
c 2. etan = 41, ..., 44 : le tetraedre etait coupe en 4
c                  selon la face 1, 2, 3, 4
c====
c
      if ( etan.ge.41 .and. etan.le.44 ) then
c
c ===> etanp1 = 0 : le tetraedre est actif et est reactive.
c             on lui attribue la valeur moyenne sur les quatre anciens
c             fils.
c             remarque : cela arrive seulement avec du deraffinement.
c
        if ( etanp1.eq.0 ) then
c
          tecnp1 = ntesca(tehnp1)
          prfcap(tecnp1) = 1
c
          daux1 = 1.d0/dble(4*ngauss)
          do 21 , nrofon = 1, nbfonc
            daux = 0.d0
            do 211 , nugaus = 1, ngauss
              daux = daux + vafoen(nrofon,nugaus,prfcan(f1cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f2cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f3cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f4cn))
  211       continue
            daux = daux*daux1
            do 212 , nugaus = 1 , ngauss
              vafott(nrofon,nugaus,tecnp1) = daux
  212       continue
   21     continue
cgn        write (41,91010) f1cn,f2cn,f3cn,f4cn,-1,tecnp1
cgn        write (ulsort,91010) f1cn,f2cn,f3cn,f4cn,-1,tecnp1
cgn91010   format(I3)
c
c ===> etanp1 = 21, ...,26 : le tetraedre est decoupe en deux
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation,
c             puis reproduit a la creation du maillage car les faces
c             autour n'ont pas change entre les deux iterations.
c             remarque : cela arrive seulement avec du deraffinement.
c
        elseif ( etanp1.ge.21 .and. etanp1.le.26 ) then
c
          f1hp = filtet(tehnp1)
          f1cp = ntesca(f1hp)
          f2cp = ntesca(f1hp+1)
          prfcap(f1cp) = 1
          prfcap(f2cp) = 1
          daux1 = 1.d0/dble(4*ngauss)
          do 22 , nrofon = 1, nbfonc
            daux = 0.d0
            do 221 , nugaus = 1, ngauss
              daux = daux + vafoen(nrofon,nugaus,prfcan(f1cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f2cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f3cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f4cn))
  221       continue
            daux = daux*daux1
            do 222 , nugaus = 1 , ngauss
              vafott(nrofon,nugaus,f1cp) = daux
              vafott(nrofon,nugaus,f2cp) = daux
  222       continue
   22     continue
cgn        write(ulsort,91010) f1cn,f2cn,f3cn,f4cn,-1,
cgn     >                     f1cp,f2cp
cgn        write(42,91010) f1cp,f2cp
c
c doc.41-44.41-44. ===> etanp1 = etan : le tetraedre est decoupe en
c                       quatre selon le meme decoupage.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation,
c             puis reproduit a la creation du maillage car les faces
c             autour n'ont pas change entre les deux iterations.
c             le fils prend la valeur de la fonction sur l'ancien
c             fils qui etait au meme endroit. comme la procedure de
c             numerotation est la meme (voir cmcdte), le premier fils
c             est toujours le meme, le second egalement. on prendra
c             alors la valeur sur le fils de rang identique a
c             l'iteration n.
c
        elseif ( etanp1.eq.etan ) then
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
          do 23 , nrofon = 1, nbfonc
            do 231 , nugaus = 1 , ngauss
              vafott(nrofon,nugaus,f1cp) =
     >                                vafoen(nrofon,nugaus,prfcan(f1cn))
              vafott(nrofon,nugaus,f2cp) =
     >                                vafoen(nrofon,nugaus,prfcan(f2cn))
              vafott(nrofon,nugaus,f3cp) =
     >                                vafoen(nrofon,nugaus,prfcan(f3cn))
              vafott(nrofon,nugaus,f4cp) =
     >                                vafoen(nrofon,nugaus,prfcan(f4cn))
  231       continue
   23     continue
cgn        write(ulsort,91010) f1cn,f2cn,f3cn,f4cn,-1,
cgn     >                     f1cp,f2cp,f3cp,f4cp
cgn        write(43,91010) f1cp,f2cp,f3cp,f4cp
c
c ===> etanp1 = 41, ..., 44 et different de etan : le tetraedre est
c                   decoupe en quatre mais par un autre decoupage.
c ===> etanp1 = 45, 46 ou 47 : le tetraedre est
c                      decoupe en quatre par une diagonale.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation. il y
c             a du deraffinement dans la zone qui induisait le decoupage
c             de conformite et raffinement sur une autre zone.
c             on donne la valeur moyenne de la fonction sur les deux
c             anciens fils a chaque nouveau fils.
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
          daux1 = 1.d0/dble(4*ngauss)
          do 24 , nrofon = 1, nbfonc
            daux = 0.d0
            do 241 , nugaus = 1, ngauss
              daux = daux + vafoen(nrofon,nugaus,prfcan(f1cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f2cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f3cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f4cn))
  241       continue
            daux = daux*daux1
            do 242 , nugaus = 1 , ngauss
              vafott(nrofon,nugaus,f1cp) = daux
              vafott(nrofon,nugaus,f2cp) = daux
              vafott(nrofon,nugaus,f3cp) = daux
              vafott(nrofon,nugaus,f4cp) = daux
  242       continue
   24     continue
cgn        write(ulsort,91010) f1cn,f2cn,f3cn,f4cn,-1,
cgn     >                     f1cp,f2cp,f3cp,f4cp
cgn        write(44,91010) f1cp,f2cp,f3cp,f4cp
c
c ===> etanp1 = 85, 86 ou 87 : le tetraedre est
c                      decoupe en huit par une diagonale.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation, puis
c             remis differement car l'environnement a change.
c             on donne la valeur moyenne de la fonction sur les quatre
c             anciens fils a chaque nouveau fils.
c             attention : il est possible que les fils sur les bords
c                         soient decoupes par de la conformite. Il faut
c                         alors transmettre la valeur a leurs 2 ou 4
c                         fils.
c             attention : ce n'est pas comme en 2D ; il faut examiner
c                         tous les fils, car par contamination de faces
c                         coupees en 2, les fils centraux peuvent etre
c                         decoupes.
c
        elseif ( etanp1.ge.85 .and. etanp1.le.87 ) then
c
          f1hp = filtet(tehnp1)
          lglist = 0
          do 251 , nrlist = 1 , 8
            fihp = f1hp+nrlist-1
            iaux = mod(hettet(fihp),100)
            if ( iaux.eq.0 ) then
              lglist = lglist + 1
              list(lglist) = ntesca(fihp)
            elseif ( iaux.ge.21 .and. iaux.le.26 ) then
              lglist = lglist + 1
              list(lglist) = ntesca(filtet(fihp))
              lglist = lglist + 1
              list(lglist) = ntesca(filtet(fihp)+1)
            elseif ( iaux.ge.41 .and. iaux.le.47 ) then
              lglist = lglist + 1
              list(lglist) = ntesca(filtet(fihp))
              lglist = lglist + 1
              list(lglist) = ntesca(filtet(fihp)+1)
              lglist = lglist + 1
              list(lglist) = ntesca(filtet(fihp)+2)
              lglist = lglist + 1
              list(lglist) = ntesca(filtet(fihp)+3)
            else
              coderr = 1
            endif
  251     continue
c
          do 252 , nrlist = 1 , lglist
            prfcap(list(nrlist)) = 1
  252     continue
c
          daux1 = 1.d0/dble(4*ngauss)
          do 25 , nrofon = 1, nbfonc
            daux = 0.d0
            do 253 , nugaus = 1, ngauss
              daux = daux + vafoen(nrofon,nugaus,prfcan(f1cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f2cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f3cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f4cn))
  253       continue
            daux = daux*daux1
            do 254 , nugaus = 1 , ngauss
              do 255 , nrlist = 1 , lglist
                vafott(nrofon,nugaus,list(nrlist)) = daux
  255         continue
  254       continue
   25     continue
cgn        write(ulsort,91010) f1cn,f2cn,f3cn,f4cn,-1,
cgn     >                   (list(nrlist),nrlist = 1 , lglist)
cgn        write(46,91010) (list(nrlist),nrlist = 1 , lglist)
c
c doc.41-44.erreur. ==> aucun autre etat sur le tetraedre courant
c                       n'est possible
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
c====
c 3. doc.45-47.p. ==> etan = 45, 46, 47 : le tetraedre etait coupe en 4
c                  selon une diagonale
c====
c
      elseif ( etan.ge.45 .and. etan.le.47 ) then
c
c ===> etanp1 = 0 : le tetraedre est actif et est reactive.
c             on lui attribue la valeur moyenne sur les quatre anciens
c             fils.
c             remarque : cela arrive seulement avec du deraffinement.
c
        if ( etanp1.eq.0 ) then
c
          tecnp1 = ntesca(tehnp1)
          prfcap(tecnp1) = 1
c
          daux1 = 1.d0/dble(4*ngauss)
          do 31 , nrofon = 1, nbfonc
            daux = 0.d0
            do 311 , nugaus = 1, ngauss
              daux = daux + vafoen(nrofon,nugaus,prfcan(f1cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f2cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f3cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f4cn))
  311       continue
            daux = daux*daux1
            do 312 , nugaus = 1 , ngauss
              vafott(nrofon,nugaus,tecnp1) = daux
  312       continue
   31     continue
cgn        write(ulsort,91010) f1cn,f2cn,f3cn,f4cn,-1,
cgn     >                     tecnp1
cgn        write(51,91010) tecnp1
c
c ===> etanp1 = 21, ...,26 : le tetraedre est decoupe en deux
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation,
c             puis reproduit a la creation du maillage car les faces
c             autour n'ont pas change entre les deux iterations.
c             remarque : cela arrive seulement avec du deraffinement.
c
        elseif ( etanp1.ge.21 .and. etanp1.le.26 ) then
c
          f1hp = filtet(tehnp1)
          f1cp = ntesca(f1hp)
          f2cp = ntesca(f1hp+1)
          prfcap(f1cp) = 1
          prfcap(f2cp) = 1
          daux1 = 1.d0/dble(4*ngauss)
          do 32 , nrofon = 1, nbfonc
            daux = 0.d0
            do 321 , nugaus = 1, ngauss
              daux = daux + vafoen(nrofon,nugaus,prfcan(f1cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f2cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f3cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f4cn))
  321       continue
            daux = daux*daux1
            do 322 , nugaus = 1 , ngauss
              vafott(nrofon,nugaus,f1cp) = daux
              vafott(nrofon,nugaus,f2cp) = daux
  322       continue
   32     continue
cgn        write(ulsort,91010) f1cn,f2cn,f3cn,f4cn,-1,
cgn     >                     f1cp,f2cp
cgn        write(52,91010) f1cp,f2cp
c
c doc.45-47.45-47. ===> etanp1 = etan : le tetraedre est decoupe en
c                       quatre selon le meme decoupage.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation,
c             puis reproduit a la creation du maillage car les faces
c             autour n'ont pas change entre les deux iterations.
c             le fils prend la valeur de la fonction sur l'ancien
c             fils qui etait au meme endroit. comme la procedure de
c             numerotation est la meme (voir cmcdte), le premier fils
c             est toujours le meme, le second egalement. on prendra
c             alors la valeur sur le fils de rang identique a
c             l'iteration n.
c
        elseif ( etanp1.eq.etan ) then
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
          do 33 , nrofon = 1, nbfonc
            do 331 , nugaus = 1 , ngauss
              vafott(nrofon,nugaus,f1cp) =
     >                                vafoen(nrofon,nugaus,prfcan(f1cn))
              vafott(nrofon,nugaus,f2cp) =
     >                                vafoen(nrofon,nugaus,prfcan(f2cn))
              vafott(nrofon,nugaus,f3cp) =
     >                                vafoen(nrofon,nugaus,prfcan(f3cn))
              vafott(nrofon,nugaus,f4cp) =
     >                                vafoen(nrofon,nugaus,prfcan(f4cn))
  331       continue
   33     continue
cgn        write(ulsort,91010) f1cn,f2cn,f3cn,f4cn,-1,
cgn     >                     f1cp,f2cp,f3cp,f4cp
cgn        write(43,91010) f1cp,f2cp,f3cp,f4cp
c
c ===> etanp1 = 41, ..., 44 : le tetraedre est decoupe en quatre par une
c                             face.
c ===> etanp1 = 45, 46, 47 et different de etan :
c        le tetraedre est decoupe en quatre mais par un autre decoupage.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation, puis
c             remis differement car l'environnement a change.
c             on donne la valeur moyenne de la fonction sur les quatre
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
          daux1 = 1.d0/dble(4*ngauss)
          do 34 , nrofon = 1, nbfonc
            daux = 0.d0
            do 341 , nugaus = 1, ngauss
              daux = daux + vafoen(nrofon,nugaus,prfcan(f1cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f2cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f3cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f4cn))
  341       continue
            daux = daux*daux1
            do 342 , nugaus = 1 , ngauss
              vafott(nrofon,nugaus,f1cp) = daux
              vafott(nrofon,nugaus,f2cp) = daux
              vafott(nrofon,nugaus,f3cp) = daux
              vafott(nrofon,nugaus,f4cp) = daux
  342       continue
   34     continue
cgn        write(ulsort,91010) f1cn,f2cn,f3cn,f4cn,-1,
cgn     >                     f1cp,f2cp,f3cp,f4cp
cgn        write(53,91010) f1cp,f2cp,f3cp,f4cp
c
c doc.45-47.85-87 ===> etanp1 = 85, 86 ou 87 : le tetraedre est
c                      decoupe en huit par une diagonale.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation, puis
c             remis differement car l'environnement a change.
c             on donne la valeur moyenne de la fonction sur les quatre
c             anciens fils a chaque nouveau fils.
c             attention : il est possible que les fils sur les bords
c                         soient decoupes par de la conformite. Il faut
c                         alors transmettre la valeur a leurs 2 ou 4
c                         fils.
c             attention : ce n'est pas comme en 2D ; il faut examiner
c                         tous les fils, car par contamination de faces
c                         coupees en 2, les fils centraux peuvent etre
c                         decoupes.
c             remarque : on pourrait certainement faire mieux, avec des
c                        moyennes ponderees en fonction du recouvrement
c                        des anciens et nouveaux fils. c'est trop
c                        complique pour que cela vaille le coup.
c
        elseif ( etanp1.ge.85 .and. etanp1.le.87 ) then
c
          f1hp = filtet(tehnp1)
          lglist = 0
          do 351 , nrlist = 1 , 8
            fihp = f1hp+nrlist-1
            iaux = mod(hettet(fihp),100)
            if ( iaux.eq.0 ) then
              lglist = lglist + 1
              list(lglist) = ntesca(fihp)
            elseif ( iaux.ge.21 .and. iaux.le.26 ) then
              lglist = lglist + 1
              list(lglist) = ntesca(filtet(fihp))
              lglist = lglist + 1
              list(lglist) = ntesca(filtet(fihp)+1)
            elseif ( iaux.ge.41 .and. iaux.le.47 ) then
              lglist = lglist + 1
              list(lglist) = ntesca(filtet(fihp))
              lglist = lglist + 1
              list(lglist) = ntesca(filtet(fihp)+1)
              lglist = lglist + 1
              list(lglist) = ntesca(filtet(fihp)+2)
              lglist = lglist + 1
              list(lglist) = ntesca(filtet(fihp)+3)
            else
              coderr = 1
            endif
  351     continue
c
          do 352 , nrlist = 1 , lglist
            prfcap(list(nrlist)) = 1
  352     continue
c
          daux1 = 1.d0/dble(4*ngauss)
          do 35 , nrofon = 1, nbfonc
            daux = 0.d0
            do 353 , nugaus = 1, ngauss
              daux = daux + vafoen(nrofon,nugaus,prfcan(f1cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f2cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f3cn))
     >                    + vafoen(nrofon,nugaus,prfcan(f4cn))
  353       continue
            daux = daux*daux1
            do 354 , nugaus = 1 , ngauss
              do 355 , nrlist = 1 , lglist
                vafott(nrofon,nugaus,list(nrlist)) = daux
  355         continue
  354       continue
   35     continue
cgn        write(56,91010) (list(nrlist),nrlist = 1 , lglist)
cgn        write(ulsort,91010) f1cn,f2cn,-1,
cgn     >                     (list(nrlist),nrlist = 1 , lglist)
cgn91010   format(I3)
c
c ==> aucun autre etat sur le tetraedre courant n'est possible
c
        else
c
          coderr = 2
          write (ulsort,texte(langue,4)) 'n  ', tehn
          write (ulsort,texte(langue,5)) 'n  ', etan
          write (ulsort,texte(langue,4)) 'n+1', tehnp1
          write (ulsort,texte(langue,5)) 'n+1', etanp1
c
        endif
c
      endif
c
      endif
c
c====
c 4. la fin
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
