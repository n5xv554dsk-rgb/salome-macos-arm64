      subroutine utb05a ( choix,
     >                    coonoe, somare,
     >                    hettri, aretri,
     >                    famtri, cfatri,
     >                    hetqua, arequa,
     >                    famqua, cfaqua,
     >                    tritet, cotrte, aretet, hettet,
     >                    quahex, coquhe, arehex, hethex,
     >                    facpyr, cofapy, arepyr, hetpyr,
     >                    facpen, cofape, arepen, hetpen,
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
c    UTilitaire - Bilan - option 05 - etape a
c    --           -              --         -
c  remarque : utb05a et utb19a sont des clones
c ______________________________________________________________________
c
c but : controle de la qualite des mailles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . choix  . e   .   1    . choix du traitement                        .
c .        .     .        . 0 : creation et affichage des histogrammes .
c .        .     .        . 2 : sortie de la qualite des triangles     .
c .        .     .        . 3 : sortie de la qualite des tetraedres    .
c .        .     .        . 4 : sortie de la qualite des quadrangles   .
c .        .     .        . 5 : sortie de la qualite des pyramides     .
c .        .     .        . 6 : sortie de la qualite des hexaedres     .
c .        .     .        . 7 : sortie de la qualite des pentaedres    .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . famtri . e   . nbtrto . famille des triangles                      .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
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
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
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
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
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
      parameter ( nompro = 'UTB05A' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
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
c
      integer somare(2,nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer cfatri(nctftr,nbftri), famtri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer cfaqua(nctfqu,nbfqua), famqua(nbquto)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hettet(nbteto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hethex(nbheto)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer hetpyr(nbpyto)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer hetpen(nbpeto)
      integer nbeexa
      integer tbiau1(*), tbiau2(*)
      integer nbiter
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer letria, lequad
      integer iaux, jaux
      integer nbvoto
c
      double precision daux1, daux2
      double precision tbdaux(1)
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
      texte(1,4) =
     > '(//,3x,''QUALITES DES MAILLES'',/,3x,20(''=''))'
      texte(1,5) = '(3x,''Qualite '',a,'' des '',a,'' : '',g12.5)'
      texte(1,6) = '(3x,''Nombre de '',a,'' a examiner : '',i8)'
      texte(1,7) = '(3x,''Nombre de '',a,'' aplatis : '',i8)'
c
      texte(2,4) =
     > '(//,3x,''QUALITIES OF MESHES'',/,3x,19(''=''))'
      texte(2,5) = '(3x,''Quality '',a,'' of '',a,'': '',g12.5)'
      texte(2,6) = '(3x,''Number of '',a,'' to be examined: '',i8)'
      texte(2,7) = '(3x,''Number of flat '',a,'': '',i8)'
c
#include "impr03.h"
c
      write (ulsort,texte(langue,4))
      if ( ulbila.ne.ulsort ) then
        write (ulbila,texte(langue,4))
      endif
c
      codret = 0
c
      nbvoto = nbteto + nbpyto + nbheto + nbpeto
c
c====
c 2. calcul des qualites des tetraedres
c===
c
      if ( choix.eq.0 .or. choix.eq.3 ) then
c
        if ( nbteto.ne.0 ) then
c
          iaux = 3
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB05C_te', nompro
#endif
          call utb05c ( choix,
     >                  iaux, nbteto, nbtecf, nbteca,
     >                  coonoe, somare,
     >                  aretri, arequa,
     >                  hettet, tritet, cotrte, aretet,
     >                  nbiter,
     >                  nbeexa, tbiau1, tbiau2, tabaur, tabau2,
     >                  ulbila,
     >                  ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 3. calcul des qualites des pyramides
c===
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. pyramides ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( choix.eq.0 .or. choix.eq.5 ) then
c
        if ( nbpyto.ne.0 ) then
c
          iaux = 5
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB05C_py', nompro
#endif
          call utb05c ( choix,
     >                  iaux, nbpyto, nbpycf, nbpyca,
     >                  coonoe, somare,
     >                  aretri, arequa,
     >                  hetpyr, facpyr, cofapy, arepyr,
     >                  nbiter,
     >                  nbeexa, tbiau1, tbiau2, tabaur, tabau2,
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
c 4. calcul des qualites des hexaedres
c===
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. hexaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( choix.eq.0 .or. choix.eq.6 ) then
c
        if ( nbheto.ne.0 ) then
c
          iaux = 6
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB05C_he', nompro
#endif
          call utb05c ( choix,
     >                  iaux, nbheto, nbhecf, nbheca,
     >                  coonoe, somare,
     >                  aretri, arequa,
     >                  hethex, quahex, coquhe, arehex,
     >                  nbiter,
     >                  nbeexa, tbiau1, tbiau2, tabaur, tabau2,
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
c 5. calcul des qualites des pentaedres
c===
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. pentaedres ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( choix.eq.0 .or. choix.eq.7 ) then
c
        if ( nbpeto.ne.0 ) then
c
          iaux = 7
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB05C_pe', nompro
#endif
          call utb05c ( choix,
     >                  iaux, nbpeto, nbpecf, nbpeca,
     >                  coonoe, somare,
     >                  aretri, arequa,
     >                  hetpen, facpen, cofape, arepen,
     >                  nbiter,
     >                  nbeexa, tbiau1, tbiau2, tabaur, tabau2,
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
c 6. calcul des qualites des triangles d'un maillage 2d ou 2,5d
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. triangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( choix.eq.0 .or. choix.eq.2 ) then
c
      if ( nbtrto.ne.0 ) then
c
c 6.1. ==> liste des triangles a examiner :
c       . en l'absence de tetraedre, pentaedre et pyramide, ce sont
c         tous les triangles actifs ;
c       . en presence de tetraedre, pentaedre ou pyramide, ce sont les
c         triangles actifs qui sont des elements de calcul
c
      nbeexa = 0
c
      if ( nbteto.eq.0 .and. nbpeto.eq.0 .and. nbpyto.eq.0 ) then
c
        do 611 , letria = 1 , nbtrto
          if ( mod(hettri(letria),10).eq.0 ) then
            nbeexa = nbeexa + 1
            tbiau1(nbeexa) = letria
          endif
  611   continue
c
      else
c
        do 612 , letria = 1 , nbtrto
          if ( mod(hettri(letria),10).eq.0 .and.
     >         cfatri(cotyel,famtri(letria)).ne.0 ) then
            nbeexa = nbeexa + 1
            tbiau1(nbeexa) = letria
          endif
  612   continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,2), nbeexa
#endif
c
c 6.2. ==> calcul
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.2. calcul ; codret', codret
#endif
c
      if ( nbeexa.gt.0 ) then
c
      do 62 , iaux = 1 , nbeexa
c
        letria = tbiau1(iaux)
c
        call utqtri ( letria, daux1, daux2,
     >                coonoe, somare, aretri )
c
        tabaur(iaux) = daux1
c
   62 continue
c
      endif
c
c 6.3. ==> impression sur la sortie standard et sur un fichier
c          a exploiter par xmgrace
c
      if ( choix.eq.0 ) then
c
        if ( nbeexa.gt.0 ) then
c
          jaux = 1
          iaux = 2
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTB05B tri', nompro
#endif
          call utb05b ( jaux, iaux, nbeexa, tabaur, tbdaux,
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
      endif
c
      endif
c
c====
c 7. calcul des qualites des quadrangles d'un maillage 2d ou 2,5d
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. quadrangles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( choix.eq.0 .or. choix.eq.4 ) then
c
      if ( nbquto.ne.0 ) then
c
c 7.1. ==> liste des quadrangles a examiner :
c       . en l'absence d'hexaedre, pentaedre et pyramide, ce sont
c         tous les quadrangles actifs ;
c       . en presence d'hexaedre, pentaedre ou pyramide, ce sont les
c         quadrangles actifs qui sont des elements de calcul
c
      nbeexa = 0
c
      if ( nbheto.eq.0 .and. nbpeto.eq.0 .and. nbpyto.eq.0 ) then
c
        do 711 , lequad = 1 , nbquto
          if ( mod(hetqua(lequad),100).eq.0 ) then
            nbeexa = nbeexa + 1
            tbiau1(nbeexa) = lequad
          endif
  711   continue
c
      else
c
        do 712 , lequad = 1 , nbquto
          if ( mod(hetqua(lequad),100).eq.0 .and.
     >         cfaqua(cotyel,famqua(lequad)).ne.0 ) then
            nbeexa = nbeexa + 1
            tbiau1(nbeexa) = lequad
          endif
  712   continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,3,4), nbeexa
#endif
c
c 7.2. ==> calcul
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7.2. calcul ; codret', codret
#endif
c
      if ( nbeexa.gt.0 ) then
c
      do 72 , iaux = 1 , nbeexa
c
        lequad = tbiau1(iaux)
c
        call utqqua ( lequad, daux1, daux2,
     >                coonoe, somare, arequa )
c
        tabaur(iaux) = daux1
c
   72 continue
c
      endif
c
c 7.3. ==> impression sur la sortie standard et sur un fichier
c          a exploiter par xmgrace
c
      if ( choix.eq.0 ) then
c
        if ( nbeexa.gt.0 ) then
c
          jaux = 1
          iaux = 4
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,3)) 'UTB05B qua', nompro
#endif
          call utb05b ( jaux, iaux, nbeexa, tabaur, tbdaux,
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
