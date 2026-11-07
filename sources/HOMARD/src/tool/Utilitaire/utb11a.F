      subroutine utb11a ( hetare, somare,
     >                    hettri, aretri,
     >                    voltri, pypetr,
     >                    hetqua, arequa,
     >                    volqua, pypequ,
     >                    hettet, tritet,
     >                    hethex, quahex,
     >                    hetpyr, facpyr,
     >                    hetpen, facpen,
     >                    povoso, voisom,
     >                    posifa, facare,
     >                    famare, cfaare,
     >                    famtri, cfatri,
     >                    famqua, cfaqua,
     >                    famtet, cfatet,
     >                    famhex, cfahex,
     >                    fampyr, cfapyr,
     >                    fampen, cfapen,
     >                    tabau1, tabau2, tabau3, tabau4,
     >                    taba11, taba12, taba13, taba14,
     >                    taba15, taba16,
     >                    nublen,
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
c    UTilitaire - Bilan sur le maillage - option 11
c    --           -                              --
c ______________________________________________________________________
c
c    analyse de la connexite du maillage de calcul
c    remarque : pour du raffinement non-conforme, chaque niveau est
c               un bloc
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . e   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ . e   .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
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
c . famare . e   . nbarto . famille des aretes                         .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
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
c . tabau1 .  a  .   *    . tableau de travail                         .
c . tabau2 .  a  .   *    . tableau de travail                         .
c . tabau3 .  a  .   *    . tableau de travail                         .
c . tabau4 .  a  .-nbquto . tableau de travail                         .
c .        .     . :nbtrto.                                            .
c . taba11 .  a  .    *   . tableau de travail                         .
c . taba12 .  a  . nbnoto . tableau de travail                         .
c . taba13 .  a  . nbarto . tableau de travail                         .
c . taba14 .  a  .    *   . tableau de travail                         .
c . taba15 .  a  . nbarto . tableau de travail                         .
c . taba16 .  a  .   *    . tableau de travail                         .
c . nublen .  s  .   *    . numero de blocs par entite                 .
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
      parameter ( nompro = 'UTB11A' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
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
      integer hetare(nbarto), somare(2,nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer volqua(2,nbquto), pypequ(2,*)
      integer hettet(nbteto), tritet(nbtecf,4)
      integer hethex(nbheto), quahex(nbhecf,6)
      integer hetpyr(nbpyto), facpyr(nbpycf,5)
      integer hetpen(nbpeto), facpen(nbpecf,5)
      integer povoso(0:nbnoto), voisom(*)
      integer posifa(0:nbarto), facare(nbfaar)
c
      integer famare(nbarto), cfaare(nctfar,nbfare)
      integer famtri(nbtrto), cfatri(nctftr,nbftri)
      integer famqua(nbquto), cfaqua(nctfqu,nbfqua)
      integer famtet(nbteto), cfatet(nctfte,nbftet)
      integer famhex(nbheto), cfahex(nctfhe,nbfhex)
      integer fampyr(nbpyto), cfapyr(nctfpy,nbfpyr)
      integer fampen(nbpeto), cfapen(nctfpe,nbfpen)
c
      integer tabau1(*)
      integer tabau2(nbnoto)
      integer tabau3(nbarto)
      integer tabau4(-nbquto:*)
      integer taba11(*)
      integer taba12(nbnoto)
      integer taba13(nbarto)
      integer taba14(*)
      integer taba15(nbarto)
      integer taba16(*)
      integer nublen(-nbquto:*)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nbblar, nbblfa, nbblvo
c
      integer nbmess
      parameter (nbmess = 10 )
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
      texte(1,4) =
     > '(//,3x,''CONNEXITE DES ENTITES DU CALCUL'',/,3x,31(''=''),/)'
      texte(1,5) =
     >'(5x,''*'',19x,''Blocs de '',a,14x,''*'')'
c
      texte(2,4) =
     > '(//,3x,''CONNEXITY OF CALCULATION ENTITIES'',/,3x,33(''=''),/)'
      texte(2,5) =
     >'(5x,''*'',19x,''Blocks of '',a,13x,''*'')'
c
      write (ulbila,texte(langue,4))
c
#ifdef _DEBUG_HOMARD_
10001 format(4x,60('-'))
#endif
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. blocs de volumes
c    Remarque : impossible si des volumes sont decrits par leurs aretes
c====
c
      if ( codret.eq.0 ) then
c
      if ( nbteca.eq.0 .and. nbheca.eq.0 .and.
     >     nbpyca.eq.0 .and. nbpeca.eq.0 ) then
c
c
      if ( nbteac.gt.0 .or. nbheac.gt.0 .or.
     >     nbpyac.gt.0 .or. nbpeac.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11B', nompro
#endif
        call utb11b ( nbblvo,
     >                hetare, somare,
     >                hettri, aretri,
     >                hetqua, arequa,
     >                hettet, tritet,
     >                hethex, quahex,
     >                hetpyr, facpyr,
     >                hetpen, facpen,
     >                povoso, voisom,
     >                posifa, facare,
     >                voltri, pypetr,
     >                volqua, pypequ,
     >                famare, cfaare,
     >                famtri, cfatri,
     >                famqua, cfaqua,
     >                famtet, cfatet,
     >                famhex, cfahex,
     >                fampyr, cfapyr,
     >                fampen, cfapen,
     >                tabau1, tabau2, tabau3, tabau4,
     >                taba11, taba12, taba13, taba14,
     >                taba15, taba16,
     >                nublen,
     >                ulbila,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,90002) 'Fin etape 2 avec codret', codret
      write(ulsort,texte(langue,5)) mess14(langue,3,3)
      write(ulsort,91040) (iaux,
     > iaux=1,min(20,nbteto+nbheto+nbpyto-nbquto))
      write(ulsort,10001)
      write(ulsort,91040) (nublen(iaux),
     > iaux=-nbquto,nbteto+nbheto+nbpyto-nbquto-1)
#endif
c
      endif
c
      endif
c
      endif
c
c====
c 3. blocs de faces
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. bloc de faces ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( nbtrac.gt.0 .or. nbquac.gt.0 ) then
c
c       on examine toutes les faces actives du calcul
c
        do 31 , iaux = -nbquto, nbtrto
          tabau4(iaux) = 1
   31   continue
        tabau4(0) = 0
        iaux = 2
c
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
     >                tabau1, tabau2, tabau3,
     >                taba15, taba16,
     >                nublen,
     >                ulbila,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Fin etape 3 avec codret', codret
      if ( nbtrac.gt.0  ) then
        write(ulsort,texte(langue,5)) mess14(langue,3,2)
        write(ulsort,91040) (iaux,iaux=1,min(20,nbtrto))
        write(ulsort,10001)
        write(ulsort,91040)
     >(nublen(iaux),iaux=-nbquto+1,-nbquto+min(100,nbtrto))
      endif
      if ( nbquac.gt.0  ) then
        write(ulsort,texte(langue,5)) mess14(langue,3,4)
        write(ulsort,91040) (iaux,iaux=1,min(20,nbquto))
        write(ulsort,10001)
        write(ulsort,91040)
     >(nublen(iaux),iaux=-nbquto,-nbquto+min(100,nbquto)-1)
      endif
#endif
c
      endif
c
      endif
c
c====
c 4. blocs d'aretes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. bloc d aretes ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
c       on examine toutes les aretes actives du calcul
c
        do 41 , iaux = 1, nbarto
          tabau3(iaux) = 1
   41   continue
        iaux = 2
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB11D', nompro
#endif
        call utb11d ( nbblar, iaux, tabau3,
     >                hetare, somare,
     >                povoso, voisom,
     >                famare, cfaare,
     >                tabau1, tabau2,
     >                nublen,
     >                ulbila,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Fin etape 4 avec codret', codret
      write(ulsort,texte(langue,5)) mess14(langue,3,1)
      write(ulsort,91040) (iaux,iaux=1,min(20,nbarto))
      write(ulsort,10001)
      write(ulsort,91040)
     >(nublen(iaux),iaux=-nbquto,-nbquto+min(100,nbarto)-1)
#endif
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
