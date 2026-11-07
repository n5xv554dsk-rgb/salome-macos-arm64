      subroutine utvgvf ( nhvois, nhtria, nhquad,
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
c    UTilitaire - VoisinaGe Volumes-Face
c    --           -      -  -       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nhvois . e   . char8  . nom de l'objet voisinage                   .
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
      parameter ( nompro = 'UTVGVF' )
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
      character*8 nhvois, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
c
      integer option
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nbfac(2)
      integer codre0
      integer codre1, codre2, codre3, codre4
c
      integer nbtrto, nbquto
      integer nbteto, nbheto, nbpyto, nbpeto
      integer nbteca, nbheca, nbpyca, nbpeca
      integer nbtecf, nbhecf, nbpycf, nbpecf
      integer ptrite, phette, parete, pfilte
      integer pquahe, phethe, parehe, pfilhe, adhes2
      integer pfacpy, phetpy, parepy, pfilpy
      integer pfacpe, phetpe, parepe, pfilpe, adpes2
      integer advotq, advotr, advoqu
      integer lgpptq, adpptq
      integer lgpptr, adpptr, nupptr
      integer lgppqu, adppqu, nuppqu
c
      character*9 suff(4)
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
c 1.1. ==> messages
c
      texte(1,4) = '(''Voisinage volumes-faces.'')'
      texte(1,5) = '(''Demande : '',i6)'
      texte(1,6) = '(''Mauvaise demande.'')'
      texte(1,7) = '(''Nombre de '',a,'' : '',i10)'
      texte(1,8) = '(''Voisinage '',a,''/ '',a)'
c
      texte(2,4) = '(''Neighbourhood volumes-faces.'')'
      texte(2,5) = '(''Request : '',i6)'
      texte(2,6) = '(''Bad request.'')'
      texte(2,7) = '(''Number of '',a,'' : '',i10)'
      texte(2,8) = '(''Neighbourhood '',a,''/ '',a)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,5)) option
#endif
c
c 1.2. ==> initialisations
c
      suff(1) = '.Vol/Tri'
      suff(2) = '.Vol/Qua'
      suff(3) = '.PyPe/Tri'
      suff(4) = '.PyPe/Qua'
c
      codret = 0
c
c====
c 2. Controle de l'option
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Controle option ; codret', codret
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
      write (ulsort,90002) '3. recuperation ; codret', codret
#endif
c
      if ( option.eq.1 .or. option.eq.2 ) then
c
c 3.1. ==> nombre d'entites volumiques
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nhtetr, 1, nbteto, codre1 )
        call gmliat ( nhpyra, 1, nbpyto, codre2 )
        call gmliat ( nhhexa, 1, nbheto, codre3 )
        call gmliat ( nhpent, 1, nbpeto, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
        call gmliat ( nhtetr, 2, nbteca, codre1 )
        call gmliat ( nhpyra, 2, nbpyca, codre2 )
        call gmliat ( nhhexa, 2, nbheca, codre3 )
        call gmliat ( nhpent, 2, nbpeca, codre4 )
c
        codre0 = min ( codre1, codre2, codre3, codre4 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4 )
c
        nbtecf = nbteto - nbteca
        nbpycf = nbpyto - nbpyca
        nbhecf = nbheto - nbheca
        nbpecf = nbpeto - nbpeca
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) mess14(langue,3,3), nbteto
      write (ulsort,texte(langue,7)) mess14(langue,3,5), nbpyto
      write (ulsort,texte(langue,7)) mess14(langue,3,6), nbheto
      write (ulsort,texte(langue,7)) mess14(langue,3,7), nbpeto
#endif
c
c 3.2. ==> nombre de triangles/quadrangles
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Etape 2.2 ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nhtria, 1, nbtrto, codre1 )
        call gmliat ( nhquad, 1, nbquto, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) mess14(langue,3,2), nbtrto
      write (ulsort,texte(langue,7)) mess14(langue,3,4), nbquto
