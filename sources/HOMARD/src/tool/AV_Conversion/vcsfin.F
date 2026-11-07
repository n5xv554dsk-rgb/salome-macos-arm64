      subroutine vcsfin ( suifro,
     >                    coexar, coextr, coexqu,
     >                    nbgrof, nbfrgr, nbfran, nbf, nbelem,
     >                    pointl, taigrl, nomgrl,
     >                    cacfpo, cacfta, cacfnm,
     >                    calfpo, calfta, calfnm,
     >                    calgpo, calgta, calgnm,
     >                    pointe, nomgrf,
     >                    frofam, typefr, nogrfr,
     >                    nuelex, narsho,
     >                    fameel, typele,
     >                    numfam, nomfam,
     >                    aretri, ntrsho,
     >                    arequa, nqusho,
     >                    ulsort, langue, codret)
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
c    aVant adaptation - Conversion
c     -                 -
c                     - Suivi de Frontiere - INitialisation
c                       -        -           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . suifro . e   .   1    . 1 : pas de suivi de frontiere              .
c .        .     .        . 2x : frontiere discrete                    .
c .        .     .        . 3x : frontiere analytique                  .
c .        .     .        . 5x : frontiere cao                         .
c . coexar . es  . nbarto*. codes de conditions aux limites portants   .
c .        .     . nctfar . sur les aretes                             .
c . coextr . es  . nbtrto*. codes de conditions aux limites portants   .
c .        .     . nctfar . sur les triangles                          .
c . coexqu . es  . nbquto*. codes de conditions aux limites portants   .
c .        .     . nctfqu . sur les quadrangles                        .
c . nbgrof . e   .   1    . nombre de groupes pour la frontiere        .
c . nbfrgr . e   .    1   . nombre de liens frontiere/groupe           .
c . nbfran . e   .    1   . nombre de frontieres analytiques           .
c . nbf    . e   .   1    . nombre de familles du maillage de calcul   .
c . nbelem . e   .   1    . nombre d'elements dans le maillage         .
c . pointl . e   .0:nbgrof. pointeur sur le tableau nomgrl             .
c . taigrl . e   .   *    . taille des noms des groupes des lignes     .
c . nomgrl . e   .   *    . noms des groupes des lignes                .
c . cacfpo . e   .0:nbfran. pointeurs sur le tableau du nom frontieres .
c . cacfta . e   .10nbfran. taille du nom des frontieres               .
c . cacfnm . e   .10nbfran. nom des frontieres                         .
c . calfpo . e   .0:nbfrgr. pointeurs sur le tableau du nom frontieres .
c . calfta . e   .10nbfrgr. taille du nom des frontieres               .
c . calfnm . e   .10nbfrgr. nom des frontieres                         .
c . calgpo . e   .0:nbfrgr. pointeurs sur le tableau du nom groupes    .
c . calgta . e   .10nbfrgr. taille du nom des groupes                  .
c . calgnm . e   .10nbfrgr. nom des groupes                            .
c . pointe . e   . 0:nbf  . pointeur sur le tableau nomgrf             .
c . nomgrf . e   .   *    . noms des groupes des familles              .
c . frofam .  s  .   nbf  . donne l'eventuel numero de frontiere       .
c .        .     .        . associee a chaque famille MED              .
c . typefr .  s  .   nbf  . type de frontiere (1:ligne/-1:surface)     .
c . nogrfr .  s  . 10*nbf . nom des groupes frontieres CAO             .
c . nuelex . e   . nbelem . numerotation des elements en exterieur     .
c . narsho . e   . rsarac . numero des aretes dans HOMARD              .
c . fameel . e   . nbelem . famille med des elements                   .
c . typele . e   . nbelem . type des elements pour le code de calcul   .
c . numfam . e   .   1    . numero MED des familles                    .
c . nomfam . e   . 10*nbf . nom des familles MED                       .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . ntrsho . e   . rstrac . numero des triangles dans HOMARD           .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . nqusho . e   . rsquac . numero des quadrangles dans HOMARD         .
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
      parameter ( nompro = 'VCSFIN' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nombar.h"
#include "nombqu.h"
#include "nombtr.h"
c
c 0.3. ==> arguments
c
      integer suifro
      integer nbgrof, nbfrgr, nbfran, nbf, nbelem
      integer coexar(nbarto,nctfar)
      integer coextr(nbtrto,nctftr)
      integer coexqu(nbquto,nctfqu)
      integer frofam(nbf), typefr(nbf)
      integer pointl(0:nbgrof), taigrl(*)
      integer cacfpo(0:nbfran), cacfta(10*nbfran)
      integer calfpo(0:nbfrgr), calfta(10*nbfrgr)
      integer calgpo(0:nbfrgr), calgta(10*nbfrgr)
      integer pointe(0:nbf)
      integer nuelex(nbelem)
      integer narsho(*)
      integer fameel(nbelem), typele(nbelem)
      integer numfam(*)
      integer aretri(nbtrto,3), ntrsho(*)
      integer arequa(nbquto,4), nqusho(*)
c
      character*8 cacfnm(10*nbfran)
      character*8 calfnm(10*nbfrgr)
      character*8 calgnm(10*nbfrgr)
      character*8 nomgrl(*)
      character*8 nomgrf(*)
      character*8 nogrfr(10*nbf)
      character*8 nomfam(10,nbf)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
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
      texte(1,4) = '(''Nombre de groupes pour la frontiere :'',i10)'
      texte(1,5) = '(''Nombre de frontieres discretes   :'',i10)'
      texte(1,6) =
     > '(''Nombre de liens frontiere analytique / groupe :'',i10)'
c
      texte(2,4) = '(''Number of groupes for the boundary:'',i10)'
      texte(2,5) = '(''Number of discrete boundaries   :'',i10)'
      texte(2,6) =
     > '(''Number of links analytical boundary / group:'',i10)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'suifro', suifro
      write (ulsort,90002) 'nbf', nbf
#endif
c
#ifdef _DEBUG_HOMARD_
      if ( mod(suifro,5).eq.0 ) then
        write (ulsort,texte(langue,4)) nbgrof
      else
        write (ulsort,texte(langue,5)) nbgrof
        write (ulsort,texte(langue,6)) nbfrgr
      endif
#endif
c
      do 11 , iaux = 1, nbf
        typefr(iaux) = 0
   11 continue
      do 12 , iaux = 1, 10*nbf
        nogrfr(iaux) = blan08
   12 continue
c
c====
c 2. correspondance entre les familles du maillage de calcul
c    et les frontieres analytiques
c====
c
      if ( nbfrgr.gt.0 ) then
c
c 2.1. ==> Description par des groupes
c
        if ( codret.eq.0 ) then
c
        iaux = nbgrof
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCSFLL', nompro
#endif
        call vcsfll ( nbfrgr, nbfran, nbf,
     >                cacfpo, cacfta, cacfnm,
     >                calfpo, calfta, calfnm,
     >                calgpo, calgta, calgnm,
     >                pointe, nomgrf, numfam, nomfam,
     >                frofam,   iaux,
     >                ulsort, langue, codret )
c
        endif
c
c 2.2. ==> Impact dans les caracteristiques des faces
c
        if ( codret.eq.0 ) then
c
        iaux = nbgrof
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCSFAS', nompro
#endif
        call vcsfas ( nbelem, nbf,
     >                calgpo, calgta, calgnm,
     >                coexar, coextr, coexqu,
     >                frofam,   iaux, typefr, nogrfr,
     >                nuelex,
     >                fameel, typele, numfam,
     >                aretri, ntrsho,
     >                arequa, nqusho,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c====
c 3. correspondance entre les familles du maillage de calcul
c    et les frontieres discretes ou CAO
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Front. discretes/CAO ; codret', codret
#endif
c
      if ( nbgrof.gt.0 ) then
c
c 3.1. ==> Description par des groupes
c
        if ( codret.eq.0 ) then
c
        iaux = 0
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'VCSFLG', nompro
#endif
        call vcsflg ( nbgrof, nbf,
     >                pointl, taigrl, nomgrl,
     >                pointe, nomgrf, numfam, nomfam,
     >                frofam, iaux,
     >                ulsort, langue, codret )
c
        endif
c
c 3.2. ==> Impact dans les caracteristiques des faces
c          dans le cas de la frontiere CAO
c
        if ( mod(suifro,5).eq.0 ) then
c
          if ( codret.eq.0 ) then
c
          iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCSFAS', nompro
#endif
          call vcsfas ( nbelem, nbf,
     >                  pointl, taigrl, nomgrl,
     >                  coexar, coextr, coexqu,
     >                  frofam,   iaux, typefr, nogrfr,
     >                  nuelex,
     >                  fameel, typele, numfam,
     >                  aretri, ntrsho,
     >                  arequa, nqusho,
     >                  ulsort, langue, codret)
c
          endif
c
        endif
c
c 3.3. ==> Impact dans les caracteristiques des segments
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCSFAL', nompro
#endif
        call vcsfal ( nbelem, nbf,
     >                pointl, taigrl, nomgrl,
     >                coexar,
     >                frofam, typefr, nogrfr,
     >                nuelex, narsho,
     >                fameel, typele, numfam,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c====
c 4. La fin
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
