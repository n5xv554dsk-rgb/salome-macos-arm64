      subroutine utvgva ( nhvois, nharet, nhtria, nhquad,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
     >                    option,
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
c     UTilitaire : VoisinaGes Volumes / Aretes
c     --           -      -   -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nhvois . e   . char8  . nom de l'objet voisinage                   .
c . nharet . e   . char8  . nom de l'objet decrivant les aretes        .
c . nhtria . e   . char8  . nom de l'objet decrivant les triangles     .
c . nhquad . e   . char8  . nom de l'objet decrivant les quadrangles   .
c . nhtetr . e   . char8  . nom de l'objet decrivant les tetraedres    .
c . nhhexa . e   . char8  . nom de l'objet decrivant les hexaedres     .
c . nhpyra . e   . char8  . nom de l'objet decrivant les pyramides     .
c . nhpent . e   . char8  . nom de l'objet decrivant les pentaedres    .
c . option . e   .   1    . pilotage des volumes voisins des faces :   .
c .        .     .        . -1 : on detruit la table.                  .
c .        .     .        . 0 : on ne fait rien.                       .
c .        .     .        . 1 : on construit la table.                 .
c .        .     .        . 2 : on construit la table et on controle   .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . non nul : probleme                         .
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
      parameter ( nompro = 'UTVGVA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nhvois, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
c
      integer option
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer adaux
      integer codre1, codre2, codre3
      integer codre0
      integer nbarto
      integer nbtrto
      integer nbquto
      integer nbteto, nbtecf, nbteca
      integer nbheto, nbhecf, nbheca
      integer nbpyto, nbpycf, nbpyca
      integer nbpeto, nbpecf, nbpeca
      integer phettr, paretr
      integer phetqu, parequ
      integer phette, ptrite, pcotrt, parete
      integer phethe, pquahe, pcoquh, parehe
      integer phetpy, pfacpe, pcofay, parepy
      integer phetpe, pfacpy, pcofap, parepe
      integer adptte, adpthe, adptpy, adptpe
      integer adtate, adtahe, adtapy, adtape
      integer nbtear, nbhear, nbpyar, nbpear
c
      character*8 saux08
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
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
      texte(1,4) = '(''Voisinage volumes-aretes.'')'
      texte(1,5) = '(''Demande : '',i6)'
      texte(1,6) = '(''Mauvaise demande.'')'
c
      texte(2,4) = '(''Neighbourhood volumes-edges.'')'
      texte(2,5) = '(''Request : '',i6)'
      texte(2,6) = '(''Bad request.'')'
c
#include "impr03.h"
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. recuperation ; codret =',codret
#endif
c
      if ( option.eq.1 .or. option.eq.2 ) then
c
c 3.1. ==> Les tetraedres
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nhtetr, 1, nbteto, codre1 )
        call gmliat ( nhtetr, 2, nbteca, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nbteto, nbteca', nbteto, nbteca
#endif
c
        if ( nbteto.gt.0 ) then
c
          iaux = 26
          if ( nbteca.gt.0 ) then
            iaux = iaux*31
          endif
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
          call utad02 (   iaux, nhtetr,
     >                  phette, ptrite,   jaux,  jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux, pcotrt,   jaux,
     >                    jaux,   jaux, parete,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
c 3.2. ==> Les hexaedres
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nhhexa, 1, nbheto, codre1 )
        call gmliat ( nhhexa, 2, nbheca, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nbheto, nbheca', nbheto, nbheca
#endif
c
        if ( nbheto.gt.0 ) then
c
          iaux = 26
          if ( nbheca.gt.0 ) then
            iaux = iaux*31
          endif
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
          call utad02 (   iaux, nhhexa,
     >                  phethe, pquahe,   jaux,  jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux, pcoquh,   jaux,
     >                    jaux,   jaux, parehe,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
c 3.3. ==> Les pyramides
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nhpyra, 1, nbpyto, codre1 )
        call gmliat ( nhpyra, 2, nbpyca, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nbpyto, nbpyca', nbpyto, nbpyca
#endif
c
        if ( nbpyto.gt.0 ) then
c
          iaux = 26
          if ( nbpyca.gt.0 ) then
            iaux = iaux*31
          endif
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
          call utad02 (   iaux, nhpyra,
     >                  phetpy, pfacpy,   jaux,  jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux, pcofay,   jaux,
     >                    jaux,   jaux, parepy,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
c 3.4. ==> Les pentaedres
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nhpent, 1, nbpeto, codre1 )
        call gmliat ( nhpent, 2, nbpeca, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nbpeto, nbpeca', nbpeto, nbpeca
#endif
c
        if ( nbpeto.gt.0 ) then
c
          iaux = 26
          if ( nbpeca.gt.0 ) then
            iaux = iaux*31
          endif
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
          call utad02 (   iaux, nhpent,
     >                  phetpe, pfacpe,   jaux,  jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux, pcofap,   jaux,
     >                    jaux,   jaux, parepe,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
c 3.5. ==> Bilan
c
        if ( codret.eq.0 ) then
c
        nbtecf = nbteto - nbteca
        nbhecf = nbheto - nbheca
        nbpycf = nbpyto - nbpyca
        nbpecf = nbpeto - nbpeca
c
        endif
c
c 3.6. ==> Les triangles si besoin
c
        if ( codret.eq.0 ) then
c
        if ( nbteto.gt.0 .or. nbpycf.gt.0 ) then
c
          call gmliat ( nhtria, 1, nbtrto, codre0 )
c
          codret = abs(codre0)
c
          iaux = 2
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTAD02_tr', nompro
#endif
          call utad02 (   iaux, nhtria,
     >                  phettr, paretr,   jaux,  jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
c 3.7. ==> Les quadangles si besoin
c
        if ( codret.eq.0 ) then
c
        if ( nbheto.gt.0 .or. nbpecf.gt.0 ) then
c
          call gmliat ( nhquad, 1, nbquto, codre0 )
c
          codret = abs(codre0)
c
          iaux = 2
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTAD02_qu', nompro
#endif
          call utad02 (   iaux, nhquad,
     >                  phetqu, parequ,   jaux,  jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
c 3.8. ==> Nombre d'aretes
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nharet, 1, nbarto, codre0 )
c
        codret = abs(codre0)
c
        endif
c
      endif
c
c====
c 4. Si on cree ou si on detruit, on commence par supprimer les graphes
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. suppression ; codret =',codret
#endif
c
      if ( option.eq.-1 .or. option.eq.1 .or. option.eq.2 ) then
c
        do 41 , iaux = 1 , 4
c
          if ( codret.eq.0 ) then
c
          saux08 = '.xxx/Are'
          if ( iaux.eq.1 ) then
            saux08(2:4) = 'Tet'
          elseif ( iaux.eq.2 ) then
            saux08(2:4) = 'Hex'
          elseif ( iaux.eq.3 ) then
            saux08(2:4) = 'Pyr'
          else
            saux08(2:4) = 'Pen'
          endif
c
          call gmobal ( nhvois//saux08, codre1 )
c
          if ( codre1.eq.0 ) then
            codret = 0
c
          elseif ( codre1.eq.1 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '.... Suppression de nhvois'//saux08
#endif
            call gmsgoj ( nhvois//saux08, codret )
c
          else
            codret = 2
c
          endif
c
          endif
c
   41   continue
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
        do 51 , iaux = 1 , 4
c
          if ( codret.eq.0 ) then
c
          saux08 = '.xxx/Are'
          if ( iaux.eq.1 ) then
            saux08(2:4) = 'Tet'
            jaux = nbteto
          elseif ( iaux.eq.2 ) then
            saux08(2:4) = 'Hex'
            jaux = nbheto
          elseif ( iaux.eq.3 ) then
            saux08(2:4) = 'Pyr'
            jaux = nbpyto
          else
            saux08(2:4) = 'Pen'
            jaux = nbpeto
          endif
c
          if ( jaux.gt.0 ) then
#ifdef _DEBUG_HOMARD_
            write (ulsort,*) '.... Allocation de nhvois'//saux08
#endif
c
            call gmaloj ( nhvois//saux08 , ' ', 0, kaux, codre1 )
            kaux = nbarto+1
            call gmecat ( nhvois//saux08, 1, kaux, codre2 )
            call gmaloj ( nhvois//saux08//'.Pointeur',
     >                    ' ', kaux, adaux, codre3 )
c
            codre0 = min ( codre1, codre2, codre3 )
            codret = max ( abs(codre0), codret,
     >                     codre1, codre2, codre3 )
c
            if ( iaux.eq.1 ) then
              adptte = adaux
            elseif ( iaux.eq.2 ) then
              adpthe = adaux
            elseif ( iaux.eq.3 ) then
              adptpy = adaux
            else
              adptpe = adaux
            endif
c
          endif
c
          endif
c
   51   continue
c
c 5.2. ==> Longueur des tableaux de voisinages
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5.2. Longueur ; codret =',codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTVGV2', nompro
#endif
        call utvgv2 ( nbarto, nbtrto, nbquto,
     >                nbteto, nbtecf, nbteca,
     >                nbheto, nbhecf, nbheca,
     >                nbpyto, nbpycf, nbpyca,
     >                nbpeto, nbpecf, nbpeca,
     >                imem(paretr),
     >                imem(parequ),
     >                imem(ptrite), imem(pcotrt), imem(parete),
     >                imem(pquahe), imem(pcoquh), imem(parehe),
     >                imem(pfacpy), imem(pcofay), imem(parepy),
     >                imem(pfacpe), imem(pcofap), imem(parepe),
     >                nbtear, imem(adptte),
     >                nbhear, imem(adpthe),
     >                nbpyar, imem(adptpy),
     >                nbpear, imem(adptpe),
     >                ulsort, langue, codret )
c
        endif
c
c 5.3. ==> Allocations
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5.3. Allocations ; codret =',codret
#endif
c
        if ( codret.eq.0 ) then
c
        do 53 , iaux = 1 , 4
c
          if ( codret.eq.0 ) then
c
          saux08 = '.xxx/Are'
          if ( iaux.eq.1 ) then
            saux08(2:4) = 'Tet'
            jaux = nbtear
          elseif ( iaux.eq.2 ) then
            saux08(2:4) = 'Hex'
            jaux = nbhear
          elseif ( iaux.eq.3 ) then
            saux08(2:4) = 'Pyr'
            jaux = nbpyar
          else
            saux08(2:4) = 'Pen'
            jaux = nbpear
          endif
c
          if ( jaux.gt.0 ) then
#ifdef _DEBUG_HOMARD_
            write (ulsort,*) '.... Allocation de nhvois'//saux08
#endif
c
            call gmecat ( nhvois//saux08, 2, jaux, codre1 )
            call gmaloj ( nhvois//saux08//'.Table',
     >                    ' ', jaux, adaux, codre2 )
c
            codre0 = min ( codre1, codre2 )
            codret = max ( abs(codre0), codret,
     >                     codre1, codre2 )
c
            if ( iaux.eq.1 ) then
              adtate = adaux
            elseif ( iaux.eq.2 ) then
              adtahe = adaux
            elseif ( iaux.eq.3 ) then
              adtapy = adaux
            else
              adtape = adaux
            endif
c
          endif
c
          endif
c
   53   continue
c
        endif
c
c 5.4. ==> Determination des voisinages
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5.4. Determination ; codret =',codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTVGV3', nompro
#endif
        call utvgv3 ( nbarto, nbtrto, nbquto,
     >                nbteto, nbtecf, nbteca,
     >                nbheto, nbhecf, nbheca,
     >                nbpyto, nbpycf, nbpyca,
     >                nbpeto, nbpecf, nbpeca,
     >                imem(paretr),
     >                imem(parequ),
     >                imem(ptrite), imem(pcotrt), imem(parete),
     >                imem(pquahe), imem(pcoquh), imem(parehe),
     >                imem(pfacpy), imem(pcofay), imem(parepy),
     >                imem(pfacpe), imem(pcofap), imem(parepe),
     >                nbtear, imem(adptte), imem(adtate),
     >                nbhear, imem(adpthe), imem(adtahe),
     >                nbpyar, imem(adptpy), imem(adtapy),
     >                nbpear, imem(adptpe), imem(adtape),
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        saux08 = '.xxx/Are'
        if ( nbteto.gt.0 ) then
          saux08(2:4) = 'Tet'
          call gmprsx(nompro//saux08//' - pt',
     >                nhvois//saux08//'.Pointeur')
          call gmprsx(nompro//saux08//' - ta', nhvois//saux08//'.Table')
        endif
        if ( nbheto.gt.0 ) then
          saux08(2:4) = 'Hex'
          call gmprsx(nompro//saux08//' - pt',
     >                nhvois//saux08//'.Pointeur')
          call gmprsx(nompro//saux08//' - ta', nhvois//saux08//'.Table')
        endif
        if ( nbpyto.gt.0 ) then
          saux08(2:4) = 'Pyr'
          call gmprsx(nompro//saux08//' - pt',
     >                nhvois//saux08//'.Pointeur')
          call gmprsx(nompro//saux08//' - ta', nhvois//saux08//'.Table')
        endif
        if ( nbpeto.gt.0 ) then
          saux08(2:4) = 'Pen'
          call gmprsx(nompro//saux08//' - pt',
     >                nhvois//saux08//'.Pointeur')
          call gmprsx(nompro//saux08//' - ta', nhvois//saux08//'.Table')
        endif
#endif
        endif
c
      endif
c
c====
c 6. La fin
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
