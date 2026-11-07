      subroutine pcetr1 ( nbfonc, deraff,
     >                    prfcan, prfcap,
     >                    hettri, anctri, filtri,
     >                    nbantr, anfitr, anhetr,
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
c    aPres adaptation - Conversion de solution - aux noeuds par Element
c     -                 -                                       -
c                       TRiangles - degre 1
c                       --                -
c ______________________________________________________________________
c
c remarque : cette interpolation suppose que l'on est en presence de
c            variables intensives. C'est-a-dire independantes de la
c            taille de la maille.
c            Une densite par exemple mais pas une masse.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfonc . e   .    1   . nombre de fonctions aux points de Gauss    .
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
c . anfitr . e   . nbantr . tableau filtri du maillage de l'iteration n
c . anhetr . e   . nbantr . tableau hettri du maillage de l'iteration n.
c . ntreca . e   .   *    . nro des triangles dans le calcul en entree .
c . ntrsca . e   . rstrto . numero des triangles du calcul             .
c . vafoen .   e . nbfonc*. variables en entree de l'adaptation        .
c .        .     . nbnoel .                                            .
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
      parameter ( nompro = 'PCETR1' )
c
#include "nblang.h"
#include "fractc.h"
#include "fracta.h"
c
      integer nbnoel
      parameter ( nbnoel = 3 )
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombtr.h"
#include "nombsr.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer prfcan(*), prfcap(*)
      integer hettri(nbtrto), anctri(*)
      integer filtri(nbtrto)
      integer nbantr, anfitr(nbantr), anhetr(nbantr)
      integer ntreca(retrto), ntrsca(rstrto)
c
      double precision vafoen(nbfonc,nbnoel,*)
      double precision vafott(nbfonc,nbnoel,*)
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
c     f1cp = Fils 1er du triangle en numerotation Calcul a l'it. N+1
c     f2cp = Fils 2eme du triangle en numerotation Calcul a l'it. N+1
c     f3cp = Fils 3eme du triangle en numerotation Calcul a l'it. N+1
c     f4cp = Fils 4eme du triangle en numerotation Calcul a l'it. N+1
c
      integer f1hp
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
c     prxxxx = numero du triangle xxxx dans le profil de la solution
c
      integer prtrcn, prf1cn, prf2cn, prf3cn, prf4cn
c
c     etan   = ETAt du triangle a l'iteration N
c     etanp1 = ETAt du triangle a l'iteration N+1
c
      integer etan, etanp1
c
c     qi   = numero local du i-eme noeud, en fonction de l'orientation
c
      integer q1
c
      integer nrofon
      integer iaux
c
      double precision daux
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
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
      write(ulsort,*) 'nbfonc, nbnoel, nbtrto = ',nbfonc, nbnoel, nbtrto
#endif
c
      texte(1,4) =
     > '(/,''Triangle en cours : nro a l''''iteration '',a3,'' : '',i8)'
      texte(1,5) =
     > '(  ''                etat a l''''iteration '',a3,''   : '',i4)'
c
      texte(2,4) =
     > '(/,''Current triangle : # at iteration '',a3,''     : '',i8)'
      texte(2,5) =
     > '(  ''              status at iteration '',a3,'' : '',i4)'
c
cgn      write (6,*)nbfonc,nbnoel
cgn      do 122 , nrofon = 1 , nbfonc
cgn        print *,'fonction numero ', nrofon
cgnc  remarque : il faut ajuster a la main la borne maximale
cgn        do 1222 , trcn = 1 , 2
cgn          print 1788,trcn,
cgn     >     (vafoen(nrofon,iaux,trcn), iaux = 1 , nbnoel)
cgn 1222   continue
cgn  122 continue
cgn 1788 format(i2,13g12.5)
c
      codret = 0
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
c
        etanp1 = mod(hettri(trhnp1),10)
        etan   = (hettri(trhnp1)-etanp1) / 10
cgn        write (ulsort,1792) 'Triangle', trhn, etan, trhnp1, etanp1
c
c 2.1.3. ==> les numeros locaux des noeuds
c
        q1 = 1
c
c=======================================================================
c doc.0.p. ==> etan = 0 : le triangle etait actif
c=======================================================================
c
        if ( etan.eq.0 ) then
c
c         on repere son ancien numero dans le calcul
c
          trcn = ntreca(trhn)
          prtrcn = prfcan(trcn)
c
          if ( prtrcn.gt.0 ) then
c
cgn          nrofon = 1
cgn       print 1789,(vafoen(nrofon,iaux,prtrcn),iaux=1,nbnoel)
cgn 1789 format('  Valeurs anciennes  :  ',5g12.5)
c
c doc.0.0. ===> etanp1 = 0 : le triangle etait actif et l'est encore ;
c               il est inchange
c             c'est le cas le plus simple : on recopie les valeurs
c             precedentes, noeud par noeud
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
cgn      write(ulsort,7778) (vafoen(nrofon,iaux,trcn),iaux=1,nbnoel)
              do 2211 , iaux = 1 , nbnoel
                vafott(nrofon,iaux,trcnp1) = vafoen(nrofon,iaux,prtrcn)
 2211         continue
  221       continue
cgn        write(21,7777) trcnp1
cgn        write(ulsort,7777) trcn,-1,trcnp1
cgn7777   format(I3)
cgn7778   format(8g14.7)
c
c doc.0.1/2/3 ==> etanp1 = 1, 2 ou 3 : le triangle etait actif et est
c                 maintenant decoupe en 2.
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
c         Pour un decoupage selon l'arete numero 1 :
c
          elseif ( etanp1.eq.1 ) then
c
            f1hp = filtri(trhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
c
            do 2221 , nrofon = 1 , nbfonc
c
c           Pour le fils aine :
c
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q1,prtrcn)
c
c           Pour le triangle fils NF+1 :
c
              vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prtrcn)
