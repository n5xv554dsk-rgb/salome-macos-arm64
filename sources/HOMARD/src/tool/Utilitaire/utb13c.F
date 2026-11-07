      subroutine utb13c ( coonoe,
     >                    somare,
     >                    hettri, aretri,
     >                    hetqua, arequa,
     >                    famtri, cfatri,
     >                    famqua, cfaqua,
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
c    UTilitaire - Bilan sur le maillage - option 13 - phase c
c    --           -                              --         -
c ______________________________________________________________________
c
c surfaces des sous-domaines du maillage de calcul
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
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
      parameter ( nompro = 'UTB13C' )
c
#include "nblang.h"
#include "fracta.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
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
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer hetqua(nbquto), arequa(nbquto,4)
c
      integer famtri(nbtrto), cfatri(nctftr,nbftri)
      integer famqua(nbquto), cfaqua(nctfqu,nbfqua)
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
      integer sa1a2, sa2a3, sa3a4, sa4a1, sa3a1
      integer a1, a2, a3, a4
      integer letria, lequad
      integer etat
      integer famnbv
c
      double precision v1(3), v2(3), v3(3), vn(3), vdiag(3)
      double precision daux, daux1, daux2
c
      integer nbmess
      parameter (nbmess = 20 )
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
      texte(1,4) = '(''Nombre de '',a,'' actifs : '',i8)'
      texte(1,5) = '(''. Examen du '',a,i8)'
      texte(1,6) = '(''... Surface du '',a,i8,'' :'',g16.8)'
      texte(1,7) = '(''..... Stockage'',i8,'' pour la famille '',i8)'
c
      texte(2,4) = '(''Number of active '',a,'' : '',i8)'
      texte(2,5) = '(''. Examination of '',a,''#'',i8)'
      texte(2,6) = '(''... Surface of '',a,''#'',i8,'' :'',g14.6)'
      texte(2,7) = '(''..... Save'',i8,'' for familiy # '',i8)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,2), nbtrac
      write (ulsort,texte(langue,4)) mess14(langue,3,4), nbquac
#endif
c
      codret = 0
c
c====
c 2. calcul des surfaces
c====
c
c 2.1. ==> initialisation
c
      famnbv = 0
c
      if ( nbtrac.gt.0 .or. nbquac.gt.0 ) then
c
        jaux = nbtrac + nbquac
        do 21 , iaux = 1 , jaux
          famnum(iaux) = 0
          famval(iaux) = 0.d0
   21   continue
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) 'jaux = ', jaux
#endif
c
      endif
c
c 2.2. ==> les zones maillees en triangles
c
      if ( nbtrac.gt.0 ) then
c
        do 22 , letria = 1, nbtrto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,1,2), letria
#endif
c
          if ( cfatri(cotyel,famtri(letria)).ne.0 ) then
c
          etat = mod( hettri(letria) , 10 )
c
          if ( etat.eq.0 ) then
c
c 2.2.1. ==> les aretes et les noeuds du triangle
c
            iaux = aretri(letria,1)
            jaux = aretri(letria,2)
            kaux = aretri(letria,3)
c
            call utsotr ( somare, iaux, jaux, kaux,
     >                    sa1a2, sa2a3, sa3a1 )
c
c 2.2.2. ==> calcul de la surface
c            on rappelle que la surface d'un triangle est egale
c            a la moitie de la norme du produit vectoriel de deux
c            des vecteurs representant les aretes.
c
            if ( sdim.eq.2 ) then
c
              v2(1) = coonoe(sa2a3,1) - coonoe(sa1a2,1)
              v2(2) = coonoe(sa2a3,2) - coonoe(sa1a2,2)
c
              v3(1) = coonoe(sa3a1,1) - coonoe(sa1a2,1)
              v3(2) = coonoe(sa3a1,2) - coonoe(sa1a2,2)
c
              daux = abs( v2(1)*v3(2) - v2(2)*v3(1) )
c
            else
c
              v2(1) = coonoe(sa2a3,1) - coonoe(sa1a2,1)
              v2(2) = coonoe(sa2a3,2) - coonoe(sa1a2,2)
              v2(3) = coonoe(sa2a3,3) - coonoe(sa1a2,3)
c
              v3(1) = coonoe(sa3a1,1) - coonoe(sa1a2,1)
              v3(2) = coonoe(sa3a1,2) - coonoe(sa1a2,2)
              v3(3) = coonoe(sa3a1,3) - coonoe(sa1a2,3)
c
              vn(1) = v2(2)*v3(3) - v2(3)*v3(2)
              vn(2) = v2(3)*v3(1) - v2(1)*v3(3)
              vn(3) = v2(1)*v3(2) - v2(2)*v3(1)
c
              daux = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
            endif
c
            daux = unsde * daux
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,2), letria, daux
#endif
c
c 2.2.3. ==> stockage dans la bonne famille
c
            jaux = 0
            do 2231 , iaux = 1 , famnbv
              if ( famnum(iaux).eq.cfatri(cofamd,famtri(letria)) ) then
                jaux = iaux
                goto 2232
              endif
 2231       continue
            famnbv = famnbv + 1
            jaux = famnbv
            famnum(jaux) = cfatri(cofamd,famtri(letria))
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,7)) jaux, famnum(jaux)
#endif
c
 2232       continue
