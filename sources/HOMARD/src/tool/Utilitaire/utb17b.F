      subroutine utb17b ( somare, np2are,
     >                    aretri, voltri,
     >                    famtri, cfatri,
     >                    arequa, volqua,
     >                    famqua, cfaqua,
     >                    hettet, tritet, cotrte, aretet,
     >                    hethex, quahex, coquhe, arehex,
     >                    hetpyr, facpyr, cofapy, arepyr,
     >                    hetpen, facpen, cofape, arepen,
     >                    tabaux,
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
c    UTilitaire - Bilan sur le maillage - option 17 - phase b
c    --           -                              --         -
c ______________________________________________________________________
c
c diagnostic des elements volumiques du calcul
c un element est surcontraint si tous ses noeuds sont au bord du domaine
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . famtri . e   . nbtrto . famille des triangles                      .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . famqua . e   . nbquto . famille des quadrangles                    .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. codes des triangles des tetraedres         .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. codes des faces des pentaedres             .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . tabaux . e   . nbnoto . 0 : le noeud est interne                   .
c .        .     .        . 1 : le noeud est au bord d'un volume       .
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
      parameter ( nompro = 'UTB17B' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
#include "dicfen.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer somare(2,nbarto), np2are(nbarto)
c
      integer aretri(nbtrto,3), voltri(2,nbtrto)
      integer famtri(nbtrto), cfatri(nctftr,nbftri)
c
      integer arequa(nbquto,4), volqua(2,nbquto)
      integer famqua(nbquto), cfaqua(nctfqu,nbfqua)
c
      integer hettet(nbteto)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hethex(nbheto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hetpyr(nbpyto)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer hetpen(nbpeto)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
c
      integer tabaux(nbnoto)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer letet0, lehex0, lepen0, lapyr0
      integer letetr, lehexa, lepent, lapyra
      integer letria, lequad
      integer nbensc, nbensb
      integer listar(12), listso(8)
      integer etat
c
      logical aubord
      logical afaire
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Nombre de '',a,'' actifs : '',i8)'
      texte(1,5) = '(''. Examen du '',a,i8)'
      texte(1,6) = '(''... '',a,i10,'' au bord'')'
      texte(1,7) =
     >'(''. Le bord du '',a,i10,'' n''''est pas une maille de calcul.''
     >)'
      texte(1,8) = '(''. Le '',a,i8,'' est surcontraint.'')'
c
      texte(2,4) = '(''Number of active '',a,'': '',i8)'
      texte(2,5) = '(''. Examination of '',a,''#'',i8)'
      texte(2,6) = '(''... '',a,''#'',i8,'' on the boundary'')'
      texte(2,7) =
     >'(''. The boundary of the '',a,i10,'' is not a calculation mesh.''
     >)'
      texte(2,8) = '(''. The '',a,''#'',i8,'' is overstressed.'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,3), nbteac
      write (ulsort,texte(langue,4)) mess14(langue,3,5), nbpyac
      write (ulsort,texte(langue,4)) mess14(langue,3,6), nbheac
      write (ulsort,texte(langue,4)) mess14(langue,3,7), nbpeac
#endif
c
      codret = 0
c
c====
c 2. Diagnostic sur les tetraedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. tetraedres, codret', codret
#endif
c
      if ( nbteac.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbteto', nbteto
      write (ulsort,90002) 'nbtecf', nbtecf
      write (ulsort,90002) 'nbteca', nbteca
#endif
c
        if ( nbteca.eq.0 ) then
          afaire =.true.
        else
          afaire =.false.
        endif
c
        nbensc = 0
        nbensb = 0
        aubord = .false.
c
        do 2 , letet0 = 1, nbteto
c
          letetr = letet0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,1,3), letetr
#endif
c
          etat = mod( hettet(letetr),100 )
c
          if ( etat.eq.0 ) then
c
c 2.1. ==> On regarde si tous les noeuds sont sur le bord
c
            call utaste ( letetr,
     >                    nbtrto, nbtecf, nbteca,
     >                    somare, aretri,
     >                    tritet, cotrte, aretet,
     >                    listar, listso )
c
            do 211 , iaux = 1 , 4
              if ( tabaux(listso(iaux)).eq.0 ) then
                goto 219
              endif
  211       continue
            if ( degre.eq.2 ) then
              do 212 , iaux = 1 , 6
                if ( tabaux(np2are(listar(iaux))).eq.0 ) then
                  goto 219
                endif
  212         continue
            endif
c
            nbensc = nbensc + 1
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,8)) mess14(langue,1,3), letetr
#endif
c
  219       continue
c
c 2.2. ==> On verifie que chaque face au bord est un element de calcul
c
            if ( afaire ) then
c
              do 22 , iaux = 1 , 4
c
                letria = tritet(letetr,iaux)
                if ( voltri(2,letria).eq.0 ) then
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,6)) mess14(langue,1,2), letria
#endif
c
                  aubord = .true.
                  if ( cfatri(cotyel,famtri(letria)).eq.0 ) then
                    nbensb = nbensb + 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,7)) mess14(langue,1,3), letetr
#endif
                    goto 229
                  endif
c
                endif
c
   22         continue
c
            endif
c
  229       continue
c
          endif
c
    2   continue
c
c 2.3. ==> Impression
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB17E', nompro
#endif
        iaux = 3
        call utb17e ( iaux, nbensc, aubord, nbensb,
     >                ulbila,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 3. Diagnostic sur les hexaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. hexaedres, codret', codret
#endif
c
      if ( nbheac.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbheto', nbheto
      write (ulsort,90002) 'nbhecf', nbhecf
      write (ulsort,90002) 'nbheca', nbheca
#endif
c
        if ( nbheca.eq.0 ) then
          afaire =.true.
        else
          afaire =.false.
        endif
c
        nbensc = 0
        nbensb = 0
        aubord = .false.
c
        do 3 , lehex0 = 1, nbheto
c
          lehexa = lehex0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,1,6), lehexa
#endif
c
          etat = mod(hethex(lehexa),1000)
c
          if ( etat.eq.0 ) then
c
c 3.1. ==> On regarde si tous les noeuds sont sur le bord
c
            call utashe ( lehexa,
     >                    nbquto, nbhecf, nbheca,
     >                    somare, arequa,
     >                    quahex, coquhe, arehex,
     >                    listar, listso )
c
            do 312 , iaux = 1 , 8
              if ( tabaux(listso(iaux)).eq.0 ) then
                goto 319
              endif
  312       continue
            if ( degre.eq.2 ) then
              do 313 , iaux = 1 , 12
                if ( tabaux(np2are(listar(iaux))).eq.0 ) then
                  goto 319
                endif
  313         continue
            endif
c
            nbensc = nbensc + 1
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,8)) mess14(langue,1,6), lehexa
#endif
c
  319       continue
c
c 3.2. ==> On verifie que chaque face au bord est un element de calcul
c
            if ( afaire ) then
c
cgn      write(ulsort,90002) 'faces', (quahex(lehexa,letet0),letet0=1,6)
              do 32 , iaux = 1 , 6
c
                lequad = quahex(lehexa,iaux)
                if ( volqua(2,lequad).eq.0 ) then
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,6)) mess14(langue,1,4), lequad
#endif
c
                  aubord = .true.
                  if ( cfaqua(cotyel,famqua(lequad)).eq.0 ) then
                    nbensb = nbensb + 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,7)) mess14(langue,1,6), lehexa
#endif
                    goto 329
                  endif
c
                endif
c
   32         continue
c
            endif
c
  329       continue
c
          endif
c
    3   continue
c
c 3.3. ==> Impression
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB17E', nompro
#endif
        iaux = 6
        call utb17e ( iaux, nbensc, aubord, nbensb,
     >                ulbila,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 4. Diagnostic sur les pyramides
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. pyramides, codret', codret
#endif
c
      if ( nbpyac.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbpyto', nbpyto
      write (ulsort,90002) 'nbpycf', nbpycf
      write (ulsort,90002) 'nbpyca', nbpyca
#endif
c
        if ( nbpyca.eq.0 ) then
          afaire =.true.
        else
          afaire =.false.
        endif
c
        nbensc = 0
        nbensb = 0
        aubord = .false.
c
        do 4 , lapyr0 = 1, nbpyto
c
          lapyra = lapyr0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,1,5), lapyra
#endif
c
          etat = mod( hetpyr(lapyra),100)
c
          if ( etat.eq.0 ) then
c
c 4.1. ==> On regarde si tous les noeuds sont sur le bord
c
            call utaspy ( lapyra,
     >                    nbtrto, nbpycf, nbpyca,
     >                    somare, aretri,
     >                    facpyr, cofapy, arepyr,
     >                    listar, listso )
c
            do 411 , iaux = 1 , 5
              if ( tabaux(listso(iaux)).eq.0 ) then
                goto 419
              endif
  411       continue
            if ( degre.eq.2 ) then
              do 412 , iaux = 1 , 8
                if ( tabaux(np2are(listar(iaux))).eq.0 ) then
                  goto 419
                endif
  412         continue
            endif
c
            nbensc = nbensc + 1
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,8)) mess14(langue,1,5), lapyra
#endif
c
  419       continue
c
c 4.2. ==> On verifie que chaque face au bord est un element de calcul
c
            if ( afaire ) then
c
              do 42 , iaux = 1 , 4
c
                letria = facpyr(lapyra,iaux)
                if ( voltri(2,letria).eq.0 ) then
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,6)) mess14(langue,1,2), letria
#endif
c
                  aubord = .true.
                  if ( cfatri(cotyel,famtri(letria)).eq.0 ) then
                    nbensb = nbensb + 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,7)) mess14(langue,1,5), lapyra
#endif
                    goto 429
                  endif
c
                endif
c
   42         continue
c
              lequad = facpyr(lapyra,5)
              if ( volqua(2,lequad).eq.0 ) then
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,6)) mess14(langue,1,4), lequad
#endif
c
                aubord = .true.
                if ( cfaqua(cotyel,famqua(lequad)).eq.0 ) then
                  nbensb = nbensb + 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,7)) mess14(langue,1,5), lapyra
#endif
                  goto 429
                endif
c
              endif
c
  429         continue
c
            endif
c
          endif
c
    4   continue
c
c 4.3. ==> Impression
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB17E', nompro
#endif
        iaux = 5
        call utb17e ( iaux, nbensc, aubord, nbensb,
     >                ulbila,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 5. Diagnostic sur les pentaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. pentaedres, codret', codret
#endif
c
      if ( nbpeac.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbpeto', nbpeto
      write (ulsort,90002) 'nbpecf', nbpecf
      write (ulsort,90002) 'nbpeca', nbpeca
#endif
c
        if ( nbpeca.eq.0 ) then
          afaire =.true.
        else
          afaire =.false.
        endif
c
        nbensc = 0
        nbensb = 0
        aubord = .false.
c
        do 5 , lepen0 = 1, nbpeto
c
          lepent = lepen0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,1,7), lepent
#endif
c
          etat = mod( hetpen(lepent),100)
c
          if ( etat.eq.0 ) then
c
c 5.1. ==> On regarde si tous les noeuds sont sur le bord
c
            call utaspe ( lepent,
     >                    nbquto, nbpecf, nbpeca,
     >                    somare, arequa,
     >                    facpen, cofape, arepen,
     >                    listar, listso )
c
            do 511 , iaux = 1 , 6
              if ( tabaux(listso(iaux)).eq.0 ) then
                goto 519
              endif
  511       continue
            if ( degre.eq.2 ) then
              do 512 , iaux = 1 , 9
                if ( tabaux(np2are(listar(iaux))).eq.0 ) then
                  goto 519
                endif
  512         continue
            endif
c
            nbensc = nbensc + 1
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,8)) mess14(langue,1,7), lepent
#endif
c
  519       continue
c
c 5.2. ==> On verifie que chaque face au bord est un element de calcul
c          . On regarde si la face est une maille de calcul
c
            if ( afaire ) then
c
              do 521 , iaux = 1 , 2
c
                letria = facpen(lepent,iaux)
                if ( voltri(2,letria).eq.0 ) then
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,6)) mess14(langue,1,2), letria
#endif
c
                  aubord = .true.
                  if ( cfatri(cotyel,famtri(letria)).eq.0 ) then
                    nbensb = nbensb + 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,7)) mess14(langue,1,7), lepent
#endif
                    goto 529
                  endif
c
                endif
c
  521         continue
c
              do 522 , iaux = 3 , 5
c
                lequad = facpen(lepent,iaux)
                if ( volqua(2,lequad).eq.0 ) then
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,6)) mess14(langue,1,4), lequad
#endif
c
                  aubord = .true.
                  if ( cfaqua(cotyel,famqua(lequad)).eq.0 ) then
                    nbensb = nbensb + 1
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,7)) mess14(langue,1,7), lepent
#endif
                    goto 529
                  endif
c
                endif
c
  522         continue
c
  529         continue
c
            endif
c
          endif
c
    5   continue
c
c 5.3. ==> Impression
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB17E', nompro
#endif
        iaux = 7
        call utb17e ( iaux, nbensc, aubord, nbensb,
     >                ulbila,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 6. La fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end
