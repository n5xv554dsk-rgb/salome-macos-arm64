      subroutine pcequ2 ( nbfonc, ngauss, deraff,
     >                    prfcan, prfcap,
     >                    hetqua, ancqua, filqua,
     >                    nbanqu, anfiqu, anhequ,
     >                    nqueca, nqusca,
     >                    nbantr, anfatr,
     >                    ntreca, ntrsca,
     >                    vafoen, vafott,
     >                    vatren, vatrtt,
     >                    prftrn, prftrp,
     >                    ulsort, langue, codret )
c
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
c                       QUadrangles - degre 2
c                       --                  -
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
c . ngauss . e   .   1    . nbre de points de Gauss des fonctions pg   .
c . deraff . e   .    1   . vrai, s'il y a eu du deraffinement en      .
c .        .     .        . passant de l'iteration n a n+1 ; faux sinon.
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . nbanqu . e   .   1    . nombre de quadrangles decoupes par         .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfiqu . e   . nbanqu . tableau filqua du maillage de l'iteration n.
c . anhequ . e   . nbanqu . tableau hetqua du maillage de l'iteration n.
c . nqueca . e   .   *    . nro des quadrangles dans le calcul en ent. .
c . nqusca . e   . rsquto . numero des quadrangles du calcul           .
c . nbantr . e   .   1    . nombre de triangles issus du decoupage par .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfatr . e   . nbantr . tableau famtri du maillage de l'iteration n.
c . ntreca . e   .   *    . nro des triangles dans le calcul en entree .
c . ntrsca . e   . rstrto . numero des triangles du calcul             .
c . vafoen .   e . nbfonc*. variables en entree de l'adaptation        .
c .        .     .    *   .                                            .
c . vafott .   a . nbfonc*. tableau temporaire de la solution          .
c .        .     .    *   .                                            .
c . vatren .   e . nbfonc*. variables en entree de l'adaptation pour   .
c .        .     .    *   . les triangles de conformite                .
c . vatrtt .   a . nbfonc*. tableau temporaire de la solution pour     .
c .        .     .    *   . les triangles de conformite                .
c . prftrn . es  .   *    . En numero du calcul a l'iteration n   :    .
c .        .     .        . 0 : le triangle est absent du profil       .
c .        .     .        . 1 : le triangle est present dans le profil .
c . prftrp . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : le triangle est absent du profil       .
c .        .     .        . 1 : le triangle est present dans le profil .
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
      parameter ( nompro = 'PCEQU2' )
c
#include "nblang.h"
c
      integer nbnoqu
      parameter ( nbnoqu = 8 )
      integer nbnotr
      parameter ( nbnotr = 6 )
c
#include "fracta.h"
#include "fractb.h"
#include "fractc.h"
#include "fractf.h"
#include "fractg.h"
#include "fracth.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombqu.h"
#include "nombsr.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer ngauss
      integer prfcan(*), prfcap(*)
      integer hetqua(nbquto), ancqua(*)
      integer filqua(nbquto)
      integer nbanqu, anfiqu(nbanqu), anhequ(nbanqu)
      integer nbantr, anfatr(nbantr)
      integer nqueca(requto), nqusca(rsquto)
      integer ntreca(retrto), ntrsca(rstrto)
      integer prftrn(*), prftrp(*)
c
      double precision vafoen(nbfonc,nbnoqu,*)
      double precision vafott(nbfonc,nbnoqu,*)
      double precision vatren(nbfonc,nbnotr,*)
      double precision vatrtt(nbfonc,nbnotr,*)
c
      logical deraff
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
c     qucn   = QUadrangle courant en numerotation Calcul a l'it. N
c     qucnp1 = QUadrangle courant en numerotation Calcul a l'it. N+1
c     quhn   = QUadrangle courant en numerotation Homard a l'it. N
c     quhnp1 = QUadrangle courant en numerotation Homard a l'it. N+1
c
      integer qucn, qucnp1, quhn, quhnp1
