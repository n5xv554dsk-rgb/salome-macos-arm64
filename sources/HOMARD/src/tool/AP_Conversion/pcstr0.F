      subroutine pcstr0 ( nbfonc, typint, deraff,
     >                    prfcan, prfcap,
     >                    hettri, anctri,
     >                    filtri,
     >                    nbantr, anfitr,
     >                    ntreca, ntrsca,
     >                    vafoen, vafott,
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c                       TRiangles - solution P0
c                       --                    -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfonc . e   .    1   . nombre de fonctions elements de volume     .
c . typint . e   .   1    . type d'interpolation                       .
c .        .     .        .  0, si automatique                         .
c .        .     .        .  elements : 0 si intensif, sans orientation.
c .        .     .        .             1 si extensif, sans orientation.
c .        .     .        .             2 si intensif, avec orientation.
c .        .     .        .             3 si extensif, avec orientation.
c .        .     .        .  noeuds : 1 si degre 1                     .
c .        .     .        .           2 si degre 2                     .
c .        .     .        .           3 si iso-P2                      .
c . deraff . e   .    1   . vrai, s'il y a eu du deraffinement en      .
c .        .     .        . passant de l'iteration n a n+1 ; faux sinon.
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
c . ntreca . e   .   *    . nro des triangles dans le calcul en entree .
c . ntrsca . e   . rstrto . numero des triangles du calcul             .
c . vafoen .   e . nbfonc*. variables en entree de l'adaptation        .
c .        .     .    *   .                                            .
c . vafott .   a . nbfonc*. tableau temporaire de la solution          .
c .        .     .    *   .                                            .
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
      parameter ( nompro = 'PCSTR0' )
c
#include "nblang.h"
#include "fracta.h"
#include "fractc.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombtr.h"
#include "nombsr.h"
#include "nomber.h"
#include "demitr.h"
#include "ope1a3.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer typint
      integer prfcan(*), prfcap(*)
      integer hettri(nbtrto), anctri(*)
      integer filtri(nbtrto)
      integer nbantr, anfitr(nbantr)
      integer ntreca(retrto), ntrsca(rstrto)
c
      double precision vafoen(nbfonc,*)
      double precision vafott(nbfonc,*)
c
      logical deraff
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
c     trcn   = TRiangle courant en numerotation Calcul a l'iteration N
c     trcnp1 = TRiangle courant en numerotation Calcul a l'iteration N+1
c     trhn   = TRiangle courant en numerotation Homard a l'iteration N
c     trhnp1 = TRiangle courant en numerotation Homard a l'iteration N+1
c
      integer trcn, trcnp1, trhn, trhnp1
c
c     f1hp = Fils 1er du triangle en numerotation Homard a l'it. N+1
c     fihp = Fils ieme du triangle en numerotation Homard a l'it. N+1
c     f1cp = Fils 1er du triangle en numerotation Calcul a l'it. N+1
c     f2cp = Fils 2eme du triangle en numerotation Calcul a l'it. N+1
c     f3cp = Fils 3eme du triangle en numerotation Calcul a l'it. N+1
c     f4cp = Fils 4eme du triangle en numerotation Calcul a l'it. N+1
c
      integer f1hp, fihp
      integer f1cp, f2cp, f3cp, f4cp
c
c     f1hn = Fils 1er du triangle en numerotation Homard a l'it. N
c     f1cn = Fils 1er du triangle en numerotation Calcul a l'it. N
c     f2cn = Fils 2eme du triangle en numerotation Calcul a l'it. N
c     f3cn = Fils 3eme du triangle en numerotation Calcul a l'it. N
c     f4cn = Fils 4eme du triangle en numerotation Calcul a l'it. N
c
      integer f1hn
      integer f1cn, f2cn, f3cn, f4cn
c
c     f1fhp = Fils 1er du Fils en numerotation Homard a l'it. N+1
c     f1fcp = Fils 1er du Fils en numerotation Calcul a l'it. N+1
c     f2fcp = Fils 2eme du Fils en numerotation Calcul a l'it. N+1
c
      integer f1fhp, f1fcp, f2fcp
c
c     etan   = ETAt du triangle a l'iteration N
c     etanp1 = ETAt du triangle a l'iteration N+1
c
      integer etan, etanp1
c
      integer nrofon
      integer iaux
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
#include "pcimp0.h"
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
      write (ulsort,90002) 'nbfonc', nbfonc
      write (ulsort,90002) 'nbtrto', nbtrto
      write (ulsort,90002) 'retrto, rstrto', retrto, rstrto
#endif
c
      texte(1,4) =
     > '(/,''Triangle en cours : nro a l''''iteration '',a3,'' : '',i8)'
      texte(1,5) =
     > '(  ''                   etat a l''''iteration '',a3,'' : '',i4)'
      texte(1,6) = '(  ''==> Aucune interpolation'')'
c
      texte(2,4) =
     > '(/,''Current triangle : # at iteration '',a3,'' : '',i8)'
      texte(2,5) =
     > '(  ''              status at iteration '',a3,'' : '',i4)'
      texte(2,6) = '(  ''==> No interpolation'')'
c
      codret = 0
cgn      write(ulsort,*) 'ntreca'
cgn      write(ulsort,91020) ntreca
cgn      write(ulsort,*) 'prfcan'
cgn      write(ulsort,91020)(prfcan(iaux),iaux=1,74)
cgn 9999   format(1I5,g14.7,3i10)
c
c====
c 2. on boucle sur tous les triangles du maillage HOMARD n+1
c    on trie en fonction de l'etat du triangle dans le maillage n
c    on numerote les paragraphes en fonction de la documentation, a
c    savoir : le paragraphe doc.n.p traite de la mise a jour de solution
c    pour un triangle dont l'etat est passe de n a p.
c    les autres paragraphes sont numerotes classiquement
c====
c
      if ( nbfonc.ne.0 ) then
c
      do 20 , trhnp1 = 1 , nbtrto
c
c 2.1. ==> caracteristiques du triangle :
c 2.1.1. ==> son numero homard dans le maillage precedent
c
        if ( deraff ) then
          trhn = anctri(trhnp1)
        else
          trhn = trhnp1
        endif
c
c 2.1.2. ==> l'historique de son etat
c          On rappelle que l'etat vaut :
c          etan = 0 : le triangle etait actif
c          etan = 1, 2, 3 : le triangle etait coupe en 2 selon l'arete
c                           1, 2, 3 ; il y a eu deraffinement.
c          etan = 4 : le triangle etait coupe en 4 ; il y a eu
c                     deraffinement.
c          etan = 5 : le triangle n'existait pas ; il a ete produit par
c                     un decoupage.
c          etan = 6, 7, 8 : le triangle etait coupe en 4 avec bascule
c                           de l'arete etan-5 pour le suivi de
c                           frontiere ; il y a eu deraffinement.
c          etan = 9 : le triangle etait coupe en 4 et un de ses fils
c                     est inactif
c
        etanp1 = mod(hettri(trhnp1),10)
        etan   = (hettri(trhnp1)-etanp1) / 10
c
cgn        write (ulsort,1792) 'Triangle', trhn, etan, trhnp1, etanp1
c
c=======================================================================
c doc.0.p. ==> etan = 0 : le triangle etait actif
c=======================================================================
c
        if ( etan.eq.0 ) then
cgn          print *,'le triangle etait actif'
c
c         on repere son ancien numero dans le calcul
c
          trcn = ntreca(trhn)
cgn          write (ulsort,1790) trcn,prfcan(trcn)
cgn 1790 format('Numero du calcul precedent = ',i3,', de profil = ',i3)
c
          if ( prfcan(trcn).gt.0 ) then
c
cgn      write (ulsort,90004)'Valeurs anciennes',
cgn     >             (vafoen(nrofon,prfcan(trcn)),nrofon=1,nbfonc)
c
c doc.0.0. ===> etanp1 = 0 : le triangle etait actif et l'est encore ;
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
            do 221 , nrofon = 1 , nbfonc
              vafott(nrofon,trcnp1) = vafoen(nrofon,prfcan(trcn))
cgn              write(ulsort,92010) vafoen(nrofon,prfcan(trcn))
  221       continue
cgn        write(21,9999) trcnp1,vafott(15,trcnp1),0,trcn,prfcan(trcn)
cgn        write(ulsort,91020) trcn,-1,trcnp1
c
c doc.0.1/2/3 ==> etanp1 = 1, 2 ou 3 : le triangle etait actif et est
c                 decoupe en 2.
c                 les deux fils prennent la valeur de la fonction sur
c                 le pere
c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .       .      ===>       .   .   .
c              .         .               .    .    .
c             .           .             .     .     .
c            .             .           .      .      .
c           .................         .................
c
          elseif ( etanp1.ge.1 .and. etanp1.le.3 ) then
c
            f1hp = filtri(trhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
            if ( typint.eq.0 ) then
              do 2220 , nrofon = 1 , nbfonc
                daux = vafoen(nrofon,prfcan(trcn))
                vafott(nrofon,f1cp) = daux
                vafott(nrofon,f2cp) = daux
cgn              write(ulsort,92010) vafoen(nrofon,prfcan(trcn))
 2220         continue
            else
              do 2221 , nrofon = 1 , nbfonc
                daux = unsde*vafoen(nrofon,prfcan(trcn))
                vafott(nrofon,f1cp) = daux
                vafott(nrofon,f2cp) = daux
cgn              write(ulsort,92010) vafoen(nrofon,prfcan(trcn))
 2221         continue
            endif
cgn        write(22,9999) f1cp,vafott(15,f1cp),2,trcn,prfcan(trcn)
cgn        write(22,9999) f2cp,vafott(15,f1cp),2,trcn,prfcan(trcn)
cgn        write(22,91020) f1cp,f2cp
cgn        write(ulsort,91020) trcn,-1,
cgn     >                     f1cp,f2cp
c
c doc.0.4/6/7/8. ==> etanp1 = 4, 6, 7 ou 8 : le triangle etait actif et
c                    est decoupe en 4.
c                    les quatre fils prennent la valeur de la fonction
c                    sur le pere
c                   .                         .
c                  . .                       . .
c                 .   .                     .   .
c                .     .                   .     .
c               .       .      ===>       .........
c              .         .               . .     . .
c             .           .             .   .   .   .
c            .             .           .     . .     .
c           .................         .................
c
c
          elseif ( etanp1.eq.4 .or.
     >             etanp1.eq.6 .or. etanp1.eq.7 .or. etanp1.eq.8 ) then
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
            if ( typint.eq.0 ) then
              do 2230 , nrofon = 1 , nbfonc
                daux = vafoen(nrofon,prfcan(trcn))
                vafott(nrofon,f1cp) = daux
                vafott(nrofon,f2cp) = daux
                vafott(nrofon,f3cp) = daux
                vafott(nrofon,f4cp) = daux
cgn              write(ulsort,92010) daux
 2230         continue
            else
              do 2231 , nrofon = 1 , nbfonc
                daux = unsqu*vafoen(nrofon,prfcan(trcn))
                vafott(nrofon,f1cp) = daux
                vafott(nrofon,f2cp) = daux
                vafott(nrofon,f3cp) = daux
                vafott(nrofon,f4cp) = daux
cgn              write(ulsort,92010) daux
 2231         continue
            endif
cgn        write(23,9999) f1cp,vafott(15,f1cp),4,trcn,prfcan(trcn)
cgn        write(23,9999) f2cp,vafott(15,f1cp),4,trcn,prfcan(trcn)
cgn        write(23,9999) f3cp,vafott(15,f1cp),4,trcn,prfcan(trcn)
cgn        write(23,9999) f4cp,vafott(15,f1cp),4,trcn,prfcan(trcn)
cgn        write(23,91020) f1cp,f2cp,f3cp,f4cp
cgn        write(ulsort,91020) trcn,-1,
cgn     >                     f1cp,f2cp,f3cp,f4cp
c
c doc.0.erreur. ==> aucun autre etat sur le triangle courant n'est
c                   possible
c
          else
c
            codret = codret + 1
            write (ulsort,texte(langue,4)) 'n  ', trhn
            write (ulsort,texte(langue,5)) 'n  ', etan
            write (ulsort,texte(langue,4)) 'n+1', trhnp1
            write (ulsort,texte(langue,5)) 'n+1', etanp1
c
          endif
c
          endif
c
c=======================================================================
c doc.1/2/3.p. ==> etan = 1, 2 ou 3 : le triangle etait coupe en 2
c=======================================================================
c
        elseif ( etan.ge.1 .and. etan.le.3 ) then
c
cgn          print *,'le triangle etait coupe en 2'
c         on repere les numeros dans le calcul pour ses deux fils a
c         l'iteration n
c
          f1hn = anfitr(trhn)
          f1cn = ntreca(f1hn)
          f2cn = ntreca(f1hn+1)
c
          if ( prfcan(f1cn).gt.0 .and. prfcan(f2cn).gt.0 ) then
c
c doc.1/2/3.0. ===> etanp1 = 0 : le triangle est actif. il est reactive.
c                   on lui attribue la valeur moyenne sur les deux
c                   anciens fils.
c        remarque : cela arrive seulement avec du deraffinement.
c                   .                         .
c                  ...                       . .
c                 . . .                     .   .
c                .  .  .                   .     .
c               .   .   .      ===>       .       .
c              .    .    .               .         .
c             .     .     .             .           .
c            .      .      .           .             .
c           .................         .................
c
          if ( etanp1.eq.0 ) then
c
            trcnp1 = ntrsca(trhnp1)
            prfcap(trcnp1) = 1
c
            if ( typint.eq.0 ) then
              do 2310 , nrofon = 1 , nbfonc
                vafott(nrofon,trcnp1) =
     >                       unsde * ( vafoen(nrofon,prfcan(f1cn))
     >                               + vafoen(nrofon,prfcan(f2cn)) )
cgn              write(ulsort,92010) vafoen(nrofon,prfcan(f1cn)),
cgn     >                           vafoen(nrofon,prfcan(f2cn))
 2310         continue
            else
              do 2311 , nrofon = 1 , nbfonc
                vafott(nrofon,trcnp1) =
     >                                 vafoen(nrofon,prfcan(f1cn))
     >                               + vafoen(nrofon,prfcan(f2cn))
cgn              write(ulsort,92010) vafoen(nrofon,prfcan(f1cn)),
cgn     >                           vafoen(nrofon,prfcan(f2cn))
 2311         continue
            endif
cgn        write(31,91020) trcnp1
cgn        write(ulsort,91020) f1cn,f2cn,-1,trcnp1
c
c doc.1/2/3.1/2/3. ===> etanp1 = etan : le triangle est decoupe en deux
c                       selon le meme decoupage.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation,
c             puis reproduit a la creation du maillage car les
c             triangles autour n'ont pas change entre les deux
c             iterations.
c             le fils prend la valeur de la fonction sur l'ancien
c             fils qui etait au meme endroit. comme la procedure de
c             numerotation est la meme (voir cmcdtr), le premier fils
c             est toujours le meme, le second egalement. on prendra
c             alors la valeur sur le fils de rang identique a
c             l'iteration n.
c                   .                         .
c                  ...                       ...
c                 . . .                     . . .
c                .  .  .                   .  .  .
c               .   .   .      ===>       .   .   .
c              .    .    .               .    .    .
c             .     .     .             .     .     .
c            .      .      .           .      .      .
c           .................         .................
c
          elseif ( etanp1.eq.etan ) then
c
            f1hp = filtri(trhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
            do 232 , nrofon = 1 , nbfonc
              vafott(nrofon,f1cp) = vafoen(nrofon,prfcan(f1cn))
              vafott(nrofon,f2cp) = vafoen(nrofon,prfcan(f2cn))
cgn              write(ulsort,92010) vafoen(nrofon,prfcan(f1cn)),
cgn     >                           vafoen(nrofon,prfcan(f2cn))
  232       continue
cgn        write(32,91020) f1cp,f2cp
cgn        write(ulsort,91020) f1cn,f2cn,-1,f1cp,f2cp
c
c doc.1/2/3.perm(1/2/3). ===> etanp1 = 1, 2 ou 3 et different de etan :
c                             le triangle est encore decoupe en deux
c                             mais par un autre decoupage.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation. il y
c             a du deraffinement dans la zone qui induisait le decoupage
c             de conformite et raffinement sur une autre zone.
c             on donne la valeur moyenne de la fonction sur les deux
c             anciens fils a chaque nouveau fils.
c             remarque : on pourrait certainement faire mieux, avec des
c                        moyennes ponderees en fonction du recouvrement
c                        des anciens et nouveaux fils. c'est trop
c                        complique pour que cela vaille le coup.
c             remarque : cela arrive seulement avec du deraffinement.
c                   .                         .
c                  ...                       . .
c                 . . .                     .   .
c                .  .  .                   .     .
c               .   .   .      ===>       .       .
c              .    .    .               .  .      .
c             .     .     .             .      .    .
c            .      .      .           .          .  .
c           .................         .................
c
          elseif ( etanp1.ge.1 .and. etanp1.le.3 ) then
c
            f1hp = filtri(trhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
            do 233 , nrofon = 1 , nbfonc
              daux = unsde * ( vafoen(nrofon,prfcan(f1cn))
     >                       + vafoen(nrofon,prfcan(f2cn)) )
              vafott(nrofon,f1cp) = daux
              vafott(nrofon,f2cp) = daux
cgn              write(ulsort,92010) vafoen(nrofon,prfcan(f1cn)),
cgn     >                           vafoen(nrofon,prfcan(f2cn))
  233       continue
cgn        write(33,91020) f1cp,f2cp
cgn        write(ulsort,91020) f1cn,f2cn,-1,f1cp,f2cp
c
c doc.1/2/3.4/6/7/8. ===> etanp1 = 4, 6, 7 ou 8 : le triangle est
c                         decoupe en quatre.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation. il y
c             a ensuite raffinement du triangle. qui plus est, par suite
c             de la regle des ecarts de niveau, on peut avoir induit
c             un decoupage de conformite sur l'un des fils.
c             remarque : c'est toujours un des fils du cote qui etait
c             decoupe qui subit le decoupage, et c'est toujours par
c             une subdivision du dit cote.
c
c             . pour le triangle central et le triangle dans le coin
c             oppose a l'arete initialement decoupee, on attribue la
c             valeur moyenne de la fonction sur les deux anciens fils.
c             . pour les deux autres triangles, on repere dans lequel
c             des deux fils ils se trouvent. si un de ces triangles est
c             decoupe, c'est en 2 et par la meme arete que le triangle
c             courant ; on affecte la valeur du fils du maillage n
c             a ces deux fils. si un des triangles est actif, on lui
c             attribue la valeur.
c
c             . on pose i, j et k comme etant les numeros locaux des
c             aretes du triangle courant.
c             si etan vaut i, c'est que la i-eme arete du triangle
c             etait coupee. les numerotations des 2 fils sont obtenues
c             par la fonction nutrde : a = nutrde(i,j), b = nutrde(i,k)
c             les numerotations des 4 fils sont +0, +i, +j et +k.
c             on voit donc que :
c              . les fils +O et +i doivent recevoir la moyenne
c              . le fils +k, ou ses fils, doit recevoir la valeur
c                de +nutrde(i,j)
c              . le fils +j, ou ses fils, doit recevoir la valeur
c                de +nutrde(i,k)
c
c                   .                         .
c                  ...                       . .
c                 . . .                     .   .
c                .  .  .                   . +i  .
c             j .   .   . k    ===>     j ......... k
c              .    .    .               . .     . .
c             . +a  . +b  .             .   .+0 .   .
c            .      .      .           . +k  . . +j  .
c           .................         .................
c                   i                        i
c
c                   .                         .
c                  ...                       . .
c                 . . .                     .   .
c                .  .  .                   . +i  .
c             j .   .   . k    ===>     j ......... k
c              .    .    .               . .     ...
c             . +a  . +b  .             .   .+0 . . .
c            .      .      .           . +k  . .+j.+j.
c           .................         .................
c                   i                        i
c
c                   .                         .
c                  ...                       . .
c                 . . .                     .   .
c                .  .  .                   . +i  .
c             j .   .   . k    ===>     j ......... k
c              .    .    .               ...     ...
c             . +a  . +b  .             . . .+0 . . .
c            .      .      .           .+k.+k. .+j.+j.
c           .................         .................
c                   i                        i
c
c
          elseif ( etanp1.eq.4 .or.
     >             etanp1.eq.6 .or. etanp1.eq.7 .or. etanp1.eq.8 ) then
c
c           ==> les deux triangles central et opposee
c
            f1hp = filtri(trhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+etan)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
            if ( typint.eq.0 ) then
              daux1 = unsde
            else
              daux1 = unsqu
            endif
            do 2341 , nrofon = 1 , nbfonc
              daux = daux1 * ( vafoen(nrofon,prfcan(f1cn))
     >                       + vafoen(nrofon,prfcan(f2cn)) )
              vafott(nrofon,f1cp) = daux
              vafott(nrofon,f2cp) = daux
cgn              write(ulsort,92010) vafoen(nrofon,prfcan(f1cn)),
cgn     >                           vafoen(nrofon,prfcan(f2cn))
 2341       continue
cgn        write(34,91020) f1cp,f2cp
cgn        write(ulsort,91020) f1cn,f2cn,-1,f1cp,f2cp
c
c           ==> le triangle d'un des cotes
c
            iaux = prfcan(ntreca(f1hn+nutrde(etan,per1a3( 1,etan))))
            fihp = f1hp+per1a3(-1,etan)
            if ( mod(hettri(fihp),10).eq.0 ) then
              f3cp = ntrsca(fihp)
              prfcap(f3cp) = 1
              if ( typint.eq.0 ) then
                do 23420 , nrofon = 1 , nbfonc
                  vafott(nrofon,f3cp) = vafoen(nrofon,iaux)
cgn                write(ulsort,92010) vafoen(nrofon,iaux)
23420           continue
              else
                do 23421 , nrofon = 1 , nbfonc
                  vafott(nrofon,f3cp) = unsde * vafoen(nrofon,iaux)
cgn                write(ulsort,92010) vafoen(nrofon,iaux)
23421           continue
              endif
cgn        write(35,91020) f3cp
cgn        write(ulsort,91020) f1hn+nutrde(etan,per1a3( 1,etan)),-1,f3cp
            elseif ( mod(hettri(fihp),10).eq.etan ) then
              f1fhp = filtri(fihp)
              f1fcp = ntrsca(f1fhp)
              f2fcp = ntrsca(f1fhp+1)
              prfcap(f1fcp) = 1
              prfcap(f2fcp) = 1
              if ( typint.eq.0 ) then
                do 23430 , nrofon = 1 , nbfonc
                  vafott(nrofon,f1fcp) = vafoen(nrofon,iaux)
                  vafott(nrofon,f2fcp) = vafoen(nrofon,iaux)
cgn                write(ulsort,92010) vafoen(nrofon,iaux)
23430           continue
              else
                do 23431 , nrofon = 1 , nbfonc
                  vafott(nrofon,f1fcp) = unsqu * vafoen(nrofon,iaux)
                  vafott(nrofon,f2fcp) = unsqu * vafoen(nrofon,iaux)
cgn                write(ulsort,92010) vafoen(nrofon,iaux)
23431           continue
              endif
cgn        write(36,91020) f1fcp,f2fcp
cgn        write(ulsort,91020) f1hn+nutrde(etan,per1a3( 1,etan)),-1,
cgn     >                     f1fcp,f2fcp
            else
              codret = codret + 1
              write (ulsort,texte(langue,4)) 'n+1', fihp
              write (ulsort,texte(langue,5)) 'n+1', hettri(fihp)
            endif
c
c           ==> le triangle de l'autre cote
c
            iaux = prfcan(ntreca(f1hn+nutrde(etan,per1a3(-1,etan))))
            fihp = f1hp+per1a3( 1,etan)
            if ( mod(hettri(fihp),10).eq.0 ) then
              f3cp = ntrsca(fihp)
              prfcap(f3cp) = 1
              if ( typint.eq.0 ) then
                do 23440 , nrofon = 1 , nbfonc
                  vafott(nrofon,f3cp) = vafoen(nrofon,iaux)
cgn                write(ulsort,92010) vafoen(nrofon,iaux)
23440           continue
              else
                do 23441 , nrofon = 1 , nbfonc
                  vafott(nrofon,f3cp) = unsde * vafoen(nrofon,iaux)
cgn                write(ulsort,92010) vafoen(nrofon,iaux)
23441           continue
              endif
cgn        write(37,91020) f3cp
cgn        write(ulsort,91020) f1hn+nutrde(etan,per1a3(-1,etan)),-1,f3cp
            elseif ( mod(hettri(fihp),10).eq.etan ) then
              f1fhp = filtri(fihp)
              f1fcp = ntrsca(f1fhp)
              f2fcp = ntrsca(f1fhp+1)
              prfcap(f1fcp) = 1
              prfcap(f2fcp) = 1
              if ( typint.eq.0 ) then
                do 23450 , nrofon = 1 , nbfonc
                  vafott(nrofon,f1fcp) = vafoen(nrofon,iaux)
                  vafott(nrofon,f2fcp) = vafoen(nrofon,iaux)
cgn                write(ulsort,92010) vafoen(nrofon,iaux)
23450           continue
              else
                do 23451 , nrofon = 1 , nbfonc
                  vafott(nrofon,f1fcp) = unsqu * vafoen(nrofon,iaux)
                  vafott(nrofon,f2fcp) = unsqu * vafoen(nrofon,iaux)
cgn                write(ulsort,92010) vafoen(nrofon,iaux)
23451           continue
              endif
cgn        write(38,91020) f1fcp,f2fcp
cgn        write(ulsort,91020) f1hn+nutrde(etan,per1a3(-1,etan)),-1,
cgn     >                     f1fcp,f2fcp
            else
              codret = codret + 1
              write (ulsort,texte(langue,4)) 'n+1', fihp
              write (ulsort,texte(langue,5)) 'n+1', hettri(fihp)
            endif
c
c doc.1/2/3.erreur. ==> aucun autre etat sur le triangle courant
c                       n'est possible
c
          else
c
            codret = codret + 1
            write (ulsort,texte(langue,4)) 'n  ', trhn
            write (ulsort,texte(langue,5)) 'n  ', etan
            write (ulsort,texte(langue,4)) 'n+1', trhnp1
            write (ulsort,texte(langue,5)) 'n+1', etanp1
c
          endif
c
          endif
c
c=======================================================================
c doc.4. ==> le triangle etait coupe en 4 :
c=======================================================================
c
        elseif ( etan.eq.4 .or.
     >           etan.eq.6 .or. etan.eq.7 .or. etan.eq.8 ) then
c
cgn          print *,'le triangle etait coupe en 4'
c         on repere les numeros dans le calcul pour ses quatre fils
c         a l'iteration n
c
          f1hn = anfitr(trhn)
          f1cn = ntreca(f1hn)
          f2cn = ntreca(f1hn+1)
          f3cn = ntreca(f1hn+2)
          f4cn = ntreca(f1hn+3)
cgn          print *,'Les 4 fils :'
cgn          print 1790,f1cn,prfcan(f1cn)
cgn          print 1790,f2cn,prfcan(f2cn)
cgn          print 1790,f3cn,prfcan(f3cn)
cgn          print 1790,f4cn,prfcan(f4cn)
c
          if ( prfcan(f1cn).gt.0 .and. prfcan(f2cn).gt.0 .and.
     >         prfcan(f3cn).gt.0 .and. prfcan(f4cn).gt.0 ) then
c
c doc.4.0. ===> etanp1 = 0 : le triangle est actif ; il est reactive.
c             on lui attribue la valeur moyenne sur les quatre anciens
c             fils.
c             remarque : cela arrive seulement avec du deraffinement.
c                   .                         .
c                  . .                       . .
c                 .   .                     .   .
c                .     .                   .     .
c               .........      ===>       .       .
c              . .     . .               .         .
c             .   .   .   .             .           .
c            .     . .     .           .             .
c           .................         .................
c
          if ( etanp1.eq.0 ) then
c
            trcnp1 = ntrsca(trhnp1)
            prfcap(trcnp1) = 1
c
            do 241 , nrofon = 1 , nbfonc
              vafott(nrofon,trcnp1) =
     >               unsqu * ( vafoen(nrofon,prfcan(f1cn))
     >                       + vafoen(nrofon,prfcan(f2cn))
     >                       + vafoen(nrofon,prfcan(f3cn))
     >                       + vafoen(nrofon,prfcan(f4cn)) )
cgn              write(ulsort,92010) vafoen(nrofon,prfcan(f1cn)),
cgn     >                           vafoen(nrofon,prfcan(f2cn)),
cgn     >                           vafoen(nrofon,prfcan(f3cn)),
cgn     >                           vafoen(nrofon,prfcan(f4cn))
  241       continue
cgn        write (41,91020) trcnp1
cgn        write (ulsort,91020) f1cn,f2cn,f3cn,f4cn,-1,trcnp1
c
c doc.4.1/2/3. ===> etanp1 = 1, 2 ou 3 : le triangle est decoupe en
c             deux.
c             on attribue la valeur moyenne sur les quatre anciens
c             fils a chacune des deux nouveaux fils.
c             remarque : on pourrait certainement faire mieux, avec des
c                        moyennes ponderees en fonction du recouvrement
c                        des anciens et nouveaux fils. c'est trop
c                        complique pour que cela vaille le coup.
c             remarque : cela arrive seulement avec du deraffinement.
c                   .                         .
c                  . .                       ...
c                 .   .                     . . .
c                .     .                   .  .  .
c               .........      ===>       .   .   .
c              . .     . .               .    .    .
c             .   .   .   .             .     .     .
c            .     . .     .           .      .      .
c           .................         .................
c
          elseif ( etanp1.ge.1 .and. etanp1.le.3 ) then
c
            f1hp = filtri(trhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
cgn            print *,f1hp,f1cp,f2cp
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
            do 242 , nrofon = 1 , nbfonc
              daux = unsqu * ( vafoen(nrofon,prfcan(f1cn))
     >                       + vafoen(nrofon,prfcan(f2cn))
     >                       + vafoen(nrofon,prfcan(f3cn))
     >                       + vafoen(nrofon,prfcan(f4cn)) )
              vafott(nrofon,f1cp) = daux
              vafott(nrofon,f2cp) = daux
cgn              write(ulsort,92010) vafoen(nrofon,prfcan(f1cn)),
cgn     >                           vafoen(nrofon,prfcan(f2cn)),
cgn     >                           vafoen(nrofon,prfcan(f3cn)),
cgn     >                           vafoen(nrofon,prfcan(f4cn))
  242       continue
cgn        write(42,91020) f1cp,f2cp
cgn        write(ulsort,91020) f1cn,f2cn,f3cn,f4cn,-1,
cgn     >                     f1cp,f2cp
c
          endif
c
          endif
c
#ifdef _DEBUG_HOMARD_
c
c=======================================================================
c doc.4. ==> le triangle n'existait pas
c=======================================================================
c
        else
c
cgn          print *,'le triangle n''existait pas'
          write (ulsort,texte(langue,6))
c
#endif
c
c=======================================================================
c
        endif
c
   20 continue
c
      endif
c
cgn      write(ulsort,91020)(prfcap(iaux),iaux=1,nbtrto)
cgn      print *,'nbfonc = ',nbfonc
cgn      etan   = 1
cgn      etanp1 = nbtrto
cgn      do 30001 , iaux=etan,etanp1
cgn        if ( mod(hettri(iaux),10).eq.0 ) then
cgn          print 11790,
cgn     >    ntrsca(iaux),prfcap(ntrsca(iaux)),vafott(1,ntrsca(iaux))
cgn        endif
cgn30001 continue
cgn11790 format(i4,' : ',i2,' / ',g15.7)
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
