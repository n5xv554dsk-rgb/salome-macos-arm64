      subroutine pcset4 ( etan, etanp1, tehn, tehnp1, typint,
     >                    prfcan, prfcap,
     >                    hettet, filtet, nbante, anfite,
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
c    aPres adaptation - Conversion de Solution Elements de volume -
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
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
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
      parameter ( nompro = 'PCSET4' )
c
#include "nblang.h"
#include "fracta.h"
#include "fractc.h"
#include "fractf.h"
#include "fractg.h"
#include "fracth.h"
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
      integer typint
      integer nbfonc
      integer prfcan(*), prfcap(*)
      integer hettet(nbteto), filtet(nbteto)
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
c     tecnp1 = TEtraedre courant en numerotation du Calcul a l'it. N+1
c
      integer tecnp1
c
c     f1hp = Fils 1er du tetraedre en numerotation Homard a l'it. N+1
c     fihp = Fils ieme u tetraedre en numerotation Homard a l'it. N+1
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
c     f1fcp = Fils 1er du Fils en numerotation Calcul a l'it. N+1
c     f2fcp = Fils 2eme du Fils en numerotation Calcul a l'it. N+1
c     f3fcp = Fils 3eme du Fils en numerotation Calcul a l'it. N+1
c     f4fcp = Fils 4eme du Fils en numerotation Calcul a l'it. N+1
c
      integer f1fcp, f2fcp, f3fcp, f4fcp
c
      integer nrofon
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
c                         selon la face 1, 2, 3, 4
c    etan = 45, 46, 47 : le tetraedre etait coupe en 4
c                        selon une diagonale
c====
c
c 2.1. ==> etanp1 = 0 : le tetraedre est reactive.
c
      if ( etanp1.eq.0 ) then
c
        tecnp1 = ntesca(tehnp1)
        prfcap(tecnp1) = 1
c
        if ( typint.eq.0 ) then
          daux1 = unsqu
        else
          daux1 = 1.d0
        endif
        do 21 , nrofon = 1, nbfonc
          daux = daux1 * ( vafoen(nrofon,prfcan(f1cn))
     >                   + vafoen(nrofon,prfcan(f2cn))
     >                   + vafoen(nrofon,prfcan(f3cn))
     >                   + vafoen(nrofon,prfcan(f4cn)) )
          vafott(nrofon,tecnp1) = daux
   21   continue
cgn        write (41,7777) tecnp1
cgn        write (ulsort,7777) f1cn,f2cn,f3cn,f4cn,-1,tecnp1
cgn7777   format(I3)
c
c 2.2. ==> etanp1 = 21, ...,26 : le tetraedre est decoupe en deux
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation,
c             puis reproduit a la creation du maillage car les faces
c             autour n'ont pas change entre les deux iterations.
c             on donne la valeur moyenne de la fonction sur les quatre
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
          daux1 = unsqu
        else
          daux1 = unsde
        endif
        do 22 , nrofon = 1, nbfonc
          daux = daux1 * ( vafoen(nrofon,prfcan(f1cn))
     >                   + vafoen(nrofon,prfcan(f2cn))
     >                   + vafoen(nrofon,prfcan(f3cn))
     >                   + vafoen(nrofon,prfcan(f4cn)) )
          vafott(nrofon,f1cp) = daux
          vafott(nrofon,f2cp) = daux
   22   continue
cgn        write(42,7777) f1cp,f2cp
cgn        write(ulsort,7777) f1cn,f2cn,f3cn,f4cn,-1,
cgn     >                     f1cp,f2cp
c
c 2.3. ==> etanp1 = etan : le tetraedre est decoupe en
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
          vafott(nrofon,f1cp) = vafoen(nrofon,prfcan(f1cn))
          vafott(nrofon,f2cp) = vafoen(nrofon,prfcan(f2cn))
          vafott(nrofon,f3cp) = vafoen(nrofon,prfcan(f3cn))
          vafott(nrofon,f4cp) = vafoen(nrofon,prfcan(f4cn))
   23   continue
cgn        write(43,7777) f1cp,f2cp,f3cp,f4cp
cgn        write(ulsort,7777) f1cn,f2cn,f3cn,f4cn,-1,
cgn     >                     f1cp,f2cp,f3cp,f4cp
c
c 2.4. ==> etanp1 = 41, ..., 47 et different de
c                             etan : le tetraedre est decoupe en quatre
c                             mais par un autre decoupage.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation. il y
c             a du deraffinement dans la zone qui induisait le decoupage
c             de conformite et raffinement sur une autre zone.
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
        do 24 , nrofon = 1, nbfonc
          daux = unsqu * ( vafoen(nrofon,prfcan(f1cn))
     >                   + vafoen(nrofon,prfcan(f2cn))
     >                   + vafoen(nrofon,prfcan(f3cn))
     >                   + vafoen(nrofon,prfcan(f4cn)) )
          vafott(nrofon,f1cp) = daux
          vafott(nrofon,f2cp) = daux
          vafott(nrofon,f3cp) = daux
          vafott(nrofon,f4cp) = daux
   24   continue
cgn        write(44,7777) f1cp,f2cp,f3cp,f4cp
cgn        write(ulsort,7777) f1cn,f2cn,f3cn,f4cn,-1,
cgn     >                     f1cp,f2cp,f3cp,f4cp
c
c 2.5. ==> etanp1 = 85, 86 ou 87 : le tetraedre est
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
        if ( typint.eq.0 ) then
c
        lglist = 0
          do 250 , nrlist = 1 , 8
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
  250     continue
c
          do 260 , nrlist = 1 , lglist
            prfcap(list(nrlist)) = 1
  260     continue
c
          do 270 , nrofon = 1, nbfonc
            daux = unsqu * ( vafoen(nrofon,prfcan(f1cn))
     >                     + vafoen(nrofon,prfcan(f2cn))
     >                     + vafoen(nrofon,prfcan(f3cn))
     >                     + vafoen(nrofon,prfcan(f4cn)) )
            do 2701 , nrlist = 1 , lglist
              vafott(nrofon,list(nrlist)) = daux
 2701       continue
  270     continue
c
        else
c
          do 251 , nrlist = 1 , 8
c
            fihp = f1hp+nrlist-1
            iaux = mod(hettet(fihp),100)
            if ( iaux.eq.0 ) then
              f1cp = ntesca(fihp)
              prfcap(f1cp) = 1
              do 2511 , nrofon = 1, nbfonc
                daux = unshu * ( vafoen(nrofon,prfcan(f1cn))
     >                         + vafoen(nrofon,prfcan(f2cn))
     >                         + vafoen(nrofon,prfcan(f3cn))
     >                         + vafoen(nrofon,prfcan(f4cn)) )
                vafott(nrofon,f1cp) = daux
 2511         continue
            elseif ( iaux.ge.21 .and. iaux.le.26 ) then
              f1fcp = ntesca(filtet(fihp))
              f2fcp = ntesca(filtet(fihp)+1)
              prfcap(f1fcp) = 1
              prfcap(f2fcp) = 1
              do 2512 , nrofon = 1, nbfonc
                daux = unssz * ( vafoen(nrofon,prfcan(f1cn))
     >                         + vafoen(nrofon,prfcan(f2cn))
     >                         + vafoen(nrofon,prfcan(f3cn))
     >                         + vafoen(nrofon,prfcan(f4cn)) )
                vafott(nrofon,f1fcp) = daux
                vafott(nrofon,f2fcp) = daux
 2512         continue
            elseif ( iaux.ge.41 .and. iaux.le.47 ) then
              f1fcp = ntesca(filtet(fihp))
              f2fcp = ntesca(filtet(fihp)+1)
              f3fcp = ntesca(filtet(fihp)+2)
              f4fcp = ntesca(filtet(fihp)+3)
              prfcap(f1fcp) = 1
              prfcap(f2fcp) = 1
              prfcap(f3fcp) = 1
              prfcap(f4fcp) = 1
              do 2513 , nrofon = 1, nbfonc
                daux = unstr2 * ( vafoen(nrofon,prfcan(f1cn))
     >                          + vafoen(nrofon,prfcan(f2cn))
     >                          + vafoen(nrofon,prfcan(f3cn))
     >                          + vafoen(nrofon,prfcan(f4cn)) )
                vafott(nrofon,f1fcp) = daux
                vafott(nrofon,f2fcp) = daux
                vafott(nrofon,f3fcp) = daux
                vafott(nrofon,f4fcp) = daux
 2513         continue
            else
              coderr = 1
            endif
c
  251     continue
c
        endif
cgn        write(46,7777) (list(nrlist),nrlist = 1 , lglist)
cgn        write(ulsort,7777) f1cn,f2cn,f3cn,f4cn,-1,
cgn     >                   (list(nrlist),nrlist = 1 , lglist)
c
c 2.6. ==> aucun autre etat sur le tetraedre courant
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
