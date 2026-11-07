      subroutine hoavcv ( codret )
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
c       HOMARD : interface AVant adaptation : ConVersions
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
c .        .     .        . 7 : problemes dans les noms d'objet        .
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
      parameter ( nompro = 'HOAVCV' )
c
#include "motcle.h"
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca2.h"
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
      character*8 typobs, nohman, nocman, nosvmn
c
      integer nbmess
      parameter ( nbmess = 20 )
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
     >''' C O N V E R S I O N S   A V A N T   A D A P T A T I O N'')'
      texte(1,5) = '(62(''=''),/)'
c
      texte(2,4) =
     > '(//,a6,'//
     >''' C O N V E R S I O N S   B E F O R E   A D A P T A T I O N'')'
      texte(2,5) = '(64(''=''),/)'
c
#include "impr03.h"
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
c 1.9. ==> la date courante
c
      call utdhlg ( ladate, langue )
c
c====
c 2. conversion du maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. conversion ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      nrssse = imem(adetco+3)
      call gtdems (nrssse)
c
c 2.1. ==> prealable pour le suivi de frontiere
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. prealable frontiere ; codret', codret
#endif
c
      if ( ( ( mod(imem(adopti+28),2).eq.0 ) .and.
     >       ( imem(adopti+28).lt.0 ) )  .or.
     >     ( ( mod(imem(adopti+28),5).eq.0 ) .and.
     >       ( imem(adopti+9).eq.0 ) ) ) then
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
      if ( imem(adopti+20).eq.1 ) then
