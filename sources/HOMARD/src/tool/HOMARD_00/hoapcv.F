      subroutine hoapcv ( codret )
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
c       HOMARD : interface APres adaptation : ConVersions
c       --                 --                 -  -
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
      parameter ( nompro = 'HOAPCV' )
c
#include "motcle.h"
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
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
      integer adoptr, lgoptr
      integer adopts, lgopts
      integer adetco, lgetco
      integer nrsect, nrssse
      integer nretap, nrsset
      integer iaux
c
      character*6 saux
      character*8 action
      character*8 typobs, nohmap
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
      character*50 commen(nblang)
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
      if ( codret.eq.0 ) then
c
      call gmadoj ( nndoad//'.OptEnt', adopti, lgopti, codret )
      if ( codret.eq.0 ) then
        langue = imem(adopti)
      else
        langue = 1
        codret = 2
      endif
c
      endif
c
c 1.4. ==> l'etat courant
c
      if ( codret.eq.0 ) then
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
     > '(//,a6,'//
     >''' C O N V E R S I O N S   A P R E S   A D A P T A T I O N'')'
      texte(1,5) = '(62(''=''),/)'
c
      texte(2,4) =
     > '(//,a6,'//
     >''' C O N V E R S I O N S   A F T E R   A D A P T A T I O N'')'
      texte(2,5) = '(62(''=''),/)'
c
c 1.6. ==> le titre
c
      if ( codret.eq.0 ) then
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
      nrsset = 0
      imem(adetco+1) = nrsset
c
      endif
c
c 1.7. ==> les options reelles
c
      call gmadoj ( nndoad//'.OptRee', adoptr, lgoptr, codret )
      if ( codret.ne.0 ) then
        codret = 2
      endif
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
#include "impr03.h"
c
c====
c 2. compactage des tableaux
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. compactage tableaux ; codret', codret
#endif
c
      if ( imem(adopti+21).eq.1 .or. imem(adopti+27).eq.1 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCOMP', nompro
#endif
c
      call utcomp (ulsort, langue, codret)
c
      endif
c
      endif
c
c====
c 3. conversion eventuelle du maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. conversion maillage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( imem(adopti+21).eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'imem(adopti+38)', imem(adopti+38)
      write (ulsort,90002) 'imem(adopti+10)', imem(adopti+10)
#endif
c
        nrssse = imem(adetco+3)
        call gtdems (nrssse)
c
c 3.1. ==> le cas extrude, non saturne, non neptune
c
        if ( imem(adopti+38).ne.0 .and.
     >       imem(adopti+10).ne.26 .and.
     >       imem(adopti+10).ne.46 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMEXT', nompro
#endif
          call pcmext ( lgopti, imem(adopti),
     >                  lgetco, imem(adetco),
     >                  ulsort, langue, codret )
c
         endif
c
        endif
c
c 3.2. ==> conversion vers le format externe
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMAIL', nompro
#endif
c
        call pcmail ( lgopti, imem(adopti), lgopts, smem(adopts),
     >                lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
        endif
c
c 3.2. ==> modification pour le cas non conforme
c          ou saturne/neptune 2D
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'imem(adopti+29)', imem(adopti+29)
      write (ulsort,90002) 'imem(adopti+10)', imem(adopti+10)
#endif
c
        if ( imem(adopti+29).eq.-2 .or.
     >       imem(adopti+29).eq.1 .or.
     >       imem(adopti+29).eq.2 .or.
     >       imem(adopti+29).eq.3 .or.
     >       imem(adopti+10).eq.26 .or.
     >       imem(adopti+10).eq.46 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMANC', nompro
#endif
          call pcmanc ( lgopti, imem(adopti), lgoptr, rmem(adoptr),
     >                  lgopts, smem(adopts),
     >                  lgetco, imem(adetco),
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
        call gtfims (nrssse)
c
      endif
c
      endif
c
c====
c 4. conversion eventuelle d'une solution
c====
c
c 4.1. ==> lecture
c          si aucune solution n'est presente, hoapls modifiera
c          l'indicateur de conversion, imem(adopti+27).
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.1. lecture solution ; codret', codret
      write (ulsort,90002) 'imem(adopti+27)', imem(adopti+27)
      write (ulsort,90002) 'imem(adopti+38)', imem(adopti+38)
#endif
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( imem(adopti+27).eq.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOAPLS', nompro
#endif
c
        call hoapls ( lgopti, imem(adopti), lgopts, smem(adopts),
     >                lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c 4.2. ==> conversion
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. conversion solution ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( imem(adopti+27).eq.1 ) then
c
        nrssse = imem(adetco+3)
        call gtdems (nrssse)
c
c 4.2.1 ==> pour le cas extrude, passage du 3D au 2D
c
        if ( codret.eq.0 ) then
c
        if ( imem(adopti+38).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSEXT', nompro
#endif
          iaux = 1
          call utsext ( smem(adopts+8), iaux, imem(adopti+10),
     >                  lgetco, imem(adetco),
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
c 4.2.2. ==> conversion vraie
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCSOLU', nompro
#endif
c
        call pcsolu ( lgopti, imem(adopti), lgopts, smem(adopts),
     >                lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
        endif
c
c 4.2.3 ==> pour le cas extrude, passage du 2D au 3D
c
        if ( codret.eq.0 ) then
c
        if ( imem(adopti+38).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSEXT', nompro
#endif
          iaux = 2
          call utsext ( smem(adopts+9), iaux, imem(adopti+10),
     >                  lgetco, imem(adetco),
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
        call gtfims (nrssse)
c
      endif
c
      endif
c
c
c====
c 5. analyse du maillage converti
c    Il faut le faire seulement ici car certaines conversions
c    modifient les familles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. analyse ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
      nrssse = imem(adetco+3)
c
      call gtdems (nrssse)
c
      if ( codret.eq.0 ) then
        typobs = mchmap
        iaux = 0
        call utosno ( typobs, nohmap, iaux, ulsort, langue, codret )
      endif
c
      if ( imem(adopti+3).eq.3 ) then
        commen(1) = 'Maillage apres modification                       '
        commen(2) = 'Mesh after modification                           '
      elseif ( imem(adopti+21).eq.1 ) then
        commen(1) = 'Maillage apres adaptation                         '
        commen(2) = 'Mesh after adaptation                             '
      else
        commen(1) = 'Maillage                                          '
        commen(2) = 'Maillage                                          '
      endif
c
      if ( codret.eq.0 ) then
c
      action = smem(adopts+29)
      if ( action.eq.'homa    ' ) then
        action = 'apad'
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTBILM', nompro
#endif
      call utbilm ( nohmap, commen(langue), imem(adopti+2), action,
     >              lgetco, imem(adetco),
     >              ulsort, langue, codret )
      endif
c
      call gtfims (nrssse)
c
      endif
c
c====
c 7. la fin
c====
c
c 7.1. ==> message si erreur
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
c 7.2. ==> fin des mesures de temps de la section
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