c
c     f1hp = Fils 1er du quadrangle en numerotation Homard a l'it. N+1
c     fihp = Fils ieme du triangle en numerotation Homard a l'it. N+1
c     f1cp = Fils 1er du quadrangle en numerotation Calcul a l'it. N+1
c     f2cp = Fils 2eme du quadrangle en numerotation Calcul a l'it. N+1
c     f3cp = Fils 3eme du quadrangle en numerotation Calcul a l'it. N+1
c     f4cp = Fils 4eme du quadrangle en numerotation Calcul a l'it. N+1
c
      integer f1hp, f1fhp
      integer f1cp, f2cp, f3cp, f4cp
      integer f1fcp, f2fcp, f3fcp
c
c     f1hn = Fils 1er du quadrangle en numerotation Homard a l'it. N
c     f1cn = Fils 1er du quadrangle en numerotation Calcul a l'it. N
c     f2cn = Fils 2eme du quadrangle en numerotation Calcul a l'it. N
c     f3cn = Fils 3eme du quadrangle en numerotation Calcul a l'it. N
c     f4cn = Fils 4eme du quadrangle en numerotation Calcul a l'it. N
c
      integer f1hn
      integer f1cn, f2cn, f3cn, f4cn
c
c
      integer prqucn, prf1cn, prf2cn, prf3cn, prf4cn
c
c     etan   = ETAt du quadrangle a l'iteration N
c     etanp1 = ETAt du quadrangle a l'iteration N+1
c
      integer etan, etanp1
c
c     qi   = numero local du i-eme noeud du quadrangle, en fonction
c           de l'orientation
      integer q1,  q2,   q3,   q4,   q5,   q6, q7, q8
      integer q1t, q2t,  q3t,  q4t,  q5t,  q6t
      integer q1tp,q2tp, q3tp, q4tp, q5tp, q6tp

      integer g1, g2, g3, d1, d2, d3
      integer pf, prfg2n, prfg1n, prfg3n, prfd2n, prfd1n, prfd3n
c
      integer nrofon
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
      write(ulsort,*) 'nbfonc, ngauss, nbquto = ',nbfonc, ngauss, nbquto
      write(ulsort,*) 'nbnotr, nbnoqu = ',nbnotr, nbnoqu
#endif
c
      texte(1,4) =
     >'(/,''Quad. en cours : nro a l''''iteration '',a3,'' :'',i10)'
      texte(1,5) =
     > '(  ''                etat a l''''iteration '',a3,''   : '',i4)'
c
      texte(2,4) =
     >'(/,''Current quadrangle : # at iteration '',a3,''     : '',i10)'
      texte(2,5) =
     > '(  ''              status at iteration '',a3,'' : '',i4)'
c
      codret = 0
cgn      print 1789, (nqusca(iaux),iaux=1,rsquto)
cgn 1789 format(10i4)
c
c====
c 2. on boucle sur tous les quadrangles du maillage HOMARD n+1
c    on trie en fonction de l'etat du quadrcangle dans le maillage n
c    on numerote les paragraphes en fonction de la documentation, a
c    savoir : le paragraphe doc.n.p traite de la mise a jour de solution
c    pour un quadrangle dont l'etat est passe de n a p.
c    les autres paragraphes sont numerotes classiquement
c====
c
      if ( nbfonc.ne.0 ) then
c
      do 20 , quhnp1 = 1 , nbquto
c
        if ( codret.eq.0 ) then
c
c 2.1. ==> caracteristiques du quadrangle :
c 2.1.1. ==> son numero homard dans le maillage precedent
c
        if ( deraff ) then
          quhn = ancqua(quhnp1)
        else
          quhn = quhnp1
        endif
c
c 2.1.2. ==> l'historique de son etat
c          On rappelle que l'etat vaut :
c          etan = 0 : le quadrangle etait actif
c          etan = 4 : le quadrangle etait coupe en 4 ; il y a eu
c                     deraffinement.
c          etan = 55 : le quadrangle n'existait pas ; il a ete produit
c                      par un decoupage.
c          etan = 31, 32, 33, 34 : le quadrangle etait coupe en 3
c                                  triangles ; il y a eu deraffinement.
c
        etanp1 = mod(hetqua(quhnp1),100)
        etan   = (hetqua(quhnp1)-etanp1) / 100
