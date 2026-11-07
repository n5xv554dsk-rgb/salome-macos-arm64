      subroutine eslnma ( idfmed, nomamd, mdim,
     >                    nbelem, nbmapo, nbsegm, nbtria, nbtetr,
     >                    nbquad, nbhexa, nbpyra, nbpent,
     >                    nbseg2, nbseg3,
     >                    nbtri3, nbtri6, nbtri7,
     >                    nbtet4, nbte10,
     >                    nbqua4, nbqua8, nbqua9,
     >                    nbhex8, nbhe20, nbhe27,
     >                    nbpen6, nbpe15,
     >                    nbpyr5, nbpy13,
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
c  Entree-Sortie - Lecture du Nombre de MAilles
c  -      -        -          -         --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier de               .
c .        .     .        . maillage d'entree                          .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . mdim   . e   .   1    . dimension du maillage                      .
c . nbelem .  s  .   1    . nombre d'elements dans le maillage         .
c . nbmapo .  s  .   1    . nombre de mailles-points                   .
c . nbsegm .  s  .   1    . nombre de segments                         .
c . nbtria .  s  .   1    . nombre de triangles                        .
c . nbtetr .  s  .   1    . nombre de tetraedres                       .
c . nbseg2 .  s  .   1    . nombre de segments a 2 noeuds              .
c . nbseg3 .  s  .   1    . nombre de segments a 3 noeuds              .
c . nbtrik .  s  .   1    . nombre de triangles a k noeuds             .
c . nbtet4 .  s  .   1    . nombre de tetraedres a 4 noeuds            .
c . nbte10 .  s  .   1    . nombre de tetraedres a 10 noeuds           .
c . nbquak .  s  .   1    . nombre de quadrangles a k noeuds           .
c . nbhexk .  s  .   1    . nombre d'hexaedres a k noeuds              .
c . nbpen6 .  s  .   1    . nombre de pentaedres a 6 noeuds            .
c . nbpe15 .  s  .   1    . nombre de pentaedres a 15 noeuds           .
c . nbpyr5 .  s  .   1    . nombre de pyramides a 5 noeuds             .
c . nbpy13 .  s  .   1    . nombre de pyramides a 13 noeuds            .
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
      parameter ( nompro = 'ESLNMA' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer mdim
      integer nbelem, nbmapo, nbsegm, nbtria, nbtetr
      integer nbquad, nbhexa, nbpyra, nbpent
      integer nbseg2, nbseg3
      integer nbtri3, nbtri6, nbtri7
      integer nbtet4, nbte10
      integer nbqua4, nbqua8, nbqua9
      integer nbhex8, nbhe20, nbhe27
      integer nbpen6, nbpe15
      integer nbpyr5, nbpy13
c
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer codre0
      integer codre1, codre2, codre3
c
      integer numdt, numit
      integer datype, chgt, tsf
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      nbmapo = 0
      nbsegm = 0
      nbtria = 0
      nbtetr = 0
c
      nbseg2 = 0
      nbseg3 = 0
      nbtri3 = 0
      nbtri6 = 0
      nbtri7 = 0
      nbtet4 = 0
      nbte10 = 0
c
      nbqua4 = 0
      nbqua8 = 0
      nbqua9 = 0
      nbpen6 = 0
      nbpe15 = 0
      nbhex8 = 0
      nbhe20 = 0
      nbhe27 = 0
      nbpyr5 = 0
      nbpy13 = 0
c
      numdt = ednodt
      numit = ednoit
      datype = edda01
c
c====
c 2. recherche des differents nombres d'elements
c====
c
c 2.1. ==> les mailles points
c
      if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMHNME', nompro
#endif
      call mmhnme ( idfmed, nomamd, numdt, numit,
     >              edmail, edpoi1, datype, ednoda, chgt, tsf,
     >              nbmapo, codret )
      endif
c
c 2.2. ==> les segments
c
      if ( codret.eq.0 ) then
      if ( mdim.ge.1 ) then
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edseg2, datype, ednoda, chgt, tsf,
     >                nbseg2, codre1 )
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edseg3, datype, ednoda, chgt, tsf,
     >                nbseg3, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
      endif
      endif
c
c 2.3. ==> les triangles
c
      if ( codret.eq.0 ) then
      if ( mdim.ge.2 ) then
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edtri3, datype, ednoda, chgt, tsf,
     >                nbtri3, codre1 )
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edtri6, datype, ednoda, chgt, tsf,
     >                nbtri6, codre2 )
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edtri7, datype, ednoda, chgt, tsf,
     >                nbtri7, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
      endif
      endif