c
c 2.2. ==> prealable pour le cas saturne/neptune 2D
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. prealable sat/nep ; codret', codret
#endif
c
        if ( imem(adopti+10).eq.26 .or.
     >       imem(adopti+10).eq.46 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMS2D', nompro
#endif
c
          call vcms2d ( lgopti, imem(adopti), lgopts, smem(adopts),
     >                  lgetco, imem(adetco),
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
c 2.3. ==> conversion vraie
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
c 3. Le cas extrude, non saturne, non neptune
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. cas extrude ; codret', codret
#endif
c
      if ( imem(adopti+38).ne.0 .and.
     >     imem(adopti+10).ne.26 .and.
     >     imem(adopti+10).ne.46 ) then
c
c 3.1. ==> Conversion complete
c
        if ( imem(adopti+20).eq.1 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMEXT', nompro
#endif
c
          call vcmext ( lgopti, imem(adopti), lgopts, smem(adopts),
     >                  lgetco, imem(adetco),
     >                  ulsort, langue, codret )
c
          endif
c
c 3.2. ==> Conversion partielle
c
        else
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMEXA', nompro
#endif
c
          call vcmexa ( lgopti, imem(adopti), lgopts, smem(adopts),
     >                  lgetco, imem(adetco),
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      endif
c
c====
c 4. s'il y a conversion de solution, on cree une structure de
c    memorisation du maillage n
c====
c
      if ( imem(adopti+20).eq.1.and. imem(adopti+27).eq.1 ) then
c
        if ( codret.eq.0 ) then
c
        nohman = smem(adopts+2)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSVMN', nompro
#endif
        call utsvmn ( nohman, nosvmn,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        smem(adopts+13) = nosvmn
c
        endif
c
      endif
c
c====
c 5. Informations sur le maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Informations ; codret', codret
#endif
c 5.1. ==> analyse du maillage
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.1. analyse ; codret', codret
#endif
c
      if ( imem(adopti+20).eq.1 ) then
c
        if ( codret.eq.0 ) then
c
        commen(1) = 'Maillage converti au format HOMARD                '
        commen(2) = 'Mesh converted to the HOMARD format               '
c
#ifdef _DEBUG_HOMARD_
        call utbica ( commen(langue),
     >                ulsort, langue, codret )
#endif
c
        endif
c
        call gtfims (nrssse)
c
      else
c
        commen(1) = 'Maillage lu au format HOMARD                      '
        commen(2) = 'Mesh read with HOMARD format                      '
c
      endif
c
c 5.2. ==> Nom du maillage au format HOMARD
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.2. nom du maillage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      typobs = mchman
      iaux = 1
      call utosno ( typobs, nohman, iaux, ulsort, langue, codret )
c
      endif
c
c====
c 6. Prise en compte eventuelle du suivi de frontiere
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. frontiere ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
      nrssse = imem(adetco+3)
c
      if ( mod(imem(adopti+28),2).eq.0 .or.
     >     mod(imem(adopti+28),3).eq.0 .or.
     >     mod(imem(adopti+28),5).eq.0 ) then
c
        call gtdems (nrssse)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCOIN', nompro
#endif
        call sfcoin ( nohman,
     >                lgopti, imem(adopti), lgopts, smem(adopts),
     >                lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
        call gtfims (nrssse)
c
      endif
c
      endif
c
c====
c 7. analyse du maillage
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. analyse du maillage ; codret', codret
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
c
      action = smem(adopts+29)
      if ( action.eq.'homa    ' ) then
        action = 'avad'
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTBILM', nompro
#endif
      call utbilm ( nohman, commen(langue), imem(adopti+2), action,
     >              lgetco, imem(adetco),
     >              ulsort, langue, codret )
      endif
c
      call gtfims (nrssse)
c
      endif
c
c====
c 8. Filtrages de l'adaptation
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. filtrage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      imem(adetco+3) = imem(adetco+3) + 1
c
      if ( imem(adopti+18).gt.0 .or.
     >     rmem(adoptr+2).gt.0.d0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCFIAD', nompro
#endif
        call vcfiad ( lgopti, imem(adopti), lgoptr, rmem(adoptr),
     >                lgopts, smem(adopts),
     >                lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
      endif
c
      endif
c
c====
c 9. conversion eventuelle de l'indicateur d'erreur
c===
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. indicateur erreur ; codret', codret
#endif
c
      if ( imem(adopti+26).eq.1 ) then
c
c 9.1. ==> lecture
c
        if ( codret.eq.0 ) then
c
        imem(adetco+3) = imem(adetco+3) + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'HOAVLI', nompro
#endif
        call hoavli ( lgopti, imem(adopti), lgoptr, rmem(adoptr),
     >                lgopts, smem(adopts),
     >                lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
        endif
c
c 9.2. ==> prealable pour le cas extrude
c
        if ( codret.eq.0 ) then
c
        if ( imem(adopti+38).ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSEXT', nompro
#endif
          iaux = 1
          call utsext ( smem(adopts+6), iaux, imem(adopti+10),
     >                  lgetco, imem(adetco),
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
c 9.3. ==> conversion vraie
c
        if ( codret.eq.0 ) then
c
        imem(adetco+3) = imem(adetco+3) + 1
c
        nrssse = imem(adetco+3)
        call gtdems (nrssse)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCINDI', nompro
#endif
        call vcindi ( lgopti, imem(adopti), lgopts, smem(adopts),
     >                lgetco, imem(adetco),
     >                ulsort, langue, codret )
c
        call gtfims (nrssse)
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro,smem(adopts+7))
cgn        call gmprsx (nompro,smem(adopts+7)//'.Quadr')
cgn        call gmprsx (nompro,smem(adopts+7)//'.Quadr.Support')
cgn        call gmprsx (nompro,smem(adopts+7)//'.Quadr.ValeursR')
#endif
c
        endif
c
      endif
c
c====
c 10. menage des structures liees au calcul
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. menage ; codret', codret
#endif
c
      if ( imem(adopti+20).eq.1 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'GMSGOJ', nompro
#endif
        nocman = smem(adopts)
        call gmsgoj ( nocman, codret )
c
      endif
c
      endif
c
c====
c 11. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '11. la fin ; codret', codret
#endif
c
c 11.1. ==> message si erreur
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
c 11.2. ==> fin des mesures de temps de la section
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