c
cgn        write (ulsort,1792) 'Quadrangle', quhn, etan, quhnp1, etanp1
c
c 2.1.3. ==> les numeros locaux des noeuds
c
        q1 = 1
        q2 = 2
        q3 = 3
        q4 = 4
        q5 = 5
        q6 = 6
        q7 = 7
        q8 = 8
cgn            print *,'qi =',q1,q2,q3,q4,q5,q6,q7,q8
c

c=======================================================================
c doc.0.p. ==> etan = 0 : le quadrangle etait actif
c=======================================================================
c
        if ( etan.eq.0 ) then
c
c         on repere son ancien numero dans le calcul
c
          qucn = nqueca(quhn)
          prqucn = prfcan(qucn)
c
          if ( prqucn.gt.0 ) then
c
cgn          print 1789,(vafoen(nrofon,iaux,qucn), iaux = 1 , nbnoqu)
cgn 1789 format('  Valeurs anciennes  :  ',5g12.5)
c
c doc.0.0. ===> etanp1 = 0 : le quadrangle etait actif et l'est encore ;
c               il est inchange
c
c           .................         .................
c           .               .         .               .
c           .               .         .               .
c           .               .         .               .
c           .               .  ===>   .               .
c           .               .         .               .
c           .               .         .               .
c           .               .         .               .
c           .................         .................
c
          if ( etanp1.eq.0 ) then
c
            qucnp1 = nqusca(quhnp1)
            prfcap(qucnp1) = 1
c
            do 221 , nrofon = 1 , nbfonc
cgn      write(ulsort,7778)
cgn     > (vafoen(nrofon,iaux,prfcan(qucn)),iaux = 1 , nbnoqu)
              do 2211 , iaux = 1 , nbnoqu
                vafott(nrofon,iaux,qucnp1) =
     >                                vafoen(nrofon,iaux,prqucn)
 2211         continue
  221       continue
cgn        write(21,7777) qucnp1
cgn        write(ulsort,7777) qucn,-1,qucnp1
cgn 7777   format(I3)
cgn 7778   format(8g14.7)
c
c doc.0.1/2/3 ==> etanp1 = 31, 32, 33 ou 34 : le quadrangle etait actif
c                 et est decoupe en 3 triangles.
c           .................         .................
c           .               .         .      . .      .
c           .               .         .     .   .     .
c           .               .         .    .     .    .
c           .               .  ===>   .   .       .   .
c           .               .         .  .         .  .
c           .               .         . .           . .
c           .               .         ..             ..
c           .................         .................
c
          elseif ( etanp1.ge.31 .and. etanp1.le.34 ) then
c
#include "pcsqu2_1.h"
c
c doc.0.4/6/7/8. ==> etanp1 = 4 : le quadrangle etait actif et
c                    est decoupe en 4.
c           .................         .................
c           .               .         .       .       .
c           .               .         .       .       .
c           .               .         .       .       .
c           .               .  ===>   .................
c           .               .         .       .       .
c           .               .         .       .       .
c           .               .         .       .       .
c           .................         .................
c
          elseif ( etanp1.eq.4 ) then
c
#include "pcsqu2_2.h"

c doc.0.erreur. ==> aucun autre etat sur le quadrangle courant n'est
c                   possible
c
          else
c
            codret = codret + 1
            write (ulsort,texte(langue,4)) 'n  ', quhn
            write (ulsort,texte(langue,5)) 'n  ', etan
            write (ulsort,texte(langue,4)) 'n+1', quhnp1
            write (ulsort,texte(langue,5)) 'n+1', etanp1
c
          endif
c
          endif
