      subroutine hosufr ( codret )
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
c   HOMARD : SUivi de FRontiere
c   --       --       --
c
c remarque : on n'execute ce programme que si le precedent s'est
c            bien passe
c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
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
      parameter ( nompro = 'HOSUFR' )
c
#include "motcle.h"
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
c
#include "cndoad.h"
c
c 0.3. ==> arguments
c
      integer codret
c
c 0.4. ==> variables locales
c
      integer ulsort, langue, codava
      integer adopti, lgopti
      integer adopts, lgopts
      integer adetco, lgetco
      integer nrsect, nrssse
      integer nretap, nrsset
      integer iaux
      integer nbarfr, nbqufr
c
      character*6 saux
      character*8 typobs, nohmap
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c 1.4. ==> l'etat courant
c
      call gmadoj ( nndoad//'.EtatCour', adetco, lgetco, codret )
c
      if ( codret.eq.0 ) then
        if ( mod(imem(adopti+28),2).eq.0 .or.
     >       mod(imem(adopti+28),3).eq.0 .or.
     >       mod(imem(adopti+28),5).eq.0 ) then
          nretap = imem(adetco) + 1
          imem(adetco) = nretap
          nrsset = -1
          imem(adetco+1) = nrsset
        endif
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
c-----------------------------------------------------------------------
      if ( mod(imem(adopti+28),2).eq.0 .or.
     >     mod(imem(adopti+28),3).eq.0 .or.
     >     mod(imem(adopti+28),5).eq.0 ) then
c-----------------------------------------------------------------------
c
c 1.5. ==> le debut des mesures de temps
c
      call gtdems (nrsect)
c
c 1.6. ==> les messages
c
      texte(1,4) = '(//,a6,'' S U I V I   D E   F R O N T I E R E'')'
      texte(1,5) = '(42(''=''),/)'
c
      texte(2,4) = '(//,a6,'' B O U N D A R Y   F O L L O W I N G'')'
      texte(2,5) = '(42(''=''),/)'
c
c 1.7. ==> le titre
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
      nrsset = 0
      imem(adetco+1) = nrsset
c
c 1.8. ==> les noms d'objets a conserver
c
      if ( codret.eq.0 ) then
        call gmadoj ( nndoad//'.OptCar', adopts, lgopts, codret )
        if ( codret.ne.0 ) then
          codret = 2
        endif
      endif
c
c 1.9. ==> le maillage homard
c
      if ( codret.eq.0 ) then
c
      typobs = mchmap
      iaux = 0
      call utosno ( typobs, nohmap, iaux, ulsort, langue, codret )
c
      endif
c
#include "impr03.h"
c
c====
c 2. A-t-on des aretes et des quadrangles concernees
c    par le suivi de frontiere ?
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Tests des aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nbarfr = 0
      nbqufr = 0
      iaux = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCOAQ', nompro
#endif
      call sfcoaq ( nohmap, iaux, nbarfr, nbqufr,
     >              ulsort, langue, codret )
c
      endif
c
c
c====
c 3. Traitement
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Traitement ; codret', codret
      write (ulsort,90002) 'nbarfr', nbarfr
      write (ulsort,90002) 'nbqufr', nbqufr
#endif
c
      if ( nbarfr.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        imem(adetco+3) = imem(adetco+3) + 1
        nrssse = imem(adetco+3)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCAFR', nompro
#endif
        call sfcafr ( lgopti, imem(adopti),
     >                lgopts, smem(adopts),
     >                lgetco, imem(adetco),
     >                nohmap, nbarfr, nbqufr,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 4. la fin
c====
c
c 4.1. ==> message si erreur
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
c 4.3. ==> fin des mesures de temps de la section
c
      call gtfims (nrsect)
c
c-----------------------------------------------------------------------
      endif
c-----------------------------------------------------------------------
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
