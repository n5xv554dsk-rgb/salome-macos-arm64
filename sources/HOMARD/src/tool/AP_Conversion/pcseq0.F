      subroutine pcseq0 ( etan, etanp1, quhn, quhnp1, typint,
     >                    prfcan, prfcap,
     >                    coonoe,
     >                    somare,
     >                    arequa, filqua,
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
c                       Quadrangles d'etat anterieur 0
c                       -                            -
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
      parameter ( nompro = 'PCSEQ0' )
c
#include "nblang.h"
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
      integer prfcan(*), prfcap(*)
      integer somare(2,nbarto)
      integer arequa(nbquto,4), filqua(nbquto)
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
c     qucn   = QUadrangle courant en numerotation Calcul a l'it. N
c     qucnp1 = QUadrangle courant en numerotation Calcul a l'it. N+1
c
      integer qucn, qucnp1
c
c     f1hp = Fils 1er du quadrangle en numerotation Homard a l'it. N+1
c     f1cp = Fils 1er du quadrangle en numerotation Calcul a l'it. N+1
c     f2cp = Fils 2eme du quadrangle en numerotation Calcul a l'it. N+1
c     f3cp = Fils 3eme du quadrangle en numerotation Calcul a l'it. N+1
c     f4cp = Fils 4eme du quadrangle en numerotation Calcul a l'it. N+1
c
      integer f1hp
      integer f1cp, f2cp, f3cp, f4cp
c
      integer coderr
      integer nrofon
      integer iaux
c
      double precision daux
      double precision daux0, daux1, daux2, daux3, daux4
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
      coderr = 0
c
c 1.2. ==> on repere son ancien numero dans le calcul
c
      qucn = nqueca(quhn)
#ifdef _DEBUG_HOMARD_
      write (ulsort,1792) 'Quadrangle', quhn, etan, quhnp1, etanp1
      write(ulsort,90002) 'qucn', qucn
      call dmflsh (iaux)
#endif
c
      if ( prfcan(qucn).gt.0 ) then
c
c====
c 2. etan = 0 : le quadrangle etait actif
c    On explore tous les etats du quadrangle a l'iteration n+1
c====
c 2.1. ==> etanp1 = 0 : le quadrangle etait actif et l'est encore ;
c                       il est inchange
c             c'est le cas le plus simple : on prend la valeur de la
c             fonction associee a l'ancien numero du quadrangle.
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
cgn      write(ulsort,90002)'quadrangle garde - prfcan', prfcan(qucn)
c
        qucnp1 = nqusca(quhnp1)
        prfcap(qucnp1) = 1
c
        do 21 , nrofon = 1 , nbfonc
          vafott(nrofon,qucnp1) = vafoen(nrofon,prfcan(qucn))
cgn              write(ulsort,90004)'Valeurs anciennes',
cgn     >              vafoen(nrofon,prfcan(qucn))
   21   continue
cgn        write(ulsort,90002) 'qucnp1',qucnp1
c
c 2.2. ==> etanp1 = 21/22 : le quadrangle etait actif et
c          il est decoupe en 2.
c          les deux fils prennent la valeur de la fonction sur le pere
c           .................         .................
c           .               .         .               .
c           .               .         .               .
c           .               .         .               .
c           .               .  ===>   .................
c           .               .         .               .
c           .               .         .               .
c           .               .         .              .
c           .................         .................
c
      elseif ( etanp1.eq.21 .or. etanp1.eq.22 ) then
cgn      write(ulsort,*)'... quadrangle coupe en 2'
c
        f1hp = filqua(quhnp1)
        f1cp = nqusca(f1hp)
        f2cp = nqusca(f1hp+1)
        prfcap(f1cp) = 1
        prfcap(f2cp) = 1
cgn        write(*,*) 'f1cp = ',f1cp
cgn        write(*,*) 'f2cp = ',f2cp
        if ( typint.eq.0 ) then
          do 221 , nrofon = 1 , nbfonc
            daux = vafoen(nrofon,prfcan(qucn))
            vafott(nrofon,f1cp) = daux
            vafott(nrofon,f2cp) = daux
cgn            write(ulsort,92010) daux
  221     continue
        else
          call utqqua ( f1hp  , daux, daux1, coonoe, somare, arequa )
          call utqqua ( f1hp+1, daux, daux2, coonoe, somare, arequa )
          daux0 = daux1 + daux2
          daux1 = daux1 / daux0
          daux2 = daux2 / daux0
          do 222 , nrofon = 1 , nbfonc
            daux = vafoen(nrofon,prfcan(qucn))
            vafott(nrofon,f1cp) = daux1 * daux
            vafott(nrofon,f2cp) = daux2 * daux
cgn            write(ulsort,92010) daux
  222     continue
        endif
cgn        write(23,91010) f1cp,f2cp
cgn        write(ulsort,91010) qucn,-1,
cgn     >                     f1cp,f2cp
c
c 2.3. ==> etanp1 = 31, 32, 33 ou 34 : le quadrangle etait actif
c          et il est decoupe en 3 triangles.
c          les trois fils prennent la valeur de la fonction sur le pere
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
cgn      write(ulsort,*)'... quadrangle coupe en 3 triangles'
c
        f1hp = -filqua(quhnp1)
        f1cp = ntrsca(f1hp)
        f2cp = ntrsca(f1hp+1)
        f3cp = ntrsca(f1hp+2)
        prftrp(f1cp) = 1
        prftrp(f2cp) = 1
        prftrp(f3cp) = 1
cgn        write(ulsort,91010) f1cp,f2cp,f3cp
cgn        write(ulsort,91010) qucn,-1,
cgn     >                     f1cp,f2cp,f3cp
        if ( typint.eq.0 ) then
          do 231 , nrofon = 1 , nbfonc
            daux = vafoen(nrofon,prfcan(qucn))
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
            daux = vafoen(nrofon,prfcan(qucn))
            vatrtt(nrofon,f1cp) = daux1 * daux
            vatrtt(nrofon,f2cp) = daux2 * daux
            vatrtt(nrofon,f3cp) = daux3 * daux
  232     continue
        endif
c
c 2.4. ==> etanp1 = 4 : le quadrangle etait actif et
c          il est decoupe en 4.
c          les quatre fils prennent la valeur de la fonction sur le pere
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
cgn      write(ulsort,*)'... quadrangle coupe en 4 quadrangles'
c
        f1hp = filqua(quhnp1)
        f1cp = nqusca(f1hp)
        f2cp = nqusca(f1hp+1)
        f3cp = nqusca(f1hp+2)
        f4cp = nqusca(f1hp+3)
        prfcap(f1cp) = 1
        prfcap(f2cp) = 1
        prfcap(f3cp) = 1
        prfcap(f4cp) = 1
cgn        write(*,*) 'f1cp = ',f1cp
cgn        write(*,*) 'f2cp = ',f2cp
cgn        write(*,*) 'f3cp = ',f3cp
cgn        write(*,*) 'f4cp = ',f4cp
        if ( typint.eq.0 ) then
          do 241 , nrofon = 1 , nbfonc
            daux = vafoen(nrofon,prfcan(qucn))
            vafott(nrofon,f1cp) = daux
            vafott(nrofon,f2cp) = daux
            vafott(nrofon,f3cp) = daux
            vafott(nrofon,f4cp) = daux
cgn              write(ulsort,92010) daux
  241    continue
        else
          call utqqua ( f1hp  , daux, daux1, coonoe, somare, arequa )
          call utqqua ( f1hp+1, daux, daux2, coonoe, somare, arequa )
          call utqqua ( f1hp+2, daux, daux3, coonoe, somare, arequa )
          call utqqua ( f1hp+3, daux, daux4, coonoe, somare, arequa )
          daux0 = daux1 + daux2 + daux3 + daux4
          daux1 = daux1 / daux0
          daux2 = daux2 / daux0
          daux3 = daux3 / daux0
          daux4 = daux4 / daux0
          do 242 , nrofon = 1 , nbfonc
            daux = vafoen(nrofon,prfcan(qucn))
            vafott(nrofon,f1cp) = daux1 * daux
            vafott(nrofon,f2cp) = daux2 * daux
            vafott(nrofon,f3cp) = daux3 * daux
            vafott(nrofon,f4cp) = daux4 * daux
cgn              write(ulsort,92010) daux
  242     continue
        endif
cgn        write(23,91010) f1cp,f2cp,f3cp,f4cp
cgn        write(ulsort,91010) qucn,-1,
cgn     >                     f1cp,f2cp,f3cp,f4cp
c
c 2.5. ==> etanp1 = 41, ..., 44 : le quadrangle etait actif
c                    et est decoupe en 3 quadrangles.
c                    les trois fils prennent la valeur de la fonction
c                    sur le pere
c           .................         .................
c           .               .         .       .       .
c           .               .         .       .       .
c           .               .         .       .       .
c           .               .  ===>   .........       .
c           .               .         .         .     .
c           .               .         .           .   .
c           .               .         .             . .
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
cgn        write(*,*) 'f1cp = ',f1cp
cgn        write(*,*) 'f2cp = ',f2cp
cgn        write(*,*) 'f3cp = ',f3cp
        if ( typint.eq.0 ) then
          do 251 , nrofon = 1 , nbfonc
            daux = vafoen(nrofon,prfcan(qucn))
            vafott(nrofon,f1cp) = daux
            vafott(nrofon,f2cp) = daux
            vafott(nrofon,f3cp) = daux
  251     continue
        else
          call utqqua ( f1hp  , daux, daux1, coonoe, somare, arequa )
          call utqqua ( f1hp+1, daux, daux2, coonoe, somare, arequa )
          call utqqua ( f1hp+2, daux, daux3, coonoe, somare, arequa )
          daux0 = daux1 + daux2 + daux3
          daux1 = daux1 / daux0
          daux2 = daux2 / daux0
          daux3 = daux3 / daux0
          do 252 , nrofon = 1 , nbfonc
            daux = vafoen(nrofon,prfcan(qucn))
            vafott(nrofon,f1cp) = daux1 * daux
            vafott(nrofon,f2cp) = daux2 * daux
            vafott(nrofon,f3cp) = daux3 * daux
  252     continue
        endif
cgn        write(23,91010) f1cp,f2cp,f3cp
cgn        write(ulsort,91010) qucn,-1,
cgn     >                     f1cp,f2cp,f3cp
c
c 2.6. ==> aucun autre etat sur le quadrangle courant n'est possible
c
      else
c
        coderr = 1
        write (ulsort,1792) 'Quadrangle', quhn, etan, quhnp1, etanp1
        write (ulsort,*) ' '
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
