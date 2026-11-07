      subroutine holect ( modhom, codret )
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
c   HOMARD : LECTures
c   --       ----
c remarque : on n'execute ce programme que si le precedent s'est
c            bien passe
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . modhom .  s  .    1   . mode de fonctionnement de homard           .
c .        .     .        . 1 : homard pur                             .
c .        .     .        . 2 : information                            .
c .        .     .        . 3 : modification de maillage sans adaptatio.
c .        .     .        . 4 : interpolation de la solution           .
c .        .     .        . 5 : mise a jour des coordonnees            .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . en entree = celui du module d'avant        .
c .        .     .        . en sortie = celui du module en cours       .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : manque de temps cpu                    .
c .        .     .        . 2x : probleme dans les memoires            .
c .        .     .        . 3x : probleme dans les fichiers            .
c .        .     .        . 5 : mauvaises options                      .
c .        .     .        . 6 : problemes dans les noms d'objet        .
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
      parameter ( nompro = 'HOLECT' )
c
#include "motcle.h"
#include "nblang.h"
c
#include "mesutp.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "cndoad.h"
c
c 0.3. ==> arguments
c
      integer modhom
      integer codret
c
c 0.4. ==> variables locales
c
      integer ulsort, langue, codava
      integer adopti, lgopti
      integer adopts, lgopts
      integer adoptr, lgoptr
      integer adetco, lgetco
      integer nrsect, nrssse
      integer nretap, nrsset
      integer iaux
c
      character*6 saux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. les initialisations
c====
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nndoad )
      call gmprsx (nompro, nndoad//'.OptEnt' )
      call gmprsx (nompro, nndoad//'.OptRee' )
      call gmprsx (nompro, nndoad//'.OptCar' )
      call gmprsx (nompro, nndoad//'.EtatCour' )
#endif
c
c 1.2. ==> le numero d'unite logique de la liste standard
c
      call utulls ( ulsort, codret )
c
c 1.3. ==> la langue des messages
c
      call gmadoj ( nndoad//'.OptEnt', adopti, lgopti, codret )
      if ( codret.eq.0 ) then
        langue = imem(adopti)
      else
        langue = 1
        codret = 2
      endif
c
c 1.4. ==> l'etat courant
c
      call gmadoj ( nndoad//'.EtatCour', adetco, lgetco, codret )
      if ( codret.eq.0 ) then
        nretap = imem(adetco) + 1
        imem(adetco) = nretap
        nrsset = -1
        imem(adetco+1) = nrsset
        nrsect = imem(adetco+2) + 10
        imem(adetco+2) = nrsect
        nrssse = nrsect
        imem(adetco+3) = nrssse
      else
        nretap = -1
        nrsset = -1
        nrsect = 200
        nrssse = nrsect
        codret = 2
      endif
c
c 1.4. ==> le debut des mesures de temps
c
      call gtdems (nrsect)
c
c 1.5. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(//,a6,'' L E C T U R E   D E S   D O N N E E S'')'
      texte(1,5) = '(44(''=''),/)'
c
      texte(2,4) = '(//,a6,'' D A T A   R E A D I N G S'')'
      texte(2,5) = '(32(''=''),/)'
c
c 1.6. ==> le titre
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
      nrsset = 0
      imem(adetco+1) = nrsset
c
c 1.7. ==> les noms d'objets a conserver
c
      if ( codret.eq.0 ) then
        call gmadoj ( nndoad//'.OptCar', adopts, lgopts, codret )
        if ( codret.ne.0 ) then
          codret = 2
        endif
      endif
c
c 1.8. ==> les options reelles
c
      if ( codret.eq.0 ) then
        call gmadoj ( nndoad//'.OptRee', adoptr, lgoptr, codret )
        if ( codret.ne.0 ) then
          codret = 2
        endif
      endif
c
#include "impr03.h"
c
c====
c 2. lectures des options et verification
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. options, verification ; codret', codret
#endif
c
      imem(adetco+3) = imem(adetco+3) + 1
      nrssse = imem(adetco+3)
c
      call gtdems (nrssse)
c
c 2.1. ==> lecture des options
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOLOPT', nompro
#endif
      call holopt ( lgopti, imem(adopti), lgoptr, rmem(adoptr),
     >              lgopts, smem(adopts),
     >              lgetco, imem(adetco),
     >              ulsort, langue, codret )
c
      endif
c
c 2.2. ==> verification
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOLVER', nompro
#endif
      call holver ( lgopti, imem(adopti), lgoptr, rmem(adoptr),
     >              lgetco, imem(adetco),
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
      modhom = imem(adopti+3)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'modhom', modhom
#endif
      endif
c
      if ( modhom.eq.2 ) then
#include "hotit2.h"
      endif
      if ( modhom.eq.3 ) then
#include "hotit3.h"
      endif
c
      call gtfims (nrssse)
c
c====
c 3. lecture du maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. lecture maillage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOAVLM', nompro
#endif
c
      call hoavlm ( lgopti, imem(adopti), lgopts, smem(adopts),
     >              lgetco, imem(adetco),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. lecture de la frontiere discrete
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. lecture frontiere ; codret', codret
#endif
c
      if ( modhom.ne.5 ) then
c
      if ( imem(adopti+9).eq.0 ) then
        imem(adopti+28) = -abs(imem(adopti+28))
      endif
c
      if ( mod(imem(adopti+28),2).eq.0 .and. imem(adopti+28).lt.0 ) then
c
        if ( codret.eq.0 ) then
c
        imem(adetco+3) = imem(adetco+3) + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFLGEO', nompro
#endif
c
        call sflgeo ( lgopti, imem(adopti), lgopts, smem(adopts),
     >                lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      endif
c
c====
c 5. la fin
c====
c
c 5.1. ==> message si erreur
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
c 5.2. ==> fin des mesures de temps de la section
c
      call gtfims (nrsect)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
c=======================================================================
      endif
c=======================================================================
c
      end
c .        .     .        . 4 : interpolation de la solution           .
