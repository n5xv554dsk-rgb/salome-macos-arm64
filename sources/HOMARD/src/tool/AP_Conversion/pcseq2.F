      subroutine pcseq2 ( etan, etanp1, quhn, quhnp1, typint,
     >                            prfcap,
     >                    coonoe,
     >                    somare,
     >                    arequa, hetqua, filqua,
     >                    nbanqu, anfiqu,
     >                            nqusca,
     >                    aretri,
     >                    ntreca, ntrsca,
     >                    nbfonc,         vafott,
     >                    vatren, vatrtt,
     >                    prftrn, prftrp,
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
c                       Quadrangles d'etat anterieur 31, 32, 33, 34
c                       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . etan   . e   .    1   . ETAt du quadrangle a l'iteration N         .
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
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . nbanqu . e   .   1    . nombre de quadrangles decoupes par         .
c .        .     .        . conformite sur le maillage avant adaptation.
c . anfiqu . e   . nbanqu . tableau filqua du maillage de l'iteration n.
c . nqusca . e   . rsquto . numero des quadrangles du calcul           .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . ntreca . e   .   *    . nro des triangles dans le calcul en entree .
c . ntrsca . e   . rstrto . numero des triangles du calcul             .
c . nbfonc . e   .    1   . nombre de fonctions elements de volume     .
c . vafott .   a . nbfonc*. tableau temporaire de la solution          .
c .        .     .    *   .                                            .
c . vatren . e   . nbfonc*. variables en entree de l'adaptation        .
c .        .     .    *   .                                            .
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
      parameter ( nompro = 'PCSEQ2' )
c
#include "nblang.h"
#include "fractb.h"
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
      integer etan, etanp1, quhn, quhnp1
      integer typint
      integer nbfonc
      integer prfcap(*)
      integer somare(2,nbarto)
      integer arequa(nbquto,4), hetqua(nbquto)
      integer filqua(nbquto)
      integer nbanqu, anfiqu(nbanqu)
      integer nqusca(rsquto)
      integer aretri(nbtrto,3)
      integer ntreca(retrto), ntrsca(rstrto)
      integer prftrn(*), prftrp(*)
c
      double precision coonoe(nbnoto,sdim)
      double precision vafott(nbfonc,*)
      double precision vatren(nbfonc,*)
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
c     fihp = Fils ieme du quadrangle en numerotation Homard a l'it. N+1
c     ficp = Fils ieme du quadrangle en numerotation Calcul a l'it. N+1
c     f1cp = Fils 1er du quadrangle en numerotation Calcul a l'it. N+1
c     f2cp = Fils 2eme du quadrangle en numerotation Calcul a l'it. N+1
c     f3cp = Fils 3eme du quadrangle en numerotation Calcul a l'it. N+1
c
      integer f1hp, fihp, ficp
      integer f1cp, f2cp, f3cp
c
c     f1hn = Fils 1er du quadrangle en numerotation Homard a l'it. N
c     f1cn = Fils 1er du quadrangle en numerotation Calcul a l'it. N
c     f2cn = Fils 2eme du quadrangle en numerotation Calcul a l'it. N
c     f3cn = Fils 3eme du quadrangle en numerotation Calcul a l'it. N
c
      integer f1hn
      integer f1cn, f2cn, f3cn
c
c     f1fhp = Fils 1er du Fils en numerotation Homard a l'it. N+1
c     f1fcp = Fils 1er du Fils en numerotation Calcul a l'it. N+1
c     f2fcp = Fils 2eme du Fils en numerotation Calcul a l'it. N+1
c     f3fcp = Fils 3eme du Fils en numerotation Calcul a l'it. N+1
c
      integer f1fhp, f1fcp, f2fcp, f3fcp
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
      f1hn = -anfiqu(quhn)
      f1cn = ntreca(f1hn)
      f2cn = ntreca(f1hn+1)
      f3cn = ntreca(f1hn+2)
c
      if ( prftrn(f1cn).gt.0 .and. prftrn(f2cn).gt.0 .and.
     >     prftrn(f3cn).gt.0 ) then
c
c====
c 2. le quadrangle etait coupe en 3 triangles
c====
c 2.1. ==> etanp1 = 0 : le quadrangle est actif. il est
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
cgn      write(ulsort,*)'... quadrangle reactive'
c
        qucnp1 = nqusca(quhnp1)
        prfcap(qucnp1) = 1
c
        if ( typint.eq.0 ) then
          daux1 = unstr
        else
          daux1 = 1.d0
        endif
        do 21 , nrofon = 1 , nbfonc
          daux = daux1 * ( vatren(nrofon,prftrn(f1cn))
     >                   + vatren(nrofon,prftrn(f2cn))
     >                   + vatren(nrofon,prftrn(f3cn)) )
cgn            write(ulsort,90004) 'daux', daux
          vafott(nrofon,qucnp1) = daux
cgn              write(ulsort,92010) vatren(nrofon,prftrn(qucnp1))
   21   continue
c
c 2.2. ==> etanp1 = 21 ou 22 : le quadrangle est decoupe en deux
c                              quadrangles
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
c           .      . .      .         .       .       .
c           .     .   .     .         .       .       .
c           .    .     .    .         .       .       .
c           .   .       .   .  ===>   .       .       .
c           .  .         .  .         .       .       .
c           . .           . .         .       .       .
c           ..             ..         .       .       .
c           .................         .................
c
      elseif ( etanp1.ge.21 .and. etanp1.le.22 ) then
cgn      write(ulsort,*)'... quadrangle coupe en 2'
c
        f1hp = filqua(quhnp1)
        f1cp = nqusca(f1hp)
        f2cp = nqusca(f1hp+1)
        prfcap(f1cp) = 1
        prfcap(f2cp) = 1
cgn       write (ulsort,90002) 'f1cp, f2cp', f1cp, f2cp
c
        if ( typint.eq.0 ) then
          do 221 , nrofon = 1 , nbfonc
            daux = unstr * ( vatren(nrofon,prftrn(f1cn))
     >                     + vatren(nrofon,prftrn(f2cn))
     >                     + vatren(nrofon,prftrn(f3cn)) )
cgn            write(ulsort,90004) 'daux', daux
            vafott(nrofon,f1cp) = daux
            vafott(nrofon,f2cp) = daux
cgn              write(*,92010) daux
 221      continue
        else
          call utqqua ( f1hp  , daux, daux1, coonoe, somare, arequa )
          call utqqua ( f1hp+1, daux, daux2, coonoe, somare, arequa )
          daux0 = daux1 + daux2
          daux1 = daux1 / daux0
          daux2 = daux2 / daux0
          do 222 , nrofon = 1 , nbfonc
            daux = vatren(nrofon,prftrn(f1cn))
     >           + vatren(nrofon,prftrn(f2cn))
     >           + vatren(nrofon,prftrn(f3cn))
cgn            write(ulsort,90004) 'daux', daux
            vafott(nrofon,f1cp) = daux1 * daux
            vafott(nrofon,f2cp) = daux2 * daux
cgn              write(*,92010) daux
 222      continue
        endif
c
c 2.3. ==> etanp1 = etan : le quadrangle est decoupe en
c                       trois triangles selon le meme decoupage.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation,
c             puis reproduit a la creation du maillage car les
c             quadrangles autour n'ont pas change entre les deux
c             iterations.
c             le fils prend la valeur de la fonction sur l'ancien
c             fils qui etait au meme endroit. comme la procedure de
c             numerotation est la meme (voir cmcdqu), le premier fils
c             est toujours le meme, le 2eme et le 3eme egalement.
c             on prendra alors la valeur sur le fils de rang identique
c             a l'iteration n.
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
cgn      write(ulsort,*)'... quadrangle coupe en 3 triangles ; meme dec'
c
        f1hp = -filqua(quhnp1)
        f1cp = ntrsca(f1hp)
        f2cp = ntrsca(f1hp+1)
        f3cp = ntrsca(f1hp+2)
        prftrp(f1cp) = 1
        prftrp(f2cp) = 1
        prftrp(f3cp) = 1
c
cgn        write(32,91010) f1cp,f2cp,f3cp
        do 230 , nrofon = 1 , nbfonc
          vatrtt(nrofon,f1cp) = vatren(nrofon,prftrn(f1cn))
          vatrtt(nrofon,f2cp) = vatren(nrofon,prftrn(f2cn))
          vatrtt(nrofon,f3cp) = vatren(nrofon,prftrn(f3cn))
cgn          write(ulsort,92010) vatren(nrofon,prftrn(f1cn)),
cgn     >                       vatren(nrofon,prftrn(f2cn)),
cgn     >                       vatren(nrofon,prftrn(f3cn))
  230   continue
c
c 2.4. ==> etanp1 = 31, 32, 33 ou 34 et different de etan :
c          le quadrangle est encore decoupe en trois triangles,
c          mais par un autre decoupage.
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
cgn      write(ulsort,*)'... quadrangle coupe en 3 triangles ; autre'
c
        f1hp = -filqua(quhnp1)
        f1cp = ntrsca(f1hp)
        f2cp = ntrsca(f1hp+1)
        f3cp = ntrsca(f1hp+2)
        prftrp(f1cp) = 1
        prftrp(f2cp) = 1
        prftrp(f3cp) = 1
c
        if ( typint.eq.0 ) then
c
          do 241 , nrofon = 1 , nbfonc
            daux = unstr * ( vatren(nrofon,prftrn(f1cn))
     >                     + vatren(nrofon,prftrn(f2cn))
     >                     + vatren(nrofon,prftrn(f3cn)) )
cgn            write(ulsort,90004) 'daux', daux
            vatrtt(nrofon,f1cp) = daux
            vatrtt(nrofon,f2cp) = daux
            vatrtt(nrofon,f3cp) = daux
  241     continue
c
        else
c
          call utqtri ( f1hp  , daux, daux1, coonoe, somare, aretri )
          call utqtri ( f1hp+1, daux, daux2, coonoe, somare, aretri )
          call utqtri ( f1hp+2, daux, daux3, coonoe, somare, aretri )
          daux0 = daux1 + daux2 + daux3
          daux1 = daux1 / daux0
          daux2 = daux2 / daux0
          daux3 = daux3 / daux0
          do 242 , nrofon = 1 , nbfonc
            daux = vatren(nrofon,prftrn(f1cn))
     >           + vatren(nrofon,prftrn(f2cn))
     >           + vatren(nrofon,prftrn(f3cn))
cgn            write(ulsort,90004) 'unsde*daux', unsde*daux
cgn            write(ulsort,90004) 'unsqu*daux', unsqu*daux
            vatrtt(nrofon,f1cp) = daux1 * daux
            vatrtt(nrofon,f2cp) = daux2 * daux
            vatrtt(nrofon,f3cp) = daux3 * daux
  242     continue
c
        endif
c
c 2.5. ==> etanp1 = 4 : le quadrangle est decoupe en quatre.
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation. il y
c             a ensuite raffinement du quadrangle. qui plus est, par
c             suite de la regle des ecarts de niveau, on peut avoir
c             induit un decoupage de conformite sur un ou plusieurs
c             des fils. Ce ou ces fils sont obligatoirement du cote du
c             precedent point de non conformite. Ils ne peuvent pas etre
c             des decoupages en 2 car une arte interne ne peut pas avoir
c             ete coupee puisqu'elle n'existait pas.
c
c             On donne la valeur moyenne de la fonction sur les trois
c             anciens fils a chaque nouveau fils.
c             remarque : on pourrait certainement faire mieux, avec des
c                        moyennes ponderees en fonction du recouvrement
c                        des anciens et nouveaux fils. c'est trop
c                        complique pour que cela vaille le coup.
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
c           .................         .................
c           .      . .      .         .  . .  .       .
c           .     .   .     .         . .   . .       .
c           .    .     .    .         ..     ..       .
c           .   .       .   .  ===>   .................
c           .  .         .  .         .       .       .
c           . .           . .         .       .       .
c           ..             ..         .       .       .
c           .................         .................
c
c
c           .................         .................
c           .      . .      .         .  .    .       .
c           .     .   .     .         ....    .       .
c           .    .     .    .         .     . .       .
c           .   .       .   .  ===>   .................
c           .  .         .  .         .       .       .
c           . .           . .         .       .       .
c           ..             ..         .       .       .
c           .................         .................
c
c
c       On parcourt chacun des 4 quadrangles fils et on distingue
c       le cas ou il est actif et le cas ou il est coupe en 3 triangles
c       ou en 3 quadrangles
c
      elseif ( etanp1.eq.4 ) then
cgn      write(ulsort,*)'... quadrangle coupe en 4 quadrangles'
c
        f1hp = filqua(quhnp1)
        if ( typint.eq.0 ) then
c
          do 251 , nrofon = 1 , nbfonc
c
            daux = unstr * ( vatren(nrofon,prftrn(f1cn))
     >                     + vatren(nrofon,prftrn(f2cn))
     >                     + vatren(nrofon,prftrn(f3cn)) )
cgn            write(ulsort,90004) 'daux', daux
c
            do 2511 , iaux = 0 , 3
              fihp = f1hp + iaux
cgn       write (ulsort,texte(langue,4)) 'n+1', fihp
cgn       write (ulsort,texte(langue,5)) 'n+1', hetqua(fihp)
              if ( mod(hetqua(fihp),100).eq.0 ) then
                ficp = nqusca(fihp)
cgn       write (ulsort,90002) 'ficp', ficp
                vafott(nrofon,ficp) = daux
                prfcap(ficp) = 1
              elseif ( mod(hetqua(fihp),100).ge.31 .and.
     >                 mod(hetqua(fihp),100).le.34 ) then
                f1fhp = -filqua(fihp)
                f1fcp = ntrsca(f1fhp)
                f2fcp = ntrsca(f1fhp+1)
                f3fcp = ntrsca(f1fhp+2)
c
                prftrp(f1fcp) = 1
                prftrp(f2fcp) = 1
                prftrp(f3fcp) = 1
                vatrtt(nrofon,f1fcp) = daux
                vatrtt(nrofon,f2fcp) = daux
                vatrtt(nrofon,f3fcp) = daux
              elseif ( mod(hetqua(fihp),100).ge.41 .and.
     >                 mod(hetqua(fihp),100).le.44 ) then
                f1fhp = filqua(fihp)
                f1fcp = nqusca(f1fhp)
                f2fcp = nqusca(f1fhp+1)
                f3fcp = nqusca(f1fhp+2)
c
                prfcap(f1fcp) = 1
                prfcap(f2fcp) = 1
                prfcap(f3fcp) = 1
                vafott(nrofon,f1fcp) = daux
                vafott(nrofon,f2fcp) = daux
                vafott(nrofon,f3fcp) = daux
              else
                codret = codret + 1
                write (ulsort,texte(langue,4)) 'n+1', fihp
                write (ulsort,texte(langue,5)) 'n+1', hetqua(fihp)
                write (ulsort,texte(langue,7)) etan
              endif
 2511       continue
c
  251     continue
c
        else
c
          call utqqua ( quhn, daux, daux0, coonoe, somare, arequa )
c
          do 252 , iaux = 0 , 3
c
            fihp = f1hp + iaux
            if ( mod(hetqua(fihp),100).eq.0 ) then
              ficp = nqusca(fihp)
              prfcap(ficp) = 1
              call utqqua ( fihp, daux, daux1, coonoe, somare, arequa )
              do 2521 , nrofon = 1 , nbfonc
                daux = vatren(nrofon,prftrn(f1cn))
     >               + vatren(nrofon,prftrn(f2cn))
     >               + vatren(nrofon,prftrn(f3cn))
                vafott(nrofon,ficp) = daux * daux1 / daux0
 2521         continue
            elseif ( mod(hetqua(fihp),100).ge.31 .and.
     >               mod(hetqua(fihp),100).le.34 ) then
              f1fhp = -filqua(fihp)
              f1fcp = ntrsca(f1fhp)
              f2fcp = ntrsca(f1fhp+1)
              f3fcp = ntrsca(f1fhp+2)
              prftrp(f1fcp) = 1
              prftrp(f2fcp) = 1
              prftrp(f3fcp) = 1
              call utqtri ( f1fhp  , daux, daux1,
     >                      coonoe, somare, aretri )
              call utqtri ( f1fhp+1, daux, daux2,
     >                      coonoe, somare, aretri )
              call utqtri ( f1fhp+2, daux, daux3,
     >                      coonoe, somare, aretri )
              do 2522 , nrofon = 1 , nbfonc
                daux = vatren(nrofon,prftrn(f1cn))
     >               + vatren(nrofon,prftrn(f2cn))
     >               + vatren(nrofon,prftrn(f3cn))
                vatrtt(nrofon,f1fcp) = daux1 * daux / daux0
                vatrtt(nrofon,f2fcp) = daux2 * daux / daux0
                vatrtt(nrofon,f3fcp) = daux3 * daux / daux0
 2522         continue
            elseif ( mod(hetqua(fihp),100).ge.41 .and.
     >               mod(hetqua(fihp),100).le.44 ) then
              f1fhp = filqua(fihp)
              f1fcp = nqusca(f1fhp)
              f2fcp = nqusca(f1fhp+1)
              f3fcp = nqusca(f1fhp+2)
c
              prfcap(f1fcp) = 1
              prfcap(f2fcp) = 1
              prfcap(f3fcp) = 1
              call utqqua ( f1fhp  , daux, daux1,
     >                      coonoe, somare, arequa )
              call utqqua ( f1fhp+1, daux, daux2,
     >                      coonoe, somare, arequa )
              call utqqua ( f1fhp+2, daux, daux3,
     >                      coonoe, somare, arequa )
              do 2523 , nrofon = 1 , nbfonc
                daux = vatren(nrofon,prftrn(f1cn))
     >               + vatren(nrofon,prftrn(f2cn))
     >               + vatren(nrofon,prftrn(f3cn))
                vafott(nrofon,f1fcp) = daux1 * daux / daux0
                vafott(nrofon,f2fcp) = daux2 * daux / daux0
                vafott(nrofon,f3fcp) = daux3 * daux / daux0
 2523         continue
            else
              codret = codret + 1
              write (ulsort,texte(langue,4)) 'n+1', fihp
              write (ulsort,texte(langue,5)) 'n+1', hetqua(fihp)
              write (ulsort,texte(langue,7)) etan
            endif
c
  252     continue
c
        endif
c
c 2.6. ==> etanp1 = 41, 42, 43 ou 43 : le quadrangle est decoupe en
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
c           .      . .      .         .       .       .
c           .     .   .     .         .       .       .
c           .    .     .    .         .       .       .
c           .   .       .   .  ===>   .........       .
c           .  .         .  .         .         .     .
c           . .           . .         .           .   .
c           ..             ..         .             . .
c           .................         .................
c
      elseif ( etanp1.ge.41 .and. etanp1.le.44 ) then
cgn      write(ulsort,*)'... quadrangle coupe en 3 quadrangles'
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
          do 261 , nrofon = 1 , nbfonc
            daux = unstr * ( vatren(nrofon,prftrn(f1cn))
     >                     + vatren(nrofon,prftrn(f2cn))
     >                     + vatren(nrofon,prftrn(f3cn)) )
            vafott(nrofon,f1cp) = daux
            vafott(nrofon,f2cp) = daux
            vafott(nrofon,f3cp) = daux
  261     continue
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
          do 262 , nrofon = 1 , nbfonc
            daux = vatren(nrofon,prftrn(f1cn))
     >           + vatren(nrofon,prftrn(f2cn))
     >           + vatren(nrofon,prftrn(f3cn))
            vafott(nrofon,f1cp) = daux1 * daux
            vafott(nrofon,f2cp) = daux2 * daux
            vafott(nrofon,f3cp) = daux3 * daux
  262     continue
c
        endif

c 2.7. ==> aucun autre etat sur le quadrangle courant n'est possible
c
      else
c
        coderr = 1
        write (ulsort,1792) 'Quadrangle', quhn, etan, quhnp1, etanp1
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
