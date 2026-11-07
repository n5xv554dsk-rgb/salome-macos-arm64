      subroutine inconv ( codret )
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
c   INformation : CONVersions
c   --            ----
c remarque : on n'execute ce programme que si le precedent s'est
c            bien passe
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
      parameter ( nompro = 'INCONV' )
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
#include "envca2.h"
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
c
      character*6 saux
      character*8 nocman
c
      integer nbmess
      parameter ( nbmess = 20 )
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
c 1.1. ==> le numero d'unite logique de la liste standard
c
      call utulls ( ulsort, codret )
c
c 1.2. ==> la langue des messages
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
        if ( imem(adopti+20) .eq. 1 ) then
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
      if ( imem(adopti+20) .eq. 1 ) then
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
     > '(//,a6,'' C O N V E R S I O N   D U   M A I L L A G E'')'
      texte(1,5) = '(50(''=''),/)'
c
      texte(2,4) = '(//,a6,'' M E S H   C O N V E R S I O N'')'
      texte(2,5) = '(36(''=''),/)'
c
#include "impr03.h"
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
c 1.8. ==> la date courante
c
      call utdhlg ( ladate, langue )
c
c====
c 2. conversion du maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. conversion ; codret', codret
#endif
cgn      write (ulsort,90002) 'imem(adopti+38)', imem(adopti+38)
cgn      write (ulsort,90002) 'imem(adopti+10)', imem(adopti+10)
c
      imem(adetco+3) = imem(adetco+3) + 1
      nrssse = imem(adetco+3)
c
      call gtdems (nrssse)
c
c 2.1. ==> prealable pour le suivi de frontiere
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. prealable frontiere ; codret', codret
#endif
c
      if ( mod(imem(adopti+28),2).eq.0 .or.
     >     mod(imem(adopti+28),5).eq.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFDEFG', nompro
#endif
c
        call sfdefg ( imem(adopti+28),
     >                smem(adopts), smem(adopts+15), smem(adopts+16),
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 2.2. ==> prealable pour le cas saturne/neptune 2D
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. prealable sat/nep ; codret', codret
#endif
c
      if ( imem(adopti+10).eq.26 .or.
     >     imem(adopti+10).eq.46 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMS2D', nompro
#endif
c
        call vcms2d ( lgopti, imem(adopti), lgopts, smem(adopts),
     >                lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 2.3. ==> conversion
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. conversion ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMAIL', nompro
#endif
      call vcmail ( lgopti, imem(adopti), lgopts, smem(adopts),
     >              lgetco, imem(adetco),
     >              ulsort, langue, codret )
c
      endif
c
c 2.4. ==> le cas extrude, non saturne, non neptune
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.4. cas extrude ; codret', codret
#endif
c
      if ( imem(adopti+38).ne.0 .and.
     >     imem(adopti+10).ne.26 .and.
     >     imem(adopti+10).ne.46 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMEXT', nompro
#endif
c
        call vcmext ( lgopti, imem(adopti), lgopts, smem(adopts),
     >                lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      call gtfims (nrssse)
c
c====
c 3. menage des structures liees au calcul
c====
c
      if ( codret.eq.0 ) then
        nocman = smem(adopts)
        call gmsgoj ( nocman, codret )
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
c 4.2. ==> fin des mesures de temps de la section
c
      call gtfims (nrsect)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      endif
c
c=======================================================================
      endif
c=======================================================================
c
      end
