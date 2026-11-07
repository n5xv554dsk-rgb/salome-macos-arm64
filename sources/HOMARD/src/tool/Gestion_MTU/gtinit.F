      subroutine gtinit ( ulsort, lgmess, imprgt )
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
c                                       premiere creation le 30.12.88 gn
c ______________________________________________________________________
c
c    'Gestion du Temps : INITialisation'
c     -          -       ----
c
c ______________________________________________________________________
c
c but : initialiser la gestion des mesures de temps
c       - on archive ce point de depart
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ulsort . e   .    1   . numero de l'unite logique ou imprimer      .
c .        .     .        . les messages du gestionnaire de temps      .
c . lgmess . e   .    1   . langue des message de gt                   .
c . imprgt . e   .    1   . pilotage des impressions                   .
c .        .     .        . 1 : le standard                            .
c .        .     .        . 2 : le detail des sections                 .
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
      parameter ( nompro = 'GTINIT' )
c
#include "genbla.h"
#include "gelggt.h"
c
#include "gtnbse.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer ulsort, lgmess, imprgt
c
c 0.4. ==> variables locales
c
#include "gedita.h"
#include "gtdita.h"
c
      integer iaux, jaux, code
      integer langue
c
      integer numann, datheu
c
      double precision tuser, tsyst
c
      character*24 blanc
      parameter ( blanc = '                        ' )
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
      if ( lgmess.ge.1 .and. lgmess.le.nblang ) then
        langue = lgmess
      else
        langue = 1
      endif
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,10) = 'Ensemble du programme   '
c
      texte(2,10) = 'Total program           '
c
c====
c 2. verification que l'initialisation n'est pas deja faite
c====
c
      code = 1
      call ugtabl ( code, tabges, ulsort)
c
      if ( tabges(2).ne.0 ) then
        write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,20000)
        iaux = 1
        call gtstop ( nompro , ulsort , iaux )
      endif
c
20000 format(
     >'L''initialisation du gestionnaire a deja ete faite.',/,
     >'Il ne faut faire appel qu''une seule fois a GTINIT.',//)
c
c====
c  3. initialisation de dmtemp
c====
c
      call dmtemp ( tuser, tsyst )
c
c====
c  4. acquisition de la date et de l'heure actuelle
c====
c
      call ugdhco ( numann, datheu )
c
c====
c  5. initialisation des differents tableaux
c====
c
      nbrapp (-4) = imprgt
      nbrapp (-3) = lgmess
      nbrapp (-2) = numann
      nbrapp (-1) = datheu
      nbrapp ( 0) = ulsort
c
      tpscpu (0) = 0.d0
c
      do 51 , iaux = 1 , nbsect
c
        nbrapp (iaux) = 0
        ouvert (iaux) = .false.
        tpscpu (iaux) = 0.d0
c
   51 continue
c
      nbrapp (nbsep1) = 1
      ouvert (nbsep1) = .true.
      tpscpu (nbsep1) = 0.d0
c
      do 52 , jaux = 1 , nblang
        do 521 , iaux = 1 , nbsect
          titsec (jaux,iaux) = blanc
  521   continue
        titsec (jaux,nbsep1) = texte(lgmess,10)(1:24)
   52 continue
c
c====
c 6. on archive l'information
c====
c
c 6.1. ==> pour le gestionnaire des mesures de temps de calcul
c
      code = 0
      iaux = nbsep1
      call gttabl ( code, iaux, nbrapp, ouvert, titsec, tpscpu )
c
c 6.2. ==>  attention, l'initialisation de ulsort doit se faire par
c           le programme gtmess, pour controler la validite du numero
c
      call gtmess ( ulsort )
c
c 6.3. ==> archivage pour le gestionnaire global
c
      tabges(2) = 1
c
      code = 0
      call ugtabl ( code, tabges, ulsort)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
