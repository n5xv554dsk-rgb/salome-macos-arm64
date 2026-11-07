      subroutine deini2 ( nohind, typind, ncmpin,
     >                    nbvtri, nbvqua,
     >                    nbvtet, nbvhex, nbvpyr,
     >                    adquin, adqurn, adqusu,
     >                    adhein, adhern, adhesu,
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
c
c traitement des DEcisions - INITialisations - phase 2
c                --          ---                     -
c ______________________________________________________________________
c  Allocations de structures supplementaires pour accueillir des valeurs
c  d'indicateurs en prevision de la suppression de la conformite
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nohind . e   .  ch8   . nom de l'objet contenant l'indicateur      .
c . typind . e   .   1    . type de valeurs                            .
c .        .     .        . 2 : entieres                               .
c .        .     .        . 3 : reelles                                .
c . ncmpin . e   .   1    . nombre de composantes de l'indicateur      .
c . nbvent . es  .   1    . nombre de valeurs pour l'entite            .
c . adensu . es  .   1    . adresse du support                         .
c . adenin . es  .   1    . adresse des valeurs entieres               .
c . adenrn . es  .   1    . adresse des valeurs reelles                .
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
      parameter ( nompro = 'DEINI2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombqu.h"
#include "nombhe.h"
#ifdef _DEBUG_HOMARD_
#include "enti01.h"
#endif
c
c 0.3. ==> arguments
c
      character*8 nohind
c
      integer typind, ncmpin
      integer nbvtri, nbvqua
      integer nbvtet, nbvhex, nbvpyr
      integer adquin, adqurn, adqusu
      integer adhein, adhern, adhesu
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer typenh
c
#ifdef _DEBUG_HOMARD_
      integer codre0
#endif
      character*8 motaux
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
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Type d''''indicateur inconnu :'',i8)'
c
      texte(2,4) = '(''Indicator type is unknown :'',i8)'
c
      if ( typind.eq.2 ) then
        motaux = 'ValeursE'
      elseif ( typind.eq.3 ) then
        motaux = 'ValeursR'
      else
        write (ulsort,texte(langue,4)) typind
        codret = 1
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      call gmprsx (nompro, nohind )
      do 1999 , iaux = 4, 6, 2
        motaux = '.'//suffix(1,iaux)(1:5)//'  '
        call gmobal ( nohind//motaux, codre0 )
        if ( codre0.eq.1 ) then
          call gmprsx (nompro, nohind//motaux )
        endif
 1999 continue
      endif
#endif
c
c====
c 2. Les quadrangles
c    Dans le cas suivant :
c    . Des quadrangles existent
c    . Aucun indicateur n'a ete defini sur les quadrangles
c    . Un indicateur a ete defini sur les triangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. quadrangles ; codret = ', codret
#endif
c
      if ( nbquto.ne.0 .and. nbvqua.eq.0 .and. nbvtri.ne.0 ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALIH_qu', nompro
#endif
      typenh = 4
      call utalih ( nohind, typenh, nbquto, ncmpin, motaux,
     >              adquin, adqusu,
     >              ulsort, langue, codret)
c
      if ( typind.eq.2 ) then
        adquin = adquin
      else
        adqurn = adquin
      endif
      nbvqua = 1
c
      endif
c
      endif
c
c====
c 3. Les hexaedres
c    Dans le cas suivant :
c    . Des hexaedres existent
c    . Aucun indicateur n'a ete defini sur les hexaedres
c    . Un indicateur a ete defini sur les tetraedres ou les pyramides
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. hexaedres ; codret = ', codret
#endif
c
      if ( nbheto.ne.0 .and. nbvhex.eq.0 .and.
     >     ( nbvtet.ne.0 .or. nbvpyr.ne.0 ) ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALIH_he', nompro
#endif
      typenh = 6
      call utalih ( nohind, typenh, nbheto, ncmpin, motaux,
     >              adhein, adhesu,
     >              ulsort, langue, codret)
c
      if ( typind.eq.2 ) then
        adhein = adhein
      else
        adhern = adhein
      endif
      nbvhex = 1
c
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