c
c=======================================================================
c doc.1/2/3.p. ==> etan = 31, 32, 33 ou 34 : le quadrangle etait coupe
c                  en 3 triangles
c=======================================================================
c
        elseif ( etan.ge.31 .and. etan.le.34 ) then
c
cgn          print *,'etan.ge.31 .and. etan.le.34'
c         on repere les numeros dans le calcul pour ses trois fils a
c         l'iteration n
c
          f1hn = -anfiqu(quhn)
          f1cn = ntreca(f1hn)
          f2cn = ntreca(f1hn+1)
          f3cn = ntreca(f1hn+2)
          prf1cn = prftrn(f1cn)
          prf2cn = prftrn(f2cn)
          prf3cn = prftrn(f3cn)
c
          q1t = 1
          q2t = 2
          q3t = 3
          q4t = 4
          q5t = 5
          q6t = 6
c
          if ( prf1cn.gt.0 .and. prf2cn.gt.0 .and.
     >         prf3cn.gt.0 ) then
c
c doc.1/2/3.0. ===> etanp1 = 0 : le quadrangle est actif. il est
c                   reactive.
c                   on lui attribue la valeur moyenne sur les trois
c                   anciens fils.
c        remarque : cela arrive seulement avec du deraffinement.
c           .................         .................
c           .      . .      .         .               .
c           .     .   .     .         .               .
c           .    .     .    .         .               .
c           .   .       .   .  ===>   .               .
c           .  .         .  .         .               .
c           . .           . .         .               .
c           ..             ..         .               .
c           .................         .................
c
          if ( etanp1.eq.0 ) then
c
cgn            print *,'.. etanp1.eq.0'
c
#include "pcsqu2_3.h"
c
c doc.1/2/3.1/2/3. ===> etanp1 = etan : le quadrangle est decoupe en
c                       trois selon le meme decoupage.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation,
c             puis reproduit a la creation du maillage car les
c             quadrangles autour n'ont pas change entre les deux
c             iterations.
c             Comme la procedure de numerotation est la meme (voir
c             cmcdqu), le premier fils est toujours le meme, le 2eme et
c             le 3eme egalement.
c             on prendra alors les valeurs sur les fils de rang
c             identique a l'iteration n.
c           .................         .................
c           .      . .      .         .      . .      .
c           .     .   .     .         .     .   .     .
c           .    .     .    .         .    .     .    .
c           .   .       .   .  ===>   .   .       .   .
c           .  .         .  .         .  .         .  .
c           . .           . .         . .           . .
c           ..             ..         ..             ..
c           .................         .................
c
          elseif ( etanp1.eq.etan ) then
cgn            print *,'.. etanp1.eq.etan'
c
            f1hp = -filqua(quhnp1)
c
            q1tp = 1
            q2tp = 2
            q3tp = 3
            q4tp = 4
            q5tp = 5
            q6tp = 6
c
            f1cp = ntrsca(f1hp)
            f2cp = ntrsca(f1hp+1)
            f3cp = ntrsca(f1hp+2)
            prftrp(f1cp) = 1
            prftrp(f2cp) = 1
            prftrp(f3cp) = 1
c
            do 232 , nrofon = 1 , nbfonc
c
              vatrtt(nrofon,q1tp,f1cp) = vatren(nrofon,q1t,prf1cn)
              vatrtt(nrofon,q2tp,f1cp) = vatren(nrofon,q2t,prf1cn)
              vatrtt(nrofon,q3tp,f1cp) = vatren(nrofon,q3t,prf1cn)
              vatrtt(nrofon,q4tp,f1cp) = vatren(nrofon,q4t,prf1cn)
              vatrtt(nrofon,q5tp,f1cp) = vatren(nrofon,q5t,prf1cn)
              vatrtt(nrofon,q6tp,f1cp) = vatren(nrofon,q6t,prf1cn)
