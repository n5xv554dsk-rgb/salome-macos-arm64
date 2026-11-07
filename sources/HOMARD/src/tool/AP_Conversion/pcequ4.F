      subroutine pcequ4 ( nbfonc, nnmold, nnmnew,
     >                    prfcan, prfcap,
     >                    nqueca, nqusca,
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
c                       QUadrangles - cas 4 - degre 1 vers degre 2
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
c . nnmold . e   .   1    . ancien nombre de noeuds par maille         .
c . nnmnew . e   .   1    . nouveau nombre de noeuds par maille        .
c . prfcan . e   .   *    . En numero du calcul a l'iteration n :      .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . i : l'entite est au rang i dans le profil  .
c . prfcap . es  .   *    . En numero du calcul a l'iteration n+1 :    .
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . nqueca . e   .   *    . nro des quadrangles dans le calcul en ent. .
c . nqusca . e   . rsquto . numero des quadrangles du calcul           .
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
      parameter ( nompro = 'PCEQU4' )
c
#include "nblang.h"
#include "fracta.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombqu.h"
#include "nombsr.h"
#include "nomber.h"
#include "ope1a4.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer nnmold, nnmnew
      integer prfcan(*), prfcap(*)
      integer nqueca(requto), nqusca(rsquto)
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
c     qucn   = QUadrangle courant en numerotation Calcul a l'it. N
c     qucnp1 = QUadrangle courant en numerotation Calcul a l'it. N+1
c     quhn   = QUadrangle courant en numerotation Homard a l'it. N
c
      integer qucn, qucnp1, quhn
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
      write(ulsort,90002) 'nbfonc, nbquto', nbfonc, nbquto
      write(ulsort,90002) 'nnmold, nnmnew', nnmold, nnmnew
#endif
c
      codret = 0
c
c====
c 2. on boucle sur tous les quadrangles du maillage HOMARD n+1
c====
c
      if ( nbfonc.ne.0 ) then
c
      do 20 , quhn = 1 , nbquto
c
c 2.1. ==> ancien numero du quadrangle dans le calcul
c
        qucn = nqueca(quhn)
c
cgn        write (ulsort,90002) 'Quadrangle', quhn, prfcan(qucn)
c
        if ( prfcan(qucn).gt.0 ) then
c
          qucnp1 = nqusca(quhn)
          prfcap(qucnp1) = 1
c
          do 21 , nrofon = 1 , nbfonc
c
cgn        write (ulsort,90002) 'fonction numero', nrofon
cgn        write (ulsort,90004) ' ',
cgn     > (vafoen(nrofon,nunoel,prfcan(qucn)),nunoel=1,nnmold)
c
c           recopie des valeurs sur les sommets
c
            do 211 , nunoel = 1 , nnmold
              vafott(nrofon,nunoel,qucnp1) =
     >                                vafoen(nrofon,nunoel,prfcan(qucn))
  211       continue
c
c           calcul des valeurs sur les noeuds milieux
c
            do 212 , iaux = 1 , 4
              nunoel = 4 + iaux
              vafott(nrofon,nunoel,qucnp1) = unsde
     >        * ( vafoen(nrofon,          iaux,prfcan(qucn)) +
     >            vafoen(nrofon,per1a4(1,iaux),prfcan(qucn)) )
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
      do 922 , iaux = 1 , nbquto, -1
        write (ulsort,90002) 'Quadrangle', iaux
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
