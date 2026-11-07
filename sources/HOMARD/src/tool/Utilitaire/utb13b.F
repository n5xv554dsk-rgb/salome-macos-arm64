      subroutine utb13b ( coonoe,
     >                    somare,
     >                    aretri,
     >                    arequa,
     >                    tritet, cotrte, aretet, hettet,
     >                    quahex, coquhe, arehex, hethex,
     >                    facpyr, cofapy, arepyr, hetpyr,
     >                    facpen, cofape, arepen, hetpen,
     >                    famtet, cfatet,
     >                    famhex, cfahex,
     >                    fampyr, cfapyr,
     >                    fampen, cfapen,
     >                    nbfmed, numfam,
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
c    UTilitaire - Bilan sur le maillage - option 13 - phase b
c    --           -                              --         -
c ______________________________________________________________________
c
c volumes des sous-domaines du maillage de calcul
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
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
c . cfapen . e   . nctfpe*. codes des familles des pentaedres          .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . nbfmed . e   .    1   . nombre de familles au sens MED             .
c . numfam . e   . nbfmed . numero des familles au sens MED            .
c . grfmpo . e   .0:nbfmed. pointeur des groupes des familles          .
c . grfmtl . e   .   *    . taille des groupes des familles            .
c . grfmtb . e   .10ngrouc. table des groupes des familles             .
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
      parameter ( nompro = 'UTB13B' )
c
#include "nblang.h"
#include "coftex.h"
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
#include "impr02.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
c
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hettet(nbteto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hethex(nbheto)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer hetpyr(nbpyto)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer hetpen(nbpeto)
c
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
      integer iaux, jaux, kaux
      integer entit0, entite, etat
      integer famnbv
      integer listar(12),listso(8)
c
      double precision daux
c
      integer nbmess
      parameter (nbmess = 20 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c 1.1. messages
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
      texte(1,6) = '(''... Volume du '',a,i8,'' :'',g16.8)'
      texte(1,7) = '(''..... Stockage'',i8,'' pour la famille '',i8)'
c
      texte(2,4) = '(''Number of active '',a,'': '',i8)'
      texte(2,5) = '(''. Examination of '',a,''#'',i8)'
      texte(2,6) = '(''... Volume of '',a,''#'',i8,'':'',g16.8)'
      texte(2,7) = '(''..... Save'',i8,'' for familiy #'',i8)'
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
c 1.2. ==> initialisation
c
      famnbv = 0
c
      codret = 0
c
      if ( nbteac.gt.0 .or. nbpyac.ne.0 .or.
     >     nbheac.ne.0 .or. nbpeac.ne.0 ) then
c
        jaux = nbteac + nbpyac + nbheac + nbpeac
        do 12 , iaux = 1 , jaux
          famnum(iaux) = 0
          famval(iaux) = 0.d0
   12   continue
c
      endif
c
c====
c 2. calcul des volumes des zones maillees en tetraedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. tetraedres, codret', codret
#endif
c
      if ( nbteac.gt.0 ) then
c
        do 2 , entit0 = 1, nbteto
c
          entite = entit0
c
          if ( cfatet(cotyel,famtet(entite)).ne.0 ) then
c
          etat = mod( hettet(entite) , 100 )
c
          if ( etat.eq.0 ) then
c
c 2.1. ==> les aretes et les sommets
c
            call utaste ( entite,
     >                    nbtrto, nbtecf, nbteca,
     >                    somare, aretri,
     >                    tritet, cotrte, aretet,
     >                    listar, listso )
c
c 2.2. ==> calcul du volume du tetraedre
c
            call utvote ( coonoe, listso,  daux )
cgn            if ( famtet(entite).eq.2 ) then
cgn      write (ulsort,texte(langue,6)) mess14(langue,1,3), entite, daux
cgn           endif
c
c 2.3. ==> stockage dans la bonne famille
c
            kaux = 0
            do 23 , jaux = 1 , famnbv
              if ( famnum(jaux).eq.cfatet(cofamd,famtet(entite)) ) then
                kaux = jaux
                goto 231
              endif
   23       continue
            famnbv = famnbv + 1
            kaux = famnbv
            famnum(kaux) = cfatet(cofamd,famtet(entite))
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,7)) kaux, famnum(kaux)
#endif
c
  231       continue
c
            famval(kaux) = famval(kaux) + daux
c
          endif
c
          endif
c
    2   continue
c
      endif
c
c====
c 3. calcul des volumes des zones maillees en hexaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. hexaedres, codret', codret
#endif
c
      if ( nbheac.gt.0 ) then
c
        do 3 , entit0 = 1, nbheto
c
          entite = entit0
c
cgn       write (ulsort,90001) '. Famille hexa', entite, famhex(entite)
          if ( cfahex(cotyel,famhex(entite)).ne.0 ) then
c
cgn       write (ulsort,90001) '.. Etat hexa', entite, hethex(entite)
          etat = mod(hethex(entite),1000)
c
          if ( etat.eq.0 ) then
c
c 3.1. ==> les aretes et les sommets
c
            call utashe ( entite,
     >                    nbquto, nbhecf, nbheca,
     >                    somare, arequa,
     >                    quahex, coquhe, arehex,
     >                    listar, listso )
c
c 3.2. ==> calcul du volume de l'hexraedre
c
            call utvohe ( coonoe, listso,  daux )
cgn            if ( famhex(entite).eq.5 ) then
cgn      write (ulsort,texte(langue,6)) mess14(langue,1,6), entite, daux
cgn           endif
c
c 3.3. ==> stockage dans la bonne famille
c
            kaux = 0
            do 33 , jaux = 1 , famnbv
              if ( famnum(jaux).eq.cfahex(cofamd,famhex(entite)) ) then
                kaux = jaux
                goto 331
              endif
   33       continue
            famnbv = famnbv + 1
            kaux = famnbv
            famnum(kaux) = cfahex(cofamd,famhex(entite))
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,7)) kaux, famnum(kaux)
#endif
c
  331       continue
