      subroutine decpte ( pilraf, pilder,
     >                    decare, decfac,
     >                    hettri, hetqua,
     >                    tritet, hettet,
     >                    quahex, hethex,
     >                    facpyr, hetpyr,
     >                    facpen, hetpen,
     >                    ulsort, langue, codret )
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
c traitement des DEcisions - ComPTagE
c                --          -  --  -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . pilraf . e   .   1    . pilotage du raffinement                    .
c .        .     .        . -1 : raffinement uniforme                  .
c .        .     .        .  0 : pas de raffinement                    .
c .        .     .        .  1 : raffinement libre                     .
c .        .     .        .  2 : raff. libre homogene en type d'element.
c . pilder . e   .   1    . pilotage du deraffinement                  .
c .        .     .        . 0 : pas de deraffinement                   .
c .        .     .        . 1 : deraffinement libre                    .
c .        .     .        . -1 : deraffinement uniforme                .
c . decare . e   .0:nbarto. decisions des aretes                       .
c . decfac . e   . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'DECPTE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envada.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer pilraf, pilder
      integer decare(0:nbarto), decfac(-nbquto:nbtrto)
      integer hettri(nbtrto)
      integer hetqua(nbquto)
      integer hettet(nbteto), tritet(nbtecf,4)
      integer hethex(nbheto), quahex(nbhecf,6)
      integer hetpyr(nbpyto), facpyr(nbpycf,5)
      integer hetpen(nbpeto), facpen(nbpecf,5)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer narde2, narra2
      integer ntrde4, ntrra4
      integer nqude4, nqura4
      integer ntede8, ntera8
      integer nhede8, nhera8
      integer npyder, npyraf
      integer npeder, nperaf
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) =
     > '(/,7x,''Nombre de '',a,'' a decouper en '',i1,''  : '',i10)'
      texte(1,5) =
     > '(/,7x,''Nombre de '',a,'' a reactiver      : '',i10)'
      texte(1,6) =
     > '(/,7x,''Nombre de '',a,'' a decouper       : '',i10)'
c
      texte(2,4) =
     > '(/,7x,''Number of '',a,'' to divide into '',i1,'' : '',i10)'
      texte(2,5) =
     > '(/,7x,''Number of '',a,'' to reactivate    : '',i10)'
      texte(2,6) =
     > '(/,7x,''Number of '',a,'' to divide  : '',i10)'
c
      codret = 0
c
#include "impr03.h"
c
c====
c 2. decompte des entites a decouper et a supprimer et impressions
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DECPT0', nompro
#endif
      call decpt0 ( decare, decfac,
     >              hettri, hetqua,
     >              tritet, hettet,
     >              quahex, hethex,
     >              facpyr, hetpyr,
     >              facpen, hetpen,
     >              narde2, narra2,
     >          ntrde4, ntrra4,
     >          nqude4, nqura4,
     >          ntede8, ntera8,
     >          nhede8, nhera8,
     >          npyder, npyraf,
     >          npeder, nperaf,
     >          ulsort, langue, codret )
c
c====
c 3. impressions
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. impressions ; codret', codret
#endif
c
c 3.1. ==> raffinement
c
#ifdef _DEBUG_HOMARD_
      if ( pilraf.ne.-100 ) then
#else
      if ( pilraf.ne.0 ) then
#endif
c
        if ( nbteto.ne.0 ) then
          write(ulsort,texte(langue,4)) mess14(langue,3,3), 8, ntera8
        endif
        if ( nbheto.ne.0 ) then
          write(ulsort,texte(langue,4)) mess14(langue,3,6), 8, nhera8
        endif
        if ( nbpyto.ne.0 ) then
          write(ulsort,texte(langue,6)) mess14(langue,3,5), npyraf
        endif
        if ( nbpeto.ne.0 ) then
          write(ulsort,texte(langue,4)) mess14(langue,3,7), 8, nperaf
        endif
        if ( nbquto.ne.0 ) then
          write(ulsort,texte(langue,4)) mess14(langue,3,4), 4, nqura4
        endif
        if ( nbtrto.ne.0 ) then
          write(ulsort,texte(langue,4)) mess14(langue,3,2), 4, ntrra4
        endif
        write(ulsort,texte(langue,4)) mess14(langue,3,1), 2, narra2
c
      endif
c
c 3.2. ==> deraffinement
c
      if ( nbiter.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      if ( pilder.ne.-100 ) then
#else
      if ( pilder.ne.0 ) then
#endif
c
        if ( nbteto.ne.0 ) then
          write(ulsort,texte(langue,5)) mess14(langue,3,3), ntede8
        endif
        if ( nbheto.ne.0 ) then
          write(ulsort,texte(langue,5)) mess14(langue,3,6), nhede8
        endif
        if ( nbpyto.ne.0 ) then
          write(ulsort,texte(langue,5)) mess14(langue,3,5), npyder
        endif
        if ( nbpeto.ne.0 ) then
          write(ulsort,texte(langue,5)) mess14(langue,3,7), npeder
        endif
        if ( nbquto.ne.0 ) then
          write(ulsort,texte(langue,5)) mess14(langue,3,4), nqude4
        endif
        if ( nbtrto.ne.0 ) then
          write(ulsort,texte(langue,5)) mess14(langue,3,2), ntrde4
        endif
        write(ulsort,texte(langue,5)) mess14(langue,3,1), narde2
c
      endif
c
      endif
c
      write(ulsort,*) ' '
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
