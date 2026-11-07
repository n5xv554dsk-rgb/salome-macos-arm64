      subroutine utad41 ( nospec,
     >                    nparrc, nptrrc, npqurc,
     >                    npterc, npherc, npperc, nppyrc,
     >                    adarrc, adtrrc, adqurc,
     >                    adterc, adherc, adperc, adpyrc,
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
c Copyright 2016 EDF
c ______________________________________________________________________
c
c    UTilitaire - ADresses - phase 41
c    --           --               --
c ______________________________________________________________________
c   Recuperation des adresses des tableaux pour les recollements
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nospec . e   . char8  . nom de l'objet memorisant les specificites .
c . nparrc .  s  .   1    . nombre de paires d'aretes recollees        .
c . nptrrc .  s  .   1    . nombre de paires de triangles recolles     .
c . npqurc .  s  .   1    . nombre de paires de quadrangles recolles   .
c . npterc .  s  .   1    . nombre de paires de tetraedres recolles    .
c . npherc .  s  .   1    . nombre de paires d'hexaedres recolles      .
c . npperc .  s  .   1    . nombre de paires de pentaedres recolles    .
c . nppyrc .  s  .   1    . nombre de paires de pyramides recollees    .
c . adarrc .  s  .   1    . paires d'aretes recollees                  .
c . adtrrc .  s  .   1    . paires de triangles recolles               .
c . adqurc .  s  .   1    . paires de quadrangles recolles             .
c . adterc .  s  .   1    . paires des tetra. voisins faces a recoller .
c . adherc .  s  .   1    . paires des hexa. voisins faces a recoller  .
c . adperc .  s  .   1    . paires des penta. voisins faces a recoller .
c . adpyrc .  s  .   1    . paires des pyram. voisines faces a recoller.
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'UTAD41' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 nospec
c
      integer nparrc, nptrrc, npqurc
      integer npterc, npherc, npperc, nppyrc
      integer adarrc, adtrrc, adqurc
      integer adterc, adherc, adperc, adpyrc
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7
      integer codre0
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
      texte(1,4) = '(''Adresses relatives aux recollements'')'
c
      texte(2,4) = '(''Adresses for entities'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
c====
c 2. recuperation des nombres et des adresses
c====
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,nospec)
#endif
c
c 2.1. ==> Nombre de paires
c
      call gmliat ( nospec, 1, nparrc, codre1 )
      call gmliat ( nospec, 2, nptrrc, codre2 )
      call gmliat ( nospec, 3, npqurc, codre3 )
      call gmliat ( nospec, 4, npterc, codre4 )
      call gmliat ( nospec, 5, npherc, codre5 )
      call gmliat ( nospec, 6, npperc, codre6 )
      call gmliat ( nospec, 7, nppyrc, codre7 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      if ( codret.ne.0 ) then
      write (ulsort,90002) 'codre1-7',
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7
      endif
c
c 2.2. ==> Adresses
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( nospec//'.Tab1', adarrc, iaux, codre1 )
      call gmadoj ( nospec//'.Tab2', adtrrc, iaux, codre2 )
      call gmadoj ( nospec//'.Tab3', adqurc, iaux, codre3 )
      call gmadoj ( nospec//'.Tab4', adterc, iaux, codre4 )
      call gmadoj ( nospec//'.Tab5', adherc, iaux, codre5 )
      call gmadoj ( nospec//'.Tab6', adperc, iaux, codre6 )
      call gmadoj ( nospec//'.Tab7', adpyrc, iaux, codre7 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
c
      if ( codret.ne.0 ) then
      write (ulsort,90002) 'codre1-7',
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprot (nompro,nospec//'.Tab1',1,2*nparrc)
      call gmprot (nompro,nospec//'.Tab2',1,2*nptrrc)
      call gmprot (nompro,nospec//'.Tab3',1,2*npqurc)
      call gmprot (nompro,nospec//'.Tab4',1,(nptrrc+npqurc)*3/2)
      call gmprot (nompro,nospec//'.Tab5',1,(nptrrc+npqurc)*3/2)
      call gmprot (nompro,nospec//'.Tab6',1,(nptrrc+npqurc)*3/2)
      call gmprot (nompro,nospec//'.Tab7',1,(nptrrc+npqurc)*3/2)
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
