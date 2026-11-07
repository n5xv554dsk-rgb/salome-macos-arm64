      subroutine utb11b ( nbbloc,
     >                    hetare, somare,
     >                    hettri, aretri,
     >                    hetqua, arequa,
     >                    hettet, tritet,
     >                    hethex, quahex,
     >                    hetpyr, facpyr,
     >                    hetpen, facpen,
     >                    povoso, voisom,
     >                    posifa, facare,
     >                    voltri, pypetr,
     >                    volqua, pypequ,
     >                    famare, cfaare,
     >                    famtri, cfatri,
     >                    famqua, cfaqua,
     >                    famtet, cfatet,
     >                    famhex, cfahex,
     >                    fampyr, cfapyr,
     >                    fampen, cfapen,
     >                    lapile, tabau2, tabau3, tabau4,
     >                    taba11, taba12, taba13, taba14,
     >                    taba15, taba16,
     >                    nublvo,
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
c    UTilitaire - Bilan sur le maillage - option 11 - phase b
c    --           -                              --         -
c ______________________________________________________________________
c
c    analyse de la connexite des volumes
c remarque : on s'est arrange pour que les mailles externes soient
c            numerotes dans cet ordre :
c            . les tetraedres
c            . les triangles
c            . les aretes
c            . les mailles-points
c            . les quadrangles
c            . les hexaedres
c            . les pyramides
c            . les pentaedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbbloc .  s  .   1    . nombre de blocs                            .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . povoso . e   .0:nbnoto. pointeur des voisins par noeud             .
c . voisom . e   . nvosom . aretes voisines de chaque noeud            .
c . posifa . e   .0:nbarto. pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . e   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ . e   .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c . famare . e   . nbarto . famille des aretes                         .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c . famtri . e   . nbtrto . famille des triangles                      .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famtet . e   . nbteto . famille des tetraedres                     .
c . cfatet .     . nctfte*. codes des familles des tetraedres          .
c .        .     . nbftet .   1 : famille MED                          .
c .        .     .        .   2 : type de tetraedres                   .
c . famhex . e   . nbheto . famille des hexaedres                      .
c . cfahex .     . nctfhe*. codes des familles des hexaedres           .
c .        .     . nbfhex .   1 : famille MED                          .
c .        .     .        .   2 : type d'hexaedres                     .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . fampyr . e   . nbpyto . famille des pyramides                      .
c . cfapyr .     . nctfpy*. codes des familles des pyramides           .
c .        .     . nbfpyr .   1 : famille MED                          .
c .        .     .        .   2 : type de pyramides                    .
c . fampen . e   . nbpeto . famille des pentaedres                     .
c . cfapen .     . nctfpe*. codes des familles des pentaedres          .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . lapile .  a  .   *    . tableau de travail                         .
c . tabau2 .  a  . nbnoto . tableau de travail                         .
c . tabau3 .  a  . nbarto . tableau de travail                         .
c . tabau4 .  a  .-nbquto . tableau de travail                         .
c .        .     . :nbtrto.                                            .
c . taba11 .  a  .    *   . tableau de travail                         .
c . taba12 .  a  . nbnoto . tableau de travail                         .
c . taba13 .  a  . nbarto . tableau de travail                         .
c . taba14 .  a  .    *   . tableau de travail                         .
c . taba15 .  a  . nbarto . tableau de travail                         .
c . taba16 .  a  .   *    . tableau de travail                         .
c . nublvo .  s  .   *    . numero de blocs des volumes, ranges ainsi :.
c .        .     .        . les tetraedres                             .
c .        .     .        . les hexaedres                              .
c .        .     .        . les pyramides                              .
c .        .     .        . les pentaedres                             .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c .        .     .        . si 0 : on n'ecrit rien                     .
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
      parameter ( nompro = 'UTB11B' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
c
#include "dicfen.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbbloc
      integer hetare(nbarto), somare(2,nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer hettet(nbteto), tritet(nbtecf,4)
      integer hethex(nbheto), quahex(nbhecf,6)
      integer hetpyr(nbpyto), facpyr(nbpycf,5)
      integer hetpen(nbpeto), facpen(nbpecf,5)
      integer posifa(0:nbarto), facare(nbfaar)
      integer povoso(0:nbnoto), voisom(*)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer volqua(2,nbquto), pypequ(2,*)
c
      integer famare(nbarto), cfaare(nctfar,nbfare)
      integer famtri(nbtrto), cfatri(nctftr,nbftri)
      integer famqua(nbquto), cfaqua(nctfqu,nbfqua)
      integer famtet(nbteto), cfatet(nctfte,nbftet)
      integer famhex(nbheto), cfahex(nctfhe,nbfhex)
      integer fampyr(nbpyto), cfapyr(nctfpy,nbfpyr)
      integer fampen(nbpeto), cfapen(nctfpe,nbfpen)
c
      integer lapile(*)
      integer tabau2(nbnoto)
      integer tabau3(nbarto)
      integer tabau4(-nbquto:*)
      integer taba11(*)
      integer taba12(nbnoto)
      integer taba13(nbarto)
      integer taba14(*)
      integer taba15(nbarto)
      integer taba16(*)
      integer nublvo(*)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux, laux, maux
      integer tbiaux(1)
      integer levolu, nument, typvo0, typvol
      integer etat
      integer lamail, lgpile
      integer maxtet, maxhex, maxpyr, maxpen
      integer dectet, dechex, decpyr, decpen
      integer lapyra, lepent
      integer nbblfa
#ifdef _DEBUG_HOMARD_
      integer glop
      integer typenh
#endif
c
      integer nbmess
      parameter (nbmess = 10 )
      character*80 texte(nblang,nbmess)
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
c 1.1. ==> Les messages
c
      texte(1,4) = '(/,3x,''. Connexite des '',a)'
      texte(1,5) =
     >'(5x,''* Les '',a,'' sont en un seul bloc.'',15x,''*'')'
      texte(1,6) =
     >'(5x,''*'',19x,''Blocs de '',a,14x,''*'')'
      texte(1,7) =
     >'(5x,''* Bloc numero '',i8,5x,'' * '',i11,1x,a,'' *'')'
      texte(1,8) =
     >'(5x,''*    Nombre d''''Euler (2+V-F+A-S) :'',i5,19x,''*'')'
      texte(1,9) = '(''.. Nombre de blocs de '',a,'':'',i5)'
      texte(1,10) = '(''.. Impression du bloc'',i8)'
c
      texte(2,4) = '(/,3x,''. Connexity of '',a)'
      texte(2,5) =
     >'(5x,''* All the '',a,'' are connected.'',18x,''*'')'
      texte(2,6) =
     >'(5x,''*'',19x,''Blocks of '',a,13x,''*'')'
      texte(2,7) =
     >'(5x,''* Block # '',i8,9x,'' * '',i11,1x,a,'' *'')'
      texte(2,8) =
     >'(5x,''*    Euler characteristic (2+V-F+A-S):'',i5,14x,''*'')'
      texte(2,9) = '(''.. Number of blocks of '',a,'':'',i5)'
      texte(2,10) = '(''.. Printing of block #'',i8)'
c
#include "impr03.h"
cgn      print 91020,(voltri(1,iaux),iaux=1,nbtrto)
cgn      print 91020,(voltri(2,iaux),iaux=1,nbtrto)
cgn      print 91020,(pypetr(1,iaux),iaux=1,16)
cgn      print 91020,(pypetr(2,iaux),iaux=1,56)
cgn      print 91020,(pypequ(1,iaux),iaux=1,4)
cgn      print 91020,(pypequ(2,iaux),iaux=1,14)
c
10100 format(/,5x,58('*'))
10200 format(  5x,58('*'))
c
c 1.2. ==> constantes
c
      if ( nbpyac.eq.0 .and. nbheac.eq.0 .and. nbpeac.eq.0 ) then
        typvo0 = 3
      elseif ( nbheac.eq.0 .and. nbpeac.eq.0 .and. nbteac.eq.0 ) then
        typvo0 = 5
      elseif ( nbpeac.eq.0 .and. nbteac.eq.0 .and. nbpyac.eq.0 ) then
        typvo0 = 6
      elseif ( nbteac.eq.0 .and. nbpyac.eq.0 .and. nbheac.eq.0 ) then
        typvo0 = 7
      else
        typvo0 = 9
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( ulbila.gt.0 ) then
        write (ulsort,texte(langue,4)) mess14(langue,3,typvo0)
      endif
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbteto, nbtecf, nbteca',
     >                      nbteto, nbtecf, nbteca
      write (ulsort,90002) 'nbheto, nbhecf, nbheca',
     >                      nbheto, nbhecf, nbheca
      write (ulsort,90002) 'nbpyto, nbpycf, nbpyca',
     >                      nbpyto, nbpycf, nbpyca
      write (ulsort,90002) 'nbpeto, nbpecf, nbpeca',
     >                      nbpeto, nbpecf, nbpeca
#endif
c
      dectet = 0
      maxtet = dectet + nbteto
      dechex = maxtet
      maxhex = dechex + nbheto
      decpyr = maxhex
      maxpyr = decpyr + nbpyto
      decpen = maxpyr
      maxpen = decpen + nbpeto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'dectet', dectet, ', maxtet', maxtet
      write (ulsort,90015) 'dechex', dechex, ', maxhex', maxhex
      write (ulsort,90015) 'decpyr', decpyr, ', maxpyr', maxpyr
      write (ulsort,90015) 'decpen', decpen, ', maxpen', maxpen
#endif
c
c 1.3. ==> Aucun bloc au depart
c
      do 13 , iaux = 1 , maxpen
        nublvo(iaux) = 0
   13 continue
c
      codret = 0
c
c====
c 2. blocs de volumes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. blocs de volumes ; codret =', codret
#endif
c
      iaux = 2
      iaux = iaux + ( nbteac + nbheac + nbpyac + nbpeac )
      iaux = iaux - ( nbtrac + nbquac )
      iaux = iaux + nbarac
      iaux = iaux - nbnop1
      write (ulbila,10100)
      write (ulbila,texte(langue,8)) iaux
      write (ulbila,10200)
c
      nbbloc = 0
      lgpile = 0
c
      do 20 , levolu = 1, maxpen
c
        etat = -1
#ifdef _DEBUG_HOMARD_
        if ( levolu.eq.0 ) then
          glop = 1
        else
          glop = 01
        endif
#endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90002) 'Volume', levolu
        endif
#endif
        if ( levolu.le.maxtet ) then
          nument = levolu - dectet
          if ( cfatet(cotyel,famtet(nument)).ne.0 ) then
            etat = mod(hettet(nument),100)
          endif
        elseif ( levolu.le.maxhex ) then
          nument = levolu - dechex
          if ( cfahex(cotyel,famhex(nument)).ne.0 ) then
            etat = mod(hethex(nument),1000)
          endif
        elseif ( levolu.le.maxpyr ) then
          nument = levolu - decpyr
          if ( cfapyr(cotyel,fampyr(nument)).ne.0 ) then
            etat = mod(hetpyr(nument),100)
          endif
        else
          nument = levolu - decpen
          if ( cfapen(cotyel,fampen(nument)).ne.0 ) then
            etat = mod(hetpen(nument),100)
          endif
        endif
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90002) '============== etat', etat
        endif
#endif
c
        if ( etat.eq.0 ) then
c
          if ( nublvo(levolu).eq.0 ) then
c
c 2.1. ==> on commence un nouveau bloc
c 2.1.1. ==> impression des caracteristiques du bloc precedent
c
          if ( ulbila.gt.0 .and. nbbloc.ge.1 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbbloc', nbbloc
#endif
c
c 2.1.1.1. ==> recherche des faces actives de ce bloc
c
            if ( codret.eq.0 ) then
c
            iaux = 3
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11E', nompro
#endif
            call utb11e ( iaux, nbbloc, nublvo,
     >                    tbiaux,
     >                    tbiaux, tbiaux,
     >                    tritet, quahex, facpyr, facpen,
     >                    maxtet, maxhex, maxpyr, maxpen,
     >                    tabau3, tabau4,
     >                    ulsort, langue, codret )
c
            endif
c
c 2.1.1.2. ==> recherche des blocs de faces actives de ce bloc
c
            if ( codret.eq.0 ) then
c
            iaux = 1
            jaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11C', nompro
#endif
            call utb11c ( nbblfa, iaux, tabau4,
     >                    hetare, somare,
     >                    hettri, aretri,
     >                    hetqua, arequa,
     >                    povoso, voisom,
     >                    posifa, facare,
     >                    famare, cfaare,
     >                    famtri, cfatri,
     >                    famqua, cfaqua,
     >                    taba11, taba12, taba13,
     >                    taba15, taba16,
     >                    taba14,
     >                    jaux,
     >                    ulsort, langue, codret )
c
            endif
c
c 2.1.1.3. ==> impression veritable
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) nbbloc
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11F', nompro
#endif
            call utb11f ( nbbloc, nbblfa, typvo0, typvol,
     >                    nublvo, tabau2, tabau3, tabau4,
     >                    ulbila,
     >                    ulsort, langue, codret )
c
            endif
c
          endif
c
c 2.1.2. ==> initialisations pour un nouveau bloc
c
            nbbloc = nbbloc + 1
            lamail = levolu
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'debut du bloc ',nbbloc,
     >                     ' avec lamail = ', lamail
#endif
c
          do 2121 , iaux = 1 , nbnoto
            tabau2(iaux) = 0
 2121     continue
          do 2122 , iaux = 1 , nbarto
            tabau3(iaux) = 0
 2122     continue
c
          typvol = 0
c
   21     continue
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
          if ( lamail.le.maxtet ) then
            typenh = 3
          elseif ( lamail.le.maxhex ) then
            typenh = 6
          elseif ( lamail.le.maxpyr ) then
            typenh = 5
          else
            typenh = 7
          endif
          write (ulsort,*) '... Maille', lamail,
     >                         ' (',mess14(langue,1,typenh),')'
        endif
#endif
c
c 2.2. ==> memorisation du bloc pour la maille courante
c
            nublvo(lamail) = nbbloc
c
            if ( lamail.le.maxtet ) then
              if ( typvol.eq.0 ) then
                typvol = 3
              elseif ( typvol.ne.3 ) then
                typvol = 9
              endif
            elseif ( lamail.le.maxhex ) then
              if ( typvol.eq.0 ) then
                typvol = 6
              elseif ( typvol.ne.6 ) then
                typvol = 9
              endif
            elseif ( lamail.le.maxpyr ) then
              if ( typvol.eq.0 ) then
                typvol = 5
              elseif ( typvol.ne.5 ) then
                typvol = 9
              endif
            else
              if ( typvol.eq.0 ) then
                typvol = 7
              elseif ( typvol.ne.7 ) then
                typvol = 9
              endif
            endif
c
c 2.3. ==> mise des voisins dans la pile s'ils n'ont pas ete vus.
c          Il faut faire attention  a la numerotation. Pour la pile et
c          nublvo, c'est la numerotation globale des mailles ; pour les
c          caracteristiques des entites, c'est leur numero local.
c
c 2.3.1. ==> Cas d'un tetraedre
c
            if ( lamail.le.maxtet ) then
c
              nument = lamail - dectet
#ifdef _DEBUG_HOMARD_
        if ( glop.eq.1 ) then
        write (ulsort,90002) 'C''est le tetraedre ', nument
        endif
#endif
c
              if ( nument.le.nbtecf ) then
c
              do 231 , iaux = 1 , 4
c
                jaux = tritet(nument,iaux)
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90002) '..... triangle jaux = ', jaux
        endif
#endif
                do 2311 , laux = 1 , 3
                  kaux = aretri(jaux,laux)
                  tabau3(kaux) = tabau3(kaux) + 1
                  maux = somare(1,kaux)
                  tabau2(maux) = tabau2(maux) + 1
                  maux = somare(2,kaux)
                  tabau2(maux) = tabau2(maux) + 1
 2311           continue
c
                do 2312 , laux = 1 , 2
c
                  kaux = voltri(laux,jaux)
c
c 2.3.1.1. ==> Le voisin est un autre tetraedre
c
                  if ( kaux.gt.0 .and. kaux.ne.nument ) then
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
       write (ulsort,90015) '....... Le ',laux,
     >                      '-ieme voisin est le tetraedre ',kaux
       write (ulsort,90002) '....... du bloc ',nublvo(kaux)
        endif
#endif
c
                    if ( nublvo(kaux).eq.0 ) then
                      if ( cfatet(cotyel,famtet(kaux)).ne.0 ) then
                        etat = mod( hettet(kaux),100)
                        if ( etat.eq.0 ) then
                          lgpile = lgpile + 1
                          lapile(lgpile) = kaux
                        endif
                      endif
                    endif
c
                  elseif ( kaux.lt.0 ) then
c
                    kaux = -kaux
c
c 2.3.1.2. ==> Le voisin est une pyramide
c
                    if ( pypetr(1,kaux).ne.0 ) then
                      lapyra = pypetr(1,kaux)
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est la pyramide ',lapyra
      write (ulsort,90002) '....... du bloc ', nublvo(decpyr+lapyra)
        endif
#endif
                      if ( nublvo(decpyr+lapyra).eq.0 ) then
                        if ( cfapyr(cotyel,fampyr(lapyra)).ne.0 ) then
                          etat = mod( hetpyr(lapyra),100)
                          if ( etat.eq.0 ) then
                            lgpile = lgpile + 1
                            lapile(lgpile) = decpyr+lapyra
                          endif
                        endif
                      endif
                    endif
c
c 2.3.1.3. ==> Le voisin est un pentaedre
c
                    if ( pypetr(2,kaux).ne.0 ) then
                      lepent = pypetr(2,kaux)
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est le pentaedre ',lepent
      write (ulsort,90002) '....... du bloc ', nublvo(decpen+lepent)
        endif
#endif
                      if ( nublvo(decpen+lepent).eq.0 ) then
                        if ( cfapen(cotyel,fampen(lepent)).ne.0 ) then
                          etat = mod( hetpen(lepent),100)
                          if ( etat.eq.0 ) then
                            lgpile = lgpile + 1
                            lapile(lgpile) = decpen+lepent
                          endif
                        endif
                      endif
                    endif
c
                  endif
c
 2312           continue
c
  231         continue
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,*) 'OK'
        endif
#endif
c
              endif
c
c 2.3.2. ==> Cas d'un hexaedre
c
            elseif ( lamail.le.maxhex ) then
c
              nument = lamail-dechex
#ifdef _DEBUG_HOMARD_
        if ( glop.eq.1 ) then
        write (ulsort,90002) 'C''est l''hexaedre   ', nument
        endif
#endif
c
              if ( nument.le.nbhecf ) then
c
              do 232 , iaux = 1 , 6
c
                jaux = quahex(nument,iaux)
#ifdef _DEBUG_HOMARD_
        if ( glop.eq.1 ) then
        write (ulsort,90002) '..... quadrangle jaux = ', jaux
        endif
#endif
                do 2321 , laux = 1 , 4
                  kaux = arequa(jaux,laux)
                  tabau3(kaux) = tabau3(kaux) + 1
                  maux = somare(1,kaux)
                  tabau2(maux) = tabau2(maux) + 1
                  maux = somare(2,kaux)
                  tabau2(maux) = tabau2(maux) + 1
 2321           continue
c
                do 2322 , laux = 1 , 2
c
                  kaux = volqua(laux,jaux)
c
#ifdef _DEBUG_HOMARD_
        if ( glop.eq.1 ) then
        write (ulsort,90002) '....... kaux = ', kaux
        endif
#endif
c
c 2.3.2.1. ==> Le voisin est un autre hexaedre
c
                  if ( kaux.gt.0 .and. kaux.ne.nument ) then
c
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est l''hexaedre ',kaux
      write (ulsort,90002) '....... du bloc ', nublvo(dechex+kaux)
      endif
#endif
                    if ( nublvo(dechex+kaux).eq.0 ) then
                      if ( cfahex(cotyel,famhex(kaux)).ne.0 ) then
                        etat = mod( hethex(kaux),1000)
                        if ( etat.eq.0 ) then
                          lgpile = lgpile + 1
                          lapile(lgpile) = dechex+kaux
                        endif
                      endif
                    endif
c
                  elseif ( kaux.lt.0 ) then
c
                    kaux = -kaux
cgn        if ( glop.eq.1 ) then
cgn        write (ulsort,90002) 'pypequ(1,kaux)', pypequ(1,kaux)
cgn        write (ulsort,90002) 'pypequ(2,kaux)', pypequ(2,kaux)
cgn        endif
c
c 2.3.2.2. ==> Le voisin est une pyramide
c
                    if ( pypequ(1,kaux).ne.0 ) then
                      lapyra = pypequ(1,kaux)
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est la pyramide ', lapyra
      write (ulsort,90002) '....... du bloc ', nublvo(decpyr+lapyra)
      endif
#endif
                      if ( nublvo(decpyr+lapyra).eq.0 ) then
                        if ( cfapyr(cotyel,fampyr(lapyra)).ne.0 ) then
                          etat = mod( hetpyr(lapyra),100)
                          if ( etat.eq.0 ) then
                            lgpile = lgpile + 1
                            lapile(lgpile) = decpyr+lapyra
                          endif
                        endif
                      endif
                    endif
c
c 2.3.2.3. ==> Le voisin est un pentaedre
c
                    if ( pypequ(2,kaux).ne.0 ) then
                      lepent = pypequ(2,kaux)
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est le pentaedre ',lepent
      write (ulsort,90002) '....... du bloc ', nublvo(decpen+lepent)
      endif
#endif
                      if ( nublvo(decpen+lepent).eq.0 ) then
                        if ( cfapen(cotyel,fampen(lepent)).ne.0 ) then
                          etat = mod( hetpen(lepent),100)
                          if ( etat.eq.0 ) then
                            lgpile = lgpile + 1
                            lapile(lgpile) = decpen+lepent
                          endif
                        endif
                      endif
                    endif
c
                  endif
c
 2322           continue
c
  232         continue
c
              endif
c
c 2.3.3. ==> Cas de la pyramide
c
            elseif ( lamail.le.maxpyr ) then
c
              nument = lamail-decpyr
#ifdef _DEBUG_HOMARD_
        if ( glop.eq.1 ) then
        write (ulsort,90002) 'C''est la pyramide  ',nument
        endif
#endif
c
              if ( nument.le.nbpycf ) then
c
c 2.3.3.1. ==> Le voisinage par les triangles
c
              do 233 , iaux = 1 , 4
c
                jaux = facpyr(nument,iaux)
#ifdef _DEBUG_HOMARD_
        if ( glop.eq.1 ) then
        write (ulsort,90015) '..... ', iaux,'-ieme triangle = ', jaux
        endif
#endif
                do 2331 , laux = 1 , 3
                  kaux = aretri(jaux,laux)
                  tabau3(kaux) = tabau3(kaux) + 1
                  maux = somare(1,kaux)
                  tabau2(maux) = tabau2(maux) + 1
                  maux = somare(2,kaux)
                  tabau2(maux) = tabau2(maux) + 1
 2331           continue
c
                do 2332 , laux = 1 , 2
c
                  kaux = voltri(laux,jaux)
c
c 2.3.3.1.1. ==> Le voisin est un tetraedre
c
                  if ( kaux.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est le tetraedre ',kaux
      write (ulsort,90002) '....... du bloc ', nublvo(kaux)
      endif
#endif
                    if ( nublvo(kaux).eq.0 ) then
                      if ( cfatet(cotyel,famtet(kaux)).ne.0 ) then
                        etat = mod( hettet(kaux),100)
                        if ( etat.eq.0 ) then
                          lgpile = lgpile + 1
                          lapile(lgpile) = kaux
                        endif
                      endif
                    endif
c
                  elseif ( kaux.lt.0 ) then
c
                    kaux = -kaux
c
c 2.3.3.1.2. ==> Le voisin est une autre pyramide
c
                    lapyra = pypetr(1,kaux)
                    if ( lapyra.ne.0 .and. lapyra.ne.nument ) then
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est la pyramide ',lapyra
      write (ulsort,90002) '....... du bloc ', nublvo(decpyr+lapyra)
      endif
#endif
                      if ( nublvo(decpyr+lapyra).eq.0 ) then
                        if ( cfapyr(cotyel,fampyr(lapyra)).ne.0 ) then
                          etat = mod( hetpyr(lapyra),100)
                          if ( etat.eq.0 ) then
                            lgpile = lgpile + 1
                            lapile(lgpile) = decpyr+lapyra
                          endif
                        endif
                      endif
                    endif
c
c 2.3.3.1.3. ==> Le voisin est un pentaedre
c
                    if ( pypetr(2,kaux).ne.0 ) then
                      lepent = pypetr(2,kaux)
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est le pentaedre ',lepent
      write (ulsort,90002) '....... du bloc ', nublvo(decpen+lepent)
      endif
#endif
                      if ( nublvo(decpen+lepent).eq.0 ) then
                        if ( cfapen(cotyel,fampen(lepent)).ne.0 ) then
                          etat = mod( hetpen(lepent),100)
                          if ( etat.eq.0 ) then
                            lgpile = lgpile + 1
                            lapile(lgpile) = decpen+lepent
                          endif
                        endif
                      endif
                    endif
c
                  endif
c
 2332           continue
c
  233         continue
c
c 2.3.3.2. ==> Le voisinage par le quadrangle
c
              jaux = facpyr(nument,5)
#ifdef _DEBUG_HOMARD_
        if ( glop.eq.1 ) then
        write (ulsort,90002) '..... le quadrangle numero', jaux
        endif
#endif
              do 2333 , laux = 1 , 4
                kaux = arequa(jaux,laux)
                tabau3(kaux) = tabau3(kaux) + 1
                maux = somare(1,kaux)
                tabau2(maux) = tabau2(maux) + 1
                maux = somare(2,kaux)
                tabau2(maux) = tabau2(maux) + 1
 2333         continue
c
              do 2334 , laux = 1 , 2
c
                kaux = volqua(laux,jaux)
c
c 2.3.3.2.1. ==> Le voisin est un hexaedre
c
                if ( kaux.gt.0 ) then
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est l''hexaedre ',kaux
      write (ulsort,90002) '....... du bloc ', nublvo(dechex+kaux)
      endif
#endif
c
                  if ( nublvo(dechex+kaux).eq.0 ) then
                    if ( cfahex(cotyel,famhex(kaux)).ne.0 ) then
                      etat = mod( hethex(kaux),1000)
                      if ( etat.eq.0 ) then
                        lgpile = lgpile + 1
                        lapile(lgpile) = dechex+kaux
                      endif
                    endif
                  endif
c
                elseif ( kaux.lt.0 ) then
c
                  kaux = -kaux
c
c 2.3.3.2.2. ==> Le voisin est une autre pyramide
c
                  lapyra = pypequ(1,kaux)
                  if ( lapyra.ne.0 .and. lapyra.ne.nument ) then
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est la pyramide ',lapyra
      write (ulsort,90002) '....... du bloc ', nublvo(decpyr+lapyra)
      endif
#endif
                    if ( nublvo(decpyr+lapyra).eq.0 ) then
                      if ( cfapyr(cotyel,fampyr(lapyra)).ne.0 ) then
                        etat = mod( hetpyr(lapyra),100)
                        if ( etat.eq.0 ) then
                          lgpile = lgpile + 1
                          lapile(lgpile) = decpyr+lapyra
                        endif
                      endif
                    endif
                  endif
c
c 2.3.3.2.3. ==> Le voisin est un pentaedre
c
                  if ( pypequ(2,kaux).ne.0 ) then
                    lepent = pypequ(2,kaux)
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est le pentaedre ',lepent
      write (ulsort,90002) '....... du bloc ', nublvo(decpen+lepent)
      endif
#endif
                    if ( nublvo(decpen+lepent).eq.0 ) then
                      if ( cfapen(cotyel,fampen(lepent)).ne.0 ) then
                        etat = mod( hetpen(lepent),100)
                        if ( etat.eq.0 ) then
                          lgpile = lgpile + 1
                          lapile(lgpile) = decpen+lepent
                        endif
                      endif
                    endif
                  endif
c
                endif
c
 2334         continue
c
              endif
c
c 2.3.4. ==> Cas du pentaedre
c
            else
c
              nument = lamail-decpen
#ifdef _DEBUG_HOMARD_
        if ( glop.eq.1 ) then
        write (ulsort,90002) 'C''est le pentaedre ',nument
        endif
#endif
c
              if ( nument.le.nbpecf ) then
c
c 2.3.4.1. ==> Le voisinage par les triangles
c
              do 2341 , iaux = 1 , 2
c
                jaux = facpen(nument,iaux)
#ifdef _DEBUG_HOMARD_
        if ( glop.eq.1 ) then
        write (ulsort,90015) '..... ', iaux,'-ieme triangle = ', jaux
        endif
#endif
                do 23411 , laux = 1 , 3
                  kaux = aretri(jaux,laux)
                  tabau3(kaux) = tabau3(kaux) + 1
                  maux = somare(1,kaux)
                  tabau2(maux) = tabau2(maux) + 1
                  maux = somare(2,kaux)
                  tabau2(maux) = tabau2(maux) + 1
23411           continue
c
                do 23412 , laux = 1 , 2
c
                  kaux = voltri(laux,jaux)
c
c 2.3.4.1.1. ==> Le voisin est un tetraedre
c
                  if ( kaux.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est le tetraedre ',kaux
      write (ulsort,90002) '....... du bloc ', nublvo(kaux)
      endif
#endif
                    if ( nublvo(kaux).eq.0 ) then
                      if ( cfatet(cotyel,famtet(kaux)).ne.0 ) then
                        etat = mod( hettet(kaux),100)
                        if ( etat.eq.0 ) then
                          lgpile = lgpile + 1
                          lapile(lgpile) = kaux
                        endif
                      endif
                    endif
c
                  elseif ( kaux.lt.0 ) then
c
                    kaux = -kaux
c
c 2.3.4.1.2. ==> Le voisin est une pyramide
c
                    if ( pypetr(1,kaux).ne.0 ) then
                      lapyra = pypetr(1,kaux)
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est la pyramide ',lapyra
      write (ulsort,90002) '....... du bloc ', nublvo(decpyr+lapyra)
      endif
#endif
                      if ( nublvo(decpyr+lapyra).eq.0 ) then
                        if ( cfapyr(cotyel,fampyr(lapyra)).ne.0 ) then
                          etat = mod( hetpyr(lapyra),100)
                          if ( etat.eq.0 ) then
                            lgpile = lgpile + 1
                            lapile(lgpile) = decpyr+lapyra
                          endif
                        endif
                      endif
                    endif
c
c 2.3.4.1.3. ==> Le voisin est un autre pentaedre
c
                    lepent = pypetr(2,kaux)
                    if ( lepent.ne.0 .and. lepent.ne.nument ) then
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90002) 'nument', nument
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est le pentaedre ',lepent
      write (ulsort,90002) '....... du bloc ', nublvo(decpen+lepent)
      endif
#endif
                      if ( nublvo(decpen+lepent).eq.0 ) then
                        if ( cfapen(cotyel,fampen(lepent)).ne.0 ) then
                          etat = mod( hetpen(lepent),100)
                          if ( etat.eq.0 ) then
                            lgpile = lgpile + 1
                            lapile(lgpile) = decpen+lepent
                          endif
                        endif
                      endif
                    endif
c
                  endif
c
23412           continue
c
 2341         continue
c
c 2.3.4.2. ==> Le voisinage par les quadrangles
c
              do 2342 , iaux = 3 , 5
c
                jaux = facpen(nument,iaux)
#ifdef _DEBUG_HOMARD_
        if ( glop.eq.1 ) then
        write (ulsort,90015) '..... ', iaux,'-ieme quadrangle =', jaux
        endif
#endif
                do 23421 , laux = 1 , 4
                  kaux = arequa(jaux,laux)
                  tabau3(kaux) = tabau3(kaux) + 1
                  maux = somare(1,kaux)
                  tabau2(maux) = tabau2(maux) + 1
                  maux = somare(2,kaux)
                  tabau2(maux) = tabau2(maux) + 1
23421           continue
c
                do 23422 , laux = 1 , 2
c
                  kaux = volqua(laux,jaux)
c
#ifdef _DEBUG_HOMARD_
          if ( glop.eq.1 ) then
          write (ulsort,90002) '....... kaux = ', kaux
          endif
#endif
c
c 2.3.4.2.1. ==> Le voisin est un hexaedre
c
                  if ( kaux.gt.0 ) then
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est l''hexaedre ',kaux
      write (ulsort,90002) '....... du bloc ', nublvo(dechex+kaux)
      endif
#endif
c
                    if ( nublvo(dechex+kaux).eq.0 ) then
                      if ( cfahex(cotyel,famhex(kaux)).ne.0 ) then
                        etat = mod( hethex(kaux),1000)
                        if ( etat.eq.0 ) then
                          lgpile = lgpile + 1
                          lapile(lgpile) = dechex+kaux
                        endif
                      endif
                    endif
c
                  elseif ( kaux.lt.0 ) then
c
                    kaux = -kaux
c
c 2.3.4.2.2. ==> Le voisin est une pyramide
c
                    if ( pypequ(1,kaux).ne.0 ) then
                      lapyra = pypequ(1,kaux)
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est la pyramide ',lapyra
      write (ulsort,90002) '....... du bloc ', nublvo(decpyr+lapyra)
      endif
#endif
                      if ( nublvo(decpyr+lapyra).eq.0 ) then
                        if ( cfapyr(cotyel,fampyr(lapyra)).ne.0 ) then
                          etat = mod( hetpyr(lapyra),100)
                          if ( etat.eq.0 ) then
                            lgpile = lgpile + 1
                            lapile(lgpile) = decpyr+lapyra
                          endif
                        endif
                      endif
                    endif
c
c 2.3.4.2.3. ==> Le voisin est un autre pentaedre
c
                    lepent = pypequ(2,kaux)
                    if ( lepent.ne.0 .and. lepent.ne.nument ) then
#ifdef _DEBUG_HOMARD_
      if ( glop.eq.1 ) then
      write (ulsort,90015) '....... Le ',laux,
     >                     '-ieme voisin est le pentaedre ',lepent
      write (ulsort,90002) '....... du bloc ', nublvo(decpen+lepent)
      endif
#endif
                      if ( nublvo(decpen+lepent).eq.0 ) then
                        if ( cfapen(cotyel,fampen(lepent)).ne.0 ) then
                          etat = mod( hetpen(lepent),100)
                          if ( etat.eq.0 ) then
                            lgpile = lgpile + 1
                            lapile(lgpile) = decpen+lepent
                          endif
                        endif
                      endif
                     endif
c
                  endif
c
23422           continue
c
 2342         continue
c
              endif
c
            endif
c
c 2.4. ==> on passe a la maille suivante de la pile
c
            if ( lgpile.gt.0 ) then
c
              lamail = lapile(lgpile)
              lgpile = lgpile - 1
              goto 21
c
            endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'fin du bloc', nbbloc
#endif
c
          endif
c
        endif
c
   20 continue
c
c====
c 3. impression du dernier bloc
c====
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) '3. impression dernier bloc ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( ulbila.gt.0 ) then
c
c 3.1. ==> recherche des faces actives de ce bloc
c
        if ( codret.eq.0 ) then
c
        iaux = 3
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11E', nompro
#endif
        call utb11e ( iaux, nbbloc, nublvo,
     >                tbiaux,
     >                tbiaux, tbiaux,
     >                tritet, quahex, facpyr, facpen,
     >                maxtet, maxhex, maxpyr, maxpen,
     >                tabau3, tabau4,
     >                ulsort, langue, codret )
c
        endif
c
c 3.2. ==> recherche des blocs de faces actives de ce bloc
c
        if ( codret.eq.0 ) then
c
        iaux = 1
        jaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11C', nompro
#endif
        call utb11c ( nbblfa, iaux, tabau4,
     >                hetare, somare,
     >                hettri, aretri,
     >                hetqua, arequa,
     >                povoso, voisom,
     >                posifa, facare,
     >                famare, cfaare,
     >                famtri, cfatri,
     >                famqua, cfaqua,
     >                taba11, taba12, taba13,
     >                taba15, taba16,
     >                taba14,
     >                jaux,
     >                ulsort, langue, codret )
c
        endif
c
c 3.3. ==> impression veritable
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,9)) mess14(langue,3,8), nbblfa
      write (ulsort,texte(langue,10)) nbbloc
#endif
c
        if ( nbbloc.eq.1 ) then
          iaux = -nbbloc
        else
          iaux =  nbbloc
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11F', nompro
#endif
        call utb11f ( iaux, nbblfa, typvo0, typvol,
     >                nublvo, tabau2, tabau3, tabau4,
     >                ulbila,
     >                ulsort, langue, codret )
c
        write (ulbila,3000)
 3000   format(5x,58('*'))
c
        endif
c
      endif
c
      endif
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
