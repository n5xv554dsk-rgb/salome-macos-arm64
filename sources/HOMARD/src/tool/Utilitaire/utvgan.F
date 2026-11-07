      subroutine utvgan ( nhvois, nhnoeu, nharet,
     >                    option,
     >                    ppovos, pvoiso,
     >                    ulsort, langue, codret)
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
c    UTilitaire - VoisinaGe Aretes-Noeuds
c    --           -      -  -      -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nhvois . e   . char8  . nom de l'objet voisinage                   .
c . nhnoeu . e   . char8  . nom de l'objet decrivant les noeuds        .
c . nharet . e   . char8  . nom de l'objet decrivant les aretes        .
c . option . e   .   1    . pilotage des voisins des noeuds :          .
c .        .     .        . -1 : on detruit la table.                  .
c .        .     .        . 0 : on ne fait rien.                       .
c .        .     .        . 1 : on construit la table.                 .
c .        .     .        . 2 : on construit la table et on controle   .
c . ppovos .   s .   1    . adresse du pointeur des vois. des sommets  .
c . pvoiso .   s .   1    . adresse des voisins des sommets            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme                               .
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
      parameter ( nompro = 'UTVGAN' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "nombno.h"
#include "nombar.h"
c
c 0.3. ==> arguments
c
      character*8 nhvois, nhnoeu, nharet
c
      integer option
      integer ppovos, pvoiso
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2, codre3
      integer codre0
c
      integer psomar
      integer nvosom
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
      texte(1,4) = '(''Voisinage aretes-noeuds.'')'
      texte(1,5) = '(''Demande : '',i6)'
      texte(1,6) = '(''Mauvaise demande.'')'
      texte(1,7) = '(''. Objet '',a,'' : '',a)'
c
      texte(2,4) = '(''Neighbourhood edges-nodes.'')'
      texte(2,5) = '(''Request : '',i6)'
      texte(2,6) = '(''Bad request.'')'
      texte(2,7) = '(''. Objet '',a,'' : '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,5)) option
      write (ulsort,texte(langue,7)) 'nhnoeu', nhnoeu
      call gmprsx (nompro, nhnoeu )
      write (ulsort,texte(langue,7)) 'nharet', nharet
      call gmprsx (nompro, nharet )
      call gmprot (nompro, nharet//'.ConnDesc', 1, min(2*nbarto,50) )
      write (ulsort,texte(langue,7)) 'nhvois', nhvois
      call gmprsx (nompro, nhvois )
      call gmprsx (nompro, nhvois//'.0D/1D' )
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. recuperation ; codret =',codret
#endif
c
      if ( option.eq.1 .or. option.eq.2 ) then
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nhnoeu, 1, nbnoto, codre1 )
        call gmliat ( nharet, 1, nbarto, codre2 )
        call gmadoj ( nharet//'.ConnDesc', psomar, iaux, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
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
          call gmobal ( nhvois//'.0D/1D', codre1 )
c
          if ( codre1.eq.0 ) then
            codret = 0
c
          elseif ( codre1.eq.1 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '.... Suppression de nhvois.0D/1D'
#endif
            call gmsgoj ( nhvois//'.0D/1D', codret )
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
      write (ulsort,*) '.... Allocation de nhvois.0D/1D'
#endif
c
        call gmaloj ( nhvois//'.0D/1D' , ' ', 0, iaux, codret )
c
        endif
c
c 5.2. ==> determination des aretes voisines des noeuds
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5.2. ==> determination ... ; codret =',codret
#endif
c
c 5.2.1. ==> comptage du nombre d'aretes pour chaque noeud
c
        if ( codret.eq.0 ) then
c
        iaux = nbnoto+1
        call gmecat ( nhvois//'.0D/1D', 1, iaux, codre1 )
        call gmaloj ( nhvois//'.0D/1D.Pointeur',
     >                ' ', iaux, ppovos, codre2 )
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTVGA1', nompro
#endif
c
        call utvga1 ( nbnoto, nbarto, nvosom,
     >                imem(psomar), imem(ppovos) )
c
        endif
c
c 5.2.2. ==> allocation du tableau des voisines a une taille
c          egale au nombre cumule de voisines des noeuds,
c          puis reperage des aretes voisines
c
        if ( codret.eq.0 ) then
c
        call gmecat ( nhvois//'.0D/1D', 2, nvosom, codre1 )
        call gmaloj ( nhvois//'.0D/1D.Table',
     >                ' ', nvosom, pvoiso, codre2 )
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
cgn      call gmprsx (nompro, nhvois//'.0D/1D' )
cgn      call gmprot (nompro, nhvois//'.0D/1D.Pointeur', 1, 50 )
        write (ulsort,texte(langue,3)) 'UTVGA2', nompro
#endif
c
        call utvga2 ( nbnoto, nbarto, nvosom,
     >                imem(psomar), imem(ppovos), imem(pvoiso) )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nhvois//'.0D/1D' )
      call gmprot (nompro, nhvois//'.0D/1D.Pointeur', 1, 50 )
      call gmprot (nompro, nhvois//'.0D/1D.Table', 1, 50 )
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
