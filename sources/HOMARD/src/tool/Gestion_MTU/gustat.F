      subroutine gustat ( gunmbr )
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
c but : etablit les statistiques relatives a la gestion des unites
c       logiques
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . gunmbr . e   .   *    . les nombres caracteristiques de la gestion .
c .        .     .        .(1): nb maxi d'unites ouvertes form/sequ    .
c .        .     .        .(2): nb maxi d'unites ouvertes bina/sequ    .
c .        .     .        .(3): nb maxi d'unites ouvertes bina/dire sta.
c .        .     .        .(4): nb maxi d'unites ouvertes bina/dire spe.
c .        .     .        .(5): nb total d'unites ouvertes form/sequ   .
c .        .     .        .(6): nb total d'unites ouvertes bina/sequ   .
c .        .     .        .(7): nb total d'unites ouvertes bina/dire st.
c .        .     .        .(8): nb total d'unites ouvertes bina/dire sp.
c .        .     .        .(9): nb actuel d'unites ouvertes form/sequ  .
c .        .     .        .(10): nb actuel d'unites ouvertes bina/sequ .
c .        .     .        .(11): nb actuel d'unites ouvertes bina/dire .
c .        .     .        .(12): nb actuel d'unites ouvertes bina/dire .
c .        .     .        .(13): nb maxi d'unites ouvertes tous types  .
c .        .     .        .(14): numero de l'entree standard           .
c .        .     .        .(15): numero de la sortie standard          .
c .        .     .        .(16): numero de l'unite des messages du gu  .
c .        .     .        .(17): langue des messages du gu             .
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
#ifdef _DEBUG_HOMARD_
      character*6 nompro
      parameter ( nompro = 'GUSTAT' )
#endif
c
#include "gulggt.h"
#ifdef _DEBUG_HOMARD_
#include "genbla.h"
#include "gunbul.h"
#endif
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer gunmbr(lgunmb)
c
c 0.4. ==> variables locales
c
      integer iaux
c
#ifdef _DEBUG_HOMARD_
c
      integer ulsort
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
      character*31 chstat(nblang,5)
c
      integer langue
#endif
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#ifdef _DEBUG_HOMARD_
      ulsort = gunmbr(16)
      langue = gunmbr(17)
#endif
c
#ifdef _DEBUG_HOMARD_
#include "impr01.h"
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#ifdef _DEBUG_HOMARD_
c
      chstat(1,1) = 'Formate, acces sequentiel      '
      chstat(1,2) = 'Binaire, acces sequentiel      '
      chstat(1,3) = 'Binaire, acces direct standard '
      chstat(1,4) = 'Binaire, acces direct special  '
      chstat(1,5) = 'Tous types confondus           '
c
      chstat(2,1) = 'Formatted, sequential access   '
      chstat(2,2) = 'Binary, sequential access      '
      chstat(2,3) = 'Binary, standard direct access '
      chstat(2,4) = 'Binary, special direct access  '
      chstat(2,5) = 'All kinds of files             '
c
      texte(1,4) =
     > '('':'',22x,''Unites logiques employees'',22x,'':'')'
      texte(1,5) =
     > '('':'',20x,''Type'',19x,'':   Nombre   :   Nombre   :'')'
      texte(1,6) =
     > '('':'',43x             ,'':   maximum  :   cumule   :'')'
c
      texte(2,4) =
     > '('':'',26x,''Used logical units'',25x,'':'')'
      texte(2,5) =
     > '('':'',20x,''Type'',19x,'':  Maximum   : Accumulated:'')'
      texte(2,6) =
     > '('':'',43x             ,'':   number   :   number   :'')'
c
c===
c 2. impressions
c===
c
      write (ulsort,21001)
c
      write (ulsort,21002)
      write (ulsort,texte(langue,4))
      write (ulsort,21003)
      write (ulsort,texte(langue,5))
      write (ulsort,texte(langue,6))
      write (ulsort,21003)
c
      do 2 , iaux = 1 , 4
         write (ulsort,21004) chstat(langue,iaux),
     >                        gunmbr(iaux), gunmbr(iaux+4)
    2 continue
c
      iaux = gunmbr(5) + gunmbr(6) + gunmbr(7) + gunmbr(8)
      write (ulsort,21003)
      write (ulsort,21004) chstat(langue,5), gunmbr(13), iaux
      write (ulsort,21003)
c
21001 format(////)
21002 format(71('.'))
21003 format(':',69('.'),':')
21004 format(': ',a31,11x,':',i7,5x,':',i7,5x,':')
c
#endif
c
      call dmflsh (iaux)
c
      end
