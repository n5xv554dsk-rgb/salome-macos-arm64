      subroutine utmemh ( nomail, choix,
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
c    UTilitaire - MEnage du Maillage HOMARD
c    --           --        -        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   .  ch8   . nom de l'objet contenant le maillage       .
c . choix  . e   .   1    . choix du menage a faire                    .
c .        .     .        . -1 : tous les menages                      .
c .        .     .        .  0 : sauf les noeuds                       .
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
      parameter ( nompro = 'UTMEMH' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nomail
c
      integer choix
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre0
c
      character*8 nhenti
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
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
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Maillage a nettoyer : '')'
      texte(1,5) = '(''... Memorisations du deraffinement anterieur'')'
      texte(1,6) = '(''..... Influence sur les '',a)'
c
      texte(2,4) = '(''Mesh to be cleaned : '')'
      texte(2,5) = '(''... Cleaning of previous unrefinement'')'
      texte(2,6) = '(''.... Influence over '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      call gmprsx (nompro, nomail )
#endif
c
c====
c 2. recuperation des pointeurs
c====
c
c 2.1. ==> structure generale
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
c
      call utnomh ( nomail,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 3. les menages
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5))
#endif
c
      do 31 , iaux = choix , 7
c
        if ( codret.eq.0 ) then
c
        if ( iaux.eq.-1 ) then
          nhenti = nhnoeu
        elseif ( iaux.eq.0 ) then
          nhenti = nhmapo
        elseif ( iaux.eq.1 ) then
          nhenti = nharet
        elseif ( iaux.eq.2 ) then
          nhenti = nhtria
        elseif ( iaux.eq.3 ) then
          nhenti = nhtetr
        elseif ( iaux.eq.4 ) then
          nhenti = nhquad
        elseif ( iaux.eq.5 ) then
          nhenti = nhpyra
        elseif ( iaux.eq.6 ) then
          nhenti = nhhexa
        elseif ( iaux.eq.7 ) then
          nhenti = nhpent
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,6)) mess14(langue,3,iaux)
#endif
c
        call gmobal ( nhenti//'.Deraffin', codre0 )
        if ( codre0.eq.2 ) then
          call gmlboj ( nhenti//'.Deraffin', codret )
        elseif ( codre0.ne.0 ) then
          codret = 1
        endif
c
        endif
c
   31 continue
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