c
              vatrtt(nrofon,q1tp,f2cp) = vatren(nrofon,q1t,prf2cn)
              vatrtt(nrofon,q2tp,f2cp) = vatren(nrofon,q2t,prf2cn)
              vatrtt(nrofon,q3tp,f2cp) = vatren(nrofon,q3t,prf2cn)
              vatrtt(nrofon,q4tp,f2cp) = vatren(nrofon,q4t,prf2cn)
              vatrtt(nrofon,q5tp,f2cp) = vatren(nrofon,q5t,prf2cn)
              vatrtt(nrofon,q6tp,f2cp) = vatren(nrofon,q6t,prf2cn)
c
              vatrtt(nrofon,q1tp,f3cp) = vatren(nrofon,q1t,prf3cn)
              vatrtt(nrofon,q2tp,f3cp) = vatren(nrofon,q2t,prf3cn)
              vatrtt(nrofon,q3tp,f3cp) = vatren(nrofon,q3t,prf3cn)
              vatrtt(nrofon,q4tp,f3cp) = vatren(nrofon,q4t,prf3cn)
              vatrtt(nrofon,q5tp,f3cp) = vatren(nrofon,q5t,prf3cn)
              vatrtt(nrofon,q6tp,f3cp) = vatren(nrofon,q6t,prf3cn)
c
  232       continue
c
c doc.1/2/3.perm(1/2/3). ===> etanp1 = 31, 32, 33 ou 34 et different de
c                             etan : le quadrangle est encore decoupe
c                             en trois, mais par un autre decoupage.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation. il y
c             a du deraffinement dans la zone qui induisait le decoupage
c             de conformite et raffinement sur une autre zone.
cc             remarque : cela arrive seulement avec du deraffinement.
c
c           .................         .................
c           .      . .      .         ..             ..
c           .     .   .     .         . .           . .
c           .    .     .    .         .  .         .  .
c           .   .       .   .  ===>   .   .       .   .
c           .  .         .  .         .    .     .    .
c           . .           . .         .     .   .     .
c           ..             ..         .      . .      .
c           .................         .................
c
          elseif ( etanp1.ge.31 .and. etanp1.le.34 ) then
c
cgn            print *,'.. etanp1.ge.31 .and. etanp1.le.34'
#include "pcsqu2_4.h"
c
c doc.1/2/3.4/6/7/8. ===> etanp1 = 4 : le quadrangle est
c                         decoupe en quatre.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation. il y
c             a ensuite raffinement du quadrangle. qui plus est, par
c             suite de la regle des ecarts de niveau, on peut avoir
c             induit un decoupage de conformite sur l'un des fils.
c
c           .................         .................
c           .      . .      .         .       .       .
c           .     .   .     .         .       .       .
c           .    .     .    .         .       .       .
c           .   .       .   .  ===>   .................
c           .  .         .  .         .       .       .
c           . .           . .         .       .       .
c           ..             ..         .       .       .
c           .................         .................
c
c
          elseif ( etanp1.eq.4 ) then
c
cgn            print *,'.. etanp1.eq.4'
c
#include "pcsqu2_5.h"
c
c doc.1/2/3.erreur. ==> aucun autre etat sur le quadrangle courant
c                       n'est possible
c
          else
c
            codret = codret + 1
            write (ulsort,texte(langue,4)) 'n  ', quhn
            write (ulsort,texte(langue,5)) 'n  ', etan
            write (ulsort,texte(langue,4)) 'n+1', quhnp1
            write (ulsort,texte(langue,5)) 'n+1', etanp1
c
          endif
c
          endif
c
c=======================================================================
c doc.4. ==> le quadrangle etait coupe en 4 :
c=======================================================================
c
        elseif ( etan.eq.4 ) then
c
c         on repere les numeros dans le calcul pour ses quatre fils
c         a l'iteration n
c
          f1hn = anfiqu(quhn)
          f1cn = nqueca(f1hn)
          f2cn = nqueca(f1hn+1)
          f3cn = nqueca(f1hn+2)
          f4cn = nqueca(f1hn+3)
          prf1cn = prfcan(f1cn)
          prf2cn = prfcan(f2cn)
          prf3cn = prfcan(f3cn)
          prf4cn = prfcan(f4cn)
