      subroutine pcsep1 ( etan, etanp1, pehn, pehnp1, typint,
     >                    prfcap,
     >                    nfpyrn, nftetn, ficn,
     >                    nfpyrp, nftetp, ficp, propor,
     >                    coonoe,
     >                    somare,
     >                    aretri,
     >                    arequa,
     >                    tritet, cotrte, aretet,
     >                    facpen, cofape, arepen,
     >                    facpyr, cofapy, arepyr,
     >                    hetpen, filpen, fppyte,
     >                            npesca,
     >                    ntesca,
     >                    npysca,
     >                    nbfonc, vafott,
     >                    vateen, vatett,
     >                    prften, prftep,
     >                    vapyen, vapytt,
     >                    prfpyn, prfpyp,
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
c                       Pentaedres - decoupage par conformite avant
c                       -
c remarque : pcseh1 et pcsep1 sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . etan   . e   .    1   . ETAt du pentaedre a l'iteration N          .
c . etanp1 . e   .    1   . ETAt du pentaedre a l'iteration N+1        .
c . pehn   . e   .    1   . PEntaedre courant en numerotation Homard   .
c .        .     .        . a l'iteration N                            .
c . pehnp1 . e   .    1   . PEntaedre courant en numerotation Homard   .
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
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . nfpyrn . e   .    1   . nombre de fils pyramides n                 .
c . nftetn . e   .    1   . nombre de fils tetraedres n                .
c . ficn   . e   .  3,11  . fils en numerotation du calcul n           .
c .        .     .        . 1 : pentaedres                             .
c .        .     .        . 2 : pyramides                              .
c .        .     .        . 3 : tetraedres                             .
c . nfpyrp . e   .    1   . nombre de fils pyramides n+1               .
c . nftetp . e   .    1   . nombre de fils tetraedres n+1              .
c . ficp   . e   .  3,11  . fils en numerotation du calcul n+1         .
c .        .     .        . 1 : pentaedres                             .
c .        .     .        . 2 : pyramides                              .
c .        .     .        . 3 : tetraedres                             .
c . propor . e   .   11   . proportion de volume entre fils et pere    .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . fppyte . e   .2*nbpeco. fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) =-j .
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
c . npesca . e   . rspeto . numero des pentaedres dans le calcul sortie.
c . ntesca . e   . rsteto . numero des tetraedres dans le calcul sortie.
c . npysca . e   . rspyto . numero des pyramides dans le calcul sortie .
c . nbfonc . e   .    1   . nombre de fonctions elements de volume     .
c . vafott . es  . nbfonc*. variables en sortie de l'adaptation        .
c .        .     . nbevso .                                            .
c . vateen . e   . nbfonc*. variables en entree de l'adaptation pour   .
c .        .     .    *   . les tetraedres                             .
c . vatett .   a . nbfonc*. tableau temporaire de la solution pour     .
c .        .     .    *   . les tetraedres                             .
c . prften . es  .   *    . En numero du calcul a l'iteration n   :    .
c .        .     .        . 0 : le tetraedre est absent du profil      .
c .        .     .        . 1 : le tetraedre est present dans le profil.
c . prftep . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : le tetraedre est absent du profil      .
c .        .     .        . 1 : le tetraedre est present dans le profil.
c . vapyen . e   . nbfonc*. variables en entree de l'adaptation pour   .
c .        .     .    *   . les pyramides                              .
c . vapytt .   a . nbfonc*. tableau temporaire de la solution pour     .
c .        .     .    *   . les pyramides                              .
c . prfpyn . es  .   *    . En numero du calcul a l'iteration n   :    .
c .        .     .        . 0 : la pyramide est absente du profil      .
c .        .     .        . 1 : la pyramide est presente dans le profil.
c . prfpyp . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : la pyramide est absente du profil      .
c .        .     .        . 1 : la pyramide est presente dans le profil
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
      parameter ( nompro = 'PCSEP1' )
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
#include "nombte.h"
#include "nombpe.h"
#include "nombpy.h"
#include "nombsr.h"
c
c 0.3. ==> arguments
c
      integer etan, etanp1, pehn, pehnp1
      integer typint
      integer nbfonc
      integer prfcap(*)
