      subroutine utnvaf ( nombre, laface,
     >                    aretri, arequa, posifa,
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
c   UTilitaire : Nombre de faces Voisins des Aretes d'une Face
c   --           -               -           -            -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nombre .   s .   4    . nombre de faces voisines de chaque arete   .
c . laface . e   .   1    . numero de la face a examiner               .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'UTNVAF' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nombre(4), laface
      integer aretri(nbtrto,3), arequa(nbquto,4)
      integer posifa(0:nbarto)
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer larete(4), nbaret
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Examen du '',a,i10)'
      texte(1,5) = '(''Aretes            :'',4i10)'
      texte(1,6) = '(''Nombre de voisins :'',4i10)'
c
      texte(2,4) = '(''Examination of '',a,''#'',i10)'
      texte(2,5) = '(''Edges                :'',4i10)'
      texte(2,6) = '(''Number of neighbours :'',4i10)'
c
#ifdef _DEBUG_HOMARD_
      if ( laface.gt.0 ) then
        iaux = 2
      else
        iaux = 4
      endif
      write (ulsort,texte(langue,4)) mess14(langue,1,iaux), abs(laface)
#endif
c
c 1.2. ==> depart
c
      codret = 0
c
c====
c 2. traitement
c====
c
      if ( laface.gt.0 ) then
        nbaret = 3
        larete(1) = aretri(laface,1)
        larete(2) = aretri(laface,2)
        larete(3) = aretri(laface,3)
      else
        nbaret = 4
        larete(1) = arequa(-laface,1)
        larete(2) = arequa(-laface,2)
        larete(3) = arequa(-laface,3)
        larete(4) = arequa(-laface,4)
      endif
c
      do 20 , iaux = 1 , nbaret
        nombre(iaux) = posifa(larete(iaux)) - posifa(larete(iaux)-1)
   20 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) (larete(iaux), iaux = 1, nbaret)
      write (ulsort,texte(langue,6)) (nombre(iaux), iaux = 1, nbaret)
#endif
c
c====
c 3. la fin
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
