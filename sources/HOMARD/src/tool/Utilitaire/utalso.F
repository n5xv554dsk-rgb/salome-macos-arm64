      subroutine utalso ( nocsol,
     >                    nbcham, nbpafo, nbprof, nblopg,
     >                    adinch, adinpf, adinpr, adinlg,
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
c    UTilitaire - ALlocation d'une SOlution
c    --           --               --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocsol .   s . char8  . nom de l'objet solution                    .
c . nbcham . e   .   1    . nombre de champs associes                  .
c . nbpafo . e   .   1    . nombre d'inf. sur les paquets de fonctions .
c . nbprof . e   .   1    . nombre de profils associes                 .
c . nblopg . e   .   1    . nombre de localisations de points de Gauss .
c . adinch .   s .   1    . adresse de l'information sur les champs    .
c . adinpf .   s .   1    . adresse de l'inf. sur paquets de fonctions .
c . adinpr .   s .   1    . adresse de l'information sur les profils   .
c . adinlg .   s .   1    . adresse de l'information sur les           .
c .        .     .        . localisations de points de Gauss           .
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
      parameter ( nompro = 'UTALSO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 nocsol
c
      integer nbcham, nbpafo, nbprof, nblopg
      integer adinch, adinpf, adinpr, adinlg
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2, codre3, codre4
      integer codre0
c
      character*08 saux08
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
      texte(1,4) = '(''Erreur en allouant '',a)'
c
      texte(2,4) = '(''Error while allocating '',a)'
c
      codret = 0
c
c====
c 2. structure generale
c====
c
      if ( codret.eq.0 ) then
c
      call gmalot ( nocsol, 'Solution', 0, iaux, codret )
c
      if ( codret.ne.0 ) then
        saux08 = 'Solution'
      endif
c
      endif
c
c====
c 3. les attributs
c====
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nocsol, 1, nbcham, codre1 )
      call gmecat ( nocsol, 2, nbpafo, codre2 )
      call gmecat ( nocsol, 3, nbprof, codre3 )
      call gmecat ( nocsol, 4, nblopg, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      if ( codret.ne.0 ) then
        saux08 = 'Attribut'
      endif
c
      endif
c
c====
c 4. les eventuelles branches
c====
c
c 4.1. ==> l'information sur les champs
c
      if ( codret.eq.0 ) then
c
      if ( nbcham.ne.0 ) then
        call gmaloj ( nocsol//'.InfoCham', ' ', nbcham, adinch, codret )
        if ( codret.ne.0 ) then
          saux08 = 'InfoCham'
        endif
      endif
c
      endif
c
c 4.2. ==> l'information sur les paquets de fonctions
c
      if ( codret.eq.0 ) then
c
      if ( nbpafo.ne.0 ) then
        call gmaloj ( nocsol//'.InfoPaFo', ' ', nbpafo, adinpf, codret )
        if ( codret.ne.0 ) then
          saux08 = 'InfoPaFo'
        endif
      endif
c
      endif
c
c 4.3. ==> l'information sur les profils
c
      if ( codret.eq.0 ) then
c
      if ( nbprof.ne.0 ) then
        call gmaloj ( nocsol//'.InfoProf', ' ', nbprof, adinpr, codret )
        if ( codret.ne.0 ) then
          saux08 = 'InfoProf'
        endif
      endif
c
      endif
c
c 4.4. ==> les localisations de points de Gauss
c
      if ( codret.eq.0 ) then
c
      if ( nblopg.ne.0 ) then
        call gmaloj ( nocsol//'.InfoLoPG', ' ', nblopg, adinlg, codret )
        if ( codret.ne.0 ) then
          saux08 = 'InfoLoPG'
        endif
      endif
c
      endif
c
c====
c 5. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nocsol )
      call gmprsx (nompro, nocsol//'.InfoCham' )
      call gmprsx (nompro, nocsol//'.InfoPaFo' )
      call gmprsx (nompro, nocsol//'.InfoProf' )
      call gmprsx (nompro, nocsol//'.InfoLoPG' )
#endif
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,4)) saux08
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
