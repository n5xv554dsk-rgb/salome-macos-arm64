      subroutine utconf ( nbarto, nbtrto, nbquto,
     >                    nbteto, nbheto, nbpyto, nbpeto,
     >                    nbteca, nbheca, nbpyca, nbpeca,
     >                    nbtecf, nbhecf, nbpycf, nbpecf,
     >                    hetare,
     >                    hettri, aretri,
     >                    hetqua, arequa,
     >                    hettet, tritet, cotrte,
     >                    hethex, quahex, coquhe,
     >                    hetpyr, facpyr, cofapy,
     >                    hetpen, facpen, cofape,
     >                    optnco, optimp,
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
c    UTilitaire - verification de la CONFormite du maillage
c    --                              ----
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . optnco . e   .   1    . option des non-conformites :               .
c .        .     .        . 0 : le maillage doit etre 100% conforme    .
c .        .     .        . 1 : au minimum 2 aretes non coupees par fac.
c .        .     .        . 2 : 1 seul noeud pendant par arete         .
c .        .     .        . -1 : le maillage doit etre 100% conforme   .
c .        .     .        . -2 : 1 seule arete coupee par maille 2D    .
c . optimp . e   .   1    . option d'impression des non-conformites :  .
c .        .     .        . 0 : pas d'impression                       .
c .        .     .        . non nul : impression                       .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : pb. de conformite sur les triangles    .
c .        .     .        . 3 : pb. de conformite sur les tetraedres   .
c .        .     .        . 4 : pb. de conformite sur les quadrangles  .
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
      parameter ( nompro = 'UTCONF' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbarto, nbtrto, nbquto
      integer nbteto, nbheto, nbpyto, nbpeto
      integer nbteca, nbheca, nbpyca, nbpeca
      integer nbtecf, nbhecf, nbpycf, nbpecf
      integer hetare(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer hettet(nbteto), tritet(nbtecf,4), cotrte(nbtecf,4)
      integer hethex(nbheto), quahex(nbhecf,6), coquhe(nbhecf,6)
      integer hetpyr(nbpyto), facpyr(nbpycf,5), cofapy(nbpycf,5)
      integer hetpen(nbpeto), facpen(nbpecf,5), cofape(nbpecf,5)
      integer optnco, optimp
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nbtrnc, nbqunc
      integer nbtenc, nbhenc, nbpync, nbpenc
      integer entite, letria, lequad
      integer larete, etat, bilanc
      integer iaux, jaux
      integer listar(12)
      integer nbard2, nbarde
      integer nbtrd2, nbtrd4
      integer nbqud3, nbqud4
c
      integer nbmess
      parameter ( nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. impression
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
     >'(''Les mailles doivent avoir au maximum 1 arete coupee.'')'
      texte(1,5) = '(''Le maillage doit etre 100% conforme.'')'
      texte(1,6) = texte(1,5)
      texte(1,7) =
     >'(''Les mailles doivent avoir au minimum 2 aretes non coupees.'')'
      texte(1,8) =
     > '(''Les aretes actives peuvent avoir un noeud pendant.'')'
      texte(1,9) =
     > '(/,''Le maillage a plus d''''un point de non-conformite.'')'
      texte(1,10) =
     > '(/,''Les '',a,''n''''ont pas de probleme de non-conformite.'')'
      texte(1,11) =
     > '(/,''ATTENTION : le maillage n''''est pas conforme.'')'
      texte(1,12) = '(''Le '',a,i10,'' a un probleme de conformite.'')'
      texte(1,13) =
     > '(2x,a,i1,'' : numero = '',i10,'', etat = '',i4)'
      texte(1,14) =
     > '(''Nombre de '',a,'' actifs a problemes  : '',i10,/)'
      texte(1,15) = '(''Son etat vaut '',i10)'
      texte(1,16) = '(''Nombre de '',a,'' : '',i10)'
      texte(1,20) = '(''Examen du '',a,i10)'
c
      texte(2,4) = '(''Meshes whould have at max 1 cut edge.'')'
      texte(2,5) = '(''Mesh should be 100% conformal.'')'
      texte(2,6) = texte(2,5)
      texte(2,7) = '(''Meshes should have at min 2 non cut edges.'')'
      texte(2,8) = '(''Active edges could have one hanging node.'')'
      texte(2,9) = '(/,''Mesh contains more than 1 hanging node.'')'
      texte(2,10) = '(/,''No conformity problem with '', a)'
      texte(2,11) = '(/,''CAUTION : mesh contains hanging nodes.'')'
      texte(2,12) =
     > '(''The active '',a,'' # '',i10,'' has a conformity problem'')'
      texte(2,13) =
     > '(2x,a,i1,'' : # '',i10,'', state = '',i4)'
      texte(2,14) =
     > '(''Number of active '',a,'' with problems : '',i10,/)'
      texte(2,15) = '(''Its state is equal to '',i10)'
      texte(2,16) = '(''Number of '',a,'' : '',i10)'
      texte(2,20) = '(''Examination of the'',a,i10)'
c
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
       write(ulsort,texte(langue,6+optnco))
#endif
c
#ifdef _DEBUG_HOMARD_
       write(ulsort,texte(langue,16)) mess14(langue,3,2), nbtrto
       write(ulsort,texte(langue,16)) mess14(langue,3,4), nbquto
       write(ulsort,texte(langue,16)) mess14(langue,3,3), nbteto
       write(ulsort,texte(langue,16)) mess14(langue,3,5), nbpyto
       write(ulsort,texte(langue,16)) mess14(langue,3,6), nbheto
       write(ulsort,texte(langue,16)) mess14(langue,3,7), nbpeto
#endif
c
c====
c 2. verification de la conformite des triangles
c====
#ifdef _DEBUG_HOMARD_
       write(ulsort,90002) '2. verif triangles, codret', codret
#endif
c
      if ( nbtrto.ne.0 ) then
c
      nbtrnc = 0
c
      do 20 , entite = 1 , nbtrto
c
        etat = mod (hettri(entite),10)
c
        if ( etat.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
       write(ulsort,texte(langue,20)) mess14(langue,1,2), entite
#endif
c
c 2.1. ==> Decompte du nombre d'aretes actives
c
          nbard2 = 0
          nbarde = 0
          do 21 , jaux = 1 , 3
            iaux = mod (hetare(aretri(entite,jaux)),10)
            if ( iaux.eq.2 ) then
              nbard2 = nbard2 + 1
            elseif ( iaux.ne.0 ) then
              nbarde = nbarde + 1
            endif
   21     continue
          bilanc = max ( nbard2, nbarde )
cgn          print *,mess14(langue,1,1), entite, ':',nbard2, nbarde
c
c 2.2. ==> S'il y a au moins une arete inactive, precision pour le cas
c          non conforme
c
          if ( optnco.ne.0 .and. bilanc.ge.1 ) then
c
c 2.2.1. ==> optnco = 1 : autorise 1 seule arete coupee par maille
c
            if ( optnco.eq.1 ) then
c
              if ( nbard2.le.1 .and. nbarde.eq.0 ) then
                bilanc = 0
              endif
c
c 2.2.2. ==> optnco = 2 : autorise 1 seul noeud pendant par arete
c
            else
c
              if ( nbarde.eq.0 ) then
                bilanc = 0
              endif
c
            endif
c
          endif
cgn          print *,mess14(langue,1,3), entite, ':',bilanc
c
c 2.3. ==> Bilan avec impression eventuelle
c
          if ( bilanc.ne.0 ) then
            nbtrnc = nbtrnc + 1
            if ( optimp.ne.0 ) then
              write(ulsort,texte(langue,12)) mess14(langue,1,2),
     >                                      entite
              write(ulsort,texte(langue,15)) hettri(entite)
              do 23 , iaux = 1 , 3
                larete = aretri(entite,iaux)
                write(ulsort,texte(langue,13)) mess14(langue,2,1),
     >                                  iaux, larete, hetare(larete)
   23         continue
            endif
          endif
c
        endif
c
   20 continue
c
      if ( nbtrnc.ne.0 ) then
        codret = 2
#ifdef _DEBUG_HOMARD_
        if ( optimp.ne.0 ) then
#else
        if ( ulsort.ne.0 ) then
#endif
          if ( optnco.eq.0 ) then
            write(ulsort,texte(langue,11))
          else
            write(ulsort,texte(langue,9))
          endif
          write(ulsort,texte(langue,14)) mess14(langue,3,2), nbtrnc
        endif
#ifdef _DEBUG_HOMARD_
      else
        write(ulsort,texte(langue,10)) mess14(langue,3,2)
#endif
      endif
c
      endif
c
c====
c 3. verification de la conformite des quadrangles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. verif quadrangles ; codret', codret
#endif
c
      if ( nbquto.ne.0 ) then
c
      nbqunc = 0
c
      do 30 , entite = 1 , nbquto
c
        etat = mod ( hetqua(entite),100)
c
        if ( etat.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
       write(ulsort,texte(langue,20)) mess14(langue,1,4), entite
#endif
c
c 3.1. ==> Decompte du nombre d'aretes actives
c
          nbard2 = 0
          nbarde = 0
          do 31 , jaux = 1 , 4
            iaux = mod (hetare(arequa(entite,jaux)),10)
            if ( iaux.eq.2 ) then
              nbard2 = nbard2 + 1
            elseif ( iaux.ne.0 ) then
              nbarde = nbarde + 1
            endif
   31     continue
          bilanc = max ( nbard2, nbarde )
cgn          print *,mess14(langue,1,1), entite, ':',nbard2, nbarde
c
c 3.2. ==> S'il y a au moins une arete inactive, precision pour le cas
c          non conforme
c
          if ( optnco.ne.0 .and. bilanc.ge.1 ) then
c
c 3.2.1. ==> optnco = 1 : au maximum 2 aretes coupees
c
            if ( optnco.eq.1 ) then
c
              if ( nbard2.le.2 .and. nbarde.eq.0 ) then
                bilanc = 0
              endif
c
c 3.2.2. ==> optnco = 2 : autorise 1 seul noeud pendant par arete
c
            else
c
              if ( nbarde.eq.0 ) then
                bilanc = 0
              endif
c
            endif
c
          endif
cgn          print *,mess14(langue,1,3), entite, ':',bilanc
c
c 3.3. ==> Bilan avec impression eventuelle
c
          if ( bilanc.ne.0 ) then
            nbqunc = nbqunc + 1
            if ( optimp.ne.0 ) then
              write(ulsort,texte(langue,12)) mess14(langue,1,4),
     >                                      entite
              write(ulsort,texte(langue,15)) hetqua(entite)
              do 33 , iaux = 1 , 4
                larete = arequa(entite,iaux)
                write(ulsort,texte(langue,13)) mess14(langue,2,1),
     >                                  iaux, larete, hetare(larete)
   33         continue
            endif
          endif
c
        endif
c
   30 continue
c
      if ( nbqunc.ne.0 ) then
        codret = 4
#ifdef _DEBUG_HOMARD_
        if ( optimp.ne.0 ) then
#else
        if ( ulsort.ne.0 ) then
#endif
          if ( optnco.eq.0 ) then
            write(ulsort,texte(langue,11))
          else
            write(ulsort,texte(langue,9))
          endif
          write(ulsort,texte(langue,14)) mess14(langue,3,4), nbqunc
        endif
#ifdef _DEBUG_HOMARD_
      else
        write(ulsort,texte(langue,10)) mess14(langue,3,4)
#endif
      endif
c
      endif
c
c====
c 4. verification de la conformite des tetraedres
c    On ne controle pas pour l'option "1 noeud pendant" car c'est pris
c    en compte par les faces
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. verif tetraedres ; codret', codret
#endif
c
      if ( nbteto.ne.0 .and. optnco.le.1 ) then
c
      nbtenc = 0
c
      do 40 , entite = 1 , nbtecf
c
        etat = mod (hettet(entite) , 100 )
c
        if ( etat.eq.0 ) then
#ifdef _DEBUG_HOMARD_
       write(ulsort,texte(langue,20)) mess14(langue,1,3), entite
#endif
c
c 4.1. ==> Decompte du nombre de faces actives
c
          nbtrd2 = 0
          nbtrd4 = 0
          do 41 , jaux = 1 , 4
            iaux = mod (hettri(tritet(entite,jaux)),10)
            if ( iaux.ge.1 .and. iaux.le.3 ) then
              nbtrd2 = nbtrd2 + 1
            elseif ( iaux.ge.4 .and. iaux.le.8 ) then
              nbtrd4 = nbtrd4 + 1
            elseif ( iaux.eq.9 ) then
              nbtrd4 = nbtrd4 + 2
            endif
   41     continue
cgn          print *,mess14(langue,1,3), entite, ':',nbtrd2, nbtrd4
          bilanc = max ( nbtrd2, nbtrd4 )
c
c 4.2. ==> S'il y a au moins une face inactive, precision pour le cas
c          non conforme
c
          if ( optnco.ne.0 .and. bilanc.ge.1 ) then
c
c 4.2.1. ==> optnco = 1, on autorise :
c            - 1 triangle coupe en 4, les 3 autres aretes non coupees
c         ou - 1 ou 2 triangles coupes en 2, 1 seule arete coupee
c
            if ( optnco.eq.1 ) then
c
              if ( ( nbtrd2.eq.0 .and. nbtrd4.eq.1 ) .or.
     >             ( nbtrd2.le.2 .and. nbtrd4.eq.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTARTE', nompro
#endif
                call utarte ( entite,
     >                        nbtrto, nbtecf,
     >                        aretri, tritet, cotrte,
     >                        listar )
                iaux = 0
                do 42 , jaux = 1 , 6
                  if ( mod(hetare(listar(jaux)),10).ne.0 ) then
                    iaux = iaux + 1
                  endif
   42           continue
c
                if ( nbtrd4.eq.0 ) then
                  if ( iaux.eq.1 ) then
                    bilanc = 0
                  endif
                else
                  if ( iaux.eq.3 ) then
                    bilanc = 0
                  endif
                endif
c
              endif
c
            endif
c
          endif
cgn          print *,mess14(langue,1,3), entite, ':',bilanc
c
c 4.3. ==> Bilan avec impression eventuelle
c
          if ( bilanc.ne.0 ) then
c
            nbtenc = nbtenc + 1
            if ( optimp.ne.0 ) then
              write(ulsort,texte(langue,12)) mess14(langue,1,3),
     >                                       entite
              write(ulsort,texte(langue,15)) hettet(entite)
              do 431 , iaux = 1 , 4
                letria = tritet(entite,iaux)
                write(ulsort,texte(langue,13)) mess14(langue,2,2),
     >                                  iaux, letria, hettri(letria)
                do 4311 , jaux = 1 , 3
                  larete = aretri(letria,jaux)
                  write(ulsort,texte(langue,13))
     >                                    '  '//mess14(langue,2,1),
     >                                    jaux, larete, hetare(larete)
 4311           continue
  431         continue
            endif
c
          endif
c
        endif
c
   40 continue
c
      if ( nbtenc.ne.0 ) then
        codret = 3
#ifdef _DEBUG_HOMARD_
        if ( optimp.ne.0 ) then
#else
        if ( ulsort.ne.0 ) then
#endif
          if ( optnco.eq.0 ) then
            write(ulsort,texte(langue,11))
          else
            write(ulsort,texte(langue,9))
          endif
          write(ulsort,texte(langue,14)) mess14(langue,3,3), nbtenc
        endif
#ifdef _DEBUG_HOMARD_
      else
        write(ulsort,texte(langue,10)) mess14(langue,3,3)
#endif
      endif
c
      endif
c
c====
c 5. verification de la conformite des pyramides
c    On ne controle pas pour l'option "1 noeud pendant" car c'est pris
c    en compte par les faces
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. verif pyramides ; codret', codret
#endif
c
      if ( nbpyto.ne.0 .and. optnco.le.1 ) then
c
      nbpync = 0
c
      do 50 , entite = 1 , nbpycf
c
        etat = mod ( hetpyr(entite) , 100 )
c
        if ( etat.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
       write(ulsort,texte(langue,20)) mess14(langue,1,5), entite
#endif
c
c 5.1. ==> Decompte du nombre de faces actives
c
          nbtrd2 = 0
          nbtrd4 = 0
          do 51 , jaux = 1 , 4
            iaux = mod (hettri(facpyr(entite,jaux)),10)
            if ( iaux.ge.1 .and. iaux.le.3 ) then
              nbtrd2 = nbtrd2 + 1
            elseif ( iaux.ge.4 .and. iaux.le.8 ) then
              nbtrd4 = nbtrd4 + 1
            elseif ( iaux.eq.9 ) then
              nbtrd4 = nbtrd4 + 2
            endif
   51     continue
          nbqud3 = 0
          nbqud4 = 0
          iaux = mod (hetqua(facpyr(entite,5)),100)
          if ( iaux.eq.4 ) then
            nbqud4 = 1
          elseif ( iaux.eq.99 ) then
            nbqud4 = 2
          elseif ( iaux.ne.0 ) then
            nbqud3 = 1
          endif
c
c 5.2. ==> S'il y a au moins une face inactive, precision pour le cas
c          non conforme
c          On autorise :
c          - 1 face coupee en 4, les autres aretes non coupees
c          - 1 ou 2 triangles coupes en 2, 1 seule arete coupee
c          - 1 quadrangle coupe en 3, 1 seule arete coupee
c          - 1 triangle coupe en 2 et 1 quadrangle coupe en 3,
c            1 seule arete coupee
c
          if ( optnco.ne.0 .and. bilanc.ge.1 ) then
c
            if ( ( nbtrd2.eq.0 .and. nbtrd4.eq.1 .and.
     >             nbqud3.eq.0 .and. nbqud4.eq.0 ) .or.
     >           ( nbtrd2.eq.0 .and. nbtrd4.eq.0 .and.
     >             nbqud3.eq.0 .and. nbqud4.eq.1 ) .or.
     >           ( nbtrd2.le.2 .and. nbtrd4.eq.0 .and.
     >             nbqud3.eq.0 .and. nbqud4.eq.0 ) .or.
     >           ( nbtrd2.le.1 .and. nbtrd4.eq.0 .and.
     >             nbqud3.eq.1 .and. nbqud4.eq.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTARPY', nompro
#endif
              call utarpy ( entite,
     >                      nbtrto, nbpycf,
     >                      aretri, facpyr, cofapy,
     >                      listar )
              iaux = 0
              do 52 , jaux = 1 , 8
                if ( mod(hetare(listar(jaux)),10).ne.0 ) then
                  iaux = iaux + 1
                endif
   52         continue
c
              if ( nbtrd4.eq.0 .and. nbqud4.eq.0 ) then
                if ( iaux.eq.1 ) then
                  bilanc = 0
                endif
              elseif ( nbtrd4.eq.1 ) then
                if ( iaux.eq.3 ) then
                  bilanc = 0
                endif
              elseif ( nbqud4.eq.1 ) then
                if ( iaux.eq.4 ) then
                  bilanc = 0
                endif
              endif
c
            endif
c
          endif
cgn          print *,mess14(langue,1,3), entite, ':',bilanc
c
c 5.3. ==> Bilan avec impression eventuelle
c
          if ( bilanc.ne.0 ) then
            nbpync = nbpync + 1
            if ( optimp.ne.0 ) then
              write(ulsort,texte(langue,12)) mess14(langue,1,5),
     >                                      entite
              write(ulsort,texte(langue,15)) hetpyr(entite)
              do 531 , iaux = 1 , 4
                letria = facpyr(entite,iaux)
                write(ulsort,texte(langue,13)) mess14(langue,2,2),
     >                                  iaux, letria, hettri(letria)
                do 5311 , jaux = 1 , 3
                  larete = aretri(letria,jaux)
                  write(ulsort,texte(langue,13))
     >                                   '  '//mess14(langue,2,1),
     >                                    jaux, larete, hetare(larete)
 5311           continue
  531         continue
              lequad = facpyr(entite,5)
              write(ulsort,texte(langue,13)) mess14(langue,2,4),
     >                                1, lequad, hetqua(lequad)
              do 532 , jaux = 1 , 4
                larete = arequa(lequad,jaux)
                write(ulsort,texte(langue,13))
     >                                  '  '//mess14(langue,2,1),
     >                                  jaux, larete, hetare(larete)
  532         continue
            endif
          endif
c
        endif
c
   50 continue
c
      if ( nbpync.ne.0 ) then
        codret = 5
#ifdef _DEBUG_HOMARD_
        if ( optimp.ne.0 ) then
#else
        if ( ulsort.ne.0 ) then
#endif
          if ( optnco.eq.0 ) then
            write(ulsort,texte(langue,11))
          else
            write(ulsort,texte(langue,9))
          endif
          write(ulsort,texte(langue,14)) mess14(langue,3,5), nbpync
        endif
#ifdef _DEBUG_HOMARD_
      else
        write(ulsort,texte(langue,10)) mess14(langue,3,5)
#endif
      endif
c
      endif
c
c====
c 6. verification de la conformite des hexaedres
c    On ne controle pas pour l'option "1 noeud pendant" car c'est pris
c    en compte par les faces
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. verif hexaedres ; codret', codret
#endif
c
      if ( nbheto.ne.0 .and. optnco.le.1 ) then
c
      nbhenc = 0
c
      do 60 , entite = 1 , nbhecf
c
        etat = mod(hethex(entite),1000)
c
        if ( etat.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
       write(ulsort,texte(langue,20)) mess14(langue,1,6), entite
#endif
c
c 6.1. ==> Decompte du nombre de faces actives
c
          nbqud3 = 0
          nbqud4 = 0
          do 61 , jaux = 1 , 6
            iaux = mod (hetqua(quahex(entite,jaux)),100)
            if ( iaux.eq.4 ) then
              nbqud4 = nbqud4 + 1
            elseif ( iaux.eq.99 ) then
              nbqud4 = nbqud4 + 2
            elseif ( iaux.ne.0 ) then
              nbqud3 = nbqud3 + 1
            endif
   61     continue
          bilanc = max ( nbqud3, nbqud4 )
c
c 6.2. ==> S'il y a au moins une face inactive, precision pour le cas
c          non conforme
c          On autorise :
c          - 1 face coupee en 4, les autres aretes non coupees
c          - 1 ou 2 quadrangles coupes en 3, 1 seule arete coupee
c
          if ( optnco.ne.0 .and. bilanc.ge.1 ) then
c
            if ( ( nbqud3.eq.0 .and. nbqud4.eq.1 ) .or.
     >           ( nbqud3.le.2 .and. nbqud4.eq.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTARHE', nompro
#endif
              call utarhe ( entite,
     >                      nbquto, nbhecf,
     >                      arequa, quahex, coquhe,
     >                      listar )
              iaux = 0
              do 62 , jaux = 1 , 12
                if ( mod(hetare(listar(jaux)),10).ne.0 ) then
                  iaux = iaux + 1
                endif
   62         continue
c
              if ( nbqud4.eq.0 ) then
                if ( iaux.eq.1 ) then
                  bilanc = 0
                endif
              else
                if ( iaux.eq.4 ) then
                  bilanc = 0
                endif
              endif
c
            endif
c
          endif
cgn          print *,mess14(langue,1,3), entite, ':',bilanc
c
c 6.3. ==> Bilan avec impression eventuelle
c
          if ( bilanc.ne.0 ) then
            nbhenc = nbhenc + 1
            if ( optimp.ne.0 ) then
              write(ulsort,texte(langue,12)) mess14(langue,1,6),
     >                                      entite
              write(ulsort,texte(langue,15)) hethex(entite)
              do 631 , iaux = 1 , 6
                lequad = quahex(entite,iaux)
                write(ulsort,texte(langue,13)) mess14(langue,2,4),
     >                                  iaux, lequad, hetqua(lequad)
                do 6311 , jaux = 1 , 4
                  larete = arequa(lequad,jaux)
                  write(ulsort,texte(langue,13))
     >                                    '  '//mess14(langue,2,1),
     >                                    jaux, larete, hetare(larete)
 6311           continue
  631         continue
            endif
          endif
c
        endif
c
   60 continue
c
      if ( nbhenc.ne.0 ) then
        codret = 6
#ifdef _DEBUG_HOMARD_
        if ( optimp.ne.0 ) then
#else
        if ( ulsort.ne.0 ) then
#endif
          if ( optnco.eq.0 ) then
            write(ulsort,texte(langue,11))
          else
            write(ulsort,texte(langue,9))
          endif
          write(ulsort,texte(langue,14)) mess14(langue,3,6), nbhenc
        endif
#ifdef _DEBUG_HOMARD_
      else
        write(ulsort,texte(langue,10)) mess14(langue,3,6)
#endif
      endif
c
      endif
c
c====
c 7. verification de la conformite des pentaedres
c    On ne controle pas pour l'option "1 noeud pendant" car c'est pris
c    en compte par les faces
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. verif pentaedres ; codret', codret
#endif
c
      if ( nbpeto.ne.0 .and. optnco.le.1  ) then
c
      nbpenc = 0
c
      do 70 , entite = 1 , nbpecf
c
        etat = mod ( hetpen(entite) , 100 )
c
        if ( etat.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
       write(ulsort,texte(langue,20)) mess14(langue,1,7), entite
#endif
c
c 7.1. ==> Decompte du nombre de faces actives
c
          nbtrd2 = 0
          nbtrd4 = 0
          do 711 , jaux = 1 , 2
            iaux = mod (hettri(facpen(entite,jaux)),10)
            if ( iaux.ge.1 .and. iaux.le.3 ) then
              nbtrd2 = nbtrd2 + 1
            elseif ( iaux.ge.4 .and. iaux.le.8 ) then
              nbtrd4 = nbtrd4 + 1
            elseif ( iaux.eq.9 ) then
              nbtrd4 = nbtrd4 + 2
            endif
  711     continue
          nbqud3 = 0
          nbqud4 = 0
          do 721 , jaux = 3, 5
            iaux = mod (hetqua(facpen(entite,jaux)),100)
            if ( iaux.eq.4 ) then
              nbqud4 = nbqud4 + 1
            elseif ( iaux.eq.99 ) then
              nbqud4 = nbqud4 + 2
            elseif ( iaux.ne.0 ) then
              nbqud3 = nbqud3 + 1
            endif
  721     continue
          bilanc = max ( nbtrd2, nbtrd4, nbqud3, nbqud4 )
c
c 7.2. ==> S'il y a au moins une face inactive, precision pour le cas
c          non conforme
c          On autorise :
c          - 1 face coupee en 4, les autres aretes non coupees
c          - 1 ou 2 triangles coupes en 2, 1 seule arete coupee
c          - 1 ou 2 quadrangles coupes en 3, 1 seule arete coupee
c          - 1 triangle coupe en 2 et 1 quadrangle coupe en 3,
c            1 seule arete coupee
c
          if ( optnco.ne.0 .and. bilanc.ge.1 ) then
c
            if ( ( nbtrd2.eq.0 .and. nbtrd4.eq.1 .and.
     >             nbqud3.eq.0 .and. nbqud4.eq.0 ) .or.
     >           ( nbtrd2.eq.0 .and. nbtrd4.eq.0 .and.
     >             nbqud3.eq.0 .and. nbqud4.eq.1 ) .or.
     >           ( nbtrd2.le.2 .and. nbtrd4.eq.0 .and.
     >             nbqud3.eq.0 .and. nbqud4.eq.0 ) .or.
     >           ( nbtrd2.eq.0 .and. nbtrd4.eq.0 .and.
     >             nbqud3.le.2 .and. nbqud4.eq.0 ) .or.
     >           ( nbtrd2.le.1 .and. nbtrd4.eq.0 .and.
     >             nbqud3.eq.1 .and. nbqud4.eq.0 ) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTARPE', nompro
#endif
              call utarpe ( entite,
     >                      nbquto, nbpeto,
     >                      arequa, facpen, cofape,
     >                      listar )
              iaux = 0
              do 72 , jaux = 1 , 9
                if ( mod(hetare(listar(jaux)),10).ne.0 ) then
                  iaux = iaux + 1
                endif
   72         continue
c
              if ( nbtrd4.eq.0 .and. nbqud4.eq.0 ) then
                if ( iaux.eq.1 ) then
                  bilanc = 0
                endif
              elseif ( nbtrd4.eq.1 ) then
                if ( iaux.eq.3 ) then
                  bilanc = 0
                endif
              elseif ( nbqud4.eq.1 ) then
                if ( iaux.eq.4 ) then
                  bilanc = 0
                endif
              endif
c
            endif
c
          endif
cgn          print *,mess14(langue,1,3), entite, ':',bilanc
c
c 7.3. ==> Bilan avec impression eventuelle
c
          if ( bilanc.ne.0 ) then
            nbpenc = nbpenc + 1
            if ( optimp.ne.0 ) then
              write(ulsort,texte(langue,20)) mess14(langue,1,7),
     >                                      entite
              write(ulsort,texte(langue,15)) hetpen(entite)
              do 731 , iaux = 1 , 2
                letria = facpen(entite,iaux)
                write(ulsort,texte(langue,13)) mess14(langue,2,2),
     >                                  iaux, letria, hettri(letria)
                do 7311 , jaux = 1 , 3
                  larete = aretri(letria,jaux)
                  write(ulsort,texte(langue,13))
     >                                    '  '//mess14(langue,2,1),
     >                                    jaux, larete, hetare(larete)
 7311           continue
  731         continue
              do 732 , iaux = 3 , 5
                lequad = facpen(entite,iaux)
                write(ulsort,texte(langue,13)) mess14(langue,2,4),
     >                                  iaux-2, lequad, hetqua(lequad)
                do 7321 , jaux = 1 , 4
                  larete = arequa(lequad,jaux)
                  write(ulsort,texte(langue,13))
     >                                    '  '//mess14(langue,2,1),
     >                                    jaux, larete, hetare(larete)
 7321           continue
  732         continue
            endif
          endif
c
        endif
c
   70 continue
c
      if ( nbpenc.ne.0 ) then
        codret = 7
#ifdef _DEBUG_HOMARD_
        if ( optimp.ne.0 ) then
#else
        if ( ulsort.ne.0 ) then
#endif
          if ( optnco.eq.0 ) then
            write(ulsort,texte(langue,11))
          else
            write(ulsort,texte(langue,9))
          endif
          write(ulsort,texte(langue,14)) mess14(langue,3,7), nbpenc
        endif
#ifdef _DEBUG_HOMARD_
      else
        write(ulsort,texte(langue,10)) mess14(langue,3,7)
#endif
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
#ifdef _DEBUG_HOMARD_
        if ( ulsort.ne.0 ) then
#else
        if ( optimp.ne.0 ) then
#endif
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