c
          if ( prf1cn.gt.0 .and. prf2cn.gt.0 .and.
     >         prf3cn.gt.0 .and. prf4cn.gt.0 ) then
c
c doc.4.0. ===> etanp1 = 0 : le quadrangle est actif ; il est reactive.
c               remarque : cela arrive seulement avec du deraffinement.
c           .................         .................
c           .       .       .         .               .
c           .       .       .         .               .
c           .       .       .         .               .
c           .................  ===>   .               .
c           .       .       .         .               .
c           .       .       .         .               .
c           .       .       .         .               .
c           .................         .................
c
          if ( etanp1.eq.0 ) then
c
            qucnp1 = nqusca(quhnp1)
            prfcap(qucnp1) = 1
c
            do 241 , nrofon = 1 , nbfonc
c
              vafott(nrofon,q1,qucnp1) = vafoen(nrofon,q1,prf1cn)
              vafott(nrofon,q2,qucnp1) = vafoen(nrofon,q1,prf2cn)
              vafott(nrofon,q3,qucnp1) = vafoen(nrofon,q1,prf3cn)
              vafott(nrofon,q4,qucnp1) = vafoen(nrofon,q1,prf4cn)
              vafott(nrofon,q5,qucnp1) =
     >                          unsde*(vafoen(nrofon,q2,prf1cn)+
     >                                 vafoen(nrofon,q4,prf2cn))
              vafott(nrofon,q6,qucnp1) =
     >                          unsde*(vafoen(nrofon,q2,prf2cn)+
     >                                 vafoen(nrofon,q4,prf3cn))
              vafott(nrofon,q7,qucnp1) =
     >                          unsde*(vafoen(nrofon,q2,prf3cn)+
     >                                 vafoen(nrofon,q4,prf4cn))
              vafott(nrofon,q8,qucnp1) =
     >                          unsde*(vafoen(nrofon,q2,prf4cn)+
     >                                 vafoen(nrofon,q4,prf1cn))
c
  241       continue
c
c doc.4.1/2/3. ===> etanp1 = 31, 32, 33 ou 34 : le quadrangle est
c             decoupe en trois.
c             remarque : cela arrive seulement avec du deraffinement.
c           .................         .................
c           .       .       .         .      . .      .
c           .       .       .         .     .   .     .
c           .       .       .         .    .     .    .
c           .................  ===>   .   .       .   .
c           .       .       .         .  .         .  .
c           .       .       .         . .           . .
c           .       .       .         ..             ..
c           .................         .................
c
          elseif ( etanp1.ge.31 .and. etanp1.le.34 ) then
cgn            print *,'etanp1.ge.31 .and. etanp1.le.34'
c
#include "pcsqu2_6.h"
c
          elseif ( etanp1.eq.4 .or. etanp1.eq.99 ) then
c
            codret = codret
c
          else
c
            codret = codret + 1
            write (ulsort,texte(langue,4)) 'n  ', quhn
            write (ulsort,texte(langue,5)) 'n  ', etan
            write (ulsort,texte(langue,4)) 'n+1', quhnp1
            write (ulsort,texte(langue,5)) 'n+1', etanp1
          endif
c
          endif
c
c=======================================================================
c doc.4. ==> le quadrangle etait coupe en 4 et au moins un de ses
c            fils etait lui-meme decoupe :
c=======================================================================
c
        elseif ( etan.eq.99 ) then
c
#include "pcsqu2_7.h"
c
        endif
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
cgn      do 922 , nrofon = 1 , nbfonc
cgn        print *,'fonction numero ', nrofon
cgn        iaux = 0
cgn        do 9222 , quhnp1 = 1 , nbtrto
cgn           if ( mod(hettri(quhnp1),100).eq.0 ) then
cgn           iaux = iaux+1
cgn          print 1788,quhnp1,
cgn     >     (vafott(nrofon,nugaus,iaux), nugaus = 1 , ngauss)
cgn           endif
cgn 9222   continue
cgn  922 continue
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

