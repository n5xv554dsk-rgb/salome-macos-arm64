      subroutine pcseq3 ( etanp1, quhn, quhnp1, typint,
     >                    prfcan, prfcap,
     >                    coonoe,
     >                    somare,
     >                    arequa, filqua,
     >                    nbanqu, anfiqu,
     >                    nqueca, nqusca,
     >                    aretri,
     >                            ntrsca,
     >                    nbfonc, vafoen, vafott,
     >                            vatrtt,
     >                            prftrp,
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
c                       Quadrangles d'etat anterieur 4
c                       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . etanp1 . e   .    1   . ETAt du quadrangle a l'iteration N+1       .
c . quhn   . e   .    1   . Quadrangle courant en numerotation Homard  .
c .        .     .        . a l'iteration N                            .
c . quhnp1 . e   .    1   . Quadrangle courant en numerotation Homard  .
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
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . nbanqu . e   .   1    . nombre de quadrangles decoupes par         .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfiqu . e   . nbanqu . tableau filqua du maillage de l'iteration n.
c . nqueca . e   .   *    . nro des quadrangles dans le calcul en ent. .
c . nqusca . e   . rsquto . numero des quadrangles du calcul           .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . ntrsca . e   . rstrto . numero des triangles du calcul             .
c . nbfonc . e   .    1   . nombre de fonctions elements de volume     .
c . vafoen . e   . nbfonc*. variables en entree de l'adaptation        .
c .        .     .    *   .                                            .
c . vafott .   a . nbfonc*. tableau temporaire de la solution          .
c .        .     .    *   .                                            .
c . vatrtt .   a . nbfonc*. tableau temporaire de la solution pour     .
c .        .     .    *   . les triangles de conformite                .
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
      parameter ( nompro = 'PCSEQ3' )
c
#include "nblang.h"
#include "fractc.h"
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombsr.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer etanp1, quhn, quhnp1
      integer typint
      integer nbfonc
      integer prfcan(*), prfcap(*)
      integer somare(2,nbarto)
      integer arequa(nbquto,4), filqua(nbquto)
      integer nbanqu, anfiqu(nbanqu)
      integer nqueca(requto), nqusca(rsquto)
      integer aretri(nbtrto,3)
      integer ntrsca(rstrto)
      integer prftrp(*)
c
      double precision coonoe(nbnoto,sdim)
      double precision vafoen(nbfonc,*)
      double precision vafott(nbfonc,*)
      double precision vatrtt(nbfonc,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
c     qucnp1 = QUadrangle courant en numerotation Calcul a l'it. N+1
c
      integer qucnp1
c
c     f1hp = Fils 1er du quadrangle en numerotation Homard a l'it. N+1
c     f1cp = Fils 1er du quadrangle en numerotation Calcul a l'it. N+1
c     f2cp = Fils 2eme du quadrangle en numerotation Calcul a l'it. N+1
c     f3cp = Fils 3eme du quadrangle en numerotation Calcul a l'it. N+1
c
      integer f1hp
      integer f1cp, f2cp, f3cp
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
      integer coderr
      integer nrofon
      integer iaux
c
      double precision daux
      double precision daux0, daux1, daux2, daux3
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
#endif
c
      texte(1,4) =
     >'(''Quad. en cours : nro a l''''iteration '',a3,'' :'',i10)'
      texte(1,5) = '( 16x,''etat a l''''iteration '',a3,'' : '',i4)'
c
      texte(2,4) =
     >'(''Current quadrangle : # at iteration '',a3,''     : '',i10)'
      texte(2,5) = '( 17x,''status at iteration '',a3,'' : '',i4)'
c
      coderr = 0
c
c 1.2. ==> on repere les numeros dans le calcul pour les fils
c          a l'iteration n
c
      f1hn = anfiqu(quhn)
      f1cn = nqueca(f1hn)
      f2cn = nqueca(f1hn+1)
      f3cn = nqueca(f1hn+2)
      f4cn = nqueca(f1hn+3)
c
      if ( prfcan(f1cn).gt.0 .and. prfcan(f2cn).gt.0 .and.
     >     prfcan(f3cn).gt.0 .and. prfcan(f3cn).gt.0 ) then
c
c====
c 2. le quadrangle etait coupe en 4 quadrangles
c====
c 2.1. ==> etanp1 = 0 : le quadrangle est actif ; il est reactive.
c          on lui attribue la valeur moyenne des quatre anciens fils.
c          remarque : cela arrive seulement avec du deraffinement.
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
cgn      write(ulsort,*)'... quadrangle reactive'
c
        qucnp1 = nqusca(quhnp1)
        prfcap(qucnp1) = 1
c
        if ( typint.eq.0 ) then
          daux1 = unsqu
        else
          daux1 = 1.d0
        endif
        do 21 , nrofon = 1 , nbfonc
          daux = daux1 * ( vafoen(nrofon,prfcan(f1cn))
     >                   + vafoen(nrofon,prfcan(f2cn))
     >                   + vafoen(nrofon,prfcan(f3cn))
     >                   + vafoen(nrofon,prfcan(f4cn)) )
cgn            write(ulsort,90004) 'daux', daux
          vafott(nrofon,qucnp1) = daux
   21   continue
c
c 2.2. ==> etanp1 = 21/22 : le quadrangle est decoupe en
c          deux quadrangles
c             On donne la valeur moyenne de la fonction sur les deux
c             anciens fils a chaque nouveau fils.
c             remarque : on pourrait certainement faire mieux, avec des
c                        moyennes ponderees en fonction du recouvrement
c                        des anciens et nouveaux fils. c'est trop
c                        complique pour que cela vaille le coup.
c           .................         .................
c           .       .       .         .       .       .
c           .       .       .         .       .       .
c           .       .       .         .       .       .
c           .................  ===>   .       .       .
c           .       .       .         .       .       .
c           .       .       .         .       .       .
c           .       .       .         .       .       .
c           .................         .................
      elseif ( etanp1.ge.21 .and. etanp1.le.22 ) then
cgn      write(ulsort,*)'... quadrangle coupe en 2'
c
        f1hp = filqua(quhnp1)
        f1cp = nqusca(f1hp)
        f2cp = nqusca(f1hp+1)
        prfcap(f1cp) = 1
        prfcap(f2cp) = 1
c
        if ( typint.eq.0 ) then
          do 221 , nrofon = 1 , nbfonc
            daux = unsqu * ( vafoen(nrofon,prfcan(f1cn))
     >                     + vafoen(nrofon,prfcan(f2cn))
     >                     + vafoen(nrofon,prfcan(f3cn))
     >                     + vafoen(nrofon,prfcan(f4cn)) )
            vafott(nrofon,f1cp) = daux
            vafott(nrofon,f2cp) = daux
  221     continue
        else
          call utqqua ( f1hp  , daux, daux1, coonoe, somare, arequa )
          call utqqua ( f1hp+1, daux, daux2, coonoe, somare, arequa )
          daux0 = daux1 + daux2
          daux1 = daux1 / daux0
          daux2 = daux2 / daux0
          do 222 , nrofon = 1 , nbfonc
            daux = vafoen(nrofon,prfcan(f1cn))
     >           + vafoen(nrofon,prfcan(f2cn))
     >           + vafoen(nrofon,prfcan(f3cn))
     >           + vafoen(nrofon,prfcan(f4cn))
            vafott(nrofon,f1cp) = daux * daux1
            vafott(nrofon,f2cp) = daux * daux2
  222     continue
        endif
c
c 2.3. ==> etanp1 = 31, 32, 33 ou 34 : le quadrangle est
c             decoupe en trois triangles.
c             on attribue la valeur moyenne sur les quatre anciens
c             fils a chacune des trois nouveaux fils.
c             remarque : on pourrait certainement faire mieux, avec des
c                        moyennes ponderees en fonction du recouvrement
c                        des anciens et nouveaux fils. c'est trop
c                        complique pour que cela vaille le coup.
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
cgn      write(ulsort,*)'... quadrangle coupe en 3 triangles'
c
        f1hp = -filqua(quhnp1)
        f1cp = ntrsca(f1hp)
        f2cp = ntrsca(f1hp+1)
        f3cp = ntrsca(f1hp+2)
        prftrp(f1cp) = 1
        prftrp(f2cp) = 1
        prftrp(f3cp) = 1
        if ( typint.eq.0 ) then
          do 231 , nrofon = 1 , nbfonc
            daux = unsqu * ( vafoen(nrofon,prfcan(f1cn))
     >                     + vafoen(nrofon,prfcan(f2cn))
     >                     + vafoen(nrofon,prfcan(f3cn))
     >                     + vafoen(nrofon,prfcan(f4cn)) )
            vatrtt(nrofon,f1cp) = daux
            vatrtt(nrofon,f2cp) = daux
            vatrtt(nrofon,f3cp) = daux
  231     continue
        else
          call utqtri ( f1hp  , daux, daux1, coonoe, somare, aretri )
          call utqtri ( f1hp+1, daux, daux2, coonoe, somare, aretri )
          call utqtri ( f1hp+2, daux, daux3, coonoe, somare, aretri )
          daux0 = daux1 + daux2 + daux3
          daux1 = daux1 / daux0
          daux2 = daux2 / daux0
          daux3 = daux3 / daux0
          do 232 , nrofon = 1 , nbfonc
            daux = vafoen(nrofon,prfcan(f1cn))
     >           + vafoen(nrofon,prfcan(f2cn))
     >           + vafoen(nrofon,prfcan(f3cn))
     >           + vafoen(nrofon,prfcan(f4cn))
            vatrtt(nrofon,f1cp) = daux * daux1
            vatrtt(nrofon,f2cp) = daux * daux2
            vatrtt(nrofon,f3cp) = daux * daux3
  232     continue
        endif
c
c 2.4. ==> etanp1 = 41, 42, 43 ou 43 : le quadrangle est decoupe en
c          trois quadrangles
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation. il y
c             a du deraffinement dans la zone qui induisait le decoupage
c             de conformite et raffinement sur une autre zone.
c             On donne la valeur moyenne de la fonction sur les trois
c             anciens fils a chaque nouveau fils.
c             remarque : on pourrait certainement faire mieux, avec des
c                        moyennes ponderees en fonction du recouvrement
c                        des anciens et nouveaux fils. c'est trop
c                        complique pour que cela vaille le coup.
c             remarque : cela arrive seulement avec du deraffinement.
c
c           .................         .................
c           .       .       .         .       .       .
c           .       .       .         .       .       .
c           .       .       .         .       .       .
c           .................  ===>   .........       .
c           .       .       .         .         .     .
c           .       .       .         .           .   .
c           .       .       .         .             . .
c           .................         .................
c
      elseif ( etanp1.ge.41 .and. etanp1.le.44 ) then
cgn         print *,'... le quadrangle est coupe en 3 quadrangles'
c
        f1hp = filqua(quhnp1)
        f1cp = nqusca(f1hp)
        f2cp = nqusca(f1hp+1)
        f3cp = nqusca(f1hp+2)
        prfcap(f1cp) = 1
        prfcap(f2cp) = 1
        prfcap(f3cp) = 1
c
        if ( typint.eq.0 ) then
c
          do 241 , nrofon = 1 , nbfonc
            daux = unsqu * ( vafoen(nrofon,prfcan(f1cn))
     >                     + vafoen(nrofon,prfcan(f2cn))
     >                     + vafoen(nrofon,prfcan(f3cn))
     >                     + vafoen(nrofon,prfcan(f4cn)) )
cgn            write(ulsort,90004) 'daux', daux
            vafott(nrofon,f1cp) = daux
            vafott(nrofon,f2cp) = daux
            vafott(nrofon,f3cp) = daux
  241     continue
c
        else
c
          call utqqua ( f1hp  , daux, daux1, coonoe, somare, arequa )
          call utqqua ( f1hp+1, daux, daux2, coonoe, somare, arequa )
          call utqqua ( f1hp+2, daux, daux3, coonoe, somare, arequa )
          daux0 = daux1 + daux2 + daux3
          daux1 = daux1 / daux0
          daux2 = daux2 / daux0
          daux3 = daux3 / daux0
          do 242 , nrofon = 1 , nbfonc
            daux = vafoen(nrofon,prfcan(f1cn))
     >           + vafoen(nrofon,prfcan(f2cn))
     >           + vafoen(nrofon,prfcan(f3cn))
     >           + vafoen(nrofon,prfcan(f4cn))
cgn            write(ulsort,90004) 'unsqu*daux', unsqu*daux
cgn            write(ulsort,90004) 'trshu*daux', trshu*daux
            vafott(nrofon,f1cp) = daux * daux1
            vafott(nrofon,f2cp) = daux * daux2
            vafott(nrofon,f3cp) = daux * daux3
  242     continue
c
        endif
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
      codret = codret + coderr
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
