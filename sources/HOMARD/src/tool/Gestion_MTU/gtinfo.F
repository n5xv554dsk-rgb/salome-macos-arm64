      subroutine gtinfo ( imprgt )
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
c    'Gestion des mesures de Temps : INFOrmations'
c     -                      -       ----
c ______________________________________________________________________
c
c but : modifie la consigne d'impression des messages du gestionnaire
c       des mesures de temps
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
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
      parameter ( nompro = 'GTINFO' )
c
#include "genbla.h"
c
#include "gtnbse.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      integer imprgt
c
c 0.4. ==> variables locales
c
#include "gtdita.h"
c
      integer iaux, code
c
      integer ulsort, langue
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisation des messages
c====
c
#include "impr01.h"
c
      texte(1,4) = '(''Dans '',a,'', imprgt ='',i8)'
c
      texte(2,4) = '(''In '',a,'', imprgt ='',i8)'
c
c====
c 2. recuperation de l'archivage
c====
c
      code = 1
      iaux = nbsep1
      call gttabl ( code, iaux, nbrapp, ouvert, titsec, tpscpu )
      langue = nbrapp(-3)
      ulsort = nbrapp(0)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c====
c 3. archivage du code de pilotage des impressions
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nompro, imprgt
#endif
c
      nbrapp(-4) = imprgt
      code = 0
      iaux = nbsep1
      call gttabl ( code, iaux, nbrapp, ouvert, titsec, tpscpu )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
