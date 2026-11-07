      subroutine utsex0 ( nocsol, option,
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
c    UTilitaire - Solution - EXtrusion - phase 0
c    --           -          --                -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocsol . e   . char8  . nom de l'objet solution a modifier         .
c . option . e   .    1   . option de la modification                  .
c .        .     .        . 1 : passage du 3D au 2D                    .
c .        .     .        . 2 : passage du 2D au 3D                    .
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
      parameter ( nompro = 'UTSEX0' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "op0012.h"
#include "nbutil.h"
#include "nombqu.h"
#include "nombhe.h"
c
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer option
c
      character*8 nocsol
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer tbiaux(2,3)
c
      integer edsuav, edsuap, edsaav, edsaap, nbenti
      integer nuedel
c
      integer nbcham, nbpafo, nbprof, nblopg
      integer adinch, adinpf, adinpr, adinlg
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Solution sur le domaine '',i1,''D'')'
      texte(1,6) = '(''Option de conversion '',i8,'' invalide.'')'
      texte(1,7) = '(''Il faut 1 ou 2.'')'
      texte(1,8) = '(''Nombre de champs               : '', i3)'
      texte(1,9) = '(''Nombre de paquets de fonctions : '', i3)'
c
      texte(2,4) = '(''Solution to convert for '',i1,''D'')'
      texte(2,6) = '(''Option for conversion '',i8,'' is uncorrect.'')'
      texte(2,7) = '(''1 or 2 is needed.'')'
      texte(2,8) = '(''Number of fields            : '', i3)'
      texte(2,9) = '(''Number of packs of functions: '', i3)'
c
#include "impr03.h"
c
c====
c 2. Les types MED a echanger
c====
c
      if ( option.eq.1 ) then
        tbiaux(1,1) = edhex8
        tbiaux(1,2) = edqua4
        tbiaux(1,3) = nbquad
        tbiaux(2,1) = edpen6
        tbiaux(2,2) = edtri3
        tbiaux(2,3) = nbtria
      elseif ( option.eq.2 ) then
        tbiaux(1,1) = edqua4
        tbiaux(1,2) = edhex8
        tbiaux(1,3) = nbhexa
        tbiaux(2,1) = edtri3
        tbiaux(2,2) = edpen6
        tbiaux(2,3) = nbpent
      else
        write (ulsort,texte(langue,6)) option
        write (ulsort,texte(langue,7))
        codret = 1
      endif
c
#ifdef _DEBUG_HOMARD_
10000 format(43('='))
      write (ulsort,10000)
      write (ulsort,90002) 'nbquac', nbquac, nbquto
      write (ulsort,90002) 'nbheac', nbheac, nbheto
      write (ulsort,90002) 'nbtria', nbtria
      write (ulsort,90002) 'nbquad', nbquad
      write (ulsort,90002) 'nbhexa', nbhexa
      write (ulsort,90002) 'nbpent', nbpent
      write (ulsort,texte(langue,4)) 1+fp0012(option)
      write (ulsort,90002) 'tbiaux', tbiaux
      call gmprsx (nompro//' - nocsol', nocsol )
cgn      call gmprsx ('nocsol.InfoCham', nocsol//'.InfoCham' )
cgn      call gmprsx (' ', '%%%%%%18' )
cgn      call gmprsx ('nocsol.InfoPaFo', nocsol//'.InfoPaFo' )
      if ( option.eq.22 ) then
        call gmprsx (' ', '%%%%%%22' )
        call gmprsx (' ', '%%Fo0054' )
        call gmprsx (' ', '%%%%%%20' )
        call gmprsx (' ', '%%%%%%20.ValeursR' )
        call gmprsx (' ', '%%%%%%21' )
        call gmprsx (' ', '%%%%%%21.ValeursR' )
      elseif ( option.eq.11 ) then
        call gmprsx (' ', '%%%%%%25' )
        call gmprsx (' ', '%%Fo0059' )
        call gmprsx (' ', '%%%%%%28' )
        call gmprsx (' ', '%%%%%%28.ValeursR' )
        call gmprsx (' ', '%%%%%%30' )
        call gmprsx (' ', '%%%%%%30.ValeursR' )
      endif
cgn      call gmprsx (nompro, nocsol//'.InfoProf' )
      write (ulsort,10000)
#endif
c
c====
c 3. recuperation des pointeurs lies a la solution
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. recuperation ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call utcaso ( nocsol,
     >              nbcham, nbpafo, nbprof, nblopg,
     >              adinch, adinpf, adinpr, adinlg,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) nbcham
      write (ulsort,texte(langue,9)) nbpafo
#endif
c
      endif
c
c====
c 4. Pour chacun des deux types de mailles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. chacun des deux types ; codret', codret
#endif
c
      do 40 , nuedel = 1 , 2
c
c 4.1. ==> Les types de mailles a echanger
c
        edsuav = tbiaux(nuedel,1)
        edsuap = tbiaux(nuedel,2)
        edsaav = tbiaux(fp0012(nuedel),1)
        edsaap = tbiaux(fp0012(nuedel),2)
        nbenti = tbiaux(nuedel,3)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'Passage de', edsuav,' a', edsuap
      write (ulsort,90015) 'Type associe de', edsaav,' a', edsaap
      write (ulsort,90002) 'nbenti', nbenti
#endif
c
c 4.2. ==> exploration des paquets de fonctions
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. paquets ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSEX1', nompro
#endif
        call utsex1 ( nbpafo, smem(adinpf),
     >                edsuav, edsuap, edsaav, edsaap, nbenti,
     >                ulsort, langue, codret )
c
        endif
c
c 4.3. ==> exploration des champs
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.3. champs ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSEX3', nompro
#endif
        call utsex3 ( nbcham, smem(adinch),
     >                edsuav, edsuap, edsaav, edsaap, nbenti,
     >                ulsort, langue, codret )
c
        endif
c
   40 continue
c
c====
c 5. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
cgn      write (ulsort,10000)
      write (ulsort,texte(langue,4)) 1+option
      call gmprsx (nompro, nocsol )
      call gmprsx (nompro, nocsol//'.InfoCham' )
      call gmprsx (nompro, nocsol//'.InfoPaFo' )
      call gmprsx (nompro, nocsol//'.InfoProf' )
cgn      write (ulsort,10000)
      endif
#endif
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
