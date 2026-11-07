      subroutine utvois ( nomail, nhvois,
     >                    voarno, vofaar, vovoar, vovofa,
     >                    ppovos, pvoiso,
     >                    nbfaar, pposif, pfacar,
     >                    ulsort, langue, codret)
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
c    UTilitaire - creation des tableaux des VOISins
c    --                                     ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   . char8  . nom de l'objet maillage homard             .
c . nhvois . es  . char8  . nom de la branche Voisins                  .
c . voarno . e   .   1    . pilotage des voisins des noeuds :          .
c .        .     .        . -1 : on detruit la table.                  .
c .        .     .        . 0 : on ne fait rien.                       .
c .        .     .        . 1 : on construit la table.                 .
c .        .     .        . 2 : on construit la table et on controle   .
c . vofaar . e   .   1    . pilotage des voisins des aretes :          .
c .        .     .        . -1 : on detruit la table.                  .
c .        .     .        . 0 : on ne fait rien.                       .
c .        .     .        . 1 : on construit la table.                 .
c .        .     .        . 2 : on construit la table et on controle   .
c . vovoar . e   .   1    . pilotage des volumes voisins des aretes :  .
c .        .     .        . -1 : on detruit la table.                  .
c .        .     .        . 0 : on ne fait rien.                       .
c .        .     .        . 1 : on construit la table.                 .
c .        .     .        . 2 : on construit la table et on controle   .
c . vovofa . e   .   1    . pilotage des volumes voisins des faces :   .
c .        .     .        . -1 : on detruit la table.                  .
c .        .     .        . 0 : on ne fait rien.                       .
c .        .     .        . 1 : on construit la table.                 .
c .        .     .        . 2 : on construit la table et on controle   .
c . ppovos .   s .   1    . adresse du pointeur des vois. des sommets  .
c . pvoiso .   s .   1    . adresse des voisins des sommets            .
c . nbfaar .  s  .   1    . nombre cumule de faces par arete           .
c . pposif .   s .   1    . adresse du pointeur des vois. des aretes   .
c . pfacar .   s .   1    . adresse des voisins des aretes             .
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
      parameter ( nompro = 'UTVOIS' )
c
#include "nblang.h"
#include "envca1.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nomail, nhvois
c
      integer voarno, vofaar, vovoar, vovofa
      integer ppovos, pvoiso
      integer nbfaar, pposif, pfacar
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhsupe, nhsups
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
      texte(1,4) = '(5x,''Mise en place des voisins.'')'
      texte(1,5) = '(a,'' voisins des '',a,'' : '',i6)'
c
      texte(2,4) = '(5x,''Neighbourhood.'')'
      texte(2,5) = '(a,'' closed to the '',a,'' : '',i6)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,4))
#endif
c
c====
c 2. Allocation de la tete des voisins.
c    Il faut le faire au depart, sinon, le programme utnomh plante.
c====
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nomail//'.Voisins', codret )
c
      if ( codret.eq.0 ) then
        call gmaloj ( nomail//'.Voisins', ' ', 0, iaux, codret )
c
      elseif ( codret.eq.1 ) then
        codret = 0
c
      else
        codret = 2
c
      endif
c
      endif
c
c====
c 3. recuperation des donnees du maillage d'entree
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. recuperation ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
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
c 4. Traitement
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Traitement ; codret', codret
#endif
c 4.1. ==> determination des aretes voisines des noeuds
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,5))
     >      mess14(langue,3,1), mess14(langue,3,-1), voarno
#endif
c
      if ( voarno.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTVGAN', nompro
#endif
c
        call utvgan ( nhvois, nhnoeu, nharet,
     >                voarno,
     >                ppovos, pvoiso,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 4.2. ==> determination des faces voisines des aretes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. faces/aretes ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,5))
     >      mess14(langue,3,8), mess14(langue,3,1), vofaar
#endif
c
      if ( vofaar.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTVGFA', nompro
#endif
c
        call utvgfa ( nhvois, nharet, nhtria, nhquad,
     >                vofaar,
     >                nbfaar, pposif, pfacar,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c 4.3. ==> reperage des volumes s'appuyant sur chaque arete
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.3. volumes/aretes ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,5))
     >      mess14(langue,3,9), mess14(langue,3,1), vovoar
#endif
c
      if ( vovoar.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTVGVA', nompro
#endif
        call utvgva ( nhvois, nharet, nhtria, nhquad,
     >                nhtetr, nhhexa, nhpyra, nhpent,
     >                vovoar,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c 4.4. ==> reperage des volumes s'appuyant sur chaque face
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.4. volumes/faces ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,5))
     >      mess14(langue,3,9), mess14(langue,3,8), vovofa
#endif
c
      if ( vovofa.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTVGVF', nompro
#endif
        call utvgvf ( nhvois, nhtria, nhquad,
     >                nhtetr, nhhexa, nhpyra, nhpent,
     >                vovofa,
     >                ulsort, langue, codret)
c
        endif
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