c
c 2.4. ==> les tetraedres
c
      if ( codret.eq.0 ) then
      if ( mdim.eq.3 ) then
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edtet4, datype, ednoda, chgt, tsf,
     >                nbtet4, codre1 )
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edte10, datype, ednoda, chgt, tsf,
     >                nbte10, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
      endif
      endif
c
c 2.5. ==> les quadrangles
c
      if ( codret.eq.0 ) then
      if ( mdim.ge.2 ) then
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edqua4, datype, ednoda, chgt, tsf,
     >                nbqua4, codre1 )
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edqua8, datype, ednoda, chgt, tsf,
     >                nbqua8, codre2 )
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edqua9, datype, ednoda, chgt, tsf,
     >                nbqua9, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                  codre1, codre2, codre3 )
      endif
      endif
c
c 2.6. ==> les hexaedres
c
      if ( codret.eq.0 ) then
      if ( mdim.eq.3 ) then
c
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edhex8, datype, ednoda, chgt, tsf,
     >                nbhex8, codre1 )
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edhe20, datype, ednoda, chgt, tsf,
     >                nbhe20, codre2 )
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edhe27, datype, ednoda, chgt, tsf,
     >                nbhe27, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                  codre1, codre2, codre3 )
c
      endif
      endif
c
c 2.7. ==> les pentaedres
c
      if ( codret.eq.0 ) then
      if ( mdim.eq.3 ) then
c
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edpen6, datype, ednoda, chgt, tsf,
     >                nbpen6, codre1 )
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edpe15, datype, ednoda, chgt, tsf,
     >                nbpe15, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                  codre1, codre2 )
c
      endif
      endif
c
c 2.8. ==> les pyramides
c
      if ( codret.eq.0 ) then
      if ( mdim.eq.3 ) then
c

        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edpyr5, datype, ednoda, chgt, tsf,
     >                nbpyr5, codre1 )
        call mmhnme ( idfmed, nomamd, numdt, numit,
     >                edmail, edpy13, datype, ednoda, chgt, tsf,
     >                nbpy13, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
      endif
      endif
c
c====
c 3. nombres deduits
c====
c
      if ( codret.eq.0 ) then
c
      iaux = nbseg2
     >     + nbtri3 + nbqua4
     >     + nbtet4 + nbhex8 + nbpyr5 + nbpen6
      jaux = nbseg3
     >     + nbtri6 + nbqua8 + nbtri7 + nbqua9
     >     + nbte10 + nbhe20 + nbpy13 + nbpe15 + nbhe27
c
      if ( iaux.gt.0 ) then
c
        nbelem = iaux + nbmapo
        nbsegm = nbseg2
        nbtria = nbtri3
        nbtetr = nbtet4
        nbquad = nbqua4
        nbhexa = nbhex8
        nbpyra = nbpyr5
        nbpent = nbpen6
c
      else if ( jaux.gt.0 ) then
c
        nbelem = jaux + nbmapo
        nbsegm = nbseg3
        nbtria = max(nbtri6, nbtri7)
        nbtetr = nbte10
        nbquad = max(nbqua8, nbqua9)
        nbhexa = max(nbhe20, nbhe27)
        nbpyra = nbpy13
        nbpent = nbpe15
c
      else
c
        nbelem = nbmapo
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