c
            famval(kaux) = famval(kaux) + daux
c
          endif
c
          endif
c
   3   continue
c
      endif
c
c====
c 4. calcul des volumes des zones maillees en pyramides
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. pyramides, codret', codret
#endif
c
      if ( nbpyac.gt.0 ) then
c
        do 4 , entit0 = 1, nbpyto
c
          entite = entit0
c
          if ( cfapyr(cotyel,fampyr(entite)).ne.0 ) then
c
          etat = mod( hetpyr(entite) , 100)
c
          if ( etat.eq.0 ) then
c
c 4.1. ==> les aretes
c
            call utaspy ( entite,
     >                    nbtrto, nbpycf, nbpyca,
     >                    somare, aretri,
     >                    facpyr, cofapy, arepyr,
     >                    listar, listso )
c
c 4.2. ==> calcul du volume de la pyramide
c
            call utvopy ( coonoe, listso,  daux )
cgn            if ( fampyr(entite).eq.5 ) then
cgn      write (ulsort,texte(langue,6)) mess14(langue,1,5), entite, daux
cgn           endif
c
c 4.3. ==> stockage dans la bonne famille
c
            kaux = 0
            do 43 , jaux = 1 , famnbv
              if ( famnum(jaux).eq.cfapyr(cofamd,fampyr(entite)) ) then
                kaux = jaux
                goto 431
              endif
   43       continue
            famnbv = famnbv + 1
            kaux = famnbv
            famnum(kaux) = cfapyr(cofamd,fampyr(entite))
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,7)) kaux, famnum(kaux)
#endif
c
  431       continue
c
            famval(kaux) = famval(kaux) + daux
c
          endif
c
          endif
c
   4   continue
c
      endif
c
c====
c 5. calcul des volumes des zones maillees en pentaedres
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. pentaedres, codret', codret
#endif
c
      if ( nbpeac.gt.0 ) then
c
        do 5 , entit0 = 1, nbpeto
c
          entite = entit0
c
          if ( cfapen(cotyel,fampen(entite)).ne.0 ) then
c
          etat = mod( hetpen(entite) , 100)
c
          if ( etat.eq.0 ) then
c
c 5.1. ==> les aretes
c
            call utaspe ( entite,
     >                    nbquto, nbpecf, nbpeca,
     >                    somare, arequa,
     >                    facpen, cofape, arepen,
     >                    listar, listso )
c
c 5.2. ==> calcul du volume du pentaedre
c
            call utvope ( coonoe, listso,  daux )
cgn            if ( fampen(entite).eq.5 ) then
cgn      write (ulsort,texte(langue,6)) mess14(langue,1,7), entite, daux
cgn           endif
c
c 5.3. ==> stockage dans la bonne famille
c
            kaux = 0
            do 53 , jaux = 1 , famnbv
              if ( famnum(jaux).eq.cfapen(cofamd,fampen(entite)) ) then
                kaux = jaux
                goto 531
              endif
   53       continue
            famnbv = famnbv + 1
            kaux = famnbv
            famnum(kaux) = cfapen(cofamd,fampen(entite))
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,7)) kaux, famnum(kaux)
#endif
c
  531       continue
c
            famval(kaux) = famval(kaux) + daux
c
          endif
c
          endif
c
   5   continue
c
      endif
c
c====
c 6. impression
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. impression ; codret =', codret
      write (ulsort,90002) 'famnbv', famnbv
#endif
c
      if ( famnbv.ne.0 ) then
c
      iaux = 1
      kaux = 3
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB13E_vol', nompro
#endif
      call utb13e ( kaux, iaux,
     >              nbfmed, numfam,
     >              grfmpo, grfmtl, grfmtb,
     >              nbgrfm, nomgro, lgnogr,
     >              famnbv, famnum, famval,
     >              lifagr,
     >              ulbila,
     >              ulsort, langue, codret )
c
      endif
c
      end
