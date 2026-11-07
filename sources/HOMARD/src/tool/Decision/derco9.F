      subroutine derco9 ( niveau,
     >                    decare,
     >                    hetare, filare,
     >                    aretri, nivtri,
     >                    arequa, nivqua,
     >                    quahex, coquhe,
     >                    facpyr, cofapy,
     >                    facpen, cofape,
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
c traitement des DEcisions - Raffinement : COntamination - option 9
c                --          -             --                     -
c Application de la regle des ecarts de niveau a travers les volumes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . niveau . e   .    1   . niveau en cours d'examen                   .
c . decare . es  . nbarto . decisions des aretes                       .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . aretri . e   . nbtrto . numeros des 3 aretes des triangles         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . arequa . e   . nbquto . numeros des 4 aretes des quadrangles       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
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
      parameter ( nompro = 'DERCO9' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer niveau
      integer decare(0:nbarto)
      integer hetare(nbarto), filare(nbarto)
      integer aretri(nbtrto,3), nivtri(nbtrto)
      integer arequa(nbquto,4), nivqua(nbquto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5)
      integer facpen(nbpecf,5), cofape(nbpecf,5)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer larete, laret0
      integer lehexa, lepent, lapyra
      integer listar(12)
c
      integer nbmess
      parameter ( nbmess = 30 )
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
#include "impr03.h"
c
#include "derco1.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,12)) niveau
#endif
c
c    Transfert via les volumes ayant des quadrangles comme faces
c    Si une fille de l'une de ses aretes est a couper, le volume
c    doit l'etre entierement : on le declare par ses aretes.
c====
c 3. Les hexaedres
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '3. Les hexaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      do 31 , lehexa = 1 , nbheto
c
        jaux = nivqua(quahex(lehexa,1)) + 1
c
        if ( jaux.eq.niveau ) then
c
          call utarhe ( lehexa,
     >                  nbquto, nbhecf,
     >                  arequa, quahex, coquhe,
     >                  listar )
c
          do 311 , iaux = 1 , 12
c
            larete = listar(iaux)
            if ( mod(hetare(larete),10).eq.2 ) then
              if ( decare(filare(larete)  ).eq.2 .or.
     >             decare(filare(larete)+1).eq.2 ) then
                do 3111 , jaux = 1 , 12
                  laret0 = listar(jaux)
                  if ( mod(hetare(laret0),10).eq.2 ) then
                    if ( decare(laret0).eq.-1 ) then
                      decare(laret0) = 0
                    endif
                  elseif ( mod(hetare(laret0),10).eq.0 ) then
                    decare(laret0) = 2
                  endif
 3111           continue
                goto 31
              endif
            endif
c
  311     continue
c
        endif
c
   31 continue
c
      endif
c
c====
c 4. Les pentaedres
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '4. Les pentaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      do 41 , lepent = 1 , nbpeto
c
        jaux = nivqua(facpen(lepent,3)) + 1
c
        if ( jaux.eq.niveau ) then
c
          call utarpe ( lepent,
     >                  nbquto, nbpecf,
     >                  arequa, facpen, cofape,
     >                  listar )
c
          do 411 , iaux = 1 , 9
c
            larete = listar(iaux)
            if ( mod(hetare(larete),10).eq.2 ) then
              if ( decare(filare(larete)  ).eq.2 .or.
     >             decare(filare(larete)+1).eq.2 ) then
                do 4111 , jaux = 1 , 12
                  laret0 = listar(jaux)
                  if ( mod(hetare(laret0),10).eq.2 ) then
                    if ( decare(laret0).eq.-1 ) then
                      decare(laret0) = 0
                    endif
                  elseif ( mod(hetare(laret0),10).eq.0 ) then
                    decare(laret0) = 2
                  endif
 4111           continue
                goto 41
              endif
            endif
c
  411     continue
c
        endif
c
   41 continue
c
      endif
c
c====
c 5. Les pyramides
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '5. Les pyramides ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      do 51 , lapyra = 1 , nbpyto
c
        jaux = nivqua(facpyr(lapyra,5)) + 1
c
        if ( jaux.eq.niveau ) then
c
          call utarpy ( lapyra,
     >                  nbtrto, nbpycf,
     >                  aretri, facpyr, cofapy,
     >                  listar )

          do 511 , iaux = 1 , 8
c
            larete = listar(iaux)
            if ( mod(hetare(larete),10).eq.2 ) then
              if ( decare(filare(larete)  ).eq.2 .or.
     >             decare(filare(larete)+1).eq.2 ) then
                do 5111 , jaux = 1 , 12
                  laret0 = listar(jaux)
                  if ( mod(hetare(laret0),10).eq.2 ) then
                    if ( decare(laret0).eq.-1 ) then
                      decare(laret0) = 0
                    endif
                  elseif ( mod(hetare(laret0),10).eq.0 ) then
                    decare(laret0) = 2
                  endif
 5111           continue
                goto 51
              endif
            endif
c
  511     continue
c
        endif
c
   51 continue
c
      endif
c
c====
c 6. la fin
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
