      subroutine pcsep0 ( etan, etanp1, pehn, pehnp1, typint,
     >                    prfcan, prfcap,
     >                    nfpenp, nfpyrp, nftetp, ficp, propor,
     >                    npeeca, npesca,
     >                    nbfonc, vafoen, vafott,
     >                    vatett, prftep,
     >                    vapytt, prfpyp,
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
c                       Pentaedres d'etat anterieur 0
c                       -                           -
c remarque : pcseh0 et pcsep0 sont des clones
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
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . nfpenp . e   .    1   . nombre de fils pentaedres                  .
c . nfpyrp . e   .    1   . nombre de fils pyramides                   .
c . nftetp . e   .    1   . nombre de fils tetraedres                  .
c . ficp   . e   .  3,11  . numeros des fils en numerotation du calcul .
c .        .     .        . 1 : pentaedres                             .
c .        .     .        . 2 : pyramides                              .
c .        .     .        . 3 : tetraedres                             .
c . propor . e   .   11   . proportion de volume entre fils et pere    .
c . npeeca . e   .    *   . numero des pentaedres dans le calcul entree.
c . npesca . e   . rspeto . numero des pentaedres dans le calcul sortie.
c . nbfonc . e   .    1   . nombre de fonctions elements de volume     .
c . vafoen . e   . nbfonc*. variables en entree de l'adaptation        .
c .        .     . nbeven .                                            .
c . vafott . es  . nbfonc*. variables en sortie de l'adaptation        .
c .        .     . nbevso .                                            .
c . vatett .   a . nbfonc*. tableau temporaire de la solution pour     .
c .        .     .    *   . les tetraedres                             .
c . prftep . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : le tetraedre est absent du profil      .
c .        .     .        . 1 : le tetraedre est present dans le profil.
c . prfpyp . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : la pyramide est absente du profil      .
c .        .     .        . 1 : la pyramide est presente dans le profil.
c . vapytt .   a . nbfonc*. tableau temporaire de la solution pour     .
c .        .     .    *   . les pyramides                              .
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
      parameter ( nompro = 'PCSEP0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "nombsr.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer etan, etanp1, pehn, pehnp1
      integer typint
      integer nbfonc
      integer prfcan(*), prfcap(*)
c
      integer nfpenp, nfpyrp, nftetp
      integer ficp(3,11)
c
      integer npeeca(reheto), npesca(rsheto)
      integer prftep(*)
      integer prfpyp(*)
c
      double precision propor(11)
      double precision vafoen(nbfonc,*)
      double precision vafott(nbfonc,*)
      double precision vatett(nbfonc,*)
      double precision vapytt(nbfonc,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
c     pecn   = Pentaedre courant en numerotation du Calcul a l'it. N
c     pecnp1 = Pentaedre courant en numerotation du Calcul a l'it. N+1
c
      integer pecn, pecnp1
c
      integer nrofon
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
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     >'(''Pent. en cours : numero a l''''iteration '',a3,'' : '',i10)'
      texte(1,5) =
     >'(''                 etat a l''''iteration '',a3,''   : '',i4)'
c
      texte(2,4) =
     >'(''Current prism : # at iteration '',a3,''      : '',i10)'
      texte(2,5) =
     > '(''                     status at iteration '',a3,'' : '',i4)'
c
      codret = 0
c
c====
c 2. seulement si une valeur existe
c====
c
      pecn = npeeca(pehn)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) 'n  ', pehn
      write (ulsort,texte(langue,5)) 'n  ', etan
      write (ulsort,texte(langue,4)) 'n+1', pehnp1
      write (ulsort,texte(langue,5)) 'n+1', etanp1
      write (ulsort,90002) 'prfcan(pecn)', prfcan(pecn)
      call dmflsh (iaux)
      write (ulsort,90002) 'nfpenp', nfpenp
      write (ulsort,90002) 'nfpyrp', nfpyrp
      write (ulsort,90002) 'nftetp', nftetp
#endif
c
      if ( prfcan(pecn).gt.0 ) then
cgn      write(ulsort,90002) 'typint', typint
cgn      write(ulsort,90002) 'etanp1', etanp1
c
c====
c 3. parcours des types de decoupages
c====
c 3.1. ==> etanp1 = 0 : le pentaedre est actif ; il est inchange
c             c'est le cas le plus simple : on prend la valeur de la
c             fonction associee a l'ancien numero du pentaedre.
c
      if ( etanp1.eq.0 ) then
c
        pecnp1 = npesca(pehnp1)
        prfcap(pecnp1) = 1
c
        do 31 , nrofon = 1, nbfonc
          vafott(nrofon,pecnp1) = vafoen(nrofon,prfcan(pecn))
   31  continue
c
c 3.2. ==> etanp1 = 1, ..., 6 : le pentaedre est coupe en
c                               1 tetraedre et 2 pyramides
c          etanp1 = 17, ..., 19 : le pentaedre est coupe en
c                                 2 tetraedres et 1 pyramide
c          etanp1 = 21, ..., 26 : le pentaedre est coupe en
c                                 6 tetraedres
c          etanp1 = 31, ..., 36 : le pentaedre est coupe en
c                                 10 tetraedres et 1 pyramide
c          etanp1 = 43, ..., 45 : le pentaedre est coupe en
c                                 2 tetraedres et 4 pyramides
c          etanp1 = 51, 52 : le pentaedre est coupe en
c                            11 tetraedres
c
      elseif ( ( etanp1.ge.1 .and. etanp1.le.6 ) .or.
     >         ( etanp1.ge.17 .and. etanp1.le.19 ) .or.
     >         ( etanp1.ge.21 .and. etanp1.le.26 ) .or.
     >         ( etanp1.ge.31 .and. etanp1.le.36 ) .or.
     >         ( etanp1.ge.43 .and. etanp1.le.45 ) .or.
     >         ( etanp1.ge.51 .and. etanp1.le.52 ) ) then
c
        if ( typint.eq.0 ) then
c
          do 320 , nrofon = 1 , nbfonc
            daux = vafoen(nrofon,prfcan(pecn))
            do 3201 , iaux = 1 , nfpyrp
              vapytt(nrofon,ficp(2,iaux)) = daux
 3201       continue
            do 3202 , iaux = 1 , nftetp
              vatett(nrofon,ficp(3,iaux)) = daux
 3202       continue
  320     continue
c
        else
c
          do 321 , nrofon = 1 , nbfonc
            daux = vafoen(nrofon,prfcan(pecn))
            do 3211 , iaux = 1 , nfpyrp
              vapytt(nrofon,ficp(2,iaux)) = daux * propor(iaux)
 3211       continue
            do 3212 , iaux = 1 , nftetp
              vatett(nrofon,ficp(3,iaux)) = daux * propor(iaux+nfpyrp)
 3212       continue
  321     continue
c
        endif
c
c 3.3. ==> etanp1 = 80 : le pentaedre est decoupe en 8.
c
      elseif ( etanp1.eq.80  ) then
c
        if ( typint.eq.0 ) then
c
          do 330 , nrofon = 1, nbfonc
            daux = vafoen(nrofon,prfcan(pecn))
            do 3301 , iaux = 1 , nfpenp
              vafott(nrofon,ficp(1,iaux)) = daux
 3301       continue
  330     continue
c
        else
c
          do 331 , nrofon = 1, nbfonc
            daux = vafoen(nrofon,prfcan(pecn))
            do 3311 , iaux = 1 , nfpenp
              vafott(nrofon,ficp(1,iaux)) = daux * propor(iaux)
 3311       continue
  331     continue
c
        endif
c
c 3.4. ==> aucun autre etat sur le pentaedre courant n'est possible
c
      else
c
        codret = 1
        write (ulsort,texte(langue,4)) 'n  ', pehn
        write (ulsort,texte(langue,5)) 'n  ', etan
        write (ulsort,texte(langue,4)) 'n+1', pehnp1
        write (ulsort,texte(langue,5)) 'n+1', etanp1
c
      endif
c
c====
c 4. affectation des profils
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. affectation des profils ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      do 41 , iaux = 1 , nfpenp
        prfcap(ficp(1,iaux)) = 1
   41 continue
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
