      subroutine pcstrg ( nbfonc, ngauss, nbnorf, typgeo, deraff,
     >                    prfcan, prfcap,
     >                    hettri, anctri,
     >                    filtri,
     >                    nbantr, anfitr,
     >                    ntreca, ntrsca,
     >                    vafoen, vafott,
     >                    conorf, copgrf, wipg,
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c                       TRiangles a plusieurs points de Gauss
c                       --                              -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfonc . e   .    1   . nombre de fonctions aux points de Gauss    .
c . ngauss . e   .   1    . nbre de points de Gauss des fonctions pg   .
c . nbnorf . e   .   1    . nbre de noeuds de l'element de reference   .
c . typgeo . e   .   1    . type geometrique au sens MED               .
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
c . anfitr . e   . nbantr . tableau filtri du maillage de l'iteration n.
c . ntreca . e   .   *    . nro des triangles dans le calcul en entree .
c . ntrsca . e   . rstrto . numero des triangles du calcul             .
c . vafoen .   e . nbfonc*. variables en entree de l'adaptation        .
c .        .     . ngauss .                                            .
c . vafott .   a . nbfonc*. tableau temporaire de la solution          .
c .        .     . ngauss .                                            .
c . conorf . e   .  sdim* . coordonnees des noeuds de l'element de     .
c .        .     . nbnorf . reference                                  .
c . copgrf . e   .  sdim* . coordonnees des points de Gauss            .
c .        .     . ngauss . de l'element de reference                  .
c . wipg   .  a  . nbnorf*. fonctions de forme exprimees aux points de .
c .        .     . ngauss . Gauss                                      .
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
      parameter ( nompro = 'PCSTRG' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombtr.h"
#include "nombsr.h"
#include "nomber.h"
c
c 0.3. ==> arguments
c
      integer nbfonc
      integer ngauss, nbnorf, typgeo
      integer prfcan(*), prfcap(*)
      integer hettri(nbtrto), anctri(*)
      integer filtri(nbtrto)
      integer nbantr, anfitr(nbantr)
      integer ntreca(retrto), ntrsca(rstrto)
c
      double precision vafoen(nbfonc,ngauss,*)
      double precision vafott(nbfonc,ngauss,*)
      double precision conorf(sdim,nbnorf), copgrf(sdim,ngauss)
      double precision wipg(nbnorf,ngauss)
c
      logical deraff
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
c     trhn   = TRiangle courant en numerotation Homard a l'iteration N
c     trhnp1 = TRiangle courant en numerotation Homard a l'iteration N+1
c
      integer trhn, trhnp1
c
c     etan   = ETAt du triangle a l'iteration N
c     etanp1 = ETAt du triangle a l'iteration N+1
c
      integer etan, etanp1
c
      integer iaux
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
      write(ulsort,*) 'nbfonc, ngauss, nbtrto = ',nbfonc, ngauss, nbtrto
#endif
c
      texte(1,4) =
     >'(/,''Triangle en cours : nro a l''''iteration '',a3,'' : '',i10)'
      texte(1,5) =
     > '(  ''                etat a l''''iteration '',a3,''   : '',i4)'
c
      texte(2,4) =
     >'(/,''Current triangle : # at iteration '',a3,''     : '',i10)'
      texte(2,5) =
     > '(  ''              status at iteration '',a3,'' : '',i4)'
c
#include "impr03.h"
c
cgn      write (ulsort,90002) 'nbfonc, ngauss, nbnorf',
cgn     >                      nbfonc,ngauss,nbnorf
c
c====
c 2. on boucle sur tous les triangles actifs du maillage HOMARD n+1
c    . soit il etait deja actif dans le maillage precedent : c'est un
c      transfert direct des valeurs
c    . soit il ne l'etait pas : il est donc issu d'un decoupage et on va
c      calculer les valeurs aux points de Gauss en fonction des valeurs
c      sur les noeuds.
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Boucle ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbfonc.ne.0 ) then
c
      do 30 , trhnp1 = 1 , nbtrto
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
c 2.1.3. ==> l'historique de son etat
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
        etan = (hettri(trhnp1)-etanp1) / 10
cgn        write (ulsort,1792) 'Triangle', trhn, etan, trhnp1, etanp1
c
c=======================================================================
c etan = 0 : le triangle etait actif
c=======================================================================
c
        if ( etan.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSPTZ', nompro
#endif
c
          call pcsptz ( etan, etanp1, trhn, trhnp1,
     >                  prfcan, prfcap,
     >                  filtri,
     >                  ntreca, ntrsca,
     >                  nbfonc, ngauss, vafoen, vafott,
     >                  ulsort, langue, codret )
c
c=======================================================================
c etan = 1, 2, 3 : le triangle etait coupe en 2
c=======================================================================
c
        elseif ( etan.ge.1 .and. etan.le.3 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSPTD', nompro
#endif
c
          call pcsptd ( etan, etanp1, trhn, trhnp1,
     >                  prfcan, prfcap,
     >                  hettri, filtri, nbantr, anfitr,
     >                  ntreca, ntrsca,
     >                  nbfonc, ngauss, vafoen, vafott,
     >                  ulsort, langue, codret )
c
c=======================================================================
c etan = 4, 6, 7, 8 : le triangle etait coupe en 4
c=======================================================================
c
        elseif ( etan.eq.4 .or.
     >           ( etan.ge.6 .and. etan.le.8 ) ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'PCSPTQ', nompro
#endif
c
          call pcsptq ( etanp1, trhn, trhnp1,
     >                  prfcan, prfcap,
     >                  filtri, nbantr, anfitr,
     >                  ntreca, ntrsca,
     >                  nbfonc, ngauss, vafoen, vafott,
     >                  ulsort, langue, codret )
c
        endif
c
   30 continue
c
      endif
c
      endif
c
c====
c 4. la fin
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