c
      integer nfpyrn, nftetn
      integer ficn(3,11)
      integer nfpyrp, nftetp
      integer ficp(3,11)
c
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
      integer hetpen(nbpeto), filpen(nbpeto), fppyte(2,nbpeco)
      integer npesca(rsheto)
      integer ntesca(rsteto)
      integer npysca(rspyto)
      integer prften(*), prftep(*)
      integer prfpyn(*), prfpyp(*)
c
      double precision propor(11)
      double precision coonoe(nbnoto,sdim)
      double precision vafott(nbfonc,*)
      double precision vateen(nbfonc,*)
      double precision vatett(nbfonc,*)
      double precision vapyen(nbfonc,*)
      double precision vapytt(nbfonc,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer pecnp1
      integer f1hp
c
      integer nrofon
c
      logical afaire
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
#include "impr03.h"
c
      codret = 0
c
c====
c 2. seulement si des valeurs existent
c====
c
      afaire = .true.
c
      do 21 , iaux = 1 , nfpyrn
        if ( prfpyn(ficn(2,iaux)).eq.0 ) then
          afaire = .false.
        endif
   21 continue
c
      do 22 , iaux = 1 , nftetn
        if ( prften(ficn(3,iaux)).eq.0 ) then
          afaire = .false.
        endif
   22 continue
c
      if ( afaire ) then
c
cgn      write(ulsort,90002) 'etanp1', etanp1
cgn      write(ulsort,90002) 'pehnp1', pehnp1
cgn      write(ulsort,90002) 'nfpyrn, nftetn', nfpyrn, nftetn
      daux1 = 1.d0 / dble(nfpyrn+nftetn)
c
c====
c 3. Le pentaedre etait coupe en conformite
c====
c 3.1. ==> etanp1 = 0 : le pentaedre est reactive.
c          0n lui attribue la valeur moyenne ou totale sur les
c          anciens fils.
c        remarque : cela arrive seulement avec du deraffinement.
c
      if ( etanp1.eq.0 ) then
cgn        write(ulsort,*) '... le pentaedre est reactive'
c
        pecnp1 = npesca(pehnp1)
cgn        write(ulsort,*) 'prfcap pour',pecnp1
        prfcap(pecnp1) = 1
c
        if ( typint.eq.0 ) then
c
          do 310 , nrofon = 1 , nbfonc
c
            daux = 0.d0
            do 3101 , iaux = 1 , nfpyrn
              daux = daux + vapyen(nrofon,prfpyn(ficn(2,iaux)))
 3101       continue
            do 3102 , iaux = 1 , nftetn
              daux = daux + vateen(nrofon,prften(ficn(3,iaux)))
 3102       continue
c
            vafott(nrofon,pecnp1) = daux * daux1
c
  310     continue
c
        else
c
          do 311 , nrofon = 1 , nbfonc
            daux = 0.d0
            do 3111 , iaux = 1 , nfpyrn
              daux = daux + vapyen(nrofon,prfpyn(ficn(2,iaux)))
 3111       continue
            do 3112 , iaux = 1 , nftetn
              daux = daux + vateen(nrofon,prften(ficn(3,iaux)))
 3112       continue
            vafott(nrofon,pecnp1) = daux
  311     continue
c
        endif
c
c 3.2. ==> etanp1 = etan : le pentaedre est decoupe selon
c          le meme decoupage. Comme les conventions sont les memes,
c          on remet les memes valeurs.
c
      elseif ( etanp1.eq.etan ) then
c
        do 32 , nrofon = 1 , nbfonc
          do 321 , iaux = 1 , nfpyrn
            vapytt(nrofon,ficp(2,iaux)) =
     >                             vapyen(nrofon,prfpyn(ficn(2,iaux)))
  321     continue
          do 322 , iaux = 1 , nftetn
            vatett(nrofon,ficp(3,iaux)) =
     >                             vateen(nrofon,prften(ficn(3,iaux)))
  322     continue
   32   continue
c
c 3.3. ==> un autre decoupage de conformite
c
      elseif ( ( etanp1.ge. 1 .and. etanp1.le. 6 ) .or.
     >         ( etanp1.ge.17 .and. etanp1.le.19 ) .or.
     >         ( etanp1.ge.21 .and. etanp1.le.26 ) .or.
     >         ( etanp1.ge.31 .and. etanp1.le.36 ) .or.
     >         ( etanp1.ge.43 .and. etanp1.le.45 ) .or.
     >         ( etanp1.ge.51 .and. etanp1.le.52 ) ) then
c
        if ( typint.eq.0 ) then
c
          do 330 , nrofon = 1 , nbfonc
c
            daux = 0.d0
            do 3301 , iaux = 1 , nfpyrn
              daux = daux + vapyen(nrofon,prfpyn(ficn(2,iaux)))
 3301       continue
            do 3302 , iaux = 1 , nftetn
              daux = daux + vateen(nrofon,prften(ficn(3,iaux)))
 3302       continue
            daux = daux * daux1
c
            do 3303 , iaux = 1 , nfpyrp
              vapytt(nrofon,ficp(2,iaux)) = daux
 3303       continue
            do 3304 , iaux = 1 , nftetp
              vatett(nrofon,ficp(3,iaux)) = daux
 3304       continue
c
  330     continue
c
        else
c
          do 331 , nrofon = 1 , nbfonc
c
            daux = 0.d0
            do 3311 , iaux = 1 , nfpyrn
              daux = daux + vapyen(nrofon,prfpyn(ficn(2,iaux)))
 3311       continue
            do 3312 , iaux = 1 , nftetn
              daux = daux + vateen(nrofon,prften(ficn(3,iaux)))
 3312       continue
c
            do 3313 , iaux = 1 , nfpyrp
              vapytt(nrofon,ficp(2,iaux)) = daux * propor(iaux)
 3313       continue
            do 3314 , iaux = 1 , nftetp
              vatett(nrofon,ficp(3,iaux)) = daux * propor(iaux+nfpyrp)
 3314       continue
c
  331     continue
c
        endif
c
c 3.4. ==> etanp1 = 80 : le pentaedre est coupe en 8 pentaedres
c             c'est ce qui se passe quand un decoupage de conformite
c             est supprime au debut des algorithmes d'adaptation. il y
c             a ensuite raffinement du pentaedre. qui plus est, par
c             suite de la regle des ecarts de niveau, on peut avoir
c             induit un decoupage de conformite sur 1,2,3 ou 4 des fils.
c             Ce ou ces fils sont obligatoirement du cote du precedent
c             point de non conformite.
c
      elseif ( etanp1.eq.80 ) then
cgn         print *,'... le penta est coupe en 8 penta'
c
        f1hp = filpen(pehnp1)
        daux1 = 1.d0 / dble(nfpyrn+nftetn)
cgn        write(ulsort,*) 'f1hp = ', f1hp
        do 34 , nrofon = 1 , nbfonc
c
          daux = 0.d0
          do 3401 , iaux = 1 , nfpyrn
            daux = daux + vapyen(nrofon,prfpyn(ficn(2,iaux)))
 3401     continue
          do 3402 , iaux = 1 , nftetn
            daux = daux + vateen(nrofon,prften(ficn(3,iaux)))
 3402     continue
c
          iaux = nrofon
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSEP9', nompro
#endif
          call pcsep9 ( etan, etanp1, pehn, pehnp1, typint,
     >                  f1hp, iaux, daux, daux1, prfcap,
     >                  ficp, propor,
     >                  coonoe, somare, aretri, arequa,
     >                  tritet, cotrte, aretet,
     >                  facpen, cofape, arepen,
     >                  facpyr, cofapy, arepyr,
     >                  hetpen, filpen, fppyte,
     >                  npesca,
     >                  ntesca,
     >                  npysca,
     >                  nbfonc, vafott,
     >                  prftep, vatett,
     >                  prfpyp, vapytt,
     >                  ulsort, langue, codret )
c
   34   continue
c
      endif
c
c====
c 4. affectation des profils
c    Attention : pour les fils en pentaedres, c'est fait dans pcsep9
c====
c
      if ( codret.eq.0 ) then
c
      do 42 , iaux = 1 , nfpyrp
        prfpyp(ficp(2,iaux)) = 1
   42 continue
c
      do 43 , iaux = 1 , nftetp
        prftep(ficp(3,iaux)) = 1
   43 continue
c
      endif
c
      endif
c
c====
c 5. la fin
c====
c
      if ( codret.ne.0 ) then
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
