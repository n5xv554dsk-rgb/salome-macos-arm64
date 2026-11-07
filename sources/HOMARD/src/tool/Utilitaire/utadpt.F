      subroutine utadpt ( nobjet, choix,
     >                    nombre, lgtabl,
     >                    adpoin, adtail, adtabl,
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
c     UTilitaire : ADresses d'un objet de type PtTabxxx
c     --           --                          - -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nobjet . e   . char8  . nom de l'objet PtTabxxx                    .
c . choix  . e   .    1   . option de la recherche :                   .
c .        .     .        . 2 : les attributs                          .
c .        .     .        . 3 : les adresses                           .
c . nombre .   s .    1   . le tableau Pointeur est (0:nombre)         .
c . lgtabl .   s .    1   . longueur commune a Taille et Table         .
c . adpoin .   s .    1   . adresse de Pointeur                        .
c . adtail .   s .    1   . adresse de Taille                          .
c . adtabl .   s .    1   . adresse de Table                           .
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
      parameter ( nompro = 'UTADPT' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*(*) nobjet
c
      integer choix
      integer nombre, lgtabl
      integer adpoin, adtail, adtabl
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codre1, codre2
      integer codre0
      integer iaux
c
      character*8 nomobj
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
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'choix',  choix
#endif
c
c 1.2. ==> Nom court de l'objet
c
      call gmnomc ( nobjet, nomobj, codret )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nomobj )
      call gmprsx (nompro, nomobj//'.Pointeur' )
      call gmprsx (nompro, nomobj//'.Taille' )
      call gmprsx (nompro, nomobj//'.Table' )
#endif
c
c====
c 2. Attributs
c====
c
      if ( mod(choix,2).eq.0 ) then
c
        call gmliat ( nomobj, 1, nombre, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nombre', nombre
#endif
c
        if ( codret.eq.0 ) then
c
        if ( nombre.gt.0 ) then
          call gmliat ( nomobj, 2, lgtabl, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'lgtabl', lgtabl
#endif
        endif
c
        endif
c
      endif
c
c====
c 3. Adresses
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Adresses ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nomobj, 1, nombre, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nombre', nombre
#endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( mod(choix,3).eq.0 .and. nombre.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
        call gmadoj ( nomobj//'.Pointeur', adpoin, iaux, codre1 )
        call gmadoj ( nomobj//'.Table' , adtabl, iaux, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call gmobal ( nomobj//'.Taille', codre0 )
        if ( codre0.eq.2 ) then
          call gmadoj ( nomobj//'.Taille', adtail, iaux, codret )
        elseif ( codre0.ne.0 ) then
          codret = 2
        endif
c
        endif
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
