      subroutine esecn1 ( idfmed, nomamd,
     >                    adhist, adarno,
     >                    adhono, addera,
     >                    numdt, numit, instan,
     >                    ltbiau, tbiaux,
     >                    ulsort, langue, codret)
c
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
c  Entree-Sortie : ECriture des Noeuds - 1
c  -      -        --           -        -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   .   1    . nom du maillage MED voulu                  .
c . ltbiau . e   .    1   . longueur allouee a tbiaux                  .
c . tbiaux .     .    *   . tableau tampon entier                      .
c . numdt  . e   .   1    . numero du pas de temps                     .
c . numit  . e   .   1    . numero d'iteration                         .
c . instan . e   .   1    . pas de temps                               .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'ESECN1' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
c
#include "enti01.h"
#include "nombno.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer adhist, adarno
      integer adhono, addera
      integer numdt, numit
      integer ltbiau, tbiaux(*)
c
      character*64 nomamd
c
      double precision instan
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer nbcmax
      parameter ( nbcmax = 20 )
c
      integer iaux, jaux, kaux, laux
      integer adress(nbcmax)
      integer nbcomp
c
      character*16 dtunit
      character*16 nomcmp(nbcmax), unicmp(nbcmax)
      character*64 nomcha
c
      logical prem
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisation
c
      data prem / .true. /
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''... Ecriture des complements pour les noeuds'')'
c
      texte(2,4) = '(''... Writings of additional terms for nodes'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
#include "esimpr.h"
c
      texte(1,4) = '(/,''Creation du champ : '',a64)'
      texte(1,5) = '(''Type du champ : '',i2)'
      texte(1,6) =
     > '(''Numero !     Composante     !       Unite'',/,49(''-''))'
      texte(1,7) = '(i6,'' !  '',a16,''  !  '',a16)'
      texte(1,81) = '(''Longueur allouee pour tbiaux    : '',i10)'
      texte(1,82) = '(''Longueur necessaire pour tbiaux : '',i10)'
c
      texte(2,4) = '(/,''Creation of field : '',a64)'
      texte(2,5) = '(''Type of field : '',i2)'
      texte(2,6) =
     > '(''  #    !     Component      !       Unit'',/,49(''-''))'
      texte(2,7) = '(i6,'' !  '',a16,''  !  '',a16)'
      texte(2,81) = '(''Allocated length for tbiaux    : '',i10)'
      texte(2,82) = '(''Used length for tbiaux : '',i10)'
c
c 1.2. ==> unites : non definies
c
      if ( prem ) then
c
        do 12 , iaux = 1 , nbcmax
          unicmp(iaux) = blan16
   12   continue
        prem = .false.
c
      endif
c
c====
c 2. Reperage des composantes en fonction de la presence des tableaux
c====
c
      if ( codret.eq.0 ) then
c
      nbcomp = 0
c
c                         1234567890123456
      if ( adhist.ne.0 ) then
        nbcomp = nbcomp + 1
        adress(nbcomp) = adhist
        nomcmp(nbcomp) = 'HistEtat        '
      endif
c
      if ( adarno.ne.0 ) then
        nbcomp = nbcomp + 1
        adress(nbcomp) = adarno
        nomcmp(nbcomp) = 'AretSupp        '
      endif
c
      if ( adhono.ne.0 ) then
        nbcomp = nbcomp + 1
        adress(nbcomp) = adhono
        nomcmp(nbcomp) = 'Homologu        '
      endif
c
      if ( addera.ne.0 ) then
        nbcomp = nbcomp + 1
        adress(nbcomp) = addera
        nomcmp(nbcomp) = 'Deraffin        '
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,85)) nbcomp
#endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nbnoto*nbcomp.gt.ltbiau ) then
        write (ulsort,texte(langue,85)) nbcomp
        write (ulsort,texte(langue,81)) ltbiau
        write (ulsort,texte(langue,82)) nbnoto*nbcomp
        codret = 7
      endif
c
      endif
c
c====
c 3. Ecritures
c====
c
      if ( nbcomp.gt.0 ) then
c
c 3.1. ==> Creation du champ
c
      if ( codret.eq.0 ) then
c
      nomcha = blan64
      nomcha(1:8) = suffix(3,-1)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nomcha
      write (ulsort,texte(langue,5)) edint
      write (ulsort,texte(langue,6))
      do 31 , iaux = 1 , nbcomp
        write (ulsort,texte(langue,7)) iaux, nomcmp(iaux), unicmp(iaux)
   31 continue
#endif
c
      iaux = edint
      dtunit = blan16
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDCRE', nompro
#endif
      call mfdcre ( idfmed, nomcha, iaux,
     >              nbcomp, nomcmp, unicmp, dtunit, nomamd, codret )
c
      endif
c
      endif
c
c 3.2. ==> Le tableau des valeurs du champ, en mode non entrelace.
c    En fortran, cela correspond au stockage memoire suivant :
c    tbiaux(1,1), tbiaux(2,1), tbiaux(3,1), ..., tbiaux(nbnoto,1),
c    tbiaux(1,2), tbiaux(2,2), tbiaux(3,2), ..., tbiaux(nbnoto,2),
c    ...
c    tbiaux(1,nbcomp), tbiaux(2,nbcomp), ..., tbiaux(nbnoto,nbcomp)
c    on a ainsi toutes les valeurs pour la premiere composante, puis
c    toutes les valeurs pour la seconde composante, etc.
c
      if ( codret.eq.0 ) then
c
      do 32 , iaux = 1 , nbcomp
c
        kaux = nbnoto*(iaux-1)
        laux = adress(iaux)-1
        do 321 , jaux = 1 , nbnoto
          tbiaux(kaux+jaux) = imem(laux+jaux)
  321   continue
c
   32 continue
c
      endif
c
c 3.3. ==> Ecriture des valeurs du champ
c
      if ( codret.eq.0 ) then
c
      iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDIVW', nompro
#endif
      call mfdivw ( idfmed, nomcha,
     >              numdt, numit, instan,
     >              ednoeu, iaux, ednoin, edall,
     >              nbnoto, tbiaux, codret )
c
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,19)) nomcha
      endif
c
      endif
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
