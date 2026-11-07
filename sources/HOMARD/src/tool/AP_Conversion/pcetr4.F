      subroutine pcetr4 ( nbfonc, nnmold, nnmnew,
     >                    prfcan, prfcap,
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
c                       TRiangles - cas 4 - degre 1 vers degre 2
c                       --              -
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
c . nnmold . e   .   1    . ancien nombre de noeuds par maille         .
c . nnmnew . e   .   1    . nouveau nombre de noeuds par maille        .
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . ntreca . e   .   *    . nro des triangles dans le calcul en entree .
c . ntrsca . e   . rstrto . numero des triangles du calcul             .
c . vafoen .   e . nbfonc*. variables en entree de l'adaptation        .
c .        .     .nnmold**.                                            .
c . vafott .   a . nbfonc*. tableau temporaire de la solution          .
c .        .     .nnmnew**.                                            .
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
      parameter ( nompro = 'PCETR4' )
c
#include "nblang.h"
#include "fracta.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombtr.h"
#include "nombsr.h"
#include "nomber.h"
#include "ope1a3.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer nnmold, nnmnew
      integer prfcan(*), prfcap(*)
      integer ntreca(retrto), ntrsca(rstrto)
c
      double precision vafoen(nbfonc,nnmold,*)
      double precision vafott(nbfonc,nnmnew,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
c     trcn   = triangle courant en numerotation Calcul a l'it. N
c     trcnp1 = triangle courant en numerotation Calcul a l'it. N+1
c     trhn   = triangle courant en numerotation Homard a l'it. N
c
      integer trcn, trcnp1, trhn
c
      integer nrofon, nunoel
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
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'nbfonc, nbtrto', nbfonc, nbtrto
      write(ulsort,90002) 'nnmold, nnmnew', nnmold, nnmnew
#endif
c
c====
c 2. on boucle sur tous les triangles du maillage HOMARD n+1
c====
c
      if ( nbfonc.ne.0 ) then
c
      do 20 , trhn = 1 , nbtrto
c
c 2.1. ==> ancien numero du triangle dans le calcul
c
        trcn = ntreca(trhn)
c
cgn        write (ulsort,90002) 'triangle', trhn, prfcan(trcn)
c
        if ( prfcan(trcn).gt.0 ) then
c
          trcnp1 = ntrsca(trhn)
          prfcap(trcnp1) = 1
c
          do 21 , nrofon = 1 , nbfonc
c
cgn        write (ulsort,90002) 'fonction numero', nrofon
cgn        write (ulsort,90004) ' ',
cgn     > (vafoen(nrofon,nunoel,prfcan(trcn)),nunoel=1,nnmold)
c
c           recopie des valeurs sur les sommets
c
            do 211 , nunoel = 1 , nnmold
              vafott(nrofon,nunoel,trcnp1) =
     >                                vafoen(nrofon,nunoel,prfcan(trcn))
  211       continue
c
c           calcul des valeurs sur les noeuds milieux
c
            do 212 , iaux = 1 , 3
              nunoel = 3 + iaux
              vafott(nrofon,nunoel,trcnp1) = unsde
     >        * ( vafoen(nrofon,          iaux,prfcan(trcn)) +
     >            vafoen(nrofon,per1a3(1,iaux),prfcan(trcn)) )
  212       continue
c
   21     continue
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
#ifdef _DEBUG_HOMARD_
      do 922 , iaux = 1 , nbtrto, -1
        write (ulsort,90002) 'triangle', iaux
        do 9222 , nrofon = 1 , nbfonc
          write (ulsort,90002) 'fonction numero', nrofon
          write(ulsort,90004) ' ',
     >     (vafott(nrofon,nunoel,iaux), nunoel = 1 , nnmnew)
 9222   continue
  922 continue
#endif
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
