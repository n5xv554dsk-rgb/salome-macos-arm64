      subroutine eslen1 ( idfmed, nomamd,
     >                    nhnoeu,
     >                    dimcst,
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
c  Entree-Sortie : LEcture des Noeuds - 1
c  -      -        --          -        -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   . char64 . nom du maillage MED voulu                  .
c . nhnoeu . e   . char8  . nom de l'objet decrivant les noeuds        .
c . dimcst . e   .    1   . dimension de la coordonnee constante       .
c .        .     .        . eventuelle, 0 si toutes varient            .
c . ltbiau . e   .    1   . longueur allouee a tbiaux                  .
c . tbiaux .     .    *   . tableau tampon entier                      .
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
      parameter ( nompro = 'ESLEN1' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
#include "gmreel.h"
c
#include "impr02.h"
#include "nombno.h"
#include "envca1.h"
#include "enti01.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer dimcst
      integer ltbiau, tbiaux(*)
c
      character*8 nhnoeu
      character*64 nomamd
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
      integer codre1, codre2
      integer codre0
      integer nbcomp
      integer typenh
      integer pcoono, adcocs
      integer numdt, numit
c
      character*16 nomcmp(nbcmax), unicmp(nbcmax)
      character*64 nomcha
      character*64 noprof
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "esimpr.h"
c
      texte(1,4) = '(''... Lecture des complements pour les noeuds'')'
      texte(1,81) = '(''Longueur allouee pour tbiaux    : '',i10)'
      texte(1,82) = '(''Longueur necessaire pour tbiaux : '',i10)'
c
      texte(2,4) = '(''... Readings of additional terms for nodes'')'
      texte(2,81) = '(''Allocated length for tbiaux    : '',i10)'
      texte(2,82) = '(''Used length for tbiaux : '',i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
c====
c 2. Lecture sous forme de champ pour les tableaux
c====
c 2.1. ==> Reperage du champ et du nombre de ses composantes
c
      nomcha = blan64
      nomcha(1:8) = suffix(3,-1)
      iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLE01_no', nompro
#endif
      call esle01 ( idfmed, nomamd, nomcha,
     >              nbcomp, nomcmp, unicmp,
     >              iaux, jaux,
     >              ulsort, langue, codret)
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
c 2.2. ==> Lecture des valeurs du champ, en mode non entrelace.
c    En fortran, cela correspond au stockage memoire suivant :
c    tabaux(1,1), tabaux(2,1), tabaux(3,1), ..., tabaux(nbnoto,1),
c    tabaux(1,2), tabaux(2,2), tabaux(3,2), ..., tabaux(nbnoto,2),
c    ...
c    tabaux(1,nbcomp), tabaux(2,nbcomp), ..., tabaux(nbnoto,nbcomp)
c    on a ainsi toutes les valeurs pour la premiere composante, puis
c    toutes les valeurs pour la seconde composante, etc.
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. Lecture ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      numdt = ednodt
      numit = ednoit
      iaux = 0
c                A TRAITER plus tard
cgn#ifdef _DEBUG_HOMARD_
cgn       write (ulsort,texte(langue,3)) 'MFDIVR', nompro
cgn#endif
cgn       call mfdivr ( idfmed, nomcha, numdt, numit,
cgn      >              ednoeu, iaux, ednoin,
cgn      >              edall,
cgn      >              tbiaux, codret )
      noprof = blan64
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDIPR', nompro
#endif
      call mfdipr ( idfmed, nomcha, numdt, numit,
     >              ednoeu, iaux, 1, noprof, ednoin,
     >              edall,
     >              tbiaux, codret )
c
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,18)) nomcha
      endif
c
      endif
c
c 2.3. ==> Transfert
c
      if ( codret.eq.0 ) then
c
      do 23 , iaux = 1 , nbcomp
c
        if ( codret.eq.0 ) then
c
        call gmaloj ( nhnoeu//'.'//nomcmp(iaux), ' ',
     >                nbnoto, laux, codret )
c
        endif
c
      if ( codret.eq.0 ) then
c
        kaux = nbnoto*(iaux-1)
        laux = laux - 1
        do 231 , jaux = 1 , nbnoto
          imem(laux+jaux) = tbiaux(kaux+jaux)
  231   continue
c
        endif
c
#ifdef _DEBUG_HOMARD_
        call gmprsx ( nompro, nhnoeu//'.'//nomcmp(iaux) )
#endif
c
   23 continue
c
      endif
c
c====
c 3. Lecture sous forme de profil pour les informations supplementaires
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Lecture profil ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      typenh = -1
      iaux = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLE02_'//mess14(langue,1,typenh),
     >                                nompro
#endif
      call esle02 ( idfmed,
     >              typenh, nhnoeu, iaux,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 4. Coordonnees extremes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. coo extremes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 11
      call gmaloj ( nhnoeu//'.CoorCons', ' ', iaux, adcocs, codre1 )
      call gmadoj ( nhnoeu//'.Coor', pcoono, iaux, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLE03', nompro
#endif
      call esle03 ( idfmed,
     >              nbnoto, sdim, rmem(pcoono), dimcst,
     >              rmem(adcocs),
     >              ulsort, langue, codret)
c
      endif
c
c====
c 5. la fin
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
