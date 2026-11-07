      subroutine utvgfa ( nhvois, nharet, nhtria, nhquad,
     >                    option,
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
c     UTilitaire : VoisinaGes FAces / Aretes
c     --           -      -   -       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nhvois . e   . char8  . nom de l'objet voisinage                   .
c . nharet . e   . char8  . nom de l'objet decrivant les aretes        .
c . nhtria . e   . char8  . nom de l'objet decrivant les triangles     .
c . nhquad . e   . char8  . nom de l'objet decrivant les quadrangles   .
c . option . e   .   1    . pilotage des voisins des aretes :          .
c .        .     .        . -1 : on detruit la table.                  .
c .        .     .        . 0 : on ne fait rien.                       .
c .        .     .        . 1 : on construit la table.                 .
c .        .     .        . 2 : on construit la table et on controle   .
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
      parameter ( nompro = 'UTVGFA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      character*8 nhvois, nharet, nhtria, nhquad
c
      integer option
      integer nbfaar, pposif, pfacar
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
c
      integer nbarto, nbtrto, nbquto
      integer paretr, parequ
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
      texte(1,4) = '(5x,''Voisinage faces-aretes.'')'
      texte(1,5) = '(''Demande : '',i6)'
      texte(1,6) = '(''Mauvaise demande.'')'
c
      texte(2,4) = '(5x,''Neighbourhood faces-edges.'')'
      texte(2,5) = '(''Request : '',i6)'
      texte(2,6) = '(''Bad request.'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,5)) option
#endif
c
      codret = 0
c
c====
c 2. Controle de l'option
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Controle option ; codret =',codret
#endif
      if ( codret.eq.0 ) then
c
      if ( option.lt.-1 .or. option.gt.2 ) then
c
        write (ulsort,texte(langue,5)) option
        write (ulsort,texte(langue,6))
        codret = 2
c
      endif
c
      endif
c
c====
c 3. recuperation des donnees du maillage d'entree
c    remarque : on relit les nombres d'entites car les communs ne
c               sont pas forcement remplis
c====
c
      if ( option.eq.1 .or. option.eq.2 ) then
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nharet, 1, nbarto, codre1 )
        call gmliat ( nhtria, 1, nbtrto, codre2 )
        if ( nbtrto.ne.0 ) then
          call gmadoj ( nhtria//'.ConnDesc', paretr, iaux, codre3 )
        else
          codre3 = 0
        endif
        call gmliat ( nhquad, 1, nbquto, codre4 )
        if ( nbquto.ne.0 ) then
          call gmadoj ( nhquad//'.ConnDesc', parequ, iaux, codre5 )
        else
          codre5 = 0
        endif
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5 )
c
        endif
c
      endif
c
c====
c 4. Si on cree ou si on detruit, on commence par supprimer le graphe
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. suppression ; codret =',codret
#endif
c
      if ( option.eq.-1 .or. option.eq.1 .or. option.eq.2 ) then
c
        if ( codret.eq.0 ) then
c
        call gmobal ( nhvois//'.1D/2D', codre1 )
c
        if ( codre1.eq.0 ) then
          codret = 0
c
        elseif ( codre1.eq.1 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '.... Suppression de nhvois.1D/2D'
#endif
          call gmsgoj ( nhvois//'.1D/2D', codret )
c
        else
          codret = 2
c
        endif
c
        endif
c
      endif
c
c====
c 5. Creation
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. Creation ; codret =',codret
#endif
c
      if ( option.eq.1 .or. option.eq.2 ) then
c
c 5.1. ==> Allocation de la tete
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '.... Allocation de nhvois.1D/2D'
#endif
        call gmaloj ( nhvois//'.1D/2D' , ' ', 0, iaux, codret )
c
        endif
c
c 5.2. ==> determination des faces voisines des aretes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5.2. ==> determination ... ; codret =',codret
#endif
c
c 5.2.1. ==> comptage du nombre de faces pour chaque arete
c
        if ( codret.eq.0 ) then
c
        iaux = nbarto+1
        call gmecat ( nhvois//'.1D/2D', 1, iaux, codre1 )
        call gmaloj ( nhvois//'.1D/2D.Pointeur',
     >                ' ', iaux, pposif, codre2 )
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFAA1', nompro
#endif
        call utfaa1 ( nbarto, nbtrto, nbquto,
     >                nbarto, nbtrto, nbquto,
     >                imem(paretr), imem(parequ),
     >                nbfaar, imem(pposif) )
c
        endif
c
c 5.2.2. ==> allocation du tableau des voisines a une taille
c            egale au nombre cumule de voisines des aretes,
c            puis reperage des faces voisines
c
        if ( codret.eq.0 ) then
c
        call gmecat ( nhvois//'.1D/2D', 2, nbfaar, codre1 )
        call gmaloj ( nhvois//'.1D/2D.Table',
     >                ' ', nbfaar, pfacar, codre2 )
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFAA2', nompro
#endif
        call utfaa2 ( nbtrto, nbquto,
     >                nbtrto, nbquto,
     >                imem(paretr), imem(parequ),
     >                nbfaar, imem(pposif), imem(pfacar) )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nhvois//'.1D/2D' )
      call gmprot (nompro, nhvois//'.1D/2D.Pointeur', 1, 50 )
      call gmprot (nompro, nhvois//'.1D/2D.Table', 1, 50 )
#endif
c
        endif
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