c
 2221       continue
c
c         Pour un decoupage selon l'arete numero 2 :
c
          elseif ( etanp1.eq.2 ) then
c
            f1hp = filtri(trhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
c
            do 2222 , nrofon = 1 , nbfonc
c
c           Pour le fils aine :
c
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q1,prtrcn)
c
c           Pour le triangle fils NF+1 :
c
              vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prtrcn)
c
 2222       continue
c
c         Pour un decoupage selon l'arete numero 3 :
c
          elseif ( etanp1.eq.3 ) then
c
            f1hp = filtri(trhnp1)
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
c
            do 2223 , nrofon = 1 , nbfonc
c
c           Pour le fils aine :
c
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q1,prtrcn)
c
c           Pour le triangle fils NF+1 :
c
              vafott(nrofon,q1,f2cp) = vafoen(nrofon,q1,prtrcn)
c
 2223       continue
c
c doc.0.4/6/7/8. ==> etanp1 = 4, 6, 7 ou 8 : le triangle etait actif et
c                    est maintenant decoupe en 4.
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
c
            do 223 , nrofon = 1 , nbfonc
c
c           Pour le fils aine (centre)
c
              vafott(nrofon,q1,f1cp) = vafoen(nrofon,q1,prtrcn)
c
  223       continue
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
c         on repere les numeros dans le calcul pour ses deux fils a
c         l'iteration n
c
          f1hn = anfitr(trhn)
          f1cn = ntreca(f1hn)
          f2cn = ntreca(f1hn+1)
          prf1cn = prfcan(f1cn)
          prf2cn = prfcan(f2cn)
c
          if ( prf1cn.gt.0 .and. prf2cn.gt.0 ) then
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
            do 231 , nrofon = 1 , nbfonc
              do 2311 , iaux = 1 , nbnoel
                vafott(nrofon,iaux,trcnp1) =
     >                    unsde * ( vafoen(nrofon,iaux,prf1cn)
     >                            + vafoen(nrofon,iaux,prf2cn) )
 2311         continue
  231       continue
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
              do 2321 , iaux = 1 , nbnoel
                vafott(nrofon,iaux,f1cp) =
     >                              vafoen(nrofon,iaux,prf1cn)
                vafott(nrofon,iaux,f2cp) =
     >                              vafoen(nrofon,iaux,prf2cn)
 2321         continue
  232       continue
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
              do 2331 , iaux = 1 , nbnoel
                daux = unsde * ( vafoen(nrofon,iaux,prf1cn)
     >                         + vafoen(nrofon,iaux,prf2cn) )
                vafott(nrofon,iaux,f1cp) = daux
                vafott(nrofon,iaux,f2cp) = daux
 2331         continue
  233       continue
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
            f2cp = ntrsca(f1hp+1)
            f3cp = ntrsca(f1hp+2)
            f4cp = ntrsca(f1hp+3)
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
            prfcap(f3cp) = 1
            prfcap(f4cp) = 1
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
c         on repere les numeros dans le calcul pour ses quatre fils
c         a l'iteration n
c
          f1hn = anfitr(trhn)
          f1cn = ntreca(f1hn)
          f2cn = ntreca(f1hn+1)
          f3cn = ntreca(f1hn+2)
          f4cn = ntreca(f1hn+3)
          prf1cn = prfcan(f1cn)
          prf2cn = prfcan(f2cn)
          prf3cn = prfcan(f3cn)
          prf4cn = prfcan(f4cn)
c
          if ( prf1cn.gt.0 .and. prf2cn.gt.0 .and.
     >         prf3cn.gt.0 .and. prf4cn.gt.0 ) then
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
              do 2411 , iaux = 1 , nbnoel
                vafott(nrofon,iaux,trcnp1) =
     >                   unsqu * ( vafoen(nrofon,iaux,prf1cn)
     >                           + vafoen(nrofon,iaux,prf2cn)
     >                           + vafoen(nrofon,iaux,prf3cn)
     >                           + vafoen(nrofon,iaux,prf4cn) )
 2411         continue
  241       continue
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
            prfcap(f1cp) = 1
            prfcap(f2cp) = 1
            do 242 , nrofon = 1 , nbfonc
              do 2421 , iaux = 1 , nbnoel
                daux = unsqu * ( vafoen(nrofon,iaux,prf1cn)
     >                         + vafoen(nrofon,iaux,prf2cn)
     >                         + vafoen(nrofon,iaux,prf3cn)
     >                         + vafoen(nrofon,iaux,prf4cn) )
                vafott(nrofon,iaux,f1cp) = daux
                vafott(nrofon,iaux,f2cp) = daux
 2421         continue
  242       continue
c
          endif
c
          endif
c
c=======================================================================
c
        endif
c
   20 continue
c
      endif
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
c

