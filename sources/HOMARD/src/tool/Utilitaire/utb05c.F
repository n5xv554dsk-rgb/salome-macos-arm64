      subroutine utb05c ( choix,
     >                    typenh, nbento, nbencf, nbenca,
     >                    coonoe, somare,
     >                    aretri, arequa,
     >                    hetvol, facvol, cofavo, arevol,
     >                    nbiter,
     >                    nbeexa, tbiau1, tbiau2, tabaur, tabau2,
     >                    ulbila,
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
c    UTilitaire - Bilan - option 05 - etape c
c    --           -              --         -
c ______________________________________________________________________
c
c but : controle de la qualite des volumes
c  remarque : utb05c et utb19c sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   .   1    . choix du traitement                        .
c .        .     .        . 0 : creation et affichage des histogrammes .
c .        .     .        . 2 : sortie de la qualite des triangles     .
c .        .     .        . 3 : sortie de la qualite des tetraedres    .
c .        .     .        . 4 : sortie de la qualite des quadrangles   .
c .        .     .        . 6 : sortie de la qualite des hexaedres     .
c . typenh . e   .    1   . variantes                                  .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . nbento . e   .    1   . nombre d'entites                           .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hetvol . e   . nbento . historique de l'etat des volumes           .
c . facvol . e   .nbencf**. numeros des faces des volumes              .
c . cofavo . e   .nbencf**. code des faces des volumes                 .
c . arevol . e   .nbenca**. code des aretes des volumes                .
c . nbeexa .  s  .   1    . nombre d'entites examinees                 .
c . tbiau1 .  a  .    *   . liste des entites examinees                .
c . tbiau2 .  a  .    *   . tableau entier auxiliaire                  .
c . tabaur .  a  .    *   . qualite des entites                        .
c . tabau2 .  a  .    *   . qualite des entites                        .
c . nbiter . e   .   1    . numero de l'iteration courante             .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB05C' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpe.h"
#include "nombpy.h"
#include "envca1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
      double precision tabaur(*)
      double precision tabau2(*)
c
      integer choix
      integer typenh, nbento, nbencf, nbenca
c
      integer somare(2,nbarto)
      integer aretri(nbtrto,3), arequa(nbquto,4)
      integer hetvol(nbento)
      integer facvol(nbencf,*), cofavo(nbencf,*), arevol(nbenca,*)
      integer nbiter
      integer nbeexa, tbiau1(*), tbiau2(*)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nbvoto
c
      double precision daux1, daux2, daux3
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. titre
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''. Pour les'',i10,1x,a)'
      texte(1,5) = '(3x,''Qualite '',a,'' des '',a,'' : '',g12.5)'
      texte(1,6) = '(''Type d''''entite inconnu :'',i10)'
      texte(1,7) = '(''Nombre d''''entites examinees :'',i10)'
      texte(1,8) = '(''Nombre de '',a,'' de qualite infinie'',i10)'
c
      texte(2,4) = '(''. For the'',i10,1x,a)'
      texte(2,5) = '(3x,''Quality '',a,'' of '',a,'' : '',g12.5)'
      texte(2,6) = '(''Unknown entity type :'',i10)'
      texte(2,7) = '(''Number of examined entities :'',i10)'
      texte(2,8) = '(''Nombre de '',a,'' de qualite infinie'',i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbento, mess14(langue,3,typenh)
#endif
c
      codret = 0
c
      nbvoto = nbteto + nbpyto + nbheto + nbpeto
c
      nbeexa = 0
c
c====
c 2. tetraedres
c====
c
      if ( typenh.eq.3 ) then
c
        do 21 , iaux = 1 , nbteto
c
          if ( mod(hetvol(iaux),100).eq.0 ) then
c
            nbeexa = nbeexa + 1
            tbiau1(nbeexa) = iaux
c
            jaux = iaux
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTQTET', nompro
#endif
            call utqtet ( jaux, daux1, daux2, daux3,
     >                    coonoe, somare, aretri,
     >                    facvol, cofavo, arevol )
c
            tabaur(nbeexa) = daux1
            tabau2(nbeexa) = daux2
c
          endif
c
   21   continue
c
c====
c 3. pyramides
c====
c
      elseif ( typenh.eq.5 ) then
c
        do 31 , iaux = 1 , nbpyto
c
          if ( mod(hetvol(iaux),100).eq.0 ) then
c
            nbeexa = nbeexa + 1
            tbiau1(nbeexa) = iaux
c
            jaux = iaux
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTQPYR', nompro
#endif
            call utqpyr ( jaux, daux1, daux2, daux3,
     >                    coonoe, somare, aretri,
     >                    facvol, cofavo, arevol )
c
            tabaur(nbeexa) = daux1
            tabau2(nbeexa) = daux2
c
          endif
c
   31   continue
c
c====
c 4. hexaedres
c====
c
      elseif ( typenh.eq.6 ) then
c
        do 41 , iaux = 1 , nbheto
c
          if ( mod(hetvol(iaux),100).eq.0 ) then
c
            nbeexa = nbeexa + 1
            tbiau1(nbeexa) = iaux
c
            jaux = iaux
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTQHEX', nompro
#endif
            call utqhex (   jaux,  daux1, daux2, daux3,
     >                    coonoe, somare, arequa,
     >                    facvol, cofavo, arevol )
c
            tabaur(nbeexa) = daux1
            tabau2(nbeexa) = daux2
c
          endif
c
   41   continue
c
c====
c 5. pentaedres
c====
c
      elseif ( typenh.eq.7 ) then
c
        do 51 , iaux = 1 , nbpeto
c
          if ( mod(hetvol(iaux),100).eq.0 ) then
c
            nbeexa = nbeexa + 1
            tbiau1(nbeexa) = iaux
c
            jaux = iaux
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTQPEN', nompro
#endif
            call utqpen ( jaux, daux1, daux2, daux3,
     >                    coonoe, somare, arequa,
     >                    facvol, cofavo, arevol )
c
            tabaur(nbeexa) = daux1
            tabau2(nbeexa) = daux2
c
          endif
c
   51   continue
c
c====
c 6. probleme
c====
c
      else
c
        write (ulsort,texte(langue,6)) typenh
        codret = 1
c
      endif
c
c====
c 7. impression sur la sortie standard et sur un fichier a exploiter
c    par xmgrace
c====
c
      if ( codret.eq.0 ) then
c
      if ( choix.eq.0 ) then
c
        if ( nbeexa.gt.0 ) then
c
          if ( typenh.eq.3 .or. typenh.eq.6 ) then
            iaux = 12
          elseif ( typenh.eq.5 .or. typenh.eq.7 ) then
            iaux = 2
          endif
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTB05B', nompro
#endif
          call utb05b ( iaux, typenh, nbeexa, tabaur, tabau2,
     >                  nbiter, rafdef, nbvoto,
     >                  tbiau2,
     >                  ulbila,
     >                  ulsort, langue, codret )
c
        endif
c
      endif
c
      endif
c
c====
c 8. la fin
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
