      subroutine vcinr1 ( nbento, rvenac, nbvapr,
     >                    nbtafo, nbvind, ncmpin, nucomp,
     >                    indica, nenvho, listpr,
     >                    ensupp, enindi,
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
c    aVant adaptation - Conversion d'INdicateur - Reel - etape 1
c     -                 -            --           -            -
c but : conversion de l'indicateur d'erreur
c       valeurs reelles double precision de l'indicateur
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbento . e   .   1    . nombre total d'entites                     .
c . rvenac . e   .   1    . taille de la renumerotation des entites    .
c . nbvapr . e   .   1    . nombre de valeurs du profil                .
c .        .     .        . -1, si pas de profil                       .
c . nbtafo . e   .   1    . nombre de tableaux dans la fonction        .
c . nbvind . e   .   1    . nombre d'entites maximum                   .
c . ncmpin . e   .   1    . nombre de composantes retenues             .
c . nucomp . e   . ncmpin . numeros des composantes retenues           .
c . indica . e   . nbtafo . valeurs de l'indicateur                    .
c .        .     .*nbvind .                                            .
c . nenvho . e   . rvenac . numero des entites dans HOMARD             .
c . listpr . e   .   *    . liste des numeros d'elements ou l'indica-  .
c .        .     .        . teur est defini.                           .
c . ensupp .  s  . nbento . support pour les entites                   .
c . enindi .  s  . nbento . valeurs pour les entites                   .
c .        .     .*ncmpin .                                            .
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
      parameter ( nompro = 'VCINR1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      integer nbento, rvenac, nbvapr
      integer nbtafo, nbvind
      integer ncmpin, nucomp(ncmpin)
      integer ensupp(nbento)
      integer listpr(*)
      integer nenvho(rvenac)
c
      double precision enindi(nbento,ncmpin)
      double precision indica(nbtafo,nbvind)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nbval
      integer adtra1
      integer nbenti
c
      character*8 ntrav1
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
      texte(1,5) = '(''.. Pas de profil'')'
      texte(1,6) = '(''.. Profil de longueur :'',i10)'
      texte(1,7) = '(''.. Taille de la renumerotation :'',i10)'
c
      texte(2,5) = '(''.. No profile'')'
      texte(2,6) = '(''.. Profile length:'',i10)'
      texte(2,7) = '(''.. Renumbering size:'',i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      if ( nbvapr.le.0 ) then
        write (ulsort,texte(langue,5))
      else
        write (ulsort,texte(langue,6)) nbvapr
      endif
      write (ulsort,texte(langue,7)) rvenac
#endif
c
cgn        do 111 , iaux = 1 , nbtafo
cgn        do 111 , adtra1 = 1 , nbvind
cgn          write (ulsort,90124) 'indica',iaux,adtra1,indica(iaux,adtra1)
cgn 111    continue
cgn        do 112 , iaux = 1 , rvenac
cgn         write (ulsort,90112) 'nenvho',iaux,nenvho(iaux)
cgn 112    continue
c
c====
c 2. initialisation : a priori sans support
c    attention : on ne fait rien sur la valeur de l'indicateur ; ainsi,
c    il aura la valeur par defaut du gestionnaire de memoire
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. initialisation ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
        do 21 , iaux = 1 , nbento
          ensupp(iaux) = 0
   21   continue
        if ( nbvapr.gt.0 ) then
          nbenti = nbvapr
        else
          nbenti = rvenac
        endif
c
      endif
c
cgn      write (ulsort,90002) 'nbvapr,nbenti,rvenac',nbvapr,nbenti,rvenac
c
c====
c 3. conversion
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. conversion ; codret', codret
#endif
c
c 3.1. ==> tableau de travail
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav1, 'entier  ', rvenac, adtra1, codret )
c
      endif
c
c 3.2. ==> filtrage
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCTE3', nompro
#endif
      call utcte3 ( 2, rvenac, nenvho,
     >              nbval, imem(adtra1),
     >              ulsort, langue, codret )
c
      endif
c
c 3.3. ==> transfert
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCINR2', nompro
#endif
      call vcinr2 ( nbento, nbenti, rvenac, nbvapr,
     >              nbtafo, nbvind,
     >              ncmpin, nucomp,
     >              indica, nenvho, listpr,
     >              ensupp, enindi, imem(adtra1),
     >              ulsort, langue, codret)
c
      endif
c
c 3.4. ==> menage
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1 , codret )
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
