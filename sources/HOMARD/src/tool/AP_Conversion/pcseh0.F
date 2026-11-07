      subroutine pcseh0 ( etan, etanp1, hehn, hehnp1, typint,
     >                    prfcan, prfcap,
     >                    nfhexp, nfpyrp, nftetp, ficp, propor,
     >                    nheeca, nhesca,
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
c                       Hexaedres d'etat anterieur 0
c                       -                          -
c remarque : pcseh0 et pcsep0 sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . etan   . e   .    1   . ETAt de l'hexaedre a l'iteration N         .
c . etanp1 . e   .    1   . ETAt de l'hexaedre a l'iteration N+1       .
c . hehn   . e   .    1   . Hexaedre courant en numerotation Homard    .
c .        .     .        . a l'iteration N                            .
c . hehnp1 . e   .    1   . Hexaedre courant en numerotation Homard    .
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
c . nfhexp . e   .    1   . nombre de fils hexaedres                   .
c . nfpyrp . e   .    1   . nombre de fils pyramides                   .
c . nftetp . e   .    1   . nombre de fils tetraedres                  .
c . ficp   . e   .  3,18  . numeros des fils en numerotation du calcul .
c .        .     .        . 1 : hexaedres                              .
c .        .     .        . 2 : pyramides                              .
c .        .     .        . 3 : tetraedres                             .
c . propor . e   .   18   . proportion de volume entre fils et pere    .
c . nheeca . e   . reteto . numero des hexaedres dans le calcul entree .
c . nhesca . e   . rsheto . numero des hexaedres dans le calcul sortie .
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
      parameter ( nompro = 'PCSEH0' )
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
      integer etan, etanp1, hehn, hehnp1
      integer typint
      integer nbfonc
      integer prfcan(*), prfcap(*)
c
      integer nfhexp, nfpyrp, nftetp
      integer ficp(3,18)
c
      integer nheeca(reheto), nhesca(rsheto)
      integer prftep(*)
      integer prfpyp(*)
c
      double precision propor(18)
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
c     hecn   = Hexaedre courant en numerotation du Calcul a l'it. N
c     hecnp1 = Hexaedre courant en numerotation du Calcul a l'it. N+1
c
      integer hecn, hecnp1
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
     >'(''Hexa. en cours : numero a l''''iteration '',a3,'' : '',i10)'
      texte(1,5) =
     >'(''                 etat a l''''iteration '',a3,''   : '',i4)'
c
      texte(2,4) =
     >'(''Current hexahedron : # at iteration '',a3,''     : '',i10)'
      texte(2,5) =
     > '(  ''                     status at iteration '',a3,'' : '',i4)'
c
      codret = 0
c
c====
c 2. seulement si une valeur existe
c====
c
      hecn = nheeca(hehn)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) 'n  ', hehn
      write (ulsort,texte(langue,5)) 'n  ', etan
      write (ulsort,texte(langue,4)) 'n+1', hehnp1
      write (ulsort,texte(langue,5)) 'n+1', etanp1
      write (ulsort,90002) 'prfcan(hecn)', prfcan(hecn)
      call dmflsh (iaux)
      write (ulsort,90002) 'nfhexp', nfhexp
      write (ulsort,90002) 'nfpyrp', nfpyrp
      write (ulsort,90002) 'nftetp', nftetp
#endif
c
      if ( prfcan(hecn).gt.0 ) then
cgn      write(ulsort,90002) 'typint', typint
cgn      write(ulsort,90002) 'etanp1', etanp1
c
c====
c 3. parcours des types de decoupages
c====
c 3.1. ==> etanp1 = 0 : l'hexaedre etait actif et l'est encore ;
c                       il est inchange
c             c'est le cas le plus simple : on prend la valeur de la
c             fonction associee a l'ancien numero de l'hexaedre.
c
      if ( etanp1.eq.0 ) then
c
        hecnp1 = nhesca(hehnp1)
        prfcap(hecnp1) = 1
c
        do 31 , nrofon = 1, nbfonc
          vafott(nrofon,hecnp1) = vafoen(nrofon,prfcan(hecn))
   31   continue
c
c 3.2. ==> etanp1 > 11 : l'hexaedre etait actif et est en conformite
c
      elseif ( etanp1.ge.11 ) then
c
        if ( typint.eq.0 ) then
c
          do 320 , nrofon = 1 , nbfonc
            daux = vafoen(nrofon,prfcan(hecn))
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
            daux = vafoen(nrofon,prfcan(hecn))
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
c 3.3. ==> etan p1 = 8 : l'hexaedre est decoupe en 8.
c
      elseif ( etanp1.eq.8  ) then
c
        if ( typint.eq.0 ) then
c
          do 330 , nrofon = 1, nbfonc
            daux = vafoen(nrofon,prfcan(hecn))
            do 3301 , iaux = 1 , nfhexp
              vafott(nrofon,ficp(1,iaux)) = daux
 3301       continue
  330     continue
c
        else
c
          do 331 , nrofon = 1, nbfonc
            daux = vafoen(nrofon,prfcan(hecn))
            do 3311 , iaux = 1 , nfhexp
              vafott(nrofon,ficp(1,iaux)) = daux * propor(iaux)
 3311       continue
  331     continue
c
        endif
c
c 3.4. ==> aucun autre etat sur l'hexaedre courant n'est possible
c
      else
c
        codret = 1
        write (ulsort,texte(langue,4)) 'n  ', hehn
        write (ulsort,texte(langue,5)) 'n  ', etan
        write (ulsort,texte(langue,4)) 'n+1', hehnp1
        write (ulsort,texte(langue,5)) 'n+1', etanp1
c
      endif
c
c====
c 4. affectation des profils
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. affectation des profils ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      do 41 , iaux = 1 , nfhexp
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