c
            famval(jaux) = famval(jaux) + daux
c
          endif
c
          endif
c
   22   continue
c
      endif
c
c 2.3. ==> les zones maillees en quadrangles
c
      if ( nbquac.gt.0 ) then
c
        do 23 , lequad = 1, nbquto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,1,4), lequad
#endif
c
          if ( cfaqua(cotyel,famqua(lequad)).ne.0 ) then
c
          etat = mod( hetqua(lequad) , 100 )
c
          if ( etat.eq.0 ) then
c
c 2.3.1. ==> les aretes et les noeuds du quadrangle
c
            a1 = arequa(lequad,1)
            a2 = arequa(lequad,2)
            a3 = arequa(lequad,3)
            a4 = arequa(lequad,4)
c
            call utsoqu ( somare, a1, a2, a3, a4,
     >                    sa1a2, sa2a3, sa3a4, sa4a1 )
c
c 2.3.2. ==> calcul de la surface
c            pour la calculer, on coupe le quadrangle en deux triangles
c            on rappelle que la surface d'un triangle est egale
c            a la moitie de la norme du produit vectoriel de deux
c            des vecteurs representant les aretes.
c           v1 : arete a1 (sa4a1-sa1a2)
c           v2 : arete a4 (sa4a1-sa3a4)
c           vdiag = diagonale(sa4a1-sa2a3)
c
c                      sa4a1  a4  sa3a4
c                          .______.
c                          ..     .
c                          . .    .
c                        a1.  .   .a3
c                          .   .  .
c                          .    . .
c                          .     ..
c                          .______.
c                      sa1a2   a2  sa2a3
c
            if ( sdim.eq.2 ) then
c
              v1(1)    = coonoe(sa1a2,1) - coonoe(sa4a1,1)
              v1(2)    = coonoe(sa1a2,2) - coonoe(sa4a1,2)
c
              v2(1)    = coonoe(sa3a4,1) - coonoe(sa4a1,1)
              v2(2)    = coonoe(sa3a4,2) - coonoe(sa4a1,2)
c
              vdiag(1) = coonoe(sa2a3,1) - coonoe(sa4a1,1)
              vdiag(2) = coonoe(sa2a3,2) - coonoe(sa4a1,2)
c
              daux1 = abs ( v1(1)*vdiag(2) - v1(2)*vdiag(1) )
c
              daux2 = abs ( v2(1)*vdiag(2) - v2(2)*vdiag(1) )
c
            else
c
              v1(1)    = coonoe(sa1a2,1) - coonoe(sa4a1,1)
              v1(2)    = coonoe(sa1a2,2) - coonoe(sa4a1,2)
              v1(3)    = coonoe(sa1a2,3) - coonoe(sa4a1,3)
c
              v2(1)    = coonoe(sa3a4,1) - coonoe(sa4a1,1)
              v2(2)    = coonoe(sa3a4,2) - coonoe(sa4a1,2)
              v2(3)    = coonoe(sa3a4,3) - coonoe(sa4a1,3)
c
              vdiag(1) = coonoe(sa2a3,1) - coonoe(sa4a1,1)
              vdiag(2) = coonoe(sa2a3,2) - coonoe(sa4a1,2)
              vdiag(3) = coonoe(sa2a3,3) - coonoe(sa4a1,3)
c
              vn(1) = v1(2)*vdiag(3) - v1(3)*vdiag(2)
              vn(2) = v1(3)*vdiag(1) - v1(1)*vdiag(3)
              vn(3) = v1(1)*vdiag(2) - v1(2)*vdiag(1)
c
              daux1 = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
              vn(1) = v2(2)*vdiag(3) - v2(3)*vdiag(2)
              vn(2) = v2(3)*vdiag(1) - v2(1)*vdiag(3)
              vn(3) = v2(1)*vdiag(2) - v2(2)*vdiag(1)
c
              daux2 = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
            endif
c
            daux = unsde * ( daux1 + daux2 )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) mess14(langue,1,4), lequad, daux
#endif
c
c 2.3.3. ==> stockage dans la bonne famille
c
            jaux = 0
            do 2331 , iaux = 1 , famnbv
              if ( famnum(iaux).eq.cfaqua(cofamd,famqua(lequad)) ) then
                jaux = iaux
                goto 2332
              endif
 2331       continue
            famnbv = famnbv + 1
            jaux = famnbv
            famnum(jaux) = cfaqua(cofamd,famqua(lequad))
c
 2332       continue
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,7)) jaux, famnum(jaux)
#endif
c
            famval(jaux) = famval(jaux) + daux
c
          endif
c
          endif
c
   23   continue
c
      endif
c
c====
c 3. impression
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. impression ; codret =', codret
      write (ulsort,90002) 'famnbv', famnbv
#endif
c
      if ( famnbv.ne.0 ) then
c
      iaux = 1
      kaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB13E_fac', nompro
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
