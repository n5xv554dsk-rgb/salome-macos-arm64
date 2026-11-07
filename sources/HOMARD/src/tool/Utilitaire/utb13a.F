      subroutine utb13a ( coonoe,
     >                    somare, hetare,
     >                    hettri, aretri,
     >                    hetqua, arequa,
     >                    tritet, cotrte, aretet, hettet,
     >                    quahex, coquhe, arehex, hethex,
     >                    facpyr, cofapy, arepyr, hetpyr,
     >                    facpen, cofape, arepen, hetpen,
     >                    famare, cfaare,
     >                    famtri, cfatri,
     >                    famqua, cfaqua,
     >                    famtet, cfatet,
     >                    famhex, cfahex,
     >                    fampyr, cfapyr,
     >                    fampen, cfapen,
     >                    nbfmed, numfam, unicoo,
     >                    grfmpo, grfmtl, grfmtb,
     >                    nbgrfm, nomgro, lgnogr,
     >                    famnum, famval,
     >                    lifagr,
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
c    UTilitaire - Bilan sur le maillage - option 13
c    --           -                              --
c ______________________________________________________________________
c
c longueurs, surfaces et volumes des sous-domaines du maillage de calcul
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
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
c .        .     .        . + l : appartenance a l'equivalence l       .
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
c . nbfmed . e   .    1   . nombre de familles au sens MED             .
c . numfam . e   . nbfmed . numero des familles au sens MED            .
c . grfmpo . e   .0:nbfmed. pointeur des groupes des familles          .
c . grfmtl . e   .   *    . taille des groupes des familles            .
c . grfmtb . e   .10ngrouc. table des groupes des familles             .
c . unicoo . e   .(2,sdim). nom et unite des coordonnees au sens MED   .
c . nbgrfm . e   .    1   . nombre de groupes                          .
c . nomgro . e   .char*(*). noms des groupes (paquets de 10char8)      .
c . lgnogr . e   . nbgrfm . longueur des noms des groupes              .
c . famnum .  a  .   *    . famille : numero avec une valeur           .
c . famval .  a  .   *    . famille : la valeur                        .
c . lifagr .  a  .   *    . liste des familles contenant le groupe     .
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
      parameter ( nompro = 'UTB13A' )
c
#include "nblang.h"
c
c 0.2. ==> communs
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
#include "envca1.h"
c
#include "dicfen.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
c
      integer somare(2,nbarto), hetare(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hettet(nbteto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hethex(nbheto)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer hetpyr(nbpyto)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer hetpen(nbpeto)
c
      integer famare(nbarto), cfaare(nctfar,nbfare)
      integer famtri(nbtrto), cfatri(nctftr,nbftri)
      integer famqua(nbquto), cfaqua(nctfqu,nbfqua)
      integer famtet(nbteto), cfatet(nctfte,nbftet)
      integer famhex(nbheto), cfahex(nctfhe,nbfhex)
      integer fampyr(nbpyto), cfapyr(nctfpy,nbfpyr)
      integer fampen(nbpeto), cfapen(nctfpe,nbfpen)
c
      integer nbfmed, numfam(nbfmed)
      integer grfmpo(0:nbfmed)
      integer grfmtl(*)
      integer nbgrfm, lgnogr(nbgrfm)
c
      character*8 grfmtb(*)
      character*8 nomgro(*)
      character*16 unicoo(2,sdim)
c
      integer famnum(*)
      double precision famval(*)
c
      integer  lifagr(*)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
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
     >'(//,3x,''TAILLES DES SOUS-DOMAINES DE CALCUL'',/,3x,35(''=''),/)'
      texte(1,5) =
     > '(/,10x,''Direction      |       Unite'',/,5x,41(''-''))'
      texte(1,6) = '(8x,a16,'' |  '',a16)'
c
      texte(2,4) =
     > '(//,3x,''SIZES OF CALCULATION SUB-DOMAINS'',/,3x,32(''=''),/)'
      texte(2,5) =
     < '(/,10x,''Direction      |       Unit'',/,5x,41(''-''))'
      texte(2,6) = '(8x,a16,'' |  '',a16)'
c
#include "impr03.h"
c
      codret = 0
c
      write (ulbila,texte(langue,4))
c
      write (ulbila,texte(langue,5))
      do 11 , iaux = 1 , sdim
        write (ulbila,texte(langue,6)) unicoo(1,iaux), unicoo(2,iaux)
   11 continue
c
c====
c 2. volumes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. volumes : codret', codret
#endif
c
      if ( nbteac.gt.0 .or. nbheac.gt.0 .or.
     >     nbpyac.gt.0 .or. nbpeac.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB13B', nompro
#endif
        call utb13b ( coonoe,
     >                somare,
     >                aretri,
     >                arequa,
     >                tritet, cotrte, aretet, hettet,
     >                quahex, coquhe, arehex, hethex,
     >                facpyr, cofapy, arepyr, hetpyr,
     >                facpen, cofape, arepen, hetpen,
     >                famtet, cfatet,
     >                famhex, cfahex,
     >                fampyr, cfapyr,
     >                fampen, cfapen,
     >                nbfmed, numfam,
     >                grfmpo, grfmtl, grfmtb,
     >                nbgrfm, nomgro, lgnogr,
     >                famnum, famval,
     >                lifagr,
     >                ulbila,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 3. surfaces
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. surfaces : codret', codret
#endif
c
      if ( nbtrac.gt.0 .or. nbquac.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB13C', nompro
#endif
        call utb13c ( coonoe,
     >                somare,
     >                hettri, aretri,
     >                hetqua, arequa,
     >                famtri, cfatri,
     >                famqua, cfaqua,
     >                nbfmed, numfam,
     >                grfmpo, grfmtl, grfmtb,
     >                nbgrfm, nomgro, lgnogr,
     >                famnum, famval,
     >                lifagr,
     >                ulbila,
     >                ulsort, langue, codret )
c
c
      endif
c
c====
c 4. longueurs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. longueurs : codret', codret
#endif
c
      if ( nbarac.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB13D', nompro
#endif
        call utb13d ( coonoe,
     >                somare, hetare,
     >                famare, cfaare,
     >                nbfmed, numfam,
     >                grfmpo, grfmtl, grfmtb,
     >                nbgrfm, nomgro, lgnogr,
     >                famnum, famval,
     >                lifagr,
     >                ulbila,
     >                ulsort, langue, codret )
c
      endif
c
      end