#endif
c
c 3.3. ==> adresses liees aux volumes
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Etape 2.3 ; codret', codret
#endif
c
        if ( nbteto.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
          iaux = 6
          if ( nbteca.gt.0 ) then
            iaux = iaux*31
          endif
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTAD02_te', nompro
#endif
          call utad02 (   iaux, nhtetr,
     >                  phette, ptrite, pfilte, jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux, parete,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
        if ( nbpyto.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
ccc      call gmprsx ('nhpyra dans '//nompro,nhpyra)
          iaux = 6
          if ( nbpyca.gt.0 ) then
            iaux = iaux*31
          endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_py', nompro
#endif
          call utad02 (   iaux, nhpyra,
     >                  phetpy, pfacpy, pfilpy, jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux, parepy,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
        if ( nbheto.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
cgn          call gmprsx ('nhhexa dans '//nompro,nhhexa)
          iaux = 6
          if ( nbheca.gt.0 ) then
            iaux = iaux*31
          endif
          if ( nbpyto.ne.0 ) then
            call gmobal ( nhhexa//'.InfoSup2', codre1 )
            if ( codre1.eq.2 ) then
              iaux = iaux*17
            elseif ( codre1.ne.0 ) then
              codret = 2
            endif
          endif
c
          endif
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_he', nompro
#endif
          call utad02 (   iaux, nhhexa,
     >                  phethe, pquahe, pfilhe, jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux, adhes2,
     >                    jaux,   jaux, parehe,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
        if ( nbpeto.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
cgn          call gmprsx ('nhpent dans '//nompro,nhpent)
          iaux = 6
          if ( nbpeca.gt.0 ) then
            iaux = iaux*31
          endif
          if ( nbpyto.ne.0 ) then
            call gmobal ( nhpent//'.InfoSup2', codre1 )
            if ( codre1.eq.2 ) then
              iaux = iaux*17
            elseif ( codre1.ne.0 ) then
              codret = 2
            endif
          endif
c
          endif
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_pe', nompro
#endif
          call utad02 (   iaux, nhpent,
     >                  phetpe, pfacpe, pfilpe, jaux,
     >                    jaux,   jaux,   jaux,
     >                    jaux,   jaux, adpes2,
     >                    jaux,   jaux, parepe,
     >                  ulsort, langue, codret )
c
          endif
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
      write (ulsort,90002) '4. suppression ; codret', codret
#endif
c
      if ( option.eq.-1 .or. option.eq.1 .or. option.eq.2 ) then
c
c 4.1. ==> Destruction des anciennes structures
c
        do 41 , iaux = 1 , 4
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,*) 'Destruction eventuelle de ',suff(iaux)
#endif
          if ( codret.eq.0 ) then
c
          call gmobal ( nhvois//suff(iaux), codre1 )
c
          if ( codre1.eq.0 ) then
            codret = 0
c
          elseif ( codre1.eq.1 ) then
            call gmsgoj ( nhvois//suff(iaux), codret )
c
          elseif ( codre1.eq.2 ) then
            call gmlboj ( nhvois//suff(iaux), codret )
c
          else
            codret = 2
c
          endif
c
          endif
c
 41     continue
c
c 4.2. ==> Attributs
c
        if ( codret.eq.0 ) then
c
        iaux = 0
        call gmecat ( nhvois , 1, iaux, codre1 )
        call gmecat ( nhvois , 2, iaux, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
      endif
c
c====
c 5. Allocation des voisinages Vol/Tri et Vol/Qua
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Etape 5 ; codret', codret
#endif
c
      if ( option.eq.1 .or. option.eq.2 ) then
c
        nbfac(1) = nbtrto
        nbfac(2) = nbquto
c
        do 50 , iaux = 1 , 2
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) 'Creation de ',suff(iaux)
#endif
c
c 5.1. ==> Allocation de la structure
c
          if ( codret.eq.0 ) then
c
          jaux = 2*nbfac(iaux)
          call gmaloj ( nhvois//suff(iaux) , ' ',
     >                  jaux, advotq, codret )
c
          if ( iaux.eq.1 ) then
            advotr = advotq
          else
            advoqu = advotq
          endif
c
          endif
c
c 5.2. ==> A priori aucun voisin
c
          if ( codret.eq.0 ) then
c
          kaux = advotq + jaux - 1
          do 52 , jaux = advotq , kaux
            imem(jaux) = 0
   52     continue
c
          endif
c
  50    continue
c
      endif
c
c====
c 6. Allocation des voisinages PyPe/Tri et PyPe/Qua
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Etape 6 ; codret', codret
#endif
c
      if ( option.eq.1 .or. option.eq.2 ) then
c
        do 60 , iaux = 1 , 2
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) 'Creation de ',suff(iaux+2)
#endif
c
c 6.1. ==> Allocation de la structure
c
          if ( codret.eq.0 ) then
c
          if ( iaux.eq.1 ) then
            lgpptq = 4*nbpyto + 2*nbpeto
          else
            lgpptq = nbpyto + 3*nbpeto
          endif
          jaux = 2*lgpptq
          call gmecat ( nhvois , 1, jaux, codre1 )
          call gmaloj ( nhvois//suff(iaux+2), ' ',
     >                  jaux, adpptq, codre2 )
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2 )
c
          if ( iaux.eq.1 ) then
            adpptr = adpptq
            lgpptr = lgpptq
          else
            adppqu = adpptq
            lgppqu = lgpptq
          endif
c
          endif
c
c 6.2. ==> A priori aucun voisin
c
          if ( codret.eq.0 ) then
c
          kaux = adpptq + jaux - 1
          do 62 , jaux = adpptq , kaux
            imem(jaux) = 0
   62     continue
c
          endif
c
   60   continue
c
      endif
c
c====
c 7. Creation des voisinages Tet/Tri et Hex/Qua
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Etape 7 ; codret', codret
#endif
c
      if ( option.eq.1 .or. option.eq.2 ) then
c
c 7.1. ==> determination des tetraedres voisins des triangles
c
        if ( nbteto.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,8)) mess14(langue,3,2),
     >                                   mess14(langue,3,3)
          write (ulsort,*) 'Creation de ',suff(1)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTTETR', nompro
#endif
          call uttetr ( option,
     >                  nbtrto, nbteto, nbtecf,
     >                  imem(ptrite), imem(phette), imem(pfilte),
     >                  imem(advotr),
     >                  ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
cgn          call gmprsx (nompro,nhvois//suff(1))
cgn       call gmprot (nompro, nhvois//suff(1), 1, nbtrto*2 )
       call gmprot (nompro, nhvois//suff(1), 1, min(10,nbtrto*2) )
#endif
c
          endif
c
        endif
c
c 7.2. ==> determination des hexaedres voisins des quadrangles
c
        if ( nbheto.ne.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,8)) mess14(langue,3,4),
     >                                   mess14(langue,3,6)
          write (ulsort,*) 'Creation de ',suff(2)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTHEQU', nompro
#endif
          call uthequ ( option,
     >                  nbquto, nbheto, nbhecf, nbpyto, nbpycf,
     >                  imem(pquahe), imem(phethe), imem(pfilhe),
     >                  imem(adhes2),
     >                  imem(pfacpy),
     >                  imem(advoqu),
     >                  ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
cgn          call gmprsx (nompro, nhvois//suff(2) )
cgn          call gmprot (nompro, nhvois//suff(2), 1, nbquto*2 )
          call gmprot (nompro, nhvois//suff(2), 1, min(20,nbquto*2) )
#endif
c
          endif
c
        endif
c
      endif
c
c====
c 8. Creation des voisinages PyPe/Tri et PyPe/Qua
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Etape 8 ; codret', codret
      write (ulsort,90002) 'nbpyto', nbpyto
      write (ulsort,90002) 'nbpyca', nbpyca
      write (ulsort,90002) 'nbpeto', nbpeto
      write (ulsort,90002) 'nbpeca', nbpeca
#endif
c
      nupptr = 0
      nuppqu = 0
c
      if ( option.eq.1 .or. option.eq.2 ) then
c
c 8.1. ==> Determination des pyramides voisines
c
        if ( nbpyto.ne.0 ) then
c
c 8.1.1. ==> Determination des pyramides voisines des triangles
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,8)) mess14(langue,3,2),
     >                                   mess14(langue,3,5)
#endif
c
          iaux = 5
          jaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPPQT-PY_TR', nompro
#endif
          call utppqt ( option, nbtrto, nbpyto, nbpycf,
     >                  iaux, jaux,
     >                  imem(pfacpy), imem(phetpy),
     >                  imem(advotr), lgpptr, imem(adpptr), nupptr,
     >                  ulsort, langue, codret )
c
          endif
#ifdef _DEBUG_HOMARD_
cgn      call gmprsx (nompro,'MaVo000h.Vol/Qua')
cgn      call gmprsx (nompro,'MaVo000h.Vol/Qua', 1, 30)
cc      call gmprsx (nompro,nhvois//'.PyPe/Qua')
#endif
c
c 8.1.2. ==> Determination des pyramides voisines des quadrangles
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,8)) mess14(langue,3,4),
     >                                   mess14(langue,3,5)
#endif
c
          iaux = 5
          jaux = 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPPQT-PY_QU', nompro
#endif
          call utppqt ( option, nbquto, nbpyto, nbpycf,
     >                  iaux, jaux,
     >                  imem(pfacpy), imem(phetpy),
     >                  imem(advoqu), lgppqu, imem(adppqu), nuppqu,
     >                  ulsort, langue, codret )
c
          endif
#ifdef _DEBUG_HOMARD_
cgn      call gmprsx (nompro,nhvois//'.Vol/Qua')
      call gmprot (nompro,nhvois//'.Vol/Qua', 1, 30)
cgn      call gmprsx (nompro,nhvois//'.PyPe/Qua')
      call gmprot (nompro,nhvois//'.PyPe/Qua', 1, 30)
#endif
c
        endif
c
c 8.2. ==> Determination des pentaedres voisins
c
        if ( nbpeto.ne.0 ) then
c
c 8.2.1. ==> Determination des pentaedres voisins des triangles
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,8)) mess14(langue,3,2),
     >                                   mess14(langue,3,7)
#endif
c
          iaux = 7
          jaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPPQT-PE_TR', nompro
#endif
          call utppqt ( option, nbtrto, nbpeto, nbpecf,
     >                  iaux, jaux,
     >                  imem(pfacpe), imem(phetpe),
     >                  imem(advotr), lgpptr, imem(adpptr), nupptr,
     >                  ulsort, langue, codret )
c
          endif
c
c 8.2.2. ==> Determination des pentaedres voisins des quadrangles
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,8)) mess14(langue,3,4),
     >                                   mess14(langue,3,7)
#endif
c
          iaux = 7
          jaux = 4
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTPPQT-PE_QU', nompro
#endif
          call utppqt ( option, nbquto, nbpeto, nbpecf,
     >                  iaux, jaux,
     >                  imem(pfacpe), imem(phetpe),
     >                  imem(advoqu), lgppqu, imem(adppqu), nuppqu,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
      endif
c
c====
c 9. la fin
c====
c
#ifdef _DEBUG_HOMARD_
cgn      call gmprsx (nompro,nhvois)
      if ( codret.eq.0 ) then
cgn      call gmprsx (nompro,nhvois//'.Vol/Tri')
cgn      call gmprsx (nompro,nhvois//'.PyPe/Tri')
cgn      call gmprsx (nompro,nhvois//'.Vol/Qua')
      call gmprot (nompro,nhvois//'.Vol/Qua', 1, 30)
cgn      call gmprsx (nompro,nhvois//'.PyPe/Qua')
      call gmprot (nompro,nhvois//'.PyPe/Qua', 1, 30)
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
