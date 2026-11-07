      subroutine infc00 ( nbrcas, caopti, nbcham,
     >                    tab,
     >                    nocsol, nbpafo,
     >                    adinch, adinpf,
     >                    ulsort, langue, codret )
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
c  INformation - inFormations Complementaires - phase 00
c  --              -          -                       --
c ______________________________________________________________________
c  Allocation de la structure de l'objet solution
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbrcas . e   .   1    . nombre de cas :                            .
c .        .     .        . 1 : niveau                                 .
c .        .     .        . 2 : qualite                                .
c .        .     .        . 3 : diametre                               .
c .        .     .        . 4 : parente                                .
c .        .     .        . 5 : voisins des recollements               .
c . caopti . e   . nbrcas . 0/1 selon que le cas est retenu            .
c . nbcham . e   .   1    . nombre de champs associes                  .
c . tab    .  s  .(-2:7)* . i = -2 : nombre de paquets concernes       .
c .        .     . nbrcas . i > -2 : nombre de valeurs pour l'entite i .
c . nocsol .  s  .   1    . nom de l'objet solution cree               .
c . nbpafo .  s  .   1    . nombre d'inf. sur les paquets de fonctions .
c . adinch .  s  .   1    . adresse de l'information sur les champs    .
c . adinpf .  s  .   1    . adresse de l'inf. sur paquets de fonctions .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'INFC00' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "nombtr.h"
#include "nombte.h"
#include "nombqu.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      integer nbrcas, nbcham
      integer caopti(nbrcas)
      integer tab(-2:7,nbrcas)
      integer nbpafo
      integer adinch, adinpf
c
      character*8 nocsol
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux
      integer tabaux(6,2)
      integer nbprof, nblopg
      integer adinpr, adinlg
      integer ladim
c
      integer nucas
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
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
      texte(1,4) = '(''Creation de l''''objet '', a8)'
c
      texte(2,4) = '(''Creation of the object '', a8)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbrcas', nbrcas
      write (ulsort,90002) 'caopti', caopti
      write (ulsort,90002) 'nbcham', nbcham
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbtria', nbtria
      write (ulsort,90002) 'nbquad', nbquad
      write (ulsort,90002) 'nbtetr', nbtetr
      write (ulsort,90002) 'nbpyra', nbpyra
      write (ulsort,90002) 'nbhexa', nbhexa
      write (ulsort,90002) 'nbpent', nbpent
#endif
c
      codret = 0
c
c====
c 2. Nombre de valeurs
c====
c 2.1. ==> Dimension a prendre en compte
c
      if ( nbteto.ne.0 .or. nbheto.ne.0 .or.
     >     nbpeto.ne.0 .or. nbpyto.ne.0 ) then
        ladim = 3
      elseif ( nbtrto.ne.0 .or. nbquto.ne.0 ) then
        ladim = 2
      else
        ladim = 1
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'ladim', ladim
#endif
c
c 2.2. ==> Decompte du nombre de valeurs
c
      if ( ladim.le.1 ) then
        kaux = 0
      elseif ( ladim.eq.3 ) then
        kaux = 4
        tabaux(1,1) = nbtetr
        tabaux(1,2) = 3
        tabaux(2,1) = nbpyra
        tabaux(2,2) = 5
        tabaux(3,1) = nbhexa
        tabaux(3,2) = 6
        tabaux(4,1) = nbpent
        tabaux(4,2) = 7
      endif
      if ( ladim.ge.2 ) then
        kaux = kaux+1
        tabaux(kaux,1) = nbtria
        tabaux(kaux,2) = 2
        kaux = kaux+1
        tabaux(kaux,1) = nbquad
        tabaux(kaux,2) = 4
      endif
c
c 2.3. ==> Transfert
c
      do 231 , iaux = -2, 7
        do 2311 , nucas = 1, nbrcas
          tab(iaux,nucas) = 0
          tab(iaux,nucas) = 0
 2311   continue
  231 continue
c
      do 232 , nucas = 1, nbrcas
        if ( ( ladim.eq.3 .and. nucas.eq.1 ) .or. ( nucas.eq.5 ) ) then
          laux = kaux - 2
        else
          laux = kaux
        endif
        do 2321 , iaux = 1, laux
          if ( tabaux(iaux,1).gt.0 ) then
            jaux = tabaux(iaux,2)
            tab(-2,nucas) = tab(-2,nucas) + caopti(nucas)
            tab(jaux,nucas) = tabaux(iaux,1)*caopti(nucas)
          endif
 2321   continue
  232 continue
c
#ifdef _DEBUG_HOMARD_
      do 2333 , iaux = 1, nbrcas
      write (ulsort,90015) 'tab de', iaux,' :',
     >                     (tab(jaux,iaux),jaux=-2,7)
 2333 continue
#endif
c
c====
c 3. allocation de la structure de tete
c====
c
      nbpafo = 0
      do 31 , nucas = 1, nbrcas
        do 311 , jaux = -1, 7
          if ( tab(jaux,nucas).gt.0 ) then
            nbpafo = nbpafo + 1
          endif
  311 continue
   31 continue
c
      nbprof = 0
      nblopg = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALSO', nompro
#endif
      call utalso ( nocsol,
     >              nbcham, nbpafo, nbprof, nblopg,
     >              adinch, adinpf, adinpr, adinlg,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nocsol
      call gmprsx ( nompro, nocsol )
#endif
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
