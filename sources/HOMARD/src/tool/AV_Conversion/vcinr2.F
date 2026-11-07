      subroutine vcinr2 ( nbento, nbenti, rvenac, nbvapr,
     >                    nbtafo, nbvind,
     >                    ncmpin, nucomp,
     >                    indica, nuenho, listpr,
     >                    ensupp, enindi, tabaux,
     >                    ulsort, langue, codret)
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
c    aVant adaptation - Conversion d'INdicateur - Reel - etape 2
c     -                 -            --           -            -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbento . e   .   1    . nombre total d'entites                     .
c . nbenti . e   .   1    . nombre total d'entites selon le profil     .
c . rvenac . e   .   1    . taille de la renumerotation des entites    .
c . nbvapr . e   .   1    . nombre de valeurs du profil                .
c .        .     .        . -1, si pas de profil
c . nbvind . e   .   1    . nombre d'entites maximum                   .
c . nbtafo . e   .   1    . nombre de tableaux dans la fonction        .
c . ncmpin . e   .   1    . nombre de composantes retenues             .
c . nucomp . e   . ncmpin . numeros des composantes retenues           .
c . indica . e   . nbtafo . valeurs de l'indicateur                    .
c .        .     .*nbvind .                                            .
c . nuenho . e   . rvenac . numero des entites dans HOMARD             .
c . listpr . e   .   *    . liste des numeros d'elements ou l'indica-  .
c .        .     .        . teur est defini.                           .
c . ensupp .  s  . nbento . support pour les entites                   .
c . enindi .  s  . nbento . valeurs pour les entites                   .
c .        .     .*ncmpin .                                            .
c . tabaux . e   . rvenac . auxiliaire de filtrage                     .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme dans les fichiers             .
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
      parameter ( nompro = 'VCINR2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbento, nbenti, rvenac, nbvapr
      integer nbtafo, nbvind
      integer ncmpin, nucomp(ncmpin)
      integer ensupp(nbento)
      integer listpr(*)
      integer nuenho(rvenac)
      integer tabaux(rvenac)
c
      double precision enindi(nbento,ncmpin)
      double precision indica(nbtafo,nbvind)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nbval
      integer nrcomp
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
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''.. Pas de profil'')'
      texte(1,5) = '(''.. Profil de longueur :'',i10)'
      texte(1,6) = '(''.. Numero de la composante :'',i10)'
c
      texte(2,4) = '(''.. No profile'')'
      texte(2,5) = '(''.. Profile length :'',i10)'
      texte(2,6) = '(''.. Component # :'',i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      if ( nbvapr.le.0 ) then
        write (ulsort,texte(langue,4))
      else
        write (ulsort,texte(langue,5)) nbvapr
      endif
      if ( ncmpin.eq.1 ) then
        write (ulsort,texte(langue,6)) nucomp(1)
      endif
      write (ulsort,90002) 'nbenti', nbenti
#endif
c
c====
c 2. Transfert de 1 ou plusieurs composantes
c====
c
      nbval = 0
c
c 2.1. ==> sans profil
c
      if ( nbvapr.eq.-1 ) then
c
        do 21 , iaux = 1 , nbenti
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90112) 'tabaux', iaux, tabaux(iaux)
#endif
          jaux = tabaux(iaux)
          if ( jaux.ne.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,90112) 'tabaux', iaux, tabaux(iaux),nuenho(jaux)
#endif
            nbval = nbval + 1
            ensupp(nuenho(jaux)) = 1
            do 211 , nrcomp = 1, ncmpin
              enindi(nuenho(jaux),nrcomp) = indica(nucomp(nrcomp),nbval)
cgn      write (ulsort,90004) 'valeur', enindi(nuenho(jaux),nrcomp)
  211       continue
          endif
c
   21   continue
c
c 2.2. ==> avec profil
c
      else
c
        do 22 , iaux = 1 , nbenti
c
          jaux = tabaux(listpr(iaux))
          if ( jaux.ne.0 ) then
            nbval = nbval + 1
            ensupp(nuenho(jaux)) = 1
            daux = 0.d0
            do 221 , nrcomp = 1, ncmpin
              enindi(nuenho(jaux),nrcomp) = indica(nucomp(nrcomp),nbval)
  221       continue
          endif
c
   22   continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbval', nbval
#endif
c
c====
c 3. la fin
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
