      subroutine holver ( lgopti, taopti, lgoptr, taoptr,
     >                    lgetco, taetco,
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
c   HOMARD : Lectures VERifications
c   --       -        ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . e   . lgopti . tableau des options                        .
c . lgoptr . e   .   1    . longueur du tableau des options reelles    .
c . taoptr . e   . lgoptr . tableau des options reelles                .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : incoherence dans les options           .
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
      parameter ( nompro = 'HOLVER' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "ope1a3.h"
c
c 0.3. ==> arguments
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgoptr
      double precision taoptr(lgoptr)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
      integer nbrepb
      integer nretap, nrsset
      integer iaux, jaux
      integer modhom
c
      character*6 saux
c
      integer nbmess
      parameter ( nbmess = 200 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
c 1.1. ==> tout va bien
c
      codret = 0
c
      nbrepb = 0
c
c 1.2. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(/,a6,'' VERIFICATION DES OPTIONS'')'
      texte(1,5) = '(31(''=''),/)'
      texte(1,8) = '(/,''Mode de fonctionnement de HOMARD :'')'
c
      texte(1,95) = '(7x,''Maillage avant adaptation :'')'
      texte(1,96) = '(7x,''Maillage apres adaptation :'')'
      texte(1,97) = '(7x,''Maillage apres modification :'')'
      texte(1,98) = '(7x,''Indicateurs d''''erreurs :'')'
      texte(1,99) = '(7x,''Solution :'')'
c
      texte(2,4) = '(/,a6,'' CONTROL OF OPTIONS'')'
      texte(2,5) = '(25(''=''),/)'
      texte(2,8) = '(/,''HOMARD running mode:'')'
c
      texte(2,95) = '(7x,''Mesh before adaptation:'')'
      texte(2,96) = '(7x,''Mesh after adaptation:'')'
      texte(2,97) = '(7x,''Mesh after modification:'')'
      texte(2,98) = '(7x,''Error indicator:'')'
      texte(2,99) = '(7x,''Solution:'')'
c
#include "impr03.h"
c
#include "mslver.h"
c
c 1.3. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.4. ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 2. verification du mode d'utilisation de homard
c====
c
      if ( taopti(4).ge.1 .and. taopti(4).le.5 ) then
        modhom = taopti(4)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'modhom', modhom
#endif
      else
        write(ulsort,texte(langue,8))
        write(ulsort,texte(langue,11)) taopti(4)
        nbrepb = nbrepb + 1
      endif
c
c====
c 3. verification de la validite des mots_cles de pilotage
c====
c
c 3.1. ==> type de code de calcul associe
c
#include "mslve0.h"
#include "mslve1.h"
c
c 3.2. ==> pour le mode homard pur
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. homard pur ; nbrepb', nbrepb
#endif
c
      if ( modhom.eq.1 ) then
c
c 3.2.1. ==> numero d'iteration initiale
c
      write(ulsort,texte(langue,23))
      if ( taopti(10).eq.0 ) then
        write(ulsort,texte(langue,20))
      elseif ( taopti(10).eq.1 ) then
        write(ulsort,texte(langue,21))
      elseif ( taopti(10).gt.1 ) then
        write(ulsort,texte(langue,22)) taopti(10)
      else
        write(ulsort,texte(langue,11)) taopti(10)
        nbrepb = nbrepb + 1
      endif
c
c 3.2.2. ==> type de conformite
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2.2. conformite ; nbrepb', nbrepb
#endif
c
#include "mslve2.h"
c
c 3.2.3. ==> maillage extrude
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2.3. maillage extrude ; nbrepb', nbrepb
#endif
c
#include "mslve3.h"
c
c 3.2.4. ==> raffinement
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2.4. raffinement ; nbrepb', nbrepb
#endif
c
#include "mslve5.h"
#include "mslv13.h"
#include "mslve6.h"
c
c 3.2.5. ==> deraffinement
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2.5. deraffinement ; nbrepb', nbrepb
#endif
c
#include "mslve7.h"
#include "mslve8.h"
c
c 3.2.6. ==> coherence entre raffinement et deraffinement
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2.6. raff/dera ; nbrepb', nbrepb
#endif
c
#include "mslve9.h"
c
c 3.2.7. ==> coherence des seuils
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2.7. seuils ; nbrepb', nbrepb
#endif
c
#include "mslv10.h"
c
c 3.2.8. ==> indicateur de suivi de frontiere
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2.8. suivi de frontiere ; nbrepb', nbrepb
#endif
c
#include "mslv11.h"
c
c 3.3. ==> pour les autres modes
c
      else
c
      taopti(31) = 0
      taopti(32) = 0
c
      endif
c
c 3.4. ==> pour le mode homard pur ou interpolation de solution
c
      if ( modhom.eq.1 .or. modhom.eq.4 ) then
c
c 3.4.1. ==> indicateur de conversion de la solution
c
      write(ulsort,texte(langue,61))
c
      write(ulsort,texte(langue,99))
      if ( taopti(28).eq.0 ) then
        write(ulsort,texte(langue,12))
      elseif ( taopti(28).eq.1 ) then
        write(ulsort,texte(langue,13))
      else
        write(ulsort,texte(langue,11)) taopti(28)
        nbrepb = nbrepb + 1
      endif
c
      endif
c
c 3.5. ==> reperage temporel de l'indicateur d'erreur
c
      if ( modhom.eq.1 ) then
c
#include "mslv12.h"
c
      endif
c
c====
c 4. message si erreur
c====
c
      if ( nbrepb.ne.0 ) then
c
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        if ( nbrepb.eq.1 ) then
          write (ulsort,texte(langue,6))
        else
          write (ulsort,texte(langue,7))
        endif
        codret = 2
c
      endif
c
c====
c 5. si tout va bien, on en deduit les conversions a faire
c====
c
      if ( codret.eq.0 ) then
c
c 5.1. ==> indicateur de conversion du maillage
c
c 5.1.1. ==> pour le mode homard pur
c
      if ( modhom.eq.1 ) then
c
      write(ulsort,texte(langue,95))
      if ( taopti(10).eq.0 ) then
        taopti(21) = 1
        write(ulsort,texte(langue,13))
      else
        taopti(21) = 0
        write(ulsort,texte(langue,12))
      endif
c
      write(ulsort,texte(langue,96))
      taopti(22) = 1
      write(ulsort,texte(langue,13))
c
c 5.1.2. ==> pour le mode information
c
      elseif ( modhom.eq.2 ) then
c
      write(ulsort,texte(langue,24))
      if ( taopti(11).ne.1 ) then
        taopti(21) = 1
        write(ulsort,texte(langue,13))
      else
        taopti(21) = 0
        write(ulsort,texte(langue,12))
      endif
c
c 5.1.3. ==> pour le mode modification
c
      elseif ( modhom.eq.3 ) then
c
      write(ulsort,texte(langue,25))
      if ( taopti(11).ne.1 ) then
        taopti(21) = 1
        write(ulsort,texte(langue,13))
      else
        taopti(21) = 0
        write(ulsort,texte(langue,12))
      endif
c
      write(ulsort,texte(langue,97))
      taopti(22) = 1
      write(ulsort,texte(langue,13))
c
c 5.1.4. ==> pour le mode interpolation
c
      else
c
      taopti(21) = 0
      taopti(22) = 0
c
      endif
c
c 5.2. ==> indicateur de conversion de l'indicateur d'erreur
c
c 5.2.1. ==> pour le mode homard pur
c
      if ( modhom.eq.1 ) then
c
        if ( taopti(37).eq.0 ) then
          write(ulsort,texte(langue,98))
            taopti(27) = 0
          if ( taopti(10).eq.0 ) then
            if ( taopti(31).gt.0 ) then
              taopti(27) = 1
            endif
          else
            if ( taopti(31).gt.0 .or. taopti(32).gt.0 ) then
              taopti(27) = 1
            endif
          endif
          if ( taopti(27).eq.0 ) then
            write(ulsort,texte(langue,12))
          else
            write(ulsort,texte(langue,13))
          endif
        else
          taopti(27) = 0
        endif
c
c 5.2.2. ==> pour les autres modes
c
      else
c
      taopti(27) = 0
c
      endif
c
      endif

c====
c 6. ecriture des fichiers HOMARD : rien pour le mode d'information
c====
c
      if ( codret.eq.0 ) then
c
      if ( modhom.eq.2 ) then
        taopti(5) = 1
      endif
c
      endif
c
c====
c 7. Option du delta de coordonnees pour les maillages extrudes
c====
c
      if ( taopti(39).ne.0 ) then
c
c 7.1 ==> Si le delta est impose, on doit avoir une valeur > 0
c
      if ( codret.eq.0 ) then
c
      if ( taopti(40).eq.2 ) then
c
      if ( abs(taoptr(3)+1789.d0).lt.1.0d-6 ) then
        write(ulsort,texte(langue,70))
        write(ulsort,texte(langue,72))
        codret = 2
c
      elseif ( taoptr(3).le.0.0d0 ) then
        write(ulsort,texte(langue,70))
        write(ulsort,texte(langue,73))
        codret = 2
c
      endif
c
      endif
c
      endif
c
      endif
c
c====
c 8. la fin
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
c=======================================================================
      endif
c=======================================================================
c
      end
